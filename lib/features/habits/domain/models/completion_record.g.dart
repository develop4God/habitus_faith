// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completion_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompletionRecordImpl _$$CompletionRecordImplFromJson(
        Map<String, dynamic> json) =>
    _$CompletionRecordImpl(
      habitId: json['habitId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$CompletionRecordImplToJson(
        _$CompletionRecordImpl instance) =>
    <String, dynamic>{
      'habitId': instance.habitId,
      'completedAt': instance.completedAt.toIso8601String(),
      'notes': instance.notes,
    };
