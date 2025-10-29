import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/habit.dart';
import '../../domain/habits_repository.dart';
import '../../domain/failures.dart';
import '../../domain/models/completion_record.dart';
import '../habit_model.dart';
import 'json_storage_service.dart';

/// Repository implementation using JSON storage (SharedPreferences)
class JsonHabitsRepository implements HabitsRepository {
  final JsonStorageService _storage;
  final String _userId;
  final String Function() _idGenerator;

  static const String _habitsKey = 'habits';
  static const String _completionsKey = 'completions';

  late final StreamController<List<Habit>> _habitsController;

  JsonHabitsRepository({
    required JsonStorageService storage,
    required String userId,
    required String Function() idGenerator,
  })  : _storage = storage,
        _userId = userId,
        _idGenerator = idGenerator {
    _habitsController = StreamController<List<Habit>>.broadcast(
      onListen: () {
        debugPrint('JsonHabitsRepository: first listener - emitting initial habits');
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
    debugPrint('JsonHabitsRepository._emitHabits: emitting ${habits.length} habits');
    _habitsController.add(habits);
  }

  List<Habit> _loadHabits() {
    final jsonList = _storage.getJsonList(_habitsKey);
    debugPrint('JsonHabitsRepository._loadHabits: loaded jsonList with ${jsonList.length} items');
    final habits = jsonList
        .map((json) => HabitModel.fromJson(json))
        .where((habit) => habit.userId == _userId && !habit.isArchived)
        .toList();

    debugPrint('JsonHabitsRepository._loadHabits: filtered habits for user "$_userId": ${habits.length}');
    final loadedHabits = habits.map((habit) => _loadHabitWithCompletions(habit)).toList();
    debugPrint('JsonHabitsRepository._loadHabits: loadedHabits (with completions): ${loadedHabits.length}');
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
      debugPrint('JsonHabitsRepository._loadCompletionsForHabit: No completions for habit "$habitId"');
      return [];
    }

    final completions = habitCompletions.entries
        .map((entry) {
      try {
        return CompletionRecord.fromJson(
            entry.value as Map<String, dynamic>);
      } catch (e) {
        debugPrint('JsonHabitsRepository._loadCompletionsForHabit: Error parsing completion for habit "$habitId": $e');
        return null;
      }
    })
        .whereType<CompletionRecord>()
        .toList();
    debugPrint('JsonHabitsRepository._loadCompletionsForHabit: Loaded ${completions.length} completions for habit "$habitId"');
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
    debugPrint('JsonHabitsRepository._saveHabits: Saving ${habits.length} habits');
    await _storage.saveJsonList(_habitsKey, jsonList);
    _emitHabits();
  }

  @override
  Stream<List<Habit>> watchHabits() {
    debugPrint('JsonHabitsRepository.watchHabits: returning habitsController.stream');
    return _habitsController.stream;
  }

  @override
  Future<Result<Habit, HabitFailure>> createHabit({
    required String name,
    required String description,
    HabitCategory category = HabitCategory.other,
    int? colorValue,
    HabitDifficulty difficulty = HabitDifficulty.medium,
  }) async {
    try {
      final habits = _loadHabits();
      final newHabit = Habit.create(
        id: _idGenerator(),
        userId: _userId,
        name: name,
        description: description,
        category: category,
        colorValue: colorValue,
        difficulty: difficulty,
      );

      habits.add(newHabit);
      debugPrint('JsonHabitsRepository.createHabit: Added new habit "${newHabit.id}"');
      await _saveHabits(habits);

      return Success(newHabit);
    } catch (e) {
      debugPrint('JsonHabitsRepository.createHabit: Failure: $e');
      return Failure(
        HabitFailure.persistence('Failed to create habit: $e'),
      );
    }
  }

  @override
  Future<Result<Habit, HabitFailure>> completeHabit(String habitId) async {
    try {
      final habits = _loadHabits();
      final index = habits.indexWhere((h) => h.id == habitId);

      if (index == -1) {
        debugPrint('JsonHabitsRepository.completeHabit: Habit not found "$habitId"');
        return Failure(
          HabitFailure.notFound('Habit not found: $habitId'),
        );
      }

      final now = DateTime.now();
      final habit = habits[index];
      if (habit.completedToday) {
        debugPrint('JsonHabitsRepository.completeHabit: Habit "$habitId" already completed today');
        return Success(habit);
      }

      final completionRecord = CompletionRecord(
        habitId: habitId,
        completedAt: now,
      );

      await _saveCompletionRecord(completionRecord);
      final updatedHabit = _loadHabitWithCompletions(habit);
      habits[index] = updatedHabit;
      debugPrint('JsonHabitsRepository.completeHabit: Completed habit "$habitId"');
      await _saveHabits(habits);

      return Success(updatedHabit);
    } catch (e) {
      debugPrint('JsonHabitsRepository.completeHabit: Failure: $e');
      return Failure(
        HabitFailure.persistence('Failed to complete habit: $e'),
      );
    }
  }

  Future<void> _saveCompletionRecord(CompletionRecord record) async {
    final completionsData = _storage.getJson(_completionsKey) ?? {};
    final habitCompletions =
        completionsData[record.habitId] as Map<String, dynamic>? ?? {};
    habitCompletions[record.dateKey] = record.toJson();
    completionsData[record.habitId] = habitCompletions;
    debugPrint('JsonHabitsRepository._saveCompletionRecord: Saved completion for habit "${record.habitId}" on "${record.dateKey}"');
    await _storage.saveJson(_completionsKey, completionsData);
  }

  @override
  Future<Result<void, HabitFailure>> deleteHabit(String habitId) async {
    try {
      final habits = _loadHabits();
      habits.removeWhere((h) => h.id == habitId);
      debugPrint('JsonHabitsRepository.deleteHabit: Deleted habit "$habitId"');
      await _saveHabits(habits);

      return const Success(null);
    } catch (e) {
      debugPrint('JsonHabitsRepository.deleteHabit: Failure: $e');
      return Failure(
        HabitFailure.persistence('Failed to delete habit: $e'),
      );
    }
  }

  void dispose() {
    _habitsController.close();
    debugPrint('JsonHabitsRepository.dispose: habitsController closed');
  }
}