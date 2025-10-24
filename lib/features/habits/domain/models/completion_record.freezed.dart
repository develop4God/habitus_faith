// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'completion_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CompletionRecord _$CompletionRecordFromJson(Map<String, dynamic> json) {
  return _CompletionRecord.fromJson(json);
}

/// @nodoc
mixin _$CompletionRecord {
  String get habitId => throw _privateConstructorUsedError;
  DateTime get completedAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this CompletionRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CompletionRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompletionRecordCopyWith<CompletionRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompletionRecordCopyWith<$Res> {
  factory $CompletionRecordCopyWith(
          CompletionRecord value, $Res Function(CompletionRecord) then) =
      _$CompletionRecordCopyWithImpl<$Res, CompletionRecord>;
  @useResult
  $Res call({String habitId, DateTime completedAt, String? notes});
}

/// @nodoc
class _$CompletionRecordCopyWithImpl<$Res, $Val extends CompletionRecord>
    implements $CompletionRecordCopyWith<$Res> {
  _$CompletionRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompletionRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? habitId = null,
    Object? completedAt = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      habitId: null == habitId
          ? _value.habitId
          : habitId // ignore: cast_nullable_to_non_nullable
              as String,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CompletionRecordImplCopyWith<$Res>
    implements $CompletionRecordCopyWith<$Res> {
  factory _$$CompletionRecordImplCopyWith(_$CompletionRecordImpl value,
          $Res Function(_$CompletionRecordImpl) then) =
      __$$CompletionRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String habitId, DateTime completedAt, String? notes});
}

/// @nodoc
class __$$CompletionRecordImplCopyWithImpl<$Res>
    extends _$CompletionRecordCopyWithImpl<$Res, _$CompletionRecordImpl>
    implements _$$CompletionRecordImplCopyWith<$Res> {
  __$$CompletionRecordImplCopyWithImpl(_$CompletionRecordImpl _value,
      $Res Function(_$CompletionRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of CompletionRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? habitId = null,
    Object? completedAt = null,
    Object? notes = freezed,
  }) {
    return _then(_$CompletionRecordImpl(
      habitId: null == habitId
          ? _value.habitId
          : habitId // ignore: cast_nullable_to_non_nullable
              as String,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompletionRecordImpl extends _CompletionRecord {
  const _$CompletionRecordImpl(
      {required this.habitId, required this.completedAt, this.notes})
      : super._();

  factory _$CompletionRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompletionRecordImplFromJson(json);

  @override
  final String habitId;
  @override
  final DateTime completedAt;
  @override
  final String? notes;

  @override
  String toString() {
    return 'CompletionRecord(habitId: $habitId, completedAt: $completedAt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompletionRecordImpl &&
            (identical(other.habitId, habitId) || other.habitId == habitId) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, habitId, completedAt, notes);

  /// Create a copy of CompletionRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompletionRecordImplCopyWith<_$CompletionRecordImpl> get copyWith =>
      __$$CompletionRecordImplCopyWithImpl<_$CompletionRecordImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompletionRecordImplToJson(
      this,
    );
  }
}

abstract class _CompletionRecord extends CompletionRecord {
  const factory _CompletionRecord(
      {required final String habitId,
      required final DateTime completedAt,
      final String? notes}) = _$CompletionRecordImpl;
  const _CompletionRecord._() : super._();

  factory _CompletionRecord.fromJson(Map<String, dynamic> json) =
      _$CompletionRecordImpl.fromJson;

  @override
  String get habitId;
  @override
  DateTime get completedAt;
  @override
  String? get notes;

  /// Create a copy of CompletionRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompletionRecordImplCopyWith<_$CompletionRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
