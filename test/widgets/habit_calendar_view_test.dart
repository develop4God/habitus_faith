import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/presentation/habits_providers.dart';
import 'package:habitus_faith/widgets/habit_calendar_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final testHabits = [
  Habit(
    id: '1',
    userId: 'user1',
    name: 'Orar',
    category: HabitCategory.spiritual,
    emoji: '🙏',
    createdAt: DateTime.now(),
    completedToday: true,
    currentStreak: 3,
    longestStreak: 5,
    completionHistory: [DateTime.now()],
  ),
];

final testHabitsProvider = Provider((ref) => testHabits);
final testAsyncHabitsProvider = StreamProvider<List<Habit>>((ref) async* {
  yield testHabits;
});

void main() {
  testWidgets('HabitCalendarView no overflow smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitsStreamProvider.overrideWith((ref) => Stream.value(testHabits)),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [Locale('es', ''), Locale('en', '')],
          home: HabitCalendarView(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HabitCalendarView), findsOneWidget);
    expect(find.textContaining('overflow'), findsNothing);
  });
}
