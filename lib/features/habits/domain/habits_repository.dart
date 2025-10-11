import 'habit.dart';
import 'failures.dart';

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
    required String description,
    HabitCategory category = HabitCategory.other,
  });

  /// Complete a habit for today
  Future<Result<Habit, HabitFailure>> completeHabit(String habitId);

  /// Delete a habit
  Future<Result<void, HabitFailure>> deleteHabit(String habitId);
}
