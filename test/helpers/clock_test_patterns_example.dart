import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/time/time.dart';
import 'package:habitus_faith/core/services/ai/behavioral_engine.dart';
import 'package:habitus_faith/core/providers/clock_provider.dart';
import 'package:habitus_faith/core/providers/behavioral_engine_provider.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import '../helpers/clock_test_helpers.dart';

/// Example tests demonstrating clock testing patterns
///
/// This file provides practical examples of how to use the clock test helpers
/// for various testing scenarios. Use these as templates for your own tests.

void main() {
  group('Clock Testing Pattern Examples', () {
    group('Pattern 1: Fixed Clock for Single Point in Time', () {
      test('example: testing habit completion at specific time', () {
        // Use fixed clock for deterministic testing
        final fixedTime = DateTime(2025, 11, 15, 10, 30); // Friday 10:30 AM
        final clock = Clock.fixed(fixedTime);

        // Create and complete habit
        final habit = Habit.create(
          id: 'test1',
          userId: 'user1',
          name: 'Morning Prayer',
          description: 'Daily prayer',
          category: HabitCategory.spiritual,
          clock: clock,
        ).completeToday(clock: clock);

        // Verify the exact completion time
        expect(habit.lastCompletedAt, fixedTime);
        expect(habit.currentStreak, 1);
      });

      test('example: testing weekday-specific logic', () {
        // Use helper to create specific weekday
        final saturday = createFixedTimeForWeekday(DateTime.saturday, hour: 14);
        expect(saturday.weekday, DateTime.saturday);

        // Test weekend detection logic
        final clock = Clock.fixed(saturday);
        final engine = BehavioralEngine(clock: clock);

        // Verify the clock and engine are set up correctly
        expect(clock.now().weekday, DateTime.saturday);
        expect(engine.clock.now(), saturday);
      });
    });

    group('Pattern 2: Advancing Clock for Time Progression', () {
      test('example: testing multi-day streak', () {
        // Start on Monday at 9 AM
        final clock = AdvancingClock(DateTime(2025, 11, 10, 9, 0));
        var habit = Habit.create(
          id: 'test2',
          userId: 'user1',
          name: 'Exercise',
          description: 'Daily workout',
          category: HabitCategory.physical,
          clock: clock,
        );

        // Day 1: Complete habit
        habit = habit.completeToday(clock: clock);
        expect(habit.currentStreak, 1);

        // Day 2: Advance and complete
        clock.advance(const Duration(days: 1));
        habit = habit.completeToday(clock: clock);
        expect(habit.currentStreak, 2);

        // Day 3: Advance and complete
        clock.advance(const Duration(days: 1));
        habit = habit.completeToday(clock: clock);
        expect(habit.currentStreak, 3);

        expect(habit.completionHistory.length, 3);
      });

      test('example: testing streak reset after gap', () {
        final clock = AdvancingClock(DateTime(2025, 11, 1, 10, 0));
        var habit = Habit.create(
          id: 'test3',
          userId: 'user1',
          name: 'Reading',
          description: 'Daily reading',
          category: HabitCategory.mental,
          clock: clock,
        );

        // Build a 3-day streak
        for (int i = 0; i < 3; i++) {
          habit = habit.completeToday(clock: clock);
          clock.advance(const Duration(days: 1));
        }
        expect(habit.currentStreak, 3);

        // Skip 2 days (advance 3 days total from last completion)
        clock.advance(const Duration(days: 2));

        // Complete again - streak should reset
        habit = habit.completeToday(clock: clock);
        expect(habit.currentStreak, 1);
        expect(habit.longestStreak, 3); // But longest streak is preserved
      });
    });

    group('Pattern 3: Historical Data Testing', () {
      test('example: testing 7-day success rate', () {
        final now = DateTime(2025, 11, 15, 10, 0);
        final clock = Clock.fixed(now);

        // Create 5 completions in last 7 days using helper
        final completions = [
          now.subtract(const Duration(days: 1)),
          now.subtract(const Duration(days: 2)),
          now.subtract(const Duration(days: 3)),
          now.subtract(const Duration(days: 5)),
          now.subtract(const Duration(days: 6)),
        ];

        var habit = Habit(
          id: 'test4',
          userId: 'user1',
          name: 'Meditation',
          description: 'Daily meditation',
          category: HabitCategory.spiritual,
          createdAt: now.subtract(const Duration(days: 30)),
          completionHistory: completions,
        );

        // Complete today to trigger calculation
        habit = habit.completeToday(clock: clock);

        // 6 completions / 7 days = ~0.857
        expect(habit.successRate7d, closeTo(6 / 7, 0.01));
      });

      test('example: testing consecutive dates helper', () {
        final start = DateTime(2025, 11, 1, 9, 0);
        final completions = createConsecutiveDates(start: start, count: 10);

        expect(completions.length, 10);
        expect(completions.first, start);
        expect(completions.last, start.add(const Duration(days: 9)));

        // Verify they're truly consecutive
        for (int i = 1; i < completions.length; i++) {
          final diff = completions[i].difference(completions[i - 1]);
          expect(diff.inDays, 1);
        }
      });
    });

    group('Pattern 4: Provider-Based Testing', () {
      test('example: testing with provider container', () {
        final fixedTime = DateTime(2025, 11, 15, 14, 30);
        final container = createContainerWithFixedClock(fixedTime);

        // Services from container will use the fixed clock
        final clock = container.read(clockProvider);
        expect(clock.now(), fixedTime);

        container.dispose();
      });

      test('example: testing behavioral engine with fixed clock', () {
        final fixedTime = DateTime(2025, 11, 15, 16, 0);
        final container = createContainerWithFixedClock(fixedTime);

        final engine = container.read(behavioralEngineProvider);

        // Create habit with weekend pattern
        final monday = DateTime(2025, 11, 10, 9, 0);
        final completions = createWeekdayOnlyDates(
          startMonday: monday,
          weeks: 2,
        );

        final habit = Habit(
          id: 'test5',
          userId: 'user1',
          name: 'Workout',
          description: 'Gym sessions',
          category: HabitCategory.physical,
          createdAt: monday,
          completionHistory: completions,
          consecutiveFailures: 3,
        );

        final pattern = engine.detectFailurePattern(habit);
        expect(pattern, FailurePattern.weekendGap);

        container.dispose();
      });
    });

    group('Pattern 5: Complex Scenarios', () {
      test('example: testing weekend gap detection', () {
        final monday = DateTime(2025, 11, 10, 9, 0);
        final clock = AdvancingClock(monday);

        // Create weekday-only completions using helper
        final completions = createWeekdayOnlyDates(
          startMonday: monday,
          weeks: 2,
        );

        // Verify we have 10 completions (5 days * 2 weeks)
        expect(completions.length, 10);

        // Verify all completions are weekdays
        for (final date in completions) {
          expect(date.weekday, lessThanOrEqualTo(5)); // Mon-Fri
        }

        final habit = Habit(
          id: 'test6',
          userId: 'user1',
          name: 'Morning Routine',
          description: 'Daily routine',
          category: HabitCategory.spiritual,
          createdAt: monday,
          completionHistory: completions,
          consecutiveFailures: 3,
        );

        // Advance to Monday of week 3
        clock.setTime(monday.add(const Duration(days: 14)));

        final engine = BehavioralEngine(clock: clock);
        final pattern = engine.detectFailurePattern(habit);

        expect(pattern, FailurePattern.weekendGap);
      });

      test('example: testing month boundary handling', () {
        // Start near end of October
        final clock = AdvancingClock(DateTime(2025, 10, 28, 10, 0));
        var habit = Habit.create(
          id: 'test7',
          userId: 'user1',
          name: 'Study',
          description: 'Daily study',
          category: HabitCategory.mental,
          clock: clock,
        );

        // Complete across month boundary (Oct 28-31, Nov 1-3)
        for (int day = 0; day < 7; day++) {
          habit = habit.completeToday(clock: clock);
          clock.advance(const Duration(days: 1));
        }

        expect(habit.currentStreak, 7);
        expect(habit.completionHistory.length, 7);

        // Verify completions span two months
        final octCompletions = habit.completionHistory
            .where((d) => d.month == 10)
            .length;
        final novCompletions = habit.completionHistory
            .where((d) => d.month == 11)
            .length;

        expect(octCompletions, 4); // Oct 28-31
        expect(novCompletions, 3); // Nov 1-3
      });

      test('example: testing time-of-day advancement', () {
        final clock = AdvancingClock(DateTime(2025, 11, 15, 8, 0));

        // Morning time
        expect(clock.now().hour, 8);

        // Advance to afternoon
        clock.setTimeOfDay(14, 30);
        expect(clock.now().hour, 14);
        expect(clock.now().minute, 30);

        // Advance to next day at midnight
        clock.advanceToNextDay();
        expect(clock.now().day, 16);
        expect(clock.now().hour, 0);
        expect(clock.now().minute, 0);
      });
    });

    group('Best Practices Examples', () {
      test('example: clean test structure with setup', () {
        // Arrange: Set up test data with clear intent
        final testTime = DateTime(2025, 11, 15, 9, 0);
        final clock = Clock.fixed(testTime);
        final habit = Habit.create(
          id: 'test8',
          userId: 'user1',
          name: 'Prayer',
          description: 'Morning prayer',
          category: HabitCategory.spiritual,
          clock: clock,
        );

        // Act: Perform the action being tested
        final completedHabit = habit.completeToday(clock: clock);

        // Assert: Verify the outcome
        expect(completedHabit.lastCompletedAt, testTime);
        expect(completedHabit.currentStreak, 1);
        expect(completedHabit.completionHistory.length, 1);
      });

      test('example: testing edge cases', () {
        // Test at exact midnight
        final midnight = DateTime(2025, 11, 15, 0, 0, 0);
        final clockMidnight = Clock.fixed(midnight);
        final habitMidnight = Habit.create(
          id: 'test9',
          userId: 'user1',
          name: 'Test',
          description: 'Test',
          category: HabitCategory.spiritual,
          clock: clockMidnight,
        ).completeToday(clock: clockMidnight);

        expect(habitMidnight.lastCompletedAt!.hour, 0);

        // Test at 11:59 PM
        final almostMidnight = DateTime(2025, 11, 15, 23, 59, 59);
        final clockAlmostMidnight = Clock.fixed(almostMidnight);
        final habitAlmostMidnight = Habit.create(
          id: 'test10',
          userId: 'user1',
          name: 'Test',
          description: 'Test',
          category: HabitCategory.spiritual,
          clock: clockAlmostMidnight,
        ).completeToday(clock: clockAlmostMidnight);

        expect(habitAlmostMidnight.lastCompletedAt!.hour, 23);
      });
    });
  });
}
