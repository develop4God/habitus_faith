import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/domain/failures.dart';
import '../features/habits/data/storage/storage_providers.dart';
import '../features/habits/presentation/widgets/habit_completion_card.dart';
import '../features/habits/presentation/widgets/mini_calendar_heatmap.dart';
import '../features/habits/presentation/constants/habit_colors.dart';
import '../core/providers/ml_providers.dart';
import '../l10n/app_localizations.dart';

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

class HabitsPage extends ConsumerWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    debugPrint('HabitsPage.build: started');
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

          // Group habits by category
          final habitsByCategory = <HabitCategory, List<Habit>>{};
          for (final habit in habits) {
            habitsByCategory.putIfAbsent(habit.category, () => []).add(habit);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Build sections for each category
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
          debugPrint('HabitsPage: FAB pressed -> showing add habit dialog');
          _showAddHabitDialog(context, ref, l10n);
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

    // Gather all completion dates for this group
    final groupCompletionDates = habits.expand((h) => h.completionHistory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            children: [
              Icon(
                categoryIcon,
                color: categoryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                categoryName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
                ),
                textAlign: TextAlign.center,
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
        // Calendar for this group
        MiniCalendarHeatmap(
          completionDates: groupCompletionDates,
        ),
        const SizedBox(height: 8),
        // Habits in this category
        ...habits.map((habit) {
          final notifier = ref.watch(jsonHabitsNotifierProvider);
          final isCompleting = notifier.isLoading;

          return Column(
            children: [
              HabitCompletionCard(
                habit: habit,
                isCompleting: isCompleting,
                onTap: () async {
                  await ref
                      .read(jsonHabitsNotifierProvider.notifier)
                      .completeHabit(habit.id);

                  await ref
                      .read(jsonHabitsRepositoryProvider)
                      .recordCompletionForML(habit.id, true);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.habitCompleted)),
                    );
                  }
                },
                onEdit: () => _showEditHabitDialog(context, ref, l10n, habit),
                onUncheck: () async {
                  await ref
                      .read(jsonHabitsNotifierProvider.notifier)
                      .uncheckHabit(habit.id);
                },
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
                    await ref
                        .read(jsonHabitsNotifierProvider.notifier)
                        .deleteHabit(habit.id);
                  }
                },
              ),
              // ML-based risk warning
              Consumer(
                builder: (context, ref, child) {
                  final riskAsync = ref.watch(habitRiskProvider(habit.id));

                  return riskAsync.when(
                    data: (risk) {
                      if (risk < 0.7) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                            ),
                            subtitle: Text(
                              l10n.riskPercentage((risk * 100).toInt()),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                            ),
                            trailing: FilledButton(
                              onPressed: () async {
                                await ref
                                    .read(jsonHabitsNotifierProvider.notifier)
                                    .completeHabit(habit.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(l10n.habitCompleted)),
                                  );
                                }
                              },
                              child: Text(l10n.completeNow),
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
              const SizedBox(height: 16),
            ],
          );
        }),
        const SizedBox(height: 8),
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

  void _showAddHabitDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => _AddHabitDialog(l10n: l10n),
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
    return AlertDialog(
      title: Text(widget.l10n.editHabit),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: widget.l10n.name,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(
                labelText: widget.l10n.description,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
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
                      Text(HabitColors.getCategoryDisplayName(category, widget.l10n))
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
                            HabitDifficultyHelper.getDifficultyStars(
                                difficulty),
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
                  ),
                );
              }).toList(),
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

class _AddHabitDialog extends ConsumerStatefulWidget {
  final AppLocalizations l10n;

  const _AddHabitDialog({required this.l10n});

  @override
  ConsumerState<_AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends ConsumerState<_AddHabitDialog> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final emojiCtrl = TextEditingController();
  HabitCategory selectedCategory = HabitCategory.mental;
  HabitDifficulty selectedDifficulty = HabitDifficulty.medium;
  Color? selectedColor;

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    emojiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.l10n.addHabit),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('habit_name_input'),
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: widget.l10n.name,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('habit_description_input'),
              controller: descCtrl,
              decoration: InputDecoration(
                labelText: widget.l10n.description,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emojiCtrl,
              decoration: const InputDecoration(
                labelText: 'Emoji',
                border: OutlineInputBorder(),
                hintText: '🙏',
              ),
              maxLength: 2,
            ),
            // Category selector
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
                      Text(HabitColors.getCategoryDisplayName(category, widget.l10n))
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                    // Reset custom color when category changes
                    selectedColor = null;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            // Difficulty selector
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
                            HabitDifficultyHelper.getDifficultyStars(
                                difficulty),
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
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Color picker
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
                // Default category color
                _buildColorOption(
                  null,
                  HabitColors.categoryColors[selectedCategory]!,
                  widget.l10n.defaultColor,
                ),
                // Available custom colors
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
          onPressed: () {
            debugPrint('AddHabitDialog: cancel pressed');
            Navigator.pop(context);
          },
          child: Text(widget.l10n.cancel),
        ),
        ElevatedButton(
          key: const Key('confirm_add_habit_button'),
          onPressed: () async {
            if (nameCtrl.text.isNotEmpty && descCtrl.text.isNotEmpty) {
              debugPrint(
                  'AddHabitDialog: adding habit -> name:${nameCtrl.text} desc:${descCtrl.text}');
              await ref.read(jsonHabitsNotifierProvider.notifier).addHabit(
                    name: nameCtrl.text,
                    description: descCtrl.text,
                    category: selectedCategory,
                    emoji: emojiCtrl.text.isNotEmpty ? emojiCtrl.text : null,
                    colorValue: selectedColor?.toARGB32(),
                    difficulty: selectedDifficulty,
                  );
              debugPrint('AddHabitDialog: addHabit awaited');
              if (context.mounted) {
                Navigator.pop(context);
              }
            } else {
              debugPrint('AddHabitDialog: missing name or description');
            }
          },
          child: Text(widget.l10n.add),
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
