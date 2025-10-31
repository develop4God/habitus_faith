import 'dart:async';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';
import '../../../features/habits/domain/models/micro_habit.dart';
import '../../../features/habits/domain/models/generation_request.dart';
import '../cache/cache_service.dart';
import 'rate_limit_service.dart';
import 'gemini_exceptions.dart';

/// Interface for Gemini AI service (state-agnostic)
abstract class IGeminiService {
  Future<List<MicroHabit>> generateMicroHabits(GenerationRequest request);
  int getRemainingRequests();
}

/// Gemini AI service for generating micro-habits
/// Pure Dart implementation with no state management dependencies
class GeminiService implements IGeminiService {
  final GenerativeModel _model;
  final ICacheService _cache;
  final IRateLimitService _rateLimit;

  /// Default timeout for API requests
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Expected number of habits per generation request
  static const int expectedHabitsCount = 3;

  /// Maximum input length for user fields
  static const int maxInputLength = 200;

  /// Blacklisted terms that could indicate prompt injection
  static const List<String> blacklistedTerms = [
    'ignore',
    'previous',
    'system:',
    'prompt:',
    'instructions'
  ];

  GeminiService({
    required String apiKey,
    required String modelName,
    required ICacheService cache,
    required IRateLimitService rateLimit,
  })  : _cache = cache,
        _rateLimit = rateLimit,
        _model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
        );

  @override
  Future<List<MicroHabit>> generateMicroHabits(
      GenerationRequest request) async {
    // 1. Sanitize inputs to prevent prompt injection
    final sanitizedGoal = _sanitizeInput(request.userGoal, 'userGoal');
    final sanitizedPattern = request.failurePattern != null
        ? _sanitizeInput(request.failurePattern!, 'failurePattern')
        : null;

    // 2. Check rate limit atomically (10/month)
    if (!await _rateLimit.tryConsumeRequest()) {
      throw RateLimitExceededException(
        'Monthly limit of ${RateLimitService.maxRequests} requests reached. '
        'Limit will reset next month.',
      );
    }

    // 3. Check cache (7 day expiry)
    final cacheKey = request.toCacheKey();
    final cached = await _cache.get<List<MicroHabit>>(cacheKey);
    if (cached != null) return cached;

    // 4. Build prompt with sanitized inputs
    final prompt = _buildPrompt(
      sanitizedGoal,
      sanitizedPattern,
      request.faithContext,
      request.languageCode,
    );

    // 5. Call Gemini API with timeout
    try {
      final response = await _model
          .generateContent([Content.text(prompt)]).timeout(defaultTimeout);

      // 6. Parse JSON response
      final habits = _parseResponse(response.text, request.languageCode);

      // 7. Cache result
      await _cache.set(cacheKey, habits, ttl: const Duration(days: 7));

      return habits;
    } on TimeoutException {
      throw GeminiException(
        'Request timed out after ${defaultTimeout.inSeconds} seconds. Please try again.',
      );
    } catch (e) {
      if (e is GeminiException) rethrow;
      throw GeminiException('Failed to generate habits: $e');
    }
  }

  @override
  int getRemainingRequests() => _rateLimit.getRemainingRequests();

  /// Sanitize user input to prevent prompt injection attacks
  String _sanitizeInput(String input, String fieldName) {
    if (input.length > maxInputLength) {
      throw InvalidInputException(
          '$fieldName exceeds $maxInputLength characters');
    }

    final lowerInput = input.toLowerCase();
    for (final term in blacklistedTerms) {
      if (lowerInput.contains(term)) {
        throw InvalidInputException('Invalid characters in $fieldName');
      }
    }

    // Strip/escape special characters
    return input.replaceAll(RegExp(r'["\\{}\n\r]'), '');
  }

  String _buildPrompt(
    String userGoal,
    String? failurePattern,
    String faithContext,
    String languageCode,
  ) {
    return '''
Usuario quiere: "$userGoal"
Falla típicamente: ${failurePattern ?? 'desconocido'}
Fe: $faithContext
Idioma respuesta: $languageCode

Genera EXACTAMENTE $expectedHabitsCount micro-hábitos cristianos. Cada hábito debe:
1. Ser completable en 5 minutos o menos
2. Incluir acción específica y medible
3. Incluir versículo bíblico relevante (referencia + texto completo)
4. Explicar propósito espiritual en UNA oración

Responde SOLO con JSON válido (sin markdown, sin ```json):
[
  {
    "action": "Acción específica en infinitivo (ej: 'Orar 3min al despertar')",
    "verse": "Libro capítulo:versículo",
    "verseText": "Texto completo del versículo",
    "purpose": "Por qué este hábito honra a Dios (1 oración)",
    "estimatedMinutes": 3
  }
]

Requisitos estrictos:
- Acciones deben ser ESPECÍFICAS (no "orar más" sino "orar 3min después de café")
- Versículos deben ser EXACTOS (formato: Libro número:número)
- Propósito debe conectar con $faithContext
- Tono: motivacional, práctico, esperanzador
''';
  }

  List<MicroHabit> _parseResponse(String? responseText, String langCode) {
    // Enhanced null safety checks
    if (responseText == null || responseText.trim().isEmpty) {
      throw GeminiParseException('API returned empty response', '');
    }

    try {
      // Remove markdown code blocks if present
      final cleaned = responseText
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      if (cleaned.isEmpty) {
        throw GeminiParseException(
            'Empty response after cleanup', responseText);
      }

      final dynamic json = jsonDecode(cleaned);

      // Validate JSON structure
      if (json is! List) {
        throw GeminiParseException('Expected JSON array', responseText);
      }

      if (json.length != expectedHabitsCount) {
        throw GeminiParseException(
          'Expected $expectedHabitsCount habits, got ${json.length}',
          responseText,
        );
      }

      return json.asMap().entries.map((entry) {
        final data = entry.value as Map<String, dynamic>;

        // Validate required fields
        if (!data.containsKey('action') ||
            !data.containsKey('verse') ||
            !data.containsKey('purpose')) {
          throw GeminiParseException(
            'Missing required fields in habit ${entry.key}',
            responseText,
          );
        }

        return MicroHabit(
          id: const Uuid().v4(),
          action: data['action'],
          verse: data['verse'],
          verseText: data['verseText'],
          purpose: data['purpose'],
          estimatedMinutes: data['estimatedMinutes'] ?? 5,
          generatedAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      if (e is GeminiParseException) rethrow;
      throw GeminiParseException(
        'Failed to parse response: $e',
        responseText,
      );
    }
  }
}
