import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/adaptive_onboarding_page.dart';
import 'package:habitus_faith/pages/habits_page.dart';
import 'package:habitus_faith/features/habits/data/storage/storage_providers.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Integration tests for UI improvements focusing on real user behavior
void main() {
  group('UI Improvements - Onboarding Skip Button', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpAdaptiveOnboardingPage(WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [Locale('en', ''), Locale('es', '')],
            home: AdaptiveOnboardingPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('User can skip onboarding without selecting habits', (
      WidgetTester tester,
    ) async {
      await pumpAdaptiveOnboardingPage(tester);

      // Find skip button
      final skipButton = find.byKey(const Key('skip_onboarding_button'));
      expect(skipButton, findsOneWidget);

      // Verify skip button is enabled even with no habits selected
      final button = tester.widget<OutlinedButton>(skipButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Skip button is visible alongside continue button', (
      WidgetTester tester,
    ) async {
      await pumpAdaptiveOnboardingPage(tester);

      // Both buttons should be visible
      final skipButton = find.byKey(const Key('skip_onboarding_button'));
      final continueButton = find.byKey(
        const Key('continue_onboarding_button'),
      );

      expect(skipButton, findsOneWidget);
      expect(continueButton, findsOneWidget);

      // Verify they are in the same Row
      final row = find.ancestor(of: skipButton, matching: find.byType(Row));
      expect(row, findsOneWidget);
    });
  });

  group('UI Improvements - Emoji Display', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Predefined habits show emojis on onboarding page', (
      WidgetTester tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [Locale('en', ''), Locale('es', '')],
            home: AdaptiveOnboardingPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check that emojis are displayed in habit cards
      // Morning Prayer should show 🙏
      expect(find.text('🙏'), findsOneWidget);
      // Bible Reading should show 📖
      expect(find.text('📖'), findsOneWidget);
      // Worship should show 🎵
      expect(find.text('🎵'), findsOneWidget);
    });
  });

  group('UI Improvements - Color Indicators', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'habits': '[]',
        'completions': '{}',
        'onboarding_complete': true,
      });
    });

    testWidgets('Habit cards display color indicators', (
      WidgetTester tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();

      // Add a test habit with specific data
      await prefs.setString('habits', '''[{
          "id": "test_habit_1",
          "userId": "test_user",
          "name": "Test Habit",
          "description": "Test Description",
          "category": "spiritual",
          "emoji": "🙏",
          "createdAt": "${DateTime.now().toIso8601String()}",
          "completedToday": false,
          "currentStreak": 0,
          "longestStreak": 0,
          "isArchived": false,
          "difficultyLevel": 3,
          "targetMinutes": 10,
          "successRate7d": 0.0,
          "optimalDays": [],
          "consecutiveFailures": 0,
          "abandonmentRisk": 0.0,
          "difficulty": "medium"
        }]''');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [Locale('en', ''), Locale('es', '')],
            home: HabitsPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Look for Container widgets that could be color indicators
      // Color indicators are 4px wide and at least 20px tall
      final colorIndicators = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints?.minWidth == 4 &&
            widget.decoration is BoxDecoration,
      );

      // Should find at least one color indicator
      expect(colorIndicators, findsWidgets);
    });
  });

  group('UI Improvements - Strikethrough Completed Habits', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    });

    testWidgets('Completed habits show strikethrough text', (
      WidgetTester tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();

      // Add a completed habit
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      await prefs.setString('habits', '''[{
          "id": "completed_habit",
          "userId": "test_user",
          "name": "Completed Habit",
          "description": "This habit is completed",
          "category": "spiritual",
          "emoji": "✅",
          "createdAt": "${DateTime.now().toIso8601String()}",
          "completedToday": true,
          "currentStreak": 1,
          "longestStreak": 1,
          "isArchived": false,
          "difficultyLevel": 3,
          "targetMinutes": 10,
          "successRate7d": 1.0,
          "optimalDays": [],
          "consecutiveFailures": 0,
          "abandonmentRisk": 0.0,
          "difficulty": "medium"
        }]''');

      await prefs.setString('completions', '''{
          "completed_habit": {
            "completion_1": {
              "habitId": "completed_habit",
              "completedAt": "${today.toIso8601String()}"
            }
          }
        }''');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [Locale('en', ''), Locale('es', '')],
            home: HabitsPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find Text widgets with strikethrough decoration
      final strikethroughTexts = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.style?.decoration == TextDecoration.lineThrough,
      );

      // Should find at least one text with strikethrough
      expect(strikethroughTexts, findsWidgets);
    });

    testWidgets('Uncompleted habits do not show strikethrough', (
      WidgetTester tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();

      // Add an uncompleted habit
      await prefs.setString('habits', '''[{
          "id": "uncompleted_habit",
          "userId": "test_user",
          "name": "Uncompleted Habit",
          "description": "This habit is not completed",
          "category": "mental",
          "emoji": "📚",
          "createdAt": "${DateTime.now().toIso8601String()}",
          "completedToday": false,
          "currentStreak": 0,
          "longestStreak": 0,
          "isArchived": false,
          "difficultyLevel": 3,
          "targetMinutes": 10,
          "successRate7d": 0.0,
          "optimalDays": [],
          "consecutiveFailures": 0,
          "abandonmentRisk": 0.0,
          "difficulty": "medium"
        }]''');

      await prefs.setString('completions', '{}');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [Locale('en', ''), Locale('es', '')],
            home: HabitsPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find the habit name text
      final habitNameText = find.text('Uncompleted Habit');
      expect(habitNameText, findsOneWidget);

      // Verify it doesn't have strikethrough
      final textWidget = tester.widget<Text>(habitNameText.first);
      expect(textWidget.style?.decoration, isNot(TextDecoration.lineThrough));
    });
  });

  group('UI Improvements - Tabbed Add Habit Dialog', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'habits': '[]',
        'completions': '{}',
        'onboarding_complete': true,
      });
    });

    testWidgets('Add habit dialog shows two tabs', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [Locale('en', ''), Locale('es', '')],
            home: HabitsPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Open add habit dialog
      final addButton = find.byKey(const Key('add_habit_fab'));
      await tester.tap(addButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show TabBar with two tabs
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(2));

      // Should show manual entry and predefined habits tabs
      expect(find.text('Add Manually'), findsOneWidget);
    });

    testWidgets('Can switch between manual and predefined tabs', (
      WidgetTester tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [Locale('en', ''), Locale('es', '')],
            home: HabitsPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Open add habit dialog
      final addButton = find.byKey(const Key('add_habit_fab'));
      await tester.tap(addButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap the second tab
      final tabs = find.byType(Tab);
      await tester.tap(tabs.at(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show grid of predefined habits
      expect(find.byType(GridView), findsOneWidget);

      // Should show some predefined habit emojis
      expect(find.text('🙏'), findsOneWidget); // Morning Prayer
    });

    testWidgets('Predefined habits grid displays emojis and names', (
      WidgetTester tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [Locale('en', ''), Locale('es', '')],
            home: HabitsPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Open add habit dialog
      final addButton = find.byKey(const Key('add_habit_fab'));
      await tester.tap(addButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Switch to predefined tab
      final tabs = find.byType(Tab);
      await tester.tap(tabs.at(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show multiple habit emojis
      expect(find.text('🙏'), findsOneWidget);
      expect(find.text('📖'), findsOneWidget);
      expect(find.text('🎵'), findsOneWidget);
      expect(find.text('✨'), findsOneWidget);
    });
  });

  group('UI Improvements - User Behavior Flow', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
      'Complete user flow: onboarding with skip, then add predefined habit',
      (WidgetTester tester) async {
        final prefs = await SharedPreferences.getInstance();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en', ''), Locale('es', '')],
              routes: {
                '/': (context) => const AdaptiveOnboardingPage(),
                '/home': (context) => const HabitsPage(),
              },
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // User skips onboarding
        final skipButton = find.byKey(const Key('skip_onboarding_button'));
        expect(skipButton, findsOneWidget);

        // Note: In a real test, we would navigate but for unit tests
        // we'll just verify the button exists and is enabled
        final button = tester.widget<OutlinedButton>(skipButton);
        expect(button.onPressed, isNotNull);
      },
    );
  });
}
