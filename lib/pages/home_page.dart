import 'package:flutter/material.dart';
import 'habits_page.dart';
import 'statistics_page.dart';
import 'settings_page.dart';
import 'bible_reader_page.dart';
import '../services/bible_db_service.dart';
import '../models/bible_version.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late List<BibleVersion> bibleVersions;
  bool _bibleLoading = true;

  @override
  void initState() {
    super.initState();
    _initBibleVersions();
  }

  Future<void> _initBibleVersions() async {
    bibleVersions = [
      BibleVersion(
        name: 'RVR1960 Reina Valera 1960',
        assetPath: 'assets/biblia/RVR1960.SQLite3',
        dbFileName: 'RVR1960.SQLite3',
      ),
      BibleVersion(
        name: 'NTV Nueva Traducción Viviente',
        assetPath: 'assets/biblia/NTV.SQLite3',
        dbFileName: 'NTV.SQLite3',
      ),
      BibleVersion(
        name: 'Biblia Peshitta Nuevo Testamento',
        assetPath: 'assets/biblia/Pesh-es.SQLite3',
        dbFileName: 'Pesh-es.SQLite3',
      ),
      BibleVersion(
        name: 'TLA Traducción en Lenguaje Actual',
        assetPath: 'assets/biblia/TLA.SQLite3',
        dbFileName: 'TLA.SQLite3',
      ),
    ];

    for (var v in bibleVersions) {
      v.service = BibleDbService();
      await v.service!.initDb(v.assetPath, v.dbFileName);
    }

    setState(() {
      _bibleLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HabitsPage(),
      _bibleLoading
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : BibleReaderPage(versions: bibleVersions),
      const StatisticsPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Hábitos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Biblia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progreso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

