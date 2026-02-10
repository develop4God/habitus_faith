import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/gamification/data/faith_points_repository.dart';
import 'package:habitus_faith/features/gamification/data/journey_level_repository.dart';
import 'package:habitus_faith/features/gamification/domain/models/journey_level.dart';
import 'package:habitus_faith/features/gamification/domain/services/faith_points_service.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('FaithPointsService', () {
    late FaithPointsRepository pointsRepo;
    late JourneyLevelRepository levelRepo;
    late FaithPointsService service;
    late SharedPreferences prefs;
    const testUserId = 'test-user-123';

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      pointsRepo = FaithPointsRepository(prefs);
      levelRepo = JourneyLevelRepository(prefs);
      service = FaithPointsService(
        pointsRepository: pointsRepo,
        levelRepository: levelRepo,
        uuid: const Uuid(),
      );
    });

    tearDown(() async {
      await pointsRepo.clearAll();
      await levelRepo.clearAll();
    });

    test('awardPointsForHabit creates faith point and updates level', () async {
      // Act
      final result = await service.awardPointsForHabit(
        userId: testUserId,
        habitId: 'habit-1',
        habitName: 'Morning Prayer',
        difficultyLevel: 3,
        isSpiritual: true,
        currentStreak: 5,
        timestamp: DateTime(2024, 1, 15),
      );

      // Assert
      expect(
          result.pointsAwarded, 70); // 30 base + 50% spiritual (45) + 25 streak
      expect(result.newTotalPoints, 70);
      expect(result.currentStage, JourneyStage.wilderness);
      expect(result.leveledUp, false);

      // Verify faith point was saved
      final points = await pointsRepo.getPoints(testUserId);
      expect(points.length, 1);
      expect(points[0].points, 70);
      expect(points[0].habitName, 'Morning Prayer');
    });

    test('awardPointsForHabit levels up user when threshold reached', () async {
      // Act - Award enough points to reach desert (100 points)
      final result = await service.awardPointsForHabit(
        userId: testUserId,
        habitId: 'habit-1',
        habitName: 'Bible Reading',
        difficultyLevel: 5,
        isSpiritual: true,
        currentStreak: 2,
        timestamp: DateTime(2024, 1, 15),
      );

      // Assert - 50 base + 50% spiritual (75) + 10 streak = 85
      expect(result.pointsAwarded, 85);
      expect(result.currentStage, JourneyStage.wilderness);
      expect(result.leveledUp, false);

      // Award more points to level up
      final result2 = await service.awardPointsForHabit(
        userId: testUserId,
        habitId: 'habit-2',
        habitName: 'Prayer',
        difficultyLevel: 3,
        isSpiritual: true,
        currentStreak: 1,
        timestamp: DateTime(2024, 1, 16),
      );

      // Assert - 30 base + 50% spiritual (45) + 5 streak = 50
      expect(result2.pointsAwarded, 50);
      expect(result2.newTotalPoints, 135); // 85 + 50
      expect(result2.currentStage, JourneyStage.desert);
      expect(result2.leveledUp, true);
      expect(result2.previousStage, JourneyStage.wilderness);
    });

    test('getTotalPoints returns correct total', () async {
      // Arrange - Award some points
      await service.awardPointsForHabit(
        userId: testUserId,
        habitId: 'habit-1',
        habitName: 'Test',
        difficultyLevel: 2,
        isSpiritual: false,
        currentStreak: 0,
      );

      // Act
      final total = await service.getTotalPoints(testUserId);

      // Assert
      expect(total, 20); // Difficulty 2 = 20 points
    });

    test('getJourneyLevel initializes level for new user', () async {
      // Act
      final level = await service.getJourneyLevel(testUserId);

      // Assert
      expect(level.userId, testUserId);
      expect(level.currentStage, JourneyStage.wilderness);
      expect(level.totalPoints, 0);
    });

    test('getRecentPoints returns limited number of recent points', () async {
      // Arrange - Award multiple points
      for (int i = 0; i < 15; i++) {
        await service.awardPointsForHabit(
          userId: testUserId,
          habitId: 'habit-$i',
          habitName: 'Habit $i',
          difficultyLevel: 1,
          isSpiritual: false,
          currentStreak: 0,
        );
      }

      // Act
      final recent = await service.getRecentPoints(testUserId, limit: 5);

      // Assert
      expect(recent.length, 5);
      // Most recent should be first
      expect(recent[0].habitName, contains('14'));
    });

    test('getPointsToday returns points earned today only', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      // Arrange - Award points yesterday
      await service.awardPointsForHabit(
        userId: testUserId,
        habitId: 'habit-1',
        habitName: 'Yesterday',
        difficultyLevel: 3,
        isSpiritual: false,
        currentStreak: 0,
        timestamp: yesterday,
      );

      // Award points today
      await service.awardPointsForHabit(
        userId: testUserId,
        habitId: 'habit-2',
        habitName: 'Today',
        difficultyLevel: 2,
        isSpiritual: false,
        currentStreak: 0,
        timestamp: today,
      );

      // Act
      final todayPoints = await service.getPointsToday(testUserId);

      // Assert - Only today's points (20)
      expect(todayPoints, 20);
    });

    test('multiple users maintain separate point totals', () async {
      const user1 = 'user-1';
      const user2 = 'user-2';

      // Arrange - Award different points to each user
      await service.awardPointsForHabit(
        userId: user1,
        habitId: 'habit-1',
        habitName: 'Test',
        difficultyLevel: 5,
        isSpiritual: false,
        currentStreak: 0,
      );

      await service.awardPointsForHabit(
        userId: user2,
        habitId: 'habit-2',
        habitName: 'Test',
        difficultyLevel: 2,
        isSpiritual: false,
        currentStreak: 0,
      );

      // Act
      final total1 = await service.getTotalPoints(user1);
      final total2 = await service.getTotalPoints(user2);

      // Assert
      expect(total1, 50);
      expect(total2, 20);
    });
  });
}
