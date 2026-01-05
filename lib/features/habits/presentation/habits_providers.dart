import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/habit.dart';
import '../data/storage/storage_providers.dart';

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
  }) async {
    state = const AsyncLoading();

    final repository = ref.read(habitsRepositoryProvider);
    final result = await repository.createHabit(
      name: name,
      category: category,
    );

    result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
      },
      (habit) {
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
    state = const AsyncLoading();

    final repository = ref.read(habitsRepositoryProvider);
    final result = await repository.deleteHabit(habitId);

    result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
      },
      (_) {
        state = const AsyncData(null);
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
}

final habitsNotifierProvider = AsyncNotifierProvider<HabitsNotifier, void>(() {
  return HabitsNotifier();
});
