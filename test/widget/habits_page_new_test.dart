import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/pages/habits_page_new.dart';
import 'package:habitus_faith/features/habits/data/storage/storage_providers.dart';
import 'package:habitus_faith/features/habits/presentation/widgets/habit_completion_card.dart';
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

    group('Initial Rendering', () {
      testWidgets('renders without crashing', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        expect(find.byType(HabitsPageNew), findsOneWidget,
            reason: 'HabitsPageNew should render');
      });

      testWidgets('shows app bar with title', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        expect(find.text('My Habits'), findsOneWidget,
            reason: 'App bar should display title');
        expect(find.byType(AppBar), findsOneWidget,
            reason: 'Should have an app bar');
      });

      testWidgets('has floating action button', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        expect(find.byKey(const Key('add_habit_fab')), findsOneWidget,
            reason: 'FAB should be present');
        expect(find.byType(FloatingActionButton), findsOneWidget,
            reason: 'Should have exactly one FAB');
        expect(find.byIcon(Icons.add), findsOneWidget,
            reason: 'FAB should have add icon');
      });
    });

    group('Empty State', () {
      testWidgets('eventually shows empty state when no habits exist',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        
        // Wait for the stream to process
        await tester.pump(); // Initial build
        await tester.pump(const Duration(milliseconds: 100)); // Let streams initialize
        await tester.pump(const Duration(milliseconds: 500)); // Additional wait
        
        // Empty state icon should eventually appear (may take a few frames)
        final iconFinder = find.byIcon(Icons.auto_awesome);
        if (iconFinder.evaluate().isEmpty) {
          // If not found yet, wait a bit more
          await tester.pump(const Duration(seconds: 1));
        }
        
        // Verify empty state (using flexible matching)
        expect(iconFinder, findsWidgets,
            reason: 'Empty state icon should be present');
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
      testWidgets('requires both name and description to create habit',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        await tester.tap(find.byKey(const Key('add_habit_fab')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Try to add with only description (no name)
        await tester.enterText(
            find.byKey(const Key('habit_description_input')), 'Test description');
        await tester.pump();
        
        await tester.tap(find.byKey(const Key('confirm_add_habit_button')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Dialog should still be open (validation failed)
        expect(find.byType(AlertDialog), findsOneWidget,
            reason: 'Dialog should remain open when validation fails');
      });

      testWidgets('creates habit successfully with valid inputs',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Open dialog
        await tester.tap(find.byKey(const Key('add_habit_fab')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Fill form with valid data
        await tester.enterText(
            find.byKey(const Key('habit_name_input')), 'Morning Prayer');
        await tester.pump();
        await tester.enterText(
            find.byKey(const Key('habit_description_input')), 'Pray each morning');
        await tester.pump();
        
        // Submit form
        await tester.tap(find.byKey(const Key('confirm_add_habit_button')));
        await tester.pump(); // Start submission
        await tester.pump(const Duration(milliseconds: 500)); // Wait for async operation

        // Dialog should close
        expect(find.byType(AlertDialog), findsNothing,
            reason: 'Dialog should close after successful creation');
        
        // Habit should be in the list
        expect(find.text('Morning Prayer'), findsOneWidget,
            reason: 'Created habit should be displayed');
      });
    });

    group('Habit Display', () {
      testWidgets('displays habit cards after creation',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Create a habit
        await tester.tap(find.byKey(const Key('add_habit_fab')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.enterText(
            find.byKey(const Key('habit_name_input')), 'Exercise');
        await tester.pump();
        await tester.enterText(
            find.byKey(const Key('habit_description_input')), 'Daily workout');
        await tester.pump();
        
        await tester.tap(find.byKey(const Key('confirm_add_habit_button')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Should display habit card
        expect(find.byType(HabitCompletionCard), findsOneWidget,
            reason: 'Habit card should be displayed');
        expect(find.text('Exercise'), findsOneWidget,
            reason: 'Habit name should be visible on card');
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

        expect(find.text('My Habits'), findsOneWidget,
            reason: 'English title should be displayed');
      });
    });

    group('Edge Cases', () {
      testWidgets('handles multiple rapid FAB taps gracefully',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        // Tap FAB multiple times rapidly
        await tester.tap(find.byKey(const Key('add_habit_fab')));
        await tester.tap(find.byKey(const Key('add_habit_fab')));
        await tester.tap(find.byKey(const Key('add_habit_fab')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Should only show one dialog
        expect(find.byType(AlertDialog), findsOneWidget,
            reason: 'Should handle rapid taps without duplicate dialogs');
      });

      testWidgets('handles empty string inputs', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        await tester.tap(find.byKey(const Key('add_habit_fab')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Enter empty strings
        await tester.enterText(find.byKey(const Key('habit_name_input')), '');
        await tester.enterText(find.byKey(const Key('habit_description_input')), '');
        await tester.pump();
        
        await tester.tap(find.byKey(const Key('confirm_add_habit_button')));
        await tester.pump();

        // Dialog should remain open
        expect(find.byType(AlertDialog), findsOneWidget,
            reason: 'Should not accept empty inputs');
      });
    });
  });
}
