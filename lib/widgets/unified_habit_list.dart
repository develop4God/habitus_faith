import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/domain/models/habit_notification.dart';
import '../features/habits/presentation/constants/habit_colors.dart';
import '../features/habits/presentation/widgets/habit_card/habit_modal_sheet.dart';
import '../features/habits/presentation/habits_providers.dart';
import '../l10n/app_localizations.dart';

/// Unified habit list widget that combines:
/// - Visual design from habits_page (colored border)
/// - Swipe-to-complete functionality
/// - Tap-to-expand details from CompactHabitCard
class UnifiedHabitList extends ConsumerWidget {
  final Future<void> Function(String habitId) onComplete;
  final Future<void> Function(String habitId) onUncheck;
  final Future<void> Function(String habitId) onDelete;
  final Future<void> Function(Habit habit)? onEdit;

  const UnifiedHabitList({
    super.key,
    required this.onComplete,
    required this.onUncheck,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStreamProvider);
    final l10n = AppLocalizations.of(context)!;

    return habitsAsync.when(
      data: (habits) {
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

        // Sort habits: pending/skipped/failed first (by order), completed last (by order)
        final sortedHabits = [...habits];
        sortedHabits.sort((a, b) {
          final aCompleted = a.dailyStatus == HabitDailyStatus.completed;
          final bCompleted = b.dailyStatus == HabitDailyStatus.completed;
          if (aCompleted != bCompleted) return aCompleted ? 1 : -1;
          return a.order.compareTo(b.order);
        });

        final hasPendingHabits =
            sortedHabits.any((h) => h.dailyStatus != HabitDailyStatus.completed);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasPendingHabits)
              Padding(
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
                ),
              ),

            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: sortedHabits.length,
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) {
                    final double animValue =
                        Curves.easeInOut.transform(animation.value);
                    final double elevation = lerpDouble(0, 6, animValue)!;
                    final double scale = lerpDouble(1, 1.02, animValue)!;
                    return Transform.scale(
                      scale: scale,
                      child: Material(
                        elevation: elevation,
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: child,
                      ),
                    );
                  },
                );
              },
              onReorderStart: (_) => HapticFeedback.mediumImpact(),
              onReorder: (oldIndex, newIndex) async {
                if (newIndex > oldIndex) newIndex -= 1;

                final movedHabit = sortedHabits[oldIndex];
                final movedIsCompleted = movedHabit.dailyStatus == HabitDailyStatus.completed;
                final completedStartIndex = sortedHabits.indexWhere((h) => h.dailyStatus == HabitDailyStatus.completed);

                if (completedStartIndex != -1) {
                  if (movedIsCompleted && newIndex < completedStartIndex) return;
                  if (!movedIsCompleted && newIndex >= completedStartIndex) return;
                }

                final reorderedHabits = [...sortedHabits];
                final item = reorderedHabits.removeAt(oldIndex);
                reorderedHabits.insert(newIndex, item);

                HapticFeedback.lightImpact();
                await ref.read(habitsNotifierProvider.notifier).reorderHabits(
                  reorderedHabits.map((h) => h.id).toList(),
                );
              },
              itemBuilder: (context, index) {
                final habit = sortedHabits[index];
                // Using Delayed listener to ensure scroll takes priority over reorder
                return ReorderableDelayedDragStartListener(
                  key: Key('habit_${habit.id}'),
                  index: index,
                  child: UnifiedHabitCard(
                    habit: habit,
                    onComplete: onComplete,
                    onUncheck: onUncheck,
                    onDelete: onDelete,
                    onEdit: onEdit,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      )),
      error: (err, stack) => Center(child: Text(l10n.errorUnknown)),
    );
  }

  double? lerpDouble(num? a, num? b, double t) {
    if (a == null && b == null) return null;
    a ??= 0.0;
    b ??= 0.0;
    return a + (b - a) * t;
  }
}

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
    setState(() => _isCompleting = true);
    try {
      final habit = getLatestHabit(ref);
      if (habit.completedToday) {
        await widget.onUncheck(habit.id);
      } else {
        await widget.onComplete(habit.id);
      }
    } finally {
      if (mounted) setState(() => _isCompleting = false);
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
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.onDelete(habit.id);
      if (!mounted) return;
      
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.habitDeleted),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleSkip() async {
    final l10n = AppLocalizations.of(context)!;
    final habit = getLatestHabit(ref);
    await ref.read(habitsNotifierProvider.notifier).skipHabit(habit.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.habitSkipped), duration: const Duration(seconds: 2)));
  }

  Future<void> _handleFail() async {
    final l10n = AppLocalizations.of(context)!;
    final habit = getLatestHabit(ref);
    await ref.read(habitsNotifierProvider.notifier).failHabit(habit.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.habitMarkedAsNotCompleted), duration: const Duration(seconds: 2)));
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
            border: Border(left: BorderSide(color: habitColor, width: 4)),
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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: habitColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(widget.habit.emoji ?? '✓', style: const TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 16),
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
                                  color: isCompleted ? Colors.green.shade900 : Colors.grey.shade900,
                                  decoration: (isCompleted || isSkipped || isFailed) ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            if (isSkipped)
                              _buildStatusBadge(l10n.skippedHabit, Colors.orange)
                            else if (isFailed)
                              _buildStatusBadge(l10n.failedHabit, Colors.red),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.local_fire_department, size: 14, color: widget.habit.currentStreak > 0 ? Colors.orange.shade600 : Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(l10n.dayStreak(widget.habit.currentStreak), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildActions(context, ref, l10n, habit, isCompleted, habitColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.shade100, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 10, color: color.shade900, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, AppLocalizations l10n, Habit habit, bool isCompleted, Color habitColor) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            habit.notificationSettings != null ? Icons.notifications_active : Icons.notifications_none,
            color: habit.notificationSettings != null ? Colors.orange : Colors.grey,
          ),
          onPressed: () => _handleNotification(context, ref, l10n, habit),
        ),
        InkWell(
          onTap: _isCompleting ? null : _handleComplete,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(4),
            child: _isCompleting
                ? Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(habitColor))))
                : Transform.scale(
                    scale: 1.3,
                    child: Checkbox(
                      value: isCompleted,
                      onChanged: (_) => _handleComplete(),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      activeColor: habitColor,
                      side: BorderSide(width: 2, color: habitColor),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleNotification(BuildContext context, WidgetRef ref, AppLocalizations l10n, Habit habit) async {
    final notifier = ref.read(habitsNotifierProvider.notifier);
    if (habit.notificationSettings != null) {
      await notifier.updateHabit(habitId: habit.id, notificationSettings: null);
    } else {
      final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (picked != null) {
        final settings = HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
        );
        await notifier.updateHabit(habitId: habit.id, notificationSettings: settings);
      }
    }
  }

  Widget _buildExpandedContent(BuildContext context, AppLocalizations l10n, Color habitColor) {
    final habit = getLatestHabit(ref);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: habitColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Center(child: Text(widget.habit.emoji ?? '✓', style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(widget.habit.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, decoration: isHabitCompleted(habit) ? TextDecoration.lineThrough : null))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(Icons.local_fire_department, l10n.currentStreak, '${habit.currentStreak}', Colors.orange),
              _buildStat(Icons.trending_up, l10n.longestStreak, '${habit.longestStreak}', Colors.blue),
              _buildStat(Icons.check_circle, 'Total', '${habit.completionHistory.length}', Colors.green),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => widget.onEdit?.call(habit), icon: const Icon(Icons.edit), label: Text(l10n.edit))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(onPressed: _handleDelete, icon: const Icon(Icons.delete), label: Text(l10n.delete), style: OutlinedButton.styleFrom(foregroundColor: Colors.red))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: _handleSkip, icon: const Icon(Icons.skip_next), label: Text(l10n.skipHabit), style: OutlinedButton.styleFrom(foregroundColor: Colors.orange.shade700))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(onPressed: _handleFail, icon: const Icon(Icons.close), label: Text(l10n.markAsNotCompleted), style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700))),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  bool isHabitCompleted(Habit habit) => habit.dailyStatus == HabitDailyStatus.completed;

  Widget _buildStat(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), textAlign: TextAlign.center),
      ],
    );
  }
}
