import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/domain/models/habit_notification.dart';
import '../features/habits/presentation/constants/habit_colors.dart';
import '../features/habits/presentation/habits_providers.dart';
import '../core/providers/notification_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/reminder_config_dialog.dart';
import '../widgets/recurrence_config_dialog.dart';
import '../widgets/subtasks_section.dart';

class EditHabitDialog extends ConsumerStatefulWidget {
  final AppLocalizations l10n;
  final Habit habit;

  const EditHabitDialog({super.key, required this.l10n, required this.habit});

  @override
  ConsumerState<EditHabitDialog> createState() => _EditHabitDialogState();
}

class _EditHabitDialogState extends ConsumerState<EditHabitDialog> {
  late TextEditingController nameCtrl;
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
    subtasks = List<Subtask>.from(widget.habit.subtasks);
    selectedCategory = widget.habit.category;
    selectedDifficulty = widget.habit.difficulty;
    notificationSettings = widget.habit.notificationSettings;
    recurrence = widget.habit.recurrence;

    // Listen to text changes to update Save button visibility
    nameCtrl.addListener(() => setState(() {}));
    emojiCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emojiCtrl.dispose();
    eventTimeCtrl.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    final habit = widget.habit;
    
    // Compare basic fields
    if (nameCtrl.text != habit.name) return true;
    if (emojiCtrl.text != (habit.emoji ?? '')) return true;
    if (selectedCategory != habit.category) return true;
    if (selectedDifficulty != habit.difficulty) return true;
    
    // Compare color
    final habitColorValue = habit.colorValue;
    final currentColorValue = selectedColor?.toARGB32();
    if (currentColorValue != habitColorValue) return true;
    
    // Compare notifications
    if (notificationSettings != habit.notificationSettings) return true;
    
    // Compare recurrence
    if (recurrence != habit.recurrence) return true;
    
    // Compare subtasks
    if (!const ListEquality<Subtask>().equals(subtasks, habit.subtasks)) return true;
    
    return false;
  }

  Future<void> _save() async {
    final l10n = widget.l10n;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    await ref.read(habitsNotifierProvider.notifier).updateHabit(
          habitId: widget.habit.id,
          name: nameCtrl.text,
          category: selectedCategory,
          emoji: emojiCtrl.text.isNotEmpty ? emojiCtrl.text : null,
          colorValue: selectedColor?.toARGB32(),
          difficulty: selectedDifficulty,
          notificationSettings: notificationSettings,
          recurrence: recurrence,
          subtasks: subtasks,
        );

    final notificationService = ref.read(notificationServiceProvider);
    if (notificationSettings != null &&
        notificationSettings!.timing != NotificationTiming.none &&
        notificationSettings!.eventTime != null) {
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
      await notificationService.cancelHabitNotification(widget.habit.id);
    }

    if (mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('${l10n.habitEdited} ✓'),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final canSave = _hasChanges();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      l10n.editHabit,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(l10n.cancel),
                  ),
                  if (canSave) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, size: 16),
                          const SizedBox(width: 4),
                          Text(l10n.save, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
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
                value: selectedCategory,
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
                value: selectedDifficulty,
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
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: HabitColors.categoryColors.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final color =
                        HabitColors.categoryColors.values.elementAt(idx);
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 48 : 40,
                        height: isSelected ? 48 : 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected ? Colors.black : Colors.transparent,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: color.withValues(alpha: 0.4),
                                      blurRadius: 8)
                                ]
                              : [],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 24)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              if (selectedColor != null)
                TextButton.icon(
                  onPressed: () => setState(() => selectedColor = null),
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Limpiar color', style: TextStyle(fontSize: 12)),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(
                            color: Colors.blueAccent, width: 2),
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
