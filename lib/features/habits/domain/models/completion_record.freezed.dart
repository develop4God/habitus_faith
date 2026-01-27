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
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CompletionRecord _$CompletionRecordFromJson(Map<String, dynamic> json) {
  return _CompletionRecord.fromJson(json);
}

/// @nodoc
mixin _$CompletionRecord {
  String get habitId => throw _privateConstructorUsedError;
  DateTime get completedAt => throw _privateConstructorUsedError;
  String? get notes =>
      throw _privateConstructorUsedError; // ML features for abandonment prediction
  int? get hourOfDay =>
      throw _privateConstructorUsedError; // 0-23, hour when action occurred
  int? get dayOfWeek =>
      throw _privateConstructorUsedError; // 1-7, Monday=1, Sunday=7
  int? get streakAtTime =>
      throw _privateConstructorUsedError; // user's current streak when this record was created
  int? get failuresLast7Days =>
      throw _privateConstructorUsedError; // count of missed days in prior 7 days
  int? get hoursFromReminder =>
      throw _privateConstructorUsedError; // hours elapsed since scheduled reminder time
  bool? get completed => throw _privateConstructorUsedError;

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
    CompletionRecord value,
    $Res Function(CompletionRecord) then,
  ) = _$CompletionRecordCopyWithImpl<$Res, CompletionRecord>;
  @useResult
  $Res call({
    String habitId,
    DateTime completedAt,
    String? notes,
    int? hourOfDay,
    int? dayOfWeek,
    int? streakAtTime,
    int? failuresLast7Days,
    int? hoursFromReminder,
    bool? completed,
  });
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
    Object? hourOfDay = freezed,
    Object? dayOfWeek = freezed,
    Object? streakAtTime = freezed,
    Object? failuresLast7Days = freezed,
    Object? hoursFromReminder = freezed,
    Object? completed = freezed,
  }) {
    return _then(
      _value.copyWith(
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
            hourOfDay: freezed == hourOfDay
                ? _value.hourOfDay
                : hourOfDay // ignore: cast_nullable_to_non_nullable
                      as int?,
            dayOfWeek: freezed == dayOfWeek
                ? _value.dayOfWeek
                : dayOfWeek // ignore: cast_nullable_to_non_nullable
                      as int?,
            streakAtTime: freezed == streakAtTime
                ? _value.streakAtTime
                : streakAtTime // ignore: cast_nullable_to_non_nullable
                      as int?,
            failuresLast7Days: freezed == failuresLast7Days
                ? _value.failuresLast7Days
                : failuresLast7Days // ignore: cast_nullable_to_non_nullable
                      as int?,
            hoursFromReminder: freezed == hoursFromReminder
                ? _value.hoursFromReminder
                : hoursFromReminder // ignore: cast_nullable_to_non_nullable
                      as int?,
            completed: freezed == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CompletionRecordImplCopyWith<$Res>
    implements $CompletionRecordCopyWith<$Res> {
  factory _$$CompletionRecordImplCopyWith(
    _$CompletionRecordImpl value,
    $Res Function(_$CompletionRecordImpl) then,
  ) = __$$CompletionRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String habitId,
    DateTime completedAt,
    String? notes,
    int? hourOfDay,
    int? dayOfWeek,
    int? streakAtTime,
    int? failuresLast7Days,
    int? hoursFromReminder,
    bool? completed,
  });
}

/// @nodoc
class __$$CompletionRecordImplCopyWithImpl<$Res>
    extends _$CompletionRecordCopyWithImpl<$Res, _$CompletionRecordImpl>
    implements _$$CompletionRecordImplCopyWith<$Res> {
  __$$CompletionRecordImplCopyWithImpl(
    _$CompletionRecordImpl _value,
    $Res Function(_$CompletionRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CompletionRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? habitId = null,
    Object? completedAt = null,
    Object? notes = freezed,
    Object? hourOfDay = freezed,
    Object? dayOfWeek = freezed,
    Object? streakAtTime = freezed,
    Object? failuresLast7Days = freezed,
    Object? hoursFromReminder = freezed,
    Object? completed = freezed,
  }) {
    return _then(
      _$CompletionRecordImpl(
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
        hourOfDay: freezed == hourOfDay
            ? _value.hourOfDay
            : hourOfDay // ignore: cast_nullable_to_non_nullable
                  as int?,
        dayOfWeek: freezed == dayOfWeek
            ? _value.dayOfWeek
            : dayOfWeek // ignore: cast_nullable_to_non_nullable
                  as int?,
        streakAtTime: freezed == streakAtTime
            ? _value.streakAtTime
            : streakAtTime // ignore: cast_nullable_to_non_nullable
                  as int?,
        failuresLast7Days: freezed == failuresLast7Days
            ? _value.failuresLast7Days
            : failuresLast7Days // ignore: cast_nullable_to_non_nullable
                  as int?,
        hoursFromReminder: freezed == hoursFromReminder
            ? _value.hoursFromReminder
            : hoursFromReminder // ignore: cast_nullable_to_non_nullable
                  as int?,
        completed: freezed == completed
            ? _value.completed
            : completed // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CompletionRecordImpl extends _CompletionRecord {
  const _$CompletionRecordImpl({
    required this.habitId,
    required this.completedAt,
    this.notes,
    this.hourOfDay,
    this.dayOfWeek,
    this.streakAtTime,
    this.failuresLast7Days,
    this.hoursFromReminder,
    this.completed,
  }) : super._();

  factory _$CompletionRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompletionRecordImplFromJson(json);

  @override
  final String habitId;
  @override
  final DateTime completedAt;
  @override
  final String? notes;
  // ML features for abandonment prediction
  @override
  final int? hourOfDay;
  // 0-23, hour when action occurred
  @override
  final int? dayOfWeek;
  // 1-7, Monday=1, Sunday=7
  @override
  final int? streakAtTime;
  // user's current streak when this record was created
  @override
  final int? failuresLast7Days;
  // count of missed days in prior 7 days
  @override
  final int? hoursFromReminder;
  // hours elapsed since scheduled reminder time
  @override
  final bool? completed;

  @override
  String toString() {
    return 'CompletionRecord(habitId: $habitId, completedAt: $completedAt, notes: $notes, hourOfDay: $hourOfDay, dayOfWeek: $dayOfWeek, streakAtTime: $streakAtTime, failuresLast7Days: $failuresLast7Days, hoursFromReminder: $hoursFromReminder, completed: $completed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompletionRecordImpl &&
            (identical(other.habitId, habitId) || other.habitId == habitId) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.hourOfDay, hourOfDay) ||
                other.hourOfDay == hourOfDay) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.streakAtTime, streakAtTime) ||
                other.streakAtTime == streakAtTime) &&
            (identical(other.failuresLast7Days, failuresLast7Days) ||
                other.failuresLast7Days == failuresLast7Days) &&
            (identical(other.hoursFromReminder, hoursFromReminder) ||
                other.hoursFromReminder == hoursFromReminder) &&
            (identical(other.completed, completed) ||
                other.completed == completed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    habitId,
    completedAt,
    notes,
    hourOfDay,
    dayOfWeek,
    streakAtTime,
    failuresLast7Days,
    hoursFromReminder,
    completed,
  );

  /// Create a copy of CompletionRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompletionRecordImplCopyWith<_$CompletionRecordImpl> get copyWith =>
      __$$CompletionRecordImplCopyWithImpl<_$CompletionRecordImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CompletionRecordImplToJson(this);
  }
}

abstract class _CompletionRecord extends CompletionRecord {
  const factory _CompletionRecord({
    required final String habitId,
    required final DateTime completedAt,
    final String? notes,
    final int? hourOfDay,
    final int? dayOfWeek,
    final int? streakAtTime,
    final int? failuresLast7Days,
    final int? hoursFromReminder,
    final bool? completed,
  }) = _$CompletionRecordImpl;
  const _CompletionRecord._() : super._();

  factory _CompletionRecord.fromJson(Map<String, dynamic> json) =
      _$CompletionRecordImpl.fromJson;

  @override
  String get habitId;
  @override
  DateTime get completedAt;
  @override
  String? get notes; // ML features for abandonment prediction
  @override
  int? get hourOfDay; // 0-23, hour when action occurred
  @override
  int? get dayOfWeek; // 1-7, Monday=1, Sunday=7
  @override
  int? get streakAtTime; // user's current streak when this record was created
  @override
  int? get failuresLast7Days; // count of missed days in prior 7 days
  @override
  int? get hoursFromReminder; // hours elapsed since scheduled reminder time
  @override
  bool? get completed;

  /// Create a copy of CompletionRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompletionRecordImplCopyWith<_$CompletionRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
