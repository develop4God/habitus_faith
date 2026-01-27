import 'package:freezed_annotation/freezed_annotation.dart';

part 'generation_request.freezed.dart';
part 'generation_request.g.dart';

/// Request DTO for micro-habit generation
/// State-agnostic for use across different state management patterns
@freezed
class GenerationRequest with _$GenerationRequest {
  const factory GenerationRequest({
    required String userGoal, // "Quiero orar más consistentemente"
    String? failurePattern, // "Olvido en las mañanas ocupadas"
    @Default('Cristiano') String faithContext,
    @Default('es') String languageCode,
  }) = _GenerationRequest;

  const GenerationRequest._();

  factory GenerationRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerationRequestFromJson(json);

  /// Generate cache key from request parameters
  String toCacheKey() =>
      '${userGoal}_${failurePattern}_${faithContext}_$languageCode'.hashCode
          .abs()
          .toString();
}
