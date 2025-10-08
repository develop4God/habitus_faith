import 'package:flutter/material.dart';
import 'habits_page.dart';
import 'statistics_page.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habitus Fe'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                child: Icon(Icons.check_box, size: 64, color: Colors.blue),
              ),
              const SizedBox(height: 24),
              Text(
                '¡Bienvenido a Habitus Fe!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Haz de la fe tu mejor hábito diario.\nEmpieza a registrar tus hábitos espirituales ahora.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HabitsPage()));
                },
                child: const Text('Mis hábitos'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const StatisticsPage()));
                },
                child: const Text('Estadísticas'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()));
                },
                child: const Text('Ajustes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
