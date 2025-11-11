import 'package:flutter/material.dart';
import '../features/habits/domain/habit.dart';

class ModernWeeklyCalendar extends StatefulWidget {
  final List<Habit> habits;
  final DateTime? initialDate;

  const ModernWeeklyCalendar({
    super.key,
    required this.habits,
    this.initialDate,
  });

  @override
  State<ModernWeeklyCalendar> createState() => _ModernWeeklyCalendarState();
}

class _ModernWeeklyCalendarState extends State<ModernWeeklyCalendar> {
  late DateTime _focusedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.initialDate ?? DateTime.now();
  }

  void _nextWeek() {
    setState(() {
      _focusedDate = _focusedDate.add(const Duration(days: 7));
    });
  }

  void _prevWeek() {
    setState(() {
      _focusedDate = _focusedDate.subtract(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final monday =
        _focusedDate.subtract(Duration(days: _focusedDate.weekday - 1));
    final daysOfWeek = List.generate(7, (i) => monday.add(Duration(days: i)));
    final today = DateTime.now();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _prevWeek,
                ),
                Text(
                  'Semana del ${monday.day}/${monday.month}/${monday.year}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextWeek,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final day = daysOfWeek[index];
                  final isToday = day.year == today.year &&
                      day.month == today.month &&
                      day.day == today.day;
                  final completedHabits = widget.habits
                      .where((h) => h.completionHistory.any((dt) =>
                          dt.year == day.year &&
                          dt.month == day.month &&
                          dt.day == day.day))
                      .toList();
                  final totalHabits = widget.habits.length;
                  final progress = totalHabits > 0
                      ? completedHabits.length / totalHabits
                      : 0.0;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 60,
                    decoration: BoxDecoration(
                      color:
                          isToday ? Colors.blue.shade100 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isToday ? Colors.blue : Colors.transparent,
                          width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ['L', 'M', 'X', 'J', 'V', 'S', 'D'][index],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isToday ? Colors.blue : Colors.black),
                        ),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isToday ? Colors.blue : Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 18,
                              width: 36,
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey.shade300,
                                color: isToday ? Colors.blue : Colors.green,
                                minHeight: 6,
                              ),
                            ),
                            if (completedHabits.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: completedHabits
                                    .take(2)
                                    .map((habit) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2),
                                          child: Text(habit.emoji ?? '✔️',
                                              style: const TextStyle(
                                                  fontSize: 14)),
                                        ))
                                    .toList(),
                              ),
                          ],
                        ),
                        if (completedHabits.length == totalHabits &&
                            totalHabits > 0)
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 18),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
