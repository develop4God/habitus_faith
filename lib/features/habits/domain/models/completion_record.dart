import 'package:freezed_annotation/freezed_annotation.dart';

part 'completion_record.freezed.dart';
part 'completion_record.g.dart';

/// Daily completion record for a habit
@freezed
class CompletionRecord with _$CompletionRecord {
  const factory CompletionRecord({
    required String habitId,
    required DateTime completedAt,
    String? notes,
    // ML features for abandonment prediction
    int? hourOfDay, // 0-23, hour when action occurred
    int? dayOfWeek, // 1-7, Monday=1, Sunday=7
    int? streakAtTime, // user's current streak when this record was created
    int? failuresLast7Days, // count of missed days in prior 7 days
    int? hoursFromReminder, // hours elapsed since scheduled reminder time
    bool? completed, // true if habit was completed, false if abandoned
  }) = _CompletionRecord;

  factory CompletionRecord.fromJson(Map<String, dynamic> json) =>
      _$CompletionRecordFromJson(json);

  const CompletionRecord._();

  /// Get date-only string for grouping (YYYY-MM-DD)
  String get dateKey {
    final date = DateTime(
      completedAt.year,
      completedAt.month,
      completedAt.day,
    );
    return date.toIso8601String().split('T')[0];
  }
}
