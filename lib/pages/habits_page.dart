import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/habit_service.dart';
import '../models/habit.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final habitService = Provider.of<HabitService>(context);
    final habits = habitService.habits;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis hábitos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => habitService.resetHabits(),
            tooltip: 'Reiniciar hábitos',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];
          return ListTile(
            leading: Checkbox(
              value: habit.completed,
              onChanged: (value) {
                habitService.toggleHabit(habit);
              },
            ),
            title: Text(habit.name),
            subtitle: Text(habit.description),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddHabitDialog(context, habitService);
        },
        tooltip: 'Agregar nuevo hábito',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, HabitService habitService) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar hábito'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && descCtrl.text.isNotEmpty) {
                habitService.addHabit(Habit(
                  name: nameCtrl.text,
                  description: descCtrl.text,
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
