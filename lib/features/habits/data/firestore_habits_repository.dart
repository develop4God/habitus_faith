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
    String? emoji,
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
        emoji: emoji,
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
  Future<Result<Habit, HabitFailure>> updateHabit({
    required String habitId,
    String? name,
    String? description,
    HabitCategory? category,
    String? emoji,
    int? colorValue,
    HabitDifficulty? difficulty,
  }) async {
    try {
      if (userId == null) {
        return const Failure(UserNotAuthenticatedFailure());
      }

      final doc = await firestore.collection('habits').doc(habitId).get();
      if (!doc.exists) {
        return Failure(HabitNotFoundFailure(habitId));
      }

      final habit = HabitModel.fromFirestore(doc);
      final updatedHabit = habit.copyWith(
        name: name,
        description: description,
        category: category,
        emoji: emoji,
        colorValue: colorValue,
        difficulty: difficulty,
      );

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
  Future<Result<Habit, HabitFailure>> uncheckHabit(String habitId) async {
    try {
      if (userId == null) {
        return const Failure(UserNotAuthenticatedFailure());
      }

      final doc = await firestore.collection('habits').doc(habitId).get();
      if (!doc.exists) {
        return Failure(HabitNotFoundFailure(habitId));
      }

      final habit = HabitModel.fromFirestore(doc);
      if (!habit.completedToday) {
        return Success(habit);
      }

      // Remove today's completion
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final updatedHistory = habit.completionHistory.where((date) {
        final completionDay = DateTime(date.year, date.month, date.day);
        return completionDay != today;
      }).toList();

      // Recalculate streak (simple version - could be improved)
      int newCurrentStreak = 0;
      if (updatedHistory.isNotEmpty) {
        final sortedDates = updatedHistory
            .map((date) => DateTime(date.year, date.month, date.day))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

        final yesterday = today.subtract(const Duration(days: 1));
        if (sortedDates.first == yesterday) {
          newCurrentStreak = 1;
          DateTime expectedDate = yesterday.subtract(const Duration(days: 1));
          for (int i = 1; i < sortedDates.length; i++) {
            if (sortedDates[i] == expectedDate) {
              newCurrentStreak++;
              expectedDate = expectedDate.subtract(const Duration(days: 1));
            } else {
              break;
            }
          }
        }
      }

      final updatedHabit = habit.copyWith(
        completedToday: false,
        currentStreak: newCurrentStreak,
        completionHistory: updatedHistory,
      );

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
