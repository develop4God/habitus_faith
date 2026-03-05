import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/presentation/habits_providers.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import 'unified_habit_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auto-scroll engine constants
// ─────────────────────────────────────────────────────────────────────────────

/// How many logical pixels from the edge the auto-scroll zone starts.
/// Larger zone makes it easier to trigger auto-scroll when dragging.
const double _kEdgeThreshold = 180.0;

/// Maximum scroll speed in pixels per second (reached at the very edge).
const double _kMaxScrollSpeed = 900.0;

/// Minimum scroll speed once inside the edge zone (prevents sluggishness).
const double _kMinScrollSpeed = 120.0;

// ─────────────────────────────────────────────────────────────────────────────

class UnifiedHabitList extends ConsumerStatefulWidget {
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
  ConsumerState<UnifiedHabitList> createState() => _UnifiedHabitListState();
}

/// Uses [SingleTickerProviderStateMixin] so the scroll ticker is driven by
/// Flutter's vsync — frame-synchronized instead of a raw [Timer].
class _UnifiedHabitListState extends ConsumerState<UnifiedHabitList>
    with SingleTickerProviderStateMixin {
  // ── scroll infrastructure ────────────────────────────────────────────────
  final ScrollController _scrollCtrl = ScrollController();

  // ── vsync ticker for auto-scroll ─────────────────────────────────────────
  Ticker? _ticker;
  Duration _lastTickTime = Duration.zero;

  // ── drag tracking ────────────────────────────────────────────────────────
  bool _isDragging = false;
  double _pointerGlobalY = 0;

  // ── edge indicator (+ = top, - = bottom, 0 = none) ───────────────────────
  double _edgeFraction = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── ticker callback (called every frame while ticker is active) ──────────

  void _onTick(Duration elapsed) {
    if (!_isDragging) {
      _stopTicker();
      return;
    }

    if (!_scrollCtrl.hasClients) return;

    // Measure the list widget's screen position
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final Offset origin = box.localToGlobal(Offset.zero);
    final double listTop = origin.dy;
    final double listBottom = listTop + box.size.height;
    final double py = _pointerGlobalY;

    double fraction = 0.0;
    double direction = 0.0; // -1 = up, +1 = down

    if (py < listTop + _kEdgeThreshold) {
      // Top edge zone
      fraction = 1.0 - math.max(0, py - listTop) / _kEdgeThreshold;
      direction = -1.0;
    } else if (py > listBottom - _kEdgeThreshold) {
      // Bottom edge zone
      fraction = 1.0 - math.max(0, listBottom - py) / _kEdgeThreshold;
      direction = 1.0;
    }

    fraction = fraction.clamp(0.0, 1.0);

    // Update the visual indicator (only setState when value changes significantly)
    final double newEdgeFraction = direction < 0 ? fraction : -fraction;
    if ((newEdgeFraction - _edgeFraction).abs() > 0.02) {
      if (mounted) setState(() => _edgeFraction = newEdgeFraction);
    }

    if (fraction <= 0) return; // not in edge zone, no scroll needed

    // Compute pixels to scroll this frame (speed × Δt in seconds)
    final double dt = _lastTickTime == Duration.zero
        ? (1 / 60)
        : (elapsed - _lastTickTime).inMicroseconds / 1e6;
    _lastTickTime = elapsed;

    // Apply graduated speed with a minimum floor for instant response
    final double speed =
        _kMinScrollSpeed + (_kMaxScrollSpeed - _kMinScrollSpeed) * fraction;
    final double pixels = direction * speed * dt;
    final double current = _scrollCtrl.offset;
    final double maxOffset = _scrollCtrl.position.maxScrollExtent;
    final double target = (current + pixels).clamp(0.0, maxOffset);

    if ((target - current).abs() > 0.1) {
      _scrollCtrl.jumpTo(target);
    }
  }

  // ── drag lifecycle ────────────────────────────────────────────────────────

  void _onDragStarted(int index) {
    HapticFeedback.mediumImpact();
    _lastTickTime = Duration.zero;
    _isDragging = true;
    if (!(_ticker?.isTicking ?? false)) {
      _ticker?.start();
    }
  }

  void _onDragEnded(int index) {
    _stopTicker();
  }

  void _stopTicker() {
    if (_ticker?.isTicking ?? false) {
      _ticker?.stop();
    }
    _isDragging = false;
    _lastTickTime = Duration.zero;
    if (_edgeFraction != 0.0 && mounted) {
      setState(() => _edgeFraction = 0.0);
    }
  }

  // ── pointer tracking ─────────────────────────────────────────────────────

  void _onPointerMove(PointerMoveEvent e) {
    _pointerGlobalY = e.position.dy;
  }

  void _onPointerUp(PointerUpEvent e) {
    _stopTicker();
  }

  void _onPointerCancel(PointerCancelEvent e) {
    _stopTicker();
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsStreamProvider);
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final viewingDate = widget.selectedDate != null
        ? DateTime(
            widget.selectedDate!.year,
            widget.selectedDate!.month,
            widget.selectedDate!.day,
          )
        : today;
    final isViewingToday = viewingDate == today;
    final isFuture = viewingDate.isAfter(today);

    return habitsAsync.when(
      data: (habits) => _buildList(
        context,
        habits,
        l10n,
        today,
        viewingDate,
        isViewingToday,
        isFuture,
      ),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, _) => Center(child: Text(l10n.errorUnknown)),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<Habit> habits,
    AppLocalizations l10n,
    DateTime today,
    DateTime viewingDate,
    bool isViewingToday,
    bool isFuture,
  ) {
    if (habits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.startJourney,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // ── date-aware habit status ───────────────────────────────────────────
    final displayHabits = widget.selectedDate != null
        ? habits.map((habit) {
            final vd = DateTime(
              widget.selectedDate!.year,
              widget.selectedDate!.month,
              widget.selectedDate!.day,
            );
            if (vd.isAfter(today)) {
              return habit.copyWith(completedToday: false);
            }
            final wasCompleted = habit.completionHistory
                .any((dt) => DateTime(dt.year, dt.month, dt.day) == vd);
            return habit.copyWith(completedToday: wasCompleted);
          }).toList()
        : habits;

    // ── sort ──────────────────────────────────────────────────────────────
    // Unified sorting logic considering pins, completion, and user order.
    int habitCompare(Habit a, Habit b) {
      // 1. Pinned status (pinned first)
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;

      // 2. Completion status (only for unpinned habits if viewing today)
      // Pinned habits stay at the top even if completed.
      if (isViewingToday && !a.isPinned && !b.isPinned) {
        final aDone =
            a.dailyStatus != HabitDailyStatus.pending || a.completedToday;
        final bDone =
            b.dailyStatus != HabitDailyStatus.pending || b.completedToday;
        if (aDone != bDone) return aDone ? 1 : -1;
      }

      // 3. User-defined order
      final orderCmp = a.order.compareTo(b.order);
      if (orderCmp != 0) return orderCmp;

      // 4. Stable tiebreaker
      return a.createdAt.compareTo(b.createdAt);
    }

    final sortedHabits = [...displayHabits]..sort(habitCompare);

    final hasPendingHabits = widget.selectedDate != null && !isViewingToday
        ? sortedHabits.any((h) => !h.completedToday)
        : sortedHabits.any((h) => h.dailyStatus == HabitDailyStatus.pending);

    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: Stack(
        children: [
          // ── core reorderable list ─────────────────────────────────────
          Listener(
            behavior: HitTestBehavior.translucent,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerCancel,
            child: ReorderableListView.builder(
              scrollController: _scrollCtrl,
              autoScrollerVelocityScalar: 30,
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
              shrinkWrap: widget.shrinkWrap,
              physics: widget.physics ??
                  (widget.shrinkWrap
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics()),
              buildDefaultDragHandles: false,
              itemCount: sortedHabits.length,
              cacheExtent: 3000,
              proxyDecorator: _proxyDecorator,
              onReorderStart: _onDragStarted,
              onReorderEnd: _onDragEnded,
              onReorder: (oldIndex, newIndex) =>
                  _onReorder(oldIndex, newIndex, sortedHabits, isViewingToday),
              itemBuilder: (context, index) {
                final habit = sortedHabits[index];
                return ReorderableDelayedDragStartListener(
                  key: Key('drag_${habit.id}'),
                  index: index,
                  child: UnifiedHabitCard(
                    habit: habit,
                    onComplete: widget.onComplete,
                    onUncheck: widget.onUncheck,
                    onDelete: widget.onDelete,
                    onEdit: widget.onEdit,
                  ),
                );
              },
            ),
          ),

          // ── top edge-scroll indicator ─────────────────────────────────
          if (_isDragging && _edgeFraction > 0.05)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blue.withAlpha(
                            (_edgeFraction.clamp(0.0, 1.0) * 160).round()),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.keyboard_double_arrow_up_rounded,
                      color:
                          Colors.white.withAlpha((_edgeFraction * 220).round()),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),

          // ── bottom edge-scroll indicator ──────────────────────────────
          if (_isDragging && _edgeFraction < -0.05)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.blue.withAlpha(
                            ((-_edgeFraction).clamp(0.0, 1.0) * 160).round()),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.keyboard_double_arrow_down_rounded,
                      color: Colors.white
                          .withAlpha(((-_edgeFraction) * 220).round()),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── reorder callback ──────────────────────────────────────────────────────

  Future<void> _onReorder(
    int oldIndex,
    int newIndex,
    List<Habit> sortedHabits,
    bool isViewingToday,
  ) async {
    _stopTicker();

    if (newIndex > oldIndex) newIndex -= 1;

    final moved = sortedHabits[oldIndex];

    // If viewing today, we maintain strict sections: Pinned -> Pending -> Done.
    if (isViewingToday) {
      if (moved.isPinned) {
        // Pinned habits can only be reordered among themselves at the top.
        final pinnedCount = sortedHabits.where((h) => h.isPinned).length;
        if (newIndex >= pinnedCount) {
          newIndex = pinnedCount - 1;
        }
      } else {
        // Unpinned habits can only be reordered within their respective pending/done sections.
        final movedDone = moved.dailyStatus != HabitDailyStatus.pending ||
            moved.completedToday;
        final pinnedCount = sortedHabits.where((h) => h.isPinned).length;
        final doneStart = sortedHabits.indexWhere(
          (h) =>
              !h.isPinned &&
              (h.dailyStatus != HabitDailyStatus.pending || h.completedToday),
        );

        if (movedDone) {
          // Done items stay in the done section.
          if (doneStart != -1 && newIndex < doneStart) {
            newIndex = doneStart;
          }
        } else {
          // Pending items stay in the pending section.
          if (doneStart != -1 && newIndex >= doneStart) {
            newIndex = doneStart - 1;
          }
          // Also don't move pending unpinned into pinned section.
          if (newIndex < pinnedCount) {
            newIndex = pinnedCount;
          }
        }
      }
    }

    final reordered = [...sortedHabits];
    final item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, item);

    // Final normalization to ensure order field is strictly strictly consistent
    // across all habits (including those not in view).
    final List<Habit> base;
    if (isViewingToday) {
      final pinned = reordered.where((h) => h.isPinned).toList();
      final pending = reordered
          .where((h) =>
              !h.isPinned &&
              h.dailyStatus == HabitDailyStatus.pending &&
              !h.completedToday)
          .toList();
      final done = reordered
          .where((h) =>
              !h.isPinned &&
              (h.dailyStatus != HabitDailyStatus.pending || h.completedToday))
          .toList();
      base = [...pinned, ...pending, ...done];
    } else {
      base = reordered;
    }

    HapticFeedback.lightImpact();
    await ref
        .read(habitsNotifierProvider.notifier)
        .reorderHabits(base.map((h) => h.id).toList());
  }

  // ── proxy decorator ───────────────────────────────────────────────────────

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(animation.value);
        return Transform.scale(
          scale: 1.0 + t * 0.03,
          child: Material(
            elevation: t * 8,
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: child,
          ),
        );
      },
    );
  }
}
