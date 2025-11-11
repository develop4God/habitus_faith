import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/bible_reader_core/bible_reader_core.dart';

void main() {
  group('BibleReferenceParser - Edge Cases & Real Logic', () {
    group('Basic reference parsing - with verse', () {
      test('parses simple book chapter verse', () {
        final result = BibleReferenceParser.parse('Juan 3:16');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('Juan'));
        expect(result['chapter'], equals(3));
        expect(result['verse'], equals(16));
      });

      test('parses book with number prefix', () {
        final result = BibleReferenceParser.parse('1 Juan 3:16');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('1 Juan'));
        expect(result['chapter'], equals(3));
        expect(result['verse'], equals(16));
      });

      test('parses book with 2 prefix', () {
        final result = BibleReferenceParser.parse('2 Corintios 5:17');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('2 Corintios'));
        expect(result['chapter'], equals(5));
        expect(result['verse'], equals(17));
      });

      test('parses English book name', () {
        final result = BibleReferenceParser.parse('Genesis 1:1');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('Genesis'));
        expect(result['chapter'], equals(1));
        expect(result['verse'], equals(1));
      });
    });

    group('Basic reference parsing - without verse', () {
      test('parses book and chapter only', () {
        final result = BibleReferenceParser.parse('Juan 3');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('Juan'));
        expect(result['chapter'], equals(3));
        expect(result.containsKey('verse'), isFalse);
      });

      test('parses numbered book with chapter only', () {
        final result = BibleReferenceParser.parse('1 Juan 3');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('1 Juan'));
        expect(result['chapter'], equals(3));
        expect(result.containsKey('verse'), isFalse);
      });

      test('parses long book name with chapter', () {
        final result = BibleReferenceParser.parse('Genesis 50');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('Genesis'));
        expect(result['chapter'], equals(50));
      });
    });

    group('Edge cases - Accented characters', () {
      test('parses book with accents (Éxodo)', () {
        final result = BibleReferenceParser.parse('Éxodo 20:1');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('Éxodo'));
        expect(result['chapter'], equals(20));
        expect(result['verse'], equals(1));
      });

      test('parses book with ñ (Corintios)', () {
        final result = BibleReferenceParser.parse('1 Corintios 13:13');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('1 Corintios'));
        expect(result['chapter'], equals(13));
        expect(result['verse'], equals(13));
      });

      test('parses book with multiple accents', () {
        final result = BibleReferenceParser.parse('Canción de Salomón 1:1');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('Canción de Salomón'));
      });
    });

    group('Edge cases - Whitespace handling', () {
      test('handles extra leading whitespace', () {
        final result = BibleReferenceParser.parse('   Juan 3:16');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('Juan'));
        expect(result['chapter'], equals(3));
        expect(result['verse'], equals(16));
      });

      test('handles extra trailing whitespace', () {
        final result = BibleReferenceParser.parse('Juan 3:16   ');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('Juan'));
      });

      test('handles extra spaces between parts', () {
        final result = BibleReferenceParser.parse('1  Juan  3:16');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('1 Juan'));
        expect(result['chapter'], equals(3));
      });

      test('handles tabs and mixed whitespace', () {
        final result = BibleReferenceParser.parse('\tJuan\t3:16\t');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('Juan'));
      });
    });

    group('Edge cases - Case sensitivity', () {
      test('parses lowercase book name', () {
        final result = BibleReferenceParser.parse('juan 3:16');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('juan'));
      });

      test('parses UPPERCASE book name', () {
        final result = BibleReferenceParser.parse('JUAN 3:16');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('JUAN'));
      });

      test('parses MiXeD case book name', () {
        final result = BibleReferenceParser.parse('JuAn 3:16');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('JuAn'));
      });
    });

    group('Edge cases - Large numbers', () {
      test('parses chapter 150 (Psalms)', () {
        final result = BibleReferenceParser.parse('Salmos 150:6');
        expect(result, isNotNull);
        expect(result!['chapter'], equals(150));
        expect(result['verse'], equals(6));
      });

      test('parses verse 176 (Psalm 119)', () {
        final result = BibleReferenceParser.parse('Salmos 119:176');
        expect(result, isNotNull);
        expect(result!['chapter'], equals(119));
        expect(result['verse'], equals(176));
      });

      test('parses three-digit chapter', () {
        final result = BibleReferenceParser.parse('Test 999:1');
        expect(result, isNotNull);
        expect(result!['chapter'], equals(999));
      });
    });

    group('Edge cases - Book names with spaces', () {
      test('parses book with multiple words', () {
        final result = BibleReferenceParser.parse('Song of Songs 1:1');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('Song of Songs'));
      });

      test('parses numbered book with spaces', () {
        final result = BibleReferenceParser.parse('1 Samuel 17:47');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('1 Samuel'));
        expect(result['chapter'], equals(17));
      });

      test('parses book with spaces and accents', () {
        final result = BibleReferenceParser.parse(
          'Cántico de los Cánticos 2:1',
        );
        expect(result, isNotNull);
        expect(result!['bookName'], equals('Cántico de los Cánticos'));
      });
    });

    group('Invalid input - Returns null', () {
      test('returns null for empty string', () {
        final result = BibleReferenceParser.parse('');
        expect(result, isNull);
      });

      test('returns null for whitespace only', () {
        final result = BibleReferenceParser.parse('   ');
        expect(result, isNull);
      });

      test('returns null for book name only', () {
        final result = BibleReferenceParser.parse('Juan');
        expect(result, isNull);
      });

      test('returns null for numbers only', () {
        final result = BibleReferenceParser.parse('3:16');
        expect(result, isNull);
      });

      test('returns null for invalid format', () {
        final result = BibleReferenceParser.parse('Juan 3-16');
        expect(result, isNull);
      });

      test('returns null for missing chapter', () {
        final result = BibleReferenceParser.parse('Juan :16');
        expect(result, isNull);
      });

      test('returns null for special characters', () {
        final result = BibleReferenceParser.parse('Juan @#\$ 3:16');
        expect(result, isNull);
      });
    });

    group('Edge cases - Number boundaries', () {
      test('parses chapter 0 (invalid but parseable)', () {
        final result = BibleReferenceParser.parse('Test 0:1');
        expect(result, isNotNull);
        expect(result!['chapter'], equals(0));
      });

      test('parses verse 0 (invalid but parseable)', () {
        final result = BibleReferenceParser.parse('Test 1:0');
        expect(result, isNotNull);
        expect(result!['verse'], equals(0));
      });

      test('handles very large chapter numbers', () {
        final result = BibleReferenceParser.parse('Test 9999:1');
        expect(result, isNotNull);
        expect(result!['chapter'], equals(9999));
      });

      test('handles very large verse numbers', () {
        final result = BibleReferenceParser.parse('Test 1:9999');
        expect(result, isNotNull);
        expect(result!['verse'], equals(9999));
      });
    });

    group('Real-world Bible references', () {
      test('parses John 3:16 (most popular)', () {
        final result = BibleReferenceParser.parse('John 3:16');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('John'));
        expect(result['chapter'], equals(3));
        expect(result['verse'], equals(16));
      });

      test('parses Psalm 23:1 (popular psalm)', () {
        final result = BibleReferenceParser.parse('Psalm 23:1');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('Psalm'));
        expect(result['chapter'], equals(23));
      });

      test('parses Genesis 1:1 (first verse)', () {
        final result = BibleReferenceParser.parse('Genesis 1:1');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('Genesis'));
        expect(result['chapter'], equals(1));
        expect(result['verse'], equals(1));
      });

      test('parses Revelation 22:21 (last verse)', () {
        final result = BibleReferenceParser.parse('Revelation 22:21');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('Revelation'));
        expect(result['chapter'], equals(22));
        expect(result['verse'], equals(21));
      });

      test('parses 1 Corinthians 13:13', () {
        final result = BibleReferenceParser.parse('1 Corinthians 13:13');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('1 Corinthians'));
        expect(result['chapter'], equals(13));
        expect(result['verse'], equals(13));
      });

      test('parses Romanos 8:28 (Spanish)', () {
        final result = BibleReferenceParser.parse('Romanos 8:28');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('Romanos'));
        expect(result['chapter'], equals(8));
        expect(result['verse'], equals(28));
      });
    });

    group('Book abbreviations with periods', () {
      test('parses book name with period', () {
        final result = BibleReferenceParser.parse('Mt. 5:3');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('Mt.'));
        expect(result['chapter'], equals(5));
        expect(result['verse'], equals(3));
      });

      test('parses numbered book with period', () {
        final result = BibleReferenceParser.parse('1 Jn. 4:8');
        expect(result, isNotNull);
        expect(result!['bookName'], equals('1 Jn.'));
      });
    });
  });
}
