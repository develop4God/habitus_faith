import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/data/habit_model.dart';

void main() {
  group('Habit Model Serialization - New Fields', () {
    test('toJson includes color and difficulty fields', () {
      // Arrange
      final habit = Habit.create(
        id: 'test-id-1',
        userId: 'user-1',
        name: 'Morning Prayer',
        description: 'Start the day with prayer',
        category: HabitCategory.spiritual,
        colorValue: 0xFF9333EA,
        difficulty: HabitDifficulty.medium,
      );

      // Act
      final json = HabitModel.toJson(habit);

      // Assert
      expect(json['colorValue'], 0xFF9333EA);
      expect(json['difficulty'], 'medium');
      expect(json['category'], 'spiritual');
    });

    test('fromJson correctly deserializes color and difficulty', () {
      // Arrange
      final json = {
        'id': 'test-id-1',
        'userId': 'user-1',
        'name': 'Morning Prayer',
        'description': 'Start the day with prayer',
        'category': 'prayer',
        'emoji': null,
        'verse': null,
        'reminderTime': null,
        'predefinedId': null,
        'completedToday': false,
        'currentStreak': 0,
        'longestStreak': 0,
        'lastCompletedAt': null,
        'completionHistory': [],
        'createdAt': DateTime.now().toIso8601String(),
        'isArchived': false,
        'colorValue': 0xFF9333EA,
        'difficulty': 'hard',
      };

      // Act
      final habit = HabitModel.fromJson(json);

      // Assert
      expect(habit.colorValue, 0xFF9333EA);
      expect(habit.difficulty, HabitDifficulty.hard);
      expect(habit.category, HabitCategory.spiritual);
    });

    test('fromJson with missing new fields uses defaults', () {
      // Arrange - simulate old data without new fields
      final json = {
        'id': 'test-id-1',
        'userId': 'user-1',
        'name': 'Old Habit',
        'description': 'Created before update',
        'category': 'other',
        'completedToday': false,
        'currentStreak': 0,
        'longestStreak': 0,
        'completionHistory': [],
        'createdAt': DateTime.now().toIso8601String(),
        'isArchived': false,
      };

      // Act
      final habit = HabitModel.fromJson(json);

      // Assert
      expect(habit.colorValue, isNull);
      expect(habit.difficulty, HabitDifficulty.medium); // Default
    });

    test('round trip serialization preserves all fields', () {
      // Arrange
      final originalHabit = Habit.create(
        id: 'test-id-1',
        userId: 'user-1',
        name: 'Bible Reading',
        description: 'Read one chapter',
        category: HabitCategory.spiritual,
        colorValue: 0xFF2563EB,
        difficulty: HabitDifficulty.easy,
      );

      // Act
      final json = HabitModel.toJson(originalHabit);
      final deserializedHabit = HabitModel.fromJson(json);

      // Assert
      expect(deserializedHabit.id, originalHabit.id);
      expect(deserializedHabit.userId, originalHabit.userId);
      expect(deserializedHabit.name, originalHabit.name);
      expect(deserializedHabit.description, originalHabit.description);
      expect(deserializedHabit.category, originalHabit.category);
      expect(deserializedHabit.colorValue, originalHabit.colorValue);
      expect(deserializedHabit.difficulty, originalHabit.difficulty);
    });
  });
}
