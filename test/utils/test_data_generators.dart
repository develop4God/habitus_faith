import 'package:habitus_faith/features/habits/domain/habit.dart';

/// Test data generators focused on real user behavior scenarios
class TestDataGenerators {
  /// Creates a habit with realistic defaults for a new user
  static Habit createTestHabit({
    String? id,
    String? userId,
    String title = 'Morning Prayer',
    HabitCategory category = HabitCategory.spiritual,
    int difficultyLevel = 2,
    int streakDays = 0,
    bool isCompleted = false,
    DateTime? createdAt,
    DateTime? lastCompletedAt,
    List<DateTime>? completionHistory,
  }) {
    final habit = Habit.create(
      id: id ?? 'habit_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId ?? 'test_user_123',
      name: title,
      category: category,
      difficultyLevel: difficultyLevel,
    );

    // Apply additional properties via copyWith if they differ from defaults
    if (streakDays > 0 ||
        isCompleted ||
        lastCompletedAt != null ||
        (completionHistory != null && completionHistory.isNotEmpty)) {
      return habit.copyWith(
        currentStreak: streakDays,
        longestStreak: streakDays,
        completedToday: isCompleted,
        lastCompletedAt: lastCompletedAt,
        completionHistory: completionHistory ?? [],
        createdAt: createdAt,
      );
    }

    if (createdAt != null) {
      return habit.copyWith(createdAt: createdAt);
    }

    return habit;
  }

  /// Creates a habit with a consistent streak (user completing daily)
  static Habit createHabitWithStreak({
    required int days,
    String? id,
    String title = 'Daily Bible Reading',
  }) {
    final now = DateTime.now();
    final completionHistory = List.generate(
      days,
      (i) => now.subtract(Duration(days: days - i - 1)),
    );

    final baseHabit = createTestHabit(
      id: id,
      title: title,
    );

    return baseHabit.copyWith(
      currentStreak: days,
      longestStreak: days,
      lastCompletedAt: now,
      completionHistory: completionHistory,
      completedToday: true,
    );
  }

  /// Creates a habit that was abandoned (common user behavior)
  static Habit createAbandonedHabit({
    String? id,
    int daysSinceLastCompletion = 7,
  }) {
    final lastCompleted =
        DateTime.now().subtract(Duration(days: daysSinceLastCompletion));

    final baseHabit = createTestHabit(
      id: id,
      title: 'Abandoned Exercise Habit',
    );

    return baseHabit.copyWith(
      currentStreak: 0,
      lastCompletedAt: lastCompleted,
      completionHistory: [lastCompleted],
      completedToday: false,
    );
  }

  /// Creates a habit with intermittent completion (realistic user behavior)
  static Habit createIntermittentHabit({
    String? id,
    List<int> completionDaysAgo = const [1, 3, 5, 8, 10],
  }) {
    final now = DateTime.now();
    final completionHistory = completionDaysAgo
        .map((daysAgo) => now.subtract(Duration(days: daysAgo)))
        .toList();

    final baseHabit = createTestHabit(
      id: id,
      title: 'Occasional Meditation',
    );

    return baseHabit.copyWith(
      currentStreak: 0,
      lastCompletedAt: completionHistory.first,
      completionHistory: completionHistory,
      completedToday: false,
    );
  }

  /// Creates user data for Firestore tests
  static Map<String, dynamic> createTestUserData({
    String? uid,
    String? fcmToken,
    DateTime? lastLogin,
    Map<String, dynamic>? notificationSettings,
  }) {
    return {
      'uid': uid ?? 'test_user_123',
      'fcmToken': fcmToken,
      'lastLogin': (lastLogin ?? DateTime.now()).toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'notificationSettings': notificationSettings ??
          {
            'dailyReminder': true,
            'habitReminders': true,
            'nudgeNotifications': true,
          },
    };
  }

  /// Creates notification data that mirrors real FCM payloads
  static Map<String, dynamic> createNotificationPayload({
    required String habitId,
    required String habitTitle,
    String type = 'habit_reminder',
  }) {
    return {
      'data': {
        'habitId': habitId,
        'habitTitle': habitTitle,
        'type': type,
        'timestamp': DateTime.now().toIso8601String(),
      },
      'notification': {
        'title': 'Time for: $habitTitle',
        'body': 'Keep your streak going!',
      },
    };
  }

  /// Creates ML prediction features based on real habit data
  static Map<String, dynamic> createMLFeatures({
    required String habitId,
    int streakDays = 0,
    double completionRate = 0.5,
    int daysSinceCreated = 7,
    int missedDays = 3,
    int difficultyLevel = 2,
  }) {
    return {
      'habitId': habitId,
      'streakDays': streakDays,
      'completionRate': completionRate,
      'daysSinceCreated': daysSinceCreated,
      'missedDays': missedDays,
      'difficultyLevel': difficultyLevel,
      'daysSinceLastCompletion': missedDays,
      'averageCompletionTime': 8.5, // hours (morning routine)
      'weekdayCompletionRate': 0.6,
      'weekendCompletionRate': 0.4,
    };
  }

  /// Creates a list of habits representing a realistic user's habit list
  static List<Habit> createRealisticHabitList({
    int activeHabits = 3,
    int strugglingHabits = 2,
    int abandonedHabits = 1,
  }) {
    final habits = <Habit>[];

    // Active habits with good streaks
    for (int i = 0; i < activeHabits; i++) {
      habits.add(createHabitWithStreak(
        days: 7 + i * 3,
        title: 'Active Habit ${i + 1}',
      ));
    }

    // Struggling habits with intermittent completion
    for (int i = 0; i < strugglingHabits; i++) {
      final baseHabit = createTestHabit(
        title: 'Struggling Habit ${i + 1}',
      );
      habits.add(createIntermittentHabit(
        id: baseHabit.id,
        completionDaysAgo: [1, 4, 7, 11, 15],
      ));
    }

    // Abandoned habits
    for (int i = 0; i < abandonedHabits; i++) {
      habits.add(createAbandonedHabit(
        daysSinceLastCompletion: 10 + i * 5,
      ));
    }

    return habits;
  }
}
