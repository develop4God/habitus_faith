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
        category: HabitCategory.spiritual,
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
      expect(firestoreData['category'], 'spiritual');
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
        category: HabitCategory.spiritual,
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
      final doc = await firestore
          .collection('habits')
          .doc(originalHabit.id)
          .get();
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
      expect(
        restoredHabit.completionHistory.length,
        originalHabit.completionHistory.length,
      );
      expect(restoredHabit.isArchived, originalHabit.isArchived);
    });

    test('migrates old category values to new holistic categories', () async {
      // Test all old category mappings
      final testCases = {
        'prayer': HabitCategory.spiritual,
        'bibleReading': HabitCategory.spiritual,
        'service':
            HabitCategory.spiritual, // Old categories default to spiritual
        'gratitude': HabitCategory.spiritual,
        'other': HabitCategory.spiritual, // Old categories default to spiritual
      };

      for (final entry in testCases.entries) {
        final oldCategory = entry.key;
        final expectedCategory = entry.value;

        // Arrange - Create Firestore document with old category
        final docId = 'test-migration-$oldCategory';
        await firestore.collection('habits').doc(docId).set({
          'userId': 'user-1',
          'name': 'Test Habit',
          'description': 'Test',
          'category': oldCategory,
          'completedToday': false,
          'currentStreak': 0,
          'longestStreak': 0,
          'completionHistory': [],
          'createdAt': Timestamp.now(),
          'isArchived': false,
        });

        // Act - Read back from Firestore
        final doc = await firestore.collection('habits').doc(docId).get();
        final habit = HabitModel.fromFirestore(doc);

        // Assert - Verify migration
        expect(
          habit.category,
          expectedCategory,
          reason:
              'Category "$oldCategory" should migrate to ${expectedCategory.name}',
        );
      }
    });
  });
}
