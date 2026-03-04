import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/habits/domain/habit.dart';
import '../features/habits/domain/models/habit_notification.dart';
import '../features/habits/presentation/constants/habit_colors.dart';
import '../features/habits/presentation/habits_providers.dart';
import '../core/providers/notification_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/reminder_config_dialog.dart';
import '../widgets/recurrence_config_dialog.dart';

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
  late HabitCategory selectedCategory;
  late HabitDifficulty selectedDifficulty;
  Color? selectedColor;
  HabitNotificationSettings? notificationSettings;
  HabitRecurrence? recurrence;
  TimeOfDay? eventTime;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.habit.name);
    emojiCtrl = TextEditingController(text: widget.habit.emoji ?? '');

    final habitNotif = widget.habit.notificationSettings;
    if (habitNotif?.eventTime != null && habitNotif!.eventTime!.contains(':')) {
      final parts = habitNotif.eventTime!.split(':');
      eventTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    selectedColor = widget.habit.colorValue != null
        ? Color(widget.habit.colorValue!)
        : null;
    selectedCategory = widget.habit.category;
    selectedDifficulty = widget.habit.difficulty;
    notificationSettings = widget.habit.notificationSettings;
    recurrence = widget.habit.recurrence;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emojiCtrl.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    final habit = widget.habit;
    if (nameCtrl.text != habit.name) return true;
    if (emojiCtrl.text != (habit.emoji ?? '')) return true;
    if (selectedCategory != habit.category) return true;
    if (selectedDifficulty != habit.difficulty) return true;

    final currentColorValue = selectedColor?.toARGB32();
    if (currentColorValue != habit.colorValue) return true;

    if (notificationSettings != habit.notificationSettings) return true;
    if (recurrence != habit.recurrence) return true;
    return false;
  }

  Future<void> _save() async {
    if (nameCtrl.text.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(habitsNotifierProvider.notifier).updateHabit(
            habitId: widget.habit.id,
            name: nameCtrl.text,
            category: selectedCategory,
            emoji: emojiCtrl.text.isNotEmpty ? emojiCtrl.text : null,
            colorValue: selectedColor?.toARGB32(),
            difficulty: selectedDifficulty,
            notificationSettings: notificationSettings,
            recurrence: recurrence,
          );

      final notificationService = ref.read(notificationServiceProvider);
      if (notificationSettings != null &&
          notificationSettings!.timing != NotificationTiming.none &&
          notificationSettings!.eventTime != null) {
        int? minutesBefore =
            notificationSettings!.timing == NotificationTiming.custom
                ? notificationSettings!.customMinutesBefore
                : notificationSettings!.timing.minutesBefore;

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
        Navigator.of(context).pop(); // Loader
        Navigator.of(context).pop(); // Dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(widget.l10n.habitEdited),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  String _notificationTimingLabel(
      AppLocalizations l10n, NotificationTiming timing) {
    switch (timing) {
      case NotificationTiming.none:
        return l10n.notificationTimingNone;
      case NotificationTiming.atEventTime:
        return l10n.notificationTimingAtEvent;
      case NotificationTiming.tenMinutesBefore:
        return l10n.notificationTimingTenMin;
      case NotificationTiming.thirtyMinutesBefore:
        return l10n.notificationTimingThirtyMin;
      case NotificationTiming.oneHourBefore:
        return l10n.notificationTimingOneHour;
      case NotificationTiming.custom:
        return l10n.custom;
    }
  }

  String _difficultyLabel(AppLocalizations l10n, HabitDifficulty diff) {
    switch (diff) {
      case HabitDifficulty.easy:
        return l10n.difficultyEasy;
      case HabitDifficulty.medium:
        return l10n.difficultyMedium;
      case HabitDifficulty.hard:
        return l10n.difficultyHard;
    }
  }

  String _recurrenceFrequencyLabel(
      AppLocalizations l10n, RecurrenceFrequency freq) {
    switch (freq) {
      case RecurrenceFrequency.daily:
        return l10n.daily;
      case RecurrenceFrequency.weekly:
        return l10n.weekly;
      case RecurrenceFrequency.monthly:
        return l10n.monthly;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _hasChanges();
    final l10n = widget.l10n;
    final themeColor = selectedColor ?? Colors.blueAccent;
    final backgroundColor =
        Color.alphaBlend(themeColor.withValues(alpha: 0.25), Colors.white);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Moderno
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ),
                Text(l10n.editHabit,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900)),
                ElevatedButton(
                  onPressed: canSave ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  child: Text(l10n.save,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Flexible(
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 4,
              radius: const Radius.circular(10),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: themeColor.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: TextField(
                                  controller: emojiCtrl,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  style: const TextStyle(fontSize: 32),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    counterText: "",
                                    hintText: "✨",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: nameCtrl,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    hintText: l10n.name,
                                    border: InputBorder.none,
                                    hintStyle:
                                        TextStyle(color: Colors.grey.shade400),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Paleta de colores vibrante
                          SizedBox(
                            height: 48,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children:
                                  HabitColors.availableColors.map((color) {
                                final isSelected = selectedColor?.toARGB32() ==
                                    color.toARGB32();
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => selectedColor = color),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin: const EdgeInsets.only(right: 14),
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.black87
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                  color: color.withValues(
                                                      alpha: 0.4),
                                                  blurRadius: 10,
                                                  spreadRadius: 2)
                                            ]
                                          : [],
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check,
                                            color: Colors.white, size: 24)
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.difficulty,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.blueGrey,
                            fontSize: 14)),
                    const SizedBox(height: 12),
                    _buildSectionCard(
                      child: Column(
                        children: [
                          _buildDifficultySelector(themeColor),
                          const SizedBox(height: 20),
                          _buildCategoryChips(themeColor),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.routine,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.blueGrey,
                            fontSize: 14)),
                    const SizedBox(height: 12),
                    _buildSectionCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _buildTile(
                            icon: Icons.access_time_rounded,
                            color: Colors.orange,
                            title: l10n.hour,
                            value:
                                eventTime?.format(context) ?? l10n.selectTime,
                            onTap: () async {
                              final picked = await showTimePicker(
                                  context: context,
                                  initialTime: eventTime ?? TimeOfDay.now());
                              if (picked != null) {
                                setState(() {
                                  eventTime = picked;
                                  final timeStr =
                                      '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                  notificationSettings = notificationSettings
                                          ?.copyWith(eventTime: timeStr) ??
                                      HabitNotificationSettings(
                                          timing:
                                              NotificationTiming.atEventTime,
                                          eventTime: timeStr);
                                });
                              }
                            },
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildTile(
                            icon: Icons.notifications_active_outlined,
                            color: Colors.purple,
                            title: l10n.reminder,
                            value: notificationSettings != null
                                ? _notificationTimingLabel(
                                    l10n, notificationSettings!.timing)
                                : l10n.notificationTimingNone,
                            onTap: () async {
                              final result =
                                  await showDialog<HabitNotificationSettings>(
                                context: context,
                                builder: (context) => ReminderConfigDialog(
                                  initialSettings: notificationSettings,
                                  eventTime: eventTime != null
                                      ? '${eventTime!.hour.toString().padLeft(2, '0')}:${eventTime!.minute.toString().padLeft(2, '0')}'
                                      : null,
                                ),
                              );
                              if (result != null) {
                                setState(() => notificationSettings = result);
                              }
                            },
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildTile(
                            icon: Icons.repeat_rounded,
                            color: Colors.green,
                            title: l10n.repetition,
                            value: recurrence?.enabled == true
                                ? _recurrenceFrequencyLabel(
                                    l10n, recurrence!.frequency)
                                : l10n.noRepetition,
                            onTap: () async {
                              final result = await showDialog<HabitRecurrence>(
                                context: context,
                                builder: (context) => RecurrenceConfigDialog(
                                    initialRecurrence: recurrence),
                              );
                              if (result != null) {
                                setState(() => recurrence = result);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }

  Widget _buildTile(
      {required IconData icon,
      required Color color,
      required String title,
      required String value,
      required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      subtitle: Text(value,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
    );
  }

  Widget _buildDifficultySelector(Color themeColor) {
    final l10n = widget.l10n;
    return Row(
      children: HabitDifficulty.values.map((diff) {
        final isSelected = selectedDifficulty == diff;
        final stars = HabitDifficultyHelper.getDifficultyStars(diff);

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedDifficulty = diff),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? themeColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _difficultyLabel(l10n, diff),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      stars,
                      (index) => Icon(
                        Icons.star,
                        size: 14,
                        color: isSelected ? Colors.white : Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryChips(Color themeColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: HabitCategory.values.map((cat) {
        final isSelected = selectedCategory == cat;
        return ChoiceChip(
          avatar: Icon(
            HabitColors.getCategoryIcon(cat),
            size: 18,
            color: isSelected ? Colors.white : themeColor,
          ),
          label: Text(
            HabitColors.getCategoryDisplayName(cat, widget.l10n),
            style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.white : Colors.black87),
          ),
          selected: isSelected,
          onSelected: (val) => setState(() => selectedCategory = cat),
          selectedColor: themeColor,
          backgroundColor: Colors.grey.shade100,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          showCheckmark: false,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        );
      }).toList(),
    );
  }
}
