import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:habitus_faith/core/services/ai/gemini_service.dart';
import 'package:habitus_faith/core/services/cache/cache_service.dart';
import 'package:habitus_faith/core/services/ai/rate_limit_service.dart';
import 'package:habitus_faith/core/config/ai_config.dart';
import 'package:habitus_faith/features/habits/domain/models/generation_request.dart';

@Tags(['integration'])
void main() {
  String? testApiKey;

  setUpAll(() async {
    // Attempt to load test environment variables
    try {
      await dotenv.load(fileName: '.env.test');
      testApiKey = dotenv.env['TEST_GEMINI_API_KEY'];
      if (testApiKey != null && testApiKey!.isNotEmpty) {
        print('✅ Test API key found - integration tests enabled');
      }
    } catch (e) {
      print('ℹ️  .env.test not found - integration tests will be skipped. '
          'Create .env.test with TEST_GEMINI_API_KEY to enable.');
    }
  });

  group('Gemini Service Integration Tests', () {
    late GeminiService service;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      if (testApiKey == null || testApiKey!.isEmpty) {
        return; // Skip setup if no API key
      }

      service = GeminiService(
        apiKey: testApiKey!,
        modelName: AiConfig.defaultModel,
        cache: CacheService(prefs),
        rateLimit: RateLimitService(prefs),
        logger: Logger(level: Level.info),
      );
    });

    test('generates 3 habits from real API with valid structure', () async {
      if (testApiKey == null || testApiKey!.isEmpty) {
        return skip('No API key configured (add .env.test to enable)');
      }

      final request = const GenerationRequest(
        userGoal: 'Orar más consistentemente',
        failurePattern: 'Olvido en las mañanas',
        languageCode: 'es',
      );

      final habits = await service.generateMicroHabits(request);

      expect(habits, hasLength(AiConfig.habitsPerGeneration));
      expect(habits.every((h) => h.action.isNotEmpty), isTrue);
      expect(habits.every((h) => h.verse.isNotEmpty), isTrue);
      expect(habits.every((h) => h.purpose.isNotEmpty), isTrue);
      expect(
          habits.every((h) =>
              h.purpose.toLowerCase().contains('dios') ||
              h.purpose.toLowerCase().contains('fe') ||
              h.purpose.toLowerCase().contains('señor')),
          isTrue);
      expect(
          habits.every((h) => h.estimatedMinutes <= AiConfig.maxHabitMinutes),
          isTrue);
    }, timeout: const Timeout(Duration(seconds: 45)));

    test('caches results on second identical request', () async {
      if (testApiKey == null || testApiKey!.isEmpty) {
        return skip('No API key configured (add .env.test to enable)');
      }

      final request = const GenerationRequest(
        userGoal: 'Leer la Biblia diariamente',
        languageCode: 'es',
      );

      // First request - calls API
      final habits1 = await service.generateMicroHabits(request);
      expect(habits1, hasLength(3));

      // Second request - should be cached (much faster)
      final stopwatch = Stopwatch()..start();
      final habits2 = await service.generateMicroHabits(request);
      stopwatch.stop();

      expect(habits2, hasLength(3));
      // Cached request should be very fast (under 100ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(100),
          reason:
              'Cache hit should be faster than ${stopwatch.elapsedMilliseconds}ms');
    }, timeout: const Timeout(Duration(seconds: 45)));

    test('respects rate limiting configuration', () async {
      if (testApiKey == null || testApiKey!.isEmpty) {
        return skip('No API key configured (add .env.test to enable)');
      }

      // Verify rate limit constant is correctly configured
      expect(AiConfig.monthlyRequestLimit, equals(10));
      expect(service.getRemainingRequests(), lessThanOrEqualTo(10));
    });

    test('generates habits in different languages', () async {
      if (testApiKey == null || testApiKey!.isEmpty) {
        return skip('No API key configured (add .env.test to enable)');
      }

      final requestEn = const GenerationRequest(
        userGoal: 'Pray more consistently',
        languageCode: 'en',
      );

      final habitsEn = await service.generateMicroHabits(requestEn);

      expect(habitsEn, hasLength(3));
      expect(habitsEn.every((h) => h.action.isNotEmpty), isTrue);
      // English response should contain English words
      expect(
          habitsEn.any((h) =>
              h.action.toLowerCase().contains('pray') ||
              h.action.toLowerCase().contains('read') ||
              h.action.toLowerCase().contains('god')),
          isTrue);
    }, timeout: const Timeout(Duration(seconds: 45)));

    test('timeout configuration is correctly set', () {
      expect(AiConfig.requestTimeout, equals(const Duration(seconds: 30)));
    });
  });
}
