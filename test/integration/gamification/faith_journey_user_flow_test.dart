import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/gamification/data/faith_points_repository.dart';
import 'package:habitus_faith/features/gamification/data/journey_level_repository.dart';
import 'package:habitus_faith/features/gamification/data/badge_repository.dart';
import 'package:habitus_faith/features/gamification/domain/services/faith_points_service.dart';
import 'package:habitus_faith/features/gamification/domain/services/badge_service.dart';
import 'package:habitus_faith/features/gamification/domain/models/journey_level.dart';
import 'package:habitus_faith/features/gamification/domain/models/badge.dart';

/// Integration test focused on real user behavior:
/// Complete habits → earn faith points → progress through journey → unlock badges
void main() {
  group('Faith Journey User Flow Integration', () {
    late FaithPointsService faithService;
    late BadgeService badgeService;
    late SharedPreferences prefs;
    const userId = 'test-user';

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      final pointsRepo = FaithPointsRepository(prefs);
      final levelRepo = JourneyLevelRepository(prefs);
      final badgeRepo = BadgeRepository(prefs);

      faithService = FaithPointsService(
        pointsRepository: pointsRepo,
        levelRepository: levelRepo,
      );

      badgeService = BadgeService(
        badgeRepository: badgeRepo,
        levelRepository: levelRepo,
      );
    });

    test('User completes spiritual habit and earns points', () async {
      // Given a new user
      final initialLevel = await faithService.getJourneyLevel(userId);
      expect(initialLevel.currentStage, JourneyStage.wilderness);
      expect(initialLevel.totalPoints, 0);

      // When user completes a spiritual habit with difficulty 3 and streak 0
      final result = await faithService.awardPointsForHabit(
        userId: userId,
        habitId: 'habit-1',
        habitName: 'Morning Prayer',
        difficultyLevel: 3,
        isSpiritual: true,
        currentStreak: 0,
      );

      // Then points should be awarded (30 base + 50% spiritual = 45)
      expect(result.pointsAwarded, 45);
      expect(result.newTotalPoints, 45);
      expect(result.currentStage, JourneyStage.wilderness);
      expect(result.leveledUp, false);
    });

    test('User maintains streak and earns bonus points', () async {
      // Given user with initial points
      await faithService.awardPointsForHabit(
        userId: userId,
        habitId: 'habit-1',
        habitName: 'Prayer',
        difficultyLevel: 2,
        isSpiritual: true,
        currentStreak: 0,
      );

      // When user completes same habit with a 7-day streak
      final result = await faithService.awardPointsForHabit(
        userId: userId,
        habitId: 'habit-1',
        habitName: 'Prayer',
        difficultyLevel: 2,
        isSpiritual: true,
        currentStreak: 7,
      );

      // Then streak bonus should be added (20 base + 50% spiritual (30) + 35 streak = 65)
      expect(result.pointsAwarded, 65);
    });

    test('User progresses through journey stages', () async {
      // Given a user at wilderness
      var level = await faithService.getJourneyLevel(userId);
      expect(level.currentStage, JourneyStage.wilderness);

      // When user earns 150 points total
      await faithService.awardPointsForHabit(
        userId: userId,
        habitId: 'habit-1',
        habitName: 'Prayer',
        difficultyLevel: 5,
        isSpiritual: true,
        currentStreak: 3,
      );

      await faithService.awardPointsForHabit(
        userId: userId,
        habitId: 'habit-2',
        habitName: 'Bible Reading',
        difficultyLevel: 4,
        isSpiritual: true,
        currentStreak: 2,
      );

      // Then user should advance to desert stage (requires 100 points)
      level = await faithService.getJourneyLevel(userId);
      expect(level.currentStage, JourneyStage.desert);
      expect(level.totalPoints, greaterThanOrEqualTo(100));
    });

    test('User unlocks Peace badge at 100 points', () async {
      // Given a user with no badges
      var badges = await badgeService.getBadges(userId);
      expect(badges.every((b) => !b.isUnlocked), true);

      // When user earns 100+ points
      await faithService.awardPointsForHabit(
        userId: userId,
        habitId: 'habit-1',
        habitName: 'Prayer',
        difficultyLevel: 5,
        isSpiritual: true,
        currentStreak: 3,
      );

      await faithService.awardPointsForHabit(
        userId: userId,
        habitId: 'habit-2',
        habitName: 'Bible Reading',
        difficultyLevel: 3,
        isSpiritual: true,
        currentStreak: 2,
      );

      // And checks for badge unlocks
      final unlockedBadges = await badgeService.checkAndUnlockBadges(userId);

      // Then Peace badge should be unlocked (requires 100 points)
      expect(unlockedBadges.isNotEmpty, true);
      final peaceBadge = unlockedBadges.firstWhere(
        (b) => b.fruit == FruitOfSpirit.peace,
        orElse: () => throw Exception('Peace badge not found'),
      );
      expect(peaceBadge.isUnlocked, true);
    });

    test('User tracks progress towards next badge', () async {
      // Given a user with 50 points
      await faithService.awardPointsForHabit(
        userId: userId,
        habitId: 'habit-1',
        habitName: 'Prayer',
        difficultyLevel: 5,
        isSpiritual: false,
        currentStreak: 0,
      );

      // When checking badge progress
      final progress = await badgeService.getNextBadgeProgress(userId);

      // Then should show progress towards Peace badge (100 points required)
      expect(progress.nextBadge, isNotNull);
      expect(progress.nextBadge!.fruit, FruitOfSpirit.peace);
      expect(progress.progress, closeTo(0.5, 0.01)); // 50/100
      expect(progress.pointsNeeded, 50);
    });

    test('Complete user journey from wilderness to promised land', () async {
      // Given a new user
      var level = await faithService.getJourneyLevel(userId);
      expect(level.currentStage, JourneyStage.wilderness);

      // When user completes many spiritual habits over time
      final habitCompletions = [
        {'difficulty': 5, 'streak': 5}, // 75 + 25 = 100
        {'difficulty': 5, 'streak': 7}, // 75 + 35 = 110
        {'difficulty': 5, 'streak': 10}, // 75 + 50 = 125
        {'difficulty': 5, 'streak': 12}, // 75 + 50 = 125 (capped)
        {'difficulty': 4, 'streak': 15}, // 60 + 50 = 110
        {'difficulty': 5, 'streak': 20}, // 75 + 50 = 125 (capped)
        {'difficulty': 5, 'streak': 25}, // 75 + 50 = 125 (capped)
        {'difficulty': 5, 'streak': 30}, // 75 + 50 = 125 (capped)
        {'difficulty': 4, 'streak': 35}, // 60 + 50 = 110 (capped)
        {'difficulty': 5, 'streak': 40}, // 75 + 50 = 125 (capped)
        {'difficulty': 5, 'streak': 45}, // 75 + 50 = 125 (capped)
        {'difficulty': 5, 'streak': 50}, // 75 + 50 = 125 (capped)
        {'difficulty': 4, 'streak': 50}, // 60 + 50 = 110 (capped)
        {'difficulty': 5, 'streak': 55}, // 75 + 50 = 125 (capped)
      ];

      for (int i = 0; i < habitCompletions.length; i++) {
        final completion = habitCompletions[i];
        await faithService.awardPointsForHabit(
          userId: userId,
          habitId: 'habit-$i',
          habitName: 'Habit $i',
          difficultyLevel: completion['difficulty'] as int,
          isSpiritual: true,
          currentStreak: completion['streak'] as int,
        );
      }

      // Then user should reach Promised Land (1500+ points)
      level = await faithService.getJourneyLevel(userId);
      expect(level.totalPoints, greaterThanOrEqualTo(1500));
      expect(level.currentStage, JourneyStage.promisedLand);

      // And multiple badges should be unlocked
      final unlockedBadges = await badgeService.checkAndUnlockBadges(userId);
      final allBadges = await badgeService.getUnlockedBadges(userId);
      expect(allBadges.length, greaterThan(3)); // Should have multiple badges
    });

    test('Different habit categories earn appropriate points', () async {
      // Spiritual habits earn 50% more points
      final spiritualResult = await faithService.awardPointsForHabit(
        userId: userId,
        habitId: 'spiritual',
        habitName: 'Prayer',
        difficultyLevel: 2,
        isSpiritual: true,
        currentStreak: 0,
      );

      // Non-spiritual habits earn base points
      final physicalResult = await faithService.awardPointsForHabit(
        userId: 'user-2',
        habitId: 'physical',
        habitName: 'Exercise',
        difficultyLevel: 2,
        isSpiritual: false,
        currentStreak: 0,
      );

      // Spiritual should earn 50% more (20 base → 30 with bonus)
      expect(spiritualResult.pointsAwarded, 30);
      expect(physicalResult.pointsAwarded, 20);
    });

    test('Points earned today are tracked separately', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final today = DateTime.now();

      // Award points yesterday
      await faithService.awardPointsForHabit(
        userId: userId,
        habitId: 'habit-yesterday',
        habitName: 'Yesterday',
        difficultyLevel: 3,
        isSpiritual: false,
        currentStreak: 0,
        timestamp: yesterday,
      );

      // Award points today
      await faithService.awardPointsForHabit(
        userId: userId,
        habitId: 'habit-today',
        habitName: 'Today',
        difficultyLevel: 2,
        isSpiritual: false,
        currentStreak: 0,
        timestamp: today,
      );

      // Should only count today's points
      final todayPoints = await faithService.getPointsToday(userId);
      expect(todayPoints, 20); // Only difficulty 2 habit from today
    });
  });
}
