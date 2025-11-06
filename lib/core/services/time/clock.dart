/// Clock abstraction for testable time-dependent code
///
/// Provides a clean interface for getting the current time,
/// allowing tests to use fixed times and enabling optional
/// time acceleration for dogfooding.
abstract class Clock {
  /// Get the current time
  DateTime now();

  /// Factory constructor for system clock (production)
  const factory Clock.system() = SystemClock;

  /// Factory constructor for fixed clock (testing)
  const factory Clock.fixed(DateTime fixedTime) = FixedClock;

  /// Factory constructor for debug clock with time acceleration (dogfooding)
  factory Clock.debug({required int daySpeedMultiplier}) {
    return DebugClock(daySpeedMultiplier: daySpeedMultiplier);
  }
}

/// System clock implementation - uses actual system time
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Fixed clock implementation - returns a fixed time (for testing)
class FixedClock implements Clock {
  final DateTime fixedTime;

  const FixedClock(this.fixedTime);

  @override
  DateTime now() => fixedTime;
}

/// Debug clock implementation - time acceleration for dogfooding
/// Allows simulating days/weeks passing in minutes
class DebugClock implements Clock {
  final DateTime _startTime;
  final int daySpeedMultiplier;

  /// Maximum allowed speed multiplier to prevent overflow (1000x = 1 day in ~90 seconds)
  static const int maxSpeedMultiplier = 1000;

  /// Creates a debug clock with time acceleration
  ///
  /// [daySpeedMultiplier]: Speed multiplier for time passage
  ///   - 1 = normal time (default)
  ///   - 288 = 24 hours in 5 minutes (1 week in 35 minutes)
  ///   - Maximum: 1000 (to prevent overflow)
  ///
  /// Throws [ArgumentError] if daySpeedMultiplier is invalid.
  DebugClock({this.daySpeedMultiplier = 1}) : _startTime = DateTime.now() {
    if (daySpeedMultiplier < 1) {
      throw ArgumentError(
        'daySpeedMultiplier must be at least 1, got $daySpeedMultiplier',
      );
    }
    if (daySpeedMultiplier > maxSpeedMultiplier) {
      throw ArgumentError(
        'daySpeedMultiplier must be at most $maxSpeedMultiplier, got $daySpeedMultiplier',
      );
    }
  }

  @override
  DateTime now() {
    final elapsed = DateTime.now().difference(_startTime);

    // Check for potential overflow before multiplication
    final maxSafeMicroseconds = (double.maxFinite / daySpeedMultiplier).floor();
    if (elapsed.inMicroseconds > maxSafeMicroseconds) {
      // Clamp to maximum safe value to prevent overflow
      final acceleratedMicroseconds = maxSafeMicroseconds * daySpeedMultiplier;
      return _startTime.add(Duration(microseconds: acceleratedMicroseconds));
    }

    // Safe to multiply - no overflow risk
    final acceleratedMicroseconds =
        (elapsed.inMicroseconds * daySpeedMultiplier).toInt();
    return _startTime.add(Duration(microseconds: acceleratedMicroseconds));
  }
}
