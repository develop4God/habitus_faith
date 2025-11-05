import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/habit.dart';
import '../habit_completion_card.dart';
import '../mini_calendar_heatmap.dart';
import '../../../../../l10n/app_localizations.dart';

/// Advanced habit card with full tracking info always visible
/// Shows all details inline: name, description, stats, calendar, actions
class AdvancedHabitCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final habitColor = Color(habit.colorValue ?? 0xFF6366F1);

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
              mainAxisSize: MainAxisSize.max,
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
                      habit.emoji ?? '✓',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Habit name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (habit.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          habit.description,
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

                // Completion button
                HabitCompletionCard(
                  key: Key('habit_completion_${habit.id}'),
                  habit: habit,
                  onTap: () => onComplete(habit.id),
                  onUncheck: () => onUncheck(habit.id),
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
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    l10n.streak,
                    '${habit.currentStreak}',
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
                    '${habit.completionHistory.length}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Mini calendar - always visible
            MiniCalendarHeatmap(
              completionDates: habit.completionHistory,
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(l10n.edit),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: habitColor,
                    side: BorderSide(color: habitColor),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onDelete,
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
