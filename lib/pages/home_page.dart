import 'package:flutter/material.dart';
import 'habits_page.dart';

import 'settings_page.dart';
import 'bible_reader_page.dart';
import 'devotional_discovery_page.dart';
import '../features/statistics/statistics_page.dart'; // Importa la página correcta
import '../l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<Widget> pages = [
      const HabitsPage(),
      const BibleReaderPage(),
      const DevotionalDiscoveryPage(),
      const StatisticsPage(), // Usa la clase correcta
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.check_box),
            label: l10n.myHabits,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book),
            label: l10n.readBible,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories_outlined),
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
