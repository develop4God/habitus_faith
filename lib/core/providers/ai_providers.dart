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

part 'ai_providers.g.dart';

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
IGeminiService geminiService(GeminiServiceRef ref) {
  return GeminiService(
    apiKey: EnvConfig.geminiApiKey,
    modelName: EnvConfig.geminiModel,
    cache: ref.watch(cacheServiceProvider),
    rateLimit: ref.watch(rateLimitServiceProvider),
    logger: ref.watch(loggerProvider),
    // Note: BibleDbService injection would require initialization
    // For now, it's optional and will be null (no enrichment)
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
      final service = ref.read(geminiServiceProvider);
      return await service.generateMicroHabits(request);
    });
  }

  /// Get remaining API requests for the current month
  int get remainingRequests =>
      ref.read(rateLimitServiceProvider).getRemainingRequests();
}
