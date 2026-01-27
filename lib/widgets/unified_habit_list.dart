import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/presentation/habits_providers.dart';
import '../l10n/app_localizations.dart';
import 'unified_habit_card.dart';

/// Unified habit list widget that combines:
/// - Visual design from habits_page (colored border)
/// - Reorderable items with drag-and-drop
/// - Dedicated subtask expansion button
/// - Historical view support
class UnifiedHabitList extends ConsumerWidget {
  final Future<void> Function(String habitId) onComplete;
  final Future<void> Function(String habitId) onUncheck;
  final Future<void> Function(String habitId) onDelete;
  final Future<void> Function(Habit habit)? onEdit;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final DateTime? selectedDate;

  const UnifiedHabitList({
    super.key,
    required this.onComplete,
    required this.onUncheck,
    required this.onDelete,
    this.onEdit,
    this.shrinkWrap = false,
    this.physics,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStreamProvider);
    final l10n = AppLocalizations.of(context)!;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final viewingDate = selectedDate != null
        ? DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day)
        : today;
    final isViewingToday = viewingDate == today;

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

        final displayHabits = selectedDate != null && !isViewingToday
            ? habits.map((habit) {
                final wasCompletedOnDate = habit.completionHistory.any((dt) {
                  final historyDay = DateTime(dt.year, dt.month, dt.day);
                  return historyDay == viewingDate;
                });
                return habit.copyWith(completedToday: wasCompletedOnDate);
              }).toList()
            : habits;

        final sortedHabits = [...displayHabits];
        sortedHabits.sort((a, b) {
          final aCompleted = selectedDate != null && !isViewingToday
              ? a.completedToday
              : a.dailyStatus == HabitDailyStatus.completed;
          final bCompleted = selectedDate != null && !isViewingToday
              ? b.completedToday
              : b.dailyStatus == HabitDailyStatus.completed;
          if (aCompleted != bCompleted) {
            return aCompleted ? 1 : -1;
          }
          return a.order.compareTo(b.order);
        });

        final hasPendingHabits = selectedDate != null && !isViewingToday
            ? sortedHabits.any((h) => !h.completedToday)
            : sortedHabits
                .any((h) => h.dailyStatus != HabitDailyStatus.completed);

        return Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
          ),
          child: ReorderableListView.builder(
            header: hasPendingHabits
                ? Padding(
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
                  )
                : null,
            footer: const SizedBox(height: 32),
            shrinkWrap: shrinkWrap,
            physics: physics ??
                (shrinkWrap
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics()),
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
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }

              final movedHabit = sortedHabits[oldIndex];
              final movedIsCompleted =
                  movedHabit.dailyStatus == HabitDailyStatus.completed;
              final completedStartIndex = sortedHabits.indexWhere(
                  (h) => h.dailyStatus == HabitDailyStatus.completed);

              if (completedStartIndex != -1) {
                if (movedIsCompleted && newIndex < completedStartIndex) {
                  return;
                }
                if (!movedIsCompleted && newIndex >= completedStartIndex) {
                  return;
                }
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
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
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
