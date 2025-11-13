import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/habits/domain/models/display_mode.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/display_mode_provider.dart';
import 'package:habitus_faith/features/habits/data/storage/storage_providers.dart';
import 'package:habitus_faith/pages/settings_page.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// User behavior tests for display mode feature
/// Tests real user interactions and workflows
void main() {
  group('Display Mode User Behavior Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    group('Settings Page Display Mode Switcher', () {
      testWidgets('User can open display mode dialog from settings', (
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
              supportedLocales: [Locale('en', '')],
              home: SettingsPage(),
            ),
          ),
        );
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Find display mode option
        expect(
          find.text('Display Mode'),
          findsOneWidget,
          reason: 'Display Mode setting should be visible',
        );

        // Tap to open dialog
        await tester.tap(find.text('Display Mode'));
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Verify dialog opened
        expect(
          find.text('Compact Mode'),
          findsAtLeast(1),
          reason: 'Dialog should show Compact Mode option',
        );
        expect(
          find.text('Advanced Mode'),
          findsAtLeast(1),
          reason: 'Dialog should show Advanced Mode option',
        );
      });

      testWidgets('User switches from compact to advanced mode', (
        WidgetTester tester,
      ) async {
        final prefs = await SharedPreferences.getInstance();
        // Set initial mode to compact
        await prefs.setString('display_mode', 'compact');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: const MaterialApp(
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: [Locale('en', '')],
              home: SettingsPage(),
            ),
          ),
        );
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Open dialog
        await tester.tap(find.text('Display Mode'));
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Select advanced mode
        await tester.tap(find.text('Advanced Mode'));
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Verify mode was saved
        final savedMode = prefs.getString('display_mode');
        expect(
          savedMode,
          'advanced',
          reason: 'Mode should be saved as advanced',
        );

        // Verify confirmation message
        expect(
          find.textContaining('Display mode updated'),
          findsOneWidget,
          reason: 'Should show confirmation message',
        );
      });

      testWidgets('User switches from advanced to compact mode', (
        WidgetTester tester,
      ) async {
        final prefs = await SharedPreferences.getInstance();
        // Set initial mode to advanced
        await prefs.setString('display_mode', 'advanced');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: const MaterialApp(
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: [Locale('en', '')],
              home: SettingsPage(),
            ),
          ),
        );
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Open dialog
        await tester.tap(find.text('Display Mode'));
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Select compact mode
        await tester.tap(find.text('Compact Mode'));
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Verify mode was saved
        final savedMode = prefs.getString('display_mode');
        expect(savedMode, 'compact', reason: 'Mode should be saved as compact');
      });

      testWidgets('Display mode icon changes based on current mode', (
        WidgetTester tester,
      ) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('display_mode', 'compact');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: const MaterialApp(
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: [Locale('en', '')],
              home: SettingsPage(),
            ),
          ),
        );
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Verify compact mode icon is shown
        final compactIcon = find.byIcon(Icons.check_circle_outline);
        expect(
          compactIcon,
          findsOneWidget,
          reason: 'Should show compact mode icon',
        );

        // Switch to advanced mode
        await tester.tap(find.text('Display Mode'));
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.text('Advanced Mode'));
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Rebuild widget to see updated icon
        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: const MaterialApp(
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: [Locale('en', '')],
              home: SettingsPage(),
            ),
          ),
        );
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Verify advanced mode icon is shown
        final advancedIcon = find.byIcon(Icons.insights);
        expect(
          advancedIcon,
          findsOneWidget,
          reason: 'Should show advanced mode icon',
        );
      });

      testWidgets('User can close dialog without changing mode', (
        WidgetTester tester,
      ) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('display_mode', 'compact');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: const MaterialApp(
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: [Locale('en', '')],
              home: SettingsPage(),
            ),
          ),
        );
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Open dialog
        await tester.tap(find.text('Display Mode'));
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Tap outside dialog or back button
        await tester.tapAt(const Offset(10, 10));
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Verify mode wasn't changed
        final savedMode = prefs.getString('display_mode');
        expect(savedMode, 'compact', reason: 'Mode should remain compact');
      });
    });

    group('Display Mode Provider Behavior', () {
      testWidgets('Provider updates immediately on mode change', (
        WidgetTester tester,
      ) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('display_mode', 'compact');

        DisplayMode? observedMode;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: Consumer(
              builder: (context, ref, child) {
                observedMode = ref.watch(displayModeProvider);
                return const MaterialApp(home: Scaffold(body: Text('Test')));
              },
            ),
          ),
        );
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Verify initial mode
        expect(observedMode, DisplayMode.compact);

        // Change mode via provider
        final container = ProviderScope.containerOf(
          tester.element(find.text('Test')),
        );
        await container
            .read(displayModeProvider.notifier)
            .setDisplayMode(DisplayMode.advanced);
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Verify mode updated
        expect(
          observedMode,
          DisplayMode.advanced,
          reason: 'Provider should update immediately',
        );
      });

      testWidgets('Multiple widgets react to mode changes', (
        WidgetTester tester,
      ) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('display_mode', 'compact');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: Consumer(
              builder: (context, ref, child) {
                final mode = ref.watch(displayModeProvider);
                return MaterialApp(
                  home: Scaffold(
                    body: Column(
                      children: [
                        Text('Widget 1: ${mode.name}'),
                        Text('Widget 2: ${mode.name}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Verify both widgets show compact
        expect(find.text('Widget 1: compact'), findsOneWidget);
        expect(find.text('Widget 2: compact'), findsOneWidget);

        // Change mode
        final container = ProviderScope.containerOf(
          tester.element(find.text('Widget 1: compact')),
        );
        await container
            .read(displayModeProvider.notifier)
            .setDisplayMode(DisplayMode.advanced);
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Verify both widgets updated
        expect(find.text('Widget 1: advanced'), findsOneWidget);
        expect(find.text('Widget 2: advanced'), findsOneWidget);
      });
    });

    group('Security & Injection Tests', () {
      testWidgets('SQL injection attempt in mode storage fails safely', (
        WidgetTester tester,
      ) async {
        final prefs = await SharedPreferences.getInstance();

        // Attempt SQL injection
        await prefs.setString('display_mode', "'; DROP TABLE users; --");

        DisplayMode? loadedMode;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: Consumer(
              builder: (context, ref, child) {
                loadedMode = ref.watch(displayModeProvider);
                return const MaterialApp(home: Scaffold(body: Text('Test')));
              },
            ),
          ),
        );
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Verify it defaults to safe value
        expect(
          loadedMode,
          DisplayMode.compact,
          reason: 'Should default to compact for invalid/malicious input',
        );
      });

      testWidgets('XSS attempt in mode storage fails safely', (
        WidgetTester tester,
      ) async {
        final prefs = await SharedPreferences.getInstance();

        // Attempt XSS injection
        await prefs.setString('display_mode', '<script>alert("xss")</script>');

        DisplayMode? loadedMode;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: Consumer(
              builder: (context, ref, child) {
                loadedMode = ref.watch(displayModeProvider);
                return const MaterialApp(home: Scaffold(body: Text('Test')));
              },
            ),
          ),
        );
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Verify it defaults to safe value
        expect(
          loadedMode,
          DisplayMode.compact,
          reason: 'Should default to compact for XSS attempt',
        );
      });

      testWidgets('Path traversal attempt in mode storage fails safely', (
        WidgetTester tester,
      ) async {
        final prefs = await SharedPreferences.getInstance();

        // Attempt path traversal
        await prefs.setString('display_mode', '../../etc/passwd');

        DisplayMode? loadedMode;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: Consumer(
              builder: (context, ref, child) {
                loadedMode = ref.watch(displayModeProvider);
                return const MaterialApp(home: Scaffold(body: Text('Test')));
              },
            ),
          ),
        );
        await tester.pump(); await tester.pump(const Duration(milliseconds: 100));

        // Verify it defaults to safe value
        expect(
          loadedMode,
          DisplayMode.compact,
          reason: 'Should default to compact for path traversal attempt',
        );
      });
    });
  });
}
