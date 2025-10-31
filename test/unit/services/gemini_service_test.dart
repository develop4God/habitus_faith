import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitus_faith/core/services/ai/gemini_service.dart';
import 'package:habitus_faith/core/services/cache/cache_service.dart';
import 'package:habitus_faith/core/services/ai/rate_limit_service.dart';
import 'package:habitus_faith/core/services/ai/gemini_exceptions.dart';
import 'package:habitus_faith/features/habits/domain/models/micro_habit.dart';
import 'package:habitus_faith/features/habits/domain/models/generation_request.dart';

class MockCacheService extends Mock implements ICacheService {}

class MockRateLimitService extends Mock implements IRateLimitService {}

void main() {
  setUpAll(() {
    registerFallbackValue(const GenerationRequest(userGoal: 'test'));
    registerFallbackValue(const Duration(days: 7));
    registerFallbackValue(<MicroHabit>[]);
  });

  group('GeminiService', () {
    late MockCacheService mockCache;
    late MockRateLimitService mockRateLimit;
    late GeminiService service;

    setUp(() {
      mockCache = MockCacheService();
      mockRateLimit = MockRateLimitService();

      // Note: We can't easily test the actual API calls without mocking GenerativeModel
      // which is final and difficult to mock. These tests focus on the logic flow.
      service = GeminiService(
        apiKey: 'test_api_key',
        modelName: 'gemini-1.5-flash',
        cache: mockCache,
        rateLimit: mockRateLimit,
      );
    });

    test('throws RateLimitExceededException when limit reached', () async {
      when(() => mockRateLimit.canMakeRequest()).thenAnswer((_) async => false);

      final request = const GenerationRequest(userGoal: 'Orar más');

      expect(
        () => service.generateMicroHabits(request),
        throwsA(isA<RateLimitExceededException>()),
      );

      verifyNever(() => mockCache.get<List<MicroHabit>>(any()));
    });

    test('returns cached result without API call', () async {
      final cachedHabits = [
        MicroHabit(
          id: '1',
          action: 'Orar 3min',
          verse: 'Salmos 5:3',
          purpose: 'Test purpose',
        ),
      ];

      when(() => mockRateLimit.canMakeRequest()).thenAnswer((_) async => true);
      when(() => mockCache.get<List<MicroHabit>>(any()))
          .thenAnswer((_) async => cachedHabits);

      final request = const GenerationRequest(userGoal: 'Orar más');
      final habits = await service.generateMicroHabits(request);

      expect(habits, equals(cachedHabits));
      verifyNever(() => mockRateLimit.incrementCounter());
    });

    test('canMakeRequest delegates to rate limit service', () async {
      when(() => mockRateLimit.canMakeRequest()).thenAnswer((_) async => true);

      final result = await service.canMakeRequest();

      expect(result, isTrue);
      verify(() => mockRateLimit.canMakeRequest()).called(1);
    });

    test('getRemainingRequests delegates to rate limit service', () {
      when(() => mockRateLimit.getRemainingRequests()).thenReturn(5);

      final result = service.getRemainingRequests();

      expect(result, equals(5));
      verify(() => mockRateLimit.getRemainingRequests()).called(1);
    });

    test('GenerationRequest toCacheKey generates consistent keys', () {
      const request1 = GenerationRequest(
        userGoal: 'Orar más',
        failurePattern: 'Olvido en mañanas',
        faithContext: 'Cristiano',
        languageCode: 'es',
      );

      const request2 = GenerationRequest(
        userGoal: 'Orar más',
        failurePattern: 'Olvido en mañanas',
        faithContext: 'Cristiano',
        languageCode: 'es',
      );

      expect(request1.toCacheKey(), equals(request2.toCacheKey()));
    });

    test('GenerationRequest toCacheKey generates different keys for different requests',
        () {
      const request1 = GenerationRequest(userGoal: 'Orar más');
      const request2 = GenerationRequest(userGoal: 'Leer la Biblia');

      expect(request1.toCacheKey(), isNot(equals(request2.toCacheKey())));
    });
  });
}
