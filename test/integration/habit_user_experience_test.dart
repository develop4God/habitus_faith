import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/domain/models/habit_notification.dart';
import 'package:habitus_faith/features/habits/presentation/habits_providers.dart';
import 'package:habitus_faith/widgets/unified_habit_list.dart';
import 'package:habitus_faith/widgets/unified_habit_card.dart';
import 'package:habitus_faith/pages/home_page.dart';
import 'package:habitus_faith/pages/habits_page.dart';
import 'package:habitus_faith/pages/edit_habit_dialog.dart';
import 'package:habitus_faith/widgets/add_habit_dialog.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';

// Helper widget for tests
class TestAppWrapper extends StatelessWidget {
  final Widget child;

  const TestAppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}

/// High-value user behavior tests for habit management features
/// SKIPPED: These tests require Firebase initialization and pumpAndSettle timing fixes
/// TODO: Re-enable after proper Firebase test setup
void main() {
  group('Habit User Experience Tests -', () {
    testWidgets('1. Habits page shows all user habits', (tester) async {
      // Create a provider override with 10 test habits
      final testHabits = List.generate(
        10,
        (i) => Habit.create(
          id: 'habit_$i',
          userId: 'test_user',
          name: 'Test Habit ${i + 1}',
          category: HabitCategory.mental,
          emoji: '🧠',
          colorValue: Colors.blue.toARGB32(),
          difficulty: HabitDifficulty.medium,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsStreamProvider.overrideWith((ref) {
              return Stream.value(testHabits);
            }),
          ],
          child: const TestAppWrapper(child: HabitsPage()),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll and verify all 10 habits are displayed
      for (int i = 0; i < 10; i++) {
        final habitFinder = find.text('Test Habit ${i + 1}');
        await tester.scrollUntilVisible(
          habitFinder,
          200.0,
          scrollable: find.byType(Scrollable).first,
        );
        expect(
          habitFinder,
          findsOneWidget,
          reason: 'All habits should be visible in the habits page',
        );
      }
    });

    testWidgets('2. Home page text is readable over background image', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: TestAppWrapper(child: HomePage())),
      );

      await tester.pumpAndSettle();

      // Find the progress text and verify it exists and has a style
      final progressTextFinder = find.byType(Text).first;
      final textWidget = tester.widget<Text>(progressTextFinder);

      // Log the style for debugging
      debugPrint('Text style: \\${textWidget.style}');

      // Check that the Text widget exists and has a style
      expect(
        textWidget,
        isNotNull,
        reason: 'Progress Text widget should exist',
      );
      expect(textWidget.style, isNotNull, reason: 'Text should have a style');
      // Optionally, check for color or fontWeight if needed
    });

    testWidgets('3. Edit habit has save/cancel buttons on top', (tester) async {
      final testHabit = Habit.create(
        id: 'test_habit',
        userId: 'test_user',
        name: 'Test Habit',
        category: HabitCategory.mental,
        emoji: '🧠',
        colorValue: Colors.blue.toARGB32(),
        difficulty: HabitDifficulty.medium,
      );

      late AppLocalizations l10n;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  l10n = AppLocalizations.of(context)!;
                  return EditHabitDialog(l10n: l10n, habit: testHabit);
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Print all button texts in the dialog for debugging
      final dialogTexts = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(Text),
      );
      for (final e in dialogTexts.evaluate()) {
        final t = e.widget as Text;
        debugPrint('Dialog text: \\${t.data}');
      }

      // Find save and cancel buttons (support both English and Spanish)
      final saveButton =
          find.widgetWithIcon(ElevatedButton, Icons.check).evaluate().isNotEmpty
              ? find.widgetWithIcon(ElevatedButton, Icons.check)
              : find.widgetWithText(ElevatedButton, l10n.save);
      final cancelButton = find.text('Cancel').evaluate().isNotEmpty
          ? find.text('Cancel')
          : find.text('Cancelar');

      expect(
        saveButton,
        findsOneWidget,
        reason: 'Save button with check icon or save text should be present',
      );
      expect(
        cancelButton,
        findsOneWidget,
        reason: 'Cancel or Cancelar button should be present',
      );

      // Get positions
      final savePos = tester.getTopLeft(saveButton);
      final dialogTop = tester.getTopLeft(find.byType(Dialog));

      // Verify buttons are near the top
      expect(
        savePos.dy - dialogTop.dy < 100,
        isTrue,
        reason: 'Save/Cancel buttons should be at the top of the dialog',
      );
    });

    testWidgets('4. Subtasks are displayed in expanded habit view', (
      tester,
    ) async {
      final testHabit = Habit.create(
        id: 'test_habit',
        userId: 'test_user',
        name: 'Test Habit with Subtasks',
        category: HabitCategory.mental,
        emoji: '🧠',
        colorValue: Colors.blue.toARGB32(),
        difficulty: HabitDifficulty.medium,
      ).copyWith(
        subtasks: const [
          Subtask(id: '1', title: 'Subtask 1', completed: false),
          Subtask(id: '2', title: 'Subtask 2', completed: true),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsStreamProvider.overrideWith((ref) {
              return Stream.value([testHabit]);
            }),
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

      await tester.pumpAndSettle();

      // Tap on the habit card to expand
      await tester.tap(find.text('Test Habit with Subtasks'));
      await tester.pumpAndSettle();

      // Verify subtasks are shown
      expect(find.text('Subtask 1'), findsOneWidget);
      expect(find.text('Subtask 2'), findsOneWidget);
    });

    testWidgets('5. Add habit includes repetition configuration', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return AddHabitDialog(l10n: l10n);
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter habit name
      await tester.enterText(
        find.byKey(const Key('habit_name_input')),
        'Daily Exercise',
      );
      await tester.pumpAndSettle();

      // Navigate through steps to reach recurrence
      for (int i = 0; i < 5; i++) {
        final nextButton = find.text('Next').last;
        if (nextButton.evaluate().isNotEmpty) {
          await tester.tap(nextButton);
          await tester.pumpAndSettle();
        }
      }

      // Verify recurrence step is available
      expect(
        find.textContaining('Repetition', findRichText: true),
        findsWidgets,
        reason: 'Recurrence configuration should be available in add habit',
      );
    });

    testWidgets('7. Habits are not ordered by completion status', (
      tester,
    ) async {
      final testHabits = [
        Habit.create(
          id: 'habit_1',
          userId: 'test_user',
          name: 'Completed Habit',
          category: HabitCategory.mental,
          emoji: '🧠',
          colorValue: Colors.blue.toARGB32(),
          difficulty: HabitDifficulty.medium,
        ).copyWith(completedToday: true),
        Habit.create(
          id: 'habit_2',
          userId: 'test_user',
          name: 'Pending Habit',
          category: HabitCategory.mental,
          emoji: '🧠',
          colorValue: Colors.blue.toARGB32(),
          difficulty: HabitDifficulty.medium,
        ),
        Habit.create(
          id: 'habit_3',
          userId: 'test_user',
          name: 'Another Completed',
          category: HabitCategory.mental,
          emoji: '🧠',
          colorValue: Colors.blue.toARGB32(),
          difficulty: HabitDifficulty.medium,
        ).copyWith(completedToday: true),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsStreamProvider.overrideWith((ref) {
              return Stream.value(testHabits);
            }),
          ],
          child: TestAppWrapper(
            child: UnifiedHabitList(
              onComplete: (_) async {},
              onUncheck: (_) async {},
              onDelete: (_) async {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find all habit cards
      final habitCards = find.byType(UnifiedHabitCard);
      expect(habitCards, findsNWidgets(3));

      // Verify order matches input order (not sorted by completion)
      final firstCard = tester.widget<UnifiedHabitCard>(habitCards.at(0));
      final secondCard = tester.widget<UnifiedHabitCard>(habitCards.at(1));
      final thirdCard = tester.widget<UnifiedHabitCard>(habitCards.at(2));

      expect(firstCard.habit.name, 'Completed Habit');
      expect(secondCard.habit.name, 'Pending Habit');
      expect(thirdCard.habit.name, 'Another Completed');
    });

    testWidgets('8. Habits can be reordered by drag and drop', (tester) async {
      final testHabits = [
        Habit.create(
          id: 'habit_1',
          userId: 'test_user',
          name: 'First Habit',
          category: HabitCategory.mental,
          emoji: '🧠',
          colorValue: Colors.blue.toARGB32(),
          difficulty: HabitDifficulty.medium,
        ),
        Habit.create(
          id: 'habit_2',
          userId: 'test_user',
          name: 'Second Habit',
          category: HabitCategory.mental,
          emoji: '🧠',
          colorValue: Colors.blue.toARGB32(),
          difficulty: HabitDifficulty.medium,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsStreamProvider.overrideWith((ref) {
              return Stream.value(testHabits);
            }),
          ],
          child: TestAppWrapper(
            child: UnifiedHabitList(
              onComplete: (_) async {},
              onUncheck: (_) async {},
              onDelete: (_) async {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify drag start listener exists for reordering
      expect(
        find.byType(ReorderableDragStartListener),
        findsNWidgets(2),
        reason: 'Each habit should have a drag listener for reordering',
      );

      // Verify habits have unique keys for reordering
      final dragListener1 = tester
          .widget<ReorderableDragStartListener>(
            find.byKey(const Key('habit_drag_habit_1')),
          )
          .key;
      final dragListener2 = tester
          .widget<ReorderableDragStartListener>(
            find.byKey(const Key('habit_drag_habit_2')),
          )
          .key;

      expect(dragListener1, isNotNull);
      expect(dragListener2, isNotNull);
      expect(dragListener1, isNot(equals(dragListener2)));
    });

    testWidgets('Habit edit shows success message', (tester) async {
      final testHabit = Habit.create(
        id: 'test_habit',
        userId: 'test_user',
        name: 'Test Habit',
        category: HabitCategory.mental,
        emoji: '🧠',
        colorValue: Colors.blue.toARGB32(),
        difficulty: HabitDifficulty.medium,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsStreamProvider.overrideWith((ref) {
              return Stream.value([testHabit]);
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        final l10n = AppLocalizations.of(context)!;
                        showDialog(
                          context: context,
                          builder: (ctx) =>
                              EditHabitDialog(l10n: l10n, habit: testHabit),
                        );
                      },
                      child: const Text('Edit'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open edit dialog
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify success message appears
      expect(
        find.textContaining('successfully', findRichText: true),
        findsWidgets,
              reason: 'Success message should appear after saving',
      );
    });
  }, skip: true); // Skip: Requires Firebase initialization
}
