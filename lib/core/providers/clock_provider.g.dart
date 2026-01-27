// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$clockHash() => r'7d0bca9f23a3bb3f7498b9a507251d3a39dda975';

/// Provider for Clock abstraction
///
/// In production mode: uses SystemClock
/// In debug mode with FAST_TIME flag: uses DebugClock with 288x speed
/// In tests: can be overridden with FixedClock or custom clock
///
/// Copied from [clock].
@ProviderFor(clock)
final clockProvider = Provider<Clock>.internal(
  clock,
  name: r'clockProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$clockHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ClockRef = ProviderRef<Clock>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
