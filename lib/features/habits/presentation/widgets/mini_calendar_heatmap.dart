import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MiniCalendarHeatmap extends StatelessWidget {
  final List<DateTime> completionDates;

  const MiniCalendarHeatmap({
    super.key,
    required this.completionDates,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get last 7 days starting from Monday
    final lastMonday =
        today.subtract(Duration(days: (today.weekday - DateTime.monday) % 7));
    final last7Days = List.generate(7, (index) {
      return lastMonday.add(Duration(days: index));
    });

    // Create set of completed dates for quick lookup
    final completedDates = completionDates.map((date) {
      return DateTime(date.year, date.month, date.day);
    }).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: last7Days.map((date) {
            final isCompleted = completedDates.contains(date);
            final isToday = date == today;

            // Get localized day abbreviation
            final dayAbbr = DateFormat.E(Localizations.localeOf(context).toString())
                .format(date)
                .substring(0, 1)
                .toUpperCase();

            return Expanded(
              child: Container(
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  gradient: isCompleted
                      ? const LinearGradient(
                          colors: [Color(0xff10b981), Color(0xff059669)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  color: isCompleted ? null : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday
                      ? Border.all(
                          color: const Color(0xff6366f1),
                          width: 2.5,
                        )
                      : null,
                  boxShadow: isCompleted
                      ? [
                          BoxShadow(
                            color: const Color(0xff10b981).withValues(alpha:0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayAbbr,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (isCompleted)
                        const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
