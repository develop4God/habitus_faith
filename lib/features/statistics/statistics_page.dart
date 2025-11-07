import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import 'statistics_model.dart';
import 'statistics_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Future<StatisticsModel> _statsFuture;
  final StatisticsService _service = StatisticsService();

  @override
  void initState() {
    super.initState();
    _statsFuture = _service.loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _statsFuture = _service.loadStatistics();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<StatisticsModel>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No hay datos de estadísticas.'));
          }
          final stats = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset('assets/lottie/Congratulation _ Success batch.json', width: 120, repeat: false),
                  const SizedBox(height: 16),
                  Text(
                    '¡Bienvenido a tus estadísticas!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aquí puedes ver tu progreso y logros de hábitos.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatTile(
                                label: 'Hábitos totales',
                                value: stats.totalHabits.toString(),
                                icon: Icons.list_alt,
                                color: Colors.blue,
                              ),
                              _StatTile(
                                label: 'Completados',
                                value: stats.completedHabits.toString(),
                                icon: Icons.check_circle,
                                color: Colors.green,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatTile(
                                label: 'Racha actual',
                                value: stats.currentStreak.toString(),
                                icon: Icons.local_fire_department,
                                color: Colors.orange,
                              ),
                              _StatTile(
                                label: 'Racha máxima',
                                value: stats.longestStreak.toString(),
                                icon: Icons.emoji_events,
                                color: Colors.amber,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Progreso de hábitos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 1.7,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: stats.totalHabits > 0 ? stats.totalHabits.toDouble() : 1,
                        barTouchData: const BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 0:
                                    return const Text('Completados');
                                  case 1:
                                    return const Text('Totales');
                                  default:
                                    return const Text('');
                                }
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: stats.completedHabits.toDouble(), color: Colors.green, width: 32)]),
                          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: stats.totalHabits.toDouble(), color: Colors.blue, width: 32)]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AnimatedOpacity(
                    opacity: stats.completedHabits == stats.totalHabits && stats.totalHabits > 0 ? 1 : 0.3,
                    duration: const Duration(milliseconds: 800),
                    child: Lottie.asset('assets/lottie/tick_animation_success.json', width: 100, repeat: false),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Última finalización: ${stats.lastCompletion.day}/${stats.lastCompletion.month}/${stats.lastCompletion.year}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withValues(alpha:0.15),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

