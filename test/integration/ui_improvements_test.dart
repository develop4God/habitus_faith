import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/pages/home_page.dart';
import 'package:habitus_faith/features/habits/data/storage/storage_providers.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/presentation/habits_providers.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// UI improvements smoke tests
/// These verify that key UI features still work
void main() {
  group('UI Improvements - Color Indicators', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'habits': '[]',
        'completions': '{}',
      });
    });

    tearDown(() {
      TestWidgetsFlutterBinding.ensureInitialized()
          .platformDispatcher
          .views
          .first
          .resetPhysicalSize();
      TestWidgetsFlutterBinding.ensureInitialized()
          .platformDispatcher
          .views
          .first
          .resetDevicePixelRatio();
    });

    Future<void> pumpHomePage(WidgetTester tester, List<Habit> habits) async {
      final prefs = await SharedPreferences.getInstance();

      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            habitsStreamProvider.overrideWith((ref) => Stream.value(habits)),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en', '')],
            home: HomePage(),
          ),
        ),
      );

      await tester.pump();
    }

    testWidgets('home page loads with habits', (WidgetTester tester) async {
      final testHabits = [
        Habit(
          id: '1',
          userId: 'test',
          name: 'Test Habit',
          category: HabitCategory.spiritual,
          createdAt: DateTime.now(),
        ),
      ];

      await pumpHomePage(tester, testHabits);

      // Page should load
      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('UI Improvements - Strikethrough Completed Habits', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    });

    tearDown(() {
      TestWidgetsFlutterBinding.ensureInitialized()
          .platformDispatcher
          .views
          .first
          .resetPhysicalSize();
      TestWidgetsFlutterBinding.ensureInitialized()
          .platformDispatcher
          .views
          .first
          .resetDevicePixelRatio();
    });

    Future<void> pumpHomePage(WidgetTester tester, List<Habit> habits) async {
      final prefs = await SharedPreferences.getInstance();

      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            habitsStreamProvider.overrideWith((ref) => Stream.value(habits)),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en', '')],
            home: HomePage(),
          ),
        ),
      );

      await tester.pump();
    }

    testWidgets('completed habits display correctly', (
      WidgetTester tester,
    ) async {
      final testHabits = [
        Habit(
          id: '1',
          userId: 'test',
          name: 'Completed Habit',
          category: HabitCategory.spiritual,
          createdAt: DateTime.now(),
          completedToday: true,
          completionHistory: [DateTime.now()],
        ),
      ];

      await pumpHomePage(tester, testHabits);

      // Should show the habit name
      expect(find.text('Completed Habit'), findsOneWidget);
    });
  });
}
