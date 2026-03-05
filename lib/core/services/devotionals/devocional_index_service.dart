// lib/core/services/devotionals/devocional_index_service.dart

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:habitus_faith/core/config/devotional_constants.dart';
import 'package:http/http.dart' as http;

/// Single responsibility: fetch and parse the devotional index.json,
/// and expose per-file date lookup for cache invalidation.
///
/// The index.json at [DevotionalConstants.getDevocionalIndexUrl()] has this shape:
/// ```json
/// {
///   "schema_version": 1,
///   "updated_at": "2026-03-01",
///   "files": {
///     "es": {
///       "RVR1960": { "2025": "2026-03-01", "2026": "2026-01-15" },
///       "NVI": { "2025": "2026-01-10" }
///     },
///     "en": { ... }
///   }
/// }
/// ```
class DevocionalIndexService {
  DevocionalIndexService(this._httpClient);

  final http.Client _httpClient;

  static const int _supportedSchemaVersion = 1;

  /// Fetches and parses index.json.
  ///
  /// Returns null on: network error, timeout, parse error, or unknown
  /// schema_version. Never throws.
  Future<Map<String, dynamic>?> fetchIndex() async {
    developer.log('🔍 [INDEX] Fetching index...', name: 'DevocionalIndex');
    try {
      final response = await _httpClient
          .get(Uri.parse(DevotionalConstants.getDevocionalIndexUrl()))
          .timeout(DevotionalConstants.indexFetchTimeout);

      if (response.statusCode != 200) {
        developer.log(
          '⚠️ [INDEX] Unreachable — HTTP ${response.statusCode} — using cache as-is',
          name: 'DevocionalIndex',
        );
        return null;
      }

      final Map<String, dynamic> parsed =
          json.decode(response.body) as Map<String, dynamic>;

      final int schemaVersion =
          (parsed['schema_version'] as num?)?.toInt() ?? 0;
      if (schemaVersion > _supportedSchemaVersion) {
        developer.log(
          '⚠️ [INDEX] Unknown schema_version: $schemaVersion — using cache as-is',
          name: 'DevocionalIndex',
        );
        return null;
      }

      final updatedAt = parsed['updated_at'] as String? ?? '';
      developer.log(
        '✅ [INDEX] Fetched — schema_version: $schemaVersion, updated_at: $updatedAt',
        name: 'DevocionalIndex',
      );
      return parsed;
    } catch (e) {
      developer.log(
        '⚠️ [INDEX] Unreachable — using cache as-is',
        name: 'DevocionalIndex',
      );
      return null;
    }
  }

  /// Returns the date string for [language][version][year] from a parsed index.
  ///
  /// Returns null if any key is not found — caller treats null as fresh
  /// (no re-fetch). Never throws.
  String? getFileDate(
    Map<String, dynamic> index,
    String language,
    String version,
    String year,
  ) {
    try {
      final files = index['files'] as Map<String, dynamic>?;
      if (files == null) return null;

      final langMap = files[language] as Map<String, dynamic>?;
      if (langMap == null) {
        developer.log(
          '⚠️ [INDEX] Key not found: $language/$version/$year — treating as fresh',
          name: 'DevocionalIndex',
        );
        return null;
      }

      final versionMap = langMap[version] as Map<String, dynamic>?;
      if (versionMap == null) {
        developer.log(
          '⚠️ [INDEX] Key not found: $language/$version/$year — treating as fresh',
          name: 'DevocionalIndex',
        );
        return null;
      }

      final date = versionMap[year] as String?;
      if (date == null) {
        developer.log(
          '⚠️ [INDEX] Key not found: $language/$version/$year — treating as fresh',
          name: 'DevocionalIndex',
        );
      }
      return date;
    } catch (e) {
      return null;
    }
  }
}
