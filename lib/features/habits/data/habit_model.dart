import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/habit.dart';

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
}
