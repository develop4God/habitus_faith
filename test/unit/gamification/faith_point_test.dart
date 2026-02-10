import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/gamification/domain/models/faith_point.dart';

void main() {
  group('FaithPoint', () {
    test('calculatePoints returns correct base points for difficulty', () {
      // Difficulty 1 → 10 points
      expect(
        FaithPoint.calculatePoints(
          difficultyLevel: 1,
          isSpiritual: false,
          currentStreak: 0,
        ),
        10,
      );

      // Difficulty 5 → 50 points
      expect(
        FaithPoint.calculatePoints(
          difficultyLevel: 5,
          isSpiritual: false,
          currentStreak: 0,
        ),
        50,
      );
    });

    test('calculatePoints adds 50% bonus for spiritual habits', () {
      // Difficulty 3 (30 points) + 50% spiritual bonus = 45
      expect(
        FaithPoint.calculatePoints(
          difficultyLevel: 3,
          isSpiritual: true,
          currentStreak: 0,
        ),
        45,
      );
    });

    test('calculatePoints adds streak bonus (capped at 50)', () {
      // Difficulty 1 (10 points) + streak 5 (25 points) = 35
      expect(
        FaithPoint.calculatePoints(
          difficultyLevel: 1,
          isSpiritual: false,
          currentStreak: 5,
        ),
        35,
      );

      // Difficulty 1 (10 points) + streak 20 (capped at 50) = 60
      expect(
        FaithPoint.calculatePoints(
          difficultyLevel: 1,
          isSpiritual: false,
          currentStreak: 20,
        ),
        60,
      );
    });

    test('calculatePoints combines all bonuses correctly', () {
      // Difficulty 5 (50) + spiritual bonus (75) + streak 3 (15) = 90
      expect(
        FaithPoint.calculatePoints(
          difficultyLevel: 5,
          isSpiritual: true,
          currentStreak: 3,
        ),
        90,
      );
    });

    test('toJson and fromJson serialize correctly', () {
      final original = FaithPoint(
        id: 'test-id',
        userId: 'user-123',
        points: 45,
        habitId: 'habit-456',
        habitName: 'Prayer',
        earnedAt: DateTime(2024, 1, 15, 10, 30),
        reason: 'Completed Prayer',
      );

      final json = original.toJson();
      final deserialized = FaithPoint.fromJson(json);

      expect(deserialized.id, original.id);
      expect(deserialized.userId, original.userId);
      expect(deserialized.points, original.points);
      expect(deserialized.habitId, original.habitId);
      expect(deserialized.habitName, original.habitName);
      expect(deserialized.earnedAt, original.earnedAt);
      expect(deserialized.reason, original.reason);
    });
  });
}
