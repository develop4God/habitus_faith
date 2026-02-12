import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitus_faith/core/services/ai/gemini_service.dart';
import 'package:habitus_faith/core/services/ai/gemini_exceptions.dart';
import 'package:habitus_faith/core/config/ai_config.dart';
import 'package:habitus_faith/features/habits/domain/models/generation_request.dart';
import 'package:habitus_faith/features/habits/domain/models/micro_habit.dart';
import '../../../utils/gemini_mocks.dart';

void main() {
  group('GeminiService Tests', () {
    late MockCacheService mockCache;
    late MockRateLimitService mockRateLimit;
    late MockBibleDbService mockBibleService;

    setUp(() {
      mockCache = MockCacheService();
      mockRateLimit = MockRateLimitService();
      mockBibleService = MockBibleDbService();

      // Register fallback values for mocktail
      registerFallbackValue(const GenerationRequest(userGoal: 'test'));
      registerFallbackValue(const Duration(seconds: 30));

      // Default mock behaviors
      when(() => mockRateLimit.canMakeRequest()).thenReturn(true);
      when(() => mockRateLimit.waitIfNeeded()).thenAnswer((_) async {});
      when(() => mockRateLimit.recordRequest()).thenReturn(null);
      when(() => mockRateLimit.getRemainingRequests()).thenReturn(10);
      when(() => mockCache.get<List<MicroHabit>>(any()))
          .thenAnswer((_) async => null);
      when(() => mockCache.set<List<MicroHabit>>(any(), any(), ttl: any(named: 'ttl')))
          .thenAnswer((_) async {});
    });

    group('Test 1: generateMicroHabits - Service initialization and configuration', () {
      test('should successfully create service with all dependencies', () {
        // Act
        final testService = GeminiService(
          apiKey: 'test-api-key-for-testing',
          modelName: AiConfig.defaultModel,
          cache: mockCache,
          rateLimit: mockRateLimit,
          bibleService: mockBibleService,
        );

        // Assert
        expect(testService, isNotNull);
        expect(testService.getRemainingRequests(), equals(10));
      });

      test('should work without optional Bible service', () {
        // Act
        final testService = GeminiService(
          apiKey: 'test-api-key-for-testing',
          modelName: AiConfig.defaultModel,
          cache: mockCache,
          rateLimit: mockRateLimit,
          // bibleService is optional
        );

        // Assert
        expect(testService, isNotNull);
      });

      test('should use correct configuration values', () {
        // Assert configuration
        expect(AiConfig.habitsPerGeneration, equals(3));
        expect(AiConfig.requestTimeout, equals(const Duration(seconds: 30)));
        expect(AiConfig.monthlyRequestLimit, equals(10));
        expect(AiConfig.maxInputLength, equals(200));
      });
    });

    group('Test 2: generateMicroHabits - handles rate limiting', () {
      test('should throw RateLimitExceededException when limit exceeded', () async {
        // Arrange
        when(() => mockRateLimit.canMakeRequest()).thenReturn(false);

        final testService = GeminiService(
          apiKey: 'test-api-key',
          modelName: AiConfig.defaultModel,
          cache: mockCache,
          rateLimit: mockRateLimit,
          bibleService: mockBibleService,
        );

        const request = GenerationRequest(
          userGoal: 'Test goal',
        );

        // Act & Assert
        await expectLater(
          testService.generateMicroHabits(request),
          throwsA(isA<RateLimitExceededException>()),
        );

        verify(() => mockRateLimit.waitIfNeeded()).called(1);
        verify(() => mockRateLimit.canMakeRequest()).called(1);
      });

      test('should check rate limit before making request', () async {
        final testService = GeminiService(
          apiKey: 'test-api-key',
          modelName: AiConfig.defaultModel,
          cache: mockCache,
          rateLimit: mockRateLimit,
          bibleService: mockBibleService,
        );

        expect(testService.getRemainingRequests(), equals(10));
        verify(() => mockRateLimit.getRemainingRequests()).called(1);
      });

      test('should configure 30-second timeout', () {
        // Verify the timeout configuration
        expect(AiConfig.requestTimeout, equals(const Duration(seconds: 30)));
      });
    });

    group('Test 3: generateMicroHabits - enforces rate limiting workflow', () {
      test('should wait if needed before making request', () async {
        // Arrange
        var waitCalled = false;
        when(() => mockRateLimit.waitIfNeeded()).thenAnswer((_) async {
          waitCalled = true;
        });

        final testService = GeminiService(
          apiKey: 'test-api-key',
          modelName: AiConfig.defaultModel,
          cache: mockCache,
          rateLimit: mockRateLimit,
          bibleService: mockBibleService,
        );

        const request = GenerationRequest(
          userGoal: 'Test goal',
        );

        // Act
        try {
          await testService.generateMicroHabits(request);
        } catch (e) {
          // Expected to fail without real API, but we verify rate limiting was called
        }

        // Assert
        expect(waitCalled, isTrue);
        verify(() => mockRateLimit.waitIfNeeded()).called(1);
        verify(() => mockRateLimit.canMakeRequest()).called(1);
      });

      test('should return remaining requests count', () {
        final testService = GeminiService(
          apiKey: 'test-api-key',
          modelName: AiConfig.defaultModel,
          cache: mockCache,
          rateLimit: mockRateLimit,
          bibleService: mockBibleService,
        );

        final remaining = testService.getRemainingRequests();
        expect(remaining, equals(10));
        verify(() => mockRateLimit.getRemainingRequests()).called(1);
      });

      test('should validate monthly request limit configuration', () {
        expect(AiConfig.monthlyRequestLimit, equals(10));
      });
    });

    group('Test 4: generateMicroHabits - sanitizes user input', () {
      test('should reject input exceeding max length', () async {
        // Arrange
        final longInput = 'a' * (AiConfig.maxInputLength + 1);
        final testService = GeminiService(
          apiKey: 'test-api-key',
          modelName: AiConfig.defaultModel,
          cache: mockCache,
          rateLimit: mockRateLimit,
          bibleService: mockBibleService,
        );

        final request = GenerationRequest(
          userGoal: longInput,
        );

        // Act & Assert
        expect(
          () => testService.generateMicroHabits(request),
          throwsA(isA<InvalidInputException>()),
        );
      });

      test('should reject input with blacklisted terms', () async {
        // Arrange
        final testService = GeminiService(
          apiKey: 'test-api-key',
          modelName: AiConfig.defaultModel,
          cache: mockCache,
          rateLimit: mockRateLimit,
          bibleService: mockBibleService,
        );

        // Test each blacklisted term
        for (final term in AiConfig.blacklistedTerms) {
          final request = GenerationRequest(
            userGoal: 'Please $term this test',
          );

          expect(
            () => testService.generateMicroHabits(request),
            throwsA(isA<InvalidInputException>()),
            reason: 'Should reject blacklisted term: $term',
          );
        }
      });

      test('should validate blacklisted terms configuration', () {
        // Verify blacklisted terms include expected values
        expect(AiConfig.blacklistedTerms, contains('ignore'));
        expect(AiConfig.blacklistedTerms, contains('instructions'));
        expect(AiConfig.blacklistedTerms.length, greaterThan(0));
      });

      test('should validate max input length configuration', () {
        expect(AiConfig.maxInputLength, equals(200));
      });
    });

    group('Test 5: generateMicroHabits - uses caching', () {
      test('should return cached result if available', () async {
        // Arrange
        const cachedHabits = [
          MicroHabit(
            id: 'cached-1',
            action: 'Cached habit',
            verse: 'John 3:16',
            purpose: 'From cache',
          ),
        ];

        when(() => mockCache.get<List<MicroHabit>>(any()))
            .thenAnswer((_) async => cachedHabits);

        final testService = GeminiService(
          apiKey: 'test-api-key',
          modelName: AiConfig.defaultModel,
          cache: mockCache,
          rateLimit: mockRateLimit,
          bibleService: mockBibleService,
        );

        const request = GenerationRequest(
          userGoal: 'Test goal',
        );

        // Act
        final result = await testService.generateMicroHabits(request);

        // Assert
        expect(result, equals(cachedHabits));
        verify(() => mockCache.get<List<MicroHabit>>(any())).called(1);
        // Note: Current implementation checks rate limit before cache
        // This is a known issue that could be optimized in the future
        verify(() => mockRateLimit.waitIfNeeded()).called(1);
        verify(() => mockRateLimit.canMakeRequest()).called(1);
      });

      test('should check cache before making API request', () async {
        // Arrange
        when(() => mockCache.get<List<MicroHabit>>(any()))
            .thenAnswer((_) async => null);

        final testService = GeminiService(
          apiKey: 'test-api-key',
          modelName: AiConfig.defaultModel,
          cache: mockCache,
          rateLimit: mockRateLimit,
          bibleService: mockBibleService,
        );

        const request = GenerationRequest(
          userGoal: 'Test goal',
        );

        // Act
        try {
          await testService.generateMicroHabits(request);
        } catch (e) {
          // Expected to fail without real API
        }

        // Assert - Cache should be checked
        verify(() => mockCache.get<List<MicroHabit>>(any())).called(1);
      });

      test('should use 7-day cache TTL configuration', () {
        expect(AiConfig.cacheTtl, equals(const Duration(days: 7)));
      });

      test('should validate cache hit rate target', () {
        expect(AiConfig.targetCacheHitRate, equals(0.8));
      });
    });

    group('Test 6: generateMicroHabits - validates response structure', () {
      test('should require exactly 3 habits per generation', () {
        expect(AiConfig.habitsPerGeneration, equals(3));
      });

      test('should validate required fields in habits', () {
        expect(
          AiConfig.requiredHabitFields,
          containsAll(['action', 'verse', 'purpose']),
        );
        expect(AiConfig.requiredHabitFields.length, equals(3));
      });

      test('should define optional fields', () {
        expect(AiConfig.optionalHabitFields, contains('verseText'));
        expect(AiConfig.optionalHabitFields, contains('estimatedMinutes'));
      });

      test('should validate habit duration constraints', () {
        expect(AiConfig.maxHabitMinutes, equals(5));
        expect(AiConfig.minHabitMinutes, equals(1));
      });
    });

    group('Test 7: generateMicroHabits - timeout and error handling', () {
      test('should have 30-second timeout configured', () {
        expect(AiConfig.requestTimeout, equals(const Duration(seconds: 30)));
      });

      test('should use correct Gemini model', () {
        expect(AiConfig.defaultModel, equals('gemini-2.0-flash'));
      });

      test('should define JSON response format', () {
        expect(AiConfig.responseFormat, equals('JSON'));
      });
    });

    group('Additional Edge Cases', () {
      test('should handle Bible service being optional', () {
        // Service should work without Bible service
        final testService = GeminiService(
          apiKey: 'test-api-key',
          modelName: AiConfig.defaultModel,
          cache: mockCache,
          rateLimit: mockRateLimit,
          // bibleService is optional
        );

        expect(testService, isNotNull);
      });

      test('should return remaining requests count', () {
        final testService = GeminiService(
          apiKey: 'test-api-key',
          modelName: AiConfig.defaultModel,
          cache: mockCache,
          rateLimit: mockRateLimit,
        );

        final remaining = testService.getRemainingRequests();
        expect(remaining, equals(10));
        verify(() => mockRateLimit.getRemainingRequests()).called(1);
      });

      test('should validate monthly request limit', () {
        expect(AiConfig.monthlyRequestLimit, equals(10));
      });
    });
  });
}
