// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completion_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompletionRecordImpl _$$CompletionRecordImplFromJson(
  Map<String, dynamic> json,
) => _$CompletionRecordImpl(
  habitId: json['habitId'] as String,
  completedAt: DateTime.parse(json['completedAt'] as String),
  notes: json['notes'] as String?,
  hourOfDay: (json['hourOfDay'] as num?)?.toInt(),
  dayOfWeek: (json['dayOfWeek'] as num?)?.toInt(),
  streakAtTime: (json['streakAtTime'] as num?)?.toInt(),
  failuresLast7Days: (json['failuresLast7Days'] as num?)?.toInt(),
  hoursFromReminder: (json['hoursFromReminder'] as num?)?.toInt(),
  completed: json['completed'] as bool?,
);

Map<String, dynamic> _$$CompletionRecordImplToJson(
  _$CompletionRecordImpl instance,
) => <String, dynamic>{
  'habitId': instance.habitId,
  'completedAt': instance.completedAt.toIso8601String(),
  'notes': instance.notes,
  'hourOfDay': instance.hourOfDay,
  'dayOfWeek': instance.dayOfWeek,
  'streakAtTime': instance.streakAtTime,
  'failuresLast7Days': instance.failuresLast7Days,
  'hoursFromReminder': instance.hoursFromReminder,
  'completed': instance.completed,
};
