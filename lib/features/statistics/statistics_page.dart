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
          final double successPercent = stats.totalHabits > 0
              ? (stats.completedHabits / stats.totalHabits) * 100
              : 0;
          final String motivacion = successPercent >= 80
              ? '¡Excelente constancia! Sigue así.'
              : successPercent >= 50
                  ? '¡Vas bien! Mantén el ritmo.'
                  : '¡Cada día cuenta! Puedes mejorar.';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie/Congratulation _ Success batch.json',
                    width: 120,
                    repeat: false,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    motivacion,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigoAccent,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatTile(
                            label: 'Hábitos activos',
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
                          _StatTile(
                            label: 'Racha máxima',
                            value: stats.longestStreak.toString(),
                            icon: Icons.emoji_events,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Porcentaje de éxito',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: successPercent / 100,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.indigo,
                        ),
                      ),
                      Text(
                        '${successPercent.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Última finalización: ${stats.lastCompletion.day}/${stats.lastCompletion.month}/${stats.lastCompletion.year}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Distribución de hábitos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  AspectRatio(
                    aspectRatio: 1.2,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: stats.completedHabits > 0
                                ? stats.completedHabits.toDouble()
                                : 1,
                            color: Colors.green,
                            title: 'Completados',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: (stats.totalHabits - stats.completedHabits) >
                                    0
                                ? (stats.totalHabits - stats.completedHabits)
                                    .toDouble()
                                : 1,
                            color: Colors.redAccent,
                            title: 'Pendientes',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
