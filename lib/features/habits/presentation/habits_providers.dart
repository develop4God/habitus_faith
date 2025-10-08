import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/firestore_provider.dart';
import '../domain/habit.dart';
import '../domain/habits_repository.dart';
import '../domain/failures.dart';
import '../data/firestore_habits_repository.dart';

/// Repository provider with injectable ID generator
final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final userId = ref.watch(userIdProvider);

  return FirestoreHabitsRepository(
    firestore: firestore,
    userId: userId,
    idGenerator: () => const Uuid().v4(),
  );
});

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
    required String description,
    HabitCategory category = HabitCategory.other,
  }) async {
    state = const AsyncLoading();

    final repository = ref.read(habitsRepositoryProvider);
    final result = await repository.createHabit(
      name: name,
      description: description,
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
    state = const AsyncLoading();

    final repository = ref.read(habitsRepositoryProvider);
    final result = await repository.completeHabit(habitId);

    result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
      },
      (habit) {
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
}

final habitsNotifierProvider = AsyncNotifierProvider<HabitsNotifier, void>(() {
  return HabitsNotifier();
});
