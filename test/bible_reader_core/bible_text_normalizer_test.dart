import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/bible_reader_core/bible_reader_core.dart';

void main() {
  group('BibleTextNormalizer - Edge Cases & Real Logic', () {
    group('Basic tag removal', () {
      test('removes simple XML tags', () {
        final result = BibleTextNormalizer.clean('<pb/>In the beginning');
        expect(result, equals('In the beginning'));
      });

      test('removes complex XML tags with attributes', () {
        final result = BibleTextNormalizer.clean(
          '<f id="123" ref="note">God created<f/> the heavens',
        );
        expect(result, equals('God created the heavens'));
      });

      test('removes multiple tags in sequence', () {
        final result = BibleTextNormalizer.clean(
          '<pb/><f>And God said<f/><note>',
        );
        expect(result, equals('And God said'));
      });
    });

    group('Bracket content removal', () {
      test('removes simple bracketed content', () {
        final result = BibleTextNormalizer.clean('In the beginning[1] God');
        expect(result, equals('In the beginning God'));
      });

      test('removes letter references', () {
        final result = BibleTextNormalizer.clean('And God[a] said let');
        expect(result, equals('And God said let'));
      });

      test('removes complex bracket references', () {
        final result = BibleTextNormalizer.clean('the earth[36†] was');
        expect(result, equals('the earth was'));
      });

      test('removes multiple bracketed contents', () {
        final result = BibleTextNormalizer.clean(
          'In[1] the[a] beginning[36†] God[b]',
        );
        expect(result, equals('In the beginning God'));
      });
    });

    group('Combined tag and bracket removal', () {
      test('removes both tags and brackets in mixed content', () {
        final result = BibleTextNormalizer.clean(
          '<pb/>In the beginning[1] <f>God<f/> created[a]',
        );
        expect(result, equals('In the beginning God created'));
      });

      test('handles nested and sequential mixed content', () {
        final result = BibleTextNormalizer.clean(
          '<note id="1">And[a] God<f/> said[b]<pb/> let there',
        );
        expect(result, equals('And God said let there'));
      });
    });

    group('Edge cases - Null and empty', () {
      test('handles null input', () {
        final result = BibleTextNormalizer.clean(null);
        expect(result, equals(''));
      });

      test('handles empty string', () {
        final result = BibleTextNormalizer.clean('');
        expect(result, equals(''));
      });

      test('handles whitespace-only string', () {
        final result = BibleTextNormalizer.clean('   ');
        expect(result, equals(''));
      });

      test('handles string with only tags', () {
        final result = BibleTextNormalizer.clean('<pb/><f></f><note>');
        expect(result, equals(''));
      });

      test('handles string with only brackets', () {
        final result = BibleTextNormalizer.clean('[1][a][36†]');
        expect(result, equals(''));
      });
    });

    group('Edge cases - Malformed input', () {
      test('handles unclosed tags gracefully', () {
        final result = BibleTextNormalizer.clean('<pb In the beginning');
        expect(result, equals('<pb In the beginning'));
      });

      test('handles unclosed brackets gracefully', () {
        final result = BibleTextNormalizer.clean('In the beginning[1 God');
        expect(result, equals('In the beginning[1 God'));
      });

      test('handles mismatched tags', () {
        final result = BibleTextNormalizer.clean('<f>text</note>');
        expect(result, equals('text'));
      });
    });

    group('Edge cases - Special characters', () {
      test('preserves accented characters', () {
        final result = BibleTextNormalizer.clean('<pb/>En el principio[1] creó');
        expect(result, equals('En el principio creó'));
      });

      test('preserves punctuation', () {
        final result = BibleTextNormalizer.clean(
          '<f>And God said, "Let there be light."<f/>',
        );
        expect(result, equals('And God said, "Let there be light."'));
      });

      test('preserves line breaks and spacing', () {
        final result = BibleTextNormalizer.clean('<pb/>Line 1\nLine 2[a]');
        expect(result, equals('Line 1\nLine 2'));
      });

      test('preserves numbers in actual text', () {
        final result = BibleTextNormalizer.clean('<f>The 12 tribes[a]');
        expect(result, equals('The 12 tribes'));
      });
    });

    group('Real-world Bible text examples', () {
      test('cleans Genesis 1:1 with typical annotations', () {
        final result = BibleTextNormalizer.clean(
          '<pb/>In the beginning[a] God[b] created<f id="1"/> the heavens[1] and the earth[2].',
        );
        expect(result, equals(
          'In the beginning God created the heavens and the earth.',
        ));
      });

      test('cleans John 3:16 with references', () {
        final result = BibleTextNormalizer.clean(
          'For God<f ref="note1"/> so loved[a] the world[b], that he gave[1] his only begotten Son[2]',
        );
        expect(result, equals(
          'For God so loved the world, that he gave his only begotten Son',
        ));
      });

      test('cleans Psalm with multiple annotations', () {
        final result = BibleTextNormalizer.clean(
          '<pb/><title>Psalm 23<title/>\nThe LORD[a] is my shepherd[1]; I shall not want[b].',
        );
        expect(result, equals(
          'Psalm 23\nThe LORD is my shepherd; I shall not want.',
        ));
      });
    });

    group('Performance - Large text', () {
      test('handles very long verses efficiently', () {
        // Psalm 119:176 - longest verse
        final longText = '<pb/>' + ('word[a] ' * 100) + '<f>end</f>';
        final result = BibleTextNormalizer.clean(longText);
        expect(result.contains('['), isFalse);
        expect(result.contains('<'), isFalse);
        expect(result, contains('word'));
        expect(result, contains('end'));
      });

      test('handles text with many sequential tags', () {
        final manyTags = '<pb/><f><note><title>' + 'text' + '</title></note></f>';
        final result = BibleTextNormalizer.clean(manyTags);
        expect(result, equals('text'));
      });
    });

    group('Trimming behavior', () {
      test('trims leading whitespace', () {
        final result = BibleTextNormalizer.clean('   In the beginning');
        expect(result, equals('In the beginning'));
      });

      test('trims trailing whitespace', () {
        final result = BibleTextNormalizer.clean('In the beginning   ');
        expect(result, equals('In the beginning'));
      });

      test('trims whitespace after tag removal', () {
        final result = BibleTextNormalizer.clean('<pb/>   In   <f/>   the   ');
        // Tags are removed, leaving spaces, then trimmed at the end
        expect(result, equals('In      the'));
      });
    });
  });
}
