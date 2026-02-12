import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

/// Simple validation result for notification time confirmation.
enum ValidationStatus { valid, info, warning, conflict, invalid, ambiguousAmPm, timezoneError }

class ValidationResult {
  final ValidationStatus status;
  final String? message;
  final String? errorCode;
  final List<TimeOfDay> suggestedTimes;
  final TimeOfDay? correctedTime;
  final List<TimeOfDay> conflictingTimes;
  final Map<String, dynamic>? raw;

  ValidationResult({
    required this.status,
    this.message,
    this.errorCode,
    this.suggestedTimes = const [],
    this.correctedTime,
    this.conflictingTimes = const [],
    this.raw,
  });
}

/// A small, pure validator for clock-hour notifications.
///
/// Designed to be conservative and deterministic (accepts an optional `now`).
class NotificationValidator {
  /// Validate a requested [TimeOfDay].
  ///
  /// - If [clockHourOnly] is true, minutes must be zero.
  /// - [existingScheduledTimes] may be used to detect conflicts (exact match or within [allowNearConflictsWindow] minutes).
  /// - [userTimezone] is optional; if provided it will be verified.
  /// - [now] may be provided (as tz.TZDateTime in tz.local) for deterministic checks (tests).
  static Future<ValidationResult> validate({
    required TimeOfDay requestedTime,
    List<TimeOfDay>? existingScheduledTimes,
    String? userTimezone,
    bool clockHourOnly = true,
    int allowNearConflictsWindow = 0,
    tz.TZDateTime? now,
  }) async {
    existingScheduledTimes ??= const [];

    // 1) Basic minutes rule
    if (clockHourOnly && requestedTime.minute != 0) {
      final suggested = TimeOfDay(hour: requestedTime.hour, minute: 0);
      return ValidationResult(
        status: ValidationStatus.invalid,
        errorCode: 'INVALID_MINUTES',
        message: 'Clock-hour reminders must have minutes set to :00.',
        suggestedTimes: [suggested],
        correctedTime: suggested,
      );
    }

    // 2) Timezone validation (best-effort)
    if (userTimezone != null && userTimezone.isNotEmpty) {
      try {
        tz.getLocation(userTimezone);
      } catch (e) {
        return ValidationResult(
          status: ValidationStatus.timezoneError,
          errorCode: 'TIMEZONE_NOT_FOUND',
          message: 'Could not resolve the selected timezone.',
        );
      }
    }

    // 3) Conflict detection (exact match or within window)
    for (final t in existingScheduledTimes) {
      final int minutesA = requestedTime.hour * 60 + requestedTime.minute;
      final int minutesB = t.hour * 60 + t.minute;
      final int diff = (minutesA - minutesB).abs();
      if (diff == 0 || (allowNearConflictsWindow > 0 && diff <= allowNearConflictsWindow)) {
        // suggest +/- 1 hour as basic suggestions
        final beforeHour = TimeOfDay(hour: (requestedTime.hour - 1) % 24, minute: 0);
        final afterHour = TimeOfDay(hour: (requestedTime.hour + 1) % 24, minute: 0);
        return ValidationResult(
          status: ValidationStatus.conflict,
          errorCode: 'TIME_CONFLICT',
          message: 'There is already a reminder at the selected hour.',
          suggestedTimes: [afterHour, beforeHour],
          conflictingTimes: [t],
        );
      }
    }

    // 4) Past time check (if now provided)
    if (now != null) {
      try {
        final tz.TZDateTime scheduled = tz.TZDateTime(
            tz.local, now.year, now.month, now.day, requestedTime.hour, requestedTime.minute);
        if (scheduled.isBefore(now)) {
          final suggested = TimeOfDay(hour: requestedTime.hour, minute: requestedTime.minute);
          return ValidationResult(
            status: ValidationStatus.info,
            message: 'The selected time is earlier than now — it will be scheduled for tomorrow.',
            suggestedTimes: [suggested],
            raw: {'scheduledToday': scheduled.toString()},
          );
        }
      } catch (e) {
        // If tz throws for DST oddities, return timezone error
        return ValidationResult(
          status: ValidationStatus.timezoneError,
          errorCode: 'DST_AMBIGUOUS',
          message: 'The chosen local time is ambiguous due to timezone rules (DST).',
        );
      }
    }

    // 5) Default: valid
    return ValidationResult(
      status: ValidationStatus.valid,
      message: 'Looks good — we will remind you at the selected time.',
    );
  }
}

