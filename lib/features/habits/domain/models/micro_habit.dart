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

  factory MicroHabit.fromJson(Map<String, dynamic> json) {
    // Fix: allow estimatedMinutes to be double or int
    final raw = json['estimatedMinutes'];
    int minutes = 5;
    if (raw is int) {
      minutes = raw;
    } else if (raw is double) {
      minutes = raw.round();
    } else if (raw != null) {
      minutes = int.tryParse(raw.toString()) ?? 5;
    }
    return _MicroHabit(
      id: json['id'] as String? ?? '',
      action: json['action'] as String? ?? '',
      verse: json['verse'] as String? ?? '',
      verseText: json['verseText'] as String?,
      purpose: json['purpose'] as String? ?? '',
      estimatedMinutes: minutes,
      generatedAt: json['generatedAt'] == null ? null : DateTime.tryParse(json['generatedAt'].toString()),
    );
  }
}
