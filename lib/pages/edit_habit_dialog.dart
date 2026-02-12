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
    if (selectedColor?.toARGB32() != habit.colorValue) return true;
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
        int? minutesBefore = notificationSettings!.timing == NotificationTiming.custom
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
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _hasChanges();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Moderno con Cancelar y Guardar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(widget.l10n.cancel, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ),
                Text(widget.l10n.editHabit, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ElevatedButton(
                  onPressed: canSave ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  child: Text(widget.l10n.save, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          Flexible(
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
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: (selectedColor ?? Colors.blueAccent).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextField(
                                controller: emojiCtrl,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                style: const TextStyle(fontSize: 30),
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
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  hintText: widget.l10n.name,
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: Colors.grey.shade400),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Paleta de colores moderna
                        SizedBox(
                          height: 45,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: HabitColors.categoryColors.values.map((color) {
                              final isSelected = selectedColor?.value == color.value;
                              return GestureDetector(
                                onTap: () => setState(() => selectedColor = color),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? Colors.black87 : Colors.transparent,
                                      width: 3,
                                    ),
                                    boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 2)] : [],
                                  ),
                                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  const Text("Challenge", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 10),
                  _buildSectionCard(
                    child: Column(
                      children: [
                        _buildDifficultySelector(),
                        const SizedBox(height: 16),
                        _buildCategoryChips(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text("Schedule", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 10),
                  _buildSectionCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _buildTile(
                          icon: Icons.access_time_rounded,
                          color: Colors.orange,
                          title: "Target Time",
                          value: eventTime?.format(context) ?? "Set time",
                          onTap: () async {
                            final picked = await showTimePicker(context: context, initialTime: eventTime ?? TimeOfDay.now());
                            if (picked != null) {
                              setState(() {
                                eventTime = picked;
                                final timeStr = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                notificationSettings = notificationSettings?.copyWith(eventTime: timeStr) 
                                  ?? HabitNotificationSettings(timing: NotificationTiming.atEventTime, eventTime: timeStr);
                              });
                            }
                          },
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildTile(
                          icon: Icons.notifications_active_outlined,
                          color: Colors.purple,
                          title: widget.l10n.reminder,
                          value: notificationSettings?.timing.displayName ?? "None",
                          onTap: () async {
                            final result = await showDialog<HabitNotificationSettings>(
                              context: context,
                              builder: (context) => ReminderConfigDialog(
                                initialSettings: notificationSettings,
                                eventTime: eventTime != null ? '${eventTime!.hour.toString().padLeft(2, '0')}:${eventTime!.minute.toString().padLeft(2, '0')}' : null,
                              ),
                            );
                            if (result != null) setState(() => notificationSettings = result);
                          },
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildTile(
                          icon: Icons.repeat_rounded,
                          color: Colors.green,
                          title: widget.l10n.repetition,
                          value: recurrence?.enabled == true ? recurrence!.frequency.displayName : widget.l10n.noRepetition,
                          onTap: () async {
                            final result = await showDialog<HabitRecurrence>(
                              context: context,
                              builder: (context) => RecurrenceConfigDialog(initialRecurrence: recurrence),
                            );
                            if (result != null) setState(() => recurrence = result);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _buildTile({required IconData icon, required Color color, required String title, required String value, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Row(
      children: HabitDifficulty.values.map((diff) {
        final isSelected = selectedDifficulty == diff;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedDifficulty = diff),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                diff.displayName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 0,
      children: HabitCategory.values.map((cat) {
        final isSelected = selectedCategory == cat;
        return ChoiceChip(
          label: Text(HabitColors.getCategoryDisplayName(cat, widget.l10n), style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
          selected: isSelected,
          onSelected: (val) => setState(() => selectedCategory = cat),
          selectedColor: Colors.blueAccent,
          backgroundColor: Colors.grey.shade100,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          showCheckmark: false,
          padding: const EdgeInsets.symmetric(horizontal: 4),
        );
      }).toList(),
    );
  }
}
