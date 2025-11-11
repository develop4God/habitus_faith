import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/habit.dart';
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
  Habit? _selectedHabit;

  @override
  void initState() {
    super.initState();
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
                              Flexible(
                                child: Text(
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
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: () {
                                      setState(() {
                                        _focusedDay = _focusedDay
                                            .subtract(const Duration(days: 7));
                                      });
                                    },
                                  ),
                                  Text(
                                    'Semana del ${_focusedDay.subtract(Duration(days: _focusedDay.weekday - 1)).day}/${_focusedDay.month}/${_focusedDay.year}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: () {
                                      setState(() {
                                        _focusedDay = _focusedDay
                                            .add(const Duration(days: 7));
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(7, (index) {
                                  final monday = _focusedDay.subtract(
                                      Duration(days: _focusedDay.weekday - 1));
                                  final day = monday.add(Duration(days: index));
                                  final isToday =
                                      DateTime.now().year == day.year &&
                                          DateTime.now().month == day.month &&
                                          DateTime.now().day == day.day;
                                  final completedHabits = habits
                                      .where((h) => h.completionHistory.any(
                                          (dt) =>
                                              dt.year == day.year &&
                                              dt.month == day.month &&
                                              dt.day == day.day))
                                      .toList();
                                  return Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      decoration: BoxDecoration(
                                        color: isToday
                                            ? Colors.blue.shade100
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: isToday
                                                ? Colors.blue
                                                : Colors.transparent,
                                            width: 2),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            [
                                              'L',
                                              'M',
                                              'X',
                                              'J',
                                              'V',
                                              'S',
                                              'D'
                                            ][index],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isToday
                                                    ? Colors.blue
                                                    : Colors.black),
                                          ),
                                          Text(
                                            '${day.day}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isToday
                                                    ? Colors.blue
                                                    : Colors.black),
                                          ),
                                          ...completedHabits.map((habit) =>
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(habit.emoji ?? '📝',
                                                        style: const TextStyle(
                                                            fontSize: 14)),
                                                    const SizedBox(width: 2),
                                                    Flexible(
                                                      child: Text(
                                                        habit.name,
                                                        style: const TextStyle(
                                                            fontSize: 10),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Column(
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
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.green.shade400),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
