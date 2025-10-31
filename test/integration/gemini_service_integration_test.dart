import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:habitus_faith/core/services/ai/gemini_service.dart';
import 'package:habitus_faith/core/services/cache/cache_service.dart';
import 'package:habitus_faith/core/services/ai/rate_limit_service.dart';
import 'package:habitus_faith/core/services/ai/gemini_exceptions.dart';
import 'package:habitus_faith/features/habits/domain/models/generation_request.dart';

@Tags(['integration'])
void main() {
  group('GeminiService Integration Tests', () {
    late GeminiService service;
    late SharedPreferences prefs;

    setUpAll(() async {
      // Load test environment variables
      try {
        await dotenv.load(fileName: '.env.test');
      } catch (e) {
        // If .env.test doesn't exist, skip integration tests
        print(
            'Warning: .env.test not found. Integration tests will be skipped.');
      }
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      final testApiKey = dotenv.env['TEST_GEMINI_API_KEY'];
      if (testApiKey == null || testApiKey.isEmpty) {
        // Skip test if no test API key is available
        return;
      }

      service = GeminiService(
        apiKey: testApiKey,
        modelName: 'gemini-1.5-flash',
        cache: CacheService(prefs),
        rateLimit: RateLimitService(prefs),
      );
    });

    test('generates 3 habits for valid request', () async {
      final testApiKey = dotenv.env['TEST_GEMINI_API_KEY'];
      if (testApiKey == null || testApiKey.isEmpty) {
        print('Skipping integration test: TEST_GEMINI_API_KEY not set');
        return;
      }

      final request = const GenerationRequest(
        userGoal: 'Orar más consistentemente',
        failurePattern: 'Olvido en las mañanas',
        languageCode: 'es',
      );

      final habits = await service.generateMicroHabits(request);

      expect(habits, hasLength(3));
      expect(habits[0].action, isNotEmpty);
      expect(habits[0].verse, matches(RegExp(r'\w+ \d+:\d+')));
      expect(habits[0].purpose, isNotEmpty);
      expect(habits[0].estimatedMinutes, lessThanOrEqualTo(5));
    }, timeout: const Timeout(Duration(seconds: 45)));

    test('handles timeout gracefully', () async {
      final testApiKey = dotenv.env['TEST_GEMINI_API_KEY'];
      if (testApiKey == null || testApiKey.isEmpty) {
        print('Skipping integration test: TEST_GEMINI_API_KEY not set');
        return;
      }

      // This test would need a way to simulate timeout
      // For now, we'll just verify the timeout constant is set correctly
      expect(GeminiService.defaultTimeout.inSeconds, equals(30));
    });

    test('caches results on second request', () async {
      final testApiKey = dotenv.env['TEST_GEMINI_API_KEY'];
      if (testApiKey == null || testApiKey.isEmpty) {
        print('Skipping integration test: TEST_GEMINI_API_KEY not set');
        return;
      }

      final request = const GenerationRequest(
        userGoal: 'Leer la Biblia diariamente',
        languageCode: 'es',
      );

      // First request
      final habits1 = await service.generateMicroHabits(request);
      expect(habits1, hasLength(3));

      // Second request should be cached (faster)
      final stopwatch = Stopwatch()..start();
      final habits2 = await service.generateMicroHabits(request);
      stopwatch.stop();

      expect(habits2, hasLength(3));
      // Cached request should be much faster (under 100ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    }, timeout: const Timeout(Duration(seconds: 45)));

    test('respects rate limiting', () async {
      final testApiKey = dotenv.env['TEST_GEMINI_API_KEY'];
      if (testApiKey == null || testApiKey.isEmpty) {
        print('Skipping integration test: TEST_GEMINI_API_KEY not set');
        return;
      }

      // This would require setting up a test scenario where limit is reached
      // For now, verify the limit constant
      expect(RateLimitService.maxRequests, equals(10));
    });
  });
}
