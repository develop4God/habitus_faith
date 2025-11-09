import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../domain/habit.dart';
import '../domain/models/verse_reference.dart';

/// Data model for Firestore serialization
class HabitModel {
  /// Migrates old category values to new holistic category model
  /// Handles backwards compatibility with legacy categories:
  /// prayer, bibleReading -> spiritual
  /// service -> relational
  /// gratitude -> mental
  static HabitCategory _migrateCategory(String? value) {
    // Migration map for legacy categories
    const migrationMap = {
      // Legacy categories
      'prayer': HabitCategory.spiritual,
      'bibleReading': HabitCategory.spiritual,
      'service': HabitCategory.relational,
      'gratitude': HabitCategory.mental,
      // New categories (passthrough)
      'spiritual': HabitCategory.spiritual,
      'physical': HabitCategory.physical,
      'mental': HabitCategory.mental,
      'relational': HabitCategory.relational,
      'other': HabitCategory.other,
    };

    return migrationMap[value] ?? HabitCategory.spiritual;
  }

  static Habit fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Habit(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      category: _migrateCategory(data['category']),
      emoji: data['emoji'] as String?,
      verse: data['verse'] != null
          ? VerseReference.fromJson(data['verse'] as Map<String, dynamic>)
          : null,
      reminderTime: data['reminderTime'] as String?,
      predefinedId: data['predefinedId'] as String?,
      completedToday: data['completedToday'] as bool? ?? false,
      currentStreak: data['currentStreak'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      lastCompletedAt: data['lastCompletedAt'] != null
          ? (data['lastCompletedAt'] as Timestamp).toDate()
          : null,
      completionHistory:
          (data['completionHistory'] as List<dynamic>?)
              ?.map((e) => (e as Timestamp).toDate())
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isArchived: data['isArchived'] as bool? ?? false,
      colorValue: data['colorValue'] as int?,
      difficulty: data['difficulty'] != null
          ? HabitDifficulty.values.firstWhere(
              (e) => e.name == data['difficulty'],
              orElse: () => HabitDifficulty.medium,
            )
          : HabitDifficulty.medium,
      // TCC/Nudge fields with backward-compatible defaults
      difficultyLevel: data['difficultyLevel'] as int? ?? 3,
      targetMinutes: data['targetMinutes'] as int? ?? 20, // Matches level 3
      successRate7d: (data['successRate7d'] as num?)?.toDouble() ?? 0.0,
      optimalDays:
          (data['optimalDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      optimalTime: data['optimalTime'] != null
          ? TimeOfDay(
              hour: data['optimalTime']['hour'] as int,
              minute: data['optimalTime']['minute'] as int,
            )
          : null,
      consecutiveFailures: data['consecutiveFailures'] as int? ?? 0,
      failurePattern: data['failurePattern'] != null
          ? FailurePattern.values.firstWhere(
              (e) => e.name == data['failurePattern'],
              orElse: () => FailurePattern.inconsistent,
            )
          : null,
      abandonmentRisk: (data['abandonmentRisk'] as num?)?.toDouble() ?? 0.0,
      lastAdjustedAt: data['lastAdjustedAt'] != null
          ? (data['lastAdjustedAt'] as Timestamp).toDate()
          : null,
    );
  }

  static Map<String, dynamic> toFirestore(Habit habit) {
    return {
      'userId': habit.userId,
      'name': habit.name,
      'description': habit.description,
      'category': habit.category.name,
      'emoji': habit.emoji,
      'verse': habit.verse?.toJson(),
      'reminderTime': habit.reminderTime,
      'predefinedId': habit.predefinedId,
      'completedToday': habit.completedToday,
      'currentStreak': habit.currentStreak,
      'longestStreak': habit.longestStreak,
      'lastCompletedAt': habit.lastCompletedAt != null
          ? Timestamp.fromDate(habit.lastCompletedAt!)
          : null,
      'completionHistory': habit.completionHistory
          .map((date) => Timestamp.fromDate(date))
          .toList(),
      'createdAt': Timestamp.fromDate(habit.createdAt),
      'isArchived': habit.isArchived,
      'colorValue': habit.colorValue,
      'difficulty': habit.difficulty.name,
      // TCC/Nudge fields
      'difficultyLevel': habit.difficultyLevel,
      'targetMinutes': habit.targetMinutes,
      'successRate7d': habit.successRate7d,
      'optimalDays': habit.optimalDays,
      'optimalTime': habit.optimalTime != null
          ? {
              'hour': habit.optimalTime!.hour,
              'minute': habit.optimalTime!.minute,
            }
          : null,
      'consecutiveFailures': habit.consecutiveFailures,
      'failurePattern': habit.failurePattern?.name,
      'abandonmentRisk': habit.abandonmentRisk,
      'lastAdjustedAt': habit.lastAdjustedAt != null
          ? Timestamp.fromDate(habit.lastAdjustedAt!)
          : null,
    };
  }

  /// JSON serialization (for local storage, non-Firestore)
  static Habit fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: _migrateCategory(json['category']),
      emoji: json['emoji'] as String?,
      verse: json['verse'] != null
          ? VerseReference.fromJson(json['verse'] as Map<String, dynamic>)
          : null,
      reminderTime: json['reminderTime'] as String?,
      predefinedId: json['predefinedId'] as String?,
      completedToday: json['completedToday'] as bool? ?? false,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastCompletedAt: json['lastCompletedAt'] != null
          ? DateTime.parse(json['lastCompletedAt'] as String)
          : null,
      completionHistory:
          (json['completionHistory'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      isArchived: json['isArchived'] as bool? ?? false,
      colorValue: json['colorValue'] as int?,
      difficulty: json['difficulty'] != null
          ? HabitDifficulty.values.firstWhere(
              (e) => e.name == json['difficulty'],
              orElse: () => HabitDifficulty.medium,
            )
          : HabitDifficulty.medium,
      // TCC/Nudge fields with backward-compatible defaults
      difficultyLevel: json['difficultyLevel'] as int? ?? 3,
      targetMinutes: json['targetMinutes'] as int? ?? 20, // Matches level 3
      successRate7d: (json['successRate7d'] as num?)?.toDouble() ?? 0.0,
      optimalDays:
          (json['optimalDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      optimalTime: json['optimalTime'] != null
          ? TimeOfDay(
              hour: json['optimalTime']['hour'] as int,
              minute: json['optimalTime']['minute'] as int,
            )
          : null,
      consecutiveFailures: json['consecutiveFailures'] as int? ?? 0,
      failurePattern: json['failurePattern'] != null
          ? FailurePattern.values.firstWhere(
              (e) => e.name == json['failurePattern'],
              orElse: () => FailurePattern.inconsistent,
            )
          : null,
      abandonmentRisk: (json['abandonmentRisk'] as num?)?.toDouble() ?? 0.0,
      lastAdjustedAt: json['lastAdjustedAt'] != null
          ? DateTime.parse(json['lastAdjustedAt'] as String)
          : null,
    );
  }

  static Map<String, dynamic> toJson(Habit habit) {
    return {
      'id': habit.id,
      'userId': habit.userId,
      'name': habit.name,
      'description': habit.description,
      'category': habit.category.name,
      'emoji': habit.emoji,
      'verse': habit.verse?.toJson(),
      'reminderTime': habit.reminderTime,
      'predefinedId': habit.predefinedId,
      'completedToday': habit.completedToday,
      'currentStreak': habit.currentStreak,
      'longestStreak': habit.longestStreak,
      'lastCompletedAt': habit.lastCompletedAt?.toIso8601String(),
      'completionHistory': habit.completionHistory
          .map((date) => date.toIso8601String())
          .toList(),
      'createdAt': habit.createdAt.toIso8601String(),
      'isArchived': habit.isArchived,
      'colorValue': habit.colorValue,
      'difficulty': habit.difficulty.name,
      // TCC/Nudge fields
      'difficultyLevel': habit.difficultyLevel,
      'targetMinutes': habit.targetMinutes,
      'successRate7d': habit.successRate7d,
      'optimalDays': habit.optimalDays,
      'optimalTime': habit.optimalTime != null
          ? {
              'hour': habit.optimalTime!.hour,
              'minute': habit.optimalTime!.minute,
            }
          : null,
      'consecutiveFailures': habit.consecutiveFailures,
      'failurePattern': habit.failurePattern?.name,
      'abandonmentRisk': habit.abandonmentRisk,
      'lastAdjustedAt': habit.lastAdjustedAt?.toIso8601String(),
    };
  }
}
