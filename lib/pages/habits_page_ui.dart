import 'package:flutter/material.dart';

import '../features/habits/domain/habit.dart';
import 'edit_habit_dialog.dart';
import '../l10n/app_localizations.dart';
import '../widgets/unified_habit_list.dart';

class ModernWeeklyCalendar extends StatefulWidget {
  final List<Habit> habits;
  final DateTime? initialDate;
  final Function(String habitId)? onComplete;
  final Function(String habitId)? onUncheck;
  final Function(String habitId)? onDelete;

  const ModernWeeklyCalendar({
    super.key,
    required this.habits,
    this.initialDate,
    this.onComplete,
    this.onUncheck,
    this.onDelete,
  });

  @override
  State<ModernWeeklyCalendar> createState() => _ModernWeeklyCalendarState();
}

class _ModernWeeklyCalendarState extends State<ModernWeeklyCalendar> {
  late PageController _pageController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    debugPrint(
      'ModernWeeklyCalendarState.initState: inicializando calendario semanal, recibidos ${widget.habits.length} hábitos',
    );
    _pageController = PageController(initialPage: 1000);
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    debugPrint('ModernWeeklyCalendarState.dispose: liberando recursos');
    _pageController.dispose();
    super.dispose();
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    debugPrint(
      'Selected date: ${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
    );
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    if (selected.isBefore(today)) {
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      });
    }
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _pageController.jumpToPage(1000);
    });
  }

  Color _getProgressColor(double progress) {
    if (progress == 0) return Colors.grey.shade50;
    if (progress <= 0.40) return const Color(0xFFFFEBEE);
    if (progress <= 0.70) return const Color(0xFFFFF9C4);
    if (progress < 1.0) return const Color(0xFFE8F5E9);
    return const Color(0xFFA5D6A7);
  }

  Widget _buildWeek(DateTime weekStart) {
    debugPrint(
      'ModernWeeklyCalendar._buildWeek: recibiendo ${widget.habits.length} hábitos',
    );
    final daysOfWeek = List.generate(
      7,
      (i) => weekStart.add(Duration(days: i)),
    );
    final today = DateTime.now();
    final selectedDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final day = daysOfWeek[index];
        final dayOnly = DateTime(day.year, day.month, day.day);
        final isToday =
            day.year == today.year &&
            day.month == today.month &&
            day.day == today.day;
        final isSelected = dayOnly == selectedDay;
        final completedHabits = widget.habits
            .where(
              (h) => h.completionHistory.any(
                (dt) =>
                    dt.year == day.year &&
                    dt.month == day.month &&
                    dt.day == day.day,
              ),
            )
            .length;
        final totalHabits = widget.habits.length;
        final progress = totalHabits > 0 ? completedHabits / totalHabits : 0.0;
        debugPrint(
          'ModernWeeklyCalendar._buildWeek: día ${day.day}/${day.month} - completados: $completedHabits/$totalHabits, progreso: $progress',
        );

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => _selectDate(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1976D2)
                      : isToday
                      ? const Color(0xFFE3F2FD)
                      : _getProgressColor(progress),
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: const Color(0xFF1565C0), width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isSelected
                                  ? const Color(0xFF1976D2)
                                  : isToday
                                  ? const Color(0xFF2196F3)
                                  : Colors.grey.shade400)
                              .withValues(alpha: 0.3),
                      blurRadius: isSelected ? 8 : 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      [
                        'Dom',
                        'Lun',
                        'Mar',
                        'Mié',
                        'Jue',
                        'Vie',
                        'Sáb',
                      ][day.weekday % 7],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : isToday
                            ? const Color(0xFF1976D2)
                            : Colors.grey.shade800,
                      ),
                    ),
                    if (totalHabits > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '$completedHabits/$totalHabits',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'ModernWeeklyCalendar.build: renderizando con ${widget.habits.length} hábitos',
    );

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final isToday = selected == today;
    final isInFuture = selected.isAfter(today);

    // Format selected date
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    final dateText = isToday
        ? 'Hoy'
        : '${_selectedDate.day} ${months[_selectedDate.month - 1]}';

    return Column(
      children: [
        const SizedBox(height: 12),
        // Navigation controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 32),
                onPressed: _goToPreviousDay,
                color: const Color(0xFF1976D2),
              ),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: isToday ? null : _goToToday,
                    child: Text(
                      dateText,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1976D2),
                        decoration: isToday ? null : TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 32),
                onPressed: isInFuture ? null : _goToNextDay,
                color: isInFuture
                    ? Colors.grey.shade300
                    : const Color(0xFF1976D2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            height: 100,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {});
              },
              itemBuilder: (context, page) {
                final weekOffset = page - 1000;
                final baseDate = DateTime.now().add(
                  Duration(days: weekOffset * 7),
                );
                final monday = baseDate.subtract(
                  Duration(days: baseDate.weekday - 1),
                );
                return _buildWeek(monday);
              },
            ),
          ),
        ),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            thickness: 4,
            radius: const Radius.circular(8),
            child: UnifiedHabitList(
              selectedDate: _selectedDate,
              onComplete: (habitId) async {
                debugPrint('HabitsPageUI: marcado hábito $habitId');
                if (widget.onComplete != null) {
                  await widget.onComplete!(habitId);
                }
              },
              onUncheck: (habitId) async {
                debugPrint('HabitsPageUI: desmarcado hábito $habitId');
                if (widget.onUncheck != null) {
                  await widget.onUncheck!(habitId);
                }
              },
              onDelete: (habitId) async {
                debugPrint('HabitsPageUI: eliminando hábito $habitId');
                if (widget.onDelete != null) {
                  await widget.onDelete!(habitId);
                }
              },
              onEdit: (habit) async {
                debugPrint('HabitsPageUI: editar hábito ${habit.name}');
                final l10n = AppLocalizations.of(context)!;
                await showDialog(
                  context: context,
                  builder: (ctx) => EditHabitDialog(l10n: l10n, habit: habit),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
