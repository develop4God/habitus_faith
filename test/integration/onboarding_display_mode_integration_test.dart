import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/display_mode_selection_page.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/onboarding_page.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/display_mode_provider.dart';
import 'package:habitus_faith/features/habits/data/storage/storage_providers.dart';
import 'package:habitus_faith/features/habits/domain/models/display_mode.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Integration tests for complete onboarding flow with display mode selection
/// Validates the entire user journey from display mode selection to habit selection
void main() {
  group('Onboarding Flow Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Complete onboarding flow: Display mode -> Habit selection', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', '')],
            routes: {'/onboarding': (context) => const OnboardingPage()},
            home: const DisplayModeSelectionPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Verify display mode selection page is shown
      expect(
        find.text('Choose Your Experience'),
        findsOneWidget,
        reason: 'Display mode selection page should be shown first',
      );

      // Step 2: Select compact mode
      await tester.tap(find.byKey(const Key('compact_mode_card')));
      await tester.pumpAndSettle();

      // Step 3: Tap select mode button
      await tester.tap(find.byKey(const Key('select_mode_button')));
      await tester.pumpAndSettle();

      // Step 4: Verify navigation to onboarding page
      expect(
        find.text('Welcome to Habitus Faith'),
        findsOneWidget,
        reason: 'Should navigate to onboarding page after mode selection',
      );

      // Step 5: Verify display mode was persisted
      final savedMode = prefs.getString('display_mode');
      expect(savedMode, 'compact', reason: 'Display mode should be saved');
    });

    testWidgets('Onboarding flow: Advanced mode selection', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', '')],
            routes: {'/onboarding': (context) => const OnboardingPage()},
            home: const DisplayModeSelectionPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to make advanced mode card visible
      await tester.dragUntilVisible(
        find.byKey(const Key('advanced_mode_card')),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      // Select advanced mode
      await tester.tap(find.byKey(const Key('advanced_mode_card')));
      await tester.pumpAndSettle();

      // Tap select mode button
      await tester.tap(find.byKey(const Key('select_mode_button')));
      await tester.pumpAndSettle();

      // Verify navigation to onboarding page
      expect(
        find.text('Welcome to Habitus Faith'),
        findsOneWidget,
        reason: 'Should navigate to onboarding page after mode selection',
      );

      // Verify display mode was persisted
      final savedMode = prefs.getString('display_mode');
      expect(savedMode, 'advanced', reason: 'Advanced mode should be saved');
    });

    testWidgets('Display mode provider correctly loads persisted mode', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({'display_mode': 'advanced'});
      final prefs = await SharedPreferences.getInstance();

      DisplayMode? loadedMode;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: Consumer(
            builder: (context, ref, child) {
              loadedMode = ref.watch(displayModeProvider);
              return const MaterialApp(
                home: Scaffold(body: Center(child: Text('Test'))),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        loadedMode,
        DisplayMode.advanced,
        reason: 'Provider should load persisted advanced mode',
      );
    });

    testWidgets('Display mode provider defaults to compact when not set', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      DisplayMode? loadedMode;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: Consumer(
            builder: (context, ref, child) {
              loadedMode = ref.watch(displayModeProvider);
              return const MaterialApp(
                home: Scaffold(body: Center(child: Text('Test'))),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        loadedMode,
        DisplayMode.compact,
        reason: 'Provider should default to compact mode when not set',
      );
    });

    testWidgets('displayModeSelectedProvider returns true when mode is set', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({'display_mode': 'compact'});
      final prefs = await SharedPreferences.getInstance();

      bool? isSelected;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: Consumer(
            builder: (context, ref, child) {
              isSelected = ref.watch(displayModeSelectedProvider);
              return const MaterialApp(
                home: Scaffold(body: Center(child: Text('Test'))),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        isSelected,
        true,
        reason:
            'displayModeSelectedProvider should return true when mode is set',
      );
    });

    testWidgets(
      'displayModeSelectedProvider returns false when mode is not set',
      (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        bool? isSelected;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: Consumer(
              builder: (context, ref, child) {
                isSelected = ref.watch(displayModeSelectedProvider);
                return const MaterialApp(
                  home: Scaffold(body: Center(child: Text('Test'))),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          isSelected,
          false,
          reason:
              'displayModeSelectedProvider should return false when mode is not set',
        );
      },
    );

    testWidgets('User can change mode selection before confirming', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', '')],
            routes: {'/onboarding': (context) => const OnboardingPage()},
            home: const DisplayModeSelectionPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // First select compact mode
      await tester.tap(find.byKey(const Key('compact_mode_card')));
      await tester.pumpAndSettle();

      // Scroll to make advanced mode card visible
      await tester.dragUntilVisible(
        find.byKey(const Key('advanced_mode_card')),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      // Change to advanced mode
      await tester.tap(find.byKey(const Key('advanced_mode_card')));
      await tester.pumpAndSettle();

      // Confirm selection
      await tester.tap(find.byKey(const Key('select_mode_button')));
      await tester.pumpAndSettle();

      // Verify final selection was advanced
      final savedMode = prefs.getString('display_mode');
      expect(
        savedMode,
        'advanced',
        reason: 'Final selection should be advanced mode',
      );
    });

    testWidgets('Cannot proceed without selecting a mode', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', '')],
            routes: {'/onboarding': (context) => const OnboardingPage()},
            home: const DisplayModeSelectionPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Try to tap the button without selecting a mode
      final selectButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('select_mode_button')),
      );

      expect(
        selectButton.enabled,
        false,
        reason: 'Button should be disabled without mode selection',
      );

      // Verify no mode was saved
      final savedMode = prefs.getString('display_mode');
      expect(
        savedMode,
        isNull,
        reason: 'No mode should be saved without selection',
      );
    });
  });
}
