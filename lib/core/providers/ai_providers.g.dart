// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

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
String _$geminiServiceHash() => r'bf56a152b4716147a3c8cd9bb668e42f623b84c8';

/// Provider for Gemini service with optional Bible enrichment
///
/// Copied from [geminiService].
@ProviderFor(geminiService)
final geminiServiceProvider = AutoDisposeProvider<IGeminiService>.internal(
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
typedef GeminiServiceRef = AutoDisposeProviderRef<IGeminiService>;
String _$microHabitGeneratorHash() =>
    r'd8bbe9a1fab2818db328b3b35501fcd9f5cd9c9c';

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
