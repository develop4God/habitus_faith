// lib/core/config/devotional_constants.dart

import 'package:flutter/material.dart';

/// Global constants for devotionals and related features
class DevotionalConstants {
  /// URL GENERATION FUNCTIONS

  // ORIGINAL METHOD - DO NOT MODIFY (Backward Compatibility)
  static String getDevocionalesApiUrl(int year) {
    return 'https://raw.githubusercontent.com/develop4God/Devocionales-json/refs/heads/main/Devocional_year_$year.json';
  }

  // NEW METHOD for multilingual support
  static String getDevocionalesApiUrlMultilingual(
    int year,
    String languageCode,
    String versionCode,
  ) {
    // Backward compatibility for Spanish RVR1960
    if (languageCode == 'es' && versionCode == 'RVR1960') {
      return getDevocionalesApiUrl(year); // Use original method
    }

    // New format for other languages/versions
    return 'https://raw.githubusercontent.com/develop4God/Devocionales-json/refs/heads/main/Devocional_year_${year}_${languageCode}_$versionCode.json';
  }

  /// MAPS: LANGUAGES, VERSIONS, DEFAULTS

  // Supported languages and their readable names
  static const Map<String, String> supportedLanguages = {
    'es': 'Español',
    'en': 'English',
    'pt': 'Português',
    'fr': 'Français',
    'zh': '中文', // Chinese
    'hi': 'हिन्दी', // Hindi
  };

  // Available Bible versions by language
  // Files are stored as gzip-compressed SQLite databases in assets/biblia/
  static const Map<String, List<String>> bibleVersionsByLanguage = {
    'es': ['RVR1960', 'NVI'],
    'en': ['KJV', 'NIV'],
    'pt': ['ARC', 'NVI'],
    'fr': ['LSG1910', 'BDS'],
    'zh': [
      'CUV1919',
      'CNVS'
    ], // Chinese Union Version 1919, Chinese New Version Simplified
    'hi': ['HERV', 'HIOV'], // Hindi Easy-to-Read Version 95, Hindi Old Version
  };

  // Default Bible version by language
  static const Map<String, String> defaultVersionByLanguage = {
    'es': 'RVR1960',
    'en': 'KJV',
    'pt': 'ARC',
    'fr': 'LSG1910',
    'zh': 'CUV1919',
    'hi': 'HERV',
  };

  /// PREFERENCES (SharedPreferences KEYS)
  static const String prefSeenIndices = 'seenIndices';
  static const String prefFavorites = 'favorites';
  static const String prefDontShowInvitation = 'dontShowInvitation';
  static const String prefCurrentIndex = 'currentIndex';
  static const String prefLastNotificationDate = 'lastNotificationDate';
  static const String prefShowInvitationDialog = 'showInvitationDialog';
  static const String prefSelectedLanguage = 'selectedLanguage';
  static const String prefSelectedVersion = 'selectedVersion';
  static const String prefDevocionalFontSize = 'devocional_font_size';

  /// Favorites local storage schema version. Bump this when changing the
  /// local format for favorites so migrations can be applied.
  static const int favoritesSchemaVersion = 1;

  /// Timeout for fetching the devocional index — keep short to avoid blocking load
  static const Duration indexFetchTimeout = Duration(seconds: 3);

  /// FEATURE FLAGS
  static const bool enableOnboardingFeature = false;
  static const bool enableBackupFeature = false;
  static const bool enableDiscoveryFeature = true;

  /// DISCOVERY STUDIES URLS
  static const String discoveryIndexUrl =
      'https://raw.githubusercontent.com/develop4God/Devocionales-json/refs/heads/main/discovery/index.json';

  static String getDiscoveryStudyFileUrl(String fileName) {
    return 'https://raw.githubusercontent.com/develop4God/Devocionales-json/refs/heads/main/discovery/$fileName';
  }

  // ---------------------------------------------------------------------------
  // Devocional Index (cache invalidation / sidecar versioning)
  // ---------------------------------------------------------------------------

  /// URL of the sidecar index.json used to detect stale cached devotional files.
  ///
  /// The index maps each `language/version/year` combination to the date the
  /// remote JSON was last modified.  When the cached sidecar date no longer
  /// matches the index date, the app re-fetches the JSON for that combination.
  static String getDevocionalIndexUrl() {
    return 'https://raw.githubusercontent.com/develop4God/Devocionales-json/refs/heads/main/index.json';
  }
}

/// Schema versioning and migration constants for favorites storage
class FavoritesSchema {
  static const int currentVersion = 2;
  static const String versionKey = 'favorites_schema_version';
  static const String migratedAtKey = 'favorites_migrated_at';
}

// Servicio de navegación global
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
