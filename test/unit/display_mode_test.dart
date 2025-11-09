import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/models/display_mode.dart';

/// Unit tests for DisplayMode enum
/// Focus: Validation, serialization, deserialization, edge cases
void main() {
  group('DisplayMode Unit Tests', () {
    group('Enum Values', () {
      test('has two enum values: compact and advanced', () {
        expect(
          DisplayMode.values.length,
          2,
          reason: 'DisplayMode should have exactly 2 values',
        );
        expect(
          DisplayMode.values.contains(DisplayMode.compact),
          true,
          reason: 'Should contain compact mode',
        );
        expect(
          DisplayMode.values.contains(DisplayMode.advanced),
          true,
          reason: 'Should contain advanced mode',
        );
      });

      test('compact mode is the first enum value', () {
        expect(
          DisplayMode.values[0],
          DisplayMode.compact,
          reason: 'Compact mode should be the first value',
        );
      });

      test('advanced mode is the second enum value', () {
        expect(
          DisplayMode.values[1],
          DisplayMode.advanced,
          reason: 'Advanced mode should be the second value',
        );
      });
    });

    group('Serialization', () {
      test('compact mode serializes to "compact"', () {
        final result = DisplayMode.compact.toStorageString();
        expect(
          result,
          'compact',
          reason: 'Compact mode should serialize to "compact"',
        );
      });

      test('advanced mode serializes to "advanced"', () {
        final result = DisplayMode.advanced.toStorageString();
        expect(
          result,
          'advanced',
          reason: 'Advanced mode should serialize to "advanced"',
        );
      });
    });

    group('Deserialization', () {
      test('deserializes "compact" to compact mode', () {
        final result = DisplayMode.fromStorageString('compact');
        expect(
          result,
          DisplayMode.compact,
          reason: '"compact" should deserialize to compact mode',
        );
      });

      test('deserializes "advanced" to advanced mode', () {
        final result = DisplayMode.fromStorageString('advanced');
        expect(
          result,
          DisplayMode.advanced,
          reason: '"advanced" should deserialize to advanced mode',
        );
      });

      test('defaults to compact mode for invalid input', () {
        final result = DisplayMode.fromStorageString('invalid');
        expect(
          result,
          DisplayMode.compact,
          reason: 'Invalid input should default to compact mode',
        );
      });

      test('defaults to compact mode for empty string', () {
        final result = DisplayMode.fromStorageString('');
        expect(
          result,
          DisplayMode.compact,
          reason: 'Empty string should default to compact mode',
        );
      });

      test('defaults to compact mode for null-like values', () {
        final result = DisplayMode.fromStorageString('null');
        expect(
          result,
          DisplayMode.compact,
          reason: 'Null-like string should default to compact mode',
        );
      });

      test('handles case sensitivity correctly', () {
        // Should be case-sensitive
        final upperCase = DisplayMode.fromStorageString('COMPACT');
        expect(
          upperCase,
          DisplayMode.compact,
          reason: 'Should default to compact for incorrect case',
        );

        final mixedCase = DisplayMode.fromStorageString('Compact');
        expect(
          mixedCase,
          DisplayMode.compact,
          reason: 'Should default to compact for incorrect case',
        );
      });
    });

    group('Round-trip Serialization', () {
      test('compact mode survives round-trip', () {
        final serialized = DisplayMode.compact.toStorageString();
        final deserialized = DisplayMode.fromStorageString(serialized);
        expect(
          deserialized,
          DisplayMode.compact,
          reason: 'Compact mode should survive round-trip',
        );
      });

      test('advanced mode survives round-trip', () {
        final serialized = DisplayMode.advanced.toStorageString();
        final deserialized = DisplayMode.fromStorageString(serialized);
        expect(
          deserialized,
          DisplayMode.advanced,
          reason: 'Advanced mode should survive round-trip',
        );
      });
    });

    group('Input Validation', () {
      test('handles whitespace in input', () {
        final withSpaces = DisplayMode.fromStorageString(' compact ');
        expect(
          withSpaces,
          DisplayMode.compact,
          reason: 'Should default to compact for whitespace input',
        );

        final tabbed = DisplayMode.fromStorageString('compact\t');
        expect(
          tabbed,
          DisplayMode.compact,
          reason: 'Should default to compact for input with tabs',
        );
      });

      test('handles special characters in input', () {
        final special = DisplayMode.fromStorageString('compact!');
        expect(
          special,
          DisplayMode.compact,
          reason: 'Should default to compact for special characters',
        );
      });

      test('handles numeric input', () {
        final numeric = DisplayMode.fromStorageString('123');
        expect(
          numeric,
          DisplayMode.compact,
          reason: 'Should default to compact for numeric input',
        );
      });

      test('handles very long input strings', () {
        final longString = 'a' * 10000;
        final result = DisplayMode.fromStorageString(longString);
        expect(
          result,
          DisplayMode.compact,
          reason: 'Should default to compact for very long input',
        );
      });
    });

    group('Security Tests', () {
      test('handles SQL injection-like strings', () {
        final sqlInjection = DisplayMode.fromStorageString(
          "compact'; DROP TABLE users; --",
        );
        expect(
          sqlInjection,
          DisplayMode.compact,
          reason: 'Should safely handle SQL injection-like strings',
        );
      });

      test('handles script injection-like strings', () {
        final scriptInjection = DisplayMode.fromStorageString(
          '<script>alert("xss")</script>',
        );
        expect(
          scriptInjection,
          DisplayMode.compact,
          reason: 'Should safely handle script injection-like strings',
        );
      });

      test('handles path traversal-like strings', () {
        final pathTraversal = DisplayMode.fromStorageString('../../etc/passwd');
        expect(
          pathTraversal,
          DisplayMode.compact,
          reason: 'Should safely handle path traversal-like strings',
        );
      });
    });

    group('Edge Cases', () {
      test('handles unicode characters', () {
        final unicode = DisplayMode.fromStorageString('🎉compact🎉');
        expect(
          unicode,
          DisplayMode.compact,
          reason: 'Should default to compact for unicode input',
        );
      });

      test('handles line breaks', () {
        final lineBreak = DisplayMode.fromStorageString('compact\n');
        expect(
          lineBreak,
          DisplayMode.compact,
          reason: 'Should default to compact for line break input',
        );
      });

      test('serialization is consistent across multiple calls', () {
        final first = DisplayMode.compact.toStorageString();
        final second = DisplayMode.compact.toStorageString();
        final third = DisplayMode.compact.toStorageString();

        expect(first, second, reason: 'Serialization should be consistent');
        expect(second, third, reason: 'Serialization should be consistent');
      });

      test('deserialization is consistent across multiple calls', () {
        final first = DisplayMode.fromStorageString('compact');
        final second = DisplayMode.fromStorageString('compact');
        final third = DisplayMode.fromStorageString('compact');

        expect(first, second, reason: 'Deserialization should be consistent');
        expect(second, third, reason: 'Deserialization should be consistent');
      });
    });
  });
}
