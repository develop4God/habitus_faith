// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generation_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GenerationRequestImpl _$$GenerationRequestImplFromJson(
  Map<String, dynamic> json,
) =>
    _$GenerationRequestImpl(
      userGoal: json['userGoal'] as String,
      failurePattern: json['failurePattern'] as String?,
      faithContext: json['faithContext'] as String? ?? 'Cristiano',
      languageCode: json['languageCode'] as String? ?? 'es',
    );

Map<String, dynamic> _$$GenerationRequestImplToJson(
  _$GenerationRequestImpl instance,
) =>
    <String, dynamic>{
      'userGoal': instance.userGoal,
      'failurePattern': instance.failurePattern,
      'faithContext': instance.faithContext,
      'languageCode': instance.languageCode,
    };
