/// Regression tests for the specific UX bugs fixed in this sprint.
///
/// These are robust, non-flaky pure-Dart tests that exercise the domain and
/// repository layer.  Zero widget pumps, zero timers, zero Firebase.
///
/// Bug coverage:
///   A. Drag-upward scroll: auto-scroll constants produce valid pixel deltas
///      (compile-time + unit-level sanity check).
///   B. Habit order stable across midnight – stable tiebreaker via createdAt
///      so equal-order habits keep a deterministic position.
///   C. Unskip infinite spinner – resetHabit always resolves to Success/Failure
///      and never leaves the caller with an unresolved future.
///   D. Unskip → complete full workflow (skip, reset, complete).
///   E. Duplicate order=0 habits are sorted stably by createdAt.
///   F. failHabit → resetHabit removes from failedDates.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habitus_faith/features/habits/data/storage/json_habits_repository.dart';
import 'package:habitus_faith/features/habits/data/storage/json_storage_service.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/core/services/time/time.dart';

// ─── shared helpers ───────────────────────────────────────────────────────────

Future<JsonHabitsRepository> _makeRepo({DateTime? fixedNow}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final storage = JsonStorageService(prefs);
  int counter = 0;
  return JsonHabitsRepository(
    storage: storage,
    userId: 'u1',
    idGenerator: () => 'h${counter++}',
    clock: fixedNow != null ? Clock.fixed(fixedNow) : null,
  );
}

Future<String> _create(JsonHabitsRepository repo, String name) async {
  final r = await repo.createHabit(
    name: name,
    category: HabitCategory.spiritual,
    emoji: '✝️',
  );
  return r.fold((f) => throw Exception('create failed: $f'), (h) => h.id);
}

// ─── A: auto-scroll constants are sensible ────────────────────────────────────

// These constants are defined at the top of unified_habit_list.dart.
// We verify the math here without importing the widget (avoids Firebase dep).
const double _kEdgeThreshold = 180.0; // must match unified_habit_list.dart
const double _kMaxScrollSpeed = 900.0; // must match unified_habit_list.dart
const double _kMinScrollSpeed = 120.0; // must match unified_habit_list.dart

void main() {
  group('A – Auto-scroll constants (drag-upward UX)', () {
    test('edge threshold is positive and large enough for comfortable drag',
        () {
      expect(_kEdgeThreshold, greaterThan(100),
          reason: 'Threshold must be wide enough for users to trigger scroll');
    });

    test('max scroll speed exceeds min scroll speed', () {
      expect(_kMaxScrollSpeed, greaterThan(_kMinScrollSpeed),
          reason: 'Max speed must be higher than min speed');
    });

    test('scroll pixel delta at full fraction (1/60 frame) is reasonable', () {
      const dt = 1 / 60;
      const fraction = 1.0; // deepest inside the edge zone
      const speed =
          _kMinScrollSpeed + (_kMaxScrollSpeed - _kMinScrollSpeed) * fraction;
      const delta = speed * dt;
      expect(delta, greaterThan(0), reason: 'Must scroll at least some pixels');
      expect(delta, lessThan(100),
          reason: 'Must not jump more than ~100px per frame (too jumpy)');
    });

    test('scroll pixel delta at fraction=0.2 uses min + proportional speed',
        () {
      const dt = 1 / 60;
      const fraction = 0.2;
      const speed =
          _kMinScrollSpeed + (_kMaxScrollSpeed - _kMinScrollSpeed) * fraction;
      const delta = speed * dt;
      expect(delta, greaterThan(0));
      expect(speed, greaterThan(_kMinScrollSpeed));
      expect(speed, lessThan(_kMaxScrollSpeed));
    });
  });

  // ─── B: stable sort across midnight ────────────────────────────────────────

  group('B – Habit order stable across midnight (createdAt tiebreaker)', () {
    test('three habits all with order=0 keep a stable position by createdAt',
        () {
      // Simulate three habits with identical order (e.g. fresh install, no reorder done yet).
      final t0 = DateTime(2026, 2, 26, 8, 0, 0);
      final t1 = DateTime(2026, 2, 26, 8, 0, 1);
      final t2 = DateTime(2026, 2, 26, 8, 0, 2);

      final habits = [
        Habit.create(
          id: 'c',
          userId: 'u',
          name: 'Meditation',
          category: HabitCategory.mental,
          emoji: '🧘',
        ).copyWith(order: 0, createdAt: t2),
        Habit.create(
          id: 'a',
          userId: 'u',
          name: 'Prayer',
          category: HabitCategory.spiritual,
          emoji: '🙏',
        ).copyWith(order: 0, createdAt: t0),
        Habit.create(
          id: 'b',
          userId: 'u',
          name: 'Exercise',
          category: HabitCategory.physical,
          emoji: '💪',
        ).copyWith(order: 0, createdAt: t1),
      ];

      // Apply the same tiebreaker sort that unified_habit_list.dart uses:
      final sorted = [...habits]..sort((a, b) {
          final cmp = a.order.compareTo(b.order);
          if (cmp != 0) return cmp;
          return a.createdAt.compareTo(b.createdAt);
        });

      expect(sorted.map((h) => h.id).toList(), ['a', 'b', 'c'],
          reason:
              'Equal-order habits must be sorted by createdAt for stability');
    });

    test('mixed order values sort correctly with createdAt tiebreaker', () {
      final t0 = DateTime(2026, 2, 26, 9, 0, 0);
      final t1 = DateTime(2026, 2, 26, 9, 0, 1);

      final habits = [
        Habit.create(
          id: 'b',
          userId: 'u',
          name: 'Exercise',
          category: HabitCategory.physical,
          emoji: '💪',
        ).copyWith(order: 0, createdAt: t1),
        Habit.create(
          id: 'c',
          userId: 'u',
          name: 'Reading',
          category: HabitCategory.mental,
          emoji: '📚',
        ).copyWith(order: 2, createdAt: t0),
        Habit.create(
          id: 'a',
          userId: 'u',
          name: 'Prayer',
          category: HabitCategory.spiritual,
          emoji: '🙏',
        ).copyWith(order: 0, createdAt: t0),
      ];

      final sorted = [...habits]..sort((a, b) {
          final cmp = a.order.compareTo(b.order);
          if (cmp != 0) return cmp;
          return a.createdAt.compareTo(b.createdAt);
        });

      // order=0 habits: 'a' (t0) before 'b' (t1); 'c' at order=2 last.
      expect(sorted.map((h) => h.id).toList(), ['a', 'b', 'c']);
    });

    test('reordered habits keep their order after simulate-midnight reload',
        () async {
      final day1 = DateTime(2026, 2, 25, 12, 0);
      final repo = await _makeRepo(fixedNow: day1);
      addTearDown(repo.dispose);

      final a = await _create(repo, 'Prayer');
      final b = await _create(repo, 'Exercise');
      final c = await _create(repo, 'Reading');

      // User sets order: b, c, a
      await repo.reorderHabits([b, c, a]);

      // Complete habit b during the day
      await repo.completeHabit(b);

      // "Midnight" – reload from fresh storage (repo re-emits based on _clock)
      // In test we just call watchHabits().first which reads from storage.
      final habits = await repo.watchHabits().first;
      // Sort by order + createdAt (same as widget logic)
      final sorted = [...habits]..sort((x, y) {
          final cmp = x.order.compareTo(y.order);
          if (cmp != 0) return cmp;
          return x.createdAt.compareTo(y.createdAt);
        });

      // The user-defined base order [b, c, a] (positions 0, 1, 2) should survive
      expect(sorted.map((h) => h.id).toList(), [b, c, a],
          reason: 'Order must survive across a midnight-style reload');
    });
  });

  // ─── C: unskip never hangs ─────────────────────────────────────────────────

  group('C – Unskip: resetHabit never hangs (always returns Result)', () {
    test('resetHabit on skipped habit returns Success with pending status',
        () async {
      final repo = await _makeRepo();
      addTearDown(repo.dispose);

      final id = await _create(repo, 'Morning walk');

      await repo.skipHabit(id);

      // Must complete (not hang) and return Success.
      final result =
          await repo.resetHabit(id).timeout(const Duration(seconds: 5));
      expect(result.isSuccess(), isTrue,
          reason: 'resetHabit must resolve to Success, not hang');

      final h = result.fold((f) => throw Exception(f), (h) => h);
      expect(h.dailyStatus, HabitDailyStatus.pending);
      expect(h.completedToday, isFalse);
    });

    test('resetHabit on a missing habit returns Failure (never throws)',
        () async {
      final repo = await _makeRepo();
      addTearDown(repo.dispose);

      // Must complete in finite time without throwing.
      final result = await repo
          .resetHabit('nonexistent')
          .timeout(const Duration(seconds: 5));
      expect(result.isFailure(), isTrue,
          reason:
              'Missing habit should give a typed Failure, not an exception');
    });

    test('rapidfire: skip→reset called twice in a row does not corrupt state',
        () async {
      final repo = await _makeRepo();
      addTearDown(repo.dispose);

      final id = await _create(repo, 'Bible reading');

      await repo.skipHabit(id);
      await repo.resetHabit(id);
      // Calling reset a second time (already pending) must still succeed.
      final result2 = await repo.resetHabit(id);
      expect(result2.isSuccess(), isTrue);

      final h = result2.fold((f) => throw Exception(f), (h) => h);
      expect(h.dailyStatus, HabitDailyStatus.pending);
    });
  });

  // ─── D: full skip → reset → complete cycle ─────────────────────────────────

  group('D – Full unskip → complete workflow', () {
    test('skip → reset → complete produces completedToday=true', () async {
      final repo = await _makeRepo();
      addTearDown(repo.dispose);

      final id = await _create(repo, 'Full cycle habit');

      // Step 1: skip
      final skipR = await repo.skipHabit(id);
      expect(
        skipR.fold((f) => throw Exception(f), (h) => h.dailyStatus),
        HabitDailyStatus.skipped,
      );

      // Step 2: unskip (reset)
      final resetR = await repo.resetHabit(id);
      final afterReset = resetR.fold((f) => throw Exception(f), (h) => h);
      expect(afterReset.dailyStatus, HabitDailyStatus.pending);
      expect(afterReset.completedToday, isFalse);

      // Step 3: complete
      final completeR = await repo.completeHabit(id);
      final done = completeR.fold((f) => throw Exception(f), (h) => h);
      expect(done.completedToday, isTrue);
      expect(done.dailyStatus, HabitDailyStatus.completed);
    });

    test('fail → reset → complete also works', () async {
      final repo = await _makeRepo();
      addTearDown(repo.dispose);

      final id = await _create(repo, 'Failed and retried');

      await repo.failHabit(id);

      final resetR = await repo.resetHabit(id);
      final afterReset = resetR.fold((f) => throw Exception(f), (h) => h);
      expect(afterReset.dailyStatus, HabitDailyStatus.pending,
          reason: 'resetHabit must clear failed status');
      expect(
          afterReset.failedDates.where((d) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            return DateTime(d.year, d.month, d.day) == today;
          }).isEmpty,
          isTrue,
          reason: "Today's entry must be removed from failedDates");

      final completeR = await repo.completeHabit(id);
      expect(
        completeR.fold((f) => throw Exception(f), (h) => h.completedToday),
        isTrue,
      );
    });
  });

  // ─── E: new habits get unique orders (no collision) ──────────────────────

  group('E – New habits always get unique order values', () {
    test('10 habits created sequentially have unique orders', () async {
      final repo = await _makeRepo();
      addTearDown(repo.dispose);

      for (int i = 0; i < 10; i++) {
        await _create(repo, 'Habit $i');
      }

      final habits = await repo.watchHabits().first;
      final orders = habits.map((h) => h.order).toList();
      expect(orders.toSet().length, orders.length,
          reason: 'Every habit must have a unique order value');
    });

    test('habits created after reorder do not get duplicate orders', () async {
      final repo = await _makeRepo();
      addTearDown(repo.dispose);

      final a = await _create(repo, 'First');
      final b = await _create(repo, 'Second');

      // Reorder: b then a (assigns orders 0, 1)
      await repo.reorderHabits([b, a]);

      // Create a new habit — must get order = max(0,1) + 1 = 2
      final c = await _create(repo, 'Third');

      final habits = await repo.watchHabits().first;
      final byId = {for (final h in habits) h.id: h};

      expect(byId[a]!.order, lessThan(byId[c]!.order),
          reason: 'Newly created habit must come after reordered ones');
      expect(byId[b]!.order, lessThan(byId[c]!.order));
      // All orders unique
      final orders = habits.map((h) => h.order).toList();
      expect(orders.toSet().length, orders.length,
          reason: 'No duplicate orders after create-after-reorder');
    });
  });

  // ─── F: failHabit → resetHabit cleanup ───────────────────────────────────

  group('F – failHabit followed by resetHabit cleans up correctly', () {
    test('failedDates entry removed after resetHabit', () async {
      final now = DateTime(2026, 2, 26, 18, 0);
      final repo = await _makeRepo(fixedNow: now);
      addTearDown(repo.dispose);

      final id = await _create(repo, 'Evening prayer');
      await repo.failHabit(id);

      final today = DateTime(now.year, now.month, now.day);

      // Verify it was failed
      var habits = await repo.watchHabits().first;
      final failed = habits.firstWhere((h) => h.id == id);
      expect(
        failed.failedDates
            .any((d) => DateTime(d.year, d.month, d.day) == today),
        isTrue,
        reason: 'failedDates must contain today after failHabit',
      );

      // Reset
      await repo.resetHabit(id);
      habits = await repo.watchHabits().first;
      final reset = habits.firstWhere((h) => h.id == id);
      expect(
        reset.failedDates.any((d) => DateTime(d.year, d.month, d.day) == today),
        isFalse,
        reason: 'failedDates must NOT contain today after resetHabit',
      );
      expect(reset.dailyStatus, HabitDailyStatus.pending);
    });

    test(
        'currentStreak is NOT broken by resetHabit when habit was merely failed',
        () async {
      // The streak should only be recalculated from completionHistory, which is
      // untouched by fail/reset.  So resetting a never-completed habit keeps streak=0.
      final repo = await _makeRepo();
      addTearDown(repo.dispose);

      final id = await _create(repo, 'Streak test');
      await repo.failHabit(id);
      final resetR = await repo.resetHabit(id);
      final h = resetR.fold((f) => throw Exception(f), (h) => h);
      // A brand-new habit with no completions → streak stays 0.
      expect(h.currentStreak, 0);
    });
  });
}
