import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/data/habit_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// Test Suite 7: Data Migration Safety
/// Verifies that habits created before the description field was added
/// can still be loaded without errors (backward compatibility).
void main() {
  group('Data Migration Safety Tests', () {
    /// Test 7.1: Loads old habits without description from JSON
    test('reads habits from JSON without description field', () {
      // Arrange - Old habit JSON without description field
      final oldHabitJson = {
        'id': 'old-1',
        'userId': 'user-123',
        'name': 'Old Prayer',
        'category': 'spiritual',
        'emoji': '🙏',
        'createdAt': DateTime(2024, 1, 1).toIso8601String(),
        'completedToday': false,
        'currentStreak': 0,
        'longestStreak': 0,
        'completionHistory': <String>[],
        'skippedDates': <String>[],
        'failedDates': <String>[],
        'isArchived': false,
        'difficultyLevel': 3,
        'targetMinutes': 20,
        'successRate7d': 0.0,
        'optimalDays': <int>[],
        'consecutiveFailures': 0,
        'abandonmentRisk': 0.0,
        'subtasks': <Map<String, dynamic>>[],
        'order': 0,
        'dailyStatus': 'pending',
        // NO description field
      };

      // Act
      final habit = HabitModel.fromJson(oldHabitJson);

      // Assert
      expect(habit.name, 'Old Prayer');
      expect(habit.description, isNull); // Should handle missing field
      expect(habit.category.name, 'spiritual');
    });

    /// Test 7.2: Loads old habits from Firestore without description
    test('reads Firestore docs without description field', () async {
      // Arrange - Create a mock Firestore document without description
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('habits').doc('old-habit-1').set({
        'userId': 'user-123',
        'name': 'Old Habit',
        'category': 'spiritual',
        'emoji': '📖',
        'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
        'completedToday': false,
        'currentStreak': 0,
        'longestStreak': 0,
        'completionHistory': <Timestamp>[],
        'skippedDates': <Timestamp>[],
        'failedDates': <Timestamp>[],
        'isArchived': false,
        'difficultyLevel': 3,
        'targetMinutes': 20,
        'successRate7d': 0.0,
        'optimalDays': <int>[],
        'consecutiveFailures': 0,
        'abandonmentRisk': 0.0,
        'subtasks': <Map<String, dynamic>>[],
        'order': 0,
        'dailyStatus': 'pending',
        // NO description field
      });

      // Act
      final docSnapshot =
          await firestore.collection('habits').doc('old-habit-1').get();
      final habit = HabitModel.fromFirestore(docSnapshot);

      // Assert
      expect(habit.name, 'Old Habit');
      expect(
          habit.description, isNull); // Should handle missing field gracefully
      expect(habit.category.name, 'spiritual');
    });
  });
}
