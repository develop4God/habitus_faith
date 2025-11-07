import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/data/storage/storage_providers.dart';
import 'habits_page_ui.dart'; // Nuevo import

// New providers for JSON-based habits
final jsonHabitsStreamProvider = StreamProvider<List<Habit>>((ref) {
  final repository = ref.watch(jsonHabitsRepositoryProvider);
  debugPrint('jsonHabitsStreamProvider: repository watched -> $repository');
  final stream = repository.watchHabits().map((list) {
    debugPrint(
        'jsonHabitsStreamProvider: stream emitted ${list.length} habits');
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
    required String description,
    HabitCategory category = HabitCategory.mental,
    int? colorValue,
    HabitDifficulty difficulty = HabitDifficulty.medium,
    String? emoji,
  }) async {
    debugPrint(
        'JsonHabitsNotifier.addHabit: start -> name:$name desc:$description');
    state = const AsyncLoading();

    final repository = ref.read(jsonHabitsRepositoryProvider);
    final result = await repository.createHabit(
      name: name,
      description: description,
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
    String? description,
    HabitCategory? category,
    String? emoji,
    int? colorValue,
    HabitDifficulty? difficulty,
  }) async {
    debugPrint('JsonHabitsNotifier.updateHabit: start -> $habitId');
    state = const AsyncLoading();

    final repository = ref.read(jsonHabitsRepositoryProvider);
    final result = await repository.updateHabit(
      habitId: habitId,
      name: name,
      description: description,
      category: category,
      emoji: emoji,
      colorValue: colorValue,
      difficulty: difficulty,
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
  final Set<String> _selectedHabits = {};

  void _clearSelection() {
    setState(() {
      _selectedHabits.clear();
    });
  }

  void _selectAll(List<Habit> habits) {
    setState(() {
      _selectedHabits.addAll(habits.map((h) => h.id));
    });
  }

  Future<void> _deleteSelected(BuildContext context, WidgetRef ref) async {
    for (final habitId in _selectedHabits) {
      await ref.read(jsonHabitsNotifierProvider.notifier).deleteHabit(habitId);
    }
    _clearSelection();
  }

  Future<void> _duplicateHabit(BuildContext context, WidgetRef ref, Habit habit) async {
    await ref.read(jsonHabitsNotifierProvider.notifier).addHabit(
      name: "${habit.name} (copy)",
      description: habit.description,
      category: habit.category,
      colorValue: habit.colorValue,
      difficulty: habit.difficulty,
      emoji: habit.emoji,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hábito duplicado")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return HabitsPageUI(
      selectedHabits: _selectedHabits,
      clearSelection: _clearSelection,
      selectAll: _selectAll,
      deleteSelected: _deleteSelected,
      duplicateHabit: _duplicateHabit,
    );
  }
}

