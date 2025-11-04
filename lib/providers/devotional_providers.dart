// lib/providers/devotional_providers.dart

import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/devocional_model.dart';
import '../core/config/devotional_constants.dart';

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
  DevotionalNotifier() : super(_initialState());

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
      String selectedLanguage = _getSupportedLanguageWithFallback(savedLanguage);

      // Save language if different from saved
      if (selectedLanguage != savedLanguage) {
        await prefs.setString(
            DevotionalConstants.prefSelectedLanguage, selectedLanguage);
      }

      // Get saved version or use default
      String savedVersion =
          prefs.getString(DevotionalConstants.prefSelectedVersion) ?? '';
      String defaultVersion =
          DevotionalConstants.defaultVersionByLanguage[selectedLanguage] ??
              'RVR1960';
      String selectedVersion =
          savedVersion.isNotEmpty ? savedVersion : defaultVersion;

      // Update state with language and version
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
      state = state.copyWith(
        errorMessage: 'Error al inicializar los datos: $e',
        isLoading: false,
      );
    }
  }

  String _getSupportedLanguageWithFallback(String requestedLanguage) {
    const supportedLanguages = ['es', 'en', 'pt', 'fr'];
    if (supportedLanguages.contains(requestedLanguage)) {
      return requestedLanguage;
    }
    return 'es'; // fallback
  }

  /// Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson =
          prefs.getString(DevotionalConstants.prefFavorites);

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

  /// Fetch devotionals from API
  Future<void> _fetchDevocionalesForLanguage() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final int currentYear = DateTime.now().year;
      final String url = DevotionalConstants.getDevocionalesApiUrlMultilingual(
        currentYear,
        state.selectedLanguage,
        state.selectedVersion,
      );

      debugPrint('🔍 Fetching devotionals from: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to load from API: ${response.statusCode}');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      await _processDevocionalData(data);
    } catch (e) {
      debugPrint('Error fetching devotionals: $e');
      state = state.copyWith(
        errorMessage: 'Error al cargar los devocionales: $e',
        isLoading: false,
      );
    }
  }

  /// Process devotional data from JSON
  Future<void> _processDevocionalData(Map<String, dynamic> data) async {
    try {
      List<Devocional> loadedDevocionales = [];

      if (data['devocionales'] != null) {
        for (var item in data['devocionales']) {
          try {
            final devocional = Devocional.fromJson(item);
            loadedDevocionales.add(devocional);
          } catch (e) {
            debugPrint('Error parsing devotional: $e');
          }
        }
      }

      // Sort by date (newest first)
      loadedDevocionales.sort((a, b) => b.date.compareTo(a.date));

      state = state.copyWith(
        all: loadedDevocionales,
        filtered: loadedDevocionales,
        isLoading: false,
      );

      debugPrint('✅ Loaded ${loadedDevocionales.length} devotionals');
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
      final isFavorite =
          favorites.any((d) => d.id == devocional.id);

      if (isFavorite) {
        favorites.removeWhere((d) => d.id == devocional.id);
      } else {
        favorites.add(devocional);
      }

      state = state.copyWith(favorites: favorites);

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson =
          json.encode(favorites.map((d) => d.toJson()).toList());
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
          DevotionalConstants.prefSelectedLanguage, languageCode);

      // Get default version for the new language
      final defaultVersion =
          DevotionalConstants.defaultVersionByLanguage[languageCode] ??
              'RVR1960';

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
          DevotionalConstants.prefSelectedVersion, versionCode);

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
      return d.reflexion.toLowerCase().contains(term) ||
          d.versiculo.toLowerCase().contains(term) ||
          d.oracion.toLowerCase().contains(term);
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
}

/// Provider for devotional state
final devotionalProvider =
    StateNotifierProvider<DevotionalNotifier, DevotionalState>((ref) {
  return DevotionalNotifier();
});
