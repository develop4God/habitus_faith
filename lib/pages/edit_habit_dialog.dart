import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/presentation/constants/habit_colors.dart';
import '../l10n/app_localizations.dart';
import 'habits_page.dart';

class EditHabitDialog extends ConsumerStatefulWidget {
  final AppLocalizations l10n;
  final Habit habit;

  const EditHabitDialog({super.key, required this.l10n, required this.habit});

  @override
  ConsumerState<EditHabitDialog> createState() => _EditHabitDialogState();
}

class _EditHabitDialogState extends ConsumerState<EditHabitDialog> {
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

  Future<void> _save() async {
    await ref.read(jsonHabitsNotifierProvider.notifier).updateHabit(
          habitId: widget.habit.id,
          name: nameCtrl.text,
          description: descCtrl.text,
          category: selectedCategory,
          emoji: emojiCtrl.text.isNotEmpty ? emojiCtrl.text : null,
          colorValue: selectedColor?.value,
          difficulty: selectedDifficulty,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final habitColor =
        selectedColor ?? HabitColors.categoryColors[selectedCategory]!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.editHabit,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emojiCtrl,
                decoration: InputDecoration(
                  labelText: l10n.emoji,
                  border: const OutlineInputBorder(),
                ),
                maxLength: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<HabitCategory>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: l10n.category,
                  border: const OutlineInputBorder(),
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
                        Text(HabitColors.getCategoryDisplayName(category, l10n))
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
              const SizedBox(height: 12),
              DropdownButtonFormField<HabitDifficulty>(
                value: selectedDifficulty,
                decoration: InputDecoration(
                  labelText: l10n.difficulty,
                  border: const OutlineInputBorder(),
                ),
                items: HabitDifficulty.values.map((difficulty) {
                  return DropdownMenuItem(
                    value: difficulty,
                    child: Text(difficulty.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedDifficulty = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              // Color picker simple
              Row(
                children: [
                  Text(l10n.color),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final color = await showDialog<Color>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.color),
                          content: Wrap(
                            spacing: 8,
                            children: HabitColors.categoryColors.values
                                .map((color) => GestureDetector(
                                      onTap: () =>
                                          Navigator.of(context).pop(color),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: selectedColor == color
                                                ? Colors.black
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      );
                      if (color != null) {
                        setState(() {
                          selectedColor = color;
                        });
                      }
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: habitColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  if (selectedColor != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => selectedColor = null),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

