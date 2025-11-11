import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'habits_page.dart';

import 'settings_page.dart';
import 'bible_reader_page.dart';
import 'devotional_discovery_page.dart';
import '../features/statistics/statistics_page.dart'; // Importa la página correcta
import '../l10n/app_localizations.dart';
import '../providers/devotional_providers.dart';
import '../features/habits/presentation/habits_providers.dart';
import '../core/models/devocional_model.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now();
    final formattedDate = '${today.day}/${today.month}/${today.year}';

    // Devocional de hoy
    final devotionalState = ref.watch(devotionalProvider);
    final todayDevocional = devotionalState.all.firstWhere(
      (d) =>
          d.date.year == today.year &&
          d.date.month == today.month &&
          d.date.day == today.day,
      orElse: () => Devocional(
        id: '',
        versiculo: '',
        reflexion: '',
        paraMeditar: [],
        oracion: '',
        date: today,
      ),
    );

    // Hábitos de hoy
    final habitsAsync = ref.watch(habitsStreamProvider);
    final habits = habitsAsync.asData?.value ?? [];
    final completedHabits = habits.where((h) => h.completedToday).length;
    final totalHabits = habits.length;

    final List<Widget> pages = [
      // Home principal con hero, versículo y resumen
      Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Icon(Icons.home, size: 28),
              const SizedBox(width: 12),
              Text(l10n.appTitle),
            ],
          ),
          elevation: 2,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero section con transición de hábitos
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade200,
                      Colors.deepOrange.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.introMessage,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      formattedDate,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    if (habits.isNotEmpty)
                      SizedBox(
                        height: 80,
                        child: PageView.builder(
                          itemCount: habits.length,
                          controller: PageController(viewportFraction: 0.7),
                          itemBuilder: (context, index) {
                            final habit = habits[index];
                            return Hero(
                              tag: 'habit_${habit.id}',
                              child: Card(
                                color: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        habit.emoji ?? '✓',
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          habit.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (habit.completedToday)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Versículo del día (del devocional)
              if (todayDevocional.versiculo.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Card(
                    color: Colors.yellow.shade50,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        todayDevocional.versiculo,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.orange.shade900,
                                  fontSize: 16,
                                ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              // Resumen de hábitos para hoy
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  l10n.habitsCompleted,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.habitsCompletedCount(
                            completedHabits,
                            totalHabits,
                          ),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Resumen de tus hábitos para hoy.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      const HabitsPage(),
      const BibleReaderPage(),
      const DevotionalDiscoveryPage(),
      const StatisticsPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_filled),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.playlist_add_check_circle_outlined),
            label: l10n.routine,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_stories_outlined),
            label: l10n.readBible,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.local_library_outlined),
            label: 'Devotionals',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: l10n.statistics,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
