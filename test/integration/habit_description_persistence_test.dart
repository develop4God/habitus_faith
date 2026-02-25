import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/models/micro_habit.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/data/storage/json_habits_repository.dart';
import 'package:habitus_faith/features/habits/data/storage/json_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test Suite 1: Description Field Persistence (CRITICAL)
/// Verifies that MicroHabit metadata (purpose, trigger, verse) is properly
/// persisted to the database through the description field.
void main() {
  group('Description Field Persistence Tests', () {
    late JsonHabitsRepository repository;
    late JsonStorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = JsonStorageService(prefs);
      repository = JsonHabitsRepository(
        storage: storageService,
        userId: 'test-user-123',
        idGenerator: () => DateTime.now().microsecondsSinceEpoch.toString(),
      );
    });

    /// Test 1.1: Description with all fields
    test('saves description with purpose, trigger, and verse', () async {
      // Arrange
      const microHabit = MicroHabit(
        id: 'test-1',
        action: 'Morning prayer 10 min',
        purpose: 'Connect with God before work',
        trigger: 'Right after waking up',
        verse: 'Psalm 5:3',
        verseText: 'In the morning, Lord, you hear my voice',
      );

      // Build description as done in generated_habits_page.dart
      final description = [
        microHabit.purpose,
        if (microHabit.trigger != null) '⏰ ${microHabit.trigger}',
        if (microHabit.verseText != null)
          '📖 ${microHabit.verse}\n"${microHabit.verseText}"',
      ].join('\n\n');

      // Act
      final result = await repository.createHabit(
        name: microHabit.action,
        description: description,
        category: HabitCategory.spiritual,
      );

      // Assert
      expect(result.isSuccess(), true);
      final saved = result.value;
      expect(saved.description, isNotNull);
      expect(saved.description, contains('Connect with God'));
      expect(saved.description, contains('⏰ Right after waking'));
      expect(saved.description, contains('📖 Psalm 5:3'));
      expect(saved.description, contains('In the morning, Lord'));
    });

    /// Test 1.2: Description with missing optional fields
    test('builds description when trigger and verse are null', () async {
      // Arrange
      const microHabit = MicroHabit(
        id: 'test-2',
        action: 'Prayer',
        purpose: 'Daily connection',
        trigger: null,
        verse: 'Psalm 1:1',
        verseText: null,
      );

      // Build description with missing fields
      final description = [
        microHabit.purpose,
        if (microHabit.trigger != null) '⏰ ${microHabit.trigger}',
        if (microHabit.verseText != null)
          '📖 ${microHabit.verse}\n"${microHabit.verseText}"',
      ].join('\n\n');

      // Act
      final result = await repository.createHabit(
        name: microHabit.action,
        description: description,
        category: HabitCategory.spiritual,
      );

      // Assert
      expect(result.isSuccess(), true);
      final saved = result.value;
      expect(saved.description, 'Daily connection');
      expect(saved.description, isNot(contains('⏰')));
      expect(saved.description, isNot(contains('📖')));
    });

    /// Test 1.3: Backward compatibility
    test('creates habit without description (legacy support)', () async {
      // Act
      final result = await repository.createHabit(
        name: 'Old habit',
        category: HabitCategory.spiritual,
        // No description parameter
      );

      // Assert
      expect(result.isSuccess(), true);
      expect(result.value.description, isNull);
    });
  });
}
