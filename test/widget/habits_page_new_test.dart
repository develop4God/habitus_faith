import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/pages/habits_page_new.dart';
import 'package:habitus_faith/features/habits/data/storage/storage_providers.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Comprehensive widget tests for HabitsPageNew
/// Tests focus on real user flows and edge cases
void main() {
  group('HabitsPageNew Widget Tests', () {
    setUp(() async {
      // Clean slate for each test
      SharedPreferences.setMockInitialValues({});
    });

    Future<Widget> createApp() async {
      final prefs = await SharedPreferences.getInstance();
      
      return ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
          ],
          home: const HabitsPageNew(),
        ),
      );
    }

    testWidgets('renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(await createApp());
      await tester.pump();

      expect(find.byType(HabitsPageNew), findsOneWidget);
    });

    testWidgets('shows empty state when no habits exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(await createApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should show empty state
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      expect(find.text('No habits'), findsOneWidget);
    });

    testWidgets('has add habit FAB button', (WidgetTester tester) async {
      await tester.pumpWidget(await createApp());
      await tester.pump();

      expect(find.byKey(const Key('add_habit_fab')), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('opens add habit dialog when FAB tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(await createApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const Key('add_habit_fab')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Dialog should be visible
      expect(find.text('Add habit'), findsOneWidget);
      expect(find.byKey(const Key('habit_name_input')), findsOneWidget);
      expect(find.byKey(const Key('habit_description_input')), findsOneWidget);
    });

    testWidgets('dialog has cancel and add buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(await createApp());
      await tester.pump();

      await tester.tap(find.byKey(const Key('add_habit_fab')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byKey(const Key('confirm_add_habit_button')), findsOneWidget);
    });

    testWidgets('can cancel dialog', (WidgetTester tester) async {
      await tester.pumpWidget(await createApp());
      await tester.pump();

      await tester.tap(find.byKey(const Key('add_habit_fab')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Dialog should be closed
      expect(find.text('Add habit'), findsNothing);
    });

    testWidgets('validates habit name is not empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(await createApp());
      await tester.pump();

      await tester.tap(find.byKey(const Key('add_habit_fab')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Try to add with empty name
      await tester.enterText(
          find.byKey(const Key('habit_description_input')), 'Test description');
      
      await tester.tap(find.byKey(const Key('confirm_add_habit_button')));
      await tester.pump();

      // Dialog should still be open (validation failed)
      expect(find.text('Add habit'), findsOneWidget);
    });

    testWidgets('creates habit with valid inputs',
        (WidgetTester tester) async {
      await tester.pumpWidget(await createApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const Key('add_habit_fab')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.enterText(
          find.byKey(const Key('habit_name_input')), 'Test Habit');
      await tester.enterText(
          find.byKey(const Key('habit_description_input')), 'Test Description');
      
      await tester.tap(find.byKey(const Key('confirm_add_habit_button')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Dialog should close
      expect(find.text('Add habit'), findsNothing);
      
      // Habit should appear in list
      expect(find.text('Test Habit'), findsOneWidget);
    });
  });

  group('HabitsPageNew - Localization', () {
    testWidgets('displays text in English', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            locale: const Locale('en', ''),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', '')],
            home: const HabitsPageNew(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('My Habits'), findsOneWidget);
      expect(find.text('No habits'), findsOneWidget);
    });
  });
}
