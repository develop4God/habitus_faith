// Domain models for habit notifications and recurrence

enum NotificationTiming {
  none, // Sin aviso
  atEventTime, // En el momento del evento
  tenMinutesBefore, // 10 minutos antes
  thirtyMinutesBefore, // 30 minutos antes
  oneHourBefore, // 1 hora antes
  custom; // Personalizado

  String get displayName {
    switch (this) {
      case NotificationTiming.none:
        return 'Sin aviso';
      case NotificationTiming.atEventTime:
        return 'En el momento del evento';
      case NotificationTiming.tenMinutesBefore:
        return '10 minutos antes';
      case NotificationTiming.thirtyMinutesBefore:
        return '30 minutos antes';
      case NotificationTiming.oneHourBefore:
        return '1 hora antes';
      case NotificationTiming.custom:
        return 'Personalizado';
    }
  }

  int? get minutesBefore {
    switch (this) {
      case NotificationTiming.none:
        return null;
      case NotificationTiming.atEventTime:
        return 0;
      case NotificationTiming.tenMinutesBefore:
        return 10;
      case NotificationTiming.thirtyMinutesBefore:
        return 30;
      case NotificationTiming.oneHourBefore:
        return 60;
      case NotificationTiming.custom:
        return null;
    }
  }
}

enum RecurrenceFrequency {
  daily, // Diario
  weekly, // Semanal
  monthly; // Mensual

  String get displayName {
    switch (this) {
      case RecurrenceFrequency.daily:
        return 'Diario';
      case RecurrenceFrequency.weekly:
        return 'Semanal';
      case RecurrenceFrequency.monthly:
        return 'Mensual';
    }
  }
}

class HabitNotificationSettings {
  final NotificationTiming timing;
  final int? customMinutesBefore;
  final String? eventTime; // HH:mm format

  const HabitNotificationSettings({
    this.timing = NotificationTiming.none,
    this.customMinutesBefore,
    this.eventTime,
  });

  HabitNotificationSettings copyWith({
    NotificationTiming? timing,
    int? customMinutesBefore,
    String? eventTime,
  }) {
    return HabitNotificationSettings(
      timing: timing ?? this.timing,
      customMinutesBefore: customMinutesBefore ?? this.customMinutesBefore,
      eventTime: eventTime ?? this.eventTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timing': timing.name,
      'customMinutesBefore': customMinutesBefore,
      'eventTime': eventTime,
    };
  }

  factory HabitNotificationSettings.fromJson(Map<String, dynamic> json) {
    return HabitNotificationSettings(
      timing: NotificationTiming.values.firstWhere(
        (e) => e.name == json['timing'],
        orElse: () => NotificationTiming.none,
      ),
      customMinutesBefore: json['customMinutesBefore'] as int?,
      eventTime: json['eventTime'] as String?,
    );
  }
}

class HabitRecurrence {
  final bool enabled;
  final RecurrenceFrequency frequency;
  final int interval; // Cada X días/semanas/meses
  final DateTime? endDate;

  const HabitRecurrence({
    this.enabled = false,
    this.frequency = RecurrenceFrequency.daily,
    this.interval = 1,
    this.endDate,
  });

  HabitRecurrence copyWith({
    bool? enabled,
    RecurrenceFrequency? frequency,
    int? interval,
    DateTime? endDate,
  }) {
    return HabitRecurrence(
      enabled: enabled ?? this.enabled,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      endDate: endDate ?? this.endDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'frequency': frequency.name,
      'interval': interval,
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory HabitRecurrence.fromJson(Map<String, dynamic> json) {
    return HabitRecurrence(
      enabled: json['enabled'] as bool? ?? false,
      frequency: RecurrenceFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => RecurrenceFrequency.daily,
      ),
      interval: json['interval'] as int? ?? 1,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
    );
  }
}

class Subtask {
  final String id;
  final String title;
  final bool completed;

  const Subtask({
    required this.id,
    required this.title,
    this.completed = false,
  });

  Subtask copyWith({
    String? id,
    String? title,
    bool? completed,
  }) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
    };
  }

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'] as String,
      title: json['title'] as String,
      completed: json['completed'] as bool? ?? false,
    );
  }
}
