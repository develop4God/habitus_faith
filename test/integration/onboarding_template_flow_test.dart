import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:habitus_faith/core/services/templates/template_matching_service.dart';
import 'package:habitus_faith/core/services/cache/cache_service.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/onboarding_models.dart';

// Mock classes
class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

void main() {
  late MockHttpClient mockHttpClient;
  late SharedPreferences prefs;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    mockHttpClient = MockHttpClient();
  });

  group('Onboarding Template Flow Integration Tests', () {
    test(
        'Template service successfully fetches and returns habits for faithBased profile',
        () async {
      // Setup mock HTTP responses for template fetching
      final metadata = {
        'templates': [
          {
            'pattern_id':
                'faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new',
            'file':
                'faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new.json',
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
        'pattern_id': 'faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new',
        'generated_habits': [
          {
            'name': 'Oración matutina',
            'description': 'Comienza tu día con Dios',
            'category': 'spiritual',
            'emoji': '🙏',
          },
          {
            'name': 'Lectura bíblica',
            'description': 'Lee la Palabra de Dios',
            'category': 'spiritual',
            'emoji': '📖',
          }
        ]
      };

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

      final cacheService = CacheService(prefs);
      final templateService =
          TemplateMatchingService(cacheService, httpClient: mockHttpClient);

      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline'],
        challenge: 'lackOfTime',
        supportLevel: 'normal',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final result = await templateService.findMatch(profile, 'es');

      expect(result, isNotNull);
      expect(result!.length, 2);
      expect(result[0]['name'], 'Oración matutina');
      expect(result[1]['name'], 'Lectura bíblica');
    });

    test('Falls back gracefully when template not found', () async {
      final metadata = {'templates': []};

      final metadataResponse = MockResponse();
      when(() => metadataResponse.statusCode).thenReturn(200);
      when(() => metadataResponse.body).thenReturn(jsonEncode(metadata));

      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => metadataResponse);

      final cacheService = CacheService(prefs);
      final templateService =
          TemplateMatchingService(cacheService, httpClient: mockHttpClient);

      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline'],
        challenge: 'lackOfTime',
        supportLevel: 'normal',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final result = await templateService.findMatch(profile, 'es');

      expect(result, isNull);
    });

    test('Handles network errors gracefully', () async {
      when(() => mockHttpClient.get(any()))
          .thenThrow(Exception('Network error'));

      final cacheService = CacheService(prefs);
      final templateService =
          TemplateMatchingService(cacheService, httpClient: mockHttpClient);

      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline'],
        challenge: 'lackOfTime',
        supportLevel: 'normal',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final result = await templateService.findMatch(profile, 'es');

      expect(result, isNull);
    });

    test('Caches templates for subsequent requests', () async {
      final metadata = {
        'templates': [
          {
            'pattern_id':
                'faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new',
            'file':
                'faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new.json',
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
            'name': 'Test Habit',
            'category': 'spiritual',
            'emoji': '🙏',
          }
        ]
      };

      int metadataCallCount = 0;

      final metadataResponse = MockResponse();
      when(() => metadataResponse.statusCode).thenReturn(200);
      when(() => metadataResponse.body).thenReturn(jsonEncode(metadata));

      final templateResponse = MockResponse();
      when(() => templateResponse.statusCode).thenReturn(200);
      when(() => templateResponse.body).thenReturn(jsonEncode(template));

      when(() => mockHttpClient.get(any())).thenAnswer((invocation) async {
        final uri = invocation.positionalArguments[0] as Uri;
        if (uri.path.contains('metadata.json')) {
          metadataCallCount++;
          return metadataResponse;
        } else {
          return templateResponse;
        }
      });

      final cacheService = CacheService(prefs);
      final templateService =
          TemplateMatchingService(cacheService, httpClient: mockHttpClient);

      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline'],
        challenge: 'lackOfTime',
        supportLevel: 'normal',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      // First call should fetch from network
      await templateService.findMatch(profile, 'es');
      expect(metadataCallCount, 1);

      // Second call should use cache (metadata call count should not increase)
      await templateService.findMatch(profile, 'es');

      // Should still be 1 because of caching
      expect(metadataCallCount, 1);
    });

    test('Fuzzy matching works for similar but not identical profiles',
        () async {
      final metadata = {
        'templates': [
          {
            'pattern_id':
                'faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new',
            'file':
                'faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new.json',
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
            'name': 'Test Habit',
            'category': 'spiritual',
            'emoji': '🙏',
          }
        ]
      };

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

      final cacheService = CacheService(prefs);
      final templateService =
          TemplateMatchingService(cacheService, httpClient: mockHttpClient);

      // Profile with different motivations but same intent and challenge
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: [
          'closerToGod',
          'understandBible'
        ], // Different second motivation
        challenge: 'lackOfTime',
        supportLevel: 'normal',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final result = await templateService.findMatch(profile, 'es');

      // Should find fuzzy match
      expect(result, isNotNull);
      expect(result!.length, 1);
    });

    test('Chinese language template fetching works correctly', () async {
      final metadata = {
        'templates': [
          {
            'pattern_id':
                'faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new',
            'file':
                'faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new.json',
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
            'name': '晨间祷告2分钟',
            'category': 'spiritual',
            'emoji': '🙏',
          }
        ]
      };

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

      final cacheService = CacheService(prefs);
      final templateService =
          TemplateMatchingService(cacheService, httpClient: mockHttpClient);

      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline'],
        challenge: 'lackOfTime',
        supportLevel: 'normal',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final result = await templateService.findMatch(profile, 'zh');

      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0]['name'], '晨间祷告2分钟');
    });

    test('Extended scenarios - passionate maturity with givingUp challenge',
        () async {
      final metadata = {
        'templates': [
          {
            'pattern_id':
                'faithBased_normal_givingUp_prayerDiscipline_growInFaith_passionate',
            'file':
                'faithBased_normal_givingUp_prayerDiscipline_growInFaith_passionate.json',
            'fingerprint': {
              'primaryIntent': 'faithBased',
              'motivations': ['prayerDiscipline', 'growInFaith'],
              'challenge': 'givingUp',
              'supportLevel': null,
              'spiritualMaturity': 'passionate'
            }
          }
        ]
      };

      final template = {
        'generated_habits': [
          {
            'name': 'Service Prayer',
            'category': 'spiritual',
            'emoji': '❤️',
          }
        ]
      };

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

      final cacheService = CacheService(prefs);
      final templateService =
          TemplateMatchingService(cacheService, httpClient: mockHttpClient);

      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['prayerDiscipline', 'growInFaith'],
        challenge: 'givingUp',
        supportLevel: 'normal',
        spiritualMaturity: 'passionate',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final result = await templateService.findMatch(profile, 'en');

      expect(result, isNotNull);
      expect(result!.length, 1);
    });
  });
}
