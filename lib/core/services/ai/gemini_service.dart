import 'dart:async';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../features/habits/domain/models/micro_habit.dart';
import '../../../features/habits/domain/models/generation_request.dart';
import '../../../features/habits/domain/habit.dart';
import '../../../features/habits/presentation/onboarding/onboarding_models.dart';
import '../../../bible_reader_core/src/bible_db_service.dart';
import '../cache/cache_service.dart';
import '../../config/ai_config.dart';
import 'rate_limit_service.dart';
import 'gemini_exceptions.dart';
import 'gemini_template_firestore_service.dart';

/// Interface for Gemini AI service (state-agnostic)
abstract class IGeminiService {
  Future<List<MicroHabit>> generateMicroHabits(GenerationRequest request);
  Future<List<Map<String, dynamic>>> generateHabitsFromProfile(
    OnboardingProfile profile,
    String userId, {
    String language = 'es',
    bool isOnboarding = false,
  });
  int getRemainingRequests();
}

/// Gemini AI service for generating micro-habits
/// Pure Dart implementation with no state management dependencies
class GeminiService implements IGeminiService {
  final GenerativeModel _model;
  final ICacheService _cache;
  final IRateLimitService _rateLimit;
  final BibleDbService? _bibleService;

  GeminiService({
    required String apiKey,
    required String modelName,
    required ICacheService cache,
    required IRateLimitService rateLimit,
    BibleDbService? bibleService,
  })  : _cache = cache,
        _rateLimit = rateLimit,
        _bibleService = bibleService,
        _model = GenerativeModel(model: modelName, apiKey: apiKey);

  @override
  Future<List<MicroHabit>> generateMicroHabits(
    GenerationRequest request,
  ) async {
    // 1. Sanitize inputs to prevent prompt injection
    final sanitizedGoal = _sanitizeInput(request.userGoal, 'userGoal');
    final sanitizedPattern = request.failurePattern != null
        ? _sanitizeInput(request.failurePattern!, 'failurePattern')
        : null;

    // 2. Check rate limit and wait if needed
    await _rateLimit.waitIfNeeded();

    if (!_rateLimit.canMakeRequest()) {
      throw RateLimitExceededException(
        'Monthly limit of ${AiConfig.monthlyRequestLimit} requests reached. '
        'Limit will reset next month.',
      );
    }

    _rateLimit.recordRequest();

    _rateLimit.getRemainingRequests();

    // 3. Check cache (7 day expiry)
    final cacheKey = request.toCacheKey();
    final cached = await _cache.get<List<MicroHabit>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    // 4. Build prompt with sanitized inputs
    final prompt = _buildPrompt(
      sanitizedGoal,
      sanitizedPattern,
      request.faithContext,
      request.languageCode,
    );

    // 5. Call Gemini API with timeout
    try {
      final response = await _model.generateContent(
          [Content.text(prompt)]).timeout(AiConfig.requestTimeout);

      // 6. Parse and validate JSON response
      final habits = _parseResponse(response.text, request.languageCode);

      // 7. Enrich with verse text if Bible service available
      final enrichedHabits = await _enrichWithVerseText(habits);

      // 8. Cache result
      await _cache.set(cacheKey, enrichedHabits, ttl: AiConfig.cacheTtl);

      return enrichedHabits;
    } on TimeoutException {
      throw GeminiException(
        'Request timed out after ${AiConfig.requestTimeout.inSeconds} seconds. Please try again.',
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
    if (input.length > AiConfig.maxInputLength) {
      throw InvalidInputException(
        '$fieldName exceeds ${AiConfig.maxInputLength} characters',
      );
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
          'Empty response after cleanup',
          responseText,
        );
      }

      final dynamic json = jsonDecode(cleaned);

      // Validate JSON structure - must be a List
      if (json is! List) {
        throw GeminiParseException(
          'Expected JSON array, got ${json.runtimeType}',
          responseText,
        );
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
      throw GeminiParseException('Failed to parse response: $e', responseText);
    }
  }

  /// Enrich habits with full verse text from Bible database
  Future<List<MicroHabit>> _enrichWithVerseText(List<MicroHabit> habits) async {
    if (_bibleService == null) {
      return habits;
    }

    return Future.wait(
      habits.map((habit) async {
        try {
          final verseData = await _parseAndFetchVerse(habit.verse);
          if (verseData != null) {
            return habit.copyWith(verseText: verseData['text'] as String?);
          } else {
            return habit;
          }
        } catch (e) {
          return habit; // Keep original without text
        }
      }),
    );
  }

  /// Parse verse reference and fetch from database
  Future<Map<String, dynamic>?> _parseAndFetchVerse(String verseRef) async {
    if (_bibleService == null) return null;

    // Parse verse reference (e.g., "Salmos 5:3" or "Juan 3:16")
    final regex = RegExp(r'(\w+)\s+(\d+):(\d+)');
    final match = regex.firstMatch(verseRef);

    if (match == null) {
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
      return null;
    }

    // Use null-aware operator to avoid unconditional invocation
    return await _bibleService?.getVerse(
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

  /// Generate habits based on onboarding profile with intent-aware context
  @override
  Future<List<Map<String, dynamic>>> generateHabitsFromProfile(
    OnboardingProfile profile,
    String userId, {
    String language = 'es',
    bool isOnboarding = false,
  }) async {
    // Solo flujo moderno: descarga remota y Gemini
    // Eliminar referencias a fingerprint, Logger, plantillas locales

    // Check rate limit
    await _rateLimit.waitIfNeeded();
    if (!_rateLimit.canMakeRequest()) {
      throw RateLimitExceededException(
        'Monthly limit reached. Please try again next month.',
      );
    }
    _rateLimit.recordRequest();

    // Build intent-aware prompt
    final prompt = _buildProfilePrompt(profile);
    (prompt.length / 4).ceil();

    try {
      final response = await _model.generateContent(
          [Content.text(prompt)]).timeout(AiConfig.requestTimeout);

      final responseText = response.text ?? '';
      (responseText.length / 4).ceil();

      // Parse and return habit data
      final habits = _parseHabitsResponse(response.text, profile, userId);

      // D. Guardar con metadata del perfil para similarity matching
      // Serializar correctamente el campo 'category' como String
      final habitsForCache = habits.map((habit) {
        final habitCopy = Map<String, dynamic>.from(habit);
        if (habitCopy['category'] is HabitCategory) {
          habitCopy['category'] =
              habitCopy['category'].toString().split('.').last;
        }
        return habitCopy;
      }).toList();
      final cacheData = {
        'profile': profile.toJson(),
        'habits': habitsForCache,
        'timestamp': DateTime.now().toIso8601String(),
        'userId': userId,
        'isOnboarding': isOnboarding,
      };
      final prefs = await SharedPreferences.getInstance();
      final cachedKey =
          'profile_${profile.primaryIntent}_${profile.completedAt.toIso8601String()}';
      await prefs.setString(cachedKey, jsonEncode(cacheData));

      // Después de parsear los hábitos generados por Gemini:
      final firestoreService = GeminiTemplateFirestoreService(
        FirebaseFirestore.instance,
      );
      await firestoreService.saveGeminiTemplate(
        fingerprint:
            '${profile.primaryIntent}_${profile.completedAt.toIso8601String()}',
        profile: profile.toJson(),
        habits: habitsForCache,
        language: language,
        source: 'gemini',
      );

      return habits;
    } on TimeoutException {
      throw GeminiException('Request timed out. Please try again.');
    } catch (e) {
      final errorMessage = e.toString();

      // Check for model not found errors
      if (errorMessage.contains('not found') ||
          errorMessage.contains('not supported')) {
        throw GeminiException(
          'AI model configuration error. Please check app settings. '
          'Try updating the app or contact support.',
        );
      }

      // Check for API key issues
      if (errorMessage.contains('API_KEY') ||
          errorMessage.contains('INVALID_ARGUMENT')) {
        throw GeminiException(
          'AI service authentication failed. Please check configuration.',
        );
      }

      if (e is GeminiException) rethrow;
      throw GeminiException('Failed to generate habits: $e');
    }
  }

  /// Build prompt based on user intent
  String _buildProfilePrompt(OnboardingProfile profile) {
    String prompt;

    switch (profile.primaryIntent) {
      case UserIntent.faithBased:
        prompt = '''
Usuario cristiano busca fortalecer fe.
Motivaciones: ${profile.motivations.join(', ')}
Madurez espiritual: ${profile.spiritualMaturity}
Desafío principal: ${profile.challenge}
Apoyo: ${profile.supportLevel}

Genera EXACTAMENTE 6 hábitos: 4 espirituales + 2 prácticos de soporte.

Ejemplos espirituales:
- "Oración matutina 10 min" (categoría: spiritual)
- "Lectio Divina diaria" (categoría: spiritual)
- "Ayuno semanal" (categoría: spiritual)
- "Memorizar versículo semanal" (categoría: spiritual)

Ejemplos prácticos de soporte:
- "Dormir 8 horas" (categoría: physical) - para estar alerta en oración
- "Caminar 20 min" (categoría: physical) - para salud física que honra a Dios
''';
        break;

      case UserIntent.wellness:
        prompt = '''
Usuario busca bienestar secular.
Objetivos: ${profile.motivations.join(', ')}
Estado actual: derivado de respuestas
Desafío principal: ${profile.challenge}
Apoyo: ${profile.supportLevel}

Genera EXACTAMENTE 6 hábitos prácticos: salud, productividad, mindfulness.
NO incluir contenido religioso explícito.

Ejemplos:
- "Meditar 5 min al despertar" (categoría: mental)
- "Caminar 30 min diarios" (categoría: physical)
- "Journaling nocturno 10 min" (categoría: mental)
- "Beber 8 vasos de agua" (categoría: physical)
- "Leer 20 páginas" (categoría: mental)
- "Estiramientos matutinos" (categoría: physical)
''';
        break;

      case UserIntent.both:
        prompt = '''
Usuario busca integración fe + bienestar.
Motivaciones: ${profile.motivations.join(', ')}
Madurez espiritual: ${profile.spiritualMaturity}
Desafío principal: ${profile.challenge}
Apoyo: ${profile.supportLevel}

Genera EXACTAMENTE 7 hábitos: 3 espirituales + 4 prácticos integrados.

Ejemplos integrados:
- "Caminata de oración 30 min" (categoría: physical) - ejercicio + espiritualidad
- "Gratitud nocturna 5 min" (categoría: mental) - reflexión que incluye agradecimiento a Dios
- "Lectura bíblica matutina 15 min" (categoría: spiritual)
- "Meditación y silencio 10 min" (categoría: mental)
- "Servicio semanal comunitario" (categoría: relational)
''';
        break;
    }

    prompt += '''

Compromiso del usuario: "${profile.commitment}"

Responde SOLO con JSON válido (sin markdown, sin ```json):
[
  {
    "name": "Nombre del hábito (acción específica)",
    "description": "Descripción clara del hábito (1-2 oraciones)",
    "category": "spiritual" | "physical" | "mental" | "relational",
    "emoji": "emoji apropiado",
    "scheduledTime": "HH:mm" (opcional, basado en momento óptimo) o null,
    "tasks": ["subtarea 1", "subtarea 2"] (opcional, para hábitos complejos),
    "notifications": [
      {
        "time": "HH:mm" (formato 24h, ej: "07:00"),
        "title": "Título motivacional del recordatorio",
        "body": "Mensaje alentador breve",
        "enabled": true
      }
    ]
  }
]

Requisitos:
- Hábitos deben ser ESPECÍFICOS y MEDIBLES
- Incluir tiempo estimado en el nombre si relevante
- Las descripciones deben motivar y explicar el beneficio
- IMPORTANTE: Cada hábito DEBE incluir al menos una notificación con horario específico
- Los recordatorios deben ser en momentos apropiados del día (mañana: 07:00-09:00, tarde: 12:00-14:00, noche: 20:00-22:00)
- Títulos de notificaciones deben ser breves y motivadores
- Tono: motivacional, práctico, esperanzador
- Respetar el contexto del usuario (${profile.primaryIntent.name})
''';

    return prompt;
  }

  /// Parse habits from JSON response
  List<Map<String, dynamic>> _parseHabitsResponse(
    String? responseText,
    OnboardingProfile profile,
    String userId,
  ) {
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
          'Empty response after cleanup',
          responseText,
        );
      }

      final dynamic json = jsonDecode(cleaned);

      if (json is! List) {
        throw GeminiParseException(
          'Expected JSON array, got ${json.runtimeType}',
          responseText,
        );
      }

      // Parse each habit
      return json.map((data) {
        final habitData = data as Map<String, dynamic>;

        // Validate required fields
        final requiredFields = ['name', 'description', 'category', 'emoji'];
        for (final field in requiredFields) {
          if (!habitData.containsKey(field)) {
            throw GeminiParseException(
              'Missing required field "$field"',
              data.toString(),
            );
          }
        }

        // Return habit data that can be used to create a Habit object
        return {
          'id': const Uuid().v4(),
          'userId': userId,
          'name': habitData['name'] as String,
          'description': habitData['description'] as String,
          'category': _parseCategory(habitData['category'] as String),
          'emoji': habitData['emoji'] as String,
          'reminderTime': habitData['scheduledTime'] as String?,
          'notifications': habitData['notifications'] as List?,
          'createdAt': DateTime.now().toIso8601String(),
          'completedToday': false,
          'currentStreak': 0,
          'longestStreak': 0,
          'completionHistory': <String>[],
          'isArchived': false,
          'difficulty': 'medium',
        };
      }).toList();
    } catch (e) {
      if (e is GeminiParseException) rethrow;
      throw GeminiParseException('Failed to parse response: $e', responseText);
    }
  }

  /// Parse category string to HabitCategory enum
  HabitCategory _parseCategory(String category) {
    switch (category.toLowerCase()) {
      case 'spiritual':
        return HabitCategory.spiritual;
      case 'physical':
        return HabitCategory.physical;
      case 'mental':
        return HabitCategory.mental;
      case 'relational':
        return HabitCategory.relational;
      default:
        return HabitCategory.other;
    }
  }

  /// Forbidden content keywords (violence, sex, etc.)
  static const List<String> _forbiddenKeywords = [
    'violence', 'kill', 'murder', 'suicide', 'sex', 'sexual', 'abuse',
    'drugs', 'weapon', 'assault', 'rape', 'porn', 'erotic', 'terror',
    'self-harm', 'harm', 'abduct', 'exploit', 'molest', 'incest',
    // Spanish
    'violencia', 'matar', 'asesinar', 'suicidio', 'sexo', 'sexual', 'abuso',
    'drogas', 'arma', 'asalto', 'violación', 'porno', 'erótico', 'terror',
    'autolesión', 'dañar', 'secuestrar', 'explotar', 'acosar', 'incesto',
  ];

  /// Check for forbidden content in a string
  bool _containsForbiddenContent(String text) {
    final lower = text.toLowerCase();
    return _forbiddenKeywords.any((word) => lower.contains(word));
  }

  /// Validate if the response is logical for the goal
  bool _isLogicalForGoal(String userGoal, List<MicroHabit> habits) {
    final goal = userGoal.toLowerCase();
    if (goal.contains('toda la biblia') ||
        goal.contains('whole bible') ||
        goal.contains('leer la biblia')) {
      // Look for a plan, schedule, or multi-step reading suggestion
      return habits.any((h) =>
          h.action.toLowerCase().contains('plan') ||
          h.action.toLowerCase().contains('capítulo') ||
          h.action.toLowerCase().contains('cronológico') ||
          h.action.toLowerCase().contains('lectura diaria') ||
          h.action.toLowerCase().contains('leer la biblia'));
    }
    // For other goals, just check that actions are not empty
    return habits.every((h) => h.action.isNotEmpty);
  }

  /// New prompt for full-plan goals (language-agnostic, not hardcoded for Bible)
  String _buildFullPlanPrompt(String userGoal, String languageCode) {
    return '''
The user wants: "$userGoal"
Generate EXACTLY 3 logical, actionable tasks that will help the user achieve this goal. Each task should be clear, specific, and directly related to the user's request. For each task, provide a brief explanation of why it is important or how it helps achieve the goal.

Respond ONLY with valid JSON (no markdown, no ```json):
[
  {"task": "First logical task", "explanation": "Why this task is important"},
  {"task": "Second logical task", "explanation": "Why this task is important"},
  {"task": "Third logical task", "explanation": "Why this task is important"}
]
''';
  }

  /// Generate a logical plan or micro-habits based on the goal
  Future<List<MicroHabit>> generateLogicalHabitsOrPlan(
      GenerationRequest request) async {
    final sanitizedGoal = _sanitizeInput(request.userGoal, 'userGoal');
    final sanitizedPattern = request.failurePattern != null
        ? _sanitizeInput(request.failurePattern!, 'failurePattern')
        : null;
    await _rateLimit.waitIfNeeded();
    if (!_rateLimit.canMakeRequest()) {
      throw RateLimitExceededException(
        'Monthly limit of {AiConfig.monthlyRequestLimit} requests reached. '
        'Limit will reset next month.',
      );
    }
    _rateLimit.recordRequest();
    _rateLimit.getRemainingRequests();
    final cacheKey = request.toCacheKey();
    final cached = await _cache.get<List<MicroHabit>>(cacheKey);
    if (cached != null) {
      return cached;
    }
    // Detect if the goal is a full-plan goal
    final goal = sanitizedGoal.toLowerCase();
    if (goal.contains('toda la biblia') ||
        goal.contains('whole bible') ||
        goal.contains('leer la biblia')) {
      // Use full plan prompt
      final prompt = _buildFullPlanPrompt(sanitizedGoal, request.languageCode);
      final response = await _model.generateContent(
          [Content.text(prompt)]).timeout(AiConfig.requestTimeout);
      // For now, just log and throw, or you can parse and return as needed
      throw GeminiException('Full plan response: \\n${response.text}');
    } else {
      // Use micro-habit prompt
      final prompt = _buildPrompt(sanitizedGoal, sanitizedPattern,
          request.faithContext, request.languageCode);
      try {
        final response = await _model.generateContent(
            [Content.text(prompt)]).timeout(AiConfig.requestTimeout);
        final habits = _parseResponse(response.text, request.languageCode);
        // Filter forbidden content
        final safeHabits = habits
            .where((h) =>
                !_containsForbiddenContent(h.action) &&
                !_containsForbiddenContent(h.purpose))
            .toList();
        if (!_isLogicalForGoal(request.userGoal, safeHabits)) {
          throw GeminiException(
              'Response not logical for goal: ${request.userGoal}');
        }
        final enrichedHabits = await _enrichWithVerseText(safeHabits);
        await _cache.set(cacheKey, enrichedHabits, ttl: AiConfig.cacheTtl);
        return enrichedHabits;
      } on TimeoutException {
        throw GeminiException(
            'Request timed out after {AiConfig.requestTimeout.inSeconds} seconds. Please try again.');
      } catch (e) {
        if (e is GeminiException) rethrow;
        throw GeminiException('Failed to generate habits: $e');
      }
    }
  }
}
