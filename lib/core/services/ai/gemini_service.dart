import 'dart:async';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import '../../../features/habits/domain/models/micro_habit.dart';
import '../../../features/habits/domain/models/generation_request.dart';
import '../../../bible_reader_core/src/bible_db_service.dart';
import '../cache/cache_service.dart';
import '../../config/ai_config.dart';
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
  final BibleDbService? _bibleService;
  final Logger? _logger;

  GeminiService({
    required String apiKey,
    required String modelName,
    required ICacheService cache,
    required IRateLimitService rateLimit,
    BibleDbService? bibleService,
    Logger? logger,
  })  : _cache = cache,
        _rateLimit = rateLimit,
        _bibleService = bibleService,
        _logger = logger,
        _model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
        );

  @override
  Future<List<MicroHabit>> generateMicroHabits(
      GenerationRequest request) async {
    _logger?.i('Starting habit generation for goal: "${request.userGoal}"');

    // 1. Sanitize inputs to prevent prompt injection
    final sanitizedGoal = _sanitizeInput(request.userGoal, 'userGoal');
    final sanitizedPattern = request.failurePattern != null
        ? _sanitizeInput(request.failurePattern!, 'failurePattern')
        : null;

    _logger?.d(
        'Input sanitized - Goal length: ${sanitizedGoal.length}, Pattern: ${sanitizedPattern != null ? "provided" : "none"}');

    // 2. Check rate limit atomically (10/month)
    if (!await _rateLimit.tryConsumeRequest()) {
      _logger?.w('Rate limit exceeded - remaining: 0');
      throw RateLimitExceededException(
        'Monthly limit of ${AiConfig.monthlyRequestLimit} requests reached. '
        'Limit will reset next month.',
      );
    }

    final remaining = _rateLimit.getRemainingRequests();
    _logger?.i('Rate limit check passed - remaining: $remaining');

    // 3. Check cache (7 day expiry)
    final cacheKey = request.toCacheKey();
    final cached = await _cache.get<List<MicroHabit>>(cacheKey);
    if (cached != null) {
      _logger?.i('Cache hit for key: $cacheKey');
      return cached;
    }

    _logger?.d('Cache miss - calling Gemini API');

    // 4. Build prompt with sanitized inputs
    final prompt = _buildPrompt(
      sanitizedGoal,
      sanitizedPattern,
      request.faithContext,
      request.languageCode,
    );

    // 5. Call Gemini API with timeout
    try {
      _logger?.d('Sending request to Gemini API...');
      final response = await _model.generateContent(
          [Content.text(prompt)]).timeout(AiConfig.requestTimeout);

      _logger?.i('Received response from Gemini API');

      // 6. Parse and validate JSON response
      final habits = _parseResponse(response.text, request.languageCode);

      _logger?.i('Successfully parsed ${habits.length} habits');

      // 7. Enrich with verse text if Bible service available
      final enrichedHabits = await _enrichWithVerseText(habits);

      // 8. Cache result
      await _cache.set(cacheKey, enrichedHabits, ttl: AiConfig.cacheTtl);

      _logger?.i('Habits cached successfully');

      return enrichedHabits;
    } on TimeoutException {
      _logger?.e(
          'API request timed out after ${AiConfig.requestTimeout.inSeconds}s');
      throw GeminiException(
        'Request timed out after ${AiConfig.requestTimeout.inSeconds} seconds. Please try again.',
      );
    } catch (e) {
      _logger?.e('Error during habit generation', error: e);
      if (e is GeminiException) rethrow;
      throw GeminiException('Failed to generate habits: $e');
    }
  }

  @override
  int getRemainingRequests() => _rateLimit.getRemainingRequests();

  /// Sanitize user input to prevent prompt injection attacks
  String _sanitizeInput(String input, String fieldName) {
    if (input.length > AiConfig.maxInputLength) {
      throw InvalidInputException(
          '$fieldName exceeds ${AiConfig.maxInputLength} characters');
    }

    final lowerInput = input.toLowerCase();
    for (final term in AiConfig.blacklistedTerms) {
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

Genera EXACTAMENTE ${AiConfig.habitsPerGeneration} micro-hábitos cristianos. Cada hábito debe:
1. Ser completable en ${AiConfig.maxHabitMinutes} minutos o menos
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

      // Validate JSON structure - must be a List
      if (json is! List) {
        throw GeminiParseException(
            'Expected JSON array, got ${json.runtimeType}', responseText);
      }

      // Validate exact count
      if (json.length != AiConfig.habitsPerGeneration) {
        throw GeminiParseException(
          'Expected ${AiConfig.habitsPerGeneration} habits, got ${json.length}',
          responseText,
        );
      }

      // Parse each habit with individual error handling
      return json.asMap().entries.map((entry) {
        try {
          final data = entry.value as Map<String, dynamic>;

          // Validate required fields
          for (final field in AiConfig.requiredHabitFields) {
            if (!data.containsKey(field)) {
              throw GeminiParseException(
                'Missing required field "$field" in habit #${entry.key + 1}',
                data.toString(),
              );
            }
          }

          return MicroHabit(
            id: const Uuid().v4(),
            action: data['action'],
            verse: data['verse'],
            verseText: data['verseText'],
            purpose: data['purpose'],
            estimatedMinutes:
                data['estimatedMinutes'] ?? AiConfig.maxHabitMinutes,
            generatedAt: DateTime.now(),
          );
        } catch (e) {
          if (e is GeminiParseException) rethrow;
          throw GeminiParseException(
            'Failed to parse habit #${entry.key + 1}: $e',
            entry.value.toString(),
          );
        }
      }).toList();
    } catch (e) {
      if (e is GeminiParseException) rethrow;
      throw GeminiParseException(
        'Failed to parse response: $e',
        responseText,
      );
    }
  }

  /// Enrich habits with full verse text from Bible database
  Future<List<MicroHabit>> _enrichWithVerseText(List<MicroHabit> habits) async {
    if (_bibleService == null) {
      _logger?.d('Bible service not available - skipping verse enrichment');
      return habits;
    }

    _logger?.i('Enriching ${habits.length} habits with verse text');

    return Future.wait(habits.map((habit) async {
      try {
        final verseData = await _parseAndFetchVerse(habit.verse);
        if (verseData != null) {
          _logger?.d('Successfully fetched verse: ${habit.verse}');
          return habit.copyWith(verseText: verseData['text'] as String?);
        } else {
          _logger?.w('Verse not found in database: ${habit.verse}');
          return habit;
        }
      } catch (e) {
        _logger?.w('Failed to fetch verse "${habit.verse}": $e');
        return habit; // Keep original without text
      }
    }));
  }

  /// Parse verse reference and fetch from database
  Future<Map<String, dynamic>?> _parseAndFetchVerse(String verseRef) async {
    if (_bibleService == null) return null;

    // Parse verse reference (e.g., "Salmos 5:3" or "Juan 3:16")
    final regex = RegExp(r'(\w+)\s+(\d+):(\d+)');
    final match = regex.firstMatch(verseRef);

    if (match == null) {
      _logger?.w('Invalid verse format: $verseRef');
      return null;
    }

    // Extract book name, chapter, verse
    final bookName = match.group(1);
    final chapter = int.tryParse(match.group(2) ?? '');
    final verse = int.tryParse(match.group(3) ?? '');

    if (chapter == null || verse == null) {
      return null;
    }

    // Map Spanish book names to book numbers (simplified mapping)
    final bookNumber = _getBookNumber(bookName ?? '');
    if (bookNumber == null) {
      _logger?.w('Unknown book name: $bookName');
      return null;
    }

    return await _bibleService!.getVerse(
      bookNumber: bookNumber,
      chapter: chapter,
      verse: verse,
    );
  }

  /// Map book name to book number (complete 66 books with variations)
  int? _getBookNumber(String bookName) {
    // Normalize the book name
    final normalized = bookName
        .toLowerCase()
        .replaceAll('1 ', 'primer ')
        .replaceAll('2 ', 'segundo ')
        .replaceAll('3 ', 'tercer ')
        .replaceAll('i ', 'primer ')
        .replaceAll('ii ', 'segundo ')
        .replaceAll('iii ', 'tercer ')
        .trim();

    final mapping = {
      // Old Testament (1-39)
      'génesis': 1,
      'genesis': 1,
      'gn': 1,
      'éxodo': 2,
      'exodo': 2,
      'ex': 2,
      'levítico': 3,
      'levitico': 3,
      'lv': 3,
      'números': 4,
      'numeros': 4,
      'nm': 4,
      'deuteronomio': 5,
      'dt': 5,
      'josué': 6,
      'josue': 6,
      'jos': 6,
      'jueces': 7,
      'jue': 7,
      'rut': 8,
      'rt': 8,
      'primer samuel': 9,
      '1samuel': 9,
      'samuel': 9, // Default to 1 Samuel
      'segundo samuel': 10,
      '2samuel': 10,
      'primer reyes': 11,
      '1reyes': 11,
      'reyes': 11, // Default to 1 Reyes
      'segundo reyes': 12,
      '2reyes': 12,
      'primer crónicas': 13,
      '1crónicas': 13,
      '1cronicas': 13,
      'crónicas': 13, // Default to 1 Crónicas
      'cronicas': 13,
      'segundo crónicas': 14,
      '2crónicas': 14,
      '2cronicas': 14,
      'esdras': 15,
      'nehemías': 16,
      'nehemias': 16,
      'ester': 17,
      'job': 18,
      'salmos': 19,
      'salmo': 19,
      'sal': 19,
      'proverbios': 20,
      'pr': 20,
      'eclesiastés': 21,
      'eclesiástes': 21,
      'ec': 21,
      'cantares': 22,
      'cnt': 22,
      'isaías': 23,
      'isaias': 23,
      'is': 23,
      'jeremías': 24,
      'jeremias': 24,
      'jer': 24,
      'lamentaciones': 25,
      'lam': 25,
      'ezequiel': 26,
      'ez': 26,
      'daniel': 27,
      'dn': 27,
      'oseas': 28,
      'os': 28,
      'joel': 29,
      'jl': 29,
      'amós': 30,
      'amos': 30,
      'am': 30,
      'abdías': 31,
      'abdias': 31,
      'abd': 31,
      'jonás': 32,
      'jonas': 32,
      'jon': 32,
      'miqueas': 33,
      'miq': 33,
      'nahúm': 34,
      'nahum': 34,
      'nah': 34,
      'habacuc': 35,
      'hab': 35,
      'sofonías': 36,
      'sofonias': 36,
      'sof': 36,
      'hageo': 37,
      'hag': 37,
      'zacarías': 38,
      'zacarias': 38,
      'zac': 38,
      'malaquías': 39,
      'malaquias': 39,
      'mal': 39,

      // New Testament (40-66)
      'mateo': 40,
      'mt': 40,
      'marcos': 41,
      'mr': 41,
      'mc': 41,
      'lucas': 42,
      'lc': 42,
      'juan': 43,
      'jn': 43,
      'hechos': 44,
      'hch': 44,
      'romanos': 45,
      'ro': 45,
      'rom': 45,
      'primer corintios': 46,
      '1corintios': 46,
      'corintios': 46, // Default to 1 Corintios
      'segundo corintios': 47,
      '2corintios': 47,
      'gálatas': 48,
      'galatas': 48,
      'ga': 48,
      'gal': 48,
      'efesios': 49,
      'ef': 49,
      'filipenses': 50,
      'fil': 50,
      'colosenses': 51,
      'col': 51,
      'primer tesalonicenses': 52,
      '1tesalonicenses': 52,
      'tesalonicenses': 52, // Default to 1 Tesalonicenses
      'segundo tesalonicenses': 53,
      '2tesalonicenses': 53,
      'primer timoteo': 54,
      '1timoteo': 54,
      'timoteo': 54, // Default to 1 Timoteo
      'segundo timoteo': 55,
      '2timoteo': 55,
      'tito': 56,
      'tit': 56,
      'filemón': 57,
      'filemon': 57,
      'flm': 57,
      'hebreos': 58,
      'heb': 58,
      'santiago': 59,
      'stg': 59,
      'primer pedro': 60,
      '1pedro': 60,
      'pedro': 60, // Default to 1 Pedro
      'segundo pedro': 61,
      '2pedro': 61,
      'primer juan': 62,
      '1juan': 62,
      'segundo juan': 63,
      '2juan': 63,
      'tercer juan': 64,
      '3juan': 64,
      'judas': 65,
      'jud': 65,
      'apocalipsis': 66,
      'ap': 66,
      'apc': 66,
    };

    return mapping[normalized];
  }
}
