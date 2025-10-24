/// Sealed class for typed failures
sealed class HabitFailure {
  final String message;
  const HabitFailure(this.message);

  // Factory constructors for common failures
  factory HabitFailure.persistence(String message) = PersistenceFailure;
  factory HabitFailure.notFound(String message) = HabitNotFoundFailure;
  factory HabitFailure.userNotAuthenticated() = UserNotAuthenticatedFailure;
  factory HabitFailure.network(String message) = NetworkFailure;
  factory HabitFailure.unknown(String message) = UnknownFailure;
}

class UserNotAuthenticatedFailure extends HabitFailure {
  const UserNotAuthenticatedFailure() : super('User not authenticated');
}

class HabitNotFoundFailure extends HabitFailure {
  const HabitNotFoundFailure(super.message);
}

class NetworkFailure extends HabitFailure {
  const NetworkFailure(super.message);
}

class UnknownFailure extends HabitFailure {
  const UnknownFailure(super.message);
}

class PersistenceFailure extends HabitFailure {
  const PersistenceFailure(super.message);
}
