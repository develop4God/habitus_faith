import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/providers/clock_provider.dart';
import 'package:habitus_faith/core/services/time/time.dart';

/// Test helper utilities for clock mocking and time manipulation
///
/// This file provides common patterns for testing time-dependent logic
/// in the Habitus Faith application using the Clock abstraction.

/// Creates a ProviderContainer with a fixed clock for deterministic testing
///
/// Example:
/// ```dart
/// final container = createContainerWithFixedClock(
///   DateTime(2025, 11, 15, 10, 30),
/// );
/// final clock = container.read(clockProvider);
/// expect(clock.now(), DateTime(2025, 11, 15, 10, 30));
/// ```
ProviderContainer createContainerWithFixedClock(DateTime fixedTime) {
  return ProviderContainer(
    overrides: [clockProvider.overrideWithValue(Clock.fixed(fixedTime))],
  );
}

/// Creates a ProviderContainer with system clock (default behavior)
///
/// Use this when you want to explicitly test with real time.
/// Most tests should use [createContainerWithFixedClock] instead.
///
/// Example:
/// ```dart
/// final container = createContainerWithSystemClock();
/// final clock = container.read(clockProvider);
/// // clock.now() returns actual current time
/// ```
ProviderContainer createContainerWithSystemClock() {
  return ProviderContainer(
    overrides: [clockProvider.overrideWithValue(const Clock.system())],
  );
}

/// Creates an advancing clock for testing time progression
///
/// This helper creates a mutable clock that can be advanced during tests,
/// useful for testing scenarios that span multiple days or time periods.
///
/// Example:
/// ```dart
/// final startTime = DateTime(2025, 11, 10, 9, 0);
/// final advancingClock = AdvancingClock(startTime);
/// final container = createContainerWithAdvancingClock(advancingClock);
///
/// // Initial state
/// expect(advancingClock.now(), startTime);
///
/// // Advance time by one day
/// advancingClock.advance(Duration(days: 1));
/// expect(advancingClock.now(), DateTime(2025, 11, 11, 9, 0));
/// ```
ProviderContainer createContainerWithAdvancingClock(AdvancingClock clock) {
  return ProviderContainer(overrides: [clockProvider.overrideWithValue(clock)]);
}

/// A mutable clock implementation for testing time progression
///
/// This clock allows you to advance time programmatically during tests,
/// making it easy to test multi-day scenarios without waiting.
///
/// Example:
/// ```dart
/// test('streak calculation over multiple days', () {
///   final clock = AdvancingClock(DateTime(2025, 11, 10, 9, 0));
///
///   // Day 1: Complete habit
///   var habit = habit.completeToday(clock: clock);
///   expect(habit.currentStreak, 1);
///
///   // Day 2: Complete habit
///   clock.advance(Duration(days: 1));
///   habit = habit.completeToday(clock: clock);
///   expect(habit.currentStreak, 2);
///
///   // Skip a day
///   clock.advance(Duration(days: 2));
///
///   // Day 4: Streak should reset
///   habit = habit.completeToday(clock: clock);
///   expect(habit.currentStreak, 1);
/// });
/// ```
class AdvancingClock implements Clock {
  DateTime _currentTime;

  AdvancingClock(this._currentTime);

  @override
  DateTime now() => _currentTime;

  /// Advances the clock by the specified duration
  void advance(Duration duration) {
    _currentTime = _currentTime.add(duration);
  }

  /// Sets the clock to a specific time
  void setTime(DateTime newTime) {
    _currentTime = newTime;
  }

  /// Advances the clock to the next day at midnight
  void advanceToNextDay() {
    final tomorrow = DateTime(
      _currentTime.year,
      _currentTime.month,
      _currentTime.day + 1,
    );
    _currentTime = tomorrow;
  }

  /// Advances the clock to a specific time on the same day
  void setTimeOfDay(int hour, [int minute = 0]) {
    _currentTime = DateTime(
      _currentTime.year,
      _currentTime.month,
      _currentTime.day,
      hour,
      minute,
    );
  }
}

/// Common test patterns for clock-based testing
///
/// These are helper functions that demonstrate common patterns
/// for testing time-dependent logic.

/// Creates a fixed time for a specific weekday
///
/// Useful for testing weekend/weekday-specific logic.
///
/// Example:
/// ```dart
/// final monday = createFixedTimeForWeekday(DateTime.monday, hour: 9);
/// final container = createContainerWithFixedClock(monday);
/// ```
DateTime createFixedTimeForWeekday(
  int weekday, {
  int hour = 9,
  int minute = 0,
}) {
  // Start from a known Monday (2025-11-10)
  final baseMonday = DateTime(2025, 11, 10);
  final daysToAdd = (weekday - DateTime.monday) % 7;
  return DateTime(
    baseMonday.year,
    baseMonday.month,
    baseMonday.day + daysToAdd,
    hour,
    minute,
  );
}

/// Creates a list of completion dates for testing streak logic
///
/// Example:
/// ```dart
/// final completions = createConsecutiveDates(
///   start: DateTime(2025, 11, 1),
///   count: 7,
/// );
/// // Returns 7 consecutive days starting from Nov 1
/// ```
List<DateTime> createConsecutiveDates({
  required DateTime start,
  required int count,
  Duration spacing = const Duration(days: 1),
}) {
  return List.generate(count, (i) => start.add(spacing * i));
}

/// Creates a list of dates with gaps for testing failure patterns
///
/// Example:
/// ```dart
/// final weekdayCompletions = createWeekdayOnlyDates(
///   startMonday: DateTime(2025, 11, 10),
///   weeks: 2,
/// );
/// // Returns Mon-Fri dates for 2 weeks (skips weekends)
/// ```
List<DateTime> createWeekdayOnlyDates({
  required DateTime startMonday,
  required int weeks,
}) {
  final completions = <DateTime>[];
  for (int week = 0; week < weeks; week++) {
    for (int day = 0; day < 5; day++) {
      // Mon-Fri (0-4)
      completions.add(startMonday.add(Duration(days: week * 7 + day)));
    }
  }
  return completions;
}
