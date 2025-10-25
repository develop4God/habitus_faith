import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/extensions/string_extensions.dart';

void main() {
  group('StringExtensions - tr() method', () {
    test('returns capitalized last part when key contains dot', () {
      final result = 'bible.select_chapter'.tr();
      expect(result, equals('Select chapter'));
    });

    test('returns original string when no dot present', () {
      final result = 'hello_world'.tr();
      expect(result, equals('hello_world'));
    });

    test('replaces single parameter correctly', () {
      final result = 'bible.total_chapters_{count}'.tr({'count': '50'});
      expect(result, contains('50'));
      expect(result, contains('Total chapters'));
    });

    test('replaces multiple parameters correctly', () {
      final result =
          'test.message_{name}_age_{age}'.tr({'name': 'John', 'age': '25'});
      expect(result, contains('John'));
      expect(result, contains('25'));
    });

    test('handles parameters with special characters', () {
      final result = 'test.value_{data}'.tr({'data': '50%'});
      expect(result, contains('50%'));
    });

    test('handles empty parameter map', () {
      final result = 'bible.close'.tr({});
      expect(result, equals('Close'));
    });

    test('returns original with parameters if no match', () {
      final result = 'test.key'.tr({'other': 'value'});
      expect(result, equals('Key')); // Should still work, just no replacement
    });

    test('capitalizes first letter correctly', () {
      expect('hello'.capitalize(), equals('Hello'));
      expect('world'.capitalize(), equals('World'));
      expect(''.capitalize(), equals(''));
      expect('a'.capitalize(), equals('A'));
    });

    test('handles underscore replacement in translation key', () {
      final result = 'bible.search_book_placeholder'.tr();
      expect(result, equals('Search book placeholder'));
    });

    test('preserves parameter values exactly as provided', () {
      final result = 'test.msg_{count}'.tr({'count': '007'});
      expect(result, contains('007'));
    });
  });
}
