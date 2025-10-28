import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../domain/habit.dart';
import '../constants/habit_colors.dart';
import '../../../../l10n/app_localizations.dart';

class HabitCompletionCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onUncheck;
  final VoidCallback? onDelete;
  final bool isCompleting;

  const HabitCompletionCard({
    super.key,
    required this.habit,
    required this.onTap,
    this.onEdit,
    this.onUncheck,
    this.onDelete,
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
    final habitColor = HabitColors.getHabitColor(widget.habit);

    return Card(
      key: Key('habit_completion_card_${widget.habit.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Colored left border
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: habitColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Checkbox on the left
                  Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(left: 8, right: 16),
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
                            size: 20,
                          )
                        : null,
                  ),
                  // Habit content
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
                                  color: widget.habit.completedToday
                                      ? Colors.grey.shade600
                                      : const Color(0xff1a202c),
                                  decoration: widget.habit.completedToday
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            // Emoji on the right if available
                            if (widget.habit.emoji != null &&
                                widget.habit.emoji!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                widget.habit.emoji!,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ],
                        ),
                        if (widget.habit.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.habit.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        // Show streak if > 0
                        if (widget.habit.currentStreak > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 14,
                                color: Colors.orange.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.habit.currentStreak} ${widget.habit.currentStreak == 1 ? 'día' : 'días'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Difficulty stars
                  if (widget.habit.difficulty != HabitDifficulty.medium)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Row(
                        children: List.generate(
                          HabitDifficultyHelper.getDifficultyStars(
                              widget.habit.difficulty),
                          (index) => Icon(
                            Icons.star,
                            size: 14,
                            color: habitColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  // 3-dot menu
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          widget.onEdit?.call();
                          break;
                        case 'uncheck':
                          widget.onUncheck?.call();
                          break;
                        case 'delete':
                          widget.onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit,
                                  size: 18, color: Colors.grey.shade700),
                              const SizedBox(width: 12),
                              Text(l10n.edit),
                            ],
                          ),
                        ),
                        if (widget.habit.completedToday)
                          PopupMenuItem(
                            value: 'uncheck',
                            child: Row(
                              children: [
                                Icon(Icons.check_box_outline_blank,
                                    size: 18, color: Colors.grey.shade700),
                                const SizedBox(width: 12),
                                Text(l10n.uncheck),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete,
                                  size: 18, color: Colors.red),
                              const SizedBox(width: 12),
                              Text(l10n.delete,
                                  style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_showAnimation)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Lottie.asset(
                    'assets/lottie/animation.json',
                    width: 100,
                    height: 100,
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
