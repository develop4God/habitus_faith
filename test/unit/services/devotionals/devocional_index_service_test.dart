// test/unit/services/devotionals/devocional_index_service_test.dart
//
// Tests for DevocionalIndexService and CacheMetadataService.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/devotionals/cache_metadata_service.dart';
import 'package:habitus_faith/core/services/devotionals/devocional_index_service.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockHttpClient extends Mock implements http.Client {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _fakeIndex({int schemaVersion = 1}) => {
      'schema_version': schemaVersion,
      'updated_at': '2026-03-01',
      'files': {
        'es': {
          'RVR1960': {'2025': '2026-02-15', '2026': '2026-01-01'},
        },
        'en': {
          'KJV': {'2025': '2026-02-20'},
        },
      },
    };

http.Response _successResponse(Map<String, dynamic> body) =>
    http.Response(jsonEncode(body), 200);

http.Response _errorResponse([int code = 500]) =>
    http.Response('Server Error', code);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  // ---------------------------------------------------------------------------
  // DevocionalIndexService
  // ---------------------------------------------------------------------------

  group('DevocionalIndexService', () {
    test('fetchIndex returns parsed index on success', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => _successResponse(_fakeIndex()));

      final service = DevocionalIndexService(mockClient);
      final index = await service.fetchIndex();

      expect(index, isNotNull);
      expect(index!['schema_version'], 1);
      expect(index['updated_at'], '2026-03-01');
    });

    test('fetchIndex returns null on HTTP error', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => _errorResponse(500));

      final service = DevocionalIndexService(mockClient);
      final index = await service.fetchIndex();

      expect(index, isNull);
    });

    test('fetchIndex returns null on network exception', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any())).thenThrow(Exception('timeout'));

      final service = DevocionalIndexService(mockClient);
      final index = await service.fetchIndex();

      expect(index, isNull);
    });

    test('fetchIndex returns null for unsupported schema_version', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any())).thenAnswer(
          (_) async => _successResponse(_fakeIndex(schemaVersion: 99)));

      final service = DevocionalIndexService(mockClient);
      final index = await service.fetchIndex();

      expect(index, isNull);
    });

    test('getFileDate returns correct date for known key', () async {
      final mockClient = MockHttpClient();
      final service = DevocionalIndexService(mockClient);
      final index = _fakeIndex();

      final date = service.getFileDate(index, 'es', 'RVR1960', '2025');
      expect(date, '2026-02-15');
    });

    test('getFileDate returns null when language not in index', () async {
      final mockClient = MockHttpClient();
      final service = DevocionalIndexService(mockClient);

      final date = service.getFileDate(_fakeIndex(), 'fr', 'LSG1910', '2025');
      expect(date, isNull);
    });

    test('getFileDate returns null when version not in index', () async {
      final mockClient = MockHttpClient();
      final service = DevocionalIndexService(mockClient);

      final date = service.getFileDate(_fakeIndex(), 'es', 'NVI', '2025');
      expect(date, isNull);
    });

    test('getFileDate returns null when year not in index', () async {
      final mockClient = MockHttpClient();
      final service = DevocionalIndexService(mockClient);

      final date = service.getFileDate(_fakeIndex(), 'es', 'RVR1960', '2020');
      expect(date, isNull);
    });

    test('getFileDate handles empty index gracefully', () async {
      final mockClient = MockHttpClient();
      final service = DevocionalIndexService(mockClient);

      final date = service.getFileDate({}, 'es', 'RVR1960', '2025');
      expect(date, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // CacheMetadataService
  // ---------------------------------------------------------------------------

  group('CacheMetadataService', () {
    late Directory tempDir;
    late CacheMetadataService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('sidecar_test_');
      service = CacheMetadataService();
    });

    tearDown(() async {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    });

    test('readManifestDate returns null when sidecar does not exist', () async {
      final path = '${tempDir.path}/devocional_2025_es.json';
      final date = await service.readManifestDate(path);
      expect(date, isNull);
    });

    test('writeMetadata creates sidecar file with correct content', () async {
      final contentPath = '${tempDir.path}/devocional_2025_es.json';
      await service.writeMetadata(contentPath, '2026-02-15');

      final sidecarPath = '${tempDir.path}/devocional_2025_es.meta.json';
      expect(await File(sidecarPath).exists(), true);

      final raw = await File(sidecarPath).readAsString();
      final parsed = jsonDecode(raw) as Map<String, dynamic>;
      expect(parsed['manifest_date'], '2026-02-15');
      expect(parsed['schema_version'], 1);
    });

    test('readManifestDate returns correct date from existing sidecar',
        () async {
      final contentPath = '${tempDir.path}/devocional_2025_es.json';
      await service.writeMetadata(contentPath, '2026-03-01');

      final date = await service.readManifestDate(contentPath);
      expect(date, '2026-03-01');
    });

    test('readManifestDate returns null for corrupt sidecar', () async {
      final sidecarPath = '${tempDir.path}/devocional_corrupt.meta.json';
      await File(sidecarPath).writeAsString('{ bad json }');

      final contentPath = '${tempDir.path}/devocional_corrupt.json';
      final date = await service.readManifestDate(contentPath);
      expect(date, isNull);
    });

    test('writeMetadata is idempotent — overwrites existing sidecar', () async {
      final contentPath = '${tempDir.path}/devocional_2026_en.json';
      await service.writeMetadata(contentPath, '2026-01-01');
      await service.writeMetadata(contentPath, '2026-03-01'); // overwrite

      final date = await service.readManifestDate(contentPath);
      expect(date, '2026-03-01');
    });

    test('sidecar path derived correctly from content path', () async {
      final contentPath = '${tempDir.path}/devocional_2025_en_KJV.json';
      await service.writeMetadata(contentPath, '2026-02-01');

      final sidecarPath = '${tempDir.path}/devocional_2025_en_KJV.meta.json';
      expect(await File(sidecarPath).exists(), true);
    });
  });
}
