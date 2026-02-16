import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/features/habits/data/storage/json_storage_service.dart';
import 'package:habitus_faith/features/habits/data/storage/json_habits_repository.dart';
import 'package:habitus_faith/features/habits/presentation/habits_providers.dart';

void main() {
  test('duplicate habit via repository creates new habit', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = JsonStorageService(prefs);
    int counter = 0;
    final repo = JsonHabitsRepository(
      storage: storage,
      userId: 'test_user',
      // Use a simple counter-based id generator to avoid millisecond collisions in tests
      idGenerator: () =>
          'id_test_${counter++}_${DateTime.now().microsecondsSinceEpoch}',
    );

    final createResult = await repo.createHabit(name: 'Original');
    expect(createResult.isSuccess(), isTrue);
    final original = createResult.value;

    final duplicateResult = await repo.createHabit(
      name: '${original.name} (Copy)',
      category: original.category,
      emoji: original.emoji,
      colorValue: original.colorValue,
      difficulty: original.difficulty,
    );

    expect(duplicateResult.isSuccess(), isTrue);
    final duplicate = duplicateResult.value;
    expect(duplicate.id != original.id, isTrue);
    expect(duplicate.name.contains('Copy'), isTrue);
  });

  test('duplicate via notifier duplicateHabitFromData works', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = JsonStorageService(prefs);
    int counter = 0;
    final repo = JsonHabitsRepository(
      storage: storage,
      userId: 'test_user',
      // Use a simple counter-based id generator to avoid millisecond collisions in tests
      idGenerator: () =>
          'id_test_${counter++}_${DateTime.now().microsecondsSinceEpoch}',
    );

    final container = ProviderContainer(overrides: [
      habitsRepositoryProvider.overrideWithValue(repo),
    ]);

    addTearDown(container.dispose);

    final createResult = await repo.createHabit(name: 'Original2');
    expect(createResult.isSuccess(), isTrue);
    final original = createResult.value;

    final notifier = container.read(habitsNotifierProvider.notifier);

    await notifier.duplicateHabitFromData(original);

    final habits = await repo.getHabits();
    expect(habits.length, 2);
    expect(habits.any((h) => h.name.contains('Copy')), isTrue);
  });
}
