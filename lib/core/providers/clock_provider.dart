import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/time/time.dart';

part 'clock_provider.g.dart';

/// Provider for Clock abstraction
///
/// In production mode: uses SystemClock
/// In debug mode with FAST_TIME flag: uses DebugClock with 288x speed
/// In tests: can be overridden with FixedClock or custom clock
@Riverpod(keepAlive: true)
Clock clock(Ref ref) {
  // Check if FAST_TIME flag is enabled via --dart-define
  const fastTime = bool.fromEnvironment('FAST_TIME');

  if (fastTime && kDebugMode) {
    // 1 week = 35 minutes (288x speed: 24 hours in 5 minutes)
    return DebugClock(daySpeedMultiplier: 288);
  }

  // Production: use system clock
  return const Clock.system();
}
