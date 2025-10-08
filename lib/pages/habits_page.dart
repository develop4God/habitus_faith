import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/domain/failures.dart';
import '../features/habits/presentation/habits_providers.dart';

class HabitsPage extends ConsumerWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStreamProvider);
    final notifierState = ref.watch(habitsNotifierProvider);

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
        title: const Text('Mis hábitos'),
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return const Center(
              child: Text(
                'No tienes hábitos',
                style: TextStyle(fontSize: 18, color: Colors.grey),
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
                    // Prevent unchecking - can only mark complete
                    onChanged: habit.completedToday
                        ? null
                        : (value) async {
                            if (value == true) {
                              await ref
                                  .read(habitsNotifierProvider.notifier)
                                  .completeHabit(habit.id);
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar hábito'),
        content: Text('¿Estás seguro de eliminar "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(habitsNotifierProvider.notifier)
                  .deleteHabit(habit.id);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
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
      builder: (dialogContext) => AlertDialog(
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
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            key: const Key('confirm_add_habit_button'),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty && descCtrl.text.isNotEmpty) {
                await ref.read(habitsNotifierProvider.notifier).addHabit(
                      name: nameCtrl.text,
                      description: descCtrl.text,
                    );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    ).then((_) {
      // Dispose controllers after dialog is closed
      nameCtrl.dispose();
      descCtrl.dispose();
    });
  }
}
