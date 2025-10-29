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
