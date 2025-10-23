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
    allVersions: versions,
    readerService: readerService,
    preferencesService: preferencesService,
  );
});
