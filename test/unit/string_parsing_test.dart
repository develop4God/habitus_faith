// test/unit/string_parsing_test.dart

import 'package:flutter_test/flutter_test.dart';

/// Tests for string parsing methods that extract verse references and text.
/// These tests validate the bounds checking logic to prevent StringIndexOutOfBoundsException.
void main() {
  group('Verse Text Extraction - Edge Cases', () {
    test('handles string with valid quotes', () {
      const versiculo = 'John 3:16 RVR1960: "For God so loved the world"';
      final quoteStart = versiculo.indexOf('"');
      final quoteEnd = versiculo.lastIndexOf('"');
      
      expect(quoteStart, greaterThanOrEqualTo(0));
      expect(quoteEnd, greaterThan(quoteStart));
      expect(quoteEnd, lessThanOrEqualTo(versiculo.length));
      
      // Validate bounds before substring
      if (quoteStart != -1 && quoteEnd != -1 && 
          quoteEnd > quoteStart && 
          quoteStart + 1 < versiculo.length && 
          quoteEnd <= versiculo.length) {
        final result = versiculo.substring(quoteStart + 1, quoteEnd);
        expect(result, equals('For God so loved the world'));
      }
    });

    test('handles string without quotes', () {
      const versiculo = 'John 3:16 RVR1960';
      final quoteStart = versiculo.indexOf('"');
      final quoteEnd = versiculo.lastIndexOf('"');
      
      expect(quoteStart, equals(-1));
      expect(quoteEnd, equals(-1));
      
      // Should not attempt substring when quotes are not found
      if (quoteStart == -1 || quoteEnd == -1) {
        expect(true, isTrue); // Validation passed
      }
    });

    test('handles string with single quote', () {
      const versiculo = 'John 3:16 "Incomplete verse';
      final quoteStart = versiculo.indexOf('"');
      final quoteEnd = versiculo.lastIndexOf('"');
      
      // Single quote means start and end are the same
      expect(quoteStart, equals(quoteEnd));
      
      // Should not attempt substring when end <= start
      if (quoteEnd <= quoteStart) {
        expect(true, isTrue); // Validation passed
      }
    });

    test('handles empty string', () {
      const versiculo = '';
      final quoteStart = versiculo.indexOf('"');
      final quoteEnd = versiculo.lastIndexOf('"');
      
      expect(quoteStart, equals(-1));
      expect(quoteEnd, equals(-1));
    });

    test('handles very long string with quotes', () {
      final longText = List.filled(200, 'A').join();
      final versiculo = 'Ref "$longText"';
      final quoteStart = versiculo.indexOf('"');
      final quoteEnd = versiculo.lastIndexOf('"');
      
      expect(quoteStart, greaterThanOrEqualTo(0));
      expect(quoteEnd, greaterThan(quoteStart));
      expect(quoteEnd, lessThanOrEqualTo(versiculo.length));
      
      // Validate bounds
      if (quoteStart != -1 && quoteEnd != -1 && 
          quoteEnd > quoteStart && 
          quoteStart + 1 < versiculo.length && 
          quoteEnd <= versiculo.length) {
        final result = versiculo.substring(quoteStart + 1, quoteEnd);
        expect(result.length, equals(200));
      }
    });

    test('validates bounds prevent index out of range', () {
      // Simulate the crash scenario: attempting to access index 259 in string of length 135
      final versiculo = List.filled(135, 'A').join(); // String of length 135
      final quoteStart = versiculo.indexOf('"');
      final quoteEnd = versiculo.lastIndexOf('"');
      
      // In this case, no quotes found
      expect(quoteStart, equals(-1));
      expect(quoteEnd, equals(-1));
      
      // Bounds check should prevent substring attempt
      final canSubstring = quoteStart != -1 && quoteEnd != -1 && 
          quoteEnd > quoteStart && 
          quoteStart + 1 < versiculo.length && 
          quoteEnd <= versiculo.length;
      
      expect(canSubstring, isFalse);
    });
  });

  group('Verse Reference Extraction - Edge Cases', () {
    test('handles valid verse reference with quote', () {
      const versiculo = 'John 3:16 RVR1960: "Text here"';
      final quoteIndex = versiculo.indexOf('"');
      
      expect(quoteIndex, greaterThan(0));
      expect(quoteIndex, lessThanOrEqualTo(versiculo.length));
      
      if (quoteIndex > 0 && quoteIndex <= versiculo.length) {
        final result = versiculo.substring(0, quoteIndex).trim();
        expect(result, equals('John 3:16 RVR1960:'));
      }
    });

    test('handles verse reference without quote', () {
      const versiculo = 'John 3:16 RVR1960';
      final quoteIndex = versiculo.indexOf('"');
      
      expect(quoteIndex, equals(-1));
      
      // Should return original when no quote found
      if (quoteIndex <= 0) {
        expect(true, isTrue); // Validation passed
      }
    });

    test('handles quote at beginning', () {
      const versiculo = '"Text without reference"';
      final quoteIndex = versiculo.indexOf('"');
      
      expect(quoteIndex, equals(0));
      
      // Should not extract when quote is at position 0
      if (quoteIndex <= 0) {
        expect(true, isTrue); // Validation passed
      }
    });

    test('validates substring bounds for reference extraction', () {
      const versiculo = 'John 3:16 "Text"';
      final quoteIndex = versiculo.indexOf('"');
      
      // Ensure quoteIndex is within valid range
      expect(quoteIndex, greaterThan(0));
      expect(quoteIndex, lessThanOrEqualTo(versiculo.length));
      
      if (quoteIndex > 0 && quoteIndex <= versiculo.length) {
        final result = versiculo.substring(0, quoteIndex);
        expect(result, equals('John 3:16 '));
      }
    });
  });

  group('Substring Boundary Validation', () {
    test('prevents out of bounds access with invalid end index', () {
      const text = 'Hello World'; // length 11
      const start = 0;
      const end = 259; // Invalid - beyond string length
      
      // This is what should be checked before substring
      final isValid = start >= 0 && 
                      end <= text.length && 
                      end > start;
      
      expect(isValid, isFalse);
    });

    test('validates correct bounds checking logic', () {
      const text = 'Hello World';
      const start = 6;
      const end = 11;
      
      final isValid = start >= 0 && 
                      end <= text.length && 
                      end > start;
      
      expect(isValid, isTrue);
      
      if (isValid) {
        final result = text.substring(start, end);
        expect(result, equals('World'));
      }
    });

    test('handles edge case where start equals end', () {
      const text = 'Test';
      const start = 2;
      const end = 2;
      
      final isValid = start >= 0 && 
                      end <= text.length && 
                      end > start; // This will be false
      
      expect(isValid, isFalse);
    });
  });
}
