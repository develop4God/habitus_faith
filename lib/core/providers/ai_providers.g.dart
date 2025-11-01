// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bibleDbServiceHash() => r'0af91e65f6b1f537e7da93b2c1f05b5b61a4d328';

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
String _$loggerHash() => r'8b7e11a155f4beb9e222fb7f4bf6f651d0da24d3';

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
String _$cacheServiceHash() => r'999391311237c437e6a805774e202f1054c2485a';

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
String _$rateLimitServiceHash() => r'34461cb97a53e3c5972e36a36412bd794fa594e3';

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
String _$geminiServiceHash() => r'3f12640f30e4b008631815b6434c1fc869f32884';

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
