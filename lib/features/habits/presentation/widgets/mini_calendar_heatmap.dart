import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MiniCalendarHeatmap extends StatefulWidget {
  final List<DateTime> completionDates;

  const MiniCalendarHeatmap({
    super.key,
    required this.completionDates,
  });

  @override
  State<MiniCalendarHeatmap> createState() => _MiniCalendarHeatmapState();
}

class _MiniCalendarHeatmapState extends State<MiniCalendarHeatmap> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _loadVisibilityPreference();
  }

  Future<void> _loadVisibilityPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isVisible = prefs.getBool('calendar_visible') ?? true;
    });
  }

  Future<void> _toggleVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isVisible = !_isVisible;
    });
    await prefs.setBool('calendar_visible', _isVisible);
  }

  @override
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
    final completedDates = widget.completionDates.map((date) {
      return DateTime(date.year, date.month, date.day);
    }).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isVisible) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...last7Days.map((date) {
                final isCompleted = completedDates.contains(date);
                final isToday = date == today;

                return Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xff10b981)
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                    border: isToday
                        ? Border.all(
                      color: const Color(0xff6366f1),
                      width: 2,
                    )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                        isCompleted ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              }),
              // Eye icon as a circle at the end
              GestureDetector(
                onTap: _toggleVisibility,
                child: Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    Icons.visibility,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _toggleVisibility,
                child: SizedBox(
                  width: 32,
                  height: 32,

                  child: Icon(
                    Icons.visibility_off,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
