import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/widgets/unified_habit_list.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/presentation/habits_providers.dart';

void main() {
  group('UnifiedHabitList Widget Tests', () {
    testWidgets('should display empty message when no habits', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsStreamProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: UnifiedHabitList(
                onComplete: (_) async {},
                onUncheck: (_) async {},
                onDelete: (_) async {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should show empty state
      expect(find.text('¡Comienza tu viaje de hábitos!'), findsOneWidget);
    });

    testWidgets('should display habit cards when habits exist', (tester) async {
      final testHabits = [
        Habit(
          id: '1',
          name: 'Test Habit 1',
          createdAt: DateTime.now(),
          category: HabitCategory.spiritual,
          emoji: '🙏',
          userId: '',
        ),
        Habit(
          id: '2',
          name: 'Test Habit 2',
          createdAt: DateTime.now(),
          category: HabitCategory.physical,
          emoji: '💪',
          userId: '',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsStreamProvider.overrideWith(
              (ref) => Stream.value(testHabits),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: UnifiedHabitList(
                onComplete: (_) async {},
                onUncheck: (_) async {},
                onDelete: (_) async {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should show both habits
      expect(find.text('Test Habit 1'), findsOneWidget);
      expect(find.text('Test Habit 2'), findsOneWidget);
      expect(find.text('🙏'), findsOneWidget);
      expect(find.text('💪'), findsOneWidget);
    });

    testWidgets('should show swipe hint when enabled', (tester) async {
      final testHabits = [
        Habit(
          id: '1',
          name: 'Test Habit',
          createdAt: DateTime.now(),
          category: HabitCategory.spiritual,
          userId: '',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsStreamProvider.overrideWith(
              (ref) => Stream.value(testHabits),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: UnifiedHabitList(
                onComplete: (_) async {},
                onUncheck: (_) async {},
                onDelete: (_) async {},
                showSwipeHint: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should show swipe hint
      expect(find.byIcon(Icons.swipe_left), findsOneWidget);
    });

    testWidgets('should not show swipe hint when disabled', (tester) async {
      final testHabits = [
        Habit(
          id: '1',
          name: 'Test Habit',
          createdAt: DateTime.now(),
          category: HabitCategory.spiritual,
          userId: '',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsStreamProvider.overrideWith(
              (ref) => Stream.value(testHabits),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: UnifiedHabitList(
                onComplete: (_) async {},
                onUncheck: (_) async {},
                onDelete: (_) async {},
                showSwipeHint: false,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should not show swipe hint
      expect(find.byIcon(Icons.swipe_left), findsNothing);
    });

    testWidgets('should show checkboxes for all habits', (tester) async {
      final testHabits = [
        Habit(
          id: '1',
          name: 'Test Habit 1',
          createdAt: DateTime.now(),
          category: HabitCategory.spiritual,
          userId: '',
        ),
        Habit(
          id: '2',
          name: 'Test Habit 2',
          createdAt: DateTime.now(),
          category: HabitCategory.physical,
          userId: '',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsStreamProvider.overrideWith(
              (ref) => Stream.value(testHabits),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: UnifiedHabitList(
                onComplete: (_) async {},
                onUncheck: (_) async {},
                onDelete: (_) async {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should have checkboxes for both habits
      expect(find.byType(Checkbox), findsNWidgets(2));
    });
  });
}
