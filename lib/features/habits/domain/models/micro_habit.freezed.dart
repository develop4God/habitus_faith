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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationConfig _$NotificationConfigFromJson(Map<String, dynamic> json) {
  return _NotificationConfig.fromJson(json);
}

/// @nodoc
mixin _$NotificationConfig {
  String get time =>
      throw _privateConstructorUsedError; // "HH:mm" format (24-hour)
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;

  /// Serializes this NotificationConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationConfigCopyWith<NotificationConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationConfigCopyWith<$Res> {
  factory $NotificationConfigCopyWith(
          NotificationConfig value, $Res Function(NotificationConfig) then) =
      _$NotificationConfigCopyWithImpl<$Res, NotificationConfig>;
  @useResult
  $Res call({String time, String title, String body});
}

/// @nodoc
class _$NotificationConfigCopyWithImpl<$Res, $Val extends NotificationConfig>
    implements $NotificationConfigCopyWith<$Res> {
  _$NotificationConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = null,
    Object? title = null,
    Object? body = null,
  }) {
    return _then(_value.copyWith(
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationConfigImplCopyWith<$Res>
    implements $NotificationConfigCopyWith<$Res> {
  factory _$$NotificationConfigImplCopyWith(_$NotificationConfigImpl value,
          $Res Function(_$NotificationConfigImpl) then) =
      __$$NotificationConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String time, String title, String body});
}

/// @nodoc
class __$$NotificationConfigImplCopyWithImpl<$Res>
    extends _$NotificationConfigCopyWithImpl<$Res, _$NotificationConfigImpl>
    implements _$$NotificationConfigImplCopyWith<$Res> {
  __$$NotificationConfigImplCopyWithImpl(_$NotificationConfigImpl _value,
      $Res Function(_$NotificationConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = null,
    Object? title = null,
    Object? body = null,
  }) {
    return _then(_$NotificationConfigImpl(
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationConfigImpl implements _NotificationConfig {
  const _$NotificationConfigImpl(
      {required this.time, required this.title, required this.body});

  factory _$NotificationConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationConfigImplFromJson(json);

  @override
  final String time;
// "HH:mm" format (24-hour)
  @override
  final String title;
  @override
  final String body;

  @override
  String toString() {
    return 'NotificationConfig(time: $time, title: $title, body: $body)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationConfigImpl &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, time, title, body);

  /// Create a copy of NotificationConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationConfigImplCopyWith<_$NotificationConfigImpl> get copyWith =>
      __$$NotificationConfigImplCopyWithImpl<_$NotificationConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationConfigImplToJson(
      this,
    );
  }
}

abstract class _NotificationConfig implements NotificationConfig {
  const factory _NotificationConfig(
      {required final String time,
      required final String title,
      required final String body}) = _$NotificationConfigImpl;

  factory _NotificationConfig.fromJson(Map<String, dynamic> json) =
      _$NotificationConfigImpl.fromJson;

  @override
  String get time; // "HH:mm" format (24-hour)
  @override
  String get title;
  @override
  String get body;

  /// Create a copy of NotificationConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationConfigImplCopyWith<_$NotificationConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
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
  String? get scheduledTime =>
      throw _privateConstructorUsedError; // "HH:mm" format (e.g., "07:00")
  String? get trigger =>
      throw _privateConstructorUsedError; // "After breakfast", "At 7am"
  List<NotificationConfig>? get notifications =>
      throw _privateConstructorUsedError;

  /// Create a copy of MicroHabit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MicroHabitCopyWith<MicroHabit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MicroHabitCopyWith<$Res> {
  factory $MicroHabitCopyWith(
          MicroHabit value, $Res Function(MicroHabit) then) =
      _$MicroHabitCopyWithImpl<$Res, MicroHabit>;
  @useResult
  $Res call(
      {String id,
      String action,
      String verse,
      String? verseText,
      String purpose,
      int estimatedMinutes,
      DateTime? generatedAt,
      String? scheduledTime,
      String? trigger,
      List<NotificationConfig>? notifications});
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
    Object? scheduledTime = freezed,
    Object? trigger = freezed,
    Object? notifications = freezed,
  }) {
    return _then(_value.copyWith(
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
      scheduledTime: freezed == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as String?,
      trigger: freezed == trigger
          ? _value.trigger
          : trigger // ignore: cast_nullable_to_non_nullable
              as String?,
      notifications: freezed == notifications
          ? _value.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as List<NotificationConfig>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MicroHabitImplCopyWith<$Res>
    implements $MicroHabitCopyWith<$Res> {
  factory _$$MicroHabitImplCopyWith(
          _$MicroHabitImpl value, $Res Function(_$MicroHabitImpl) then) =
      __$$MicroHabitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String action,
      String verse,
      String? verseText,
      String purpose,
      int estimatedMinutes,
      DateTime? generatedAt,
      String? scheduledTime,
      String? trigger,
      List<NotificationConfig>? notifications});
}

/// @nodoc
class __$$MicroHabitImplCopyWithImpl<$Res>
    extends _$MicroHabitCopyWithImpl<$Res, _$MicroHabitImpl>
    implements _$$MicroHabitImplCopyWith<$Res> {
  __$$MicroHabitImplCopyWithImpl(
      _$MicroHabitImpl _value, $Res Function(_$MicroHabitImpl) _then)
      : super(_value, _then);

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
    Object? scheduledTime = freezed,
    Object? trigger = freezed,
    Object? notifications = freezed,
  }) {
    return _then(_$MicroHabitImpl(
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
      scheduledTime: freezed == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as String?,
      trigger: freezed == trigger
          ? _value.trigger
          : trigger // ignore: cast_nullable_to_non_nullable
              as String?,
      notifications: freezed == notifications
          ? _value._notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as List<NotificationConfig>?,
    ));
  }
}

/// @nodoc

class _$MicroHabitImpl implements _MicroHabit {
  const _$MicroHabitImpl(
      {required this.id,
      required this.action,
      required this.verse,
      this.verseText,
      required this.purpose,
      this.estimatedMinutes = 5,
      this.generatedAt,
      this.scheduledTime,
      this.trigger,
      final List<NotificationConfig>? notifications})
      : _notifications = notifications;

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
  final String? scheduledTime;
// "HH:mm" format (e.g., "07:00")
  @override
  final String? trigger;
// "After breakfast", "At 7am"
  final List<NotificationConfig>? _notifications;
// "After breakfast", "At 7am"
  @override
  List<NotificationConfig>? get notifications {
    final value = _notifications;
    if (value == null) return null;
    if (_notifications is EqualUnmodifiableListView) return _notifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'MicroHabit(id: $id, action: $action, verse: $verse, verseText: $verseText, purpose: $purpose, estimatedMinutes: $estimatedMinutes, generatedAt: $generatedAt, scheduledTime: $scheduledTime, trigger: $trigger, notifications: $notifications)';
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
                other.generatedAt == generatedAt) &&
            (identical(other.scheduledTime, scheduledTime) ||
                other.scheduledTime == scheduledTime) &&
            (identical(other.trigger, trigger) || other.trigger == trigger) &&
            const DeepCollectionEquality()
                .equals(other._notifications, _notifications));
  }

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
      scheduledTime,
      trigger,
      const DeepCollectionEquality().hash(_notifications));

  /// Create a copy of MicroHabit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MicroHabitImplCopyWith<_$MicroHabitImpl> get copyWith =>
      __$$MicroHabitImplCopyWithImpl<_$MicroHabitImpl>(this, _$identity);
}

abstract class _MicroHabit implements MicroHabit {
  const factory _MicroHabit(
      {required final String id,
      required final String action,
      required final String verse,
      final String? verseText,
      required final String purpose,
      final int estimatedMinutes,
      final DateTime? generatedAt,
      final String? scheduledTime,
      final String? trigger,
      final List<NotificationConfig>? notifications}) = _$MicroHabitImpl;

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
  @override
  String? get scheduledTime; // "HH:mm" format (e.g., "07:00")
  @override
  String? get trigger; // "After breakfast", "At 7am"
  @override
  List<NotificationConfig>? get notifications;

  /// Create a copy of MicroHabit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MicroHabitImplCopyWith<_$MicroHabitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
