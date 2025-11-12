import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/habit.dart';
import '../domain/habits_repository.dart';
import '../domain/failures.dart';
import '../domain/models/habit_notification.dart';

class FirestoreHabitsRepository implements HabitsRepository {
  final FirebaseFirestore firestore;
  final String? userId;
  final String Function() idGenerator;

  FirestoreHabitsRepository({
    required this.firestore,
    required this.userId,
    required this.idGenerator,
  });

  @override
  Stream<List<Habit>> watchHabits() {
    // Firestore desactivado
    return Stream.value([]);
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
    // Firestore desactivado
    return Failure(
        HabitFailure.persistence('Funcionalidad desactivada temporalmente.'));
  }

  @override
  Future<Result<Habit, HabitFailure>> completeHabit(String habitId) async {
    // Firestore desactivado
    return Failure(
        HabitFailure.persistence('Funcionalidad desactivada temporalmente.'));
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
    // Firestore desactivado
    return Failure(
        HabitFailure.persistence('Funcionalidad desactivada temporalmente.'));
  }

  @override
  Future<Result<Habit, HabitFailure>> uncheckHabit(String habitId) async {
    // Firestore desactivado
    return Failure(
        HabitFailure.persistence('Funcionalidad desactivada temporalmente.'));
  }

  @override
  Future<Result<void, HabitFailure>> deleteHabit(String habitId) async {
    // Firestore desactivado
    return Failure(
        HabitFailure.persistence('Funcionalidad desactivada temporalmente.'));
  }

  @override
  Future<void> recordCompletionForML(String habitId, bool completed) async {
    // Firestore desactivado
    return;
  }
}
