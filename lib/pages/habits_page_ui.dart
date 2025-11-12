import 'package:flutter/material.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/presentation/widgets/habit_card/compact_habit_card.dart';

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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    debugPrint('ModernWeeklyCalendarState.initState: inicializando calendario semanal, recibidos ${widget.habits.length} hábitos');
    _pageController = PageController(initialPage: 1000);
  }

  @override
  void dispose() {
    debugPrint('ModernWeeklyCalendarState.dispose: liberando recursos');
    _pageController.dispose();
    super.dispose();
  }

  Color _getProgressColor(double progress) {
    if (progress == 0) return Colors.grey.shade50;
    if (progress <= 0.40) return const Color(0xFFFFEBEE);
    if (progress <= 0.70) return const Color(0xFFFFF9C4);
    if (progress < 1.0) return const Color(0xFFE8F5E9);
    return const Color(0xFFA5D6A7);
  }

  Widget _buildWeek(DateTime weekStart) {
    debugPrint('ModernWeeklyCalendar._buildWeek: recibiendo ${widget.habits.length} hábitos');
    final daysOfWeek = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    final today = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final day = daysOfWeek[index];
        final isToday = day.year == today.year &&
            day.month == today.month &&
            day.day == today.day;
        final completedHabits = widget.habits.where((h) =>
            h.completionHistory.any((dt) =>
            dt.year == day.year &&
                dt.month == day.month &&
                dt.day == day.day
            )
        ).length;
        final totalHabits = widget.habits.length;
        final progress = totalHabits > 0 ? completedHabits / totalHabits : 0.0;
        debugPrint('ModernWeeklyCalendar._buildWeek: día ${day.day}/${day.month} - completados: $completedHabits/$totalHabits, progreso: $progress');

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 48,
              height: 64, // Ajuste de alto para evitar overflow
              decoration: BoxDecoration(
                color: isToday ? const Color(0xFFE3F2FD) : _getProgressColor(progress),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isToday ? const Color(0xFF2196F3) : Colors.grey.shade400).withValues(alpha:0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center, // Centrado vertical
                children: [
                  Text(
                    ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'][day.weekday % 7],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2), // Menos espacio
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isToday ? const Color(0xFF1976D2) : Colors.grey.shade800,
                    ),
                  ),
                  if (totalHabits > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$completedHabits/$totalHabits',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ModernWeeklyCalendar.build: renderizando con ${widget.habits.length} hábitos');
    return Column(
      children: [
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Hoy',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
            textAlign: TextAlign.center,
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
                color: Colors.black.withValues(alpha:0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            height: 100, // Ajuste de alto para el calendario semanal
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {});
              },
              itemBuilder: (context, page) {
                final weekOffset = page - 1000;
                final baseDate = DateTime.now().add(Duration(days: weekOffset * 7));
                final monday = baseDate.subtract(Duration(days: baseDate.weekday - 1));
                return _buildWeek(monday);
              },
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.habits.length,
            itemBuilder: (context, index) {
              final habit = widget.habits[index];
              debugPrint('CompactHabitCard: renderizando hábito \x1B[32m${habit.name}\x1B[0m');
              return CompactHabitCard(
                habit: habit,
                onDelete: () {
                  debugPrint('CompactHabitCard: eliminar hábito ${habit.name}');
                },
                onEdit: () {
                  debugPrint('CompactHabitCard: editar hábito ${habit.name}');
                },
                onComplete: (id) {
                  debugPrint('CompactHabitCard: marcado hábito $id');
                  // Aquí debe ir la lógica de marcado igual que en la vista compacta
                },
                onUncheck: (id) {
                  debugPrint('CompactHabitCard: desmarcado hábito $id');
                  // Aquí debe ir la lógica de desmarcado igual que en la vista compacta
                },
              );
            },
          ),
        ),
      ],
    );
  }
}