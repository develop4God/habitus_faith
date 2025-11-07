import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/domain/failures.dart';
import '../features/habits/domain/models/display_mode.dart';
import '../features/habits/data/storage/storage_providers.dart';
import '../features/habits/presentation/onboarding/display_mode_provider.dart';
import '../features/habits/presentation/widgets/habit_card/compact_habit_card.dart';
import '../features/habits/presentation/widgets/habit_card/advanced_habit_card.dart';
import '../features/habits/presentation/constants/habit_colors.dart';
import '../core/providers/ml_providers.dart';
import '../l10n/app_localizations.dart';
import '../widgets/add_habit_discovery_dialog.dart';

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
      emoji: habit.emoji, // Asegura que el emoji se pase correctamente
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hábito duplicado")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final habitsAsync = ref.watch(jsonHabitsStreamProvider);

    // Listen for errors
    ref.listen<AsyncValue<void>>(jsonHabitsNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          debugPrint('HabitsPage: notifier error -> $error');
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
                    _selectAll(habits);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'select_all',
                    child: Row(
                      children: [
                        Icon(Icons.select_all, size: 20),
                        SizedBox(width: 8),
                        Text('Marcar todo'),
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
          debugPrint('HabitsPage.when.data: received ${habits.length} habits');
          if (habits.isEmpty) {
            debugPrint('HabitsPage.when.data: habits list is empty');
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

          // Agrupa hábitos por categoría
          final habitsByCategory = <HabitCategory, List<Habit>>{};
          for (final habit in habits) {
            habitsByCategory.putIfAbsent(habit.category, () => []).add(habit);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Banner animado para indicar swipe actions
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
              if (_selectedHabits.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    color: Colors.blue.shade50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text('${_selectedHabits.length} seleccionados'),
                        ),
                        Row(
                          children: [
                            // Eliminar seleccionados ya no está en el menú, pero sí aquí si hay selección
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Eliminar seleccionados',
                              onPressed: () => _deleteSelected(context, ref),
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear),
                              tooltip: 'Limpiar selección',
                              onPressed: _clearSelection,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              // Secciones por categoría
              for (final category in HabitCategory.values)
                if (habitsByCategory.containsKey(category))
                  _buildCategorySection(
                    context,
                    ref,
                    l10n,
                    category,
                    habitsByCategory[category]!,
                  ),
            ],
          );
        },
        loading: () {
          debugPrint('HabitsPage: loading state -> showing spinner');
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stack) {
          debugPrint('HabitsPage: error state -> $error');
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
          debugPrint('HabitsPage: FAB pressed -> showing add habit discovery dialog');
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

  Widget _buildCategorySection(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    HabitCategory category,
    List<Habit> habits,
  ) {
    final categoryColor = HabitColors.categoryColors[category]!;
    final categoryIcon = HabitColors.getCategoryIcon(category);
    final categoryName = HabitColors.getCategoryDisplayName(category, l10n);
    final displayMode = ref.watch(displayModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Category header
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                categoryColor.withValues(alpha: 0.1),
                categoryColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: categoryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                categoryIcon,
                color: categoryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${habits.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        // ⬇️ ELIMINADO: Calendario grupal que estaba aquí
        // if (displayMode == DisplayMode.advanced) ...[
        //   MiniCalendarHeatmap(
        //     completionDates: groupCompletionDates,
        //   ),
        //   const SizedBox(height: 8),
        // ],
        // Habits in this category - use appropriate card based on display mode
        ...habits.map((habit) {
          Widget card;
          if (displayMode == DisplayMode.compact) {
            card = Dismissible(
              key: Key('compact_habit_${habit.id}'),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 24),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Colors.blue,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                child: const Icon(Icons.copy, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  // Eliminar
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
                  // Duplicar
                  await _duplicateHabit(context, ref, habit);
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
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Colors.blue,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                child: const Icon(Icons.copy, color: Colors.white),
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
                  await _duplicateHabit(context, ref, habit);
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
  }

  void _showEditHabitDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Habit habit,
  ) {
    showDialog(
      context: context,
      builder: (context) => _EditHabitDialog(l10n: l10n, habit: habit),
    );
  }

}

class _EditHabitDialog extends ConsumerStatefulWidget {
  final AppLocalizations l10n;
  final Habit habit;

  const _EditHabitDialog({required this.l10n, required this.habit});

  @override
  ConsumerState<_EditHabitDialog> createState() => _EditHabitDialogState();
}

class _EditHabitDialogState extends ConsumerState<_EditHabitDialog> {
  late TextEditingController nameCtrl;
  late TextEditingController descCtrl;
  late TextEditingController emojiCtrl;
  late HabitCategory selectedCategory;
  late HabitDifficulty selectedDifficulty;
  Color? selectedColor;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.habit.name);
    descCtrl = TextEditingController(text: widget.habit.description);
    emojiCtrl = TextEditingController(text: widget.habit.emoji ?? '');
    selectedCategory = widget.habit.category;
    selectedDifficulty = widget.habit.difficulty;
    selectedColor = widget.habit.colorValue != null
        ? Color(widget.habit.colorValue!)
        : null;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    emojiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitColor = selectedColor ?? HabitColors.categoryColors[selectedCategory]!;

    return AlertDialog(
      title: Text(widget.l10n.editHabit),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vista previa del hábito
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: habitColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: habitColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Emoji en la vista previa
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: habitColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        emojiCtrl.text.isNotEmpty ? emojiCtrl.text : '✓',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nameCtrl.text.isNotEmpty ? nameCtrl.text : widget.l10n.previewHabitName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          descCtrl.text.isNotEmpty ? descCtrl.text : widget.l10n.previewHabitDescription,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: widget.l10n.name,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(
                labelText: widget.l10n.description,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emojiCtrl,
              decoration: InputDecoration(
                labelText: widget.l10n.emoji,
                border: const OutlineInputBorder(),
                hintText: '🙏',
              ),
              maxLength: 2,
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Text(
              widget.l10n.category,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<HabitCategory>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: HabitCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(
                        HabitColors.getCategoryIcon(category),
                        size: 20,
                        color: HabitColors.categoryColors[category],
                      ),
                      const SizedBox(width: 8),
                      Text(HabitColors.getCategoryDisplayName(
                          category, widget.l10n))
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                    selectedColor = null;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              widget.l10n.difficulty,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: HabitDifficulty.values.map((difficulty) {
                final isSelected = selectedDifficulty == difficulty;
                final color = HabitColors.categoryColors[selectedCategory]!;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDifficulty = difficulty;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            HabitDifficultyHelper.getDifficultyStars(difficulty),
                            (index) => Icon(
                              Icons.star,
                              size: 18,
                              color: isSelected ? color : Colors.grey.shade500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          difficulty.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected ? color : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ));
              }
              ).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.l10n.color} (${widget.l10n.optional})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildColorOption(
                  null,
                  HabitColors.categoryColors[selectedCategory]!,
                  widget.l10n.defaultColor,
                ),
                ...HabitColors.availableColors.map(
                  (color) => _buildColorOption(color, color, null),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            if (nameCtrl.text.isNotEmpty && descCtrl.text.isNotEmpty) {
              await ref.read(jsonHabitsNotifierProvider.notifier).updateHabit(
                    habitId: widget.habit.id,
                    name: nameCtrl.text,
                    description: descCtrl.text,
                    category: selectedCategory,
                    emoji: emojiCtrl.text.isNotEmpty ? emojiCtrl.text : null,
                    colorValue: selectedColor?.toARGB32(),
                    difficulty: selectedDifficulty,
                  );
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: Text(widget.l10n.save),
        ),
      ],
    );
  }

  Widget _buildColorOption(
      Color? colorValue, Color displayColor, String? label) {
    final isSelected = selectedColor == colorValue;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = colorValue;
        });
      },
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: displayColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 24)
                : null,
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}

