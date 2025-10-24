import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/presentation/habits_providers.dart';
import '../features/habits/domain/failures.dart';
import '../l10n/app_localizations.dart';

/// DEPRECATED: Use HabitsPageNew instead
/// This page is kept for backward compatibility but will be removed
@Deprecated('Use HabitsPageNew from habits_page_new.dart instead')
class HabitsPage extends ConsumerWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final habitsAsync = ref.watch(habitsStreamProvider);

    // Listen for errors
    ref.listen<AsyncValue<void>>(habitsNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          if (error is HabitFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myHabits),
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Text(
                l10n.noHabits,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return Card(
                key: Key('habit_card_${habit.id}'),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Checkbox(
                    key: Key('habit_checkbox_${habit.id}'),
                    value: habit.completedToday,
                    onChanged: habit.completedToday
                        ? null  // Deshabilita si ya está completado
                        : (value) async {
                      if (value == true) {
                        final notifier = ref.read(habitsNotifierProvider.notifier);
                        await notifier.completeHabit(habit.id);
                      }
                    },
                  ),
                  title: Text(habit.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.description),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department,
                              size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            'Racha: ${habit.currentStreak} días | Mejor: ${habit.longestStreak}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    key: Key('habit_delete_${habit.id}'),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmation(context, ref, habit);
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_habit_fab'),
        onPressed: () {
          _showAddHabitDialog(context, ref);
        },
        tooltip: 'Agregar nuevo hábito',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar hábito'),
        content: Text('¿Estás seguro de eliminar "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final notifier = ref.read(habitsNotifierProvider.notifier);
              await notifier.deleteHabit(habit.id);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
  void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar hábito'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('habit_name_input'),
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              key: const Key('habit_description_input'),
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            key: const Key('confirm_add_habit_button'),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty && descCtrl.text.isNotEmpty) {
                final notifier = ref.read(habitsNotifierProvider.notifier);
                await notifier.addHabit(
                  name: nameCtrl.text,
                  description: descCtrl.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    ).whenComplete(() {
      // ✅ AGREGAR ESTO - Liberar recursos
      nameCtrl.dispose();
      descCtrl.dispose();
    });
  }
}
