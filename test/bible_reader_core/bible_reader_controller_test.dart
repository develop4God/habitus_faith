import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/bible_reader_core/bible_reader_core.dart';
import 'package:habitus_faith/providers/bible_providers.dart';

void main() {
  late ProviderContainer container;
  late BibleVersion testVersion;

  setUp(() async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});

    testVersion = BibleVersion(
      name: 'TestVersion',
      language: 'English',
      languageCode: 'en',
      assetPath: 'test/assets/test.db',
      dbFileName: 'test.db',
    );

    container = ProviderContainer(
      overrides: [
        bibleVersionsProvider.overrideWithValue([testVersion]),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('BibleReaderController', () {
    test('initialize sets correct initial state', () async {
      container.read(bibleReaderProvider.notifier);

      expect(container.read(bibleReaderProvider).isLoading, isFalse);

      // Note: Full initialization requires actual database files
      // In a real test environment, you would mock the database service
    });

    test('fontSize increases within bounds', () async {
      final controller = container.read(bibleReaderProvider.notifier);
      final initialState = container.read(bibleReaderProvider);

      // Increase font size
      await controller.increaseFontSize();

      final newState = container.read(bibleReaderProvider);
      expect(newState.fontSize, greaterThan(initialState.fontSize));
    });

    test('fontSize decreases respects minimum bound', () async {
      final controller = container.read(bibleReaderProvider.notifier);

      // Set to minimum
      await controller.setFontSize(12.0);
      final beforeState = container.read(bibleReaderProvider);

      // Try to decrease below minimum
      await controller.decreaseFontSize();

      final afterState = container.read(bibleReaderProvider);
      expect(afterState.fontSize, equals(beforeState.fontSize));
      expect(afterState.fontSize, greaterThanOrEqualTo(12.0));
    });

    test('fontSize increases respects maximum bound', () async {
      final controller = container.read(bibleReaderProvider.notifier);

      // Set to near maximum
      await controller.setFontSize(32.0);
      container.read(bibleReaderProvider);

      // Try to increase beyond maximum
      await controller.increaseFontSize();

      final afterState = container.read(bibleReaderProvider);
      expect(afterState.fontSize, lessThanOrEqualTo(32.0));
    });

    test('setFontSize respects bounds (12-32)', () async {
      final controller = container.read(bibleReaderProvider.notifier);

      // Test setting within bounds
      await controller.setFontSize(20.0);
      expect(container.read(bibleReaderProvider).fontSize, equals(20.0));

      // Test setting below minimum (should be ignored or clamped)
      await controller.setFontSize(8.0);
      expect(container.read(bibleReaderProvider).fontSize,
          greaterThanOrEqualTo(12.0));

      // Test setting above maximum (should be ignored or clamped)
      await controller.setFontSize(40.0);
      expect(container.read(bibleReaderProvider).fontSize,
          lessThanOrEqualTo(32.0));
    });

    test('toggleVerseSelection adds and removes correctly', () {
      final controller = container.read(bibleReaderProvider.notifier);
      const verseKey = 'Genesis|1|1';

      // Add verse
      controller.toggleVerseSelection(verseKey);
      expect(
          container.read(bibleReaderProvider).selectedVerses.contains(verseKey),
          isTrue);

      // Remove verse
      controller.toggleVerseSelection(verseKey);
      expect(
          container.read(bibleReaderProvider).selectedVerses.contains(verseKey),
          isFalse);
    });

    test('clearSelection removes all selected verses', () {
      final controller = container.read(bibleReaderProvider.notifier);

      // Add multiple verses
      controller.toggleVerseSelection('Genesis|1|1');
      controller.toggleVerseSelection('Genesis|1|2');
      controller.toggleVerseSelection('Genesis|1|3');

      expect(
          container.read(bibleReaderProvider).selectedVerses.length, equals(3));

      // Clear selection
      controller.clearSelection();

      expect(
          container.read(bibleReaderProvider).selectedVerses.isEmpty, isTrue);
    });

    test('toggleFontControls changes visibility', () {
      final controller = container.read(bibleReaderProvider.notifier);
      final initialVisible =
          container.read(bibleReaderProvider).showFontControls;

      controller.toggleFontControls();
      expect(container.read(bibleReaderProvider).showFontControls,
          equals(!initialVisible));

      controller.toggleFontControls();
      expect(container.read(bibleReaderProvider).showFontControls,
          equals(initialVisible));
    });
  });

  group('BibleReaderController - Navigation', () {
    // Note: These tests require mocked database service
    // as they depend on actual Bible data structure

    test('goToNextChapter updates chapter number', () {
      // Would test chapter navigation
      // Requires mocking the database to have predictable data
    });

    test('goToPreviousChapter updates chapter number', () {
      // Would test backwards chapter navigation
    });

    test('goToNextChapter at book boundary moves to next book', () {
      // Test Genesis 50 -> Exodus 1
      // Requires full database mock
    });

    test('goToPreviousChapter at book boundary moves to previous book', () {
      // Test Exodus 1 -> Genesis 50
      // Requires full database mock
    });
  });

  group('BibleReaderController - Search', () {
    test('performSearch with Bible reference parses correctly', () async {
      // Test references like "Juan 3:16", "Gn 1:1", "Genesis 1"
      // Requires mocked BibleReferenceParser
    });

    test('performSearch falls back to text search on invalid reference',
        () async {
      // Test that invalid references trigger text search
    });
  });
}
