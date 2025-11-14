import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:habitus_faith/core/services/templates/template_matching_service.dart';
import 'package:habitus_faith/core/services/cache/cache_service.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/onboarding_models.dart';

// Fake implementation for CacheService to avoid Mocktail generic issues
class FakeCacheService implements ICacheService {
  final Map<String, dynamic> _cache = {};

  @override
  Future<T?> get<T>(String key) async {
    return _cache[key] as T?;
  }

  @override
  Future<void> set<T>(String key, T value, {Duration? ttl}) async {
    _cache[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _cache.remove(key);
  }

  @override
  Future<void> clear() async {
    _cache.clear();
  }
}

// Mock classes
class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

void main() {
  late FakeCacheService fakeCache;
  late MockHttpClient mockHttpClient;
  late TemplateMatchingService service;

  setUp(() {
    fakeCache = FakeCacheService();
    mockHttpClient = MockHttpClient();
    service = TemplateMatchingService(fakeCache, httpClient: mockHttpClient);

    // Register fallback values for mocktail
    registerFallbackValue(Uri());
  });

  group('generatePatternId', () {
    test('generates correct pattern ID for faith-based profile', () {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline', 'growInFaith'],
        challenge: 'lackOfTime',
        supportLevel: 'normal',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final patternId = service.generatePatternId(profile);

      expect(patternId,
          'faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new');
    });

    test('generates correct pattern ID for wellness profile', () {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.wellness,
        motivations: ['timeManagement', 'productivity'],
        challenge: 'lackOfMotivation',
        supportLevel: 'normal',
        spiritualMaturity: null,
        commitment: 'weekly',
        completedAt: DateTime.now(),
      );

      final patternId = service.generatePatternId(profile);

      expect(patternId,
          'wellness_normal_lackOfMotivation_timeManagement_productivity_timeManagement');
    });

    test('uses only first two motivations', () {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline', 'understandBible'],
        challenge: 'dontKnowStart',
        supportLevel: 'normal',
        spiritualMaturity: 'growing',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final patternId = service.generatePatternId(profile);

      expect(patternId,
          'faithBased_normal_dontKnowStart_closerToGod_prayerDiscipline_growing');
    });
  });

  group('findMatch', () {
    test('returns cached template if available', () async {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline'],
        challenge: 'lackOfTime',
        supportLevel: 'normal',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final cacheKey =
          'template_es_faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new';
      await fakeCache.set(cacheKey, {
        'pattern_id':
            'faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new',
        'generated_habits': [
          {
            'name': 'Cached Prayer',
            'category': 'spiritual',
          }
        ]
      });

      final result = await service.findMatch(profile, 'es');

      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0]['name'], 'Cached Prayer');
    });

    test('fetches from network when not cached', () async {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline'],
        challenge: 'lackOfTime',
        supportLevel: 'normal',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      // New consolidated template file structure
      final templateFile = {
        'templates': [
          {
            'pattern_id':
                'faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new',
            'habits': [
              {
                'name': 'Morning Prayer',
                'category': 'spiritual',
                'emoji': '🙏',
              }
            ]
          }
        ]
      };

      // HTTP call returns consolidated template file
      final response = MockResponse();
      when(() => response.statusCode).thenReturn(200);
      when(() => response.body).thenReturn(jsonEncode(templateFile));

      when(() => mockHttpClient.get(any())).thenAnswer((_) async => response);

      final result = await service.findMatch(profile, 'es');

      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0]['name'], 'Morning Prayer');
    });

    test('returns null on network error', () async {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline'],
        challenge: 'lackOfTime',
        supportLevel: 'normal',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      when(() => mockHttpClient.get(any()))
          .thenThrow(Exception('Network error'));

      final result = await service.findMatch(profile, 'es');

      expect(result, isNull);
    });

    test('performs fuzzy match when exact match not found', () async {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline'],
        challenge: 'lackOfTime',
        supportLevel: 'normal',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      // Template file with similar but not exact pattern
      final templateFile = {
        'templates': [
          {
            'pattern_id':
                'faithBased_normal_lackOfTime_closerToGod_understandBible_new', // Different motivations
            'habits': [
              {
                'name': 'Fuzzy Match Prayer',
                'category': 'spiritual',
              }
            ]
          }
        ]
      };

      final response = MockResponse();
      when(() => response.statusCode).thenReturn(200);
      when(() => response.body).thenReturn(jsonEncode(templateFile));

      when(() => mockHttpClient.get(any())).thenAnswer((_) async => response);

      final result = await service.findMatch(profile, 'es');

      // Should find fuzzy match (similarity > 0.85)
      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0]['name'], 'Fuzzy Match Prayer');
    });
  });

  group('error handling', () {
    test('gracefully handles invalid JSON from network', () async {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline'],
        challenge: 'lackOfTime',
        supportLevel: 'normal',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final response = MockResponse();
      when(() => response.statusCode).thenReturn(200);
      when(() => response.body).thenReturn('invalid json');

      when(() => mockHttpClient.get(any())).thenAnswer((_) async => response);

      final result = await service.findMatch(profile, 'es');

      expect(result, isNull);
    });

    test('handles 404 response gracefully', () async {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline'],
        challenge: 'lackOfTime',
        supportLevel: 'normal',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final response = MockResponse();
      when(() => response.statusCode).thenReturn(404);
      when(() => response.body).thenReturn('Not found');

      when(() => mockHttpClient.get(any())).thenAnswer((_) async => response);

      final result = await service.findMatch(profile, 'es');

      expect(result, isNull);
    });
  });

  group('Multi-language support', () {
    test('fetches Chinese templates successfully', () async {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline'],
        challenge: 'lackOfTime',
        supportLevel: 'normal',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final templateFile = {
        'templates': [
          {
            'pattern_id':
                'faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new',
            'habits': [
              {
                'name': '晨间祷告',
                'category': 'spiritual',
              }
            ]
          }
        ]
      };

      final response = MockResponse();
      when(() => response.statusCode).thenReturn(200);
      when(() => response.body).thenReturn(jsonEncode(templateFile));

      when(() => mockHttpClient.get(any())).thenAnswer((_) async => response);

      final result = await service.findMatch(profile, 'zh');

      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0]['name'], '晨间祷告');
    });

    test('supports multiple languages (es, en, pt, fr, zh)', () async {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline'],
        challenge: 'lackOfTime',
        supportLevel: 'normal',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      for (final lang in ['es', 'en', 'pt', 'fr', 'zh']) {
        final templateFile = {
          'templates': [
            {
              'pattern_id':
                  'faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new',
              'habits': [
                {
                  'name': 'Prayer in $lang',
                  'category': 'spiritual',
                }
              ]
            }
          ]
        };

        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn(jsonEncode(templateFile));

        when(() => mockHttpClient.get(any()))
            .thenAnswer((_) async => response);

        final result = await service.findMatch(profile, lang);

        expect(result, isNotNull,
            reason: 'Should fetch template for language: $lang');
        expect(result!.length, 1);
        expect(result[0]['name'], 'Prayer in $lang');
      }
    });
  });

  group('Extended template scenarios', () {
    test('matches passionate spiritual maturity with givingUp challenge',
        () async {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['prayerDiscipline', 'growInFaith'],
        challenge: 'givingUp',
        supportLevel: 'normal',
        spiritualMaturity: 'passionate',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final templateFile = {
        'templates': [
          {
            'pattern_id':
                'faithBased_normal_givingUp_prayerDiscipline_growInFaith_passionate',
            'habits': [
              {
                'name': 'Service Prayer',
                'category': 'spiritual',
              }
            ]
          }
        ]
      };

      final response = MockResponse();
      when(() => response.statusCode).thenReturn(200);
      when(() => response.body).thenReturn(jsonEncode(templateFile));

      when(() => mockHttpClient.get(any())).thenAnswer((_) async => response);

      final result = await service.findMatch(profile, 'es');

      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0]['name'], 'Service Prayer');
    });

    test('matches wellness profile with betterSleep and reduceStress',
        () async {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.wellness,
        motivations: ['betterSleep', 'reduceStress'],
        challenge: 'dontKnowStart',
        supportLevel: 'normal',
        spiritualMaturity: null,
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final templateFile = {
        'templates': [
          {
            'pattern_id':
                'wellness_normal_dontKnowStart_betterSleep_reduceStress_betterSleep',
            'habits': [
              {
                'name': 'Evening Routine',
                'category': 'physical',
              }
            ]
          }
        ]
      };

      final response = MockResponse();
      when(() => response.statusCode).thenReturn(200);
      when(() => response.body).thenReturn(jsonEncode(templateFile));

      when(() => mockHttpClient.get(any())).thenAnswer((_) async => response);

      final result = await service.findMatch(profile, 'es');

      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0]['name'], 'Evening Routine');
    });

    test('matches both path with growing maturity and givingUp challenge',
        () async {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.both,
        motivations: ['closerToGod', 'understandBible'],
        challenge: 'givingUp',
        supportLevel: 'normal',
        spiritualMaturity: 'growing',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final templateFile = {
        'templates': [
          {
            'pattern_id':
                'both_normal_givingUp_closerToGod_understandBible_growing',
            'habits': [
              {
                'name': 'Grace-Focused Practice',
                'category': 'spiritual',
              }
            ]
          }
        ]
      };

      final response = MockResponse();
      when(() => response.statusCode).thenReturn(200);
      when(() => response.body).thenReturn(jsonEncode(templateFile));

      when(() => mockHttpClient.get(any())).thenAnswer((_) async => response);

      final result = await service.findMatch(profile, 'es');

      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0]['name'], 'Grace-Focused Practice');
    });
  });
}
