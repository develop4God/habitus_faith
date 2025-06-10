import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/habit_service.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final habits = Provider.of<HabitService>(context).habits;
    final total = habits.length;
    final completed = habits.where((h) => h.completed).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hábitos completados:',
              style: TextStyle(fontSize: 22, color: Colors.blue[800]),
            ),
            const SizedBox(height: 12),
            Text(
              '$completed de $total',
              style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: total == 0 ? 0 : completed / total,
              minHeight: 12,
            ),
          ],
        ),
      ),
    );
  }
}
