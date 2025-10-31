import 'package:freezed_annotation/freezed_annotation.dart';

part 'micro_habit.freezed.dart';
part 'micro_habit.g.dart';

/// Domain model for AI-generated micro-habits
/// Pure Dart class with no state management dependencies for reusability
@freezed
class MicroHabit with _$MicroHabit {
  const factory MicroHabit({
    required String id,
    required String action, // "Orar 3min al despertar antes del teléfono"
    required String verse, // "Salmos 5:3"
    String? verseText, // "Oh Jehová, de mañana oirás mi voz..."
    required String purpose, // "Comenzar el día reconociendo a Dios"
    @Default(5) int estimatedMinutes,
    DateTime? generatedAt,
  }) = _MicroHabit;

  factory MicroHabit.fromJson(Map<String, dynamic> json) =>
      _$MicroHabitFromJson(json);
}
