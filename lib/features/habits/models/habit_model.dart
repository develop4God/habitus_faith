import 'package:cloud_firestore/cloud_firestore.dart';

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

class HabitModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final HabitCategory category;
  final bool completedToday;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedAt;
  final List<DateTime> completionHistory;
  final DateTime createdAt;
  final bool isArchived;

  HabitModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.category,
    this.completedToday = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedAt,
    this.completionHistory = const [],
    required this.createdAt,
    this.isArchived = false,
  });

  factory HabitModel.create({
    required String id,
    required String userId,
    required String name,
    required String description,
    HabitCategory category = HabitCategory.other,
  }) {
    return HabitModel(
      id: id,
      userId: userId,
      name: name,
      description: description,
      category: category,
      createdAt: DateTime.now(),
    );
  }

  factory HabitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HabitModel(
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

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'category': category.name,
      'completedToday': completedToday,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCompletedAt':
          lastCompletedAt != null ? Timestamp.fromDate(lastCompletedAt!) : null,
      'completionHistory': completionHistory
          .map((date) => Timestamp.fromDate(date))
          .toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'isArchived': isArchived,
    };
  }

  HabitModel completeToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if already completed today
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
    final newLongestStreak = newStreak > longestStreak ? newStreak : longestStreak;

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

  HabitModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    HabitCategory? category,
    bool? completedToday,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedAt,
    List<DateTime>? completionHistory,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
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
