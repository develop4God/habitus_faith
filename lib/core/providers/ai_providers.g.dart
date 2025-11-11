// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bibleDbServiceHash() => r'72f293b5ef89775da50f7cc174c2f1c4ea12cfce';

/// Provider for Bible database service (for verse enrichment)
/// Uses default Spanish RVR1960 version
///
/// Copied from [bibleDbService].
@ProviderFor(bibleDbService)
final bibleDbServiceProvider =
    AutoDisposeFutureProvider<BibleDbService?>.internal(
  bibleDbService,
  name: r'bibleDbServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bibleDbServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BibleDbServiceRef = AutoDisposeFutureProviderRef<BibleDbService?>;
String _$loggerHash() => r'd82e17351f7a6c96c7ef50f1535546f76e38e5b9';

/// Provider for logger instance
///
/// Copied from [logger].
@ProviderFor(logger)
final loggerProvider = AutoDisposeProvider<Logger>.internal(
  logger,
  name: r'loggerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$loggerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LoggerRef = AutoDisposeProviderRef<Logger>;
String _$cacheServiceHash() => r'f6a834603c48562a7bdb40c7e576149a167fb10d';

/// Provider for cache service
///
/// Copied from [cacheService].
@ProviderFor(cacheService)
final cacheServiceProvider = AutoDisposeProvider<ICacheService>.internal(
  cacheService,
  name: r'cacheServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cacheServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CacheServiceRef = AutoDisposeProviderRef<ICacheService>;
String _$rateLimitServiceHash() => r'e4131004ca6c03162ee33c4b5d6cecc63191d9d4';

/// Provider for rate limit service
///
/// Copied from [rateLimitService].
@ProviderFor(rateLimitService)
final rateLimitServiceProvider =
    AutoDisposeProvider<IRateLimitService>.internal(
  rateLimitService,
  name: r'rateLimitServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rateLimitServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RateLimitServiceRef = AutoDisposeProviderRef<IRateLimitService>;
String _$geminiServiceHash() => r'13dc1468f26d8611f69b3dd189bf6d8b90e7b2e8';

/// Provider for Gemini service with optional Bible enrichment
///
/// Copied from [geminiService].
@ProviderFor(geminiService)
final geminiServiceProvider =
    AutoDisposeFutureProvider<IGeminiService>.internal(
  geminiService,
  name: r'geminiServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$geminiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GeminiServiceRef = AutoDisposeFutureProviderRef<IGeminiService>;
String _$microHabitGeneratorHash() =>
    r'18f811dfabb0c13a0880bee63caabe36c38a9533';

/// State provider for micro-habit generation
///
/// Copied from [MicroHabitGenerator].
@ProviderFor(MicroHabitGenerator)
final microHabitGeneratorProvider = AutoDisposeAsyncNotifierProvider<
    MicroHabitGenerator, List<MicroHabit>>.internal(
  MicroHabitGenerator.new,
  name: r'microHabitGeneratorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$microHabitGeneratorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MicroHabitGenerator = AutoDisposeAsyncNotifier<List<MicroHabit>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
