import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/habit.dart';
import '../../domain/habits_repository.dart';
import '../../domain/failures.dart';
import '../../domain/models/completion_record.dart';
import '../../domain/models/habit_notification.dart';
import '../../domain/ml_features_calculator.dart';
import '../habit_model.dart';
import 'json_storage_service.dart';
import '../../../statistics/statistics_service.dart';
import '../../../statistics/statistics_model.dart';
import '../../../../core/services/time/time.dart';

/// Repository implementation using JSON storage (SharedPreferences)
class JsonHabitsRepository implements HabitsRepository {
  final JsonStorageService _storage;
  final String _userId;
  final String Function() _idGenerator;
  final FirebaseFirestore? _firestore;
  final Clock _clock;

  static const String _habitsKey = 'habits';
  static const String _completionsKey = 'completions';

  late final StreamController<List<Habit>> _habitsController;

  JsonHabitsRepository({
    required JsonStorageService storage,
    required String userId,
    required String Function() idGenerator,
    FirebaseFirestore? firestore,
    Clock? clock,
  })  : _storage = storage,
        _userId = userId,
        _idGenerator = idGenerator,
        _firestore = firestore,
        _clock = clock ?? const Clock.system() {
    _habitsController = StreamController<List<Habit>>.broadcast(
      onListen: () {
        debugPrint(
          'JsonHabitsRepository: first listener - emitting initial habits',
        );
        Future.microtask(() {
          if (!_habitsController.isClosed) {
            final habits = _loadHabits();
            _habitsController.add(habits);
          }
        });
      },
    );
    // Emisión inicial forzada
    Future.microtask(() {
      if (!_habitsController.isClosed) {
        final habits = _loadHabits();
        _habitsController.add(habits);
      }
    });
  }

  void _emitHabits() {
    final habits = _loadHabits();
    debugPrint(
      'JsonHabitsRepository._emitHabits: emitting ${habits.length} habits',
    );
    _habitsController.add(habits);
  }

  List<Habit> _loadHabits() {
    final jsonList = _storage.getJsonList(_habitsKey);
    debugPrint(
      'JsonHabitsRepository._loadHabits: loaded jsonList with ${jsonList.length} items',
    );
    final habits = jsonList
        .map((json) => HabitModel.fromJson(json))
        .where((habit) => habit.userId == _userId && !habit.isArchived)
        .toList();

    debugPrint(
      'JsonHabitsRepository._loadHabits: filtered habits for user "$_userId": ${habits.length}',
    );
    final loadedHabits =
        habits.map((habit) => _loadHabitWithCompletions(habit)).toList();
    debugPrint(
      'JsonHabitsRepository._loadHabits: loadedHabits (with completions): ${loadedHabits.length}',
    );
    return loadedHabits;
  }

  Habit _loadHabitWithCompletions(Habit habit) {
    final completions = _loadCompletionsForHabit(habit.id);
    final completionDates = completions.map((c) => c.completedAt).toList();

    final now = _clock.now();
    final today = DateTime(now.year, now.month, now.day);
    debugPrint(
        '🗓️ _loadHabitWithCompletions: now=$_clock.now(), today=$today, completionDates=${completionDates.map((d) => d.toIso8601String()).toList()}');

    final completedToday = completionDates.any((date) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      debugPrint(
          '🗓️ _loadHabitWithCompletions: comparing dateOnly=$dateOnly to today=$today');
      return dateOnly == today;
    });

    // Sync dailyStatus based on historical records for today
    final skippedToday = habit.skippedDates.any((date) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      return dateOnly == today;
    });

    final failedToday = habit.failedDates.any((date) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      return dateOnly == today;
    });

    HabitDailyStatus status = HabitDailyStatus.pending;
    if (completedToday) {
      status = HabitDailyStatus.completed;
    } else if (skippedToday) {
      status = HabitDailyStatus.skipped;
    } else if (failedToday) {
      status = HabitDailyStatus.failed;
    }

    final currentStreak = _calculateCurrentStreak(completionDates);
    final longestStreak = _calculateLongestStreak(completionDates);
    final lastCompletedAt = completionDates.isNotEmpty
        ? completionDates.reduce((a, b) => a.isAfter(b) ? a : b)
        : null;

    return habit.copyWith(
      completedToday: completedToday,
      dailyStatus: status,
      currentStreak: currentStreak,
      longestStreak: longestStreak > habit.longestStreak
          ? longestStreak
          : habit.longestStreak,
      lastCompletedAt: lastCompletedAt,
      completionHistory: completionDates,
    );
  }

  List<CompletionRecord> _loadCompletionsForHabit(String habitId) {
    final completionsData = _storage.getJson(_completionsKey) ?? {};
    final habitCompletions = completionsData[habitId] as Map<String, dynamic>?;

    if (habitCompletions == null) {
      debugPrint(
        'JsonHabitsRepository._loadCompletionsForHabit: No completions for habit "$habitId"',
      );
      return [];
    }

    final completions = habitCompletions.entries
        .map((entry) {
          try {
            return CompletionRecord.fromJson(
              entry.value as Map<String, dynamic>,
            );
          } catch (e) {
            debugPrint(
              'JsonHabitsRepository._loadCompletionsForHabit: Error parsing completion for habit "$habitId": $e',
            );
            return null;
          }
        })
        .whereType<CompletionRecord>()
        .toList();
    debugPrint(
      'JsonHabitsRepository._loadCompletionsForHabit: Loaded ${completions.length} completions for habit "$habitId"',
    );
    return completions;
  }

  int _calculateCurrentStreak(List<DateTime> completionDates) {
    if (completionDates.isEmpty) return 0;

    final now = _clock.now();
    final today = DateTime(now.year, now.month, now.day);

    final sortedDates = completionDates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedDates.first != today) {
      // If not completed today, check if it was completed yesterday to maintain streak
      final yesterday = today.subtract(const Duration(days: 1));
      if (sortedDates.first != yesterday) return 0;
    }

    int streak = 1;
    DateTime expectedDate = sortedDates.first.subtract(const Duration(days: 1));

    for (int i = 1; i < sortedDates.length; i++) {
      if (sortedDates[i] == expectedDate) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  int _calculateLongestStreak(List<DateTime> completionDates) {
    if (completionDates.isEmpty) return 0;

    final sortedDates = completionDates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList()
      ..sort();

    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final daysDiff = sortedDates[i].difference(sortedDates[i - 1]).inDays;

      if (daysDiff == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }

    return longestStreak;
  }

  Future<void> _saveHabits(List<Habit> habits) async {
    final jsonList = habits.map((h) => HabitModel.toJson(h)).toList();
    debugPrint(
      'JsonHabitsRepository._saveHabits: Saving ${habits.length} habits',
    );
    await _storage.saveJsonList(_habitsKey, jsonList);
    _emitHabits();
    debugPrint('JsonHabitsRepository._saveHabits: Habits saved and emitted');
  }

  Future<void> _updateStatistics() async {
    final habits = _loadHabits();
    // Exclude skipped habits from the total count for the day to avoid penalizing success percentage
    int total =
        habits.where((h) => h.dailyStatus != HabitDailyStatus.skipped).length;
    int completed = habits.where((h) => h.completedToday).length;
    int currentStreak = 0;
    int longestStreak = 0;
    DateTime lastCompletion = DateTime(2000);
    for (final h in habits) {
      if (h.currentStreak > currentStreak) currentStreak = h.currentStreak;
      if (h.longestStreak > longestStreak) {
        longestStreak = h.longestStreak;
      }
      if (h.lastCompletedAt != null &&
          h.lastCompletedAt!.isAfter(lastCompletion)) {
        lastCompletion = h.lastCompletedAt!;
      }
    }
    if (lastCompletion.year == 2000) lastCompletion = _clock.now();
    final stats = StatisticsModel(
      totalHabits: total,
      completedHabits: completed,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastCompletion: lastCompletion,
    );
    await StatisticsService().saveStatistics(stats);
  }

  @override
  Stream<List<Habit>> watchHabits() {
    debugPrint(
      'JsonHabitsRepository.watchHabits: returning habitsController.stream',
    );
    return _habitsController.stream;
  }

  @override
  Future<Result<Habit, HabitFailure>> createHabit({
    required String name,
    String? description,
    HabitCategory category = HabitCategory.mental,
    String? emoji,
    int? colorValue,
    HabitDifficulty difficulty = HabitDifficulty.medium,
    HabitNotificationSettings? notificationSettings,
    int? targetMinutes,
  }) async {
    try {
      final habits = _loadHabits();

      // Calculate next order value (max + 1 to place at end)
      final maxOrder = habits.isEmpty
          ? 0
          : habits.map((h) => h.order).reduce((a, b) => a > b ? a : b);
      final nextOrder = maxOrder + 1;

      final newHabit = Habit.create(
        id: _idGenerator(),
        userId: _userId,
        name: name,
        description: description,
        category: category,
        emoji: emoji,
        colorValue: colorValue,
        difficulty: difficulty,
        notificationSettings: notificationSettings,
        targetMinutes: targetMinutes,
      ).copyWith(order: nextOrder);

      habits.add(newHabit);
      debugPrint(
        'JsonHabitsRepository.createHabit: Added new habit "${newHabit.id}" with order $nextOrder',
      );
      await _saveHabits(habits);

      return Success(newHabit);
    } catch (e) {
      debugPrint('JsonHabitsRepository.createHabit: Failure: $e');
      return Failure(HabitFailure.persistence('Failed to create habit: $e'));
    }
  }

  @override
  Future<Result<Habit, HabitFailure>> completeHabit(String habitId) async {
    return completeHabitWithNote(habitId, null);
  }

  @override
  Future<Result<Habit, HabitFailure>> completeHabitWithNote(
    String habitId,
    String? note,
  ) async {
    debugPrint(
      'completeHabitWithNote: inicio para habitId=$habitId, note=$note',
    );
    try {
      final habits = _loadHabits();
      debugPrint('completeHabitWithNote: hábitos cargados: ${habits.length}');
      final index = habits.indexWhere((h) => h.id == habitId);
      debugPrint('completeHabitWithNote: índice encontrado: $index');
      if (index == -1) {
        debugPrint('completeHabitWithNote: hábito no encontrado "$habitId"');
        return Failure(HabitFailure.notFound('Habit not found: $habitId'));
      }
      final now = _clock.now();
      debugPrint('✅ completeHabitWithNote: now=$now, habitId=$habitId');
      final habit = habits[index];
      debugPrint(
        'completeHabitWithNote: estado completedToday antes: ${habit.completedToday}',
      );
      if (habit.completedToday) {
        debugPrint(
          'completeHabitWithNote: hábito "$habitId" ya completado hoy',
        );
        return Success(habit);
      }
      final completionRecord = CompletionRecord(
        habitId: habitId,
        completedAt: now,
        notes: note,
      );
      debugPrint(
          '✅ completeHabitWithNote: completionRecord.completedAt=${completionRecord.completedAt}');
      await _saveCompletionRecord(completionRecord);
      debugPrint('✅ completeHabitWithNote: registro de completado guardado');

      // If the habit was skipped or failed, completing it overrides that state
      final updatedHabit = _loadHabitWithCompletions(habit);
      debugPrint(
        'completeHabitWithNote: estado completedToday después: \\${updatedHabit.completedToday}',
      );
      habits[index] = updatedHabit;
      debugPrint('✅ completeHabitWithNote: hábito actualizado en la lista');
      await _saveHabits(habits);
      debugPrint('✅ completeHabitWithNote: hábitos guardados');
      await _updateStatistics();
      debugPrint('✅ completeHabitWithNote: estadísticas actualizadas');
      debugPrint(
          '✅ completeHabitWithNote: Happy path, returning Success with updatedHabit.completedToday=${updatedHabit.completedToday}');
      return Success(updatedHabit);
    } catch (e) {
      debugPrint('completeHabitWithNote: error: $e');
      return Failure(HabitFailure.persistence('Failed to complete habit: $e'));
    }
  }

  Future<void> _saveCompletionRecord(CompletionRecord record) async {
    final completionsData = _storage.getJson(_completionsKey) ?? {};
    final habitCompletions =
        completionsData[record.habitId] as Map<String, dynamic>? ?? {};
    habitCompletions[record.dateKey] = record.toJson();
    completionsData[record.habitId] = habitCompletions;
    debugPrint(
      'JsonHabitsRepository._saveCompletionRecord: Saved completion for habit "${record.habitId}" on "${record.dateKey}"',
    );
    await _storage.saveJson(_completionsKey, completionsData);
  }

  @override
  Future<Result<void, HabitFailure>> updateHabitNote(
    String habitId,
    String? note,
  ) async {
    debugPrint('updateHabitNote: inicio para habitId=$habitId, note=$note');
    try {
      final now = _clock.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final completionsData = _storage.getJson(_completionsKey) ?? {};
      final habitCompletions =
          completionsData[habitId] as Map<String, dynamic>? ?? {};

      if (!habitCompletions.containsKey(todayKey)) {
        debugPrint('updateHabitNote: no completion found for today');
        return Failure(HabitFailure.notFound('No completion found for today'));
      }

      final existingRecord = CompletionRecord.fromJson(
        habitCompletions[todayKey] as Map<String, dynamic>,
      );

      final updatedRecord = CompletionRecord(
        habitId: existingRecord.habitId,
        completedAt: existingRecord.completedAt,
        notes: note,
        hourOfDay: existingRecord.hourOfDay,
        dayOfWeek: existingRecord.dayOfWeek,
        streakAtTime: existingRecord.streakAtTime,
        failuresLast7Days: existingRecord.failuresLast7Days,
        hoursFromReminder: existingRecord.hoursFromReminder,
        completed: existingRecord.completed,
      );

      habitCompletions[todayKey] = updatedRecord.toJson();
      completionsData[habitId] = habitCompletions;
      await _storage.saveJson(_completionsKey, completionsData);

      debugPrint('updateHabitNote: note updated successfully');
      _emitHabits(); // Emit to trigger UI update
      return const Success(null);
    } catch (e) {
      debugPrint('updateHabitNote: error: $e');
      return Failure(HabitFailure.persistence('Failed to update note: $e'));
    }
  }

  /// Record completion/abandonment data to Firestore for ML training
  /// This method enriches completion records with ML features for the training pipeline
  @override
  Future<void> recordCompletionForML(String habitId, bool completed) async {
    final habits = _loadHabits();
    final habit = habits.where((h) => h.id == habitId).firstOrNull;

    if (habit == null) {
      debugPrint(
        'JsonHabitsRepository.recordCompletionForML: Habit not found "$habitId"',
      );
      return;
    }

    final now = _clock.now();

    final record = CompletionRecord(
      habitId: habitId,
      completedAt: now,
      notes: null,
      hourOfDay: now.hour,
      dayOfWeek: now.weekday,
      streakAtTime: habit.currentStreak,
      failuresLast7Days: MLFeaturesCalculator.countRecentFailures(habit, 7),
      hoursFromReminder: MLFeaturesCalculator.calculateHoursFromReminder(
        habit,
        now,
      ),
      completed: completed,
    );

    // Save to Firestore for ML pipeline
    if (_firestore != null) {
      try {
        await _firestore!
            .collection('ml_training_data')
            .doc('${habit.userId}_${habitId}_${now.millisecondsSinceEpoch}')
            .set(record.toJson());
        debugPrint(
          'JsonHabitsRepository.recordCompletionForML: Saved ML data for habit "$habitId"',
        );
      } catch (e) {
        // Non-critical: log but don't block user flow
        debugPrint(
          'JsonHabitsRepository.recordCompletionForML: ML data save failed: $e',
        );
      }
    } else {
      debugPrint(
        'JsonHabitsRepository.recordCompletionForML: Firestore not available, skipping ML data save',
      );
    }
  }

  @override
  Future<Result<Habit, HabitFailure>> updateHabit({
    required String habitId,
    String? name,
    String? description,
    HabitCategory? category,
    String? emoji,
    int? colorValue,
    HabitDifficulty? difficulty,
    HabitNotificationSettings? notificationSettings,
    HabitRecurrence? recurrence,
    List<Subtask>? subtasks,
  }) async {
    try {
      final habits = _loadHabits();
      final index = habits.indexWhere((h) => h.id == habitId);
      if (index == -1) {
        debugPrint(
          'JsonHabitsRepository.updateHabit: Habit not found "$habitId"',
        );
        return Failure(HabitFailure.notFound('Habit not found: $habitId'));
      }
      final habit = habits[index];
      final updatedHabit = habit.copyWith(
        name: name,
        description: description,
        category: category,
        emoji: emoji,
        colorValue: colorValue,
        difficulty: difficulty,
        notificationSettings: notificationSettings,
        recurrence: recurrence,
        subtasks: subtasks,
      );
      habits[index] = updatedHabit;
      debugPrint('JsonHabitsRepository.updateHabit: Updated habit "$habitId"');
      await _saveHabits(habits);
      return Success(updatedHabit);
    } catch (e) {
      debugPrint('JsonHabitsRepository.updateHabit: Failure: $e');
      return Failure(HabitFailure.persistence('Failed to update habit: $e'));
    }
  }

  /// Update a habit instance directly (used by ML predictor and other services)
  Future<Result<Habit, HabitFailure>> updateHabitInstance(
      Habit updatedHabit) async {
    try {
      final habits = _loadHabits();
      final index = habits.indexWhere((h) => h.id == updatedHabit.id);
      if (index == -1) {
        debugPrint(
          'JsonHabitsRepository.updateHabitInstance: Habit not found "${updatedHabit.id}"',
        );
        return Failure(
            HabitFailure.notFound('Habit not found: ${updatedHabit.id}'));
      }
      habits[index] = updatedHabit;
      debugPrint(
          'JsonHabitsRepository.updateHabitInstance: Updated habit "${updatedHabit.id}"');
      await _saveHabits(habits);
      return Success(updatedHabit);
    } catch (e) {
      debugPrint('JsonHabitsRepository.updateHabitInstance: Failure: $e');
      return Failure(HabitFailure.persistence('Failed to update habit: $e'));
    }
  }

  @override
  Future<Result<Habit, HabitFailure>> uncheckHabit(String habitId) async {
    debugPrint('uncheckHabit: inicio para habitId=$habitId');
    try {
      final habits = _loadHabits();
      debugPrint('uncheckHabit: hábitos cargados: ${habits.length}');
      final index = habits.indexWhere((h) => h.id == habitId);
      debugPrint('uncheckHabit: índice encontrado: $index');
      if (index == -1) {
        debugPrint('uncheckHabit: hábito no encontrado "$habitId"');
        return Failure(HabitFailure.notFound('Habit not found: $habitId'));
      }
      final habit = habits[index];
      debugPrint(
        'uncheckHabit: estado completedToday antes: ${habit.completedToday}',
      );
      if (!habit.completedToday) {
        debugPrint('uncheckHabit: hábito "$habitId" no completado hoy');
        return Success(habit);
      }
      final now = _clock.now();
      final today = DateTime(now.year, now.month, now.day);
      debugPrint('🗓️ uncheckHabit: now=$now, today=$today');
      final updatedHistory = habit.completionHistory.where((date) {
        final completionDay = DateTime(date.year, date.month, date.day);
        debugPrint(
            '🗓️ uncheckHabit: comparing completionDay=$completionDay to today=$today');
        return completionDay != today;
      }).toList();
      final newCurrentStreak = _calculateCurrentStreak(updatedHistory);
      final updatedHabit = habit.copyWith(
        completedToday: false,
        dailyStatus: HabitDailyStatus.pending,
        currentStreak: newCurrentStreak,
        completionHistory: updatedHistory,
      );
      final completionsData = _storage.getJson(_completionsKey) ?? {};
      final habitCompletions =
          completionsData[habitId] as Map<String, dynamic>? ?? {};
      final todayKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      habitCompletions.remove(todayKey);
      if (habitCompletions.isEmpty) {
        completionsData.remove(habitId);
      } else {
        completionsData[habitId] = habitCompletions;
      }
      await _storage.saveJson(_completionsKey, completionsData);
      debugPrint('uncheckHabit: registro de completado eliminado');
      habits[index] = updatedHabit;
      debugPrint('uncheckHabit: hábito actualizado en la lista');
      await _saveHabits(habits);
      debugPrint('uncheckHabit: hábitos guardados');
      await _updateStatistics();
      debugPrint('uncheckHabit: estadísticas actualizadas');
      debugPrint(
        'Happy path: uncheckHabit retornando Success con updatedHabit.completedToday=${updatedHabit.completedToday}',
      );
      return Success(updatedHabit);
    } catch (e) {
      debugPrint('uncheckHabit: error: $e');
      return Failure(HabitFailure.persistence('Failed to uncheck habit: $e'));
    }
  }

  @override
  Future<Result<Habit, HabitFailure>> skipHabit(String habitId) async {
    debugPrint('skipHabit: inicio para habitId=$habitId');
    try {
      final habits = _loadHabits();
      final index = habits.indexWhere((h) => h.id == habitId);
      if (index == -1) {
        debugPrint('skipHabit: hábito no encontrado "$habitId"');
        return Failure(HabitFailure.notFound('Habit not found: $habitId'));
      }

      final habit = habits[index];
      final updatedHabit = habit.skipToday();

      habits[index] = updatedHabit;
      await _saveHabits(habits);
      await _updateStatistics();
      debugPrint('skipHabit: hábito "$habitId" pospuesto para hoy');
      return Success(updatedHabit);
    } catch (e) {
      debugPrint('skipHabit: error: $e');
      return Failure(HabitFailure.persistence('Failed to skip habit: $e'));
    }
  }

  @override
  Future<Result<Habit, HabitFailure>> resetHabit(String habitId) async {
    debugPrint('resetHabit: inicio para habitId=$habitId');
    try {
      final habits = _loadHabits();
      final index = habits.indexWhere((h) => h.id == habitId);
      if (index == -1) {
        debugPrint('resetHabit: hábito no encontrado "$habitId"');
        return Failure(HabitFailure.notFound('Habit not found: $habitId'));
      }

      final habit = habits[index];
      final updatedHabit = habit.resetToday(clock: _clock);

      habits[index] = updatedHabit;
      await _saveHabits(habits);
      await _updateStatistics();
      debugPrint(
          'resetHabit: hábito "$habitId" restablecido a pendiente para hoy');
      return Success(updatedHabit);
    } catch (e) {
      debugPrint('resetHabit: error: $e');
      return Failure(
          HabitFailure.persistence('Failed to reset habit: $e'));
    }
  }

  @override
  Future<Result<Habit, HabitFailure>> failHabit(String habitId) async {
    debugPrint('failHabit: inicio para habitId=$habitId');
    try {
      final habits = _loadHabits();
      final index = habits.indexWhere((h) => h.id == habitId);
      if (index == -1) {
        debugPrint('failHabit: hábito no encontrado "$habitId"');
        return Failure(HabitFailure.notFound('Habit not found: $habitId'));
      }

      final habit = habits[index];
      final updatedHabit = habit.failToday();

      habits[index] = updatedHabit;
      await _saveHabits(habits);
      await _updateStatistics();
      debugPrint('failHabit: hábito "$habitId" marcado como fallido para hoy');
      return Success(updatedHabit);
    } catch (e) {
      debugPrint('failHabit: error: $e');
      return Failure(HabitFailure.persistence('Failed to fail habit: $e'));
    }
  }

  @override
  Future<Result<void, HabitFailure>> deleteHabit(String habitId) async {
    try {
      final habits = _loadHabits();
      habits.removeWhere((h) => h.id == habitId);
      debugPrint('JsonHabitsRepository.deleteHabit: Deleted habit "$habitId"');
      await _saveHabits(habits);
      await _updateStatistics();

      return const Success(null);
    } catch (e) {
      debugPrint('JsonHabitsRepository.deleteHabit: Failure: $e');
      return Failure(HabitFailure.persistence('Failed to delete habit: $e'));
    }
  }

  @override
  Future<Result<void, HabitFailure>> reorderHabits(
    List<String> habitIds,
  ) async {
    try {
      // 1. Load ALL raw habits from storage to avoid losing data (archived, other users, etc)
      final jsonList = _storage.getJsonList(_habitsKey);
      final allHabits =
          jsonList.map((json) => HabitModel.fromJson(json)).toList();

      // 2. Separate habits that are NOT being reordered (e.g. archived or different user)
      final otherHabits =
          allHabits.where((h) => !habitIds.contains(h.id)).toList();

      // 3. Get the habits being reordered and update their order property
      final habitsToReorder =
          allHabits.where((h) => habitIds.contains(h.id)).toList();
      final habitMap = {for (var h in habitsToReorder) h.id: h};

      final reorderedList = <Habit>[];
      for (var i = 0; i < habitIds.length; i++) {
        final habitId = habitIds[i];
        final habit = habitMap[habitId];
        if (habit != null) {
          reorderedList.add(habit.copyWith(order: i));
        }
      }

      // 4. Combine and save
      final finalHabits = [...otherHabits, ...reorderedList];

      debugPrint(
        'JsonHabitsRepository.reorderHabits: Saving ${finalHabits.length} habits total (${reorderedList.length} reordered)',
      );

      await _saveHabits(finalHabits);

      return const Success(null);
    } catch (e) {
      debugPrint('JsonHabitsRepository.reorderHabits: Failure: $e');
      return Failure(HabitFailure.persistence('Failed to reorder habits: $e'));
    }
  }

  void dispose() {
    _habitsController.close();
    debugPrint('JsonHabitsRepository.dispose: habitsController closed');
  }

  @override
  CompletionRecord? getTodayCompletionRecord(String habitId) {
    final now = _clock.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    debugPrint(
        '🗓️ getTodayCompletionRecord: now=$now, today=$today, todayKey=$todayKey');

    final completionsData = _storage.getJson(_completionsKey) ?? {};
    final habitCompletions = completionsData[habitId] as Map<String, dynamic>?;

    if (habitCompletions == null || !habitCompletions.containsKey(todayKey)) {
      return null;
    }

    try {
      return CompletionRecord.fromJson(
        habitCompletions[todayKey] as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint(
        'JsonHabitsRepository.getTodayCompletionRecord: Error parsing today\'s completion: $e',
      );
      return null;
    }
  }

  @override

  /// Public method to fetch all habits for the current user (non-archived)
  Future<List<Habit>> getHabits() async {
    return _loadHabits();
  }
}
