import '../../data/badge_repository.dart';
import '../../data/journey_level_repository.dart';
import '../models/badge.dart';

/// Service for checking and unlocking badges
class BadgeService {
  final BadgeRepository _badgeRepo;
  final JourneyLevelRepository _levelRepo;

  BadgeService({
    required BadgeRepository badgeRepository,
    required JourneyLevelRepository levelRepository,
  })  : _badgeRepo = badgeRepository,
        _levelRepo = levelRepository;

  /// Check and unlock badges based on current points
  Future<List<Badge>> checkAndUnlockBadges(String userId) async {
    final badges = await _badgeRepo.getBadges(userId);
    final level = await _levelRepo.getLevel(userId);

    if (level == null) return [];

    final newlyUnlocked = <Badge>[];
    final now = DateTime.now();

    for (final badge in badges) {
      if (!badge.isUnlocked &&
          level.totalPoints >= badge.fruit.requiredPoints) {
        final unlockedBadge = await _badgeRepo.unlockBadge(
          userId,
          badge.fruit,
          now,
        );
        newlyUnlocked.add(unlockedBadge);
      }
    }

    return newlyUnlocked;
  }

  /// Get all badges for a user
  Future<List<Badge>> getBadges(String userId) async {
    return await _badgeRepo.getBadges(userId);
  }

  /// Get unlocked badges
  Future<List<Badge>> getUnlockedBadges(String userId) async {
    final badges = await _badgeRepo.getBadges(userId);
    return badges.where((b) => b.isUnlocked).toList();
  }

  /// Get locked badges
  Future<List<Badge>> getLockedBadges(String userId) async {
    final badges = await _badgeRepo.getBadges(userId);
    return badges.where((b) => !b.isUnlocked).toList();
  }

  /// Get badge progress (percentage towards next badge)
  Future<BadgeProgress> getNextBadgeProgress(String userId) async {
    final level = await _levelRepo.getLevel(userId);
    if (level == null) {
      return BadgeProgress(
        nextBadge: null,
        progress: 0.0,
        pointsNeeded: 0,
      );
    }

    final lockedBadges = await getLockedBadges(userId);
    if (lockedBadges.isEmpty) {
      return BadgeProgress(
        nextBadge: null,
        progress: 1.0,
        pointsNeeded: 0,
      );
    }

    // Find the badge with lowest required points
    lockedBadges.sort(
        (a, b) => a.fruit.requiredPoints.compareTo(b.fruit.requiredPoints));

    final nextBadge = lockedBadges.first;
    final pointsNeeded = nextBadge.fruit.requiredPoints - level.totalPoints;
    final progress =
        (level.totalPoints / nextBadge.fruit.requiredPoints).clamp(0.0, 1.0);

    return BadgeProgress(
      nextBadge: nextBadge,
      progress: progress,
      pointsNeeded: pointsNeeded > 0 ? pointsNeeded : 0,
    );
  }
}

class BadgeProgress {
  final Badge? nextBadge;
  final double progress;
  final int pointsNeeded;

  const BadgeProgress({
    required this.nextBadge,
    required this.progress,
    required this.pointsNeeded,
  });
}
