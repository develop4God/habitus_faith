import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/domain/models/habit_notification.dart';
import '../features/habits/presentation/constants/habit_colors.dart';
import '../features/habits/presentation/widgets/habit_card/habit_modal_sheet.dart';
import '../features/habits/presentation/habits_providers.dart';
import '../features/habits/presentation/widgets/abandonment_risk_indicator.dart';
import '../features/common/presentation/widgets/task_timer.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import '../core/utils/global_snackbar.dart';
import 'notification_options_dialog.dart';
import 'subtasks_section.dart';

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

class _UnifiedHabitCardState extends ConsumerState<UnifiedHabitCard>
    with SingleTickerProviderStateMixin {
  bool _isCompleting = false;
  bool _isExpanded = false;
  late final AnimationController _timerPulseController;

  @override
  void initState() {
    super.initState();
    _timerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timerPulseController.dispose();
    super.dispose();
  }

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
      final habit = widget.habit;
      if (habit.completedToday) {
        // Completed → uncheck back to pending
        await widget.onUncheck(habit.id);
      } else if (habit.dailyStatus == HabitDailyStatus.skipped ||
          habit.dailyStatus == HabitDailyStatus.failed) {
        // Skipped / failed → reset back to pending first, then complete
        await ref.read(habitsNotifierProvider.notifier).resetHabit(habit.id);
        await widget.onComplete(habit.id);
      } else {
        // Pending → complete
        await widget.onComplete(habit.id);
      }
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  Future<void> _handleDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final habit = widget.habit;

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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      Navigator.of(context).pop();
      await Future.delayed(const Duration(milliseconds: 300));
      await widget.onDelete(habit.id);
      GlobalSnackbar.showError(l10n.habitDeleted);
    }
  }

  Future<void> _handleSkip() async {
    final l10n = AppLocalizations.of(context)!;
    final habit = widget.habit;
    if (!mounted) return;
    Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 300));
    await ref.read(habitsNotifierProvider.notifier).skipHabit(habit.id);
    GlobalSnackbar.showWarning(l10n.habitSkipped);
  }

  Future<void> _handleDuplicate() async {
    final l10n = AppLocalizations.of(context)!;
    final habit = widget.habit;
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.copyHabit),
        content: Text(l10n.copyHabitConfirm(habit.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.copy),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 300));
    await ref
        .read(habitsNotifierProvider.notifier)
        .duplicateHabitFromData(habit);
    GlobalSnackbar.showSuccess(l10n.copy);
  }

  void _showTimer(
      BuildContext context, Color habitColor, AppLocalizations l10n) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => TaskTimer(
        habitName: widget.habit.name,
        initialSeconds: widget.habit.targetMinutes * 60,
        activeColor: habitColor,
        onCompleted: () {
          _handleComplete();
          GlobalSnackbar.showSuccess(l10n.focusComplete);
        },
        onFinish: () {
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showSubtasksEditor(BuildContext context, Habit habit, Color habitColor,
      AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.subtasks,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: SubtasksSection(
                    initialSubtasks: habit.subtasks,
                    onSubtasksChanged: (newSubtasks) async {
                      await ref
                          .read(habitsNotifierProvider.notifier)
                          .updateHabit(
                            habitId: habit.id,
                            subtasks: newSubtasks,
                          );
                    },
                    showAddButton: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final habit = widget.habit;
    final habitColor = HabitColors.getHabitColor(habit);
    final isCompleted = habit.completedToday;
    final isSkipped = habit.dailyStatus == HabitDailyStatus.skipped;
    final isFailed = habit.dailyStatus == HabitDailyStatus.failed;

    // Derived light color for modern card background
    final cardColor = isCompleted
        ? Colors.green.shade50
        : isSkipped
            ? Colors.orange.shade50
            : isFailed
                ? Colors.red.shade50
                : habitColor.withValues(alpha: 0.08);

    return AnimatedScale(
      scale: (isCompleted || isSkipped || isFailed) ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await HabitModalSheet.show(
                  context: context,
                  child: Builder(
                    builder: (modalContext) =>
                        _buildExpandedContent(modalContext, l10n, habitColor),
                  ),
                  maxHeight: 520,
                );
                if (!mounted) return;
                setState(() {});
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: habitColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.habit.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isCompleted
                                            ? Colors.green.shade900
                                            : Colors.grey.shade900,
                                        decoration: (isCompleted ||
                                                isSkipped ||
                                                isFailed)
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                  if (isSkipped || isFailed) ...[
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: _buildStatusBadge(
                                        isSkipped
                                            ? l10n.skippedHabit
                                            : l10n.failedHabit,
                                        isSkipped ? Colors.orange : Colors.red,
                                      ),
                                    ),
                                  ],
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
                                  const SizedBox(width: 8),
                                  AbandonmentRiskIndicator(
                                    risk: habit.abandonmentRisk,
                                  ),
                                  if (habit.subtasks.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        setState(
                                          () => _isExpanded = !_isExpanded,
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: habitColor.withValues(
                                            alpha: 0.15,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          _isExpanded
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                          size: 20,
                                          color: habitColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        _buildActions(
                          context,
                          ref,
                          l10n,
                          habit,
                          isCompleted,
                          habitColor,
                        ),
                      ],
                    ),
                    if (habit.subtasks.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildSubtasksProgress(habit, habitColor),
                      if (_isExpanded) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        _buildInlineSubtasks(habit, habitColor),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineSubtasks(Habit habit, Color habitColor) {
    return Column(
      children: habit.subtasks.map((subtask) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: InkWell(
            onTap: () async {
              final newSubtasks = habit.subtasks.map((s) {
                if (s.id == subtask.id) {
                  return s.copyWith(completed: !s.completed);
                }
                return s;
              }).toList();
              await ref
                  .read(habitsNotifierProvider.notifier)
                  .updateHabit(habitId: habit.id, subtasks: newSubtasks);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                children: [
                  Icon(
                    subtask.completed
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    size: 18,
                    color:
                        subtask.completed ? habitColor : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      subtask.title,
                      style: TextStyle(
                        fontSize: 14,
                        decoration: subtask.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: subtask.completed
                            ? Colors.grey.shade500
                            : Colors.grey.shade800,
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

  Widget _buildSubtasksProgress(Habit habit, Color color) {
    final completedCount = habit.subtasks.where((s) => s.completed).length;
    final totalCount = habit.subtasks.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$completedCount/$totalCount',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10,
          color: color.shade900,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Habit habit,
    bool isCompleted,
    Color habitColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(8),
          icon: Icon(
            habit.hasActiveNotification
                ? Icons.notifications_active
                : Icons.notifications_none,
            size: 22,
            color: habit.hasActiveNotification ? Colors.orange : Colors.grey,
          ),
          onPressed: () => _handleNotification(context, ref, l10n, habit),
        ),
        InkWell(
          onTap: _isCompleting ? null : _handleComplete,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(2),
            child: _isCompleting
                ? Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(habitColor),
                      ),
                    ),
                  )
                : Transform.scale(
                    scale: 1.1,
                    child: Checkbox(
                      value: isCompleted,
                      onChanged: (_) => _handleComplete(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      activeColor: habitColor,
                      side: BorderSide(width: 2, color: habitColor),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleNotification(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Habit habit,
  ) async {
    final notifier = ref.read(habitsNotifierProvider.notifier);

    if (habit.hasActiveNotification) {
      final currentTime = habit.notificationSettings?.eventTime;
      if (currentTime == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.invalidNotificationConfig),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final result = await showDialog<String>(
        context: context,
        builder: (context) =>
            NotificationOptionsDialog(currentTime: currentTime),
      );

      if (result == 'turnOff') {
        await notifier.updateHabit(
          habitId: habit.id,
          notificationSettings: const HabitNotificationSettings(
            timing: NotificationTiming.none,
          ),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.notificationTurnedOff)));
        }
      } else if (result == 'changeTime') {
        if (!context.mounted) return;
        final picked = await showTimePicker(
          context: context,
          initialTime: _parseTime(currentTime),
        );
        if (picked != null) {
          final settings = HabitNotificationSettings(
            timing: NotificationTiming.atEventTime,
            eventTime:
                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
          );
          await notifier.updateHabit(
            habitId: habit.id,
            notificationSettings: settings,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.notificationTimeChanged)),
            );
          }
        }
      }
    } else {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null) {
        final settings = HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime:
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
        );
        await notifier.updateHabit(
          habitId: habit.id,
          notificationSettings: settings,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.notificationTimeChanged)));
        }
      }
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null &&
          minute != null &&
          hour >= 0 &&
          hour <= 23 &&
          minute >= 0 &&
          minute <= 59) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return TimeOfDay.now();
  }

  Widget _buildExpandedContent(
    BuildContext context,
    AppLocalizations l10n,
    Color habitColor,
  ) {
    final habit = widget.habit;
    final isCompleted = habit.dailyStatus == HabitDailyStatus.completed;
    final isSkipped = habit.dailyStatus == HabitDailyStatus.skipped;
    final isFailed = habit.dailyStatus == HabitDailyStatus.failed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      _showSubtasksEditor(
                          this.context, habit, habitColor, l10n);
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: habitColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: habitColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.checklist_rtl_outlined,
                        color: habitColor,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.subtasks,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: habitColor,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () async {
                      Navigator.of(context).pop();
                      _showTimer(this.context, habitColor, l10n);
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: AnimatedBuilder(
                      animation: _timerPulseController,
                      builder: (context, child) {
                        final pulse = 0.95 +
                            0.07 *
                                Curves.easeInOut
                                    .transform(_timerPulseController.value);
                        final shadowOpacity =
                            0.15 + 0.25 * _timerPulseController.value;
                        return Transform.scale(
                          scale: pulse,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  habitColor.withValues(alpha: 0.4),
                                  habitColor.withValues(alpha: 0.15),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: habitColor.withValues(alpha: 0.5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: habitColor.withValues(
                                      alpha: shadowOpacity),
                                  blurRadius: 14,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        Icons.timer_outlined,
                        color: habitColor,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.timer,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: habitColor,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: habitColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          habit.emoji ?? '✓',
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AutoSizeText(
                      habit.name,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      minFontSize: 12,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade900,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AbandonmentRiskIndicator(risk: habit.abandonmentRisk),
                    const SizedBox(height: 16),
                  ],
                ),
                Row(
                  children: [
                    _buildModernStatCard(
                      Icons.local_fire_department,
                      l10n.currentStreak,
                      '${habit.currentStreak}',
                      Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _buildModernStatCard(
                      Icons.emoji_events,
                      l10n.longestStreak,
                      '${habit.longestStreak}',
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildModernStatCard(
                      Icons.check_circle_rounded,
                      l10n.total,
                      '${habit.completionHistory.length}',
                      Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (isSkipped || isFailed) ...[
                  // Unskip / un-fail: reset back to pending
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await Future.delayed(const Duration(milliseconds: 150));
                        await ref
                            .read(habitsNotifierProvider.notifier)
                            .resetHabit(habit.id);
                      },
                      icon: const Icon(Icons.replay_rounded),
                      label: Text(
                        isSkipped ? l10n.uncheck : l10n.uncheck,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isSkipped
                            ? Colors.orange.shade700
                            : Colors.red.shade700,
                        side: BorderSide(
                          color: isSkipped
                              ? Colors.orange.shade300
                              : Colors.red.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _handleComplete();
                      },
                      icon: const Icon(Icons.check_rounded, size: 28),
                      label: Text(
                        l10n.completeNow,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: habitColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ] else if (!isCompleted)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _handleComplete();
                      },
                      icon: const Icon(Icons.check_rounded, size: 28),
                      label: Text(
                        l10n.completeNow,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: habitColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _handleComplete();
                      },
                      icon: const Icon(Icons.undo_rounded),
                      label: Text(l10n.uncheck),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCircularAction(
                      Icons.edit_rounded,
                      l10n.edit,
                      Colors.blueGrey.shade600,
                      () {
                        Navigator.of(context).pop();
                        widget.onEdit?.call(habit);
                      },
                    ),
                    _buildCircularAction(
                      Icons.fast_forward_rounded,
                      l10n.skipHabit,
                      Colors.orange.shade700,
                      _handleSkip,
                    ),
                    _buildCircularAction(
                      Icons.copy_rounded,
                      l10n.copy,
                      Colors.purple.shade500,
                      _handleDuplicate,
                    ),
                    _buildCircularAction(
                      Icons.delete_outline_rounded,
                      l10n.delete,
                      Colors.red.shade400,
                      _handleDelete,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStatCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.1), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            SizedBox(
              height: 28,
              child: Center(
                child: AutoSizeText(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  minFontSize: 8,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.7),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: SizedBox(
              height: 36,
              child: AutoSizeText(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                minFontSize: 13,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
