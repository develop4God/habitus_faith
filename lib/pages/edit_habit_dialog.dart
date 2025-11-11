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
  TimeOfDay? eventTime;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.habit.name);
    descCtrl = TextEditingController(text: widget.habit.description);
    emojiCtrl = TextEditingController(text: widget.habit.emoji ?? '');
    eventTimeCtrl = TextEditingController(
      text: widget.habit.notificationSettings?.eventTime ?? '',
    );
    eventTime = widget.habit.notificationSettings?.eventTime != null &&
            widget.habit.notificationSettings!.eventTime!.contains(':')
        ? TimeOfDay(
            hour: int.parse(
                widget.habit.notificationSettings!.eventTime!.split(':')[0]),
            minute: int.parse(
                widget.habit.notificationSettings!.eventTime!.split(':')[1]),
          )
        : null;
    selectedColor = widget.habit.colorValue != null
        ? Color(widget.habit.colorValue!)
        : null;
    // subtasks siempre tiene valor por defecto
    subtasks = List<Subtask>.from(widget.habit.subtasks);
    selectedCategory = widget.habit.category;
    selectedDifficulty = widget.habit.difficulty;
    notificationSettings = widget.habit.notificationSettings;
    recurrence = widget.habit.recurrence;
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
          colorValue: selectedColor?.toARGB32(),
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emojiCtrl,
                decoration: InputDecoration(
                  labelText: l10n.emoji,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                maxLength: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<HabitCategory>(
                initialValue: selectedCategory,
                decoration: InputDecoration(
                  labelText: l10n.category,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16)),
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
                        Text(
                          HabitColors.getCategoryDisplayName(category, l10n),
                        ),
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16)),
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
                                .map(
                                  (color) => GestureDetector(
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
                                  ),
                                )
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
                        border: Border.all(color: Colors.black, width: 2),
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: Colors.blueAccent, width: 2),
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue.shade900,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: eventTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            eventTime = picked;
                            eventTimeCtrl.text =
                                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                            if (notificationSettings != null) {
                              notificationSettings =
                                  notificationSettings!.copyWith(
                                eventTime: eventTimeCtrl.text,
                              );
                            }
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time,
                              color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Text(
                            eventTime != null
                                ? eventTime!.format(context)
                                : 'Seleccionar hora',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Notification configuration button
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                tileColor: Colors.blue.shade50,
                leading:
                    const Icon(Icons.notifications, color: Colors.blueAccent),
                title: Text(l10n.reminder,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  notificationSettings?.timing.displayName ?? 'Sin aviso',
                  style: const TextStyle(color: Colors.blueGrey),
                ),
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.blueAccent),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                tileColor: Colors.green.shade50,
                leading: const Icon(Icons.repeat, color: Colors.green),
                title: Text(l10n.repetition,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  recurrence?.enabled == true
                      ? '${recurrence!.frequency.displayName} (Cada ${recurrence!.interval} ${_getFrequencyUnit(recurrence!.frequency)})'
                      : l10n.noRepetition,
                  style: const TextStyle(color: Colors.green),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.green),
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
                showAddButton: true,
                addButtonStyle: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _save, child: Text(l10n.save)),
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
