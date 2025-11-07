import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/data/storage/storage_providers.dart';
import '../features/habits/domain/failures.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/domain/models/display_mode.dart';
import '../features/habits/presentation/onboarding/display_mode_provider.dart';
import '../features/habits/presentation/widgets/habit_card/compact_habit_card.dart';
import '../features/habits/presentation/widgets/habit_card/advanced_habit_card.dart';
import '../core/providers/ml_providers.dart';
import '../l10n/app_localizations.dart';
import '../widgets/add_habit_discovery_dialog.dart';
import 'habits_page.dart';
import 'edit_habit_dialog.dart';

class HabitsPageUI extends ConsumerWidget {
  final Set<String> selectedHabits;
  final VoidCallback clearSelection;
  final void Function(List<Habit>) selectAll;
  final Future<void> Function(BuildContext, WidgetRef) deleteSelected;
  final Future<void> Function(BuildContext, WidgetRef, Habit) duplicateHabit;

  const HabitsPageUI({
    super.key,
    required this.selectedHabits,
    required this.clearSelection,
    required this.selectAll,
    required this.deleteSelected,
    required this.duplicateHabit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final habitsAsync = ref.watch(jsonHabitsStreamProvider);

    ref.listen<AsyncValue<void>>(jsonHabitsNotifierProvider, (previous, next) {
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
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        title: Text(l10n.myHabits),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xff1a202c),
        actions: [
          habitsAsync.when(
            data: (habits) {
              if (habits.isEmpty) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'select_all') {
                    selectAll(habits);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'select_all',
                    child: Row(
                      children: [
                        const Icon(Icons.select_all, size: 20),
                        const SizedBox(width: 8),
                        Text(l10n.selectAll),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noHabits,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          final displayMode = ref.watch(displayModeProvider);

          // Mostrar todos los hábitos como lista plana, sin categorías
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 20),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swipe, color: Color(0xff6366f1)),
                        SizedBox(width: 8),
                        Text(
                          "Desliza a la izquierda para eliminar o a la derecha para duplicar",
                          style: TextStyle(
                            color: Color(0xff6366f1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (selectedHabits.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    color: Colors.blue.shade50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text('${selectedHabits.length} seleccionados'),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Eliminar seleccionados',
                              onPressed: () => deleteSelected(context, ref),
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear),
                              tooltip: 'Limpiar selección',
                              onPressed: clearSelection,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ...habits.map((habit) {
                Widget card;
                if (displayMode == DisplayMode.compact) {
                  card = Dismissible(
                    key: Key('compact_habit_${habit.id}'),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 24),
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            l10n.delete,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.blue,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            l10n.copy, // Usar la nueva clave de traducción
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.copy, color: Colors.white),
                        ],
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.deleteHabit),
                            content: Text(l10n.deleteHabitConfirm(habit.name)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(l10n.cancel),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text(l10n.delete),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await ref.read(jsonHabitsNotifierProvider.notifier).deleteHabit(habit.id);
                        }
                        return confirmed == true;
                      } else {
                        await duplicateHabit(context, ref, habit);
                        return false;
                      }
                    },
                    child: CompactHabitCard(
                      habit: habit,
                      onComplete: (habitId) async {
                        await ref.read(jsonHabitsNotifierProvider.notifier).completeHabit(habitId);
                        await ref.read(jsonHabitsRepositoryProvider).recordCompletionForML(habitId, true);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.habitCompleted)),
                          );
                        }
                      },
                      onUncheck: (habitId) async {
                        await ref.read(jsonHabitsNotifierProvider.notifier).uncheckHabit(habitId);
                      },
                      onEdit: () => _showEditHabitDialog(context, ref, l10n, habit),
                      onDelete: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.deleteHabit),
                            content: Text(l10n.deleteHabitConfirm(habit.name)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(l10n.cancel),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text(l10n.delete),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await ref.read(jsonHabitsNotifierProvider.notifier).deleteHabit(habit.id);
                        }
                      },
                    ),
                  );
                } else {
                  card = Dismissible(
                    key: Key('advanced_habit_${habit.id}'),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 24),
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            l10n.delete,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.blue,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            l10n.copy, // Usar la nueva clave de traducción
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.copy, color: Colors.white),
                        ],
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.deleteHabit),
                            content: Text(l10n.deleteHabitConfirm(habit.name)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(l10n.cancel),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text(l10n.delete),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await ref.read(jsonHabitsNotifierProvider.notifier).deleteHabit(habit.id);
                        }
                        return confirmed == true;
                      } else {
                        await duplicateHabit(context, ref, habit);
                        return false;
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AdvancedHabitCard(
                          habit: habit,
                          onComplete: (habitId) async {
                            await ref.read(jsonHabitsNotifierProvider.notifier).completeHabit(habitId);
                            await ref.read(jsonHabitsRepositoryProvider).recordCompletionForML(habitId, true);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.habitCompleted)),
                              );
                            }
                          },
                          onUncheck: (habitId) async {
                            await ref.read(jsonHabitsNotifierProvider.notifier).uncheckHabit(habitId);
                          },
                          onEdit: () => _showEditHabitDialog(context, ref, l10n, habit),
                          onDelete: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(l10n.deleteHabit),
                                content: Text(l10n.deleteHabitConfirm(habit.name)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text(l10n.cancel),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text(l10n.delete),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await ref.read(jsonHabitsNotifierProvider.notifier).deleteHabit(habit.id);
                            }
                          },
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final riskAsync = ref.watch(habitRiskProvider(habit.id));
                            return riskAsync.when(
                              data: (risk) {
                                if (risk < 0.7) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                                  child: Card(
                                    color: Theme.of(context).colorScheme.errorContainer,
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.warning_amber,
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                      title: Text(
                                        l10n.highRiskWarning,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onErrorContainer,
                                        ),
                                      ),
                                      subtitle: Text(
                                        l10n.riskPercentage((risk * 100).toInt()),
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onErrorContainer,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: card,
                );
              }),
              const SizedBox(height: 24),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_habit_fab'),
        onPressed: () {
          final l10n = AppLocalizations.of(context)!;
          showDialog(
            context: context,
            builder: (context) => AddHabitDiscoveryDialog(l10n: l10n),
          );
        },
        backgroundColor: const Color(0xff6366f1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showEditHabitDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Habit habit,
  ) {
    showDialog(
      context: context,
      builder: (context) => EditHabitDialog(l10n: l10n, habit: habit),
    );
  }
}
