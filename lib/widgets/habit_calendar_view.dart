import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/data/storage/storage_providers.dart';
import '../pages/habits_page.dart';
import '../l10n/app_localizations.dart';

/// Calendar widget to track habit completion
class HabitCalendarView extends ConsumerStatefulWidget {
  const HabitCalendarView({super.key});

  @override
  ConsumerState<HabitCalendarView> createState() => _HabitCalendarViewState();
}

class _HabitCalendarViewState extends ConsumerState<HabitCalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Habit? _selectedHabit;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final habitsAsync = ref.watch(jsonHabitsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.habitTracking),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Text(
                l10n.noHabits,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            );
          }

          // Get completed dates for selected habit
          final completedDates = _selectedHabit != null
              ? _selectedHabit!.completionHistory
                  .map((dt) => DateTime(dt.year, dt.month, dt.day))
                  .toSet()
              : <DateTime>{};

          return Column(
            children: [
              // Habit selector
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    final isSelected = _selectedHabit?.id == habit.id;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedHabit = habit;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  isSelected ? Colors.blue : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                habit.emoji ?? '📝',
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                habit.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Calendar
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: TableCalendar(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) {
                              return isSameDay(_selectedDay, day);
                            },
                            calendarFormat: CalendarFormat.month,
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Colors.blue.shade300,
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              markerDecoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            onPageChanged: (focusedDay) {
                              _focusedDay = focusedDay;
                            },
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                final normalizedDay =
                                    DateTime(day.year, day.month, day.day);
                                final isCompleted =
                                    completedDates.contains(normalizedDay);

                                return Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? Colors.green.shade100
                                        : null,
                                    shape: BoxShape.circle,
                                    border: isCompleted
                                        ? Border.all(
                                            color: Colors.green,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${day.day}',
                                      style: TextStyle(
                                        color: isCompleted
                                            ? Colors.green.shade900
                                            : Colors.black,
                                        fontWeight: isCompleted
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Statistics
                      if (_selectedHabit != null)
                        _buildStatistics(_selectedHabit!, l10n),
                    ],
                  ),
                ),
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

  Widget _buildStatistics(Habit habit, AppLocalizations l10n) {
    final thisMonth = DateTime.now();
    final completedThisMonth = habit.completionHistory
        .where((date) =>
            date.year == thisMonth.year && date.month == thisMonth.month)
        .length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${habit.emoji ?? '📝'} ${habit.name}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  l10n.streak,
                  '${habit.currentStreak} ${l10n.days}',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
                _buildStatItem(
                  l10n.best,
                  '${habit.longestStreak} ${l10n.days}',
                  Icons.calendar_today,
                  Colors.blue,
                ),
                _buildStatItem(
                  'This Month',
                  '$completedThisMonth ${l10n.days}',
                  Icons.calendar_today,
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: completedThisMonth / DateTime.now().day,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              'Completion rate this month: ${(completedThisMonth / DateTime.now().day * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
