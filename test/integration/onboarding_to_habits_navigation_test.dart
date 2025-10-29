import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/onboarding_page.dart';
import 'package:habitus_faith/pages/home_page.dart';
import 'package:habitus_faith/pages/habits_page.dart';
import 'package:habitus_faith/features/habits/data/storage/storage_providers.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('Onboarding to Habits Page Navigation Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
        'onboarding flow to habits page - no blank spinner, habits display correctly',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();

      // Build app with navigation support
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('es', ''),
            ],
            routes: {
              '/': (context) => const OnboardingPage(),
              '/home': (context) => const HomePage(),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Step 1: Verify onboarding page loads
      expect(find.text('Welcome! Let\'s set up your habits'),
          findsOneWidget); // Adjusted to exact text
      expect(find.textContaining('0/3'), findsOneWidget);

      // Step 2: Select 3 habits (simulating real user behavior)
      await tester.tap(find.byKey(const Key('habit_card_morning_prayer')));
      await tester.pumpAndSettle();
      expect(find.textContaining('1/3'), findsOneWidget);

      await tester.tap(find.byKey(const Key('habit_card_bible_reading')));
      await tester.pumpAndSettle();
      expect(find.textContaining('2/3'), findsOneWidget);

      await tester.tap(find.byKey(const Key('habit_card_gratitude')));
      await tester.pumpAndSettle();
      expect(find.textContaining('3/3'), findsOneWidget);

      // Step 3: Tap continue button
      final continueButton =
          find.byKey(const Key('continue_onboarding_button'));
      expect(continueButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(continueButton);
      expect(button.onPressed, isNotNull); // Should be enabled

      await tester.tap(continueButton);

      // Pump frames to handle async navigation
      await tester.pump(); // Start async operation
      await tester.pump(const Duration(milliseconds: 100)); // Processing
      await tester
          .pump(const Duration(milliseconds: 500)); // Allow time for navigation

      // Step 4: Verify navigation to HomePage occurred
      expect(find.byType(HomePage), findsOneWidget);

      // Step 5: Verify we're on the Habits tab (index 0) by default
      expect(find.byType(HabitsPage), findsOneWidget);

      // Step 6: CRITICAL - Verify NO loading spinner is visible
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Step 7: Verify habits page displays correctly (not blank)
      // Should show FAB button
      expect(find.byKey(const Key('add_habit_fab')), findsOneWidget);

      // Should show either empty state or habits list
      // Since we just created 3 habits, we should see habit cards
      await tester.pumpAndSettle(
          const Duration(seconds: 2)); // Allow time for habit loading

      // Verify NO spinner after settling
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Verify the page is not blank - should have content
      expect(find.byType(HabitsPage), findsOneWidget);
    });

    testWidgets('direct navigation to habits page - no blank spinner',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();

      // Simulate user already completed onboarding (has habits)
      await prefs.setString('habits',
          '[{"id":"1","name":"Morning Prayer","emoji":"🙏","description":"Start day with prayer","color":4294198070,"createdAt":"2024-01-01T00:00:00.000"}]');

      // Build app starting directly at HomePage
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en', ''),
              Locale('es', ''),
            ],
            home: HomePage(),
          ),
        ),
      );

      // Initial pump
      await tester.pump();

      // CRITICAL: Verify page loads without getting stuck on spinner
      // After initial frame, there should be no infinite spinner
      await tester.pump(const Duration(milliseconds: 100));

      // Verify HomePage is visible
      expect(find.byType(HomePage), findsOneWidget);

      // Verify HabitsPage is visible (tab 0 is selected by default)
      expect(find.byType(HabitsPage), findsOneWidget);

      // Wait for stream to emit habits
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // CRITICAL: No loading spinner should be visible now
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Verify FAB is visible (page is not blank)
      expect(find.byKey(const Key('add_habit_fab')), findsOneWidget);

      // Verify habit card is visible
      expect(find.textContaining('Morning Prayer'), findsOneWidget);
    });

    testWidgets('habits page with no habits - shows empty state, no spinner',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      // No habits in storage

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en', ''),
              Locale('es', ''),
            ],
            home: HomePage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Wait for stream initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify HabitsPage is visible
      expect(find.byType(HabitsPage), findsOneWidget);

      // CRITICAL: No loading spinner
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Verify FAB is visible
      expect(find.byKey(const Key('add_habit_fab')), findsOneWidget);

      // Should show empty state message
      expect(
          find.textContaining('No tienes hábitos'), findsOneWidget); // Spanish
    });
  });
}
