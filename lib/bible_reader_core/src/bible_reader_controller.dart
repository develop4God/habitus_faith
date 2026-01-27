/// BibleReaderController - Riverpod StateNotifier for Bible Reader functionality
///
/// This controller manages all business logic for the Bible Reader feature.
/// It's designed to be:
/// - Native Riverpod StateNotifier integration
/// - Testable (all services injected)
/// - Type-safe state management
/// - Fully decoupled from UI layer
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bible_db_service.dart';
import 'bible_preferences_service.dart';
import 'bible_reader_service.dart';
import 'bible_reader_state.dart';
import 'bible_version.dart';
import '../../providers/bible_providers.dart';

class BibleReaderController extends StateNotifier<BibleReaderState> {
  final Ref ref;
  final List<BibleVersion> allVersions;
  final BibleReaderService readerService;
  final BiblePreferencesService preferencesService;

  BibleReaderController({
    required this.ref,
    required this.allVersions,
    required this.readerService,
    required this.preferencesService,
    BibleReaderState? initialState,
  }) : super(initialState ?? const BibleReaderState());

  /// Initialize the controller with device language and restore last position
  Future<void> initialize(String deviceLanguage) async {
    state = state.copyWith(isLoading: true, deviceLanguage: deviceLanguage);

    // Filter versions by device language
    List<BibleVersion> availableVersions = allVersions
        .where((v) => v.languageCode == deviceLanguage)
        .toList();

    // Fallback to Spanish or all versions if no match
    if (availableVersions.isEmpty) {
      availableVersions = allVersions
          .where((v) => v.languageCode == 'es')
          .toList();
      if (availableVersions.isEmpty) {
        availableVersions = allVersions;
      }
    }

    // Select initial version - prefer saved current version if available
    final currentVersion = ref.read(currentBibleVersionProvider);
    final selectedVersion =
        currentVersion != null && availableVersions.contains(currentVersion)
        ? currentVersion
        : (availableVersions.isNotEmpty
              ? availableVersions.first
              : allVersions.first);

    // Initialize version's database service
    await _initializeVersionService(selectedVersion);

    // Update current version provider if needed
    if (currentVersion != selectedVersion) {
      await ref
          .read(currentBibleVersionProvider.notifier)
          .setVersion(selectedVersion);
    }

    // Load preferences
    final fontSize = await preferencesService.getFontSize();
    final markedVerses = await preferencesService.getMarkedVerses();

    state = state.copyWith(
      availableVersions: availableVersions,
      selectedVersion: selectedVersion,
      fontSize: fontSize,
      persistentlyMarkedVerses: markedVerses,
    );

    // Try to restore last position
    final lastPosition = await readerService.getLastPosition();

    if (lastPosition != null &&
        _canRestorePosition(lastPosition, availableVersions)) {
      await _restoreLastPosition(lastPosition, availableVersions);
    } else {
      await _loadFirstBook();
    }

    state = state.copyWith(isLoading: false);
  }

  bool _canRestorePosition(
    Map<String, dynamic> lastPosition,
    List<BibleVersion> availableVersions,
  ) {
    return availableVersions.any(
      (v) =>
          v.name == lastPosition['version'] &&
          v.languageCode == lastPosition['languageCode'],
    );
  }

  Future<void> _restoreLastPosition(
    Map<String, dynamic> lastPosition,
    List<BibleVersion> availableVersions,
  ) async {
    // Find and switch to saved version
    final savedVersion = availableVersions.firstWhere(
      (v) =>
          v.name == lastPosition['version'] &&
          v.languageCode == lastPosition['languageCode'],
    );

    await _initializeVersionService(savedVersion);

    // Load books
    final dbService = await _getDbServiceForVersion(savedVersion);
    final books = await dbService.getAllBooks();

    // Restore position
    final position = await readerService.restorePosition(
      savedPosition: lastPosition,
      books: books,
    );

    if (position != null) {
      state = state.copyWith(
        selectedVersion: savedVersion,
        books: books,
        selectedBookName: position['bookName'],
        selectedBookNumber: position['bookNumber'],
        selectedChapter: position['chapter'],
        selectedVerse: position['verse'],
      );

      // Load chapter data
      await _loadChapterData();
    } else {
      // Position restoration failed, load first book
      await _loadFirstBook();
    }
  }

  Future<void> _loadFirstBook() async {
    final dbService = await _getDbService();
    final books = await dbService.getAllBooks();

    if (books.isNotEmpty) {
      state = state.copyWith(
        books: books,
        selectedBookName: books[0]['short_name'],
        selectedBookNumber: books[0]['book_number'],
        selectedChapter: 1,
        selectedVerse: 1,
      );

      await _loadChapterData();
    }
  }

  Future<void> _initializeVersionService(BibleVersion version) async {
    // Initialize the database service for this version through the provider
    // This ensures the service is cached and ready for use
    await ref.read(bibleDbServiceProvider(version.id).future);

    // Also initialize readerService.dbService with the same DB for business logic
    await readerService.dbService.initDb(version.assetPath, version.dbFileName);
  }

  /// Get the database service for the currently selected version
  Future<BibleDbService> _getDbService() async {
    if (state.selectedVersion == null) {
      throw Exception('No version selected');
    }
    return await ref.read(
      bibleDbServiceProvider(state.selectedVersion!.id).future,
    );
  }

  /// Get the database service for a specific version
  Future<BibleDbService> _getDbServiceForVersion(BibleVersion version) async {
    return await ref.read(bibleDbServiceProvider(version.id).future);
  }

  Future<void> _loadChapterData() async {
    if (state.selectedBookNumber == null || state.selectedChapter == null) {
      return;
    }

    final dbService = await _getDbService();
    final maxChapter = await dbService.getMaxChapter(state.selectedBookNumber!);

    final verses = await dbService.getChapterVerses(
      state.selectedBookNumber!,
      state.selectedChapter!,
    );

    final maxVerse = verses.isNotEmpty
        ? (verses.last['verse'] as int? ?? 1)
        : 1;
    final selectedVerse = state.selectedVerse;
    final validatedVerse = (selectedVerse == null || selectedVerse > maxVerse)
        ? 1
        : selectedVerse;

    state = state.copyWith(
      maxChapter: maxChapter,
      verses: verses,
      maxVerse: maxVerse,
      selectedVerse: validatedVerse,
    );

    // Save reading position
    if (state.selectedBookName != null) {
      await readerService.saveReadingPosition(
        bookName: state.selectedBookName!,
        bookNumber: state.selectedBookNumber!,
        chapter: state.selectedChapter!,
        version: state.selectedVersion!.name,
        languageCode: state.selectedVersion!.languageCode,
      );
    }
  }

  /// Switch to a different Bible version
  Future<void> switchVersion(BibleVersion newVersion) async {
    if (newVersion.name == state.selectedVersion?.name) return;

    state = state.copyWith(isLoading: true);

    await _initializeVersionService(newVersion);

    final dbService = await _getDbServiceForVersion(newVersion);
    final books = await dbService.getAllBooks();

    // Update the current version provider
    await ref.read(currentBibleVersionProvider.notifier).setVersion(newVersion);

    state = state.copyWith(
      selectedVersion: newVersion,
      books: books,
      selectedBookName: books.isNotEmpty ? books[0]['short_name'] : null,
      selectedBookNumber: books.isNotEmpty ? books[0]['book_number'] : null,
      selectedChapter: 1,
      selectedVerse: 1,
      selectedVerses: {},
    );

    await _loadChapterData();

    state = state.copyWith(isLoading: false);
  }

  /// Select a book and optionally a chapter
  Future<void> selectBook(Map<String, dynamic> book, {int? chapter}) async {
    state = state.copyWith(
      selectedBookName: book['short_name'],
      selectedBookNumber: book['book_number'],
      selectedChapter: chapter ?? 1,
      selectedVerse: 1,
      selectedVerses: {},
    );

    await _loadChapterData();
  }

  /// Select a specific chapter
  Future<void> selectChapter(int chapter) async {
    state = state.copyWith(
      selectedChapter: chapter,
      selectedVerse: 1,
      selectedVerses: {},
      verses: [], // Ensure verses list is reset before loading new
    );

    await _loadChapterData();
  }

  /// Select a specific verse (for navigation/highlighting)
  void selectVerse(int verse) {
    state = state.copyWith(selectedVerse: verse);
  }

  /// Navigate to the next chapter
  Future<void> goToNextChapter() async {
    if (state.selectedBookNumber == null || state.selectedChapter == null) {
      return;
    }

    final result = await readerService.navigateToNextChapter(
      currentBookNumber: state.selectedBookNumber!,
      currentChapter: state.selectedChapter!,
      books: state.books,
    );

    if (result == null) return; // At end of Bible

    state = state.copyWith(
      selectedBookNumber: result['bookNumber'],
      selectedBookName: result['bookName'] ?? state.selectedBookName,
      selectedChapter: result['chapter'],
      selectedVerse: 1,
      selectedVerses: {},
    );

    if (result['bookName'] != null) {
      // Book changed, need to reload max chapter
      final dbService = await _getDbService();
      final maxChapter = await dbService.getMaxChapter(result['bookNumber']);
      state = state.copyWith(maxChapter: maxChapter);
    }

    await _loadChapterData();
  }

  /// Navigate to the previous chapter
  Future<void> goToPreviousChapter() async {
    if (state.selectedBookNumber == null || state.selectedChapter == null) {
      return;
    }

    final result = await readerService.navigateToPreviousChapter(
      currentBookNumber: state.selectedBookNumber!,
      currentChapter: state.selectedChapter!,
      books: state.books,
    );

    if (result == null) return; // At start of Bible

    state = state.copyWith(
      selectedBookNumber: result['bookNumber'],
      selectedBookName: result['bookName'] ?? state.selectedBookName,
      selectedChapter: result['chapter'],
      selectedVerse: 1,
      selectedVerses: {},
    );

    if (result['bookName'] != null) {
      // Book changed, need to reload max chapter
      final dbService = await _getDbService();
      final maxChapter = await dbService.getMaxChapter(result['bookNumber']);
      state = state.copyWith(maxChapter: maxChapter);
    }

    await _loadChapterData();
  }

  /// Perform search with automatic Bible reference detection
  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(
        isSearching: false,
        searchResults: [],
        searchQuery: '',
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    final result = await readerService.searchWithReferenceDetection(query);

    if (result['isReference'] == true) {
      // Direct navigation to Bible reference
      final target = result['navigationTarget'] as Map<String, dynamic>;

      state = state.copyWith(
        selectedBookName: target['bookName'],
        selectedBookNumber: target['bookNumber'],
        selectedChapter: target['chapter'],
        selectedVerse: target['verse'] ?? 1,
        isSearching: false,
        searchResults: [],
        searchQuery: '',
        isLoading: false,
      );

      await _loadChapterData();
    } else {
      // Text search results
      state = state.copyWith(
        searchResults: result['searchResults'] as List<Map<String, dynamic>>,
        searchQuery: query,
        isSearching: true,
        isLoading: false,
      );
    }
  }

  /// Jump to a search result
  Future<void> jumpToSearchResult(Map<String, dynamic> result) async {
    final bookNumber = result['book_number'] as int;
    final chapter = result['chapter'] as int;
    final verse = result['verse'] as int;

    // Find the book
    final book = state.books.firstWhere(
      (b) => b['book_number'] == bookNumber,
      orElse: () => state.books[0],
    );

    state = state.copyWith(
      selectedBookName: book['short_name'],
      selectedBookNumber: bookNumber,
      selectedChapter: chapter,
      selectedVerse: verse,
      isSearching: false,
      searchResults: [],
      searchQuery: '',
    );

    await _loadChapterData();
  }

  /// Clear search results and exit search mode
  void clearSearch() {
    state = state.copyWith(
      isSearching: false,
      searchResults: [],
      searchQuery: '',
    );
  }

  /// Toggle verse selection for copy/share
  void toggleVerseSelection(String verseKey) {
    final selectedVerses = Set<String>.from(state.selectedVerses);
    if (selectedVerses.contains(verseKey)) {
      selectedVerses.remove(verseKey);
    } else {
      selectedVerses.add(verseKey);
    }
    state = state.copyWith(selectedVerses: selectedVerses);
  }

  /// Clear all selected verses
  void clearSelectedVerses() {
    state = state.copyWith(selectedVerses: {});
  }

  /// Toggle persistent marking of a verse
  Future<void> togglePersistentMark(String verseKey) async {
    final markedVerses = await preferencesService.toggleMarkedVerse(
      verseKey,
      state.persistentlyMarkedVerses,
    );
    state = state.copyWith(persistentlyMarkedVerses: markedVerses);
  }

  /// Increase font size
  Future<void> increaseFontSize() async {
    if (state.fontSize < 30) {
      final newSize = state.fontSize + 2;
      await preferencesService.saveFontSize(newSize);
      state = state.copyWith(fontSize: newSize);
    }
  }

  /// Decrease font size
  Future<void> decreaseFontSize() async {
    if (state.fontSize > 12) {
      final newSize = state.fontSize - 2;
      await preferencesService.saveFontSize(newSize);
      state = state.copyWith(fontSize: newSize);
    }
  }

  /// Set font size directly
  Future<void> setFontSize(double size) async {
    if (size >= 12 && size <= 32) {
      await preferencesService.saveFontSize(size);
      state = state.copyWith(fontSize: size);
    }
  }

  /// Toggle font controls visibility
  void toggleFontControls() {
    state = state.copyWith(showFontControls: !state.showFontControls);
  }

  /// Set font controls visibility
  void setFontControlsVisibility(bool visible) {
    state = state.copyWith(showFontControls: visible);
  }

  // UI convenience methods

  /// Change Bible version (wrapper for switchVersion)
  Future<void> changeVersion(BibleVersion version) async {
    await switchVersion(version);
  }

  /// Clear selected verses (wrapper for clearSelectedVerses)
  void clearSelection() {
    clearSelectedVerses();
  }

  /// Save all selected verses as bookmarks
  Future<void> saveSelectedVerses() async {
    for (final verseKey in state.selectedVerses) {
      await togglePersistentMark(verseKey);
    }
  }

  /// Delete a marked verse (wrapper for togglePersistentMark)
  Future<void> deleteMarkedVerse(String verseKey) async {
    await togglePersistentMark(verseKey);
  }

  /// Search for text (wrapper for performSearch)
  Future<void> searchText(String query) async {
    await performSearch(query);
  }
}
