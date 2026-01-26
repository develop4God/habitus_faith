import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/storage/calendar_persistence_service.dart';
import '../domain/models/calendar_completion_log.dart';
import '../domain/habit.dart';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Provider for CalendarPersistenceService
final calendarPersistenceServiceProvider = Provider<CalendarPersistenceService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) {
    throw Exception('SharedPreferences not initialized');
  }
  return CalendarPersistenceService(prefs);
});

/// Provider for calendar state management
class CalendarState {
  final DateTime selectedDate;
  final List<CalendarCompletionLog> logsForSelectedDate;
  final Map<String, List<CalendarCompletionLog>> logsForRange;
  final bool isLoading;

  CalendarState({
    required this.selectedDate,
    required this.logsForSelectedDate,
    required this.logsForRange,
    this.isLoading = false,
  });

  CalendarState copyWith({
    DateTime? selectedDate,
    List<CalendarCompletionLog>? logsForSelectedDate,
    Map<String, List<CalendarCompletionLog>>? logsForRange,
    bool? isLoading,
  }) {
    return CalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      logsForSelectedDate: logsForSelectedDate ?? this.logsForSelectedDate,
      logsForRange: logsForRange ?? this.logsForRange,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Calendar notifier for managing calendar state
class CalendarNotifier extends StateNotifier<CalendarState> {
  final CalendarPersistenceService _persistenceService;

  CalendarNotifier(this._persistenceService)
      : super(CalendarState(
          selectedDate: DateTime.now(),
          logsForSelectedDate: [],
          logsForRange: {},
        )) {
    loadLogsForDate(DateTime.now());
  }

  /// Load logs for a specific date
  Future<void> loadLogsForDate(DateTime date) async {
    state = state.copyWith(isLoading: true);

    final logs = await _persistenceService.getLogsForDate(date);

    state = state.copyWith(
      selectedDate: date,
      logsForSelectedDate: logs,
      isLoading: false,
    );
  }

  /// Load logs for a date range (e.g., a month)
  Future<void> loadLogsForRange(DateTime start, DateTime end) async {
    state = state.copyWith(isLoading: true);

    final logsMap = await _persistenceService.getLogsForRange(start, end);

    state = state.copyWith(
      logsForRange: logsMap,
      isLoading: false,
    );
  }

  /// Sync habit completions from habits to calendar logs
  Future<void> syncFromHabits(List<Habit> habits, DateTime date) async {
    final logs = habits.map((habit) {
      return CalendarCompletionLog(
        habitId: habit.id,
        habitName: habit.name,
        date: date,
        completed: habit.completedToday,
        note: null, // Notes are stored separately in completion records
      );
    }).toList();

    await _persistenceService.saveLogsForDate(date, logs);
    await loadLogsForDate(date);
  }

  /// Get completion status for a habit on a specific date
  bool isHabitCompletedOn(String habitId, DateTime date) {
    final dateKey = _getDateKey(date);
    final logsForDate = state.logsForRange[dateKey];

    if (logsForDate == null) return false;

    final log = logsForDate.firstWhere(
      (log) => log.habitId == habitId,
      orElse: () => CalendarCompletionLog(
        habitId: habitId,
        habitName: '',
        date: date,
        completed: false,
      ),
    );

    return log.completed;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Provider for CalendarNotifier
final calendarNotifierProvider =
    StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  final persistenceService = ref.watch(calendarPersistenceServiceProvider);
  return CalendarNotifier(persistenceService);
});
