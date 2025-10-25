import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/bible_reader_core/bible_reader_core.dart';

void main() {
  group('BibleReadingPositionService - Edge Cases & Real Logic', () {
    late BibleReadingPositionService service;

    setUp(() {
      service = BibleReadingPositionService();
      SharedPreferences.setMockInitialValues({});
    });

    group('Save position - Normal cases', () {
      test('saves complete reading position', () async {
        await service.savePosition(
          bookName: 'Genesis',
          bookNumber: 1,
          chapter: 1,
          verse: 1,
          version: 'RVR1960',
          languageCode: 'es',
        );

        final position = await service.getLastPosition();
        expect(position, isNotNull);
        expect(position!['bookName'], equals('Genesis'));
        expect(position['bookNumber'], equals(1));
        expect(position['chapter'], equals(1));
        expect(position['verse'], equals(1));
        expect(position['version'], equals('RVR1960'));
        expect(position['languageCode'], equals('es'));
      });

      test('saves position with default verse (1)', () async {
        await service.savePosition(
          bookName: 'John',
          bookNumber: 43,
          chapter: 3,
          version: 'KJV',
          languageCode: 'en',
        );

        final position = await service.getLastPosition();
        expect(position, isNotNull);
        expect(position!['verse'], equals(1)); // Default value
      });

      test('overwrites previous position', () async {
        // Save first position
        await service.savePosition(
          bookName: 'Genesis',
          bookNumber: 1,
          chapter: 1,
          version: 'RVR1960',
          languageCode: 'es',
        );

        // Save second position
        await service.savePosition(
          bookName: 'John',
          bookNumber: 43,
          chapter: 3,
          verse: 16,
          version: 'KJV',
          languageCode: 'en',
        );

        final position = await service.getLastPosition();
        expect(position!['bookName'], equals('John'));
        expect(position['chapter'], equals(3));
        expect(position['verse'], equals(16));
      });
    });

    group('Edge cases - Boundary values', () {
      test('saves position with verse 0', () async {
        await service.savePosition(
          bookName: 'Test',
          bookNumber: 1,
          chapter: 1,
          verse: 0,
          version: 'TEST',
          languageCode: 'en',
        );

        final position = await service.getLastPosition();
        expect(position!['verse'], equals(0));
      });

      test('saves position with very large chapter number (150 - Psalms)',
          () async {
        await service.savePosition(
          bookName: 'Psalms',
          bookNumber: 19,
          chapter: 150,
          verse: 6,
          version: 'KJV',
          languageCode: 'en',
        );

        final position = await service.getLastPosition();
        expect(position!['chapter'], equals(150));
      });

      test('saves position with very large verse number (176 - Psalm 119)',
          () async {
        await service.savePosition(
          bookName: 'Psalms',
          bookNumber: 19,
          chapter: 119,
          verse: 176,
          version: 'KJV',
          languageCode: 'en',
        );

        final position = await service.getLastPosition();
        expect(position!['verse'], equals(176));
      });

      test('saves position with book number 66 (Revelation - last book)',
          () async {
        await service.savePosition(
          bookName: 'Revelation',
          bookNumber: 66,
          chapter: 22,
          verse: 21,
          version: 'KJV',
          languageCode: 'en',
        );

        final position = await service.getLastPosition();
        expect(position!['bookNumber'], equals(66));
        expect(position['chapter'], equals(22));
        expect(position['verse'], equals(21));
      });
    });

    group('Edge cases - Special characters', () {
      test('saves book name with accents', () async {
        await service.savePosition(
          bookName: 'Éxodo',
          bookNumber: 2,
          chapter: 20,
          version: 'RVR1960',
          languageCode: 'es',
        );

        final position = await service.getLastPosition();
        expect(position!['bookName'], equals('Éxodo'));
      });

      test('saves book name with numbers', () async {
        await service.savePosition(
          bookName: '1 Corintios',
          bookNumber: 46,
          chapter: 13,
          version: 'RVR1960',
          languageCode: 'es',
        );

        final position = await service.getLastPosition();
        expect(position!['bookName'], equals('1 Corintios'));
      });

      test('saves version name with special characters', () async {
        await service.savePosition(
          bookName: 'John',
          bookNumber: 43,
          chapter: 1,
          version: 'RVR-1960',
          languageCode: 'es',
        );

        final position = await service.getLastPosition();
        expect(position!['version'], equals('RVR-1960'));
      });

      test('saves language code variations', () async {
        await service.savePosition(
          bookName: 'John',
          bookNumber: 43,
          chapter: 1,
          version: 'KJV',
          languageCode: 'en-US',
        );

        final position = await service.getLastPosition();
        expect(position!['languageCode'], equals('en-US'));
      });
    });

    group('Get position - No saved data', () {
      test('returns null when no position saved', () async {
        final position = await service.getLastPosition();
        expect(position, isNull);
      });

      test('returns null when SharedPreferences is empty', () async {
        SharedPreferences.setMockInitialValues({});
        final position = await service.getLastPosition();
        expect(position, isNull);
      });
    });

    group('Get position - Incomplete data', () {
      test('returns null when bookName is missing', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('bible_last_book_number', 1);
        await prefs.setInt('bible_last_chapter', 1);
        await prefs.setString('bible_last_version', 'KJV');
        await prefs.setString('bible_last_language', 'en');

        final position = await service.getLastPosition();
        expect(position, isNull);
      });

      test('returns null when bookNumber is missing', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('bible_last_book', 'Genesis');
        await prefs.setInt('bible_last_chapter', 1);
        await prefs.setString('bible_last_version', 'KJV');
        await prefs.setString('bible_last_language', 'en');

        final position = await service.getLastPosition();
        expect(position, isNull);
      });

      test('returns null when chapter is missing', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('bible_last_book', 'Genesis');
        await prefs.setInt('bible_last_book_number', 1);
        await prefs.setString('bible_last_version', 'KJV');
        await prefs.setString('bible_last_language', 'en');

        final position = await service.getLastPosition();
        expect(position, isNull);
      });

      test('returns null when version is missing', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('bible_last_book', 'Genesis');
        await prefs.setInt('bible_last_book_number', 1);
        await prefs.setInt('bible_last_chapter', 1);
        await prefs.setString('bible_last_language', 'en');

        final position = await service.getLastPosition();
        expect(position, isNull);
      });

      test('returns null when languageCode is missing', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('bible_last_book', 'Genesis');
        await prefs.setInt('bible_last_book_number', 1);
        await prefs.setInt('bible_last_chapter', 1);
        await prefs.setString('bible_last_version', 'KJV');

        final position = await service.getLastPosition();
        expect(position, isNull);
      });

      test('returns default verse (1) when verse is missing', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('bible_last_book', 'Genesis');
        await prefs.setInt('bible_last_book_number', 1);
        await prefs.setInt('bible_last_chapter', 1);
        await prefs.setString('bible_last_version', 'KJV');
        await prefs.setString('bible_last_language', 'en');

        final position = await service.getLastPosition();
        expect(position, isNotNull);
        expect(position!['verse'], equals(1)); // Default value
      });
    });

    group('Clear position', () {
      test('clears all saved position data', () async {
        // Save position first
        await service.savePosition(
          bookName: 'Genesis',
          bookNumber: 1,
          chapter: 1,
          verse: 1,
          version: 'KJV',
          languageCode: 'en',
        );

        // Verify it's saved
        var position = await service.getLastPosition();
        expect(position, isNotNull);

        // Clear position
        await service.clearPosition();

        // Verify it's cleared
        position = await service.getLastPosition();
        expect(position, isNull);
      });

      test('clearing already empty position does not error', () async {
        // Clear when nothing is saved
        await service.clearPosition();

        final position = await service.getLastPosition();
        expect(position, isNull);
      });

      test('can save again after clearing', () async {
        // Save, clear, save again
        await service.savePosition(
          bookName: 'Genesis',
          bookNumber: 1,
          chapter: 1,
          version: 'KJV',
          languageCode: 'en',
        );

        await service.clearPosition();

        await service.savePosition(
          bookName: 'John',
          bookNumber: 43,
          chapter: 3,
          verse: 16,
          version: 'NIV',
          languageCode: 'en',
        );

        final position = await service.getLastPosition();
        expect(position, isNotNull);
        expect(position!['bookName'], equals('John'));
        expect(position['verse'], equals(16));
      });
    });

    group('Real-world scenarios', () {
      test('tracks reading through entire Bible', () async {
        // Genesis 1:1
        await service.savePosition(
          bookName: 'Genesis',
          bookNumber: 1,
          chapter: 1,
          verse: 1,
          version: 'KJV',
          languageCode: 'en',
        );

        var position = await service.getLastPosition();
        expect(position!['bookName'], equals('Genesis'));

        // Revelation 22:21 (last verse)
        await service.savePosition(
          bookName: 'Revelation',
          bookNumber: 66,
          chapter: 22,
          verse: 21,
          version: 'KJV',
          languageCode: 'en',
        );

        position = await service.getLastPosition();
        expect(position!['bookName'], equals('Revelation'));
        expect(position['bookNumber'], equals(66));
      });

      test('saves position at John 3:16 (most popular)', () async {
        await service.savePosition(
          bookName: 'John',
          bookNumber: 43,
          chapter: 3,
          verse: 16,
          version: 'NIV',
          languageCode: 'en',
        );

        final position = await service.getLastPosition();
        expect(position!['bookName'], equals('John'));
        expect(position['chapter'], equals(3));
        expect(position['verse'], equals(16));
      });

      test('handles version switching', () async {
        // Save in RVR1960
        await service.savePosition(
          bookName: 'Juan',
          bookNumber: 43,
          chapter: 3,
          verse: 16,
          version: 'RVR1960',
          languageCode: 'es',
        );

        // Switch to KJV
        await service.savePosition(
          bookName: 'John',
          bookNumber: 43,
          chapter: 3,
          verse: 16,
          version: 'KJV',
          languageCode: 'en',
        );

        final position = await service.getLastPosition();
        expect(position!['version'], equals('KJV'));
        expect(position['languageCode'], equals('en'));
      });
    });
  });
}
