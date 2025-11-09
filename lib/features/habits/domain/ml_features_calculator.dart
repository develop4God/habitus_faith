import 'package:flutter/foundation.dart';
import 'habit.dart';

/// Centralized logic to compute ML features from Habit objects
/// Ensures consistency between training data collection and inference
class MLFeaturesCalculator {
  /// Calculate absolute difference in hours from reminder time to current time
  /// Returns 0 if reminderTime is null or unparseable
  static int calculateHoursFromReminder(Habit habit, DateTime now) {
    final reminderTime = habit.reminderTime;

    if (reminderTime == null || reminderTime.isEmpty) {
      return 0;
    }

    try {
      // Parse reminder time (format "HH:mm")
      final parts = reminderTime.split(':');
      if (parts.length != 2) {
        debugPrint(
          'MLFeaturesCalculator: Invalid reminder time format: $reminderTime',
        );
        return 0;
      }

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Create DateTime for reminder on current day
      final reminderDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Calculate absolute difference in hours
      final difference = now.difference(reminderDateTime);
      return difference.inHours.abs();
    } catch (e) {
      debugPrint(
        'MLFeaturesCalculator: Error parsing reminder time "$reminderTime": $e',
      );
      return 0;
    }
  }

  /// Calculate count of missed days in the last N days
  /// Returns expected completions minus actual completions in that period
  ///
  /// Example: if 7 days passed but only 4 completions exist, return 3 failures
  /// If habit was created less than N days ago, only count actual days elapsed
  static int countRecentFailures(Habit habit, int days, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final today = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
    );

    // Calculate habit age in days
    final habitCreated = DateTime(
      habit.createdAt.year,
      habit.createdAt.month,
      habit.createdAt.day,
    );
    final habitAgeDays = today.difference(habitCreated).inDays;

    // Use actual days elapsed if habit is newer than requested window
    final daysToCheck = habitAgeDays < days ? habitAgeDays : days;

    // If habit was just created today or is brand new, no failures yet
    if (daysToCheck <= 0) {
      return 0;
    }

    // Count completions in the last N days
    final cutoffDate = today.subtract(Duration(days: daysToCheck));

    final recentCompletions = habit.completionHistory.where((completion) {
      final completionDate = DateTime(
        completion.year,
        completion.month,
        completion.day,
      );
      return completionDate.isAfter(cutoffDate) || completionDate == cutoffDate;
    }).length;

    // Expected completions = days to check, actual = recentCompletions
    final failures = daysToCheck - recentCompletions;

    return failures > 0 ? failures : 0;
  }

  /// Calculate success rate over the last N days
  /// Returns a value between 0.0 and 1.0 representing the success percentage
  ///
  /// Example: 5 completions in 7 days = 5/7 = ~0.714 (71.4% success rate)
  ///
  /// [completionHistory] - List of completion timestamps
  /// [now] - Current time (defaults to DateTime.now())
  /// [days] - Number of days to look back (default: 7)
  static double calculateSuccessRate(
    List<DateTime> completionHistory,
    DateTime now, {
    int days = 7,
  }) {
    if (completionHistory.isEmpty) return 0.0;

    final today = DateTime(now.year, now.month, now.day);
    final cutoffDate = today.subtract(
      Duration(days: days - 1),
    ); // -1 to include today

    // Count completions within the window
    int completionsInWindow = 0;
    for (final completion in completionHistory) {
      final completionDate = DateTime(
        completion.year,
        completion.month,
        completion.day,
      );
      if (completionDate.isAfter(
            cutoffDate.subtract(const Duration(days: 1)),
          ) &&
          completionDate.isBefore(today.add(const Duration(days: 1)))) {
        completionsInWindow++;
      }
    }

    return completionsInWindow / days.toDouble();
  }
}
