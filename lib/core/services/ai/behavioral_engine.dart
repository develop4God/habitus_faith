import 'package:flutter/material.dart';
import '../../../features/habits/domain/habit.dart';
import '../../services/time/time.dart';

/// Behavioral Engine - Applies TCC (Task Control Components) and Nudge Theory
/// to analyze habit completion patterns and provide adaptive intelligence
class BehavioralEngine {
  final Clock clock;

  /// Constructor with optional clock injection
  BehavioralEngine({Clock? clock}) : clock = clock ?? const Clock.system();

  // TCC (Task Control Components) thresholds
  static const double tccIncreaseThreshold = 0.85;
  static const double tccDecreaseThreshold = 0.50;
  static const int maxDifficultyLevel = 5;
  static const int minDifficultyLevel = 1;

  // Nudge Theory minimums for pattern detection
  static const int minCompletionsForOptimalTime = 3;
  static const int minCompletionsForOptimalDays = 5;
  static const int minConsecutiveFailuresForPattern = 3;
  static const int topOptimalDaysCount = 3;

  /// Calculate next difficulty level based on success rate
  /// TCC: Increase challenge when succeeding, reduce when struggling
  int calculateNextDifficulty(Habit habit) {
    // If successRate7d >= threshold and not at max: increase challenge
    if (habit.successRate7d >= tccIncreaseThreshold &&
        habit.difficultyLevel < maxDifficultyLevel) {
      return habit.difficultyLevel + 1;
    }

    // If successRate7d < threshold and not at min: reduce to maintain engagement
    if (habit.successRate7d < tccDecreaseThreshold &&
        habit.difficultyLevel > minDifficultyLevel) {
      return habit.difficultyLevel - 1;
    }

    // Otherwise: return current difficultyLevel
    return habit.difficultyLevel;
  }

  /// Find the optimal time of day for habit completion
  /// Returns the most frequent hour when habit was successfully completed
  TimeOfDay? findOptimalTime(Habit habit) {
    // Need minimum completions for meaningful data
    if (habit.completionHistory.length < minCompletionsForOptimalTime) {
      return null;
    }

    // Extract hours from completion history
    final hours =
        habit.completionHistory.map((dt) => dt.toLocal().hour).toList();

    // Calculate mode (most frequent hour)
    final int? modeHour = _calculateMode(hours);

    if (modeHour == null) {
      return null;
    }

    return TimeOfDay(hour: modeHour, minute: 0);
  }

  /// Find the optimal days of the week for habit completion
  /// Returns top 3 most frequent days (1=Monday, 7=Sunday)
  List<int> findOptimalDays(Habit habit) {
    // Need minimum completions for meaningful pattern
    if (habit.completionHistory.length < minCompletionsForOptimalDays) {
      return [];
    }

    // Extract weekdays from successful completions
    final weekdays = habit.completionHistory.map((dt) => dt.weekday).toList();

    // Count frequency of each day
    final Map<int, int> dayFrequency = {};
    for (final day in weekdays) {
      dayFrequency[day] = (dayFrequency[day] ?? 0) + 1;
    }

    // Sort by frequency (descending) and return top count
    final sortedDays = dayFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedDays.take(topOptimalDaysCount).map((e) => e.key).toList();
  }

  /// Detect failure patterns in habit completion
  /// Returns specific pattern or null if no clear pattern
  FailurePattern? detectFailurePattern(Habit habit) {
    // Need minimum consecutive failures to detect pattern
    if (habit.consecutiveFailures < minConsecutiveFailuresForPattern) {
      return null;
    }

    // Need some completion history to detect patterns
    if (habit.completionHistory.isEmpty) {
      return null;
    }

    // Analyze last 7 days for patterns
    final now = clock.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));

    // Get completions in last 7 days
    final recentCompletions = habit.completionHistory.where((dt) {
      final date = DateTime(dt.year, dt.month, dt.day);
      final start =
          DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day);
      final end = DateTime(now.year, now.month, now.day);
      return (date.isAfter(start.subtract(const Duration(days: 1))) &&
          date.isBefore(end.add(const Duration(days: 1))));
    }).toList();

    // If no recent completions, can't determine pattern
    if (recentCompletions.isEmpty) {
      return null;
    }

    // Count completions by day of week
    final Map<int, int> dayCompletions = {};
    for (final dt in recentCompletions) {
      final day = dt.weekday;
      dayCompletions[day] = (dayCompletions[day] ?? 0) + 1;
    }

    // Check for weekend gap (Saturday=6, Sunday=7 have 0 completions)
    final hasWeekdayCompletions =
        dayCompletions.keys.any((day) => day >= 1 && day <= 5);
    final hasWeekendCompletions =
        dayCompletions.keys.any((day) => day == 6 || day == 7);

    if (hasWeekdayCompletions &&
        !hasWeekendCompletions &&
        recentCompletions.isNotEmpty) {
      return FailurePattern.weekendGap;
    }

    // Check for evening slump (failures after 6pm = 18:00)
    final eveningCompletions =
        recentCompletions.where((dt) => dt.toLocal().hour >= 18).length;
    final morningCompletions =
        recentCompletions.where((dt) => dt.toLocal().hour < 18).length;

    if (morningCompletions > 0 &&
        eveningCompletions == 0 &&
        recentCompletions.length >= 3) {
      return FailurePattern.eveningSlump;
    }

    // Default to inconsistent if we have consecutive failures but no clear pattern
    return FailurePattern.inconsistent;
  }

  /// Helper: Calculate mode (most frequent value) in a list
  int? _calculateMode(List<int> values) {
    if (values.isEmpty) {
      return null;
    }

    final Map<int, int> frequency = {};
    for (final value in values) {
      frequency[value] = (frequency[value] ?? 0) + 1;
    }

    // Find the value with highest frequency
    int? modeValue;
    int maxFrequency = 0;

    for (final entry in frequency.entries) {
      if (entry.value > maxFrequency) {
        maxFrequency = entry.value;
        modeValue = entry.key;
      }
    }

    return modeValue;
  }
}
