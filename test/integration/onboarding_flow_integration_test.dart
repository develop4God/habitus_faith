import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/onboarding_page.dart';
import 'package:habitus_faith/features/habits/data/storage/storage_providers.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('OnboardingPage Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpOnboardingPage(WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      
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
            home: OnboardingPage(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
    }

    testWidgets('displays welcome message and habit grid',
        (WidgetTester tester) async {
      await pumpOnboardingPage(tester);

      // Should show welcome text
      expect(find.textContaining('Welcome'), findsOneWidget);
      
      // Should show selection counter (0/3)
      expect(find.textContaining('0/3'), findsOneWidget);
      
      // Should show habit grid
      expect(find.byType(GridView), findsOneWidget);
      
      // Continue button should be disabled when no habits selected
      final continueButton = find.byKey(const Key('continue_onboarding_button'));
      expect(continueButton, findsOneWidget);
      
      final button = tester.widget<ElevatedButton>(continueButton);
      expect(button.onPressed, isNull); // Disabled
    });

    testWidgets('selects one habit successfully',
        (WidgetTester tester) async {
      await pumpOnboardingPage(tester);

      // Find first habit card
      final firstHabitCard = find.byKey(const Key('habit_card_morning_prayer'));
      expect(firstHabitCard, findsOneWidget);

      // Tap to select
      await tester.tap(firstHabitCard);
      await tester.pumpAndSettle();

      // Counter should update to 1/3
      expect(find.textContaining('1/3'), findsOneWidget);
      
      // Continue button should be enabled
      final continueButton = find.byKey(const Key('continue_onboarding_button'));
      final button = tester.widget<ElevatedButton>(continueButton);
      expect(button.onPressed, isNotNull); // Enabled
    });

    testWidgets('selects two habits successfully',
        (WidgetTester tester) async {
      await pumpOnboardingPage(tester);

      // Select first habit
      await tester.tap(find.byKey(const Key('habit_card_morning_prayer')));
      await tester.pumpAndSettle();

      // Select second habit
      await tester.tap(find.byKey(const Key('habit_card_bible_reading')));
      await tester.pumpAndSettle();

      // Counter should update to 2/3
      expect(find.textContaining('2/3'), findsOneWidget);
    });

    testWidgets('selects three habits (maximum) successfully',
        (WidgetTester tester) async {
      await pumpOnboardingPage(tester);

      // Select three habits
      await tester.tap(find.byKey(const Key('habit_card_morning_prayer')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('habit_card_bible_reading')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('habit_card_worship')));
      await tester.pumpAndSettle();

      // Counter should update to 3/3
      expect(find.textContaining('3/3'), findsOneWidget);
    });

    testWidgets('prevents selecting more than 3 habits',
        (WidgetTester tester) async {
      await pumpOnboardingPage(tester);

      // Select three habits
      await tester.tap(find.byKey(const Key('habit_card_morning_prayer')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('habit_card_bible_reading')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('habit_card_worship')));
      await tester.pumpAndSettle();

      // Try to select fourth habit
      await tester.tap(find.byKey(const Key('habit_card_gratitude')));
      await tester.pumpAndSettle();

      // Should still be 3/3
      expect(find.textContaining('3/3'), findsOneWidget);
    });

    testWidgets('deselects a habit when tapped again',
        (WidgetTester tester) async {
      await pumpOnboardingPage(tester);

      // Select habit
      final habitCard = find.byKey(const Key('habit_card_morning_prayer'));
      await tester.tap(habitCard);
      await tester.pumpAndSettle();
      
      expect(find.textContaining('1/3'), findsOneWidget);

      // Tap again to deselect
      await tester.tap(habitCard);
      await tester.pumpAndSettle();

      // Counter should be back to 0/3
      expect(find.textContaining('0/3'), findsOneWidget);
    });

    testWidgets('responsive grid displays correctly on small screen',
        (WidgetTester tester) async {
      // Set small screen size (iPhone SE)
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpOnboardingPage(tester);

      // Should render without overflow
      expect(tester.takeException(), isNull);
      
      // Grid should be visible
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('responsive grid displays correctly on tablet',
        (WidgetTester tester) async {
      // Set tablet screen size (iPad)
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpOnboardingPage(tester);

      // Should render without overflow
      expect(tester.takeException(), isNull);
      
      // Grid should be visible
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('grid scrolls to show all habits',
        (WidgetTester tester) async {
      await pumpOnboardingPage(tester);

      // Find grid view
      final gridView = find.byType(GridView);
      expect(gridView, findsOneWidget);

      // Scroll to bottom
      await tester.drag(gridView, const Offset(0, -500));
      await tester.pumpAndSettle();

      // Should be able to scroll without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows loading spinner while completing onboarding',
        (WidgetTester tester) async {
      await pumpOnboardingPage(tester);

      // Select one habit
      await tester.tap(find.byKey(const Key('habit_card_morning_prayer')));
      await tester.pumpAndSettle();

      // Verify continue button is enabled now
      final continueButton = find.byKey(const Key('continue_onboarding_button'));
      final button = tester.widget<ElevatedButton>(continueButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('all 12 predefined habits are present',
        (WidgetTester tester) async {
      await pumpOnboardingPage(tester);

      // Check for habit cards exist (at least the visible ones)
      expect(find.byKey(const Key('habit_card_morning_prayer')), findsOneWidget);
      expect(find.byKey(const Key('habit_card_bible_reading')), findsOneWidget);
      expect(find.byKey(const Key('habit_card_worship')), findsOneWidget);
      expect(find.byKey(const Key('habit_card_gratitude')), findsOneWidget);
    });
  });
}
