import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/habits/domain/models/calendar_completion_log.dart';

class CalendarPersistenceService {
  static const String _calendarLogsKey = 'calendar_logs';
  final SharedPreferences prefs;

  CalendarPersistenceService(this.prefs);

  // Save logs for a specific date
  Future<void> saveLogsForDate(
      DateTime date, List<CalendarCompletionLog> logs) async {
    final allLogs = await _getAllLogs();
    final dateKey = _dateKey(date);
    allLogs[dateKey] = logs.map((log) => log.toJson()).toList();
    await prefs.setString(_calendarLogsKey, jsonEncode(allLogs));
  }

  // Retrieve logs for a specific date
  Future<List<CalendarCompletionLog>> getLogsForDate(DateTime date) async {
    final allLogs = await _getAllLogs();
    final dateKey = _dateKey(date);
    final logsJson = allLogs[dateKey] as List<dynamic>?;
    if (logsJson == null) return [];
    return logsJson
        .map((json) => CalendarCompletionLog.fromJson(json))
        .toList();
  }

  // Retrieve logs for a date range (inclusive)
  Future<Map<String, List<CalendarCompletionLog>>> getLogsForRange(
      DateTime start, DateTime end) async {
    final allLogs = await _getAllLogs();
    final result = <String, List<CalendarCompletionLog>>{};
    DateTime current = start;
    while (!current.isAfter(end)) {
      final dateKey = _dateKey(current);
      final logsJson = allLogs[dateKey] as List<dynamic>?;
      if (logsJson != null) {
        result[dateKey] = logsJson
            .map((json) => CalendarCompletionLog.fromJson(json))
            .toList();
      }
      current = current.add(const Duration(days: 1));
    }
    return result;
  }

  // Internal: get all logs as a Map
  Future<Map<String, dynamic>> _getAllLogs() async {
    final jsonString = prefs.getString(_calendarLogsKey);
    if (jsonString == null) return {};
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // Helper: get date key in yyyy-MM-dd format
  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
