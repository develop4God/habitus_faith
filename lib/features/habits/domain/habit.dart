import 'package:flutter/material.dart';
import 'models/verse_reference.dart';
import 'models/habit_notification.dart';
import '../../../core/services/time/time.dart';
import 'ml_features_calculator.dart';

enum FailurePattern { weekendGap, eveningSlump, inconsistent }

enum HabitCategory {
  spiritual, // prayer, bible reading, worship, fasting
  physical, // exercise, sleep, nutrition, health
  mental, // learning, meditation, reading, creativity
  relational, // family time, friendships, community, service
  other; // user-defined or uncategorized

  String get displayName {
    switch (this) {
      case HabitCategory.spiritual:
        return 'Espiritual';
      case HabitCategory.physical:
        return 'Físico';
      case HabitCategory.mental:
        return 'Mental';
      case HabitCategory.relational:
        return 'Relacional';
      case HabitCategory.other:
        return 'Otros';
    }
  }
}

enum HabitDifficulty {
  easy,
  medium,
  hard;

  String get displayName {
    switch (this) {
      case HabitDifficulty.easy:
        return 'Fácil';
      case HabitDifficulty.medium:
        return 'Medio';
      case HabitDifficulty.hard:
        return 'Difícil';
    }
  }
}

/// Pure domain entity - no Firestore dependencies
class Habit {
  /// Maps difficulty level (1-5) to recommended target minutes
  static const Map<int, int> targetMinutesByLevel = {
    1: 5,
    2: 10,
    3: 20,
    4: 30,
    5: 45,
  };

  final String id;
  final String userId;
  final String name;
  final String description;
  final HabitCategory category;
  final String? emoji;
  final VerseReference? verse;
  final String? reminderTime;
  final String? predefinedId;
  final bool completedToday;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedAt;
  final List<DateTime> completionHistory;
  final DateTime createdAt;
  final bool isArchived;
  final int? colorValue; // Store color as int (Color.value)
  final HabitDifficulty difficulty;

  // TCC/Nudge adaptive intelligence fields
  final int difficultyLevel; // 1-5 scale for TCC adjustment
  final int targetMinutes; // expected duration
  final double successRate7d; // calculated weekly success percentage
  final List<int>
      optimalDays; // List<int> where 1=Monday, learned from completion patterns
  final TimeOfDay? optimalTime; // when user most succeeds
  final int consecutiveFailures; // triggers intervention
  final FailurePattern? failurePattern;
  final double abandonmentRisk; // 0.0-1.0 from ML predictor
  final DateTime? lastAdjustedAt; // for tracking auto-adjustments

  // Notification and recurrence fields
  final HabitNotificationSettings? notificationSettings;
  final HabitRecurrence? recurrence;
  final List<Subtask> subtasks;

  Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.category,
    this.emoji,
    this.verse,
    this.reminderTime,
    this.predefinedId,
    this.completedToday = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedAt,
    this.completionHistory = const [],
    required this.createdAt,
    this.isArchived = false,
    this.colorValue,
    this.difficulty = HabitDifficulty.medium,
    this.difficultyLevel = 3,
    this.targetMinutes = 20, // Default matches difficultyLevel 3
    this.successRate7d = 0.0,
    this.optimalDays = const [],
    this.optimalTime,
    this.consecutiveFailures = 0,
    this.failurePattern,
    this.abandonmentRisk = 0.0,
    this.lastAdjustedAt,
    this.notificationSettings,
    this.recurrence,
    this.subtasks = const [],
  });

  factory Habit.create({
    required String id,
    required String userId,
    required String name,
    required String description,
    HabitCategory category = HabitCategory.spiritual,
    String? emoji,
    VerseReference? verse,
    String? reminderTime,
    String? predefinedId,
    int? colorValue,
    HabitDifficulty difficulty = HabitDifficulty.medium,
    int difficultyLevel = 3,
    int? targetMinutes,
    Clock? clock,
  }) {
    final effectiveClock = clock ?? const Clock.system();
    return Habit(
      id: id,
      userId: userId,
      name: name,
      description: description,
      category: category,
      emoji: emoji,
      verse: verse,
      reminderTime: reminderTime,
      predefinedId: predefinedId,
      createdAt: effectiveClock.now(),
      colorValue: colorValue,
      difficulty: difficulty,
      difficultyLevel: difficultyLevel,
      targetMinutes: targetMinutes ?? targetMinutesByLevel[difficultyLevel]!,
    );
  }

  /// Business logic: Complete habit for today
  Habit completeToday({Clock? clock}) {
    final effectiveClock = clock ?? const Clock.system();
    final now = effectiveClock.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if already completed today - idempotent operation
    if (lastCompletedAt != null) {
      final lastCompleted = DateTime(
        lastCompletedAt!.year,
        lastCompletedAt!.month,
        lastCompletedAt!.day,
      );

      if (lastCompleted == today) {
        // Already completed today, return unchanged
        return this;
      }
    }

    // Calculate new streak
    int newStreak = 1;
    if (lastCompletedAt != null) {
      final lastCompleted = DateTime(
        lastCompletedAt!.year,
        lastCompletedAt!.month,
        lastCompletedAt!.day,
      );
      final yesterday = today.subtract(const Duration(days: 1));

      if (lastCompleted == yesterday) {
        // Consecutive day
        newStreak = currentStreak + 1;
      } else {
        // Gap > 1 day, restart streak
        newStreak = 1;
      }
    }

    // Update longest streak if necessary
    final newLongestStreak =
        newStreak > longestStreak ? newStreak : longestStreak;

    // Add to completion history
    final newHistory = [...completionHistory, now];

    // Calculate successRate7d based on last 7 days using MLFeaturesCalculator
    final newSuccessRate7d = MLFeaturesCalculator.calculateSuccessRate(
      newHistory,
      now,
      days: 7,
    );

    return copyWith(
      completedToday: true,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastCompletedAt: now,
      completionHistory: newHistory,
      successRate7d: newSuccessRate7d,
      consecutiveFailures:
          0, // Reset consecutive failures on successful completion
    );
  }

  Habit copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    HabitCategory? category,
    String? emoji,
    VerseReference? verse,
    String? reminderTime,
    String? predefinedId,
    bool? completedToday,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedAt,
    List<DateTime>? completionHistory,
    DateTime? createdAt,
    bool? isArchived,
    int? colorValue,
    HabitDifficulty? difficulty,
    int? difficultyLevel,
    int? targetMinutes,
    double? successRate7d,
    List<int>? optimalDays,
    TimeOfDay? optimalTime,
    int? consecutiveFailures,
    FailurePattern? failurePattern,
    double? abandonmentRisk,
    DateTime? lastAdjustedAt,
    HabitNotificationSettings? notificationSettings,
    HabitRecurrence? recurrence,
    List<Subtask>? subtasks,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      verse: verse ?? this.verse,
      reminderTime: reminderTime ?? this.reminderTime,
      predefinedId: predefinedId ?? this.predefinedId,
      completedToday: completedToday ?? this.completedToday,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      completionHistory: completionHistory ?? this.completionHistory,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
      colorValue: colorValue ?? this.colorValue,
      difficulty: difficulty ?? this.difficulty,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      successRate7d: successRate7d ?? this.successRate7d,
      optimalDays: optimalDays ?? this.optimalDays,
      optimalTime: optimalTime ?? this.optimalTime,
      consecutiveFailures: consecutiveFailures ?? this.consecutiveFailures,
      failurePattern: failurePattern ?? this.failurePattern,
      abandonmentRisk: abandonmentRisk ?? this.abandonmentRisk,
      lastAdjustedAt: lastAdjustedAt ?? this.lastAdjustedAt,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      recurrence: recurrence ?? this.recurrence,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}
