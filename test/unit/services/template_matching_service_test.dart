import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:habitus_faith/core/services/templates/template_matching_service.dart';
import 'package:habitus_faith/core/services/cache/cache_service.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/onboarding_models.dart';

// Mock classes
class MockCacheService extends Mock implements ICacheService {}

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

void main() {
  late MockCacheService mockCache;
  late MockHttpClient mockHttpClient;
  late TemplateMatchingService service;

  setUp(() {
    mockCache = MockCacheService();
    mockHttpClient = MockHttpClient();
    service = TemplateMatchingService(mockCache, httpClient: mockHttpClient);

    // Register fallback values for mocktail
    registerFallbackValue(Uri());
    registerFallbackValue(const Duration(hours: 1));
  });

  group('generatePatternId', () {
    test('generates correct pattern ID for faith-based profile', () {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline', 'growInFaith'],
        challenge: 'lackOfTime',
        supportLevel: 'strong',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final patternId = service.generatePatternId(profile);

      expect(patternId,
          'faithBased_new_lackOfTime_closerToGod_prayerDiscipline');
    });

    test('generates correct pattern ID for wellness profile', () {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.wellness,
        motivations: ['timeManagement', 'productivity'],
        challenge: 'lackOfMotivation',
        supportLevel: 'weak',
        spiritualMaturity: null,
        commitment: 'weekly',
        completedAt: DateTime.now(),
      );

      final patternId = service.generatePatternId(profile);

      expect(
          patternId, 'wellness_timeManagement_lackOfMotivation_timeManagement_productivity');
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
          'faithBased_growing_dontKnowStart_closerToGod_prayerDiscipline');
    });
  });

  group('findMatch', () {
    test('returns cached template if available', () async {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline'],
        challenge: 'lackOfTime',
        supportLevel: 'strong',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final cachedTemplate = {
        'generated_habits': [
          {
            'name': 'Morning Prayer',
            'category': 'spiritual',
            'emoji': '🙏',
          }
        ]
      };

      when(() => mockCache.get<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => cachedTemplate);

      final result = await service.findMatch(profile, 'es');

      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0]['name'], 'Morning Prayer');
    });

    test('fetches from network when not cached', () async {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline'],
        challenge: 'lackOfTime',
        supportLevel: 'strong',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final metadata = {
        'templates': [
          {
            'pattern_id':
                'faithBased_new_lackOfTime_closerToGod_prayerDiscipline',
            'file':
                'faithBased_new_lackOfTime_closerToGod_prayerDiscipline.json',
            'fingerprint': {
              'primaryIntent': 'faithBased',
              'motivations': ['closerToGod', 'prayerDiscipline'],
              'challenge': 'lackOfTime',
              'supportLevel': null,
              'spiritualMaturity': 'new'
            }
          }
        ]
      };

      final template = {
        'generated_habits': [
          {
            'name': 'Morning Prayer',
            'category': 'spiritual',
            'emoji': '🙏',
          }
        ]
      };

      // First call for cache (returns null)
      when(() => mockCache.get<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => null);

      // HTTP calls
      final metadataResponse = MockResponse();
      when(() => metadataResponse.statusCode).thenReturn(200);
      when(() => metadataResponse.body).thenReturn(jsonEncode(metadata));

      final templateResponse = MockResponse();
      when(() => templateResponse.statusCode).thenReturn(200);
      when(() => templateResponse.body).thenReturn(jsonEncode(template));

      when(() => mockHttpClient.get(any())).thenAnswer((invocation) async {
        final uri = invocation.positionalArguments[0] as Uri;
        if (uri.path.contains('metadata.json')) {
          return metadataResponse;
        } else {
          return templateResponse;
        }
      });

      when(() => mockCache.set<Map<String, dynamic>>(
          any(), any(), ttl: any(named: 'ttl'))).thenAnswer((_) async {});

      final result = await service.findMatch(profile, 'es');

      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0]['name'], 'Morning Prayer');

      // Verify cache was called
      verify(() => mockCache.set<Map<String, dynamic>>(
          any(), any(), ttl: any(named: 'ttl'))).called(greaterThan(0));
    });

    test('returns null on network error', () async {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline'],
        challenge: 'lackOfTime',
        supportLevel: 'strong',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      when(() => mockCache.get<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => null);

      when(() => mockHttpClient.get(any()))
          .thenThrow(Exception('Network error'));

      final result = await service.findMatch(profile, 'es');

      expect(result, isNull);
    });

    test('performs fuzzy match when exact match not found', () async {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: [
          'closerToGod',
          'prayerDiscipline',
          'understandBible'
        ], // Different motivations
        challenge: 'lackOfTime',
        supportLevel: 'strong',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final metadata = {
        'templates': [
          {
            'pattern_id':
                'faithBased_new_lackOfTime_closerToGod_prayerDiscipline',
            'file':
                'faithBased_new_lackOfTime_closerToGod_prayerDiscipline.json',
            'fingerprint': {
              'primaryIntent': 'faithBased',
              'motivations': ['closerToGod', 'prayerDiscipline'],
              'challenge': 'lackOfTime',
              'supportLevel': 'strong',
              'spiritualMaturity': 'new'
            }
          }
        ]
      };

      final template = {
        'generated_habits': [
          {
            'name': 'Morning Prayer',
            'category': 'spiritual',
            'emoji': '🙏',
          }
        ]
      };

      when(() => mockCache.get<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => null);

      final metadataResponse = MockResponse();
      when(() => metadataResponse.statusCode).thenReturn(200);
      when(() => metadataResponse.body).thenReturn(jsonEncode(metadata));

      final templateResponse = MockResponse();
      when(() => templateResponse.statusCode).thenReturn(200);
      when(() => templateResponse.body).thenReturn(jsonEncode(template));

      when(() => mockHttpClient.get(any())).thenAnswer((invocation) async {
        final uri = invocation.positionalArguments[0] as Uri;
        if (uri.path.contains('metadata.json')) {
          return metadataResponse;
        } else {
          return templateResponse;
        }
      });

      when(() => mockCache.set<Map<String, dynamic>>(
          any(), any(), ttl: any(named: 'ttl'))).thenAnswer((_) async {});

      final result = await service.findMatch(profile, 'es');

      // Should find fuzzy match since similarity should be high (same intent, maturity, challenge)
      expect(result, isNotNull);
      expect(result!.length, 1);
    });
  });

  group('error handling', () {
    test('gracefully handles invalid JSON from network', () async {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline'],
        challenge: 'lackOfTime',
        supportLevel: 'strong',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      when(() => mockCache.get<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => null);

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
        supportLevel: 'strong',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      when(() => mockCache.get<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => null);

      final response = MockResponse();
      when(() => response.statusCode).thenReturn(404);

      when(() => mockHttpClient.get(any())).thenAnswer((_) async => response);

      final result = await service.findMatch(profile, 'es');

      expect(result, isNull);
    });
  });
}
