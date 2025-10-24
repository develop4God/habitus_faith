import 'models/verse_reference.dart';

enum HabitCategory {
  prayer,
  bibleReading,
  service,
  gratitude,
  other;

  String get displayName {
    switch (this) {
      case HabitCategory.prayer:
        return 'Oración';
      case HabitCategory.bibleReading:
        return 'Lectura Bíblica';
      case HabitCategory.service:
        return 'Servicio';
      case HabitCategory.gratitude:
        return 'Gratitud';
      case HabitCategory.other:
        return 'Otro';
    }
  }
}

/// Pure domain entity - no Firestore dependencies
class Habit {
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
  });

  factory Habit.create({
    required String id,
    required String userId,
    required String name,
    required String description,
    HabitCategory category = HabitCategory.other,
    String? emoji,
    VerseReference? verse,
    String? reminderTime,
    String? predefinedId,
  }) {
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
      createdAt: DateTime.now(),
    );
  }

  /// Business logic: Complete habit for today
  Habit completeToday() {
    final now = DateTime.now();
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

    return copyWith(
      completedToday: true,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastCompletedAt: now,
      completionHistory: newHistory,
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
    );
  }
}
