// lib/core/services/encounters/encounter_repository.dart

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:habitus_faith/core/config/devotional_constants.dart';
import 'package:habitus_faith/core/models/encounter_index_entry.dart';
import 'package:habitus_faith/core/models/encounter_study.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for fetching Encounters content from remote JSON via GitHub.
///
/// Strategy: Network-first with fallback to SharedPreferences cache.
/// Version-aware cache invalidation: when the index entry version changes,
/// the cached study is considered stale and re-fetched.
class EncounterRepository {
  final http.Client httpClient;

  static const String _indexCacheKey = 'encounter_index_cache';
  static const String _studyCacheKeyPrefix = 'encounter_cache_';
  static const String _studyVersionSuffix = '_version';

  /// Fetched at most once per app session — reset on every cold start.
  static bool _indexFetchedThisSession = false;

  static const Duration _networkTimeout = Duration(seconds: 10);

  EncounterRepository({required this.httpClient});

  // ---------------------------------------------------------------------------
  // Index
  // ---------------------------------------------------------------------------

  /// Fetches the encounter index. Cache-first within session → network → empty.
  Future<List<EncounterIndexEntry>> fetchIndex({
    bool forceRefresh = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // ── Cache-First: serve from cache within the same app session ──
    if (!forceRefresh && _indexFetchedThisSession) {
      final cachedIndex = prefs.getString(_indexCacheKey);
      if (cachedIndex != null) {
        final entries =
            _parseIndex(jsonDecode(cachedIndex) as Map<String, dynamic>);
        debugPrint(
            '✅ Encounter: Index cache hit (same session, skipping network)');
        return entries;
      }
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final url = DevotionalConstants.getEncounterIndexUrl();
      final cacheBusterUrl = '$url?cb=$timestamp';

      debugPrint(
          '🌐 Encounter: Fetching index — session flag: $_indexFetchedThisSession');
      final response = await httpClient
          .get(Uri.parse(cacheBusterUrl))
          .timeout(_networkTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final entries = _parseIndex(json);
        await prefs.setString(_indexCacheKey, response.body);
        _indexFetchedThisSession = true;
        debugPrint('💾 Encounter: Index cached — ${entries.length} entries');
        return entries;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ Encounter: Network error fetching index: $e');

      // Try SharedPreferences cache
      final cached = prefs.getString(_indexCacheKey);
      if (cached != null) {
        try {
          final entries =
              _parseIndex(jsonDecode(cached) as Map<String, dynamic>);
          debugPrint(
              '📦 Encounter: Using cached index after network failure — ${entries.length} entries');
          return entries;
        } catch (_) {
          debugPrint(
              '💥 Encounter: Cached index corrupt — returning empty list');
        }
      }

      return [];
    }
  }

  List<EncounterIndexEntry> _parseIndex(Map<String, dynamic> json) {
    final entries = json['encounters'] ?? json['studies'] ?? json['entries'];
    if (entries is List) {
      return entries
          .whereType<Map<String, dynamic>>()
          .map(EncounterIndexEntry.fromJson)
          .toList();
    }
    return [];
  }

  // ---------------------------------------------------------------------------
  // Study
  // ---------------------------------------------------------------------------

  /// Fetches an individual encounter study. Checks cache first, then network.
  ///
  /// [filename] — the exact filename from the index `files` map
  ///   (e.g. `peter_water_001_es.json`). Preferred over constructing it from [id].
  /// [entry] — index entry carrying the expected version for cache validation.
  Future<EncounterStudy> fetchStudy(
    String id,
    String lang, {
    String? filename,
    EncounterIndexEntry? entry,
  }) async {
    // 1. Check SharedPreferences cache with version validation
    final cached = await _loadStudyFromCache(id, lang, entry?.version);
    if (cached != null) return cached;

    // 2. Fetch from network
    try {
      final study = await _fetchStudyFromNetwork(
        id,
        lang,
        filename: filename,
        version: entry?.version,
      );
      return study;
    } catch (e) {
      developer.log('❌ Encounter: Error fetching study $id ($lang): $e',
          name: 'EncounterRepository');
      rethrow;
    }
  }

  /// Non-recursive network fetch: tries [lang], then 'en' if different.
  Future<EncounterStudy> _fetchStudyFromNetwork(
    String id,
    String lang, {
    String? filename,
    String? version,
  }) async {
    final url =
        DevotionalConstants.getEncounterStudyUrl(id, lang, filename: filename);
    debugPrint('🌐 Encounter: Fetching study $id ($lang) from $url');
    final response =
        await httpClient.get(Uri.parse(url)).timeout(_networkTimeout);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final study = EncounterStudy.fromJson(json);
      await _saveStudyToCache(id, lang, response.body, version);
      return study;
    }

    // Try English fallback once (no recursion)
    if (lang != 'en') {
      debugPrint(
          '⚠️ Encounter: $lang not found for $id, trying English fallback');
      String? enFilename;
      if (filename != null) {
        enFilename = filename.contains('_${lang}_')
            ? filename.replaceFirst('_${lang}_', '_en_')
            : filename.replaceAll('_$lang.json', '_en.json');
      }
      final enUrl =
          DevotionalConstants.getEncounterStudyUrl(id, 'en', filename: enFilename);
      final enResponse =
          await httpClient.get(Uri.parse(enUrl)).timeout(_networkTimeout);
      if (enResponse.statusCode == 200) {
        final json = jsonDecode(enResponse.body) as Map<String, dynamic>;
        final study = EncounterStudy.fromJson(json);
        await _saveStudyToCache(id, 'en', enResponse.body, version);
        return study;
      }
    }

    throw Exception(
        'Failed to load encounter study $id: ${response.statusCode}');
  }

  Future<EncounterStudy?> _loadStudyFromCache(
    String id,
    String lang, [
    String? expectedVersion,
  ]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contentKey = '$_studyCacheKeyPrefix${id}_$lang';
      final cached = prefs.getString(contentKey);

      if (cached == null) {
        debugPrint(
            '📭 Encounter: No cache for $id ($lang) — first install or cleared');
        return null;
      }

      // Version check — only when expectedVersion is provided
      if (expectedVersion != null) {
        final cachedVersion =
            prefs.getString('$contentKey$_studyVersionSuffix');
        if (cachedVersion != expectedVersion) {
          debugPrint(
            '🔄 Encounter: Stale cache for $id ($lang) '
            '— cached: $cachedVersion, expected: $expectedVersion',
          );
          return null; // stale → trigger network re-fetch
        }
      }

      debugPrint('✅ Encounter: Cache hit $id ($lang) v$expectedVersion');
      return EncounterStudy.fromJson(
          jsonDecode(cached) as Map<String, dynamic>);
    } catch (e) {
      developer.log('Failed to load encounter study from cache: $e',
          name: 'EncounterRepository._loadStudyFromCache');
    }
    return null;
  }

  Future<void> _saveStudyToCache(
    String id,
    String lang,
    String body, [
    String? version,
  ]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contentKey = '$_studyCacheKeyPrefix${id}_$lang';
      await prefs.setString(contentKey, body);
      if (version != null) {
        await prefs.setString('$contentKey$_studyVersionSuffix', version);
      }
      debugPrint('💾 Encounter: Saved $id ($lang) v$version to cache');
    } catch (e) {
      developer.log('Failed to save encounter study to cache: $e',
          name: 'EncounterRepository._saveStudyToCache');
    }
  }

  /// Clears the session flag so the index is re-fetched next time.
  /// Useful for testing or forced refresh.
  static void resetSessionFlag() {
    _indexFetchedThisSession = false;
  }
}
