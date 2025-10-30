import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/domain/ml_features_calculator.dart';

/// Integration tests for ML prediction flow
/// Note: These tests verify the feature calculation logic
/// TFLite model tests are skipped due to package compatibility issues
void main() {
  group('ML Prediction Flow Integration', () {
    test('feature calculation produces valid values for prediction', () {
      // Create a habit with specific characteristics
      final now = DateTime.now();
      final createdAt = now.subtract(const Duration(days: 10));
      
      final completions = [
        now.subtract(const Duration(days: 1)),
        now.subtract(const Duration(days: 2)),
        now.subtract(const Duration(days: 4)),
      ];

      final habit = Habit(
        id: 'test_habit_1',
        userId: 'user1',
        name: 'Morning Prayer',
        description: 'Pray every morning',
        category: HabitCategory.spiritual,
        reminderTime: '09:00',
        createdAt: createdAt,
        currentStreak: 2,
        completionHistory: completions,
      );

      // Calculate all ML features
      final testTime = DateTime(2024, 1, 15, 14, 30); // Monday 2:30 PM
      
      final hourOfDay = testTime.hour;
      final dayOfWeek = testTime.weekday;
      final streakAtTime = habit.currentStreak;
      final failuresLast7Days = MLFeaturesCalculator.countRecentFailures(habit, 7);
      final hoursFromReminder = MLFeaturesCalculator.calculateHoursFromReminder(habit, testTime);

      // Verify all features are in valid ranges
      expect(hourOfDay, greaterThanOrEqualTo(0));
      expect(hourOfDay, lessThanOrEqualTo(23));
      
      expect(dayOfWeek, greaterThanOrEqualTo(1));
      expect(dayOfWeek, lessThanOrEqualTo(7));
      
      expect(streakAtTime, greaterThanOrEqualTo(0));
      
      expect(failuresLast7Days, greaterThanOrEqualTo(0));
      
      expect(hoursFromReminder, greaterThanOrEqualTo(0));
    });

    test('high-risk scenario produces expected features', () {
      // Create a habit that should have high abandonment risk
      final now = DateTime.now();
      final createdAt = now.subtract(const Duration(days: 30));
      
      // Very few recent completions (only 2 in the last 15 days, none in last 7)
      final completions = [
        now.subtract(const Duration(days: 10)),
        now.subtract(const Duration(days: 15)),
      ];

      final habit = Habit(
        id: 'risky_habit',
        userId: 'user1',
        name: 'Exercise',
        description: 'Exercise daily',
        category: HabitCategory.mental,
        reminderTime: '07:00',
        createdAt: createdAt,
        currentStreak: 0, // Broken streak
        completionHistory: completions,
      );

      // Late night scenario - 21:00 (9 PM)
      final testTime = DateTime(2024, 1, 19, 21, 0); // Friday 9 PM
      
      final hourOfDay = testTime.hour;
      final dayOfWeek = testTime.weekday;
      final streakAtTime = habit.currentStreak;
      final failuresLast7Days = MLFeaturesCalculator.countRecentFailures(habit, 7);
      final hoursFromReminder = MLFeaturesCalculator.calculateHoursFromReminder(habit, testTime);

      // Verify high-risk indicators
      expect(hourOfDay, 21); // Late in the day
      expect(dayOfWeek, 5); // Friday (end of week)
      expect(streakAtTime, 0); // No streak
      expect(failuresLast7Days, greaterThan(3)); // Multiple recent failures
      expect(hoursFromReminder, greaterThan(10)); // Long time since reminder
    });

    test('low-risk scenario produces expected features', () {
      // Create a habit with consistent completions
      final now = DateTime.now();
      final createdAt = now.subtract(const Duration(days: 20));
      
      // Completed every day for the last week
      final completions = List.generate(
        7,
        (i) => now.subtract(Duration(days: i)),
      );

      final habit = Habit(
        id: 'consistent_habit',
        userId: 'user1',
        name: 'Bible Reading',
        description: 'Read Bible daily',
        category: HabitCategory.spiritual,
        reminderTime: '10:00',
        createdAt: createdAt,
        currentStreak: 7, // Strong streak
        completionHistory: completions,
      );

      // Shortly after reminder time - 10:30 AM
      final testTime = DateTime(2024, 1, 15, 10, 30); // Monday 10:30 AM
      
      final streakAtTime = habit.currentStreak;
      final failuresLast7Days = MLFeaturesCalculator.countRecentFailures(habit, 7);
      final hoursFromReminder = MLFeaturesCalculator.calculateHoursFromReminder(habit, testTime);

      // Verify low-risk indicators
      expect(streakAtTime, greaterThanOrEqualTo(7)); // Strong streak
      expect(failuresLast7Days, 0); // No failures
      expect(hoursFromReminder, lessThanOrEqualTo(1)); // Near reminder time
    });

    test('feature values are deterministic for same inputs', () {
      final habit = Habit(
        id: 'test_habit',
        userId: 'user1',
        name: 'Test',
        description: 'Test',
        category: HabitCategory.mental,
        reminderTime: '12:00',
        createdAt: DateTime(2024, 1, 1),
        currentStreak: 5,
        completionHistory: [],
      );

      final testTime = DateTime(2024, 1, 15, 15, 0);

      // Calculate features twice
      final features1 = {
        'hoursFromReminder': MLFeaturesCalculator.calculateHoursFromReminder(habit, testTime),
        'failures': MLFeaturesCalculator.countRecentFailures(habit, 7),
      };

      final features2 = {
        'hoursFromReminder': MLFeaturesCalculator.calculateHoursFromReminder(habit, testTime),
        'failures': MLFeaturesCalculator.countRecentFailures(habit, 7),
      };

      // Should produce identical results
      expect(features1['hoursFromReminder'], features2['hoursFromReminder']);
      expect(features1['failures'], features2['failures']);
    });
  });
}
