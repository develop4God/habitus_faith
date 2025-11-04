import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/display_mode_selection_page.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/display_mode_provider.dart';
import 'package:habitus_faith/features/habits/data/storage/storage_providers.dart';
import 'package:habitus_faith/features/habits/domain/models/display_mode.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Comprehensive widget tests for DisplayModeSelectionPage
/// Focus: Real user interactions, mode selection, state persistence, accessibility
void main() {
  group('DisplayModeSelectionPage Widget Tests', () {
    setUp(() async {
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
          home: DisplayModeSelectionPage(),
        ),
      );
    }

    group('Initial Rendering', () {
      testWidgets('renders without crashing', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        expect(find.byType(DisplayModeSelectionPage), findsOneWidget,
            reason: 'DisplayModeSelectionPage should render');
      });

      testWidgets('shows title "Choose Your Experience"',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('choose_experience_title')), findsOneWidget,
            reason: 'Title should be displayed');
        expect(find.text('Choose Your Experience'), findsOneWidget,
            reason: 'Title text should be correct');
      });

      testWidgets('shows description text', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        expect(find.text('Select how you want to use Habitus Faith'),
            findsOneWidget,
            reason: 'Description text should guide user');
      });

      testWidgets('displays both Compact and Advanced mode cards',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('compact_mode_card')), findsOneWidget,
            reason: 'Simple mode card should be displayed');
        expect(find.byKey(const Key('advanced_mode_card')), findsOneWidget,
            reason: 'Advanced mode card should be displayed');
      });

      testWidgets('shows "change anytime" message',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('change_anytime_text')), findsOneWidget,
            reason: 'Change anytime message should be displayed');
        expect(find.textContaining('You can change this setting anytime'),
            findsOneWidget,
            reason: 'Message should inform users about flexibility');
      });

      testWidgets('has select mode button at bottom',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('select_mode_button')), findsOneWidget,
            reason: 'Select mode button should be present');
        expect(
            find.widgetWithText(ElevatedButton, 'Select Mode'), findsOneWidget,
            reason: 'Button should have correct text');
      });
    });

    group('Mode Selection', () {
      testWidgets('select mode button is initially disabled',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        final selectButton = tester.widget<ElevatedButton>(
            find.byKey(const Key('select_mode_button')));

        expect(selectButton.enabled, false,
            reason: 'Button should be disabled when no mode selected');
      });

      testWidgets('tapping compact mode card selects compact mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        // Tap on compact mode card
        await tester.tap(find.byKey(const Key('compact_mode_card')));
        await tester.pumpAndSettle();

        final selectButton = tester.widget<ElevatedButton>(
            find.byKey(const Key('select_mode_button')));

        expect(selectButton.enabled, true,
            reason: 'Button should be enabled after selection');
      });

      testWidgets('tapping advanced mode card selects advanced mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        // Scroll to make advanced mode card visible
        await tester.dragUntilVisible(
          find.byKey(const Key('advanced_mode_card')),
          find.byType(SingleChildScrollView),
          const Offset(0, -50),
        );
        await tester.pumpAndSettle();

        // Tap on advanced mode card
        await tester.tap(find.byKey(const Key('advanced_mode_card')));
        await tester.pumpAndSettle();

        final selectButton = tester.widget<ElevatedButton>(
            find.byKey(const Key('select_mode_button')));

        expect(selectButton.enabled, true,
            reason: 'Button should be enabled after selection');
      });

      testWidgets('can switch between modes before confirming',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
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

        // Then select advanced mode
        await tester.tap(find.byKey(const Key('advanced_mode_card')));
        await tester.pumpAndSettle();

        final selectButton = tester.widget<ElevatedButton>(
            find.byKey(const Key('select_mode_button')));

        expect(selectButton.enabled, true,
            reason: 'Button should remain enabled after mode switch');
      });
    });

    group('Visual Feedback', () {
      testWidgets('compact mode card shows correct title and description',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        expect(find.text('Compact Mode'), findsOneWidget,
            reason: 'Simple mode title should be displayed');
        expect(find.text('Essential features for daily habit tracking'),
            findsOneWidget,
            reason: 'Simple mode description should be displayed');
      });

      testWidgets('advanced mode card shows correct title and description',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        expect(find.text('Advanced Mode'), findsOneWidget,
            reason: 'Advanced mode title should be displayed');
        expect(
            find.text('Full-featured experience with insights and analytics'),
            findsOneWidget,
            reason: 'Advanced mode description should be displayed');
      });

      testWidgets('compact mode shows all three features',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        expect(find.text('Clean, minimalist interface'), findsOneWidget,
            reason: 'Simple mode feature 1 should be displayed');
        expect(find.text('Quick habit tracking'), findsOneWidget,
            reason: 'Simple mode feature 2 should be displayed');
        expect(find.text('Basic statistics'), findsOneWidget,
            reason: 'Simple mode feature 3 should be displayed');
      });

      testWidgets('advanced mode shows all three features',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        expect(find.text('Detailed habit analytics'), findsOneWidget,
            reason: 'Advanced mode feature 1 should be displayed');
        expect(find.text('AI-powered insights'), findsOneWidget,
            reason: 'Advanced mode feature 2 should be displayed');
        expect(find.text('Advanced customization'), findsOneWidget,
            reason: 'Advanced mode feature 3 should be displayed');
      });

      testWidgets('page is scrollable', (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        // Find the SingleChildScrollView
        final scrollView = find.byType(SingleChildScrollView);
        expect(scrollView, findsOneWidget,
            reason: 'Page should have scrollable content');

        // Try scrolling
        await tester.drag(scrollView, const Offset(0, -100));
        await tester.pumpAndSettle();

        // Should still be able to see the title
        expect(find.text('Choose Your Experience'), findsOneWidget,
            reason: 'Title should remain visible after scrolling');
      });
    });

    group('State Persistence', () {
      testWidgets('selecting compact mode persists to SharedPreferences',
          (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

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
              supportedLocales: const [Locale('en', '')],
              routes: {
                '/onboarding': (context) => const Scaffold(
                      body: Center(child: Text('Onboarding Page')),
                    ),
              },
              home: const DisplayModeSelectionPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Select compact mode
        await tester.tap(find.byKey(const Key('compact_mode_card')));
        await tester.pumpAndSettle();

        // Tap select button
        await tester.tap(find.byKey(const Key('select_mode_button')));
        await tester.pump();

        // Verify that display mode was saved
        final savedMode = prefs.getString('display_mode');
        expect(savedMode, 'compact',
            reason: 'Simple mode should be saved to preferences');
      });

      testWidgets('selecting advanced mode persists to SharedPreferences',
          (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

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
              supportedLocales: const [Locale('en', '')],
              routes: {
                '/onboarding': (context) => const Scaffold(
                      body: Center(child: Text('Onboarding Page')),
                    ),
              },
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

        // Tap select button
        await tester.tap(find.byKey(const Key('select_mode_button')));
        await tester.pump();

        // Verify that display mode was saved
        final savedMode = prefs.getString('display_mode');
        expect(savedMode, 'advanced',
            reason: 'Advanced mode should be saved to preferences');
      });
    });

    group('Accessibility', () {
      testWidgets('mode cards have semantic labels',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        // Find semantics for compact mode card
        final simpleModeSemantics =
            tester.getSemantics(find.byKey(const Key('compact_mode_card')));
        expect(simpleModeSemantics.label, isNotEmpty,
            reason: 'Simple mode card should have semantic label');

        // Find semantics for advanced mode card
        final advancedModeSemantics =
            tester.getSemantics(find.byKey(const Key('advanced_mode_card')));
        expect(advancedModeSemantics.label, isNotEmpty,
            reason: 'Advanced mode card should have semantic label');
      });
    });

    group('Edge Cases', () {
      testWidgets('handles rapid tapping of mode cards',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        // Rapidly tap between modes
        await tester.tap(find.byKey(const Key('compact_mode_card')));
        await tester.pump(const Duration(milliseconds: 50));

        // Scroll to make advanced mode card visible
        await tester.dragUntilVisible(
          find.byKey(const Key('advanced_mode_card')),
          find.byType(SingleChildScrollView),
          const Offset(0, -50),
        );
        await tester.pump(const Duration(milliseconds: 50));

        await tester.tap(find.byKey(const Key('advanced_mode_card')));
        await tester.pump(const Duration(milliseconds: 50));

        // Scroll back to compact mode
        await tester.dragUntilVisible(
          find.byKey(const Key('compact_mode_card')),
          find.byType(SingleChildScrollView),
          const Offset(0, 50),
        );
        await tester.pump(const Duration(milliseconds: 50));

        await tester.tap(find.byKey(const Key('compact_mode_card')));
        await tester.pumpAndSettle();

        final selectButton = tester.widget<ElevatedButton>(
            find.byKey(const Key('select_mode_button')));

        expect(selectButton.enabled, true,
            reason: 'Button should remain functional after rapid tapping');
      });

      testWidgets('button stays disabled if mode is deselected somehow',
          (WidgetTester tester) async {
        await tester.pumpWidget(await createApp());
        await tester.pumpAndSettle();

        // Initially no mode selected
        final selectButton = tester.widget<ElevatedButton>(
            find.byKey(const Key('select_mode_button')));

        expect(selectButton.enabled, false,
            reason: 'Button should be disabled with no selection');
      });
    });

    group('Localization', () {
      testWidgets('displays English text correctly',
          (WidgetTester tester) async {
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
              home: DisplayModeSelectionPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Choose Your Experience'), findsOneWidget,
            reason: 'English title should be displayed');
        expect(find.text('Compact Mode'), findsOneWidget,
            reason: 'English compact mode text should be displayed');
        expect(find.text('Advanced Mode'), findsOneWidget,
            reason: 'English advanced mode text should be displayed');
      });
    });
  });
}
