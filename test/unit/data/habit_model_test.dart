import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/data/habit_model.dart';

void main() {
  group('HabitModel - Firestore Serialization', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    test('toFirestore() serializes all fields correctly', () {
      // Arrange
      final now = DateTime.now();
      final habit = Habit(
        id: 'test-6',
        userId: 'user-1',
        name: 'Test',
        description: 'Test desc',
        category: HabitCategory.prayer,
        completedToday: true,
        currentStreak: 3,
        longestStreak: 5,
        lastCompletedAt: now,
        completionHistory: [now],
        createdAt: now,
        isArchived: false,
      );

      // Act
      final firestoreData = HabitModel.toFirestore(habit);

      // Assert
      expect(firestoreData['userId'], 'user-1');
      expect(firestoreData['name'], 'Test');
      expect(firestoreData['description'], 'Test desc');
      expect(firestoreData['category'], 'prayer');
      expect(firestoreData['completedToday'], true);
      expect(firestoreData['currentStreak'], 3);
      expect(firestoreData['longestStreak'], 5);
      expect(firestoreData['lastCompletedAt'], isA<Timestamp>());
      expect(firestoreData['completionHistory'], isA<List>());
      expect(firestoreData['createdAt'], isA<Timestamp>());
      expect(firestoreData['isArchived'], false);
    });

    test('fromFirestore() + toFirestore() round-trip preserves data', () async {
      // Arrange
      final now = DateTime.now();
      final originalHabit = Habit(
        id: 'test-7',
        userId: 'user-1',
        name: 'Round Trip Test',
        description: 'Testing serialization',
        category: HabitCategory.bibleReading,
        completedToday: true,
        currentStreak: 7,
        longestStreak: 10,
        lastCompletedAt: now,
        completionHistory: [now],
        createdAt: now,
        isArchived: false,
      );

      // Act - Save to fake Firestore
      await firestore
          .collection('habits')
          .doc(originalHabit.id)
          .set(HabitModel.toFirestore(originalHabit));

      // Read back from Firestore
      final doc =
          await firestore.collection('habits').doc(originalHabit.id).get();
      final restoredHabit = HabitModel.fromFirestore(doc);

      // Assert
      expect(restoredHabit.id, originalHabit.id);
      expect(restoredHabit.userId, originalHabit.userId);
      expect(restoredHabit.name, originalHabit.name);
      expect(restoredHabit.description, originalHabit.description);
      expect(restoredHabit.category, originalHabit.category);
      expect(restoredHabit.completedToday, originalHabit.completedToday);
      expect(restoredHabit.currentStreak, originalHabit.currentStreak);
      expect(restoredHabit.longestStreak, originalHabit.longestStreak);
      expect(restoredHabit.completionHistory.length,
          originalHabit.completionHistory.length);
      expect(restoredHabit.isArchived, originalHabit.isArchived);
    });
  });
}
