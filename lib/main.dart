import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'pages/bible_reader_page.dart';
import 'services/habit_service.dart';
import 'services/bible_db_service.dart';
import 'models/bible_version.dart';
import 'utils/bible_version_registry.dart';
import 'providers/devocional_provider.dart';
import 'utils/theme_constants.dart';

// ----- MODELO DE VERSIÓN DE BIBLIA -----
//moved to  bible_version.dart

// ----- LANDING PAGE (la de siempre) -----
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 220,
              child: Lottie.asset('assets/lottie/animation.json'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Habitus Fe',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Color(0xff1a202c),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                backgroundColor: const Color(0xff6366f1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
                shadowColor: Colors.blueAccent.withValues(alpha: 0.15),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Text(
                'Comenzar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Botón para ir al lector de Biblia
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: const Color(0xffa5b4fc),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 3,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BiblePageLauncher()),
                );
              },
              child: const Text(
                'Leer Biblia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----- PANTALLA LANZADORA DE LA BIBLIA (para inicializar async las DBs antes de mostrar) -----
class BiblePageLauncher extends StatefulWidget {
  const BiblePageLauncher({super.key});

  @override
  State<BiblePageLauncher> createState() => _BiblePageLauncherState();
}

class _BiblePageLauncherState extends State<BiblePageLauncher> {
  late List<BibleVersion> bibleVersions;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    bibleVersions = BibleVersionRegistry.getAllVersions();
    _initAll();
  }

  Future<void> _initAll() async {
    for (var v in bibleVersions) {
      v.service = BibleDbService();
      await v.service!.initDb(v.assetPath, v.dbFileName);
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return BibleReaderPage(versions: bibleVersions);
  }
}

// ----- MAIN -----
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitService()),
        ChangeNotifierProvider(create: (_) => DevocionalProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeConstants.lightTheme,
      home: const LandingPage(),
    );
  }
}
