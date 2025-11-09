// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generation_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GenerationRequest _$GenerationRequestFromJson(Map<String, dynamic> json) {
  return _GenerationRequest.fromJson(json);
}

/// @nodoc
mixin _$GenerationRequest {
  String get userGoal =>
      throw _privateConstructorUsedError; // "Quiero orar más consistentemente"
  String? get failurePattern =>
      throw _privateConstructorUsedError; // "Olvido en las mañanas ocupadas"
  String get faithContext => throw _privateConstructorUsedError;
  String get languageCode => throw _privateConstructorUsedError;

  /// Serializes this GenerationRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GenerationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GenerationRequestCopyWith<GenerationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GenerationRequestCopyWith<$Res> {
  factory $GenerationRequestCopyWith(
          GenerationRequest value, $Res Function(GenerationRequest) then) =
      _$GenerationRequestCopyWithImpl<$Res, GenerationRequest>;
  @useResult
  $Res call(
      {String userGoal,
      String? failurePattern,
      String faithContext,
      String languageCode});
}

/// @nodoc
class _$GenerationRequestCopyWithImpl<$Res, $Val extends GenerationRequest>
    implements $GenerationRequestCopyWith<$Res> {
  _$GenerationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GenerationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userGoal = null,
    Object? failurePattern = freezed,
    Object? faithContext = null,
    Object? languageCode = null,
  }) {
    return _then(_value.copyWith(
      userGoal: null == userGoal
          ? _value.userGoal
          : userGoal // ignore: cast_nullable_to_non_nullable
              as String,
      failurePattern: freezed == failurePattern
          ? _value.failurePattern
          : failurePattern // ignore: cast_nullable_to_non_nullable
              as String?,
      faithContext: null == faithContext
          ? _value.faithContext
          : faithContext // ignore: cast_nullable_to_non_nullable
              as String,
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GenerationRequestImplCopyWith<$Res>
    implements $GenerationRequestCopyWith<$Res> {
  factory _$$GenerationRequestImplCopyWith(_$GenerationRequestImpl value,
          $Res Function(_$GenerationRequestImpl) then) =
      __$$GenerationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userGoal,
      String? failurePattern,
      String faithContext,
      String languageCode});
}

/// @nodoc
class __$$GenerationRequestImplCopyWithImpl<$Res>
    extends _$GenerationRequestCopyWithImpl<$Res, _$GenerationRequestImpl>
    implements _$$GenerationRequestImplCopyWith<$Res> {
  __$$GenerationRequestImplCopyWithImpl(_$GenerationRequestImpl _value,
      $Res Function(_$GenerationRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of GenerationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userGoal = null,
    Object? failurePattern = freezed,
    Object? faithContext = null,
    Object? languageCode = null,
  }) {
    return _then(_$GenerationRequestImpl(
      userGoal: null == userGoal
          ? _value.userGoal
          : userGoal // ignore: cast_nullable_to_non_nullable
              as String,
      failurePattern: freezed == failurePattern
          ? _value.failurePattern
          : failurePattern // ignore: cast_nullable_to_non_nullable
              as String?,
      faithContext: null == faithContext
          ? _value.faithContext
          : faithContext // ignore: cast_nullable_to_non_nullable
              as String,
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GenerationRequestImpl extends _GenerationRequest {
  const _$GenerationRequestImpl(
      {required this.userGoal,
      this.failurePattern,
      this.faithContext = 'Cristiano',
      this.languageCode = 'es'})
      : super._();

  factory _$GenerationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$GenerationRequestImplFromJson(json);

  @override
  final String userGoal;
// "Quiero orar más consistentemente"
  @override
  final String? failurePattern;
// "Olvido en las mañanas ocupadas"
  @override
  @JsonKey()
  final String faithContext;
  @override
  @JsonKey()
  final String languageCode;

  @override
  String toString() {
    return 'GenerationRequest(userGoal: $userGoal, failurePattern: $failurePattern, faithContext: $faithContext, languageCode: $languageCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GenerationRequestImpl &&
            (identical(other.userGoal, userGoal) ||
                other.userGoal == userGoal) &&
            (identical(other.failurePattern, failurePattern) ||
                other.failurePattern == failurePattern) &&
            (identical(other.faithContext, faithContext) ||
                other.faithContext == faithContext) &&
            (identical(other.languageCode, languageCode) ||
                other.languageCode == languageCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, userGoal, failurePattern, faithContext, languageCode);

  /// Create a copy of GenerationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GenerationRequestImplCopyWith<_$GenerationRequestImpl> get copyWith =>
      __$$GenerationRequestImplCopyWithImpl<_$GenerationRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GenerationRequestImplToJson(
      this,
    );
  }
}

abstract class _GenerationRequest extends GenerationRequest {
  const factory _GenerationRequest(
      {required final String userGoal,
      final String? failurePattern,
      final String faithContext,
      final String languageCode}) = _$GenerationRequestImpl;
  const _GenerationRequest._() : super._();

  factory _GenerationRequest.fromJson(Map<String, dynamic> json) =
      _$GenerationRequestImpl.fromJson;

  @override
  String get userGoal; // "Quiero orar más consistentemente"
  @override
  String? get failurePattern; // "Olvido en las mañanas ocupadas"
  @override
  String get faithContext;
  @override
  String get languageCode;

  /// Create a copy of GenerationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GenerationRequestImplCopyWith<_$GenerationRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
