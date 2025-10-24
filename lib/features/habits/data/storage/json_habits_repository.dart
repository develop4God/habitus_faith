import 'dart:async';
import '../../domain/habit.dart';
import '../../domain/habits_repository.dart';
import '../../domain/failures.dart';
import '../habit_model.dart';
import 'json_storage_service.dart';

/// Repository implementation using JSON storage (SharedPreferences)
class JsonHabitsRepository implements HabitsRepository {
  final JsonStorageService _storage;
  final String _userId;
  final String Function() _idGenerator;

  static const String _habitsKey = 'habits';

  final StreamController<List<Habit>> _habitsController =
      StreamController<List<Habit>>.broadcast();

  JsonHabitsRepository({
    required JsonStorageService storage,
    required String userId,
    required String Function() idGenerator,
  })  : _storage = storage,
        _userId = userId,
        _idGenerator = idGenerator {
    // Emit initial data
    _emitHabits();
  }

  void _emitHabits() {
    final habits = _loadHabits();
    _habitsController.add(habits);
  }

  List<Habit> _loadHabits() {
    final jsonList = _storage.getJsonList(_habitsKey);
    return jsonList
        .map((json) => HabitModel.fromJson(json))
        .where((habit) => habit.userId == _userId && !habit.isArchived)
        .toList();
  }

  Future<void> _saveHabits(List<Habit> habits) async {
    final jsonList = habits.map((h) => HabitModel.toJson(h)).toList();
    await _storage.saveJsonList(_habitsKey, jsonList);
    _emitHabits();
  }

  @override
  Stream<List<Habit>> watchHabits() {
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
      await _saveHabits(habits);

      return Success(newHabit);
    } catch (e) {
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
        return Failure(
          HabitFailure.notFound('Habit not found: $habitId'),
        );
      }

      final updatedHabit = habits[index].completeToday();
      habits[index] = updatedHabit;
      await _saveHabits(habits);

      return Success(updatedHabit);
    } catch (e) {
      return Failure(
        HabitFailure.persistence('Failed to complete habit: $e'),
      );
    }
  }

  @override
  Future<Result<void, HabitFailure>> deleteHabit(String habitId) async {
    try {
      final habits = _loadHabits();
      habits.removeWhere((h) => h.id == habitId);
      await _saveHabits(habits);

      return const Success(null);
    } catch (e) {
      return Failure(
        HabitFailure.persistence('Failed to delete habit: $e'),
      );
    }
  }

  void dispose() {
    _habitsController.close();
  }
}
