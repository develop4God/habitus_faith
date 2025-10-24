import 'package:freezed_annotation/freezed_annotation.dart';

part 'verse_reference.freezed.dart';
part 'verse_reference.g.dart';

/// Biblical verse reference for habits
@freezed
class VerseReference with _$VerseReference {
  const factory VerseReference({
    required String book,
    required int chapter,
    required int verse,
    String? endVerse,
  }) = _VerseReference;

  factory VerseReference.fromJson(Map<String, dynamic> json) =>
      _$VerseReferenceFromJson(json);

  const VerseReference._();

  /// Human-readable format: "John 3:16" or "Romans 12:1-2"
  String get displayText {
    if (endVerse != null) {
      return '$book $chapter:$verse-$endVerse';
    }
    return '$book $chapter:$verse';
  }
}
