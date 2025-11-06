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
    debugPrint('HabitCompletionCard initState: ${widget.habit.name}');
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
    debugPrint(
        'HabitCompletionCard tap: completed=${widget.habit.completedToday}, isCompleting=${widget.isCompleting}');
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
    debugPrint('HabitCompletionCard building: ${widget.habit.name}');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        minHeight: 80,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Main card content
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Colored left border
                  Container(
                    width: 20,
                    color: habitColor,
                  ),
                  // Content
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 16.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Checkbox
                              Container(
                                width: 28,
                                height: 28,
                                margin: const EdgeInsets.only(right: 12),
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
                              // Habit details - Now flexible
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Name - single line with ellipsis
                                    Text(
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // Description
                                    if (widget.habit.description.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          widget.habit.description,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    // Streak
                                    if (widget.habit.currentStreak > 0)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 6.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.local_fire_department,
                                              size: 14,
                                              color: Colors.orange.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                '${widget.habit.currentStreak} ${widget.habit.currentStreak == 1 ? 'día' : 'días'}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Emoji - separate and flexible
                              if (widget.habit.emoji != null &&
                                  widget.habit.emoji!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    widget.habit.emoji!,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              // Right side - menu and stars
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Difficulty stars
                                  if (widget.habit.difficulty !=
                                      HabitDifficulty.medium)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 4.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(
                                          HabitDifficultyHelper
                                              .getDifficultyStars(
                                                  widget.habit.difficulty),
                                          (index) => Icon(
                                            Icons.star,
                                            size: 14,
                                            color: habitColor.withValues(
                                                alpha: 0.6),
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Menu
                                  SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      iconSize: 20,
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      ),
                                      onSelected: (value) {
                                        debugPrint('Menu selected: $value');
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
                                        final l10n =
                                            AppLocalizations.of(context)!;
                                        return [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.edit,
                                                    size: 18,
                                                    color:
                                                        Colors.grey.shade700),
                                                const SizedBox(width: 12),
                                                Text(l10n.edit),
                                              ],
                                            ),
                                          ),
                                          if (widget.habit.completedToday)
                                            PopupMenuItem(
                                              value: 'uncheck',
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .check_box_outline_blank,
                                                      size: 18,
                                                      color:
                                                          Colors.grey.shade700),
                                                  const SizedBox(width: 12),
                                                  Text(l10n.uncheck),
                                                ],
                                              ),
                                            ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.delete,
                                                    size: 18,
                                                    color: Colors.red),
                                                const SizedBox(width: 12),
                                                Text(l10n.delete,
                                                    style: const TextStyle(
                                                        color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ];
                                      },
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
                ],
              ),
            ),
          ),
          // Animation overlay
          if (_showAnimation)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.95),
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
            ),
          // Loading overlay
          if (widget.isCompleting)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.8),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
