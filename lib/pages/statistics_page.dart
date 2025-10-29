import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'habits_page.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(jsonHabitsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: habitsAsync.when(
        data: (habits) {
          final total = habits.length;
          final completed = habits.where((h) => h.completedToday).length;

          return Center(
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
