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

/// Repository implementation using JSON storage (SharedPreferences)
class JsonHabitsRepository implements HabitsRepository {
  final JsonStorageService _storage;
  final String _userId;
  final String Function() _idGenerator;
  final FirebaseFirestore? _firestore;

  static const String _habitsKey = 'habits';
  static const String _completionsKey = 'completions';

  late final StreamController<List<Habit>> _habitsController;

  JsonHabitsRepository({
    required JsonStorageService storage,
    required String userId,
    required String Function() idGenerator,
    FirebaseFirestore? firestore,
  })  : _storage = storage,
        _userId = userId,
        _idGenerator = idGenerator,
        _firestore = firestore {
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

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final completedToday = completionDates.any((date) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      return dateOnly == today;
    });

    final currentStreak = _calculateCurrentStreak(completionDates);
    final longestStreak = _calculateLongestStreak(completionDates);
    final lastCompletedAt = completionDates.isNotEmpty
        ? completionDates.reduce((a, b) => a.isAfter(b) ? a : b)
        : null;

    return habit.copyWith(
      completedToday: completedToday,
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

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final sortedDates = completionDates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedDates.first != today) return 0;

    int streak = 1;
    DateTime expectedDate = today.subtract(const Duration(days: 1));

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
    debugPrint(
      'JsonHabitsRepository._saveHabits: Habits saved and emitted',
    );
  }

  Future<void> _updateStatistics() async {
    final habits = _loadHabits();
    int total = habits.length;
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
    if (lastCompletion.year == 2000) lastCompletion = DateTime.now();
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
    HabitCategory category = HabitCategory.mental,
    String? emoji,
    int? colorValue,
    HabitDifficulty difficulty = HabitDifficulty.medium,
    HabitNotificationSettings? notificationSettings,
  }) async {
    try {
      final habits = _loadHabits();
      final newHabit = Habit.create(
        id: _idGenerator(),
        userId: _userId,
        name: name,
        category: category,
        emoji: emoji,
        colorValue: colorValue,
        difficulty: difficulty,
        notificationSettings: notificationSettings,
      );

      habits.add(newHabit);
      debugPrint(
        'JsonHabitsRepository.createHabit: Added new habit "${newHabit.id}"',
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
    debugPrint('completeHabit: inicio para habitId=$habitId');
    try {
      final habits = _loadHabits();
      debugPrint('completeHabit: hábitos cargados: ${habits.length}');
      final index = habits.indexWhere((h) => h.id == habitId);
      debugPrint('completeHabit: índice encontrado: $index');
      if (index == -1) {
        debugPrint('completeHabit: hábito no encontrado "$habitId"');
        return Failure(HabitFailure.notFound('Habit not found: $habitId'));
      }
      final now = DateTime.now();
      final habit = habits[index];
      debugPrint('completeHabit: estado completedToday antes: ${habit.completedToday}');
      if (habit.completedToday) {
        debugPrint('completeHabit: hábito "$habitId" ya completado hoy');
        return Success(habit);
      }
      final completionRecord = CompletionRecord(
        habitId: habitId,
        completedAt: now,
      );
      await _saveCompletionRecord(completionRecord);
      debugPrint('completeHabit: registro de completado guardado');
      final updatedHabit = _loadHabitWithCompletions(habit);
      debugPrint('completeHabit: estado completedToday después: ${updatedHabit.completedToday}');
      habits[index] = updatedHabit;
      debugPrint('completeHabit: hábito actualizado en la lista');
      await _saveHabits(habits);
      debugPrint('completeHabit: hábitos guardados');
      await _updateStatistics();
      debugPrint('completeHabit: estadísticas actualizadas');
      debugPrint('Happy path: completeHabit retornando Success con updatedHabit.completedToday=${updatedHabit.completedToday}');
      return Success(updatedHabit);
    } catch (e) {
      debugPrint('completeHabit: error: $e');
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

    final now = DateTime.now();

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
      debugPrint('uncheckHabit: estado completedToday antes: ${habit.completedToday}');
      if (!habit.completedToday) {
        debugPrint('uncheckHabit: hábito "$habitId" no completado hoy');
        return Success(habit);
      }
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final updatedHistory = habit.completionHistory.where((date) {
        final completionDay = DateTime(date.year, date.month, date.day);
        return completionDay != today;
      }).toList();
      final newCurrentStreak = _calculateCurrentStreak(updatedHistory);
      final updatedHabit = habit.copyWith(
        completedToday: false,
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
      debugPrint('Happy path: uncheckHabit retornando Success con updatedHabit.completedToday=${updatedHabit.completedToday}');
      return Success(updatedHabit);
    } catch (e) {
      debugPrint('uncheckHabit: error: $e');
      return Failure(HabitFailure.persistence('Failed to uncheck habit: $e'));
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

  void dispose() {
    _habitsController.close();
    debugPrint('JsonHabitsRepository.dispose: habitsController closed');
  }
}
