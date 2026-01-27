// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'micro_habit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MicroHabit _$MicroHabitFromJson(Map<String, dynamic> json) {
  return _MicroHabit.fromJson(json);
}

/// @nodoc
mixin _$MicroHabit {
  String get id => throw _privateConstructorUsedError;
  String get action =>
      throw _privateConstructorUsedError; // "Orar 3min al despertar antes del teléfono"
  String get verse => throw _privateConstructorUsedError; // "Salmos 5:3"
  String? get verseText =>
      throw _privateConstructorUsedError; // "Oh Jehová, de mañana oirás mi voz..."
  String get purpose =>
      throw _privateConstructorUsedError; // "Comenzar el día reconociendo a Dios"
  int get estimatedMinutes => throw _privateConstructorUsedError;
  DateTime? get generatedAt => throw _privateConstructorUsedError;

  /// Serializes this MicroHabit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MicroHabit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MicroHabitCopyWith<MicroHabit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MicroHabitCopyWith<$Res> {
  factory $MicroHabitCopyWith(
    MicroHabit value,
    $Res Function(MicroHabit) then,
  ) = _$MicroHabitCopyWithImpl<$Res, MicroHabit>;
  @useResult
  $Res call({
    String id,
    String action,
    String verse,
    String? verseText,
    String purpose,
    int estimatedMinutes,
    DateTime? generatedAt,
  });
}

/// @nodoc
class _$MicroHabitCopyWithImpl<$Res, $Val extends MicroHabit>
    implements $MicroHabitCopyWith<$Res> {
  _$MicroHabitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MicroHabit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? action = null,
    Object? verse = null,
    Object? verseText = freezed,
    Object? purpose = null,
    Object? estimatedMinutes = null,
    Object? generatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String,
            verse: null == verse
                ? _value.verse
                : verse // ignore: cast_nullable_to_non_nullable
                      as String,
            verseText: freezed == verseText
                ? _value.verseText
                : verseText // ignore: cast_nullable_to_non_nullable
                      as String?,
            purpose: null == purpose
                ? _value.purpose
                : purpose // ignore: cast_nullable_to_non_nullable
                      as String,
            estimatedMinutes: null == estimatedMinutes
                ? _value.estimatedMinutes
                : estimatedMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            generatedAt: freezed == generatedAt
                ? _value.generatedAt
                : generatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MicroHabitImplCopyWith<$Res>
    implements $MicroHabitCopyWith<$Res> {
  factory _$$MicroHabitImplCopyWith(
    _$MicroHabitImpl value,
    $Res Function(_$MicroHabitImpl) then,
  ) = __$$MicroHabitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String action,
    String verse,
    String? verseText,
    String purpose,
    int estimatedMinutes,
    DateTime? generatedAt,
  });
}

/// @nodoc
class __$$MicroHabitImplCopyWithImpl<$Res>
    extends _$MicroHabitCopyWithImpl<$Res, _$MicroHabitImpl>
    implements _$$MicroHabitImplCopyWith<$Res> {
  __$$MicroHabitImplCopyWithImpl(
    _$MicroHabitImpl _value,
    $Res Function(_$MicroHabitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MicroHabit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? action = null,
    Object? verse = null,
    Object? verseText = freezed,
    Object? purpose = null,
    Object? estimatedMinutes = null,
    Object? generatedAt = freezed,
  }) {
    return _then(
      _$MicroHabitImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String,
        verse: null == verse
            ? _value.verse
            : verse // ignore: cast_nullable_to_non_nullable
                  as String,
        verseText: freezed == verseText
            ? _value.verseText
            : verseText // ignore: cast_nullable_to_non_nullable
                  as String?,
        purpose: null == purpose
            ? _value.purpose
            : purpose // ignore: cast_nullable_to_non_nullable
                  as String,
        estimatedMinutes: null == estimatedMinutes
            ? _value.estimatedMinutes
            : estimatedMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        generatedAt: freezed == generatedAt
            ? _value.generatedAt
            : generatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MicroHabitImpl implements _MicroHabit {
  const _$MicroHabitImpl({
    required this.id,
    required this.action,
    required this.verse,
    this.verseText,
    required this.purpose,
    this.estimatedMinutes = 5,
    this.generatedAt,
  });

  factory _$MicroHabitImpl.fromJson(Map<String, dynamic> json) =>
      _$$MicroHabitImplFromJson(json);

  @override
  final String id;
  @override
  final String action;
  // "Orar 3min al despertar antes del teléfono"
  @override
  final String verse;
  // "Salmos 5:3"
  @override
  final String? verseText;
  // "Oh Jehová, de mañana oirás mi voz..."
  @override
  final String purpose;
  // "Comenzar el día reconociendo a Dios"
  @override
  @JsonKey()
  final int estimatedMinutes;
  @override
  final DateTime? generatedAt;

  @override
  String toString() {
    return 'MicroHabit(id: $id, action: $action, verse: $verse, verseText: $verseText, purpose: $purpose, estimatedMinutes: $estimatedMinutes, generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MicroHabitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.verse, verse) || other.verse == verse) &&
            (identical(other.verseText, verseText) ||
                other.verseText == verseText) &&
            (identical(other.purpose, purpose) || other.purpose == purpose) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    action,
    verse,
    verseText,
    purpose,
    estimatedMinutes,
    generatedAt,
  );

  /// Create a copy of MicroHabit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MicroHabitImplCopyWith<_$MicroHabitImpl> get copyWith =>
      __$$MicroHabitImplCopyWithImpl<_$MicroHabitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MicroHabitImplToJson(this);
  }
}

abstract class _MicroHabit implements MicroHabit {
  const factory _MicroHabit({
    required final String id,
    required final String action,
    required final String verse,
    final String? verseText,
    required final String purpose,
    final int estimatedMinutes,
    final DateTime? generatedAt,
  }) = _$MicroHabitImpl;

  factory _MicroHabit.fromJson(Map<String, dynamic> json) =
      _$MicroHabitImpl.fromJson;

  @override
  String get id;
  @override
  String get action; // "Orar 3min al despertar antes del teléfono"
  @override
  String get verse; // "Salmos 5:3"
  @override
  String? get verseText; // "Oh Jehová, de mañana oirás mi voz..."
  @override
  String get purpose; // "Comenzar el día reconociendo a Dios"
  @override
  int get estimatedMinutes;
  @override
  DateTime? get generatedAt;

  /// Create a copy of MicroHabit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MicroHabitImplCopyWith<_$MicroHabitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
