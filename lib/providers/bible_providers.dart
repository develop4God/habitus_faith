import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bible_reader_core/bible_reader_core.dart';

/// Provider for SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Provider for Bible versions list
final bibleVersionsProvider = Provider<List<BibleVersion>>((ref) {
  return [
    BibleVersion(
      name: 'RVR1960',
      language: 'Spanish',
      languageCode: 'es',
      assetPath: 'assets/biblia/RVR1960.SQLite3',
      dbFileName: 'RVR1960.SQLite3',
    ),
    BibleVersion(
      name: 'NTV',
      language: 'Spanish',
      languageCode: 'es',
      assetPath: 'assets/biblia/NTV.SQLite3',
      dbFileName: 'NTV.SQLite3',
    ),
    BibleVersion(
      name: 'Peshitta',
      language: 'Spanish',
      languageCode: 'es',
      assetPath: 'assets/biblia/Pesh-es.SQLite3',
      dbFileName: 'Pesh-es.SQLite3',
    ),
    BibleVersion(
      name: 'TLA',
      language: 'Spanish',
      languageCode: 'es',
      assetPath: 'assets/biblia/TLA.SQLite3',
      dbFileName: 'TLA.SQLite3',
    ),
    BibleVersion(
      name: 'RV1865',
      language: 'Spanish',
      languageCode: 'es',
      assetPath: 'assets/biblia/RV1865.SQLite3',
      dbFileName: 'RV1865.SQLite3',
    ),
  ];
});

/// Family provider for BibleDbService instances
/// Each version gets its own initialized database service
final bibleDbServiceProvider = FutureProvider.family<BibleDbService, String>((ref, versionId) async {
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
final currentBibleVersionProvider = StateNotifierProvider<CurrentBibleVersionNotifier, BibleVersion?>((ref) {
  return CurrentBibleVersionNotifier(ref);
});

/// Provider for Bible preferences service
final biblePreferencesServiceProvider = Provider<BiblePreferencesService>((ref) {
  return BiblePreferencesService();
});

/// Provider for Bible reading position service
final bibleReadingPositionServiceProvider = Provider<BibleReadingPositionService>((ref) {
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
final bibleReaderProvider = StateNotifierProvider<BibleReaderController, BibleReaderState>((ref) {
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
