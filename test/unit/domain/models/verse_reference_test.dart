import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/models/verse_reference.dart';

void main() {
  group('VerseReference', () {
    test('creates a valid verse reference', () {
      const verse = VerseReference(book: 'John', chapter: 3, verse: 16);

      expect(verse.book, 'John');
      expect(verse.chapter, 3);
      expect(verse.verse, 16);
      expect(verse.endVerse, isNull);
    });

    test('displayText shows single verse correctly', () {
      const verse = VerseReference(book: 'John', chapter: 3, verse: 16);

      expect(verse.displayText, 'John 3:16');
    });

    test('displayText shows verse range correctly', () {
      const verse = VerseReference(
        book: 'Romans',
        chapter: 12,
        verse: 1,
        endVerse: '2',
      );

      expect(verse.displayText, 'Romans 12:1-2');
    });

    test('serializes to JSON correctly', () {
      const verse = VerseReference(book: 'Psalm', chapter: 23, verse: 1);

      final json = verse.toJson();

      expect(json['book'], 'Psalm');
      expect(json['chapter'], 23);
      expect(json['verse'], 1);
    });

    test('deserializes from JSON correctly', () {
      final json = {'book': 'Psalm', 'chapter': 23, 'verse': 1};

      final verse = VerseReference.fromJson(json);

      expect(verse.book, 'Psalm');
      expect(verse.chapter, 23);
      expect(verse.verse, 1);
    });

    test('round-trip serialization preserves data', () {
      const original = VerseReference(
        book: 'Ephesians',
        chapter: 6,
        verse: 2,
        endVerse: '3',
      );

      final json = original.toJson();
      final restored = VerseReference.fromJson(json);

      expect(restored.book, original.book);
      expect(restored.chapter, original.chapter);
      expect(restored.verse, original.verse);
      expect(restored.endVerse, original.endVerse);
    });
  });
}
