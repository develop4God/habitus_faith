// Ejemplo de uso del UnifiedHabitList en cualquier página

/*import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/unified_habit_list.dart';
import '../features/habits/presentation/habits_providers.dart';

class ExampleHabitUsagePage extends ConsumerWidget {
  const ExampleHabitUsagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener los hábitos desde el provider
    final habitsAsync = ref.watch(habitsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Hábitos'),
      ),
      body: habitsAsync.when(
        data: (habits) {
          // Usar el widget unificado
          return UnifiedHabitList(
            habits: habits,

            // Callback para marcar como completado
            onComplete: (habitId) async {
              final notifier = ref.read(habitsNotifierProvider.notifier);
              await notifier.completeHabit(habitId);
            },

            // Callback para desmarcar
            onUncheck: (habitId) async {
              final notifier = ref.read(habitsNotifierProvider.notifier);
              await notifier.uncheckHabit(habitId);
            },

            // Callback para eliminar
            onDelete: (habitId) async {
              final notifier = ref.read(habitsNotifierProvider.notifier);
              await notifier.deleteHabit(habitId);
            },

            // Callback opcional para editar
            onEdit: (habit) async {
              // Implementar lógica de edición
              // Por ejemplo, abrir un diálogo de edición
              final l10n = AppLocalizations.of(context)!;
              await showDialog(
                context: context,
                builder: (ctx) => EditHabitDialog(
                  l10n: l10n,
                  habit: habit,
                ),
              );
            },

            // Mostrar hint de swipe (opcional)
            showSwipeHint: true, // false por defecto
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

// EJEMPLO: Filtrar hábitos antes de mostrarlos
class FilteredHabitListExample extends ConsumerWidget {
  final HabitCategory? categoryFilter;

  const FilteredHabitListExample({
    super.key,
    this.categoryFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStreamProvider);

    return habitsAsync.when(
      data: (habits) {
        // Filtrar hábitos por categoría si es necesario
        final filteredHabits = categoryFilter != null
            ? habits.where((h) => h.category == categoryFilter).toList()
            : habits;

        // Ordenar hábitos como prefieras
        final sortedHabits = List<Habit>.from(filteredHabits)
          ..sort((a, b) => a.name.compareTo(b.name));

        return UnifiedHabitList(
          habits: sortedHabits,
          onComplete: (habitId) async {
            final notifier = ref.read(habitsNotifierProvider.notifier);
            await notifier.completeHabit(habitId);
          },
          onUncheck: (habitId) async {
            final notifier = ref.read(habitsNotifierProvider.notifier);
            await notifier.uncheckHabit(habitId);
          },
          onDelete: (habitId) async {
            final notifier = ref.read(habitsNotifierProvider.notifier);
            await notifier.deleteHabit(habitId);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

// EJEMPLO: Mostrar solo hábitos incompletos
class IncompleteHabitsExample extends ConsumerWidget {
  const IncompleteHabitsExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStreamProvider);

    return habitsAsync.when(
      data: (habits) {
        // Filtrar solo hábitos no completados
        final incompleteHabits = habits
            .where((h) => !h.completedToday)
            .toList();

        return UnifiedHabitList(
          habits: incompleteHabits,
          onComplete: (habitId) async {
            final notifier = ref.read(habitsNotifierProvider.notifier);
            await notifier.completeHabit(habitId);
          },
          onUncheck: (habitId) async {
            final notifier = ref.read(habitsNotifierProvider.notifier);
            await notifier.uncheckHabit(habitId);
          },
          onDelete: (habitId) async {
            final notifier = ref.read(habitsNotifierProvider.notifier);
            await notifier.deleteHabit(habitId);
          },
          showSwipeHint: incompleteHabits.isNotEmpty,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
*/
