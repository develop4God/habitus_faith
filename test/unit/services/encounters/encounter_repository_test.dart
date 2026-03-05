// test/unit/services/encounters/encounter_repository_test.dart
//
// Tests for EncounterRepository: cache, versioning, fallback, network fetch.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/models/encounter_index_entry.dart';
import 'package:habitus_faith/core/models/encounter_study.dart';
import 'package:habitus_faith/core/services/encounters/encounter_repository.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockHttpClient extends Mock implements http.Client {}

// ---------------------------------------------------------------------------
// Test data helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _fakeIndexJson({String? status}) => {
      'encounters': [
        {
          'id': 'peter_water_001',
          'version': '1.0',
          'status': status ?? 'published',
          'files': {
            'en': 'peter_water_001_en.json',
            'es': 'peter_water_001_es.json'
          },
          'titles': {'en': 'Peter Walks on Water'},
          'subtitles': {'en': 'Faith Beyond the Storm'},
          'scripture_reference': {'en': 'Matthew 14:22-33'},
          'estimated_reading_minutes': {'en': 10},
        }
      ]
    };

Map<String, dynamic> _fakeStudyJson({String? version}) => {
      'id': 'peter_water_001',
      'language': 'en',
      'version': version ?? '1.0',
      'cards': [
        {'order': 1, 'type': 'cinematic_scene', 'title': 'Card 1'},
        {'order': 2, 'type': 'completion', 'title': 'Done'},
      ],
    };

EncounterIndexEntry _fakeEntry({String version = '1.0'}) =>
    EncounterIndexEntry(
      id: 'peter_water_001',
      version: version,
      emoji: '🌊',
      status: 'published',
      files: {'en': 'peter_water_001_en.json'},
      titles: {'en': 'Peter Walks on Water'},
      subtitles: {'en': 'Faith Beyond the Storm'},
      scriptureReference: {'en': 'Matthew 14:22-33'},
      estimatedReadingMinutes: {'en': 10},
    );

http.Response _successResponse(Map<String, dynamic> body) =>
    http.Response(jsonEncode(body), 200);

http.Response _errorResponse([int code = 404]) =>
    http.Response('Not Found', code);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    EncounterRepository.resetSessionFlag();
  });

  // ---------------------------------------------------------------------------
  // fetchIndex
  // ---------------------------------------------------------------------------

  group('EncounterRepository.fetchIndex', () {
    test('fetches and parses index from network on first call', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => _successResponse(_fakeIndexJson()));
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => _successResponse(_fakeIndexJson()));

      final repo = EncounterRepository(httpClient: mockClient);
      final entries = await repo.fetchIndex();

      expect(entries.length, 1);
      expect(entries.first.id, 'peter_water_001');
    });

    test('returns cached index within the same session (no extra request)', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => _successResponse(_fakeIndexJson()));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'encounter_index_cache', jsonEncode(_fakeIndexJson()));

      // Simulate session already fetched
      EncounterRepository.resetSessionFlag();
      final repo = EncounterRepository(httpClient: mockClient);
      // First call goes to network
      await repo.fetchIndex();
      // Second call should be cache-hit
      final entries = await repo.fetchIndex();

      expect(entries.length, 1);
      // Only one network call (first call), second is cache hit
      verify(() => mockClient.get(any())).called(1);
    });

    test('returns empty list when network fails and no cache', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any()))
          .thenThrow(Exception('no internet'));

      final repo = EncounterRepository(httpClient: mockClient);
      final entries = await repo.fetchIndex();

      expect(entries, isEmpty);
    });

    test('falls back to SharedPreferences cache on network error', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any()))
          .thenThrow(Exception('timeout'));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'encounter_index_cache', jsonEncode(_fakeIndexJson()));

      final repo = EncounterRepository(httpClient: mockClient);
      final entries = await repo.fetchIndex();

      expect(entries.length, 1);
      expect(entries.first.id, 'peter_water_001');
    });

    test('forceRefresh bypasses session cache and hits network', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => _successResponse(_fakeIndexJson()));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'encounter_index_cache', jsonEncode(_fakeIndexJson()));

      final repo = EncounterRepository(httpClient: mockClient);
      // First call (sets session flag)
      await repo.fetchIndex();
      // Force refresh should hit network again
      await repo.fetchIndex(forceRefresh: true);

      verify(() => mockClient.get(any())).called(2);
    });
  });

  // ---------------------------------------------------------------------------
  // fetchStudy
  // ---------------------------------------------------------------------------

  group('EncounterRepository.fetchStudy', () {
    test('fetches study from network and caches it', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => _successResponse(_fakeStudyJson()));

      final repo = EncounterRepository(httpClient: mockClient);
      final study = await repo.fetchStudy('peter_water_001', 'en');

      expect(study.id, 'peter_water_001');
      expect(study.cards.length, 2);

      // Verify it was cached
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('encounter_cache_peter_water_001_en'), true);
    });

    test('returns cached study when version matches', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => _successResponse(_fakeStudyJson()));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'encounter_cache_peter_water_001_en', jsonEncode(_fakeStudyJson()));
      await prefs.setString(
          'encounter_cache_peter_water_001_en_version', '1.0');

      final repo = EncounterRepository(httpClient: mockClient);
      final entry = _fakeEntry(version: '1.0');
      final study =
          await repo.fetchStudy('peter_water_001', 'en', entry: entry);

      expect(study.id, 'peter_water_001');
      // No network call because cache hit with matching version
      verifyNever(() => mockClient.get(any()));
    });

    test('re-fetches when version is stale', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => _successResponse(_fakeStudyJson(version: '2.0')));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'encounter_cache_peter_water_001_en', jsonEncode(_fakeStudyJson()));
      await prefs.setString(
          'encounter_cache_peter_water_001_en_version', '1.0');

      final repo = EncounterRepository(httpClient: mockClient);
      final entry = _fakeEntry(version: '2.0'); // newer version
      final study =
          await repo.fetchStudy('peter_water_001', 'en', entry: entry);

      // Should re-fetch because version changed
      verify(() => mockClient.get(any())).called(1);
      expect(study.id, 'peter_water_001');
    });

    test('uses cached study when no expectedVersion provided (legacy)', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => _successResponse(_fakeStudyJson()));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'encounter_cache_peter_water_001_en', jsonEncode(_fakeStudyJson()));
      // No version key stored — should serve from cache

      final repo = EncounterRepository(httpClient: mockClient);
      final study =
          await repo.fetchStudy('peter_water_001', 'en'); // no entry/version

      expect(study.id, 'peter_water_001');
      verifyNever(() => mockClient.get(any()));
    });

    test('uses English fallback when requested language not found', () async {
      final mockClient = MockHttpClient();
      int callCount = 0;
      when(() => mockClient.get(any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return _errorResponse(404); // pt version fails
        }
        return _successResponse(_fakeStudyJson()); // en fallback succeeds
      });

      final repo = EncounterRepository(httpClient: mockClient);
      final study = await repo.fetchStudy('peter_water_001', 'pt');

      expect(study.id, 'peter_water_001');
      expect(callCount, 2); // tried pt then en
    });

    test('throws when network fails and no cache available', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => _errorResponse(500));

      final repo = EncounterRepository(httpClient: mockClient);

      expect(
        () => repo.fetchStudy('peter_water_001', 'en'),
        throwsException,
      );
    });

    test('saves version to cache when fetching from network', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => _successResponse(_fakeStudyJson(version: '1.5')));

      final repo = EncounterRepository(httpClient: mockClient);
      final entry = _fakeEntry(version: '1.5');
      await repo.fetchStudy('peter_water_001', 'en', entry: entry);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString('encounter_cache_peter_water_001_en_version'),
        '1.5',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Index parsing
  // ---------------------------------------------------------------------------

  group('EncounterRepository index parsing', () {
    test('parses encounters key from index JSON', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => _successResponse({
                'encounters': [
                  {
                    'id': 'test_001',
                    'version': '1.0',
                    'files': <String, dynamic>{},
                    'titles': {'en': 'Test'},
                    'subtitles': <String, dynamic>{},
                    'scripture_reference': <String, dynamic>{},
                    'estimated_reading_minutes': <String, dynamic>{},
                  }
                ]
              }));

      final repo = EncounterRepository(httpClient: mockClient);
      final entries = await repo.fetchIndex();
      expect(entries.first.id, 'test_001');
    });

    test('parses studies key as alias for encounters key', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => _successResponse({
                'studies': [
                  {
                    'id': 'study_001',
                    'version': '1.0',
                    'files': <String, dynamic>{},
                    'titles': {'en': 'Study'},
                    'subtitles': <String, dynamic>{},
                    'scripture_reference': <String, dynamic>{},
                    'estimated_reading_minutes': <String, dynamic>{},
                  }
                ]
              }));

      final repo = EncounterRepository(httpClient: mockClient);
      final entries = await repo.fetchIndex();
      expect(entries.first.id, 'study_001');
    });

    test('returns empty list for unexpected JSON structure', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => _successResponse({'data': 'unexpected'}));

      final repo = EncounterRepository(httpClient: mockClient);
      final entries = await repo.fetchIndex();
      expect(entries, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // EncounterStudy — fromJson contract tests
  // ---------------------------------------------------------------------------

  group('EncounterStudy fromJson', () {
    test('parses id and cards from study JSON', () {
      final study = EncounterStudy.fromJson(_fakeStudyJson());
      expect(study.id, 'peter_water_001');
      expect(study.cards.length, 2);
    });

    test('returns empty cards list when cards key is missing', () {
      final study = EncounterStudy.fromJson({'id': 'test'});
      expect(study.cards, isEmpty);
    });
  });
}
