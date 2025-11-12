import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ai/behavioral_engine.dart';
import 'package:habitus_faith/core/services/time/time.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';

/// Helper class for advancing time in tests
class FakeClockAdvancing implements Clock {
  DateTime _currentTime;

  FakeClockAdvancing(this._currentTime);

  @override
  DateTime now() => _currentTime;

  void advance(Duration duration) {
    _currentTime = _currentTime.add(duration);
  }

  void setTime(DateTime newTime) {
    _currentTime = newTime;
  }
}

void main() {
  group('Time-Accelerated Habit Flow Tests', () {
    test('detects weekend failure pattern in accelerated time', () {
      // Start on Monday 9am
      final startTime = DateTime(2025, 11, 10, 9, 0); // Monday
      final fakeClock = FakeClockAdvancing(startTime);
      final engine = BehavioralEngine(clock: fakeClock);

      // Create habit
      var habit = Habit.create(
        id: 'test1',
        userId: 'user1',
        name: 'Morning meditation',
        category: HabitCategory.spiritual,
        clock: fakeClock,
      );

      // Simulate 2 weeks of completions
      final completions = <DateTime>[];

      // Week 1: Complete Mon-Fri (skip weekends)
      for (int day = 0; day < 7; day++) {
        final currentDay = startTime.add(Duration(days: day));
        if (currentDay.weekday <= 5) {
          // Monday-Friday
          completions.add(currentDay);
          fakeClock.advance(const Duration(days: 1));
        } else {
          // Weekend - skip
          fakeClock.advance(const Duration(days: 1));
        }
      }

      // Week 2: Complete Mon-Fri (skip weekends)
      for (int day = 7; day < 14; day++) {
        final currentDay = startTime.add(Duration(days: day));
        if (currentDay.weekday <= 5) {
          // Monday-Friday
          completions.add(currentDay);
          fakeClock.advance(const Duration(days: 1));
        } else {
          // Weekend - skip
          fakeClock.advance(const Duration(days: 1));
        }
      }

      // Update habit with completion history and consecutive failures
      habit = habit.copyWith(
        completionHistory: completions,
        consecutiveFailures: 3, // Simulating weekend failures
      );

      // Advance to Monday of week 3 to detect pattern
      fakeClock.setTime(startTime.add(const Duration(days: 14)));

      // Detect failure pattern
      final pattern = engine.detectFailurePattern(habit);

      // Should detect weekend gap
      expect(pattern, equals(FailurePattern.weekendGap));

      // Verify completions are weekdays only
      for (final completion in completions) {
        expect(completion.weekday, lessThanOrEqualTo(5)); // Mon-Fri
      }
    });

    test('calculates successRate7d correctly over accelerated week', () {
      // Start on a specific date
      final startTime = DateTime(2025, 11, 10, 8, 0); // Monday 8am
      final fakeClock = FakeClockAdvancing(startTime);

      var habit = Habit.create(
        id: 'test2',
        userId: 'user1',
        name: 'Reading',
        category: HabitCategory.mental,
        clock: fakeClock,
      );

      // Simulate 5 completions out of 7 days
      for (int day = 0; day < 7; day++) {
        if (day < 5) {
          // Complete first 5 days
          habit = habit.completeToday(clock: fakeClock);
        }
        // Advance one day
        fakeClock.advance(const Duration(days: 1));
      }

      // Success rate should be 5/7 ≈ 0.714
      expect(habit.successRate7d, closeTo(5 / 7, 0.01));
      expect(habit.completionHistory.length, 5);
    });

    test('maintains streak when completing daily in accelerated time', () {
      final startTime = DateTime(2025, 11, 1, 10, 0);
      final fakeClock = FakeClockAdvancing(startTime);

      var habit = Habit.create(
        id: 'test3',
        userId: 'user1',
        name: 'Exercise',
        category: HabitCategory.physical,
        clock: fakeClock,
      );

      // Complete habit for 10 consecutive days
      for (int day = 0; day < 10; day++) {
        habit = habit.completeToday(clock: fakeClock);
        expect(habit.currentStreak, day + 1);

        // Advance to next day
        fakeClock.advance(const Duration(days: 1));
      }

      expect(habit.currentStreak, 10);
      expect(habit.longestStreak, 10);
      expect(habit.completionHistory.length, 10);
    });

    test('breaks streak when missing a day in accelerated time', () {
      final startTime = DateTime(2025, 11, 1, 10, 0);
      final fakeClock = FakeClockAdvancing(startTime);

      var habit = Habit.create(
        id: 'test4',
        userId: 'user1',
        name: 'Journaling',
        category: HabitCategory.spiritual,
        clock: fakeClock,
      );

      // Complete for 3 days
      for (int day = 0; day < 3; day++) {
        habit = habit.completeToday(clock: fakeClock);
        fakeClock.advance(const Duration(days: 1));
      }

      expect(habit.currentStreak, 3);

      // Skip a day (advance 2 days)
      fakeClock.advance(const Duration(days: 2));

      // Complete again - should reset streak
      habit = habit.completeToday(clock: fakeClock);

      expect(habit.currentStreak, 1); // Streak reset
      expect(habit.longestStreak, 3); // But longest streak preserved
    });

    test('optimal time detection works with accelerated completions', () {
      final startTime = DateTime(2025, 11, 1, 7, 0); // 7am start
      final fakeClock = FakeClockAdvancing(startTime);
      final engine = BehavioralEngine(clock: fakeClock);

      var habit = Habit.create(
        id: 'test5',
        userId: 'user1',
        name: 'Prayer',
        category: HabitCategory.spiritual,
        clock: fakeClock,
      );

      // Complete at 7am for 5 days
      final completions = <DateTime>[];
      for (int day = 0; day < 5; day++) {
        // Set time to 7am each day
        fakeClock.setTime(startTime.add(Duration(days: day)));
        completions.add(fakeClock.now());
        fakeClock.advance(const Duration(days: 1));
      }

      habit = habit.copyWith(completionHistory: completions);

      // Detect optimal time
      final optimalTime = engine.findOptimalTime(habit);

      expect(optimalTime, isNotNull);
      expect(optimalTime!.hour, 7); // Should be 7am
    });

    test('finds optimal days from accelerated weekly patterns', () {
      final startTime = DateTime(2025, 11, 10, 9, 0); // Monday
      final fakeClock = FakeClockAdvancing(startTime);
      final engine = BehavioralEngine(clock: fakeClock);

      var habit = Habit.create(
        id: 'test6',
        userId: 'user1',
        name: 'Gym',
        category: HabitCategory.physical,
        clock: fakeClock,
      );

      // Complete Mon, Wed, Fri for 3 weeks
      final completions = <DateTime>[];
      for (int week = 0; week < 3; week++) {
        for (int day = 0; day < 7; day++) {
          final currentDay = startTime.add(Duration(days: week * 7 + day));
          // Complete on Mon (1), Wed (3), Fri (5)
          if (currentDay.weekday == 1 ||
              currentDay.weekday == 3 ||
              currentDay.weekday == 5) {
            completions.add(currentDay);
          }
        }
      }

      habit = habit.copyWith(completionHistory: completions);

      // Find optimal days
      final optimalDays = engine.findOptimalDays(habit);

      expect(optimalDays.length, greaterThan(0));
      // Should include Monday, Wednesday, Friday
      expect(optimalDays.contains(1), isTrue); // Monday
      expect(optimalDays.contains(3), isTrue); // Wednesday
      expect(optimalDays.contains(5), isTrue); // Friday
    });

    test('handles month boundaries correctly in accelerated time', () {
      // Start near end of month
      final startTime = DateTime(2025, 10, 28, 10, 0); // Oct 28
      final fakeClock = FakeClockAdvancing(startTime);

      var habit = Habit.create(
        id: 'test7',
        userId: 'user1',
        name: 'Reading',
        category: HabitCategory.mental,
        clock: fakeClock,
      );

      // Complete across month boundary (Oct 28-31, Nov 1-3)
      for (int day = 0; day < 7; day++) {
        habit = habit.completeToday(clock: fakeClock);
        fakeClock.advance(const Duration(days: 1));
      }

      expect(habit.currentStreak, 7);
      expect(habit.completionHistory.length, 7);

      // Verify completions span two months
      final octoberCompletions =
          habit.completionHistory.where((d) => d.month == 10).length;
      final novemberCompletions =
          habit.completionHistory.where((d) => d.month == 11).length;

      expect(octoberCompletions, 4); // Oct 28-31
      expect(novemberCompletions, 3); // Nov 1-3
    });
  });
}
