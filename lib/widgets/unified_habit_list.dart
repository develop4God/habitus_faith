import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/domain/models/habit_notification.dart';
import '../features/habits/presentation/constants/habit_colors.dart';
import '../features/habits/presentation/widgets/habit_card/habit_modal_sheet.dart';
import '../l10n/app_localizations.dart';

/// Unified habit list widget that combines:
/// - Visual design from habits_page (colored border)
/// - Swipe-to-delete functionality from home_page
/// - Tap-to-expand details from CompactHabitCard
class UnifiedHabitList extends ConsumerWidget {
  final List<Habit> habits;
  final Future<void> Function(String habitId) onComplete;
  final Future<void> Function(String habitId) onUncheck;
  final Future<void> Function(String habitId) onDelete;
  final Future<void> Function(Habit habit)? onEdit;
  final bool showSwipeHint;

  const UnifiedHabitList({
    super.key,
    required this.habits,
    required this.onComplete,
    required this.onUncheck,
    required this.onDelete,
    this.onEdit,
    this.showSwipeHint = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint(
        '🟢 UnifiedHabitList.build: Recibidos ${habits.length} hábitos: ${habits.map((h) => h.name).toList()}');
    if (habits.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
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

    return Column(
      children: [
        ...habits.map((habit) => UnifiedHabitCard(
              habit: habit,
              onComplete: onComplete,
              onUncheck: onUncheck,
              onDelete: onDelete,
              onEdit: onEdit,
            )),
        if (showSwipeHint && habits.any((h) => !h.completedToday))
          _buildSwipeHint(context),
      ],
    );
  }

  Widget _buildSwipeHint(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.swipe_left, size: 16, color: Colors.grey.shade500),
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

  Future<void> _handleComplete() async {
    if (_isCompleting) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      if (widget.habit.completedToday) {
        debugPrint('Desmarcando hábito: ${widget.habit.id}');
        await widget.onUncheck(widget.habit.id);
      } else {
        debugPrint('Marcando hábito: ${widget.habit.id}');
        await widget.onComplete(widget.habit.id);
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteHabit),
        content: Text(l10n.deleteHabitConfirm(widget.habit.name)),
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
      await widget.onDelete(widget.habit.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final habitColor = HabitColors.getHabitColor(widget.habit);
    final isCompleted = widget.habit.completedToday;

    return AnimatedScale(
      scale: isCompleted ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
          child: Container(
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green.shade50 : Colors.white,
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
                          Text(
                            widget.habit.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? Colors.green.shade900
                                  : Colors.grey.shade900,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
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
                        ],
                      ),
                    ),
                    // Checkbox más grande y notification bell juntos
                    Row(
                      children: [
                        // Notification bell button (left of checkbox)
                        IconButton(
                          icon: Icon(
                            widget.habit.notificationSettings != null &&
                                    widget.habit.notificationSettings!.timing != NotificationTiming.none
                                ? Icons.notifications_active
                                : Icons.notifications_none,
                            color: widget.habit.notificationSettings != null &&
                                    widget.habit.notificationSettings!.timing != NotificationTiming.none
                                ? Colors.orange
                                : Colors.grey,
                          ),
                          tooltip: l10n.reminderConfig,
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: widget.habit.notificationSettings?.eventTime != null && widget.habit.notificationSettings!.eventTime!.contains(':')
                                  ? TimeOfDay(
                                      hour: int.parse(widget.habit.notificationSettings!.eventTime!.split(':')[0]),
                                      minute: int.parse(widget.habit.notificationSettings!.eventTime!.split(':')[1]),
                                    )
                                  : TimeOfDay.now(),
                            );
                            if (picked != null) {
                              final settings = HabitNotificationSettings(
                                timing: NotificationTiming.atEventTime,
                                eventTime: '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                              );
                              if (widget.onEdit != null) {
                                await widget.onEdit!(
                                  widget.habit.copyWith(notificationSettings: settings),
                                );
                                setState(() {});
                              }
                            }
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
                                      side: BorderSide(width: 2, color: habitColor),
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
        ),
      ),
    );
  }

  Widget _buildExpandedContent(
      BuildContext context, AppLocalizations l10n, Color habitColor) {
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
                          await widget.onEdit!(widget.habit);
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
