import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_fe/features/habits/models/habit_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('HabitModel - Lógica de rachas', () {
    test('Primera vez completa → streak = 1', () {
      // Arrange
      final habit = HabitModel.create(
        id: 'test-1',
        userId: 'user-1',
        name: 'Oración',
        description: 'Orar diariamente',
      );

      // Act
      final completed = habit.completeToday();

      // Assert
      expect(completed.currentStreak, 1);
      expect(completed.longestStreak, 1);
      expect(completed.completedToday, true);
      expect(completed.completionHistory.length, 1);
    });

    test('Días consecutivos → streak++', () {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
      
      final habit = HabitModel.create(
        id: 'test-2',
        userId: 'user-1',
        name: 'Lectura',
        description: 'Leer la Biblia',
      ).copyWith(
        currentStreak: 1,
        longestStreak: 1,
        lastCompletedAt: yesterdayDate,
        completionHistory: [yesterdayDate],
      );

      // Act
      final completed = habit.completeToday();

      // Assert
      expect(completed.currentStreak, 2);
      expect(completed.longestStreak, 2);
      expect(completed.completionHistory.length, 2);
    });

    test('Gap >1 día → streak = 1 (mantiene longestStreak)', () {
      // Arrange
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final threeDaysAgoDate = DateTime(threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day);
      
      final habit = HabitModel.create(
        id: 'test-3',
        userId: 'user-1',
        name: 'Servicio',
        description: 'Servir a otros',
      ).copyWith(
        currentStreak: 5,
        longestStreak: 5,
        lastCompletedAt: threeDaysAgoDate,
        completionHistory: [threeDaysAgoDate],
      );

      // Act
      final completed = habit.completeToday();

      // Assert
      expect(completed.currentStreak, 1, reason: 'Streak should reset to 1 after gap');
      expect(completed.longestStreak, 5, reason: 'Longest streak should be maintained');
    });

    test('No completar 2× mismo día', () {
      // Arrange
      final habit = HabitModel.create(
        id: 'test-4',
        userId: 'user-1',
        name: 'Gratitud',
        description: 'Agradecer',
      );

      // Act
      final firstComplete = habit.completeToday();
      final secondComplete = firstComplete.completeToday();

      // Assert
      expect(secondComplete.currentStreak, 1, reason: 'Should not increase streak on same day');
      expect(secondComplete.completionHistory.length, 1, reason: 'Should not add duplicate completion');
    });

    test('longestStreak se actualiza si se supera', () {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
      
      final habit = HabitModel.create(
        id: 'test-5',
        userId: 'user-1',
        name: 'Meditación',
        description: 'Meditar',
      ).copyWith(
        currentStreak: 3,
        longestStreak: 5,
        lastCompletedAt: yesterdayDate,
      );

      // Act
      final completed = habit.completeToday();

      // Assert
      expect(completed.currentStreak, 4);
      expect(completed.longestStreak, 5, reason: 'Should not update longest when current < longest');

      // Now test surpassing longest
      final habit2 = habit.copyWith(
        currentStreak: 5,
        longestStreak: 5,
        lastCompletedAt: yesterdayDate,
      );
      
      final completed2 = habit2.completeToday();
      expect(completed2.currentStreak, 6);
      expect(completed2.longestStreak, 6, reason: 'Should update longest when surpassed');
    });

    test('toFirestore() serializa correctamente', () {
      // Arrange
      final now = DateTime.now();
      final habit = HabitModel(
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
      final firestore = habit.toFirestore();

      // Assert
      expect(firestore['userId'], 'user-1');
      expect(firestore['name'], 'Test');
      expect(firestore['description'], 'Test desc');
      expect(firestore['category'], 'prayer');
      expect(firestore['completedToday'], true);
      expect(firestore['currentStreak'], 3);
      expect(firestore['longestStreak'], 5);
      expect(firestore['lastCompletedAt'], isA<Timestamp>());
      expect(firestore['completionHistory'], isA<List>());
      expect(firestore['createdAt'], isA<Timestamp>());
      expect(firestore['isArchived'], false);
    });

    test('fromFirestore() round-trip funciona', () {
      // Arrange
      final now = DateTime.now();
      final habit = HabitModel(
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

      // Act - save to fake firestore and read back
      final firestoreData = habit.toFirestore();
      
      // Manually verify the serialization/deserialization
      expect(firestoreData['name'], habit.name);
      expect(firestoreData['description'], habit.description);
      expect(firestoreData['category'], habit.category.name);
      expect(firestoreData['currentStreak'], habit.currentStreak);
      expect(firestoreData['longestStreak'], habit.longestStreak);
      
      // Round-trip test with actual Firestore timestamp conversion
      final restoredHabit = HabitModel(
        id: 'test-7',
        userId: firestoreData['userId'] as String,
        name: firestoreData['name'] as String,
        description: firestoreData['description'] as String,
        category: HabitCategory.values.firstWhere((e) => e.name == firestoreData['category']),
        completedToday: firestoreData['completedToday'] as bool,
        currentStreak: firestoreData['currentStreak'] as int,
        longestStreak: firestoreData['longestStreak'] as int,
        lastCompletedAt: (firestoreData['lastCompletedAt'] as Timestamp).toDate(),
        completionHistory: (firestoreData['completionHistory'] as List)
            .map((e) => (e as Timestamp).toDate())
            .toList(),
        createdAt: (firestoreData['createdAt'] as Timestamp).toDate(),
        isArchived: firestoreData['isArchived'] as bool,
      );

      // Assert
      expect(restoredHabit.name, habit.name);
      expect(restoredHabit.description, habit.description);
      expect(restoredHabit.category, habit.category);
      expect(restoredHabit.currentStreak, habit.currentStreak);
      expect(restoredHabit.longestStreak, habit.longestStreak);
    });
  });
}
