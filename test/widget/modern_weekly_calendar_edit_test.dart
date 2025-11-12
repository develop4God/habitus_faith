import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/pages/habits_page_ui.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:habitus_faith/features/habits/presentation/widgets/habit_card/compact_habit_card.dart';

void main() {
  testWidgets('Tapping Edit in modal opens EditHabitDialog', (tester) async {
    final habit = Habit.create(
      id: 'h1',
      userId: 'u1',
      name: 'Mi hábito',
      emoji: '✅',
      category: HabitCategory.spiritual,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es', '')],
        home: Scaffold(
          body: ModernWeeklyCalendar(habits: [habit], initialDate: DateTime.now()),
        ),
      ),
    );

    // Wait for build
    await tester.pumpAndSettle();

    // Tap the CompactHabitCard (first one)
    final cardFinder = find.byType(CompactHabitCard);
    expect(cardFinder, findsOneWidget);

    await tester.tap(cardFinder);
    await tester.pumpAndSettle();

    // Find the edit button inside the modal (label localized 'Editar')
    final editButton = find.widgetWithText(ElevatedButton, 'Editar');
    expect(editButton, findsOneWidget);

    // Tap edit button
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    // After tapping, the EditHabitDialog should be visible with title 'Editar Hábito'
    expect(find.text('Editar Hábito'), findsOneWidget);
  });
}
