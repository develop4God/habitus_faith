import 'package:flutter/material.dart';
          import 'package:flutter_riverpod/flutter_riverpod.dart';
          import '../../../domain/habit.dart';
          import '../mini_calendar_heatmap.dart';
          import '../../../../../l10n/app_localizations.dart';
          import '../../constants/habit_colors.dart';

          /// Advanced habit card with full tracking info always visible
          /// Shows all details inline: name, description, stats, calendar, actions
          class AdvancedHabitCard extends ConsumerStatefulWidget {
            final Habit habit;
            final VoidCallback onDelete;
            final VoidCallback onEdit;
            final Function(String) onComplete;
            final Function(String) onUncheck;

            const AdvancedHabitCard({
              super.key,
              required this.habit,
              required this.onDelete,
              required this.onEdit,
              required this.onComplete,
              required this.onUncheck,
            });

            @override
            ConsumerState<AdvancedHabitCard> createState() => _AdvancedHabitCardState();
          }

          class _AdvancedHabitCardState extends ConsumerState<AdvancedHabitCard> {
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
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with emoji, name, and completion button
                      Row(
                        children: [
                          // Habit emoji/icon
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: habitColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                widget.habit.emoji ?? '✓',
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Habit name and description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.habit.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (widget.habit.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.habit.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Simple completion checkbox button
                          InkWell(
                            onTap: _isCompleting ? null : _handleComplete,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 48,
                              height: 48,
                              padding: const EdgeInsets.all(10),
                              child: _isCompleting
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(habitColor),
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
                                          width: 2.5,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: widget.habit.completedToday
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 20,
                                            )
                                          : null,
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Stats row - always visible
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: habitColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              l10n.streak,
                              '${widget.habit.currentStreak}',
                              Icons.local_fire_department,
                              Colors.orange,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            _buildStatItem(
                              'Total',
                              '${widget.habit.completionHistory.length}',
                              Icons.check_circle,
                              Colors.green,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Mini calendar - always visible
                      MiniCalendarHeatmap(
                        completionDates: widget.habit.completionHistory,
                      ),
                      const SizedBox(height: 16),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: widget.onEdit,
                            icon: const Icon(Icons.edit, size: 18),
                            label: Text(l10n.edit),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: habitColor,
                              side: BorderSide(color: habitColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: widget.onDelete,
                            icon: const Icon(Icons.delete, size: 18),
                            label: Text(l10n.delete),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }

            Widget _buildStatItem(
                String label, String value, IconData icon, Color color) {
              return Column(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }
          }