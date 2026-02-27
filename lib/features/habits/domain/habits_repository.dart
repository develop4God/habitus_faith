import 'habit.dart';
import 'failures.dart';
import 'models/habit_notification.dart';
import 'models/completion_record.dart';

/// Result type for typed errors
sealed class Result<T, F> {
  const Result();

  bool isSuccess() => this is Success<T, F>;
  bool isFailure() => this is Failure<T, F>;

  T get value => (this as Success<T, F>).data;
  F get error => (this as Failure<T, F>).failure;

  R fold<R>(R Function(F failure) onFailure, R Function(T data) onSuccess) {
    if (this is Success<T, F>) {
      return onSuccess((this as Success<T, F>).data);
    } else {
      return onFailure((this as Failure<T, F>).failure);
    }
  }
}

class Success<T, F> extends Result<T, F> {
  final T data;
  const Success(this.data);
}

class Failure<T, F> extends Result<T, F> {
  final F failure;
  const Failure(this.failure);
}

/// Abstract repository interface
abstract class HabitsRepository {
  /// Watch all habits for the current user
  Stream<List<Habit>> watchHabits();

  /// Create a new habit
  Future<Result<Habit, HabitFailure>> createHabit({
    required String name,
    String? description,
    HabitCategory category = HabitCategory.mental,
    String? emoji,
    int? colorValue,
    HabitDifficulty difficulty = HabitDifficulty.medium,
    HabitNotificationSettings? notificationSettings,
    int? targetMinutes,
  });

  /// Complete a habit for today
  Future<Result<Habit, HabitFailure>> completeHabit(String habitId);

  /// Complete a habit for today with an optional note
  Future<Result<Habit, HabitFailure>> completeHabitWithNote(
    String habitId,
    String? note,
  );

  /// Update the note for today's completion record
  Future<Result<void, HabitFailure>> updateHabitNote(
    String habitId,
    String? note,
  );

  /// Update an existing habit
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
  });

  /// Uncheck a habit (reset today's completion)
  Future<Result<Habit, HabitFailure>> uncheckHabit(String habitId);

  /// Reset a habit back to pending (removes skip / fail status for today)
  Future<Result<Habit, HabitFailure>> resetHabit(String habitId);

  /// Skip/postpone a habit for today (doesn't affect statistics)
  Future<Result<Habit, HabitFailure>> skipHabit(String habitId);

  /// Mark a habit as failed/not completed for today (affects statistics negatively)
  Future<Result<Habit, HabitFailure>> failHabit(String habitId);

  /// Delete a habit
  Future<Result<void, HabitFailure>> deleteHabit(String habitId);

  /// Reorder habits - update the order field for multiple habits
  Future<Result<void, HabitFailure>> reorderHabits(List<String> habitIds);

  /// Record completion/abandonment data for ML training
  Future<void> recordCompletionForML(String habitId, bool completed);

  /// Get today's completion record for a habit (including notes)
  CompletionRecord? getTodayCompletionRecord(String habitId);

  /// Fetch all habits for the current user (non-archived)
  Future<List<Habit>> getHabits();
}
