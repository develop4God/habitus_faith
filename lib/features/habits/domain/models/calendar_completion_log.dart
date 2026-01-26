/// Model for storing habit completion logs for calendar view
class CalendarCompletionLog {
  final String habitId;
  final String habitName;
  final DateTime date;
  final bool completed;
  final String? note;

  CalendarCompletionLog({
    required this.habitId,
    required this.habitName,
    required this.date,
    required this.completed,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'habitId': habitId,
      'habitName': habitName,
      'date': date.toIso8601String(),
      'completed': completed,
      'note': note,
    };
  }

  factory CalendarCompletionLog.fromJson(Map<String, dynamic> json) {
    return CalendarCompletionLog(
      habitId: json['habitId'] as String,
      habitName: json['habitName'] as String,
      date: DateTime.parse(json['date'] as String),
      completed: json['completed'] as bool,
      note: json['note'] as String?,
    );
  }

  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
