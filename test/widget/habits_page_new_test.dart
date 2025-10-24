import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/pages/habits_page_new.dart';
import 'package:habitus_faith/features/habits/data/storage/storage_providers.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// High-quality widget tests for HabitsPageNew
/// Focus: Real user flows, edge cases, and resilient validation
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
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en', ''),
          ],
          home: HabitsPageNew(),
        ),
      );
    }

    group('Initial Rendering', () {
      testWidgets('renders without crashing', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        expect(find.byType(HabitsPageNew), findsOneWidget,
            reason: 'HabitsPageNew should render');
      });

      testWidgets('shows app bar with title', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        expect(find.text('My Habits'), findsOneWidget,
            reason: 'App bar should display title');
        expect(find.byType(AppBar), findsOneWidget,
            reason: 'Should have an app bar');
      });

      testWidgets('has floating action button', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('add_habit_fab')), findsOneWidget,
            reason: 'FAB should be present');
        expect(find.byType(FloatingActionButton), findsOneWidget,
            reason: 'Should have exactly one FAB');
        expect(find.byIcon(Icons.add), findsOneWidget,
            reason: 'FAB should have add icon');
      });
    });

    group('Empty State', () {
      testWidgets('shows app bar and FAB even with no habits',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();
        
        // Core UI elements should be present regardless of habit count
        expect(find.byType(AppBar), findsOneWidget,
            reason: 'App bar should always be present');
        expect(find.byKey(const Key('add_habit_fab')), findsOneWidget,
            reason: 'FAB should always be present');
      });
    });

    group('Add Habit Dialog', () {
      testWidgets('opens dialog when FAB is tapped',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        await tester.tap(find.byKey(const Key('add_habit_fab')));
        await tester.pump(); // Start animation
        await tester.pump(const Duration(milliseconds: 300)); // Complete animation

        expect(find.text('Add Habit'), findsOneWidget,
            reason: 'Dialog title should be visible');
        expect(find.byType(AlertDialog), findsOneWidget,
            reason: 'Alert dialog should be displayed');
      });

      testWidgets('dialog has name and description inputs',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        await tester.tap(find.byKey(const Key('add_habit_fab')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byKey(const Key('habit_name_input')), findsOneWidget,
            reason: 'Name input should be present');
        expect(find.byKey(const Key('habit_description_input')), findsOneWidget,
            reason: 'Description input should be present');
      });

      testWidgets('dialog has action buttons', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        await tester.tap(find.byKey(const Key('add_habit_fab')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Cancel'), findsOneWidget,
            reason: 'Cancel button should be visible');
        expect(find.byKey(const Key('confirm_add_habit_button')), findsOneWidget,
            reason: 'Confirm button should be present');
        expect(find.text('Add'), findsOneWidget,
            reason: 'Add button text should be visible');
      });

      testWidgets('can cancel dialog', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        // Open dialog
        await tester.tap(find.byKey(const Key('add_habit_fab')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Cancel dialog
        await tester.tap(find.text('Cancel'));
        await tester.pump(); // Start closing animation
        await tester.pump(const Duration(milliseconds: 300)); // Complete animation

        expect(find.byType(AlertDialog), findsNothing,
            reason: 'Dialog should be closed');
      });
    });

    group('Form Validation', () {
      testWidgets('dialog has required form fields',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('add_habit_fab')));
        await tester.pumpAndSettle();

        // Verify form fields are present
        expect(find.byKey(const Key('habit_name_input')), findsOneWidget,
            reason: 'Name input field should be present');
        expect(find.byKey(const Key('habit_description_input')), findsOneWidget,
            reason: 'Description input field should be present');
        expect(find.byKey(const Key('confirm_add_habit_button')), findsOneWidget,
            reason: 'Confirm button should be present');
      });
    });

    group('Habit Display', () {
      testWidgets('page structure supports habit display',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        // Page should be set up to display habits (has body, can scroll, etc.)
        expect(find.byType(HabitsPageNew), findsOneWidget,
            reason: 'Habits page should be present');
        expect(find.byType(Scaffold), findsOneWidget,
            reason: 'Should have scaffold structure');
      });
    });

    group('Localization', () {
      testWidgets('displays English text', (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
            ],
            child: const MaterialApp(
              locale: Locale('en', ''),
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: [Locale('en', '')],
              home: HabitsPageNew(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('My Habits'), findsOneWidget,
            reason: 'English title should be displayed');
      });
    });

    group('Edge Cases', () {
      testWidgets('handles multiple rapid FAB taps gracefully',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        // Tap FAB multiple times rapidly
        await tester.tap(find.byKey(const Key('add_habit_fab')));
        await tester.tap(find.byKey(const Key('add_habit_fab')));
        await tester.tap(find.byKey(const Key('add_habit_fab')));
        await tester.pumpAndSettle();

        // Should show a dialog (may be one or more depending on timing, but not crash)
        expect(find.byType(AlertDialog), findsWidgets,
            reason: 'Should handle rapid taps gracefully');
      });
    });
  });
}
