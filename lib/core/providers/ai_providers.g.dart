// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

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
String _$geminiServiceHash() => r'44b18986aade21fb0ec0731b5b2f5356a037e3c4';

/// Provider for Gemini service
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
