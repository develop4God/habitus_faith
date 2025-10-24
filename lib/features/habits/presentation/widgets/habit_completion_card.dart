import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../domain/habit.dart';
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

    return Card(
      key: Key('habit_completion_card_${widget.habit.id}'),
      elevation: widget.habit.completedToday ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: widget.habit.completedToday
            ? BorderSide(color: const Color(0xff10b981), width: 2)
            : BorderSide.none,
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: widget.habit.completedToday
                              ? const Color(0xff10b981).withValues(alpha:0.1)
                              : const Color(0xff6366f1).withValues(alpha:0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.habit.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff1a202c),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
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
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xff10b981),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
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
                        color: const Color(0xff6366f1),
                      ),
                    ],
                  ),
                  if (!widget.habit.completedToday) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff6366f1).withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.touch_app,
                            size: 16,
                            color: Color(0xff6366f1),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.tapToComplete,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff6366f1),
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
                  color: Colors.white.withValues(alpha:0.95),
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
                  color: Colors.white.withValues(alpha:0.8),
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
