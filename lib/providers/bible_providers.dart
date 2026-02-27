import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bible_reader_core/bible_reader_core.dart';

/// Provider for SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

/// Provider for Bible versions list
/// All assets are gzip-compressed SQLite databases (*.SQLite3.gz).
/// BibleDbService handles decompression transparently on first load.
final bibleVersionsProvider = Provider<List<BibleVersion>>((ref) {
  return [
    // Spanish
    BibleVersion(
      name: 'RVR1960',
      language: 'Español',
      languageCode: 'es',
      assetPath: 'assets/biblia/RVR1960_es.SQLite3.gz',
      dbFileName: 'RVR1960_es.SQLite3.gz',
    ),
    BibleVersion(
      name: 'NVI',
      language: 'Español',
      languageCode: 'es',
      assetPath: 'assets/biblia/NVI_es.SQLite3.gz',
      dbFileName: 'NVI_es.SQLite3.gz',
    ),
    // English
    BibleVersion(
      name: 'KJV',
      language: 'English',
      languageCode: 'en',
      assetPath: 'assets/biblia/KJV_en.SQLite3.gz',
      dbFileName: 'KJV_en.SQLite3.gz',
    ),
    BibleVersion(
      name: 'NIV',
      language: 'English',
      languageCode: 'en',
      assetPath: 'assets/biblia/NIV_en.SQLite3.gz',
      dbFileName: 'NIV_en.SQLite3.gz',
    ),
    // Portuguese
    BibleVersion(
      name: 'ARC',
      language: 'Português',
      languageCode: 'pt',
      assetPath: 'assets/biblia/ARC_pt.SQLite3.gz',
      dbFileName: 'ARC_pt.SQLite3.gz',
    ),
    BibleVersion(
      name: 'NVI',
      language: 'Português',
      languageCode: 'pt',
      assetPath: 'assets/biblia/NVI_pt.SQLite3.gz',
      dbFileName: 'NVI_pt.SQLite3.gz',
    ),
    // French
    BibleVersion(
      name: 'LSG1910',
      language: 'Français',
      languageCode: 'fr',
      assetPath: 'assets/biblia/LSG1910_fr.SQLite3.gz',
      dbFileName: 'LSG1910_fr.SQLite3.gz',
    ),
    BibleVersion(
      name: 'BDS',
      language: 'Français',
      languageCode: 'fr',
      assetPath: 'assets/biblia/BDS_fr.SQLite3.gz',
      dbFileName: 'BDS_fr.SQLite3.gz',
    ),
    // Chinese
    BibleVersion(
      name: 'CUV1919',
      language: '中文',
      languageCode: 'zh',
      assetPath: 'assets/biblia/CUV1919_zh.SQLite3.gz',
      dbFileName: 'CUV1919_zh.SQLite3.gz',
    ),
    BibleVersion(
      name: 'CNVS',
      language: '中文',
      languageCode: 'zh',
      assetPath: 'assets/biblia/CNVS_zh.SQLite3.gz',
      dbFileName: 'CNVS_zh.SQLite3.gz',
    ),
    // Hindi
    BibleVersion(
      name: 'ERV',
      language: 'हिन्दी',
      languageCode: 'hi',
      assetPath: 'assets/biblia/ERV_hi.SQLite3.gz',
      dbFileName: 'ERV_hi.SQLite3.gz',
    ),
    BibleVersion(
      name: 'HIOV',
      language: 'हिन्दी',
      languageCode: 'hi',
      assetPath: 'assets/biblia/HIOV_hi.SQLite3.gz',
      dbFileName: 'HIOV_hi.SQLite3.gz',
    ),
  ];
});

/// Family provider for BibleDbService instances
/// Each version gets its own initialized database service
final bibleDbServiceProvider = FutureProvider.family<BibleDbService, String>((
  ref,
  versionId,
) async {
  final versions = ref.watch(bibleVersionsProvider);
  final version = versions.firstWhere(
    (v) => v.id == versionId,
    orElse: () => throw Exception('Version $versionId not found'),
  );

  final service = BibleDbService();
  await service.initDb(version.assetPath, version.dbFileName);
  return service;
});

/// StateNotifier for managing current Bible version
class CurrentBibleVersionNotifier extends StateNotifier<BibleVersion?> {
  final Ref ref;

  CurrentBibleVersionNotifier(this.ref) : super(null) {
    _loadInitialVersion();
  }

  Future<void> _loadInitialVersion() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final versionName = prefs.getString('current_bible_version');

    final available = ref.read(bibleVersionsProvider);
    if (versionName != null) {
      try {
        final saved = available.firstWhere((v) => v.name == versionName);
        state = saved;
        return;
      } catch (_) {
        // Saved version not found, fall through to default
      }
    }

    // Default to first available version
    state = available.isNotEmpty ? available.first : null;
  }

  Future<void> setVersion(BibleVersion version) async {
    state = version;
    // Save to preferences
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString('current_bible_version', version.name);
  }
}

/// Provider for current Bible version
final currentBibleVersionProvider =
    StateNotifierProvider<CurrentBibleVersionNotifier, BibleVersion?>((ref) {
  return CurrentBibleVersionNotifier(ref);
});

/// Provider for Bible preferences service
final biblePreferencesServiceProvider = Provider<BiblePreferencesService>((
  ref,
) {
  return BiblePreferencesService();
});

/// Provider for Bible reading position service
final bibleReadingPositionServiceProvider =
    Provider<BibleReadingPositionService>((ref) {
  return BibleReadingPositionService();
});

/// Provider for Bible reader service
final bibleReaderServiceProvider = Provider<BibleReaderService>((ref) {
  final positionService = ref.watch(bibleReadingPositionServiceProvider);
  return BibleReaderService(
    dbService: BibleDbService(), // Each version will have its own instance
    positionService: positionService,
  );
});

/// Provider for Bible reader state
/// Now using the controller directly as it extends StateNotifier
final bibleReaderProvider =
    StateNotifierProvider<BibleReaderController, BibleReaderState>((ref) {
  final versions = ref.watch(bibleVersionsProvider);
  final readerService = ref.watch(bibleReaderServiceProvider);
  final preferencesService = ref.watch(biblePreferencesServiceProvider);

  return BibleReaderController(
    ref: ref,
    allVersions: versions,
    readerService: readerService,
    preferencesService: preferencesService,
  );
});
