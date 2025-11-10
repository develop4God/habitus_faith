import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/habit.dart';
import '../mini_calendar_heatmap.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../constants/habit_colors.dart';
import '../abandonment_risk_indicator.dart';

/// Compact habit card with tap-to-expand details
/// Shows only essential info: name, emoji, streak, completion button
class CompactHabitCard extends ConsumerStatefulWidget {
  final Habit habit;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final Function(String) onComplete;
  final Function(String) onUncheck;

  const CompactHabitCard({
    super.key,
    required this.habit,
    required this.onDelete,
    required this.onEdit,
    required this.onComplete,
    required this.onUncheck,
  });

  @override
  ConsumerState<CompactHabitCard> createState() => _CompactHabitCardState();
}

class _CompactHabitCardState extends ConsumerState<CompactHabitCard> {
  bool _isExpanded = false;
  bool _isCompleting = false;

  Future<void> _handleComplete() async {
    if (_isCompleting) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      if (widget.habit.completedToday) {
        await widget.onUncheck(widget.habit.id);
      } else {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final habitColor = HabitColors.getHabitColor(widget.habit);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Compact view - always visible
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  // Color indicator bar
                  Container(
                    width: 4,
                    height: 48,
                    decoration: BoxDecoration(
                      color: habitColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Simple completion checkbox button (ahora a la izquierda)
                  InkWell(
                    onTap: _isCompleting ? null : _handleComplete,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      child: _isCompleting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(habitColor),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: widget.habit.completedToday
                                    ? habitColor
                                    : Colors.transparent,
                                border: Border.all(
                                  color: widget.habit.completedToday
                                      ? habitColor
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: widget.habit.completedToday
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Habit emoji/icon
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

                  // Habit name and streak
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.habit.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: widget.habit.completedToday
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationThickness: 2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 16,
                              color: widget.habit.currentStreak > 0
                                  ? Colors.orange
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.habit.currentStreak} ${l10n.days}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (widget.habit.abandonmentRisk > 0.0) ...[
                              const SizedBox(width: 12),
                              AbandonmentRiskIndicator(
                                risk: widget.habit.abandonmentRisk,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Expand indicator
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),

          // Expanded details - shown when tapped
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                color: habitColor.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Description
                  if (widget.habit.description.isNotEmpty) ...[
                    Text(
                      widget.habit.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        l10n.streak,
                        '${widget.habit.currentStreak}',
                        Icons.local_fire_department,
                        Colors.orange,
                      ),
                      _buildStatItem(
                        l10n.total,
                        '${widget.habit.completionHistory.length}',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Mini calendar
                  MiniCalendarHeatmap(
                    completionDates: widget.habit.completionHistory,
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.grey.shade700,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            widget.onEdit();
                          } else if (value == 'delete') {
                            widget.onDelete();
                          } else if (value == 'uncheck' &&
                              widget.habit.completedToday) {
                            widget.onUncheck(widget.habit.id);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          if (widget.habit.completedToday)
                            PopupMenuItem<String>(
                              value: 'uncheck',
                              child: Row(
                                children: [
                                  const Icon(Icons.undo,
                                      size: 20, color: Colors.orange),
                                  const SizedBox(width: 12),
                                  Text(l10n.uncheck),
                                ],
                              ),
                            ),
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 20),
                                const SizedBox(width: 12),
                                Text(l10n.edit),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete,
                                    size: 20, color: Colors.red),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.delete,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
