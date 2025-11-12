import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/domain/models/habit_notification.dart';
import '../features/habits/data/storage/storage_providers.dart';
import 'habits_page_ui.dart'; // Nuevo import

// New providers for JSON-based habits
final jsonHabitsStreamProvider = StreamProvider<List<Habit>>((ref) {
  final repository = ref.watch(jsonHabitsRepositoryProvider);
  debugPrint('jsonHabitsStreamProvider: repository watched -> $repository');
  final stream = repository.watchHabits().map((list) {
    debugPrint(
      'jsonHabitsStreamProvider: stream emitted ${list.length} habits',
    );
    return list;
  }).handleError((e, st) {
    debugPrint('jsonHabitsStreamProvider: stream error -> $e');
  });
  return stream;
});

class JsonHabitsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  JsonHabitsNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> completeHabit(String habitId) async {
    debugPrint('JsonHabitsNotifier.completeHabit: start -> $habitId');
    state = const AsyncLoading();

    final repository = ref.read(jsonHabitsRepositoryProvider);
    final result = await repository.completeHabit(habitId);

    result.fold(
      (failure) {
        debugPrint('JsonHabitsNotifier.completeHabit: failure -> $failure');
        state = AsyncError(failure, StackTrace.current);
      },
      (habit) {
        debugPrint('JsonHabitsNotifier.completeHabit: success -> ${habit.id}');
        state = const AsyncData(null);
      },
    );
  }

  Future<void> deleteHabit(String habitId) async {
    debugPrint('JsonHabitsNotifier.deleteHabit: start -> $habitId');
    state = const AsyncLoading();

    final repository = ref.read(jsonHabitsRepositoryProvider);
    final result = await repository.deleteHabit(habitId);

    result.fold(
      (failure) {
        debugPrint('JsonHabitsNotifier.deleteHabit: failure -> $failure');
        state = AsyncError(failure, StackTrace.current);
      },
      (_) {
        debugPrint('JsonHabitsNotifier.deleteHabit: success -> $habitId');
        state = const AsyncData(null);
      },
    );
  }

  Future<void> addHabit({
    required String name,
    HabitCategory category = HabitCategory.mental,
    int? colorValue,
    HabitDifficulty difficulty = HabitDifficulty.medium,
    String? emoji,
  }) async {
    debugPrint(
      'JsonHabitsNotifier.addHabit: start -> name:$name',
    );
    state = const AsyncLoading();

    final repository = ref.read(jsonHabitsRepositoryProvider);
    final result = await repository.createHabit(
      name: name,
      category: category,
      colorValue: colorValue,
      difficulty: difficulty,
      emoji: emoji, // <-- Asegura que el emoji se pase al crear el hábito
    );

    result.fold(
      (failure) {
        debugPrint('JsonHabitsNotifier.addHabit: failure -> $failure');
        state = AsyncError(failure, StackTrace.current);
      },
      (habit) {
        debugPrint('JsonHabitsNotifier.addHabit: success -> ${habit.id}');
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
    debugPrint('JsonHabitsNotifier.updateHabit: start -> $habitId');
    state = const AsyncLoading();

    final repository = ref.read(jsonHabitsRepositoryProvider);
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
        debugPrint('JsonHabitsNotifier.updateHabit: failure -> $failure');
        state = AsyncError(failure, StackTrace.current);
      },
      (habit) {
        debugPrint('JsonHabitsNotifier.updateHabit: success -> ${habit.id}');
        state = const AsyncData(null);
      },
    );
  }

  Future<void> uncheckHabit(String habitId) async {
    debugPrint('JsonHabitsNotifier.uncheckHabit: start -> $habitId');
    state = const AsyncLoading();

    final repository = ref.read(jsonHabitsRepositoryProvider);
    final result = await repository.uncheckHabit(habitId);

    result.fold(
      (failure) {
        debugPrint('JsonHabitsNotifier.uncheckHabit: failure -> $failure');
        state = AsyncError(failure, StackTrace.current);
      },
      (habit) {
        debugPrint('JsonHabitsNotifier.uncheckHabit: success -> ${habit.id}');
        state = const AsyncData(null);
      },
    );
  }
}

final jsonHabitsNotifierProvider =
    StateNotifierProvider<JsonHabitsNotifier, AsyncValue<void>>((ref) {
  return JsonHabitsNotifier(ref);
});

class HabitsPage extends ConsumerStatefulWidget {
  const HabitsPage({super.key});

  @override
  ConsumerState<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends ConsumerState<HabitsPage> {
  HabitCategory? _categoryFilter;

  List<Habit> _filterHabits(List<Habit> habits) {
    debugPrint('HabitsPage._filterHabits: recibidos ${habits.length} hábitos');
    if (_categoryFilter == null) {
      debugPrint('HabitsPage._filterHabits: sin filtro, retornando todos');
      return habits;
    }
    final filtrados =
        habits.where((h) => h.category == _categoryFilter).toList();
    debugPrint(
        'HabitsPage._filterHabits: filtrados ${filtrados.length} hábitos');
    return filtrados;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final habitsAsync = ref.watch(jsonHabitsStreamProvider);
        debugPrint('HabitsPage.build: estado de habitsAsync: $habitsAsync');
        return habitsAsync.when(
          data: (habits) {
            debugPrint(
                'HabitsPage.build: data recibida con ${habits.length} hábitos');
            final filtrados = _filterHabits(habits);
            debugPrint(
                'HabitsPage.build: mostrando ${filtrados.length} hábitos en el calendario');
            return ModernWeeklyCalendar(
              habits: filtrados,
              initialDate: DateTime.now(),
            );
          },
          loading: () {
            debugPrint('HabitsPage.build: cargando hábitos...');
            return const Center(child: CircularProgressIndicator());
          },
          error: (e, st) {
            debugPrint('HabitsPage.build: error cargando hábitos: $e');
            return const Center(child: Text('Error cargando hábitos'));
          },
        );
      },
    );
  }
}
