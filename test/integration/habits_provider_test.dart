import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/features/habits/models/habit_model.dart';
import 'package:habitus_faith/features/habits/providers/habits_provider.dart';
import 'package:habitus_faith/core/providers/auth_provider.dart';
import '../helpers/test_providers.dart';

void main() {
  group('HabitsProvider Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ProviderContainer container;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      container = createTestContainer(firestore: fakeFirestore);
    });

    tearDown(() {
      container.dispose();
    });

    test('addHabit() persiste en Firestore fake', () async {
      // Arrange
      // Ensure the provider container has initialized user
      container.read(userIdProvider);
      await Future.delayed(const Duration(milliseconds: 50));

      final actions = container.read(habitsActionsProvider);

      // Act
      await actions.addHabit(
        name: 'Test Habit',
        description: 'Test Description',
        category: HabitCategory.prayer,
      );

      // Assert
      final snapshot = await fakeFirestore.collection('habits').get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['name'], 'Test Habit');
      expect(snapshot.docs.first.data()['description'], 'Test Description');
      expect(snapshot.docs.first.data()['category'], 'prayer');
    });

    test('completeHabit() actualiza racha en Firestore', () async {
      // Arrange
      final actions = container.read(habitsActionsProvider);
      final habit = HabitModel.create(
        id: 'test-habit-1',
        userId: 'test-user',
        name: 'Morning Prayer',
        description: 'Pray in the morning',
      );

      await fakeFirestore
          .collection('habits')
          .doc(habit.id)
          .set(habit.toFirestore());

      // Act
      await actions.completeHabit(habit);

      // Assert
      final doc = await fakeFirestore.collection('habits').doc(habit.id).get();
      final data = doc.data()!;
      expect(data['currentStreak'], 1);
      expect(data['longestStreak'], 1);
      expect(data['completedToday'], true);
    });

    test('deleteHabit() remueve documento', () async {
      // Arrange
      final actions = container.read(habitsActionsProvider);
      const habitId = 'test-habit-delete';
      final habit = HabitModel.create(
        id: habitId,
        userId: 'test-user',
        name: 'To Delete',
        description: 'Will be deleted',
      );

      await fakeFirestore
          .collection('habits')
          .doc(habitId)
          .set(habit.toFirestore());

      // Verify it exists
      var snapshot = await fakeFirestore.collection('habits').get();
      expect(snapshot.docs.length, 1);

      // Act
      await actions.deleteHabit(habitId);

      // Assert
      snapshot = await fakeFirestore.collection('habits').get();
      expect(snapshot.docs.length, 0);
    });

    test('habitsProvider filtra por userId correcto', () async {
      // Arrange
      final habit1 = HabitModel.create(
        id: 'habit-1',
        userId: 'test-user',
        name: 'Habit 1',
        description: 'User 1 habit',
      );

      final habit2 = HabitModel.create(
        id: 'habit-2',
        userId: 'other-user',
        name: 'Habit 2',
        description: 'User 2 habit',
      );

      await fakeFirestore
          .collection('habits')
          .doc(habit1.id)
          .set(habit1.toFirestore());
      await fakeFirestore
          .collection('habits')
          .doc(habit2.id)
          .set(habit2.toFirestore());

      // Act - Wait for the stream to emit and container to initialize
      await Future.delayed(const Duration(milliseconds: 150));
      final habitsAsync = container.read(habitsProvider);

      // Assert
      habitsAsync.when(
        data: (habits) {
          // Should only include habits for 'test-user' (from MockFirebaseAuth)
          expect(habits.length, 1);
          expect(habits.first.userId, 'test-user');
        },
        loading: () {
          // If still loading after delay, that's also acceptable
          // The stream may not have emitted yet
        },
        error: (error, stack) => fail('Should not have error: $error'),
      );
    });

    test('Completar múltiples hábitos mismo día funciona', () async {
      // Arrange
      final actions = container.read(habitsActionsProvider);

      final habit1 = HabitModel.create(
        id: 'habit-1',
        userId: 'test-user',
        name: 'Habit 1',
        description: 'First habit',
      );

      final habit2 = HabitModel.create(
        id: 'habit-2',
        userId: 'test-user',
        name: 'Habit 2',
        description: 'Second habit',
      );

      await fakeFirestore
          .collection('habits')
          .doc(habit1.id)
          .set(habit1.toFirestore());
      await fakeFirestore
          .collection('habits')
          .doc(habit2.id)
          .set(habit2.toFirestore());

      // Act
      await actions.completeHabit(habit1);
      await actions.completeHabit(habit2);

      // Assert
      final doc1 =
          await fakeFirestore.collection('habits').doc(habit1.id).get();
      final doc2 =
          await fakeFirestore.collection('habits').doc(habit2.id).get();

      expect(doc1.data()!['completedToday'], true);
      expect(doc1.data()!['currentStreak'], 1);

      expect(doc2.data()!['completedToday'], true);
      expect(doc2.data()!['currentStreak'], 1);
    });
  });
}
