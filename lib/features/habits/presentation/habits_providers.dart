import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/habit.dart';
import '../domain/models/habit_notification.dart';
import '../data/storage/storage_providers.dart';
import '../../../core/services/notifications/notification_service.dart';

/// Repository provider with injectable ID generator
final habitsRepositoryProvider = jsonHabitsRepositoryProvider;

/// Stream provider for reading habits
final habitsStreamProvider = StreamProvider<List<Habit>>((ref) {
  final repository = ref.watch(habitsRepositoryProvider);
  return repository.watchHabits();
});

/// AsyncNotifier for habit mutations with error handling
class HabitsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Initial state - no loading needed
  }

  Future<void> addHabit({
    required String name,
    HabitCategory category = HabitCategory.mental,
    int? colorValue,
    HabitDifficulty difficulty = HabitDifficulty.medium,
    String? emoji,
  }) async {
    debugPrint('HabitsNotifier.addHabit: start -> name:$name');
    state = const AsyncLoading();

    final repository = ref.read(habitsRepositoryProvider);
    final result = await repository.createHabit(
      name: name,
      category: category,
      colorValue: colorValue,
      difficulty: difficulty,
      emoji: emoji,
    );

    result.fold(
      (failure) {
        debugPrint('HabitsNotifier.addHabit: failure -> $failure');
        state = AsyncError(failure, StackTrace.current);
      },
      (habit) {
        debugPrint('HabitsNotifier.addHabit: success -> ${habit.id}');
        state = const AsyncData(null);
      },
    );
  }

  Future<void> completeHabit(String habitId) async {
    debugPrint('HabitsNotifier.completeHabit: llamado para habitId=$habitId');
    state = const AsyncLoading();
    final repository = ref.read(habitsRepositoryProvider);
    final result = await repository.completeHabit(habitId);
    result.fold(
      (failure) {
        debugPrint('HabitsNotifier.completeHabit: error: $failure');
        state = AsyncError(failure, StackTrace.current);
      },
      (habit) {
        debugPrint(
            'HabitsNotifier.completeHabit: éxito, habit.completedToday=${habit.completedToday}');
        state = const AsyncData(null);
      },
    );
  }

  Future<void> deleteHabit(String habitId) async {
    debugPrint('HabitsNotifier.deleteHabit: start -> $habitId');
    state = const AsyncLoading();

    final repository = ref.read(habitsRepositoryProvider);
    final result = await repository.deleteHabit(habitId);

    result.fold(
      (failure) {
        debugPrint('HabitsNotifier.deleteHabit: failure -> $failure');
        state = AsyncError(failure, StackTrace.current);
      },
      (_) {
        debugPrint('HabitsNotifier.deleteHabit: success -> $habitId');
        state = const AsyncData(null);
      },
    );
  }

  Future<void> updateHabit({
    required String habitId,
    String? name,
    HabitCategory? category,
    String? emoji,
    int? colorValue,
    HabitDifficulty? difficulty,
    HabitNotificationSettings? notificationSettings,
    HabitRecurrence? recurrence,
    List<Subtask>? subtasks,
  }) async {
    debugPrint('HabitsNotifier.updateHabit: start -> $habitId');
    state = const AsyncLoading();

    final repository = ref.read(habitsRepositoryProvider);
    final result = await repository.updateHabit(
      habitId: habitId,
      name: name,
      category: category,
      emoji: emoji,
      colorValue: colorValue,
      difficulty: difficulty,
      notificationSettings: notificationSettings,
      recurrence: recurrence,
      subtasks: subtasks,
    );

    result.fold(
      (failure) {
        debugPrint('HabitsNotifier.updateHabit: failure -> $failure');
        state = AsyncError(failure, StackTrace.current);
      },
      (habit) async {
        debugPrint('HabitsNotifier.updateHabit: success -> ${habit.id}');
        state = const AsyncData(null);
        // Schedule or cancel notification
        if (notificationSettings != null &&
            notificationSettings.timing == NotificationTiming.atEventTime &&
            notificationSettings.eventTime != null) {
          await NotificationService().scheduleHabitNotification(
            habitId: habit.id,
            habitName: habit.name,
            eventTime: notificationSettings.eventTime!,
          );
        } else if (notificationSettings == null) {
          await NotificationService().cancelHabitNotification(habit.id);
        }
      },
    );
  }

  Future<void> uncheckHabit(String habitId) async {
    debugPrint('HabitsNotifier.uncheckHabit: llamado para habitId=$habitId');
    state = const AsyncLoading();
    final repository = ref.read(habitsRepositoryProvider);
    final result = await repository.uncheckHabit(habitId);
    result.fold(
      (failure) {
        debugPrint('HabitsNotifier.uncheckHabit: error: $failure');
        state = AsyncError(failure, StackTrace.current);
      },
      (habit) {
        debugPrint(
            'HabitsNotifier.uncheckHabit: éxito, habit.completedToday=${habit.completedToday}');
        state = const AsyncData(null);
      },
    );
  }

  Future<void> skipHabit(String habitId) async {
    debugPrint('HabitsNotifier.skipHabit: llamado para habitId=$habitId');
    state = const AsyncLoading();
    final repository = ref.read(habitsRepositoryProvider);
    final result = await repository.skipHabit(habitId);
    result.fold(
      (failure) {
        debugPrint('HabitsNotifier.skipHabit: error: $failure');
        state = AsyncError(failure, StackTrace.current);
      },
      (habit) {
        debugPrint(
            'HabitsNotifier.skipHabit: éxito, habit.dailyStatus=${habit.dailyStatus}');
        state = const AsyncData(null);
      },
    );
  }

  Future<void> failHabit(String habitId) async {
    debugPrint('HabitsNotifier.failHabit: llamado para habitId=$habitId');
    state = const AsyncLoading();
    final repository = ref.read(habitsRepositoryProvider);
    final result = await repository.failHabit(habitId);
    result.fold(
      (failure) {
        debugPrint('HabitsNotifier.failHabit: error: $failure');
        state = AsyncError(failure, StackTrace.current);
      },
      (habit) {
        debugPrint(
            'HabitsNotifier.failHabit: éxito, habit.dailyStatus=${habit.dailyStatus}');
        state = const AsyncData(null);
      },
    );
  }

  Future<void> reorderHabits(List<String> habitIds) async {
    debugPrint('HabitsNotifier.reorderHabits: reordering ${habitIds.length} habits');
    state = const AsyncLoading();
    final repository = ref.read(habitsRepositoryProvider);
    final result = await repository.reorderHabits(habitIds);
    result.fold(
      (failure) {
        debugPrint('HabitsNotifier.reorderHabits: error: $failure');
        state = AsyncError(failure, StackTrace.current);
      },
      (_) {
        debugPrint('HabitsNotifier.reorderHabits: éxito');
        state = const AsyncData(null);
      },
    );
  }
}

final habitsNotifierProvider = AsyncNotifierProvider<HabitsNotifier, void>(() {
  return HabitsNotifier();
});
