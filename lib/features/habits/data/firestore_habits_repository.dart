import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/habit.dart';
import '../domain/habits_repository.dart';
import '../domain/failures.dart';
import 'habit_model.dart';

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
    if (userId == null) {
      return Stream.value([]);
    }

    return firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => HabitModel.fromFirestore(doc)).toList();
    });
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
      if (userId == null) {
        return const Failure(UserNotAuthenticatedFailure());
      }

      final habit = Habit.create(
        id: idGenerator(),
        userId: userId!,
        name: name,
        description: description,
        category: category,
        colorValue: colorValue,
        difficulty: difficulty,
      );

      await firestore
          .collection('habits')
          .doc(habit.id)
          .set(HabitModel.toFirestore(habit));

      return Success(habit);
    } on FirebaseException catch (e) {
      return Failure(NetworkFailure(e.message ?? 'Unknown Firebase error'));
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Habit, HabitFailure>> completeHabit(String habitId) async {
    try {
      if (userId == null) {
        return const Failure(UserNotAuthenticatedFailure());
      }

      final doc = await firestore.collection('habits').doc(habitId).get();

      if (!doc.exists) {
        return Failure(HabitNotFoundFailure(habitId));
      }

      final habit = HabitModel.fromFirestore(doc);
      final updatedHabit = habit.completeToday();

      await firestore
          .collection('habits')
          .doc(habitId)
          .update(HabitModel.toFirestore(updatedHabit));

      return Success(updatedHabit);
    } on FirebaseException catch (e) {
      return Failure(NetworkFailure(e.message ?? 'Unknown Firebase error'));
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, HabitFailure>> deleteHabit(String habitId) async {
    try {
      if (userId == null) {
        return const Failure(UserNotAuthenticatedFailure());
      }

      await firestore.collection('habits').doc(habitId).delete();
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failure(NetworkFailure(e.message ?? 'Unknown Firebase error'));
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }
}
