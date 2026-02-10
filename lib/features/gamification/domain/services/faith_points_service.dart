import 'package:uuid/uuid.dart';
import '../../data/faith_points_repository.dart';
import '../../data/journey_level_repository.dart';
import '../models/faith_point.dart';
import '../models/journey_level.dart';

/// Service for managing faith points and progression
class FaithPointsService {
  final FaithPointsRepository _pointsRepo;
  final JourneyLevelRepository _levelRepo;
  final Uuid _uuid;

  FaithPointsService({
    required FaithPointsRepository pointsRepository,
    required JourneyLevelRepository levelRepository,
    Uuid? uuid,
  })  : _pointsRepo = pointsRepository,
        _levelRepo = levelRepository,
        _uuid = uuid ?? const Uuid();

  /// Award points for completing a habit
  Future<AwardResult> awardPointsForHabit({
    required String userId,
    required String habitId,
    required String habitName,
    required int difficultyLevel,
    required bool isSpiritual,
    required int currentStreak,
    DateTime? timestamp,
  }) async {
    final now = timestamp ?? DateTime.now();

    // Calculate points
    final points = FaithPoint.calculatePoints(
      difficultyLevel: difficultyLevel,
      isSpiritual: isSpiritual,
      currentStreak: currentStreak,
    );

    // Create faith point record
    final faithPoint = FaithPoint(
      id: _uuid.v4(),
      userId: userId,
      points: points,
      habitId: habitId,
      habitName: habitName,
      earnedAt: now,
      reason: 'Completed $habitName',
    );

    // Add to repository
    await _pointsRepo.addPoint(faithPoint);

    // Update journey level
    var level = await _levelRepo.getLevel(userId);
    if (level == null) {
      level = await _levelRepo.initializeForUser(userId);
    }

    final oldStage = level.currentStage;
    final newLevel = level.addPoints(points, now);
    await _levelRepo.saveLevel(newLevel);

    final leveledUp = newLevel.currentStage != oldStage;

    return AwardResult(
      pointsAwarded: points,
      newTotalPoints: newLevel.totalPoints,
      currentStage: newLevel.currentStage,
      leveledUp: leveledUp,
      previousStage: leveledUp ? oldStage : null,
    );
  }

  /// Get current total points for a user
  Future<int> getTotalPoints(String userId) async {
    return await _pointsRepo.getTotalPoints(userId);
  }

  /// Get current journey level for a user
  Future<JourneyLevel> getJourneyLevel(String userId) async {
    var level = await _levelRepo.getLevel(userId);
    if (level == null) {
      level = await _levelRepo.initializeForUser(userId);
    }
    return level;
  }

  /// Get recent points history
  Future<List<FaithPoint>> getRecentPoints(String userId,
      {int limit = 10}) async {
    final allPoints = await _pointsRepo.getPoints(userId);
    allPoints.sort((a, b) => b.earnedAt.compareTo(a.earnedAt));
    return allPoints.take(limit).toList();
  }

  /// Get points earned today
  Future<int> getPointsToday(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final todayPoints = await _pointsRepo.getPointsInPeriod(
      userId,
      startOfDay,
      endOfDay,
    );

    return todayPoints.fold<int>(0, (sum, p) => sum + p.points);
  }
}

/// Result of awarding points
class AwardResult {
  final int pointsAwarded;
  final int newTotalPoints;
  final JourneyStage currentStage;
  final bool leveledUp;
  final JourneyStage? previousStage;

  const AwardResult({
    required this.pointsAwarded,
    required this.newTotalPoints,
    required this.currentStage,
    required this.leveledUp,
    this.previousStage,
  });
}
