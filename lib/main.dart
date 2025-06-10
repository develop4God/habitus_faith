import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/habit_service.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const HabitusFeApp());
}

class HabitusFeApp extends StatelessWidget {
  const HabitusFeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitService()),
      ],
      child: MaterialApp(
        title: 'Habitus Fe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      ),
    );
  }
}
