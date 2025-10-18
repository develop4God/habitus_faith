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

/// StateNotifier for Bible reader state management
class BibleReaderNotifier extends StateNotifier<BibleReaderState> {
  final BibleReaderController _controller;

  BibleReaderNotifier(this._controller) : super(const BibleReaderState()) {
    _controller.stateStream.listen((newState) {
      state = newState;
    });
  }

  Future<void> initialize(String deviceLanguage) async {
    await _controller.initialize(deviceLanguage);
  }

  Future<void> changeVersion(BibleVersion version) async {
    await _controller.switchVersion(version);
  }

  Future<void> selectBook(int bookNumber, String bookName) async {
    // Find the book in the state
    final book = state.books.firstWhere(
      (b) => b['book_number'] == bookNumber,
      orElse: () => {'book_number': bookNumber, 'short_name': bookName},
    );
    await _controller.selectBook(book);
  }

  Future<void> selectChapter(int chapter) async {
    await _controller.selectChapter(chapter);
  }

  void selectVerse(int verse) {
    _controller.selectVerse(verse);
  }

  void toggleVerseSelection(String verseKey) {
    _controller.toggleVerseSelection(verseKey);
  }

  void clearSelection() {
    _controller.clearSelectedVerses();
  }

  Future<void> saveSelectedVerses() async {
    // Save each selected verse
    for (final verseKey in state.selectedVerses) {
      await _controller.togglePersistentMark(verseKey);
    }
  }

  Future<void> deleteMarkedVerse(String verseKey) async {
    await _controller.togglePersistentMark(verseKey);
  }

  Future<void> searchText(String query) async {
    await _controller.performSearch(query);
  }

  void setFontSize(double size) {
    // Update state directly since controller doesn't have this method
    state = state.copyWith(fontSize: size);
  }

  void toggleFontControls() {
    // This is a UI-only state
    state = state.copyWith(showFontControls: !state.showFontControls);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Provider for Bible reader state
final bibleReaderProvider = StateNotifierProvider<BibleReaderNotifier, BibleReaderState>((ref) {
  final versions = ref.watch(bibleVersionsProvider);
  final readerService = ref.watch(bibleReaderServiceProvider);
  final preferencesService = ref.watch(biblePreferencesServiceProvider);

  final controller = BibleReaderController(
    allVersions: versions,
    readerService: readerService,
    preferencesService: preferencesService,
  );

  return BibleReaderNotifier(controller);
});
