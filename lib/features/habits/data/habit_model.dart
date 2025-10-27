import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/habit.dart';
import '../domain/models/verse_reference.dart';

/// Data model for Firestore serialization
class HabitModel {
  static Habit fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Habit(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      category: HabitCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => HabitCategory.other,
      ),
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
      completionHistory: (data['completionHistory'] as List<dynamic>?)
              ?.map((e) => (e as Timestamp).toDate())
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isArchived: data['isArchived'] as bool? ?? false,
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
    };
  }

  /// JSON serialization (for local storage, non-Firestore)
  static Habit fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: HabitCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => HabitCategory.other,
      ),
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
      completionHistory: (json['completionHistory'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      isArchived: json['isArchived'] as bool? ?? false,
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
    };
  }
}
