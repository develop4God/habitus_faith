import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../domain/habit.dart';
import '../constants/habit_colors.dart';
import '../../../../l10n/app_localizations.dart';

class HabitCompletionCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback onTap;
  final bool isCompleting;

  const HabitCompletionCard({
    super.key,
    required this.habit,
    required this.onTap,
    this.isCompleting = false,
  });

  @override
  State<HabitCompletionCard> createState() => _HabitCompletionCardState();
}

class _HabitCompletionCardState extends State<HabitCompletionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.habit.completedToday && !widget.isCompleting) {
      setState(() {
        _showAnimation = true;
      });
      _animationController.forward().then((_) {
        widget.onTap();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _showAnimation = false;
            });
            _animationController.reset();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final emoji = widget.habit.emoji ?? '✨';
    final habitColor = HabitColors.getHabitColor(widget.habit);
    
    // Calculate weekly progress for gamification
    final weeklyProgress = _calculateWeeklyProgress();

    return Card(
      key: Key('habit_completion_card_${widget.habit.id}'),
      elevation: widget.habit.completedToday ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: widget.habit.completedToday
            ? BorderSide(color: habitColor, width: 2)
            : BorderSide.none,
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(24.0), // Increased padding for better tap target
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64, // Larger icon container
                        height: 64,
                        decoration: BoxDecoration(
                          color: widget.habit.completedToday
                              ? habitColor.withValues(alpha: 0.2)
                              : habitColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 32), // Larger emoji
                          ),
                        ),
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
                                    style: const TextStyle(
                                      fontSize: 19, // Slightly larger
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff1a202c),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Difficulty indicator
                                ...List.generate(
                                  HabitDifficultyHelper.getDifficultyStars(widget.habit.difficulty),
                                  (index) => Icon(
                                    Icons.star,
                                    size: 16,
                                    color: HabitDifficultyHelper.getDifficultyColor(widget.habit.difficulty),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.habit.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (widget.habit.completedToday)
                        Container(
                          padding: const EdgeInsets.all(10), // Larger tap target
                          decoration: BoxDecoration(
                            color: habitColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Weekly progress bar (preparation for gamification)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progreso semanal',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${(weeklyProgress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: habitColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: weeklyProgress,
                          backgroundColor: habitColor.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(habitColor),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StreakBadge(
                        icon: Icons.local_fire_department,
                        label: l10n.currentStreak,
                        value: widget.habit.currentStreak.toString(),
                        color: const Color(0xfff59e0b),
                      ),
                      _StreakBadge(
                        icon: Icons.emoji_events,
                        label: l10n.best,
                        value: widget.habit.longestStreak.toString(),
                        color: habitColor,
                      ),
                    ],
                  ),
                  if (!widget.habit.completedToday) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity, // Full width for better tap target
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: habitColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 18,
                            color: habitColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.tapToComplete,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: habitColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_showAnimation)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Lottie.asset(
                    'assets/lottie/animation.json',
                    width: 150,
                    height: 150,
                    controller: _animationController,
                    onLoaded: (composition) {
                      _animationController.duration = composition.duration;
                    },
                  ),
                ),
              ),
            ),
          if (widget.isCompleting)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Calculate weekly completion rate (7 days)
  double _calculateWeeklyProgress() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int completedDays = 0;

    for (int i = 0; i < 7; i++) {
      final day = today.subtract(Duration(days: i));
      final isCompleted = widget.habit.completionHistory.any((date) {
        final completionDay = DateTime(date.year, date.month, date.day);
        return completionDay == day;
      });
      if (isCompleted) completedDays++;
    }

    return completedDays / 7.0;
  }
}

class _StreakBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StreakBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
