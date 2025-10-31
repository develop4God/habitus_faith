// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'micro_habit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MicroHabitImpl _$$MicroHabitImplFromJson(Map<String, dynamic> json) =>
    _$MicroHabitImpl(
      id: json['id'] as String,
      action: json['action'] as String,
      verse: json['verse'] as String,
      verseText: json['verseText'] as String?,
      purpose: json['purpose'] as String,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 5,
      generatedAt: json['generatedAt'] == null
          ? null
          : DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$$MicroHabitImplToJson(_$MicroHabitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'action': instance.action,
      'verse': instance.verse,
      'verseText': instance.verseText,
      'purpose': instance.purpose,
      'estimatedMinutes': instance.estimatedMinutes,
      'generatedAt': instance.generatedAt?.toIso8601String(),
    };
