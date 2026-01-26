import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/presentation/habits_providers.dart';
import '../features/habits/presentation/calendar_providers.dart';
import '../features/habits/presentation/constants/habit_colors.dart';
import '../l10n/app_localizations.dart';

/// Enhanced calendar widget with navigation and persistence
class EnhancedHabitCalendarView extends ConsumerStatefulWidget {
  const EnhancedHabitCalendarView({super.key});

  @override
  ConsumerState<EnhancedHabitCalendarView> createState() =>
      _EnhancedHabitCalendarViewState();
}

class _EnhancedHabitCalendarViewState
    extends ConsumerState<EnhancedHabitCalendarView> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();

    // Load initial calendar data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCalendarData();
    });
  }

  void _loadCalendarData() {
    // Load logs for the current month
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    ref.read(calendarNotifierProvider.notifier).loadLogsForRange(
          firstDay,
          lastDay,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final habitsAsync = ref.watch(habitsStreamProvider);
    final calendarState = ref.watch(calendarNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.habitTracking),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noHabits,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create habits to track your progress',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Calendar widget
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 1,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });

                    // Load logs for selected day
                    ref
                        .read(calendarNotifierProvider.notifier)
                        .loadLogsForDate(selectedDay);
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                    _loadCalendarData();
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  // Event loader to show markers for completed days
                  eventLoader: (day) {
                    final dateKey =
                        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                    final logsForDay = calendarState.logsForRange[dateKey];

                    if (logsForDay != null && logsForDay.isNotEmpty) {
                      final completedCount =
                          logsForDay.where((log) => log.completed).length;
                      if (completedCount > 0) {
                        return [
                          completedCount
                        ]; // Show marker if any habit completed
                      }
                    }
                    return [];
                  },
                ),
              ),

              // Selected day's habits
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 20, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      _formatSelectedDate(l10n),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Habits list for selected day
              Expanded(
                child: _buildHabitsList(habits, colorScheme),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildHabitsList(List<Habit> habits, ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        final habitColor = HabitColors.getHabitColor(habit);

        // Check if habit was completed on selected day
        final isCompleted = _isHabitCompletedOnDate(habit, _selectedDay);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isCompleted
                  ? habitColor.withValues(alpha: 0.5)
                  : Colors.grey.shade300,
              width: isCompleted ? 2 : 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: habitColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  habit.emoji ?? '📝',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            title: Text(
              habit.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : null,
              ),
            ),
            subtitle: isCompleted
                ? Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: habitColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          color: habitColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Text(
                    HabitColors.getCategoryDisplayName(
                      habit.category,
                      AppLocalizations.of(context)!,
                    ),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
            trailing:
                isCompleted ? Icon(Icons.verified, color: habitColor) : null,
          ),
        );
      },
    );
  }

  bool _isHabitCompletedOnDate(Habit habit, DateTime date) {
    // Check if the selected day is today
    final today = DateTime.now();
    final isToday = isSameDay(date, today);

    if (isToday) {
      return habit.completedToday;
    }

    // For past/future dates, check completion history
    return habit.completionHistory.any((completedDate) {
      return isSameDay(completedDate, date);
    });
  }

  String _formatSelectedDate(AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );

    if (isSameDay(selected, today)) {
      return l10n.todayLabel;
    } else if (isSameDay(selected, today.add(const Duration(days: 1)))) {
      return l10n.tomorrowLabel;
    } else {
      // Format: Day, Month DD, YYYY
      return '${_getDayName(_selectedDay.weekday)}, ${_getMonthName(_selectedDay.month)} ${_selectedDay.day}, ${_selectedDay.year}';
    }
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
