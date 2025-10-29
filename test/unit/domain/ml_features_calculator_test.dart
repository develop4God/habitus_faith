import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/domain/ml_features_calculator.dart';

void main() {
  group('MLFeaturesCalculator', () {
    group('calculateHoursFromReminder', () {
      test('returns 0 when reminderTime is null', () {
        final habit = Habit(
          id: 'habit1',
          userId: 'user1',
          name: 'Test Habit',
          description: 'Test',
          category: HabitCategory.prayer,
          reminderTime: null,
          createdAt: DateTime.now(),
        );

        final hours = MLFeaturesCalculator.calculateHoursFromReminder(
          habit,
          DateTime.now(),
        );

        expect(hours, 0);
      });

      test('returns 0 when reminderTime is empty string', () {
        final habit = Habit(
          id: 'habit1',
          userId: 'user1',
          name: 'Test Habit',
          description: 'Test',
          category: HabitCategory.prayer,
          reminderTime: '',
          createdAt: DateTime.now(),
        );

        final hours = MLFeaturesCalculator.calculateHoursFromReminder(
          habit,
          DateTime.now(),
        );

        expect(hours, 0);
      });

      test('returns 0 when reminderTime has invalid format', () {
        final habit = Habit(
          id: 'habit1',
          userId: 'user1',
          name: 'Test Habit',
          description: 'Test',
          category: HabitCategory.prayer,
          reminderTime: 'invalid',
          createdAt: DateTime.now(),
        );

        final hours = MLFeaturesCalculator.calculateHoursFromReminder(
          habit,
          DateTime.now(),
        );

        expect(hours, 0);
      });

      test('calculates correct hours when current time is after reminder', () {
        final habit = Habit(
          id: 'habit1',
          userId: 'user1',
          name: 'Test Habit',
          description: 'Test',
          category: HabitCategory.prayer,
          reminderTime: '09:00',
          createdAt: DateTime.now(),
        );

        final now = DateTime(2024, 1, 15, 14, 30); // 2:30 PM
        // Reminder was at 9:00 AM, so difference is 5.5 hours (rounded to 5)

        final hours = MLFeaturesCalculator.calculateHoursFromReminder(
          habit,
          now,
        );

        expect(hours, 5); // 14:30 - 09:00 = 5 hours (integer division)
      });

      test('calculates correct hours when current time is before reminder', () {
        final habit = Habit(
          id: 'habit1',
          userId: 'user1',
          name: 'Test Habit',
          description: 'Test',
          category: HabitCategory.prayer,
          reminderTime: '14:00',
          createdAt: DateTime.now(),
        );

        final now = DateTime(2024, 1, 15, 9, 0); // 9:00 AM
        // Reminder is at 2:00 PM, so difference is 5 hours

        final hours = MLFeaturesCalculator.calculateHoursFromReminder(
          habit,
          now,
        );

        expect(hours, 5); // abs(09:00 - 14:00) = 5 hours
      });

      test('handles reminder at exact current time', () {
        final habit = Habit(
          id: 'habit1',
          userId: 'user1',
          name: 'Test Habit',
          description: 'Test',
          category: HabitCategory.prayer,
          reminderTime: '10:00',
          createdAt: DateTime.now(),
        );

        final now = DateTime(2024, 1, 15, 10, 0);

        final hours = MLFeaturesCalculator.calculateHoursFromReminder(
          habit,
          now,
        );

        expect(hours, 0);
      });
    });

    group('countRecentFailures', () {
      test('returns 0 for brand new habit created today', () {
        final now = DateTime.now();
        final habit = Habit(
          id: 'habit1',
          userId: 'user1',
          name: 'Test Habit',
          description: 'Test',
          category: HabitCategory.prayer,
          createdAt: now,
          completionHistory: [],
        );

        final failures = MLFeaturesCalculator.countRecentFailures(habit, 7);

        expect(failures, 0);
      });

      test('calculates failures correctly for habit older than window', () {
        final now = DateTime.now();
        final createdAt = now.subtract(const Duration(days: 10));

        // Habit created 10 days ago, completed only 4 times in last 7 days
        final completions = [
          now.subtract(const Duration(days: 1)),
          now.subtract(const Duration(days: 2)),
          now.subtract(const Duration(days: 4)),
          now.subtract(const Duration(days: 6)),
        ];

        final habit = Habit(
          id: 'habit1',
          userId: 'user1',
          name: 'Test Habit',
          description: 'Test',
          category: HabitCategory.prayer,
          createdAt: createdAt,
          completionHistory: completions,
        );

        final failures = MLFeaturesCalculator.countRecentFailures(habit, 7);

        // Expected 7 completions, got 4, so 3 failures
        expect(failures, 3);
      });

      test('handles habit newer than requested window', () {
        final now = DateTime.now();
        final createdAt = now.subtract(const Duration(days: 3));

        // Habit created 3 days ago, completed 2 times
        final completions = [
          now.subtract(const Duration(days: 1)),
          now.subtract(const Duration(days: 2)),
        ];

        final habit = Habit(
          id: 'habit1',
          userId: 'user1',
          name: 'Test Habit',
          description: 'Test',
          category: HabitCategory.prayer,
          createdAt: createdAt,
          completionHistory: completions,
        );

        final failures = MLFeaturesCalculator.countRecentFailures(habit, 7);

        // Only 3 days old, expected 3 completions, got 2, so 1 failure
        expect(failures, 1);
      });

      test('returns 0 when all days completed', () {
        final now = DateTime.now();
        final createdAt = now.subtract(const Duration(days: 5));

        // Habit created 5 days ago, completed every day
        final completions = [
          now,
          now.subtract(const Duration(days: 1)),
          now.subtract(const Duration(days: 2)),
          now.subtract(const Duration(days: 3)),
          now.subtract(const Duration(days: 4)),
        ];

        final habit = Habit(
          id: 'habit1',
          userId: 'user1',
          name: 'Test Habit',
          description: 'Test',
          category: HabitCategory.prayer,
          createdAt: createdAt,
          completionHistory: completions,
        );

        final failures = MLFeaturesCalculator.countRecentFailures(habit, 7);

        expect(failures, 0);
      });

      test('ignores completions outside the window', () {
        final now = DateTime.now();
        final createdAt = now.subtract(const Duration(days: 30));

        // Old completions that shouldn't count
        final completions = [
          now.subtract(const Duration(days: 10)),
          now.subtract(const Duration(days: 15)),
          now.subtract(const Duration(days: 20)),
        ];

        final habit = Habit(
          id: 'habit1',
          userId: 'user1',
          name: 'Test Habit',
          description: 'Test',
          category: HabitCategory.prayer,
          createdAt: createdAt,
          completionHistory: completions,
        );

        final failures = MLFeaturesCalculator.countRecentFailures(habit, 7);

        // Expected 7 completions in last 7 days, got 0, so 7 failures
        expect(failures, 7);
      });

      test('handles empty completion history', () {
        final now = DateTime.now();
        final createdAt = now.subtract(const Duration(days: 5));

        final habit = Habit(
          id: 'habit1',
          userId: 'user1',
          name: 'Test Habit',
          description: 'Test',
          category: HabitCategory.prayer,
          createdAt: createdAt,
          completionHistory: [],
        );

        final failures = MLFeaturesCalculator.countRecentFailures(habit, 7);

        // Expected 5 completions (habit is 5 days old), got 0, so 5 failures
        expect(failures, 5);
      });
    });
  });
}
