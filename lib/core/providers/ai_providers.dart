import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../config/env_config.dart';
import '../services/cache/cache_service.dart';
import '../services/ai/rate_limit_service.dart';
import '../services/ai/gemini_service.dart';
import '../../features/habits/domain/models/micro_habit.dart';
import '../../features/habits/domain/models/generation_request.dart';
import '../../features/habits/data/storage/storage_providers.dart';
import '../../bible_reader_core/src/bible_db_service.dart';

part 'ai_providers.g.dart';

/// Provider for Bible database service (for verse enrichment)
/// Uses default Spanish RVR1960 version
@riverpod
Future<BibleDbService?> bibleDbService(BibleDbServiceRef ref) async {
  try {
    final service = BibleDbService();
    await service.initDb('assets/biblia/RVR1960.SQLite3', 'RVR1960.SQLite3');
    return service;
  } catch (e) {
    // Graceful degradation - continue without verse enrichment
    return null;
  }
}

/// Provider for logger instance
@riverpod
Logger logger(LoggerRef ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
}

/// Provider for cache service
@riverpod
ICacheService cacheService(CacheServiceRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CacheService(prefs);
}

/// Provider for rate limit service
@riverpod
IRateLimitService rateLimitService(RateLimitServiceRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return RateLimitService(prefs);
}

/// Provider for Gemini service with optional Bible enrichment
@riverpod
Future<IGeminiService> geminiService(GeminiServiceRef ref) async {
  final bibleService = await ref.watch(bibleDbServiceProvider.future);

  return GeminiService(
    apiKey: EnvConfig.geminiApiKey,
    modelName: EnvConfig.geminiModel,
    cache: ref.watch(cacheServiceProvider),
    rateLimit: ref.watch(rateLimitServiceProvider),
    logger: ref.watch(loggerProvider),
    bibleService: bibleService, // NOW ACTIVE!
  );
}

/// State provider for micro-habit generation
@riverpod
class MicroHabitGenerator extends _$MicroHabitGenerator {
  @override
  FutureOr<List<MicroHabit>> build() async => [];

  /// Generate micro-habits based on user request
  Future<void> generate(GenerationRequest request) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final service = await ref.read(geminiServiceProvider.future);
      return await service.generateMicroHabits(request);
    });
  }

  /// Get remaining API requests for the current month
  int get remainingRequests =>
      ref.read(rateLimitServiceProvider).getRemainingRequests();
}
