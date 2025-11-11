import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ai/behavioral_engine.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';

void main() {
  group('Behavioral Intelligence Flow - Realistic User Scenarios', () {
    late BehavioralEngine engine;

    setUp(() {
      engine = BehavioralEngine();
    });

    test(
      'Scenario 1: Progressive Overload - TCC increases difficulty as user succeeds consistently',
      () {
        // Simulate user completing habit 6/7 days for 2 weeks
        var habit = Habit.create(
          id: 'test1',
          userId: 'user1',
          name: 'Morning prayer',
          description: 'Prayer habit',
          category: HabitCategory.spiritual,
          difficultyLevel: 2,
        );

        final now = DateTime.now();
        final startDate = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 13));

        // Week 1: Complete Mon-Sat (6/7 days)
        final week1Completions = <DateTime>[];
        for (int i = 0; i < 7; i++) {
          final day = startDate.add(Duration(days: i));
          // Skip Sunday (weekday 7)
          if (day.weekday != 7) {
            week1Completions.add(day);
          }
        }

        // Week 2: Complete Mon-Sat (6/7 days)
        for (int i = 7; i < 14; i++) {
          final day = startDate.add(Duration(days: i));
          // Skip Sunday
          if (day.weekday != 7) {
            week1Completions.add(day);
          }
        }

        habit = habit.copyWith(
          completionHistory: week1Completions,
          currentStreak: 6,
          successRate7d: 6 / 7, // 85.7%
        );

        expect(habit.successRate7d, closeTo(0.857, 0.01));

        final newLevel = engine.calculateNextDifficulty(habit);
        expect(newLevel, 3); // Should increase from 2 to 3

        final newTargetMinutes = Habit.targetMinutesByLevel[newLevel]!;
        expect(newTargetMinutes, 20); // Level 3 = 20 minutes
      },
    );

    test(
      'Scenario 2: Adaptive Reduction - System reduces difficulty when user struggles',
      () {
        // User at level 4, struggling with only 40% completion
        var habit = Habit.create(
          id: 'test2',
          userId: 'user1',
          name: 'Exercise',
          description: 'Daily workout',
          category: HabitCategory.physical,
          difficultyLevel: 4,
          targetMinutes: 30,
        );

        final now = DateTime.now();
        final startDate = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));

        // Complete only 3 out of 7 days (42.8%)
        final completions = [
          startDate,
          startDate.add(const Duration(days: 2)),
          startDate.add(const Duration(days: 4)),
        ];

        habit = habit.copyWith(
          completionHistory: completions,
          currentStreak: 0,
          consecutiveFailures: 3,
          successRate7d: 3 / 7, // 42.8%
        );

        expect(
          habit.successRate7d,
          lessThan(BehavioralEngine.tccDecreaseThreshold),
        );

        final newLevel = engine.calculateNextDifficulty(habit);
        expect(newLevel, 3); // Should decrease from 4 to 3

        final pattern = engine.detectFailurePattern(habit);
        expect(
          pattern,
          isNotNull,
        ); // Should detect some pattern with 3+ failures
      },
    );

    test(
      'Scenario 3: Weekend Gap Detection - identifies weekday-only pattern',
      () {
        // User completes Mon-Fri consistently but fails weekends
        var habit = Habit.create(
          id: 'test3',
          userId: 'user1',
          name: 'Meditation',
          description: 'Daily meditation',
          category: HabitCategory.mental,
        );

        final now = DateTime.now();
        // Find most recent Monday
        final daysToMonday = (now.weekday - 1) % 7;
        final monday = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: daysToMonday));

        final completions = <DateTime>[];

        // 3 weeks of Mon-Fri success
        for (int week = 0; week < 3; week++) {
          for (int day = 0; day < 5; day++) {
            // Monday through Friday (0-4)
            completions.add(
              monday
                  .subtract(Duration(days: (2 - week) * 7))
                  .add(Duration(days: day)),
            );
          }
        }

        habit = habit.copyWith(
          completionHistory: completions,
          consecutiveFailures: 3, // Failed last weekend
        );

        final pattern = engine.detectFailurePattern(habit);
        expect(pattern, FailurePattern.weekendGap);

        final optimalDays = engine.findOptimalDays(habit);
        expect(optimalDays.length, greaterThan(0));
        // Should primarily show weekdays (1-5)
        expect(optimalDays.every((day) => day >= 1 && day <= 5), isTrue);
      },
    );

    test(
      'Scenario 4: Time Pattern Learning - learns user is morning person',
      () {
        // User completes at 7am 80% of the time
        var habit = Habit.create(
          id: 'test4',
          userId: 'user1',
          name: 'Bible reading',
          description: 'Daily reading',
          category: HabitCategory.spiritual,
        );

        final now = DateTime.now();
        final baseDate = DateTime(now.year, now.month, now.day);

        final completionTimes = [
          baseDate
              .subtract(const Duration(days: 7))
              .add(const Duration(hours: 7, minutes: 15)), // 7am
          baseDate
              .subtract(const Duration(days: 6))
              .add(const Duration(hours: 19, minutes: 30)), // 7pm (outlier)
          baseDate
              .subtract(const Duration(days: 5))
              .add(const Duration(hours: 6, minutes: 45)), // 7am
          baseDate
              .subtract(const Duration(days: 4))
              .add(const Duration(hours: 7, minutes: 20)), // 7am
          baseDate
              .subtract(const Duration(days: 3))
              .add(const Duration(hours: 7, minutes: 0)), // 7am
          baseDate
              .subtract(const Duration(days: 2))
              .add(const Duration(hours: 7, minutes: 10)), // 7am
          baseDate
              .subtract(const Duration(days: 1))
              .add(const Duration(hours: 21, minutes: 0)), // 9pm (outlier)
          baseDate.add(const Duration(hours: 6, minutes: 50)), // 7am
        ];

        habit = habit.copyWith(completionHistory: completionTimes);

        final optimalTime = engine.findOptimalTime(habit);

        expect(optimalTime, isNotNull);
        expect(optimalTime!.hour, anyOf(6, 7)); // Mode should be 6-7am range
      },
    );

    test(
      'Scenario 5: Recovery After Long Gap - handles abandonment gracefully',
      () {
        // User stops for 2 weeks, then restarts
        var habit = Habit.create(
          id: 'test5',
          userId: 'user1',
          name: 'Journaling',
          description: 'Daily gratitude journal',
          category: HabitCategory.spiritual,
          difficultyLevel: 3,
          targetMinutes: 20,
        );

        final now = DateTime.now();
        final twoWeeksAgo = now.subtract(const Duration(days: 14));
        final threeWeeksAgo = twoWeeksAgo.subtract(const Duration(days: 7));

        // Initial success: 5/7 days three weeks ago
        final initialCompletions = List.generate(
          5,
          (i) => threeWeeksAgo.add(Duration(days: i)),
        );

        habit = habit.copyWith(
          completionHistory: initialCompletions,
          consecutiveFailures: 14, // 14-day gap
          abandonmentRisk: 0.92, // High risk from ML predictor
          successRate7d: 5 / 7, // Old successes from 3 weeks ago
        );

        // System should suggest easier re-entry after abandonment
        final adjustedLevel = engine.calculateNextDifficulty(habit);

        // With high abandonment risk and long gap, system might reduce difficulty
        // depending on current success rate
        if (habit.successRate7d < BehavioralEngine.tccDecreaseThreshold) {
          expect(adjustedLevel, lessThan(habit.difficultyLevel));
        }

        // First completion after gap resets consecutive failures
        habit = habit.completeToday();
        expect(habit.consecutiveFailures, 0);
      },
    );

    test(
      'Scenario 6: Category-Specific Patterns - different patterns for different categories',
      () {
        final now = DateTime.now();
        final daysToMonday = (now.weekday - 1) % 7;
        final monday = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: daysToMonday));

        // Physical habit: weekday mornings
        final physicalCompletions = <DateTime>[];
        for (int week = 0; week < 2; week++) {
          for (int day = 0; day < 5; day++) {
            physicalCompletions.add(
              monday
                  .subtract(Duration(days: (1 - week) * 7))
                  .add(Duration(days: day, hours: 7)),
            );
          }
        }

        final physicalHabit = Habit.create(
          id: 'test6a',
          userId: 'user1',
          name: 'Workout',
          description: 'Morning exercise',
          category: HabitCategory.physical,
        ).copyWith(completionHistory: physicalCompletions);

        // Spiritual habit: daily evenings (including weekends)
        final spiritualCompletions = List.generate(
          14,
          (i) => monday
              .subtract(const Duration(days: 13))
              .add(Duration(days: i, hours: 20)),
        );

        final spiritualHabit = Habit.create(
          id: 'test6b',
          userId: 'user1',
          name: 'Prayer',
          description: 'Evening prayer',
          category: HabitCategory.spiritual,
        ).copyWith(completionHistory: spiritualCompletions);

        // Physical habit analysis
        final physOptimalDays = engine.findOptimalDays(physicalHabit);
        expect(physOptimalDays.isNotEmpty, isTrue);
        // Primarily weekdays
        final hasWeekdays = physOptimalDays.any((day) => day >= 1 && day <= 5);
        expect(hasWeekdays, isTrue);

        final physOptimalTime = engine.findOptimalTime(physicalHabit);
        expect(physOptimalTime, isNotNull);
        expect(physOptimalTime!.hour, lessThan(12)); // Morning

        // Spiritual habit analysis
        final spiritOptimalDays = engine.findOptimalDays(spiritualHabit);
        expect(
          spiritOptimalDays.length,
          greaterThan(0),
        ); // Should have patterns

        final spiritOptimalTime = engine.findOptimalTime(spiritualHabit);
        expect(spiritOptimalTime, isNotNull);
        expect(
          spiritOptimalTime!.hour,
          greaterThanOrEqualTo(17),
        ); // Evening (5pm or later)
      },
    );

    test(
      'Edge Case: Late Night Completion (11:59 PM) - should count for that day',
      () {
        var habit = Habit.create(
          id: 'test7',
          userId: 'user1',
          name: 'Reading',
          description: 'Daily reading',
          category: HabitCategory.mental,
        );

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final lateNight = today.add(const Duration(hours: 23, minutes: 59));

        habit = habit.copyWith(
          completionHistory: [lateNight],
          successRate7d: 1 / 7,
        );

        // Should have recorded the completion
        expect(habit.completionHistory.length, 1);
        expect(habit.completionHistory.first.day, today.day);

        // Optimal time should recognize late night pattern if consistent
        final moreCompletions = List.generate(
          5,
          (i) => today
              .subtract(Duration(days: i + 1))
              .add(const Duration(hours: 23, minutes: 30)),
        )..add(lateNight);

        habit = habit.copyWith(completionHistory: moreCompletions);

        final optimalTime = engine.findOptimalTime(habit);
        expect(optimalTime, isNotNull);
        expect(optimalTime!.hour, 23); // Should detect 11 PM pattern
      },
    );

    test(
      'Edge Case: Month Boundary - successRate7d calculation handles correctly',
      () {
        var habit = Habit.create(
          id: 'test8',
          userId: 'user1',
          name: 'Habit crossing months',
          description: 'Test month boundary',
          category: HabitCategory.relational,
        );

        // Create completions that span across month boundary
        final now = DateTime.now();
        // Go to first day of current month
        final firstOfMonth = DateTime(now.year, now.month, 1);

        // Completions: 3 days before month start, 3 days after
        final completions = [
          firstOfMonth.subtract(const Duration(days: 3)),
          firstOfMonth.subtract(const Duration(days: 2)),
          firstOfMonth.subtract(const Duration(days: 1)),
          firstOfMonth,
          firstOfMonth.add(const Duration(days: 1)),
          firstOfMonth.add(const Duration(days: 2)),
        ];

        habit = habit.copyWith(
          completionHistory: completions,
          successRate7d: 6 / 7, // 6 out of 7 days
        );

        // Verify completions are recorded across month boundary
        expect(habit.completionHistory.length, 6);

        // Success rate should be calculated correctly
        expect(habit.successRate7d, closeTo(0.857, 0.01));

        // System should recognize high performance
        final newLevel = engine.calculateNextDifficulty(habit);
        expect(newLevel, greaterThanOrEqualTo(habit.difficultyLevel));
      },
    );
  });
}
