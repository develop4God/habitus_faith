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
             debugPrint('HabitCompletionCard tap: completed=${widget.habit.completedToday}, isCompleting=${widget.isCompleting}');
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
               child: LayoutBuilder(
                 builder: (context, constraints) {
                   debugPrint('HabitCompletionCard constraints: ${constraints.maxWidth}');
                   return ClipRRect(
                     borderRadius: BorderRadius.circular(12),
                     child: Stack(
                       children: [
                         // Main content
                         Row(
                           children: [
                             // Colored left border
                             Container(
                               width: 20,
                               color: habitColor,
                             ),
                             // Card content
                             Expanded(
                               child: Material(
                                 color: Colors.transparent,
                                 child: InkWell(
                                   onTap: _handleTap,
                                   child: Padding(
                                     padding: const EdgeInsets.symmetric(
                                       horizontal: 16.0,
                                       vertical: 16.0,
                                     ),
                                     child: Row(
                                       children: [
                                         // Checkbox
                                         Container(
                                           width: 28,
                                           height: 28,
                                           margin: const EdgeInsets.only(right: 16),
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
                                         // Habit details
                                         Expanded(
                                           child: Column(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             mainAxisSize: MainAxisSize.min,
                                             children: [
                                               // Name and emoji
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
                                                   if (widget.habit.emoji != null &&
                                                       widget.habit.emoji!.isNotEmpty)
                                                     Padding(
                                                       padding: const EdgeInsets.only(left: 8.0),
                                                       child: Text(
                                                         widget.habit.emoji!,
                                                         style: const TextStyle(fontSize: 20),
                                                       ),
                                                     ),
                                                 ],
                                               ),
                                               // Description
                                               if (widget.habit.description.isNotEmpty)
                                                 Padding(
                                                   padding: const EdgeInsets.only(top: 4.0),
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
                                                   padding: const EdgeInsets.only(top: 6.0),
                                                   child: Row(
                                                     mainAxisSize: MainAxisSize.min,
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
                                                 ),
                                             ],
                                           ),
                                         ),
                                         // Difficulty stars
                                         if (widget.habit.difficulty != HabitDifficulty.medium)
                                           Padding(
                                             padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                             child: Row(
                                               mainAxisSize: MainAxisSize.min,
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
                                         // Menu
                                         PopupMenuButton<String>(
                                           padding: EdgeInsets.zero,
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
                                             final l10n = AppLocalizations.of(context)!;
                                             return [
                                               PopupMenuItem(
                                                 value: 'edit',
                                                 child: Row(
                                                   mainAxisSize: MainAxisSize.min,
                                                   children: [
                                                     Icon(Icons.edit,
                                                         size: 18,
                                                         color: Colors.grey.shade700),
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
                                                       Icon(Icons.check_box_outline_blank,
                                                           size: 18,
                                                           color: Colors.grey.shade700),
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
                                                         size: 18, color: Colors.red),
                                                     const SizedBox(width: 12),
                                                     Text(l10n.delete,
                                                         style:
                                                             const TextStyle(color: Colors.red)),
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
                               ),
                             ),
                           ],
                         ),
                         // Animation overlay
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
                         // Loading overlay
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
                 },
               ),
             );
           }
         }