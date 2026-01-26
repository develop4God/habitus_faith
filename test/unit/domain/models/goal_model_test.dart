import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/models/goal_model.dart';

void main() {
  group('Goal Model', () {
    final now = DateTime.now();
    final deadline = now.add(const Duration(days: 30));

    test('should create a Goal with default progress and completion state', () {
      final goal = Goal(
        id: '1',
        userId: 'user123',
        title: 'Leer la Biblia',
        description: 'Meta anual',
        type: GoalType.year,
        deadline: deadline,
        createdAt: now,
      );

      expect(goal.progress, 0.0);
      expect(goal.isCompleted, false);
      expect(goal.type, GoalType.year);
    });

    test('copyWith should create a new instance with updated values', () {
      final goal = Goal(
        id: '1',
        userId: 'user123',
        title: 'Original',
        description: 'Desc',
        type: GoalType.month,
        deadline: deadline,
        createdAt: now,
      );

      final updatedGoal = goal.copyWith(
        progress: 0.5,
        title: 'Updated',
      );

      expect(updatedGoal.progress, 0.5);
      expect(updatedGoal.title, 'Updated');
      expect(updatedGoal.id, goal.id); // ID should remain same
      expect(updatedGoal.type, goal.type); // Type should remain same
    });

    test('JSON serialization should work correctly', () {
      final goal = Goal(
        id: '1',
        userId: 'user1',
        title: 'Test JSON',
        description: 'Meta',
        type: GoalType.week,
        deadline: DateTime(2025, 12, 31),
        progress: 0.75,
        isCompleted: false,
        emoji: '🎯',
        createdAt: DateTime(2025, 1, 1),
      );

      final json = goal.toJson();
      final fromJson = Goal.fromJson(json);

      expect(fromJson.id, goal.id);
      expect(fromJson.title, goal.title);
      expect(fromJson.progress, goal.progress);
      expect(fromJson.type, goal.type);
      expect(fromJson.emoji, '🎯');
    });

    test('GoalType display names should be in Spanish', () {
      expect(GoalType.year.displayName, 'Anual');
      expect(GoalType.month.displayName, 'Mensual');
      expect(GoalType.week.displayName, 'Semanal');
      expect(GoalType.custom.displayName, 'Personalizado');
    });
  });
}
