import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/domain/models/habit_notification.dart';
import '../features/habits/presentation/constants/habit_colors.dart';
import '../features/habits/presentation/widgets/habit_card/habit_modal_sheet.dart';
import '../features/habits/presentation/habits_providers.dart';
import '../l10n/app_localizations.dart';

/// Unified habit list widget that combines:
/// - Visual design from habits_page (colored border)
/// - Swipe-to-delete functionality from home_page
/// - Tap-to-expand details from CompactHabitCard
class UnifiedHabitList extends ConsumerWidget {
  final Future<void> Function(String habitId) onComplete;
  final Future<void> Function(String habitId) onUncheck;
  final Future<void> Function(String habitId) onDelete;
  final Future<void> Function(Habit habit)? onEdit;
  final bool showSwipeHint;

  const UnifiedHabitList({
    super.key,
    required this.onComplete,
    required this.onUncheck,
    required this.onDelete,
    this.onEdit,
    this.showSwipeHint = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStreamProvider);
    final l10n = AppLocalizations.of(context)!;
    return habitsAsync.when(
      data: (habits) {
        debugPrint(
            '🟢 UnifiedHabitList.build: Recibidos ${habits.length} hábitos: ${habits.map((h) => h.name).toList()}');
        if (habits.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                l10n.startJourney,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // No sorting - maintain user-defined order (for drag-and-drop)
        final sortedHabits = [...habits];

        // Sort habits: pending/skipped/failed first (by order), completed last (by order)
        sortedHabits.sort((a, b) {
          final aCompleted = a.dailyStatus == HabitDailyStatus.completed;
          final bCompleted = b.dailyStatus == HabitDailyStatus.completed;

          // If completion status differs, pending goes first
          if (aCompleted != bCompleted) {
            return aCompleted ? 1 : -1;
          }

          // If both have same completion status, sort by order
          return a.order.compareTo(b.order);
        });

        return Expanded(
          child: ReorderableListView.builder(
            padding:
                const EdgeInsets.only(bottom: kBottomNavigationBarHeight + 24),
            itemCount: sortedHabits.length + 2, // +2 for title and swipe hint
            onReorder: (oldIndex, newIndex) async {
              // Adjust for the title being at index 0
              final hasTitleBefore = sortedHabits
                  .any((h) => h.dailyStatus == HabitDailyStatus.pending);
              final titleOffset = hasTitleBefore ? 1 : 0;

              // Adjust indices for the title
              var adjustedOldIndex = oldIndex - titleOffset;
              var adjustedNewIndex = newIndex - titleOffset;

              // Ensure indices are within bounds
              if (adjustedOldIndex < 0 ||
                  adjustedOldIndex >= sortedHabits.length ||
                  adjustedNewIndex < 0 ||
                  adjustedNewIndex > sortedHabits.length) {
                return;
              }

              // Adjust newIndex for list behavior
              if (adjustedNewIndex > adjustedOldIndex) {
                adjustedNewIndex -= 1;
              }

              // Check if we're trying to move between sections (pending <-> completed)
              final movedHabit = sortedHabits[adjustedOldIndex];
              final movedIsCompleted =
                  movedHabit.dailyStatus == HabitDailyStatus.completed;

              // Find the boundary between pending and completed
              final completedStartIndex = sortedHabits.indexWhere(
                (h) => h.dailyStatus == HabitDailyStatus.completed,
              );

              // Prevent moving completed to pending section and vice versa
              if (completedStartIndex != -1) {
                if (movedIsCompleted &&
                    adjustedNewIndex < completedStartIndex) {
                  // Don't allow moving completed habit to pending section
                  return;
                }
                if (!movedIsCompleted &&
                    adjustedNewIndex >= completedStartIndex) {
                  // Don't allow moving pending habit to completed section
                  return;
                }
              }

              // Reorder the list
              final reorderedHabits = [...sortedHabits];
              final item = reorderedHabits.removeAt(adjustedOldIndex);
              reorderedHabits.insert(adjustedNewIndex, item);

              // Update order values and save
              final habitIds = reorderedHabits.map((h) => h.id).toList();
              final notifier = ref.read(habitsNotifierProvider.notifier);
              await notifier.reorderHabits(habitIds);
            },
            itemBuilder: (context, index) {
              // Title at the beginning
              if (index == 0 &&
                  sortedHabits
                      .any((h) => h.dailyStatus == HabitDailyStatus.pending)) {
                return Padding(
                  key: const Key('plan_your_day_title'),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    '📝 ${l10n.planYourDay}',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: Colors.blueAccent,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                          color: Colors.blueAccent.withAlpha(77),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.left,
                  ),
                );
              }

              // Adjust index for title
              final hasTitleBefore = sortedHabits
                  .any((h) => h.dailyStatus == HabitDailyStatus.pending);
              final titleOffset = hasTitleBefore ? 1 : 0;
              final habitIndex = index - titleOffset;

              // Swipe hint at the end
              if (habitIndex >= sortedHabits.length) {
                if (showSwipeHint &&
                    sortedHabits.any(
                        (h) => h.dailyStatus == HabitDailyStatus.pending)) {
                  return Padding(
                    key: const Key('swipe_hint'),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swipe_left,
                            size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 8),
                        Text(
                          l10n.swipeToComplete,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink(key: Key('empty_end'));
              }

              final habit = sortedHabits[habitIndex];
              return UnifiedHabitCard(
                key: Key('habit_${habit.id}'),
                habit: habit,
                onComplete: onComplete,
                onUncheck: onUncheck,
                onDelete: onDelete,
                onEdit: onEdit,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text(l10n.errorUnknown)),
    );
  }

}

/// Individual habit card with swipe-to-delete and tap-to-expand
class UnifiedHabitCard extends ConsumerStatefulWidget {
  final Habit habit;
  final Future<void> Function(String habitId) onComplete;
  final Future<void> Function(String habitId) onUncheck;
  final Future<void> Function(String habitId) onDelete;
  final Future<void> Function(Habit habit)? onEdit;

  const UnifiedHabitCard({
    super.key,
    required this.habit,
    required this.onComplete,
    required this.onUncheck,
    required this.onDelete,
    this.onEdit,
  });

  @override
  ConsumerState<UnifiedHabitCard> createState() => _UnifiedHabitCardState();
}

class _UnifiedHabitCardState extends ConsumerState<UnifiedHabitCard> {
  bool _isCompleting = false;

  Habit getLatestHabit(WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStreamProvider);
    return habitsAsync.maybeWhen(
      data: (habits) => habits.firstWhere(
        (h) => h.id == widget.habit.id,
        orElse: () => widget.habit,
      ),
      orElse: () => widget.habit,
    );
  }

  Future<void> _handleComplete() async {
    if (_isCompleting) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      final habit = getLatestHabit(ref);
      if (habit.completedToday) {
        debugPrint('Desmarcando hábito: ${habit.id}');
        await widget.onUncheck(habit.id);
      } else {
        debugPrint('Marcando hábito: ${habit.id}');
        await widget.onComplete(habit.id);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  Future<void> _handleDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final habit = getLatestHabit(ref);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteHabit),
        content: Text(l10n.deleteHabitConfirm(habit.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.onDelete(habit.id);
    }
  }

  Future<void> _handleSkip() async {
    final l10n = AppLocalizations.of(context)!;
    final habit = getLatestHabit(ref);
    final notifier = ref.read(habitsNotifierProvider.notifier);

    // Skip the habit for today
    await notifier.skipHabit(habit.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.habitSkipped),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleFail() async {
    final l10n = AppLocalizations.of(context)!;
    final habit = getLatestHabit(ref);
    final notifier = ref.read(habitsNotifierProvider.notifier);

    // Mark the habit as failed for today
    await notifier.failHabit(habit.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.habitMarkedAsNotCompleted),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final habit = getLatestHabit(ref);
    final habitColor = HabitColors.getHabitColor(habit);
    final isCompleted = habit.completedToday;
    final isSkipped = habit.dailyStatus == HabitDailyStatus.skipped;
    final isFailed = habit.dailyStatus == HabitDailyStatus.failed;

    return AnimatedScale(
      scale: (isCompleted || isSkipped || isFailed) ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        // Swipe-to-delete is currently disabled. To re-enable, uncomment the Dismissible widget below.
        /*
        child: Dismissible(
          key: Key('habit_${widget.habit.id}'),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              HapticFeedback.mediumImpact();
              await _handleDelete();
            }
            return false; // Don't actually dismiss the widget
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 28,
            ),
          ),
        */
        child: Container(
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green.shade50
                : isSkipped
                    ? Colors.orange.shade50
                    : isFailed
                        ? Colors.red.shade50
                        : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(color: habitColor, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () async {
              // Show expanded modal sheet
              await HabitModalSheet.show(
                context: context,
                child: _buildExpandedContent(context, l10n, habitColor),
                maxHeight: 480,
              );
              if (!mounted) return;
              setState(() {});
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Emoji con color de fondo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: habitColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        widget.habit.emoji ?? '✓',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Habit info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.habit.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isCompleted
                                      ? Colors.green.shade900
                                      : Colors.grey.shade900,
                                  decoration:
                                      (isCompleted || isSkipped || isFailed)
                                          ? TextDecoration.lineThrough
                                          : null,
                                ),
                              ),
                            ),
                            // Status badge
                            if (isSkipped)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  l10n.skippedHabit,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            else if (isFailed)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  l10n.failedHabit,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red.shade900,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 14,
                              color: widget.habit.currentStreak > 0
                                  ? Colors.orange.shade600
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.dayStreak(widget.habit.currentStreak),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        // Subtasks summary (if any)
                        if (habit.subtasks.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.checklist,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${habit.subtasks.where((s) => s.completed).length}/${habit.subtasks.length} ${l10n.subtasks}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Checkbox más grande y notification bell juntos
                  Row(
                    children: [
                      // Notification bell button (left of checkbox)
                      Consumer(
                        builder: (context, ref, _) {
                          final isActive =
                              widget.habit.notificationSettings != null &&
                                  widget.habit.notificationSettings!.timing ==
                                      NotificationTiming.atEventTime &&
                                  widget.habit.notificationSettings!
                                          .eventTime !=
                                      null;
                          return IconButton(
                            icon: Icon(
                              isActive
                                  ? Icons.notifications_active
                                  : Icons.notifications_none,
                              color: isActive ? Colors.orange : Colors.grey,
                            ),
                            tooltip: l10n.reminderConfig,
                            onPressed: () async {
                              debugPrint(
                                  '🔔 Bell tapped. isActive=$isActive, habitId=${widget.habit.id}');
                              final notifier =
                                  ref.read(habitsNotifierProvider.notifier);
                              if (isActive) {
                                // Turn off notification
                                debugPrint(
                                    '🔕 Bell untap (turn off notification) for habitId=${widget.habit.id}');
                                await notifier.updateHabit(
                                  habitId: widget.habit.id,
                                  notificationSettings: null,
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${l10n.reminderConfig}: ${l10n.notificationsDisabled}'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                // Open time picker to set notification
                                debugPrint(
                                    '⏰ Bell tap (open time picker) for habitId=${widget.habit.id}');
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  debugPrint(
                                      '🔔 Bell configuration set for habitId=${widget.habit.id}, hour=${picked.hour}, minute=${picked.minute}');
                                  final settings = HabitNotificationSettings(
                                    timing: NotificationTiming.atEventTime,
                                    eventTime:
                                        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                                  );
                                  await notifier.updateHabit(
                                    habitId: widget.habit.id,
                                    notificationSettings: settings,
                                  );
                                  if (!context.mounted) return;
                                  final formatted = picked.format(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${l10n.reminderConfig}: $formatted'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  debugPrint(
                                      '🔕 Bell configuration cancelled for habitId=${widget.habit.id}');
                                }
                              }
                            },
                          );
                        },
                      ),
                      // Checkbox
                      InkWell(
                        onTap: _isCompleting ? null : _handleComplete,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(4),
                          child: _isCompleting
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      habitColor,
                                    ),
                                  ),
                                )
                              : Transform.scale(
                                  scale: 1.3,
                                  child: Checkbox(
                                    value: isCompleted,
                                    onChanged: (val) {
                                      if (!_isCompleting) {
                                        _handleComplete();
                                      }
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    activeColor: habitColor,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: const VisualDensity(
                                        horizontal: 0, vertical: 0),
                                    side: BorderSide(
                                        width: 2, color: habitColor),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // ), // End Dismissible
      ),
    );
  }

  Widget _buildExpandedContent(
      BuildContext context, AppLocalizations l10n, Color habitColor) {
    final habit = getLatestHabit(ref);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con emoji y nombre
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: habitColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.habit.emoji ?? '✓',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.habit.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    decoration: widget.habit.completedToday
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Subtasks section
          if (habit.subtasks.isNotEmpty) ...[
            Text(
              l10n.subtasks,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ...habit.subtasks.map((subtask) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        subtask.completed
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: subtask.completed
                            ? Colors.green
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subtask.title,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            decoration: subtask.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
          ],
          // Estadísticas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(
                icon: Icons.local_fire_department,
                label: l10n.currentStreak,
                value: '${widget.habit.currentStreak}',
                color: Colors.orange,
              ),
              _buildStat(
                icon: Icons.trending_up,
                label: l10n.longestStreak,
                value: '${widget.habit.longestStreak}',
                color: Colors.blue,
              ),
              _buildStat(
                icon: Icons.check_circle,
                label: 'Total',
                value: '${widget.habit.completionHistory.length}',
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Acciones
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onEdit != null
                      ? () async {
                          await widget.onEdit!(habit);
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        }
                      : null,
                  icon: const Icon(Icons.edit),
                  label: Text(l10n.edit),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _handleDelete,
                  icon: const Icon(Icons.delete),
                  label: Text(l10n.delete),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Skip and Fail options
          if (habit.dailyStatus == HabitDailyStatus.pending ||
              habit.dailyStatus == HabitDailyStatus.completed)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await _handleSkip();
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.skip_next),
                    label: Text(l10n.skipHabit),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await _handleFail();
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                    label: Text(l10n.markAsNotCompleted),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          // Espaciador invisible para evitar que las opciones se mezclen con la navegación del sistema
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
