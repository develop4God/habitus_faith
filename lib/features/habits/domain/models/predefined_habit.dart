import 'package:freezed_annotation/freezed_annotation.dart';
import 'verse_reference.dart';

part 'predefined_habit.freezed.dart';
part 'predefined_habit.g.dart';

enum PredefinedHabitCategory { spiritual, physical, mental, relational }

/// Predefined habit template with localization keys
@freezed
class PredefinedHabit with _$PredefinedHabit {
  const factory PredefinedHabit({
    required String id,
    required String emoji,
    required String nameKey,
    required String descriptionKey,
    required PredefinedHabitCategory category,
    VerseReference? verse,
    String? suggestedTime, // e.g., "morning", "evening"
  }) = _PredefinedHabit;

  factory PredefinedHabit.fromJson(Map<String, dynamic> json) =>
      _$PredefinedHabitFromJson(json);
}
