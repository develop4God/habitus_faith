import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/domain/models/habit_notification.dart';
import '../features/habits/presentation/constants/habit_colors.dart';
import '../core/providers/notification_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/reminder_config_dialog.dart';
import '../widgets/recurrence_config_dialog.dart';
import '../widgets/subtasks_section.dart';
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
  late TextEditingController eventTimeCtrl;
  late HabitCategory selectedCategory;
  late HabitDifficulty selectedDifficulty;
  Color? selectedColor;
  HabitNotificationSettings? notificationSettings;
  HabitRecurrence? recurrence;
  List<Subtask> subtasks = [];

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.habit.name);
    descCtrl = TextEditingController(text: widget.habit.description);
    emojiCtrl = TextEditingController(text: widget.habit.emoji ?? '');
    eventTimeCtrl = TextEditingController(
        text: widget.habit.notificationSettings?.eventTime ?? '');
    selectedCategory = widget.habit.category;
    selectedDifficulty = widget.habit.difficulty;
    selectedColor = widget.habit.colorValue != null
        ? Color(widget.habit.colorValue!)
        : null;
    notificationSettings = widget.habit.notificationSettings;
    recurrence = widget.habit.recurrence;
    subtasks = List.from(widget.habit.subtasks);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    emojiCtrl.dispose();
    eventTimeCtrl.dispose();
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
          notificationSettings: notificationSettings,
          recurrence: recurrence,
          subtasks: subtasks,
        );

    // Schedule or cancel notifications based on settings
    final notificationService = ref.read(notificationServiceProvider);
    if (notificationSettings != null &&
        notificationSettings!.timing != NotificationTiming.none &&
        notificationSettings!.eventTime != null) {
      // Calculate minutes before
      int? minutesBefore;
      if (notificationSettings!.timing == NotificationTiming.custom) {
        minutesBefore = notificationSettings!.customMinutesBefore;
      } else {
        minutesBefore = notificationSettings!.timing.minutesBefore;
      }

      await notificationService.scheduleHabitNotification(
        habitId: widget.habit.id,
        habitName: nameCtrl.text,
        eventTime: notificationSettings!.eventTime!,
        minutesBefore: minutesBefore,
      );
    } else {
      // Cancel notification if disabled
      await notificationService.cancelHabitNotification(widget.habit.id);
    }

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
                initialValue: selectedCategory,
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
                initialValue: selectedDifficulty,
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
              // Event time for notifications
              TextField(
                controller: eventTimeCtrl,
                decoration: InputDecoration(
                  labelText: l10n.eventTime,
                  border: const OutlineInputBorder(),
                  hintText: '09:00',
                ),
                onChanged: (value) {
                  setState(() {
                    // Update notification settings with new event time
                    if (notificationSettings != null) {
                      notificationSettings = notificationSettings!.copyWith(
                        eventTime: value,
                      );
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              // Notification configuration button
              ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(l10n.reminder),
                subtitle: Text(
                  notificationSettings?.timing.displayName ?? 'Sin aviso',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final result = await showDialog<HabitNotificationSettings>(
                    context: context,
                    builder: (context) => ReminderConfigDialog(
                      initialSettings: notificationSettings,
                      eventTime: eventTimeCtrl.text.isNotEmpty
                          ? eventTimeCtrl.text
                          : null,
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      notificationSettings = result;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              // Recurrence configuration button
              ListTile(
                leading: const Icon(Icons.repeat),
                title: Text(l10n.repetition),
                subtitle: Text(
                  recurrence?.enabled == true
                      ? '${recurrence!.frequency.displayName} (Cada ${recurrence!.interval} ${_getFrequencyUnit(recurrence!.frequency)})'
                      : l10n.noRepetition,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final result = await showDialog<HabitRecurrence>(
                    context: context,
                    builder: (context) => RecurrenceConfigDialog(
                      initialRecurrence: recurrence,
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      recurrence = result;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              // Subtasks section
              SubtasksSection(
                initialSubtasks: subtasks,
                onSubtasksChanged: (newSubtasks) {
                  setState(() {
                    subtasks = newSubtasks;
                  });
                },
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

  String _getFrequencyUnit(RecurrenceFrequency frequency) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return 'día';
      case RecurrenceFrequency.weekly:
        return 'semana';
      case RecurrenceFrequency.monthly:
        return 'mes';
    }
  }
}
