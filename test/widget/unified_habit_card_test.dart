import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/widgets/unified_habit_card.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/presentation/habits_providers.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('UnifiedHabitCard Widget Tests', () {
    testWidgets('should display habit name and emoji', (tester) async {
      final testHabit = Habit(
        id: 'test-habit-1',
        name: 'Morning Prayer',
        createdAt: DateTime.now(),
        category: HabitCategory.spiritual,
        emoji: '🙏',
        userId: 'test-user',
        completedToday: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsStreamProvider
                .overrideWith((ref) => Stream.value([testHabit])),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', '')],
            home: Scaffold(
              body: UnifiedHabitCard(
                habit: testHabit,
                onComplete: (_) async {},
                onUncheck: (_) async {},
                onDelete: (_) async {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Morning Prayer'), findsOneWidget);
      expect(find.text('🙏'), findsOneWidget);
    });

    testWidgets('should show checkbox unchecked when habit not completed',
        (tester) async {
      final testHabit = Habit(
        id: 'test-habit-1',
        name: 'Morning Prayer',
        createdAt: DateTime.now(),
        category: HabitCategory.spiritual,
        emoji: '🙏',
        userId: 'test-user',
        completedToday: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsStreamProvider
                .overrideWith((ref) => Stream.value([testHabit])),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', '')],
            home: Scaffold(
              body: UnifiedHabitCard(
                habit: testHabit,
                onComplete: (_) async {},
                onUncheck: (_) async {},
                onDelete: (_) async {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);
    });

    testWidgets('should open modal on tap and show duplicate button',
        (tester) async {
      final testHabit = Habit(
        id: 'test-habit-1',
        name: 'Morning Prayer',
        createdAt: DateTime.now(),
        category: HabitCategory.spiritual,
        emoji: '🙏',
        userId: 'test-user',
        completedToday: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsStreamProvider
                .overrideWith((ref) => Stream.value([testHabit])),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', '')],
            home: Scaffold(
              body: UnifiedHabitCard(
                habit: testHabit,
                onComplete: (_) async {},
                onUncheck: (_) async {},
                onDelete: (_) async {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Tap on the card to open modal
      await tester.tap(find.byType(UnifiedHabitCard));
      await tester.pumpAndSettle();

      // Modal should show duplicate button (copy icon)
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);

      // Modal should show timer icon
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });
  });
}
