// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'predefined_habit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PredefinedHabit _$PredefinedHabitFromJson(Map<String, dynamic> json) {
  return _PredefinedHabit.fromJson(json);
}

/// @nodoc
mixin _$PredefinedHabit {
  String get id => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  String get nameKey => throw _privateConstructorUsedError;
  String get descriptionKey => throw _privateConstructorUsedError;
  PredefinedHabitCategory get category => throw _privateConstructorUsedError;
  VerseReference? get verse => throw _privateConstructorUsedError;
  String? get suggestedTime => throw _privateConstructorUsedError;

  /// Serializes this PredefinedHabit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PredefinedHabit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PredefinedHabitCopyWith<PredefinedHabit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PredefinedHabitCopyWith<$Res> {
  factory $PredefinedHabitCopyWith(
          PredefinedHabit value, $Res Function(PredefinedHabit) then) =
      _$PredefinedHabitCopyWithImpl<$Res, PredefinedHabit>;
  @useResult
  $Res call(
      {String id,
      String emoji,
      String nameKey,
      String descriptionKey,
      PredefinedHabitCategory category,
      VerseReference? verse,
      String? suggestedTime});

  $VerseReferenceCopyWith<$Res>? get verse;
}

/// @nodoc
class _$PredefinedHabitCopyWithImpl<$Res, $Val extends PredefinedHabit>
    implements $PredefinedHabitCopyWith<$Res> {
  _$PredefinedHabitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PredefinedHabit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? emoji = null,
    Object? nameKey = null,
    Object? descriptionKey = null,
    Object? category = null,
    Object? verse = freezed,
    Object? suggestedTime = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      nameKey: null == nameKey
          ? _value.nameKey
          : nameKey // ignore: cast_nullable_to_non_nullable
              as String,
      descriptionKey: null == descriptionKey
          ? _value.descriptionKey
          : descriptionKey // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as PredefinedHabitCategory,
      verse: freezed == verse
          ? _value.verse
          : verse // ignore: cast_nullable_to_non_nullable
              as VerseReference?,
      suggestedTime: freezed == suggestedTime
          ? _value.suggestedTime
          : suggestedTime // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of PredefinedHabit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VerseReferenceCopyWith<$Res>? get verse {
    if (_value.verse == null) {
      return null;
    }

    return $VerseReferenceCopyWith<$Res>(_value.verse!, (value) {
      return _then(_value.copyWith(verse: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PredefinedHabitImplCopyWith<$Res>
    implements $PredefinedHabitCopyWith<$Res> {
  factory _$$PredefinedHabitImplCopyWith(_$PredefinedHabitImpl value,
          $Res Function(_$PredefinedHabitImpl) then) =
      __$$PredefinedHabitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String emoji,
      String nameKey,
      String descriptionKey,
      PredefinedHabitCategory category,
      VerseReference? verse,
      String? suggestedTime});

  @override
  $VerseReferenceCopyWith<$Res>? get verse;
}

/// @nodoc
class __$$PredefinedHabitImplCopyWithImpl<$Res>
    extends _$PredefinedHabitCopyWithImpl<$Res, _$PredefinedHabitImpl>
    implements _$$PredefinedHabitImplCopyWith<$Res> {
  __$$PredefinedHabitImplCopyWithImpl(
      _$PredefinedHabitImpl _value, $Res Function(_$PredefinedHabitImpl) _then)
      : super(_value, _then);

  /// Create a copy of PredefinedHabit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? emoji = null,
    Object? nameKey = null,
    Object? descriptionKey = null,
    Object? category = null,
    Object? verse = freezed,
    Object? suggestedTime = freezed,
  }) {
    return _then(_$PredefinedHabitImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      nameKey: null == nameKey
          ? _value.nameKey
          : nameKey // ignore: cast_nullable_to_non_nullable
              as String,
      descriptionKey: null == descriptionKey
          ? _value.descriptionKey
          : descriptionKey // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as PredefinedHabitCategory,
      verse: freezed == verse
          ? _value.verse
          : verse // ignore: cast_nullable_to_non_nullable
              as VerseReference?,
      suggestedTime: freezed == suggestedTime
          ? _value.suggestedTime
          : suggestedTime // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PredefinedHabitImpl implements _PredefinedHabit {
  const _$PredefinedHabitImpl(
      {required this.id,
      required this.emoji,
      required this.nameKey,
      required this.descriptionKey,
      required this.category,
      this.verse,
      this.suggestedTime});

  factory _$PredefinedHabitImpl.fromJson(Map<String, dynamic> json) =>
      _$$PredefinedHabitImplFromJson(json);

  @override
  final String id;
  @override
  final String emoji;
  @override
  final String nameKey;
  @override
  final String descriptionKey;
  @override
  final PredefinedHabitCategory category;
  @override
  final VerseReference? verse;
  @override
  final String? suggestedTime;

  @override
  String toString() {
    return 'PredefinedHabit(id: $id, emoji: $emoji, nameKey: $nameKey, descriptionKey: $descriptionKey, category: $category, verse: $verse, suggestedTime: $suggestedTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PredefinedHabitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.nameKey, nameKey) || other.nameKey == nameKey) &&
            (identical(other.descriptionKey, descriptionKey) ||
                other.descriptionKey == descriptionKey) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.verse, verse) || other.verse == verse) &&
            (identical(other.suggestedTime, suggestedTime) ||
                other.suggestedTime == suggestedTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, emoji, nameKey,
      descriptionKey, category, verse, suggestedTime);

  /// Create a copy of PredefinedHabit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PredefinedHabitImplCopyWith<_$PredefinedHabitImpl> get copyWith =>
      __$$PredefinedHabitImplCopyWithImpl<_$PredefinedHabitImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PredefinedHabitImplToJson(
      this,
    );
  }
}

abstract class _PredefinedHabit implements PredefinedHabit {
  const factory _PredefinedHabit(
      {required final String id,
      required final String emoji,
      required final String nameKey,
      required final String descriptionKey,
      required final PredefinedHabitCategory category,
      final VerseReference? verse,
      final String? suggestedTime}) = _$PredefinedHabitImpl;

  factory _PredefinedHabit.fromJson(Map<String, dynamic> json) =
      _$PredefinedHabitImpl.fromJson;

  @override
  String get id;
  @override
  String get emoji;
  @override
  String get nameKey;
  @override
  String get descriptionKey;
  @override
  PredefinedHabitCategory get category;
  @override
  VerseReference? get verse;
  @override
  String? get suggestedTime;

  /// Create a copy of PredefinedHabit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PredefinedHabitImplCopyWith<_$PredefinedHabitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
