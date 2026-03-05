// test/unit/providers/devotional_notifier_cache_test.dart
//
// Tests for DevotionalNotifier sidecar cache decision logic.
// Covers the four paths in _fetchDevocionalesForLanguage:
//   Path A — index reachable + cache fresh   → serve local file
//   Path B — index reachable + cache stale   → re-fetch from API + write sidecar
//   Path C — index unreachable + local exists → serve stale gracefully (offline)
//   Path D — index unreachable + no local    → fetch from API

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/devotionals/cache_metadata_service.dart';
import 'package:habitus_faith/core/services/devotionals/devocional_index_service.dart';
import 'package:habitus_faith/providers/devotional_providers.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockDevocionalIndexService extends Mock
    implements DevocionalIndexService {}

class MockCacheMetadataService extends Mock implements CacheMetadataService {}

class MockHttpClient extends Mock implements http.Client {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Minimal valid devotional JSON that _processDevocionalData can parse
/// without crashing. Uses current year so sorting logic does not throw.
String _fakeApiBody() {
  return jsonEncode({
    'data': {
      'es': {
        '2026-01-01': [
          {
            'id': 'dev_001',
            'date': '2026-01-01',
            'reflexion': 'Test reflection',
            'versiculo': 'Test verse',
            'oracion': 'Test prayer',
            'tags': ['fe'],
          }
        ]
      }
    }
  });
}

Map<String, dynamic> _fakeIndex() => {
      'schema_version': 1,
      'updated_at': '2026-03-01',
      'files': {
        'es': {
          'RVR1960': {'2026': '2026-03-01'},
        },
      },
    };

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDevocionalIndexService mockIndex;
  late MockCacheMetadataService mockCache;
  late MockHttpClient mockHttp;
  late Directory tempDir;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockIndex = MockDevocionalIndexService();
    mockCache = MockCacheMetadataService();
    mockHttp = MockHttpClient();
    tempDir = await Directory.systemTemp.createTemp('notifier_test_');
    // Intercept path_provider's platform channel so tests don't need a host runner
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall call) async => tempDir.path,
    );
  });

  tearDown(() async {
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  DevotionalNotifier buildNotifier() => DevotionalNotifier(
        indexService: mockIndex,
        cacheService: mockCache,
        httpClient: mockHttp,
      );

  // ── Path A — fresh cache ──────────────────────────────────────────────────
  group('Path A — index reachable + cache fresh → serve local', () {
    test('does NOT call http client when cache is fresh', () async {
      when(() => mockIndex.fetchIndex()).thenAnswer((_) async => _fakeIndex());
      when(() => mockIndex.getFileDate(any(), any(), any(), any()))
          .thenReturn('2026-03-01');
      when(() => mockCache.readManifestDate(any()))
          .thenAnswer((_) async => '2026-03-01'); // sidecar matches index

      // Pre-seed the local file so hasLocal = true.
      // TestWidgetsFlutterBinding returns locale 'en', so the notifier picks
      // 'en'/'KJV'.  The path_provider mock redirects to tempDir.
      final year = DateTime.now().year;
      final devDir = Directory('${tempDir.path}/devotionals');
      await devDir.create(recursive: true);
      await File('${devDir.path}/devocional_${year}_en_KJV.json')
          .writeAsString(_fakeApiBody());

      final notifier = buildNotifier();
      await notifier.initialize();

      verifyNever(() => mockHttp.get(any()));
    });
  });

  // ── Path B — stale cache ──────────────────────────────────────────────────
  group('Path B — index reachable + cache stale → re-fetch API', () {
    test('calls http client when sidecar date differs from index date',
        () async {
      when(() => mockIndex.fetchIndex()).thenAnswer((_) async => _fakeIndex());
      when(() => mockIndex.getFileDate(any(), any(), any(), any()))
          .thenReturn('2026-03-01');
      when(() => mockCache.readManifestDate(any()))
          .thenAnswer((_) async => '2026-01-01'); // stale sidecar
      when(() => mockCache.writeMetadata(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockHttp.get(any()))
          .thenAnswer((_) async => http.Response(_fakeApiBody(), 200));

      final notifier = buildNotifier();
      await notifier.initialize();

      verify(() => mockHttp.get(any())).called(greaterThanOrEqualTo(1));
    });

    test('writes sidecar after successful API fetch', () async {
      when(() => mockIndex.fetchIndex()).thenAnswer((_) async => _fakeIndex());
      when(() => mockIndex.getFileDate(any(), any(), any(), any()))
          .thenReturn('2026-03-01');
      when(() => mockCache.readManifestDate(any()))
          .thenAnswer((_) async => null); // no sidecar = stale
      when(() => mockCache.writeMetadata(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockHttp.get(any()))
          .thenAnswer((_) async => http.Response(_fakeApiBody(), 200));

      final notifier = buildNotifier();
      await notifier.initialize();

      verify(() => mockCache.writeMetadata(any(), any()))
          .called(greaterThanOrEqualTo(1));
    });
  });

  // ── Path C — offline + local exists ──────────────────────────────────────
  group('Path C — index unreachable + local exists → serve stale', () {
    test('does NOT throw and sets isOfflineMode when index unreachable',
        () async {
      when(() => mockIndex.fetchIndex()).thenAnswer((_) async => null);
      when(() => mockCache.readManifestDate(any()))
          .thenAnswer((_) async => '2026-01-01');
      when(() => mockCache.writeMetadata(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockHttp.get(any()))
          .thenAnswer((_) async => http.Response(_fakeApiBody(), 200));

      // Seed a local file so hasLocal = true and the notifier serves it
      // instead of falling through to Path D (API fetch).
      final year = DateTime.now().year;
      final devDir = Directory('${tempDir.path}/devotionals');
      await devDir.create(recursive: true);
      await File('${devDir.path}/devocional_${year}_en_KJV.json')
          .writeAsString(_fakeApiBody());

      final container = ProviderContainer(
        overrides: [
          devotionalProvider.overrideWith(
            (ref) => DevotionalNotifier(
              indexService: mockIndex,
              cacheService: mockCache,
              httpClient: mockHttp,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(devotionalProvider.notifier).initialize();

      // Verify offline mode was set and no error occurred
      final st = container.read(devotionalProvider);
      expect(st.isOfflineMode, isTrue);
      expect(st.errorMessage, isNull);
      // HTTP client should NOT have been called — served from local file
      verifyNever(() => mockHttp.get(any()));
    });
  });

  // ── Path D — index unreachable + no local ─────────────────────────────────
  group('Path D — index unreachable + no local → fetch from API', () {
    test('calls API when index is unreachable and no local file exists',
        () async {
      when(() => mockIndex.fetchIndex()).thenAnswer((_) async => null);
      when(() => mockCache.readManifestDate(any()))
          .thenAnswer((_) async => null);
      when(() => mockCache.writeMetadata(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockHttp.get(any()))
          .thenAnswer((_) async => http.Response(_fakeApiBody(), 200));

      final notifier = buildNotifier();
      await notifier.initialize();

      verify(() => mockHttp.get(any())).called(greaterThanOrEqualTo(1));
    });
  });

  // ── Dispose guard ─────────────────────────────────────────────────────────
  group('Dispose guard', () {
    test('does not throw StateError when disposed mid-flight', () async {
      when(() => mockIndex.fetchIndex()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 10));
        return null;
      });
      when(() => mockCache.readManifestDate(any()))
          .thenAnswer((_) async => null);
      when(() => mockHttp.get(any()))
          .thenAnswer((_) async => http.Response(_fakeApiBody(), 200));
      when(() => mockCache.writeMetadata(any(), any()))
          .thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          devotionalProvider.overrideWith(
            (ref) => DevotionalNotifier(
              indexService: mockIndex,
              cacheService: mockCache,
              httpClient: mockHttp,
            ),
          ),
        ],
      );

      // Start initialize, then dispose the container (Riverpod-managed teardown)
      final notifier = container.read(devotionalProvider.notifier);
      final future = notifier.initialize();
      container.dispose(); // ← correct: let Riverpod call notifier.dispose()

      await expectLater(future, completes);
    });
  });
}
