import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/models/completion_record.dart';

void main() {
  group('CompletionRecord', () {
    test('creates a valid completion record', () {
      final now = DateTime.now();
      final record = CompletionRecord(
        habitId: 'habit123',
        completedAt: now,
      );

      expect(record.habitId, 'habit123');
      expect(record.completedAt, now);
      expect(record.notes, isNull);
    });

    test('creates completion record with notes', () {
      final now = DateTime.now();
      const notes = 'Felt great today!';
      final record = CompletionRecord(
        habitId: 'habit123',
        completedAt: now,
        notes: notes,
      );

      expect(record.notes, notes);
    });

    test('dateKey returns correct date string', () {
      final date = DateTime(2024, 10, 24, 14, 30);
      final record = CompletionRecord(
        habitId: 'habit123',
        completedAt: date,
      );

      expect(record.dateKey, '2024-10-24');
    });

    test('dateKey ignores time component', () {
      final morning = DateTime(2024, 10, 24, 8, 0);
      final evening = DateTime(2024, 10, 24, 20, 0);

      final record1 = CompletionRecord(
        habitId: 'habit123',
        completedAt: morning,
      );

      final record2 = CompletionRecord(
        habitId: 'habit123',
        completedAt: evening,
      );

      expect(record1.dateKey, record2.dateKey);
    });

    test('serializes to JSON correctly', () {
      final date = DateTime(2024, 10, 24, 14, 30);
      final record = CompletionRecord(
        habitId: 'habit123',
        completedAt: date,
        notes: 'Great session',
      );

      final json = record.toJson();

      expect(json['habitId'], 'habit123');
      expect(json['completedAt'], isNotNull);
      expect(json['notes'], 'Great session');
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'habitId': 'habit123',
        'completedAt': '2024-10-24T14:30:00.000',
        'notes': 'Great session',
      };

      final record = CompletionRecord.fromJson(json);

      expect(record.habitId, 'habit123');
      expect(record.notes, 'Great session');
    });

    test('round-trip serialization preserves data', () {
      final original = CompletionRecord(
        habitId: 'habit123',
        completedAt: DateTime(2024, 10, 24, 14, 30),
        notes: 'Test notes',
      );

      final json = original.toJson();
      final restored = CompletionRecord.fromJson(json);

      expect(restored.habitId, original.habitId);
      expect(restored.notes, original.notes);
      expect(restored.dateKey, original.dateKey);
    });
  });
}
