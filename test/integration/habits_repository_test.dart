import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/domain/failures.dart';
import 'package:habitus_faith/features/habits/data/firestore_habits_repository.dart';

void main() {
  group('FirestoreHabitsRepository - Integration Tests', () {
    late FakeFirebaseFirestore firestore;
    late FirestoreHabitsRepository repository;
    int idCounter = 0;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      idCounter = 0;
      repository = FirestoreHabitsRepository(
        firestore: firestore,
        userId: 'test-user',
        idGenerator: () => 'test-id-${idCounter++}',
      );
    });

    test('createHabit generates unique ID and persists', () async {
      // Act
      final result = await repository.createHabit(
        name: 'Prayer',
        description: 'Daily prayer',
      );

      // Assert
      result.fold(
        (failure) => fail('Should succeed, got: ${failure.message}'),
        (habit) {
          expect(habit.id, 'test-id-0');
          expect(habit.userId, 'test-user');
          expect(habit.name, 'Prayer');
          expect(habit.description, 'Daily prayer');
        },
      );

      final snapshot = await firestore.collection('habits').get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['name'], 'Prayer');
    });

    test('createHabit with null userId returns failure', () async {
      // Arrange
      final repo = FirestoreHabitsRepository(
        firestore: firestore,
        userId: null,
        idGenerator: () => 'test-id',
      );

      // Act
      final result = await repo.createHabit(
        name: 'Prayer',
        description: 'Daily prayer',
      );

      // Assert
      expect(result.isFailure(), true);
      result.fold(
        (failure) => expect(failure, isA<UserNotAuthenticatedFailure>()),
        (habit) => fail('Should have failed'),
      );

      final snapshot = await firestore.collection('habits').get();
      expect(snapshot.docs.length, 0);
    });

    test('completeHabit updates streak correctly', () async {
      // Arrange
      final createResult = await repository.createHabit(
        name: 'Morning Prayer',
        description: 'Pray in the morning',
      );

      final habitId = createResult.fold(
        (failure) => fail('Setup failed'),
        (habit) => habit.id,
      );

      // Act
      final result = await repository.completeHabit(habitId);

      // Assert
      result.fold(
        (failure) => fail('Should succeed, got: ${failure.message}'),
        (updated) {
          expect(updated.currentStreak, 1);
          expect(updated.longestStreak, 1);
          expect(updated.completedToday, true);
        },
      );
    });

    test('completeHabit with non-existent ID returns failure', () async {
      // Act
      final result = await repository.completeHabit('non-existent-id');

      // Assert
      expect(result.isFailure(), true);
      result.fold(
        (failure) => expect(failure, isA<HabitNotFoundFailure>()),
        (habit) => fail('Should have failed'),
      );
    });

    test('completeHabit with null userId returns failure', () async {
      // Arrange
      final repo = FirestoreHabitsRepository(
        firestore: firestore,
        userId: null,
        idGenerator: () => 'test-id',
      );

      // Act
      final result = await repo.completeHabit('any-id');

      // Assert
      expect(result.isFailure(), true);
      result.fold(
        (failure) => expect(failure, isA<UserNotAuthenticatedFailure>()),
        (habit) => fail('Should have failed'),
      );
    });

    test('deleteHabit removes document', () async {
      // Arrange
      final createResult = await repository.createHabit(
        name: 'To Delete',
        description: 'Will be deleted',
      );

      final habitId = createResult.fold(
        (failure) => fail('Setup failed'),
        (habit) => habit.id,
      );

      // Verify it exists
      var snapshot = await firestore.collection('habits').get();
      expect(snapshot.docs.length, 1);

      // Act
      final result = await repository.deleteHabit(habitId);

      // Assert
      result.fold(
        (failure) => fail('Should succeed, got: ${failure.message}'),
        (_) {
          // Success
        },
      );

      snapshot = await firestore.collection('habits').get();
      expect(snapshot.docs.length, 0);
    });

    test('watchHabits filters by userId', () async {
      // Arrange
      await repository.createHabit(
        name: 'Habit 1',
        description: 'User 1 habit',
      );

      // Create habit for different user
      final otherRepo = FirestoreHabitsRepository(
        firestore: firestore,
        userId: 'other-user',
        idGenerator: () => 'other-id',
      );
      await otherRepo.createHabit(name: 'Habit 2', description: 'User 2 habit');

      // Act
      final stream = repository.watchHabits();

      // Assert
      await expectLater(
        stream,
        emits(
          predicate<List<Habit>>((habits) {
            return habits.length == 1 && habits.first.userId == 'test-user';
          }),
        ),
      );
    });

    test('watchHabits returns empty for null userId', () async {
      // Arrange
      final repo = FirestoreHabitsRepository(
        firestore: firestore,
        userId: null,
        idGenerator: () => 'test-id',
      );

      // Act
      final stream = repo.watchHabits();

      // Assert
      await expectLater(
        stream,
        emits(predicate<List<Habit>>((habits) => habits.isEmpty)),
      );
    });
  });
}
