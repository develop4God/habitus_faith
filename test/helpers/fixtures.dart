import 'package:habitus_faith/features/habits/domain/habit.dart';

class TestFixtures {
  static Habit habitOracion() {
    return Habit.create(
      id: 'test-habit-1',
      userId: 'test-user',
      name: 'Oración',
      description: 'Dedica tiempo a la oración diaria.',
      category: HabitCategory.spiritual,
    );
  }

  static Habit habitLectura() {
    return Habit.create(
      id: 'test-habit-2',
      userId: 'test-user',
      name: 'Lectura Bíblica',
      description: 'Lee un capítulo de la Biblia.',
      category: HabitCategory.spiritual,
    );
  }

  static Habit habitConRacha(int days) {
    final habit = Habit.create(
      id: 'test-habit-streak',
      userId: 'test-user',
      name: 'Hábito con racha',
      description: 'Hábito para probar rachas',
    );

    // Simulate completing the habit for consecutive days
    var updatedHabit = habit;
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      updatedHabit = updatedHabit.copyWith(
        currentStreak: days - i,
        longestStreak: days - i,
        lastCompletedAt: date,
        completionHistory: [...updatedHabit.completionHistory, date],
      );
    }

    return updatedHabit;
  }

  static List<Habit> listaHabitos(int cantidad) {
    return List.generate(
      cantidad,
      (index) => Habit.create(
        id: 'test-habit-$index',
        userId: 'test-user',
        name: 'Hábito ${index + 1}',
        description: 'Descripción del hábito ${index + 1}',
      ),
    );
  }
}
