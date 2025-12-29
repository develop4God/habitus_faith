// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'predefined_habit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PredefinedHabitImpl _$$PredefinedHabitImplFromJson(
        Map<String, dynamic> json) =>
    _$PredefinedHabitImpl(
      id: json['id'] as String,
      emoji: json['emoji'] as String,
      nameKey: json['nameKey'] as String,
      descriptionKey: json['descriptionKey'] as String?,
      category: $enumDecode(_$PredefinedHabitCategoryEnumMap, json['category']),
      verse: json['verse'] == null
          ? null
          : VerseReference.fromJson(json['verse'] as Map<String, dynamic>),
      suggestedTime: json['suggestedTime'] as String?,
    );

Map<String, dynamic> _$$PredefinedHabitImplToJson(
        _$PredefinedHabitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'emoji': instance.emoji,
      'nameKey': instance.nameKey,
      'descriptionKey': instance.descriptionKey,
      'category': _$PredefinedHabitCategoryEnumMap[instance.category]!,
      'verse': instance.verse,
      'suggestedTime': instance.suggestedTime,
    };

const _$PredefinedHabitCategoryEnumMap = {
  PredefinedHabitCategory.spiritual: 'spiritual',
  PredefinedHabitCategory.physical: 'physical',
  PredefinedHabitCategory.mental: 'mental',
  PredefinedHabitCategory.relational: 'relational',
};
