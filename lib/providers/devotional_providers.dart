// lib/providers/devotional_providers.dart

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/devotional_constants.dart';
import '../core/models/devocional_model.dart';
import '../core/services/devotionals/cache_metadata_service.dart';
import '../core/services/devotionals/devocional_index_service.dart';

/// State class for devotional data
class DevotionalState {
  final List<Devocional> all;
  final List<Devocional> filtered;
  final List<Devocional> favorites;
  final bool isLoading;
  final String? errorMessage;
  final String selectedLanguage;
  final String selectedVersion;
  final bool isOfflineMode;

  const DevotionalState({
    required this.all,
    required this.filtered,
    required this.favorites,
    required this.isLoading,
    this.errorMessage,
    required this.selectedLanguage,
    required this.selectedVersion,
    required this.isOfflineMode,
  });

  DevotionalState copyWith({
    List<Devocional>? all,
    List<Devocional>? filtered,
    List<Devocional>? favorites,
    bool? isLoading,
    String? errorMessage,
    String? selectedLanguage,
    String? selectedVersion,
    bool? isOfflineMode,
  }) {
    return DevotionalState(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedVersion: selectedVersion ?? this.selectedVersion,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
    );
  }
}

/// Devotional State Notifier
class DevotionalNotifier extends StateNotifier<DevotionalState> {
  /// Injectable services — default to production implementations.
  /// Pass custom instances in tests to avoid file I/O and network calls.
  final DevocionalIndexService _indexService;
  final CacheMetadataService _cacheService;
  final http.Client _httpClient;
  bool _disposed = false;

  /// Full index map from last successful fetch — null when unreachable.
  Map<String, dynamic>? _cachedIndex;

  DevotionalNotifier({
    DevocionalIndexService? indexService,
    CacheMetadataService? cacheService,
    http.Client? httpClient,
  })  : _httpClient = httpClient ?? http.Client(),
        _cacheService = cacheService ?? CacheMetadataService(),
        _indexService = indexService ??
            DevocionalIndexService(httpClient ?? http.Client()),
        super(_initialState());

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    super.dispose();
  }

  static DevotionalState _initialState() {
    return const DevotionalState(
      all: [],
      filtered: [],
      favorites: [],
      isLoading: false,
      selectedLanguage: 'es',
      selectedVersion: 'RVR1960',
      isOfflineMode: false,
    );
  }

  /// Initialize devotional data
  Future<void> initialize() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceLanguage = PlatformDispatcher.instance.locale.languageCode;

      // Get saved language or use device language
      String savedLanguage =
          prefs.getString(DevotionalConstants.prefSelectedLanguage) ??
              deviceLanguage;
      String selectedLanguage = _getSupportedLanguageWithFallback(
        savedLanguage,
      );

      // Save language if different from saved
      if (selectedLanguage != savedLanguage) {
        await prefs.setString(
          DevotionalConstants.prefSelectedLanguage,
          selectedLanguage,
        );
      }

      // Get saved version or use default and validate it's compatible with language
      String savedVersion =
          prefs.getString(DevotionalConstants.prefSelectedVersion) ?? '';
      String defaultVersion =
          DevotionalConstants.defaultVersionByLanguage[selectedLanguage] ??
              'RVR1960';

      final availableVersions =
          DevotionalConstants.bibleVersionsByLanguage[selectedLanguage] ?? [];

      String selectedVersion;
      if (savedVersion.isNotEmpty && availableVersions.contains(savedVersion)) {
        selectedVersion = savedVersion;
      } else {
        selectedVersion = defaultVersion;
        // Persist the default version for this language when falling back
        await prefs.setString(
          DevotionalConstants.prefSelectedVersion,
          selectedVersion,
        );
      }

      // Update state with language and version
      if (_disposed) return;
      state = state.copyWith(
        selectedLanguage: selectedLanguage,
        selectedVersion: selectedVersion,
      );

      // Load favorites
      await _loadFavorites();

      // Fetch devotionals
      await _fetchDevocionalesForLanguage();
    } catch (e) {
      debugPrint('Error in initialize: $e');
      if (_disposed) return;
      state = state.copyWith(
        errorMessage: 'Error al inicializar los datos: $e',
        isLoading: false,
      );
    }
  }

  String _getSupportedLanguageWithFallback(String requestedLanguage) {
    const supportedLanguages = ['es', 'en', 'pt', 'fr', 'zh'];
    if (supportedLanguages.contains(requestedLanguage)) {
      return requestedLanguage;
    }
    return 'es'; // fallback
  }

  /// Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString(
        DevotionalConstants.prefFavorites,
      );

      if (favoritesJson != null && favoritesJson.isNotEmpty) {
        final List<dynamic> favoritesData = json.decode(favoritesJson);
        final favorites =
            favoritesData.map((item) => Devocional.fromJson(item)).toList();
        state = state.copyWith(favorites: favorites);
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  /// Fetch devotionals — sidecar-aware: checks index.json for staleness,
  /// loads from local file when fresh, re-fetches from API when stale.
  Future<void> _fetchDevocionalesForLanguage() async {
    if (_disposed) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final int currentYear = DateTime.now().year;

      // ── Step 1: Fetch the index — before any cache decisions ──────────────
      // If unreachable, fall back to local file without staleness check.
      _cachedIndex = await _indexService.fetchIndex();
      if (_disposed) return;
      final bool indexUnreachable = (_cachedIndex == null);

      // ── Step 2: Decide whether to use cached file or re-fetch from API ───
      final String filePath = await _getLocalFilePath(
        currentYear,
        state.selectedLanguage,
        state.selectedVersion,
      );

      final String? indexDate = indexUnreachable
          ? null
          : _indexService.getFileDate(
              _cachedIndex!,
              state.selectedLanguage,
              state.selectedVersion,
              currentYear.toString(),
            );

      final String? sidecarDate =
          await _cacheService.readManifestDate(filePath);

      // Stale when index has a date AND sidecar is missing or different
      final bool isStale = (indexDate != null) &&
          (sidecarDate == null || sidecarDate != indexDate);

      if (isStale) {
        developer.log(
          '🔄 [CACHE] Stale: ${currentYear}_${state.selectedLanguage}_${state.selectedVersion}'
          ' — index: $indexDate, sidecar: $sidecarDate',
          name: 'DevocionalCache',
        );
      }

      final bool hasLocal = await File(filePath).exists();

      if (!isStale && hasLocal) {
        // ── Cache is fresh — load from local file ──────────────────────────
        developer.log(
          '✅ [CACHE] Fresh: using local file',
          name: 'DevocionalCache',
        );
        final Map<String, dynamic>? localData = await _loadFromLocalStorage(
            currentYear, state.selectedLanguage, state.selectedVersion);
        if (localData != null) {
          if (_disposed) return;
          await _processDevocionalData(localData);
          if (_disposed) return;
          state = state.copyWith(isOfflineMode: indexUnreachable);
          return;
        }
      }

      // ── Stale or no local file — fetch from API ────────────────────────
      final String url = DevotionalConstants.getDevocionalesApiUrlMultilingual(
        currentYear,
        state.selectedLanguage,
        state.selectedVersion,
      );
      debugPrint('🔍 Fetching devotionals from: $url');
      final response = await _httpClient.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        await _processDevocionalData(data);
        // Persist to local file with sidecar
        await _saveToLocalStorage(
          currentYear,
          state.selectedLanguage,
          response.body,
          state.selectedVersion,
        );
      } else if (hasLocal) {
        // API failed but we have stale cache — use it gracefully
        final Map<String, dynamic>? localData = await _loadFromLocalStorage(
            currentYear, state.selectedLanguage, state.selectedVersion);
        if (localData != null) {
          await _processDevocionalData(localData);
        } else {
          throw Exception('Failed to load: ${response.statusCode}');
        }
      } else {
        throw Exception('Failed to load from API: ${response.statusCode}');
      }

      if (_disposed) return;
      state = state.copyWith(isOfflineMode: indexUnreachable);
    } catch (e) {
      debugPrint('Error fetching devotionals: $e');
      if (_disposed) return;
      state = state.copyWith(
        errorMessage: 'Error al cargar los devocionales: $e',
        isLoading: false,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Local storage helpers
  // ---------------------------------------------------------------------------

  Future<Directory> _getLocalStorageDirectory() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory dir = Directory('${appDir.path}/devotionals');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> _getLocalFilePath(
    int year,
    String language, [
    String? version,
  ]) async {
    final Directory storageDir = await _getLocalStorageDirectory();
    if (language == 'es' && (version == null || version == 'RVR1960')) {
      return '${storageDir.path}/devocional_${year}_$language.json';
    }
    final versionSuffix = version != null ? '_$version' : '';
    return '${storageDir.path}/devocional_${year}_$language$versionSuffix.json';
  }

  Future<void> _saveToLocalStorage(
    int year,
    String language,
    String content, [
    String? version,
  ]) async {
    try {
      final String filePath = await _getLocalFilePath(year, language, version);
      await File(filePath).writeAsString(content);
      debugPrint('✅ Saved to local storage: $filePath');

      // Write sidecar atomically after JSON save
      final String manifestDate = _indexService.getFileDate(
            _cachedIndex ?? {},
            language,
            version ?? '',
            year.toString(),
          ) ??
          DateTime.now().toIso8601String().split('T').first;

      await _cacheService.writeMetadata(filePath, manifestDate);
    } catch (e) {
      debugPrint('❌ Error saving to local storage: $e');
    }
  }

  Future<Map<String, dynamic>?> _loadFromLocalStorage(
    int year,
    String language, [
    String? version,
  ]) async {
    try {
      final String filePath = await _getLocalFilePath(year, language, version);
      final File file = File(filePath);
      if (!await file.exists()) return null;
      final String content = await file.readAsString();
      return json.decode(content) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error loading from local storage: $e');
      return null;
    }
  }

  /// Process devotional data from JSON
  Future<void> _processDevocionalData(Map<String, dynamic> data) async {
    try {
      List<Devocional> loadedDevocionales = [];

      // Parse new JSON structure: data -> language -> date -> devotionals[]
      if (data['data'] != null) {
        final dataMap = data['data'] as Map<String, dynamic>;

        // Get devotionals for the selected language
        if (dataMap[state.selectedLanguage] != null) {
          final languageData =
              dataMap[state.selectedLanguage] as Map<String, dynamic>;

          // Iterate through each date
          for (var dateEntry in languageData.entries) {
            final dateDevocionales = dateEntry.value as List<dynamic>;

            // Parse each devotional for this date
            for (var item in dateDevocionales) {
              try {
                final devocional = Devocional.fromJson(
                  item as Map<String, dynamic>,
                );
                loadedDevocionales.add(devocional);
              } catch (e) {
                debugPrint('Error parsing devotional: $e');
              }
            }
          }
        } else {
          debugPrint(
            '⚠️ No devotionals found for language: ${state.selectedLanguage}',
          );
        }
      }

      // Sort by date: Today's devotionals first, then by date (newest first)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      loadedDevocionales.sort((a, b) {
        final aDate = DateTime(a.date.year, a.date.month, a.date.day);
        final bDate = DateTime(b.date.year, b.date.month, b.date.day);

        // Today's devotionals come first
        if (aDate == today && bDate != today) return -1;
        if (bDate == today && aDate != today) return 1;

        // Otherwise sort by date (newest first)
        return b.date.compareTo(a.date);
      });

      state = state.copyWith(
        all: loadedDevocionales,
        filtered: loadedDevocionales,
        isLoading: false,
      );

      debugPrint(
        '✅ Loaded ${loadedDevocionales.length} devotionals for ${state.selectedLanguage}',
      );
    } catch (e) {
      debugPrint('Error processing devotional data: $e');
      state = state.copyWith(
        errorMessage: 'Error al procesar los devocionales: $e',
        isLoading: false,
      );
    }
  }

  /// Toggle favorite status for a devotional
  Future<void> toggleFavorite(Devocional devocional) async {
    try {
      final favorites = List<Devocional>.from(state.favorites);
      final isFavorite = favorites.any((d) => d.id == devocional.id);

      if (isFavorite) {
        favorites.removeWhere((d) => d.id == devocional.id);
      } else {
        favorites.add(devocional);
      }

      state = state.copyWith(favorites: favorites);

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = json.encode(
        favorites.map((d) => d.toJson()).toList(),
      );
      await prefs.setString(DevotionalConstants.prefFavorites, favoritesJson);

      debugPrint('✅ Favorite toggled for: ${devocional.id}');
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  /// Check if a devotional is a favorite
  bool isFavorite(String devocionalId) {
    return state.favorites.any((d) => d.id == devocionalId);
  }

  /// Change language
  Future<void> changeLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        DevotionalConstants.prefSelectedLanguage,
        languageCode,
      );

      // Get default version for the new language
      final defaultVersion =
          DevotionalConstants.defaultVersionByLanguage[languageCode] ??
              'RVR1960';

      // Persist selected version for the new language
      await prefs.setString(
        DevotionalConstants.prefSelectedVersion,
        defaultVersion,
      );

      state = state.copyWith(
        selectedLanguage: languageCode,
        selectedVersion: defaultVersion,
      );

      await _fetchDevocionalesForLanguage();
    } catch (e) {
      debugPrint('Error changing language: $e');
    }
  }

  /// Change version
  Future<void> changeVersion(String versionCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        DevotionalConstants.prefSelectedVersion,
        versionCode,
      );

      state = state.copyWith(selectedVersion: versionCode);

      await _fetchDevocionalesForLanguage();
    } catch (e) {
      debugPrint('Error changing version: $e');
    }
  }

  /// Filter devotionals by search term
  void filterBySearch(String searchTerm) {
    if (searchTerm.isEmpty) {
      state = state.copyWith(filtered: state.all);
      return;
    }

    final filtered = state.all.where((d) {
      final term = searchTerm.toLowerCase();

      // Search in reflection, verse, and prayer
      final inReflection = d.reflexion.toLowerCase().contains(term);
      final inVerse = d.versiculo.toLowerCase().contains(term);
      final inPrayer = d.oracion.toLowerCase().contains(term);

      // Search in tags (in the corresponding language)
      final inTags =
          d.tags?.any((tag) => tag.toLowerCase().contains(term)) ?? false;

      return inReflection || inVerse || inPrayer || inTags;
    }).toList();

    state = state.copyWith(filtered: filtered);
  }

  /// Get devotional by ID
  Devocional? getDevocionalById(String id) {
    try {
      return state.all.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Expose available Bible versions for the currently selected language
  List<String> getAvailableVersionsForCurrentLanguage() {
    return DevotionalConstants
            .bibleVersionsByLanguage[state.selectedLanguage] ??
        [];
  }
}

/// Provider for devotional state
final devotionalProvider =
    StateNotifierProvider<DevotionalNotifier, DevotionalState>((ref) {
  return DevotionalNotifier();
});
