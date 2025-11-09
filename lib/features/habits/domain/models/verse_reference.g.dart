// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse_reference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VerseReferenceImpl _$$VerseReferenceImplFromJson(Map<String, dynamic> json) =>
    _$VerseReferenceImpl(
      book: json['book'] as String,
      chapter: (json['chapter'] as num).toInt(),
      verse: (json['verse'] as num).toInt(),
      endVerse: json['endVerse'] as String?,
    );

Map<String, dynamic> _$$VerseReferenceImplToJson(
  _$VerseReferenceImpl instance,
) => <String, dynamic>{
  'book': instance.book,
  'chapter': instance.chapter,
  'verse': instance.verse,
  'endVerse': instance.endVerse,
};
