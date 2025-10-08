import 'package:habitus_faith/features/habits/models/habit_model.dart';

class TestFixtures {
  static HabitModel habitOracion() {
    return HabitModel.create(
      id: 'test-habit-1',
      userId: 'test-user',
      name: 'Oración',
      description: 'Dedica tiempo a la oración diaria.',
      category: HabitCategory.prayer,
    );
  }

  static HabitModel habitLectura() {
    return HabitModel.create(
      id: 'test-habit-2',
      userId: 'test-user',
      name: 'Lectura Bíblica',
      description: 'Lee un capítulo de la Biblia.',
      category: HabitCategory.bibleReading,
    );
  }

  static HabitModel habitConRacha(int days) {
    final habit = HabitModel.create(
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

  static List<HabitModel> listaHabitos(int cantidad) {
    return List.generate(
      cantidad,
      (index) => HabitModel.create(
        id: 'test-habit-$index',
        userId: 'test-user',
        name: 'Hábito ${index + 1}',
        description: 'Descripción del hábito ${index + 1}',
      ),
    );
  }
}
