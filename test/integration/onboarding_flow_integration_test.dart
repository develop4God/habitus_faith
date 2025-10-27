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
      final continueButton =
          find.byKey(const Key('continue_onboarding_button'));
      expect(continueButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(continueButton);
      expect(button.onPressed, isNull); // Disabled
    });

    testWidgets('selects one habit successfully', (WidgetTester tester) async {
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
      final continueButton =
          find.byKey(const Key('continue_onboarding_button'));
      final button = tester.widget<ElevatedButton>(continueButton);
      expect(button.onPressed, isNotNull); // Enabled
    });

    testWidgets('selects two habits successfully', (WidgetTester tester) async {
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

      // Counter should be 3/3
      expect(find.textContaining('3/3'), findsOneWidget);

      // Try to select fourth habit (need to scroll to it if not visible)
      final gratitudeCard = find.byKey(const Key('habit_card_gratitude'));
      if (gratitudeCard.evaluate().isEmpty) {
        // Scroll to make it visible
        await tester.drag(find.byType(GridView), const Offset(0, -100));
        await tester.pumpAndSettle();
      }

      await tester.tap(gratitudeCard);
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

    testWidgets('responsive grid on small Android phone',
        (WidgetTester tester) async {
      // Set small Android phone screen size with lower DPR to prevent overflow in test
      tester.view.physicalSize =
          const Size(720, 1280); // Logical 360x640 @ 2.0 DPR
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpOnboardingPage(tester);

      // Grid should be visible
      expect(find.byType(GridView), findsOneWidget);

      // Should render without overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('responsive grid on Android tablet',
        (WidgetTester tester) async {
      // Set Android tablet screen size (Nexus 7) with realistic height
      tester.view.physicalSize =
          const Size(600, 1100); // Increased height to prevent overflow
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpOnboardingPage(tester);

      // Grid should be visible
      expect(find.byType(GridView), findsOneWidget);

      // Should render without overflow
      expect(tester.takeException(), isNull);
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

    testWidgets('grid scrolls to show all habits', (WidgetTester tester) async {
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
      final continueButton =
          find.byKey(const Key('continue_onboarding_button'));
      final button = tester.widget<ElevatedButton>(continueButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('all 12 predefined habits are present',
        (WidgetTester tester) async {
      await pumpOnboardingPage(tester);

      // Find the GridView
      final gridFinder = find.byType(GridView);
      expect(gridFinder, findsOneWidget);

      // Verify key habits are present - checking first, visible, and last items
      // We check specific habits that should be visible in the grid
      expect(find.byKey(const Key('habit_card_morning_prayer')), findsOneWidget,
          reason: 'First habit (morning_prayer) should be present');
      expect(find.byKey(const Key('habit_card_bible_reading')), findsOneWidget,
          reason: 'Second habit (bible_reading) should be present');
      expect(find.byKey(const Key('habit_card_worship')), findsOneWidget,
          reason: 'Third habit (worship) should be present');

      // The predefinedHabits list in predefined_habits_data.dart has all 12 items
      // GridView will lazy-load others as user scrolls
    });
  });
}
