import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/onboarding_page.dart';
import 'package:habitus_faith/features/habits/data/storage/storage_providers.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// High-quality widget tests for OnboardingPage
/// Focus: Real user flows, selection logic, edge cases
void main() {
  group('OnboardingPage Widget Tests', () {
    setUp(() async {
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
          home: const OnboardingPage(),
        ),
      );
    }

    group('Initial Rendering', () {
      testWidgets('renders without crashing', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        expect(find.byType(OnboardingPage), findsOneWidget,
            reason: 'OnboardingPage should render');
      });

      testWidgets('shows welcome title', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        expect(find.text('Welcome to Habitus Faith'), findsOneWidget,
            reason: 'Welcome title should be displayed');
      });

      testWidgets('shows selection instruction text', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        expect(find.textContaining('Select up to 3 habits'), findsOneWidget,
            reason: 'Instruction text should guide user');
      });

      testWidgets('shows habit counter starting at 0/3', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        expect(find.textContaining('0/3'), findsOneWidget,
            reason: 'Counter should start at 0/3');
      });

      testWidgets('displays 12 predefined habits', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        // Check for habit cards (12 predefined habits)
        final habitCards = find.byType(Card);
        expect(habitCards.evaluate().length, greaterThanOrEqualTo(12),
            reason: 'Should display all 12 predefined habits');
      });

      testWidgets('has continue button at bottom', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        expect(find.byKey(const Key('continue_onboarding_button')), findsOneWidget,
            reason: 'Continue button should be present');
        expect(find.widgetWithText(ElevatedButton, 'Continue'), findsOneWidget,
            reason: 'Continue button should have correct text');
      });
    });

    group('Habit Selection', () {
      testWidgets('can select a single habit', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        // Tap first habit card
        final firstHabitCard = find.byKey(const Key('habit_card_morning_prayer'));
        expect(firstHabitCard, findsOneWidget,
            reason: 'Morning Prayer habit card should exist');

        await tester.tap(firstHabitCard);
        await tester.pump();

        // Counter should update
        expect(find.textContaining('1/3'), findsOneWidget,
            reason: 'Counter should show 1 selected habit');
      });

      testWidgets('can select up to 3 habits', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        // Select 3 different habits by scrolling and tapping
        final scrollable = find.byType(GridView);
        await tester.tap(find.byKey(const Key('habit_card_morning_prayer')));
        await tester.pump();
        
        await tester.tap(find.byKey(const Key('habit_card_bible_reading')));
        await tester.pump();
        
        // Scroll to make worship visible if needed
        await tester.drag(scrollable, const Offset(0, -200));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byKey(const Key('habit_card_worship')));
        await tester.pump();

        // Counter should show 3/3
        expect(find.textContaining('3/3'), findsOneWidget,
            reason: 'Counter should show 3 selected habits');
      });

      testWidgets('can deselect a selected habit', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        // Select a habit
        final habitCard = find.byKey(const Key('habit_card_morning_prayer'));
        await tester.tap(habitCard);
        await tester.pump();

        expect(find.textContaining('1/3'), findsOneWidget,
            reason: 'Should show 1 selected');

        // Deselect the same habit
        await tester.tap(habitCard);
        await tester.pump();

        expect(find.textContaining('0/3'), findsOneWidget,
            reason: 'Should return to 0 selected after deselection');
      });

      testWidgets('shows snackbar when trying to select more than 3 habits',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        final scrollable = find.byType(GridView);

        // Select 3 habits first
        await tester.tap(find.byKey(const Key('habit_card_morning_prayer')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('habit_card_bible_reading')));
        await tester.pump();
        
        // Scroll to find worship
        await tester.drag(scrollable, const Offset(0, -200));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byKey(const Key('habit_card_worship')));
        await tester.pump();

        // Scroll to find exercise
        await tester.drag(scrollable, const Offset(0, -200));
        await tester.pumpAndSettle();

        // Try to select 4th habit
        await tester.tap(find.byKey(const Key('habit_card_exercise')));
        await tester.pump(); // Trigger snackbar

        // Snackbar should appear with error message
        expect(find.byType(SnackBar), findsOneWidget,
            reason: 'Snackbar should appear when limit reached');

        // Counter should still be 3/3
        expect(find.textContaining('3/3'), findsOneWidget,
            reason: 'Counter should remain at 3/3');
      });
    });

    group('Visual Feedback', () {
      testWidgets('selected habit shows visual indicator',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        // Select a habit
        await tester.tap(find.byKey(const Key('habit_card_morning_prayer')));
        await tester.pump();

        // Visual indicator should be present (check icon in circle)
        expect(find.byIcon(Icons.check), findsWidgets,
            reason: 'Selected habit should show check icon');
      });

      testWidgets('counter changes color when 3 habits selected',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        final scrollable = find.byType(GridView);

        // Select 3 habits
        await tester.tap(find.byKey(const Key('habit_card_morning_prayer')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('habit_card_bible_reading')));
        await tester.pump();
        
        // Scroll to find worship
        await tester.drag(scrollable, const Offset(0, -200));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byKey(const Key('habit_card_worship')));
        await tester.pump();

        // Scroll back to top to see counter
        await tester.drag(scrollable, const Offset(0, 200));
        await tester.pumpAndSettle();

        // Find the counter text widget
        final counterFinder = find.textContaining('3/3');
        expect(counterFinder, findsOneWidget,
            reason: 'Counter should display 3/3');
        
        final counterWidget = tester.widget<Text>(counterFinder);
        // Color should be green (0xff10b981) when 3 selected
        expect(counterWidget.style?.color, const Color(0xff10b981),
            reason: 'Counter should be green when limit reached');
      });
    });

    group('Continue Button', () {
      testWidgets('continue button is disabled when no habits selected',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        final continueButton = tester.widget<ElevatedButton>(
            find.byKey(const Key('continue_onboarding_button')));
        
        expect(continueButton.enabled, false,
            reason: 'Continue button should be disabled with no selection');
      });

      testWidgets('continue button is enabled when habits selected',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        // Select one habit
        await tester.tap(find.byKey(const Key('habit_card_morning_prayer')));
        await tester.pump();

        final continueButton = tester.widget<ElevatedButton>(
            find.byKey(const Key('continue_onboarding_button')));
        
        expect(continueButton.enabled, true,
            reason: 'Continue button should be enabled with at least 1 habit');
      });
    });

    group('Edge Cases', () {
      testWidgets('handles rapid selection/deselection',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        final habitCard = find.byKey(const Key('habit_card_morning_prayer'));

        // Rapid taps
        await tester.tap(habitCard);
        await tester.tap(habitCard);
        await tester.tap(habitCard);
        await tester.pump();

        // Should handle gracefully and show consistent state
        final counterText = tester.widget<Text>(find.textContaining('/3')).data!;
        expect(counterText, matches(r'^[0-3]/3'),
            reason: 'Counter should show valid state (0-3)');
      });

      testWidgets('maintains selection state across rebuilds',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pump();

        // Select habits
        await tester.tap(find.byKey(const Key('habit_card_morning_prayer')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('habit_card_bible_reading')));
        await tester.pump();

        expect(find.textContaining('2/3'), findsOneWidget);

        // Trigger rebuild by scrolling
        await tester.drag(find.byType(GridView), const Offset(0, -100));
        await tester.pump();

        // Selection should persist
        expect(find.textContaining('2/3'), findsOneWidget,
            reason: 'Selection should persist across rebuilds');
      });
    });

    group('Localization', () {
      testWidgets('displays English text correctly', (WidgetTester tester) async {
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
              home: const OnboardingPage(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Welcome to Habitus Faith'), findsOneWidget,
            reason: 'English welcome text should be displayed');
        expect(find.text('Continue'), findsOneWidget,
            reason: 'English button text should be displayed');
      });
    });
  });
}
