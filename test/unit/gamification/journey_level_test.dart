import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/gamification/domain/models/journey_level.dart';

void main() {
  group('JourneyStage', () {
    test('has correct display names', () {
      expect(JourneyStage.wilderness.displayName, 'Wilderness');
      expect(JourneyStage.promisedLand.displayName, 'Promised Land');
    });

    test('has correct required points', () {
      expect(JourneyStage.wilderness.requiredPoints, 0);
      expect(JourneyStage.desert.requiredPoints, 100);
      expect(JourneyStage.jordan.requiredPoints, 300);
      expect(JourneyStage.canaan.requiredPoints, 600);
      expect(JourneyStage.jerusalem.requiredPoints, 1000);
      expect(JourneyStage.promisedLand.requiredPoints, 1500);
    });
  });

  group('JourneyLevel', () {
    test('initial creates level at wilderness with 0 points', () {
      final level = JourneyLevel.initial('user-123');

      expect(level.userId, 'user-123');
      expect(level.currentStage, JourneyStage.wilderness);
      expect(level.totalPoints, 0);
    });

    test('progressToNext calculates correctly within a stage', () {
      // 200 points = halfway between desert (100) and jordan (300)
      final level = JourneyLevel(
        userId: 'user-123',
        currentStage: JourneyStage.desert,
        totalPoints: 200,
        lastUpdatedAt: DateTime.now(),
      );

      expect(level.progressToNext, closeTo(0.5, 0.01));
    });

    test('progressToNext returns 1.0 at max level', () {
      final level = JourneyLevel(
        userId: 'user-123',
        currentStage: JourneyStage.promisedLand,
        totalPoints: 2000,
        lastUpdatedAt: DateTime.now(),
      );

      expect(level.progressToNext, 1.0);
    });

    test('nextStage returns correct next stage', () {
      final level = JourneyLevel(
        userId: 'user-123',
        currentStage: JourneyStage.desert,
        totalPoints: 150,
        lastUpdatedAt: DateTime.now(),
      );

      expect(level.nextStage, JourneyStage.jordan);
    });

    test('nextStage returns null at max level', () {
      final level = JourneyLevel(
        userId: 'user-123',
        currentStage: JourneyStage.promisedLand,
        totalPoints: 1500,
        lastUpdatedAt: DateTime.now(),
      );

      expect(level.nextStage, null);
    });

    test('canLevelUp returns true when points exceed next stage requirement', () {
      final level = JourneyLevel(
        userId: 'user-123',
        currentStage: JourneyStage.wilderness,
        totalPoints: 150,
        lastUpdatedAt: DateTime.now(),
      );

      expect(level.canLevelUp(), true);
    });

    test('canLevelUp returns false when not enough points', () {
      final level = JourneyLevel(
        userId: 'user-123',
        currentStage: JourneyStage.wilderness,
        totalPoints: 50,
        lastUpdatedAt: DateTime.now(),
      );

      expect(level.canLevelUp(), false);
    });

    test('addPoints increases total and updates stage correctly', () {
      final initial = JourneyLevel.initial('user-123');
      final timestamp = DateTime(2024, 1, 15);

      // Add 150 points → should level up to desert
      final updated = initial.addPoints(150, timestamp);

      expect(updated.totalPoints, 150);
      expect(updated.currentStage, JourneyStage.desert);
      expect(updated.lastUpdatedAt, timestamp);
    });

    test('addPoints advances multiple stages if enough points', () {
      final initial = JourneyLevel.initial('user-123');
      final timestamp = DateTime(2024, 1, 15);

      // Add 700 points → should level up to canaan (requires 600)
      final updated = initial.addPoints(700, timestamp);

      expect(updated.totalPoints, 700);
      expect(updated.currentStage, JourneyStage.canaan);
    });

    test('toJson and fromJson serialize correctly', () {
      final original = JourneyLevel(
        userId: 'user-123',
        currentStage: JourneyStage.jordan,
        totalPoints: 450,
        lastUpdatedAt: DateTime(2024, 1, 15, 10, 30),
      );

      final json = original.toJson();
      final deserialized = JourneyLevel.fromJson(json);

      expect(deserialized.userId, original.userId);
      expect(deserialized.currentStage, original.currentStage);
      expect(deserialized.totalPoints, original.totalPoints);
      expect(deserialized.lastUpdatedAt, original.lastUpdatedAt);
    });
  });
}
