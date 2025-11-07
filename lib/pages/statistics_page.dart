import 'package:flutter/material.dart';
// DEPRECATED: Usa la nueva página en features/statistics/statistics_page.dart
import '../features/statistics/statistics_page.dart' as modern_stats;

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const modern_stats.StatisticsPage();
  }
}
