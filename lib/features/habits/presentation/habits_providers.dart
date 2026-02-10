import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/habit.dart';
import '../domain/models/habit_notification.dart';
import '../data/storage/storage_providers.dart';
import '../../../core/services/notifications/notification_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../gamification/presentation/gamification_providers.dart';

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
      (habit) async {
        debugPrint(
          'HabitsNotifier.completeHabit: éxito, habit.completedToday=${habit.completedToday}',
        );
        state = const AsyncData(null);

        // Award faith points for completing the habit
        final userId = ref.read(userIdProvider);
        if (userId != null) {
          try {
            final faithPointsService = ref.read(faithPointsServiceProvider);
            final awardResult = await faithPointsService.awardPointsForHabit(
              userId: userId,
              habitId: habit.id,
              habitName: habit.name,
              difficultyLevel: habit.difficultyLevel,
              isSpiritual: habit.category == HabitCategory.spiritual,
              currentStreak: habit.currentStreak,
            );

            debugPrint(
              'Faith points awarded: ${awardResult.pointsAwarded}, '
              'Total: ${awardResult.newTotalPoints}, '
              'Stage: ${awardResult.currentStage.displayName}',
            );

            // Check and unlock badges
            if (awardResult.leveledUp) {
              final badgeService = ref.read(badgeServiceProvider);
              final newBadges = await badgeService.checkAndUnlockBadges(userId);
              if (newBadges.isNotEmpty) {
                debugPrint('New badges unlocked: ${newBadges.length}');
              }
            }
          } catch (e) {
            debugPrint('Error awarding faith points: $e');
            // Don't fail the habit completion if gamification fails
          }
        }
      },
    );
  }

  Future<void> updateHabitNote(String habitId, String? note) async {
    debugPrint('HabitsNotifier.updateHabitNote: habitId=$habitId');
    // We don't necessarily want to set state to Loading here to avoid flickering
    // since this might be called frequently while typing.
    final repository = ref.read(habitsRepositoryProvider);
    await repository.updateHabitNote(habitId, note);
    // State remains Data(null) but the repository will emit new habits via watchHabits()
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
          'HabitsNotifier.uncheckHabit: éxito, habit.completedToday=${habit.completedToday}',
        );
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
          'HabitsNotifier.skipHabit: éxito, habit.dailyStatus=${habit.dailyStatus}',
        );
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
          'HabitsNotifier.failHabit: éxito, habit.dailyStatus=${habit.dailyStatus}',
        );
        state = const AsyncData(null);
      },
    );
  }

  Future<void> reorderHabits(List<String> habitIds) async {
    debugPrint(
      'HabitsNotifier.reorderHabits: reordering ${habitIds.length} habits',
    );
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

  Future<void> duplicateHabit(String habitId) async {
    debugPrint('HabitsNotifier.duplicateHabit: start -> $habitId');
    state = const AsyncLoading();

    final repository = ref.read(habitsRepositoryProvider);

    try {
      // Try a dynamic invocation of getHabits(); if it fails, fall back to watchHabits().first
      List<Habit> habits;
      try {
        habits = await (repository as dynamic).getHabits();
      } catch (_) {
        habits = await repository.watchHabits().first;
      }
      debugPrint('HabitsNotifier.duplicateHabit: loaded ${habits.length} habits from repository');

      Habit? habitToDuplicate;
      for (final h in habits) {
        if (h.id == habitId) {
          habitToDuplicate = h;
          break;
        }
      }

      if (habitToDuplicate == null) {
        debugPrint('HabitsNotifier.duplicateHabit: habit not found -> $habitId');
        // Nothing to do - keep UI stable
        state = const AsyncData(null);
        return;
      }

      // Create a new habit with the same properties but a new ID
      final result = await repository.createHabit(
        name: '${habitToDuplicate.name} (Copy)',
        category: habitToDuplicate.category,
        emoji: habitToDuplicate.emoji,
        colorValue: habitToDuplicate.colorValue,
        difficulty: habitToDuplicate.difficulty,
        notificationSettings: habitToDuplicate.notificationSettings,
        targetMinutes: habitToDuplicate.targetMinutes,
      );

      result.fold(
        (failure) {
          debugPrint('HabitsNotifier.duplicateHabit: failure -> $failure');
          state = AsyncError(failure, StackTrace.current);
        },
        (habit) {
          debugPrint('HabitsNotifier.duplicateHabit: success -> ${habit.id}');
          state = const AsyncData(null);
        },
      );
    } catch (e, st) {
      debugPrint('HabitsNotifier.duplicateHabit: exception -> $e');
      state = AsyncError(e, st);
    }
  }

  /// Duplicate a habit using the provided Habit object directly.
  /// This is useful to avoid timing/race issues when the in-memory
  /// stream may not yet reflect the latest storage state.
  Future<void> duplicateHabitFromData(Habit habitToDuplicate) async {
    debugPrint('HabitsNotifier.duplicateHabitFromData: start -> ${habitToDuplicate.id}');
    state = const AsyncLoading();

    final repository = ref.read(habitsRepositoryProvider);

    try {
      final result = await repository.createHabit(
        name: '${habitToDuplicate.name} (Copy)',
        category: habitToDuplicate.category,
        emoji: habitToDuplicate.emoji,
        colorValue: habitToDuplicate.colorValue,
        difficulty: habitToDuplicate.difficulty,
        notificationSettings: habitToDuplicate.notificationSettings,
        targetMinutes: habitToDuplicate.targetMinutes,
      );

      result.fold(
        (failure) {
          debugPrint('HabitsNotifier.duplicateHabitFromData: failure -> $failure');
          state = AsyncError(failure, StackTrace.current);
        },
        (habit) {
          debugPrint('HabitsNotifier.duplicateHabitFromData: success -> ${habit.id}');
          state = const AsyncData(null);
        },
      );
    } catch (e, st) {
      debugPrint('HabitsNotifier.duplicateHabitFromData: exception -> $e');
      state = AsyncError(e, st);
    }
  }
}

final habitsNotifierProvider = AsyncNotifierProvider<HabitsNotifier, void>(() {
  return HabitsNotifier();
});
