/// Sealed class for typed failures
sealed class HabitFailure {
  final String message;
  const HabitFailure(this.message);
}

class UserNotAuthenticatedFailure extends HabitFailure {
  const UserNotAuthenticatedFailure() : super('User not authenticated');
}

class HabitNotFoundFailure extends HabitFailure {
  const HabitNotFoundFailure(String habitId)
      : super('Habit not found: $habitId');
}

class NetworkFailure extends HabitFailure {
  const NetworkFailure(String message) : super(message);
}

class UnknownFailure extends HabitFailure {
  const UnknownFailure(String message) : super(message);
}
