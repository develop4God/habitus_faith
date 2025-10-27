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
    // Create stream controller and emit initial data immediately
    _habitsController = StreamController<List<Habit>>.broadcast();
    // Load habits synchronously and emit immediately
    final initialHabits = _loadHabits();
    debugPrint('JsonHabitsRepository: emitting initial habits: ${initialHabits.length}');
    _habitsController.add(initialHabits);
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
    // Load completion history for each habit
    final loadedHabits = habits.map((habit) => _loadHabitWithCompletions(habit)).toList();
    debugPrint('JsonHabitsRepository._loadHabits: loadedHabits (with completions): ${loadedHabits.length}');
    return loadedHabits;
  }

  Habit _loadHabitWithCompletions(Habit habit) {
    final completions = _loadCompletionsForHabit(habit.id);
    final completionDates = completions.map((c) => c.completedAt).toList();

    // Calculate streaks from completion history
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if completed today
    final completedToday = completionDates.any((date) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      return dateOnly == today;
    });

    // Calculate current streak
    final currentStreak = _calculateCurrentStreak(completionDates);

    // Calculate longest streak
    final longestStreak = _calculateLongestStreak(completionDates);

    // Get last completion date
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

    // Sort dates in descending order
    final sortedDates = completionDates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    // Check if today is completed
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

    // Get unique dates only
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
  }) async {
    try {
      final habits = _loadHabits();
      final newHabit = Habit.create(
        id: _idGenerator(),
        userId: _userId,
        name: name,
        description: description,
        category: category,
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

      // Check if already completed today
      final habit = habits[index];
      if (habit.completedToday) {
        debugPrint('JsonHabitsRepository.completeHabit: Habit "$habitId" already completed today');
        // Already completed, return as-is
        return Success(habit);
      }

      // Create completion record
      final completionRecord = CompletionRecord(
        habitId: habitId,
        completedAt: now,
      );

      // Save completion record
      await _saveCompletionRecord(completionRecord);

      // Reload habit with updated completion data
      final updatedHabit = _loadHabitWithCompletions(habit);

      // Update habit in the list
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

    // Get or create habit completions map
    final habitCompletions =
        completionsData[record.habitId] as Map<String, dynamic>? ?? {};

    // Add completion with date key
    habitCompletions[record.dateKey] = record.toJson();

    // Update completions data
    completionsData[record.habitId] = habitCompletions;
    debugPrint('JsonHabitsRepository._saveCompletionRecord: Saved completion for habit "${record.habitId}" on "${record.dateKey}"');

    // Save back to storage
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