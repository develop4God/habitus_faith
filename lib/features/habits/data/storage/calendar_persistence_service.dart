import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/calendar_completion_log.dart';

/// Service to persist calendar completion logs to SharedPreferences
class CalendarPersistenceService {
  static const String _calendarLogsKey = 'calendar_completion_logs';

  final SharedPreferences _prefs;

  CalendarPersistenceService(this._prefs);

  /// Save calendar logs for a specific date
  Future<void> saveLogsForDate(
    DateTime date,
    List<CalendarCompletionLog> logs,
  ) async {
    final allLogs = await getAllLogs();
    final dateKey = _getDateKey(date);

    // Update logs for this date
    allLogs[dateKey] = logs.map((log) => log.toJson()).toList();

    await _prefs.setString(_calendarLogsKey, jsonEncode(allLogs));
  }

  /// Get calendar logs for a specific date
  Future<List<CalendarCompletionLog>> getLogsForDate(DateTime date) async {
    final allLogs = await getAllLogs();
    final dateKey = _getDateKey(date);

    if (!allLogs.containsKey(dateKey)) {
      return [];
    }

    final logsJson = allLogs[dateKey] as List<dynamic>;
    return logsJson
        .map((json) => CalendarCompletionLog.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get all calendar logs
  Future<Map<String, dynamic>> getAllLogs() async {
    final logsString = _prefs.getString(_calendarLogsKey);

    if (logsString == null || logsString.isEmpty) {
      return {};
    }

    return jsonDecode(logsString) as Map<String, dynamic>;
  }

  /// Get logs for a date range
  Future<Map<String, List<CalendarCompletionLog>>> getLogsForRange(
    DateTime start,
    DateTime end,
  ) async {
    final allLogs = await getAllLogs();
    final result = <String, List<CalendarCompletionLog>>{};

    DateTime currentDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (!currentDate.isAfter(endDate)) {
      final dateKey = _getDateKey(currentDate);

      if (allLogs.containsKey(dateKey)) {
        final logsJson = allLogs[dateKey] as List<dynamic>;
        result[dateKey] = logsJson
            .map((json) => CalendarCompletionLog.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return result;
  }

  /// Clear all calendar logs (for testing)
  Future<void> clearAllLogs() async {
    await _prefs.remove(_calendarLogsKey);
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
