import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/models/display_mode.dart';

/// Unit tests for DisplayMode enum
/// Focus: Validation, serialization, deserialization, edge cases
void main() {
  group('DisplayMode Unit Tests', () {
    group('Enum Values', () {
      test('has two enum values: simple and advanced', () {
        expect(DisplayMode.values.length, 2,
            reason: 'DisplayMode should have exactly 2 values');
        expect(DisplayMode.values.contains(DisplayMode.simple), true,
            reason: 'Should contain simple mode');
        expect(DisplayMode.values.contains(DisplayMode.advanced), true,
            reason: 'Should contain advanced mode');
      });

      test('simple mode is the first enum value', () {
        expect(DisplayMode.values[0], DisplayMode.simple,
            reason: 'Simple mode should be the first value');
      });

      test('advanced mode is the second enum value', () {
        expect(DisplayMode.values[1], DisplayMode.advanced,
            reason: 'Advanced mode should be the second value');
      });
    });

    group('Serialization', () {
      test('simple mode serializes to "simple"', () {
        final result = DisplayMode.simple.toStorageString();
        expect(result, 'simple',
            reason: 'Simple mode should serialize to "simple"');
      });

      test('advanced mode serializes to "advanced"', () {
        final result = DisplayMode.advanced.toStorageString();
        expect(result, 'advanced',
            reason: 'Advanced mode should serialize to "advanced"');
      });
    });

    group('Deserialization', () {
      test('deserializes "simple" to simple mode', () {
        final result = DisplayMode.fromStorageString('simple');
        expect(result, DisplayMode.simple,
            reason: '"simple" should deserialize to simple mode');
      });

      test('deserializes "advanced" to advanced mode', () {
        final result = DisplayMode.fromStorageString('advanced');
        expect(result, DisplayMode.advanced,
            reason: '"advanced" should deserialize to advanced mode');
      });

      test('defaults to simple mode for invalid input', () {
        final result = DisplayMode.fromStorageString('invalid');
        expect(result, DisplayMode.simple,
            reason: 'Invalid input should default to simple mode');
      });

      test('defaults to simple mode for empty string', () {
        final result = DisplayMode.fromStorageString('');
        expect(result, DisplayMode.simple,
            reason: 'Empty string should default to simple mode');
      });

      test('defaults to simple mode for null-like values', () {
        final result = DisplayMode.fromStorageString('null');
        expect(result, DisplayMode.simple,
            reason: 'Null-like string should default to simple mode');
      });

      test('handles case sensitivity correctly', () {
        // Should be case-sensitive
        final upperCase = DisplayMode.fromStorageString('SIMPLE');
        expect(upperCase, DisplayMode.simple,
            reason: 'Should default to simple for incorrect case');

        final mixedCase = DisplayMode.fromStorageString('Simple');
        expect(mixedCase, DisplayMode.simple,
            reason: 'Should default to simple for incorrect case');
      });
    });

    group('Round-trip Serialization', () {
      test('simple mode survives round-trip', () {
        final serialized = DisplayMode.simple.toStorageString();
        final deserialized = DisplayMode.fromStorageString(serialized);
        expect(deserialized, DisplayMode.simple,
            reason: 'Simple mode should survive round-trip');
      });

      test('advanced mode survives round-trip', () {
        final serialized = DisplayMode.advanced.toStorageString();
        final deserialized = DisplayMode.fromStorageString(serialized);
        expect(deserialized, DisplayMode.advanced,
            reason: 'Advanced mode should survive round-trip');
      });
    });

    group('Input Validation', () {
      test('handles whitespace in input', () {
        final withSpaces = DisplayMode.fromStorageString(' simple ');
        expect(withSpaces, DisplayMode.simple,
            reason: 'Should default to simple for whitespace input');

        final tabbed = DisplayMode.fromStorageString('simple\t');
        expect(tabbed, DisplayMode.simple,
            reason: 'Should default to simple for input with tabs');
      });

      test('handles special characters in input', () {
        final special = DisplayMode.fromStorageString('simple!');
        expect(special, DisplayMode.simple,
            reason: 'Should default to simple for special characters');
      });

      test('handles numeric input', () {
        final numeric = DisplayMode.fromStorageString('123');
        expect(numeric, DisplayMode.simple,
            reason: 'Should default to simple for numeric input');
      });

      test('handles very long input strings', () {
        final longString = 'a' * 10000;
        final result = DisplayMode.fromStorageString(longString);
        expect(result, DisplayMode.simple,
            reason: 'Should default to simple for very long input');
      });
    });

    group('Security Tests', () {
      test('handles SQL injection-like strings', () {
        final sqlInjection =
            DisplayMode.fromStorageString("simple'; DROP TABLE users; --");
        expect(sqlInjection, DisplayMode.simple,
            reason: 'Should safely handle SQL injection-like strings');
      });

      test('handles script injection-like strings', () {
        final scriptInjection =
            DisplayMode.fromStorageString('<script>alert("xss")</script>');
        expect(scriptInjection, DisplayMode.simple,
            reason: 'Should safely handle script injection-like strings');
      });

      test('handles path traversal-like strings', () {
        final pathTraversal = DisplayMode.fromStorageString('../../etc/passwd');
        expect(pathTraversal, DisplayMode.simple,
            reason: 'Should safely handle path traversal-like strings');
      });
    });

    group('Edge Cases', () {
      test('handles unicode characters', () {
        final unicode = DisplayMode.fromStorageString('🎉simple🎉');
        expect(unicode, DisplayMode.simple,
            reason: 'Should default to simple for unicode input');
      });

      test('handles line breaks', () {
        final lineBreak = DisplayMode.fromStorageString('simple\n');
        expect(lineBreak, DisplayMode.simple,
            reason: 'Should default to simple for line break input');
      });

      test('serialization is consistent across multiple calls', () {
        final first = DisplayMode.simple.toStorageString();
        final second = DisplayMode.simple.toStorageString();
        final third = DisplayMode.simple.toStorageString();

        expect(first, second, reason: 'Serialization should be consistent');
        expect(second, third, reason: 'Serialization should be consistent');
      });

      test('deserialization is consistent across multiple calls', () {
        final first = DisplayMode.fromStorageString('simple');
        final second = DisplayMode.fromStorageString('simple');
        final third = DisplayMode.fromStorageString('simple');

        expect(first, second, reason: 'Deserialization should be consistent');
        expect(second, third, reason: 'Deserialization should be consistent');
      });
    });
  });
}
