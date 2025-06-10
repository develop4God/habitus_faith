import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitService with ChangeNotifier {
  final List<Habit> _habits = [
    Habit(name: "Oración", description: "Dedica tiempo a la oración diaria."),
    Habit(name: "Lectura Bíblica", description: "Lee un capítulo de la Biblia."),
    Habit(name: "Gratitud", description: "Escribe algo por lo que agradeces hoy."),
  ];

  List<Habit> get habits => _habits;

  void toggleHabit(Habit habit) {
    habit.completed = !habit.completed;
    notifyListeners();
  }

  void resetHabits() {
    for (final habit in _habits) {
      habit.completed = false;
    }
    notifyListeners();
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    notifyListeners();
  }
}
