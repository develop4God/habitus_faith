import 'package:flutter/material.dart';
import '../../../features/habits/domain/habit.dart';

/// Behavioral Engine - Applies TCC (Task Control Components) and Nudge Theory
/// to analyze habit completion patterns and provide adaptive intelligence
class BehavioralEngine {
  /// Calculate next difficulty level based on success rate
  /// TCC: Increase challenge when succeeding, reduce when struggling
  int calculateNextDifficulty(Habit habit) {
    // If successRate7d >= 0.85 and difficultyLevel < 5: increase challenge
    if (habit.successRate7d >= 0.85 && habit.difficultyLevel < 5) {
      return habit.difficultyLevel + 1;
    }
    
    // If successRate7d < 0.50 and difficultyLevel > 1: reduce to maintain engagement
    if (habit.successRate7d < 0.50 && habit.difficultyLevel > 1) {
      return habit.difficultyLevel - 1;
    }
    
    // Otherwise: return current difficultyLevel
    return habit.difficultyLevel;
  }

  /// Find the optimal time of day for habit completion
  /// Returns the most frequent hour when habit was successfully completed
  TimeOfDay? findOptimalTime(Habit habit) {
    // Need at least 3 completions for meaningful data
    if (habit.completionHistory.length < 3) {
      return null;
    }

    // Extract hours from completion history
    final hours = habit.completionHistory.map((dt) => dt.toLocal().hour).toList();
    
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
    // Need at least 5 completions for meaningful pattern
    if (habit.completionHistory.length < 5) {
      return [];
    }

    // Extract weekdays from successful completions
    final weekdays = habit.completionHistory.map((dt) => dt.weekday).toList();
    
    // Count frequency of each day
    final Map<int, int> dayFrequency = {};
    for (final day in weekdays) {
      dayFrequency[day] = (dayFrequency[day] ?? 0) + 1;
    }
    
    // Sort by frequency (descending) and return top 3
    final sortedDays = dayFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedDays.take(3).map((e) => e.key).toList();
  }

  /// Detect failure patterns in habit completion
  /// Returns specific pattern or null if no clear pattern
  FailurePattern? detectFailurePattern(Habit habit) {
    // Need at least 3 consecutive failures to detect pattern
    if (habit.consecutiveFailures < 3) {
      return null;
    }
    
    // Need some completion history to detect patterns
    if (habit.completionHistory.isEmpty) {
      return null;
    }
    
    // Analyze last 7 days for patterns
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));
    
    // Get completions in last 7 days
    final recentCompletions = habit.completionHistory.where((dt) {
      final date = DateTime(dt.year, dt.month, dt.day);
      final start = DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day);
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
    final hasWeekdayCompletions = dayCompletions.keys.any((day) => day >= 1 && day <= 5);
    final hasWeekendCompletions = dayCompletions.keys.any((day) => day == 6 || day == 7);
    
    if (hasWeekdayCompletions && !hasWeekendCompletions && recentCompletions.isNotEmpty) {
      return FailurePattern.weekendGap;
    }
    
    // Check for evening slump (failures after 6pm = 18:00)
    final eveningCompletions = recentCompletions.where((dt) => dt.toLocal().hour >= 18).length;
    final morningCompletions = recentCompletions.where((dt) => dt.toLocal().hour < 18).length;
    
    if (morningCompletions > 0 && eveningCompletions == 0 && recentCompletions.length >= 3) {
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
