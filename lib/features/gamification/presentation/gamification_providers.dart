import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../habits/data/storage/storage_providers.dart';
import '../data/faith_points_repository.dart';
import '../data/journey_level_repository.dart';
import '../data/badge_repository.dart';
import '../domain/services/faith_points_service.dart';
import '../domain/services/badge_service.dart';
import '../domain/models/journey_level.dart';
import '../domain/models/badge.dart' as gamification;

// Repository Providers
final faithPointsRepositoryProvider = Provider<FaithPointsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FaithPointsRepository(prefs);
});

final journeyLevelRepositoryProvider = Provider<JourneyLevelRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return JourneyLevelRepository(prefs);
});

final badgeRepositoryProvider = Provider<BadgeRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return BadgeRepository(prefs);
});

// Service Providers
final faithPointsServiceProvider = Provider<FaithPointsService>((ref) {
  final pointsRepo = ref.watch(faithPointsRepositoryProvider);
  final levelRepo = ref.watch(journeyLevelRepositoryProvider);
  return FaithPointsService(
    pointsRepository: pointsRepo,
    levelRepository: levelRepo,
  );
});

final badgeServiceProvider = Provider<BadgeService>((ref) {
  final badgeRepo = ref.watch(badgeRepositoryProvider);
  final levelRepo = ref.watch(journeyLevelRepositoryProvider);
  return BadgeService(
    badgeRepository: badgeRepo,
    levelRepository: levelRepo,
  );
});

// State Providers

/// Provider for current user's journey level
final journeyLevelProvider =
    FutureProvider.family<JourneyLevel, String>((ref, userId) async {
  final service = ref.watch(faithPointsServiceProvider);
  return await service.getJourneyLevel(userId);
});

/// Provider for current user's badges
final badgesProvider = FutureProvider.family<List<gamification.Badge>, String>(
    (ref, userId) async {
  final service = ref.watch(badgeServiceProvider);
  return await service.getBadges(userId);
});

/// Provider for unlocked badges
final unlockedBadgesProvider =
    FutureProvider.family<List<gamification.Badge>, String>(
        (ref, userId) async {
  final service = ref.watch(badgeServiceProvider);
  return await service.getUnlockedBadges(userId);
});

/// Provider for total faith points
final totalFaithPointsProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final service = ref.watch(faithPointsServiceProvider);
  return await service.getTotalPoints(userId);
});

/// Provider for points earned today
final pointsTodayProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final service = ref.watch(faithPointsServiceProvider);
  return await service.getPointsToday(userId);
});
