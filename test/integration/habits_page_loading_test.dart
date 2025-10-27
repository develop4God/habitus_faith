import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/pages/home_page.dart';
import 'package:habitus_faith/pages/habits_page.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/onboarding_page.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';

void main() {
  group('Habits Page Loading - Real User Behavior Tests', () {
    testWidgets(
      'A. Onboarding → Habits Page flow shows content without blank/spinner',
      (WidgetTester tester) async {
        // Build the onboarding page
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const OnboardingPage(),
              routes: {
                '/home': (context) => const HomePage(),
              },
            ),
          ),
        );

        // Wait for initial render
        await tester.pumpAndSettle();

        // Verify onboarding page is displayed
        expect(find.text('Selecciona tus hábitos'), findsOneWidget);

        // Find and tap on first habit card (Prayer)
        final firstHabitCard = find.byKey(const Key('habit_card_0'));
        expect(firstHabitCard, findsOneWidget);
        await tester.tap(firstHabitCard);
        await tester.pump(const Duration(milliseconds: 100));

        // Verify habit is selected
        expect(find.byIcon(Icons.check_circle), findsOneWidget);

        // Find and tap continue button
        final continueButton = find.widgetWithText(ElevatedButton, 'Continuar');
        expect(continueButton, findsOneWidget);
        await tester.tap(continueButton);

        // Wait for navigation and habit creation (should show spinner briefly)
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Wait for async operations to complete
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // CRITICAL: Verify we navigated to HomePage (Mis Hábitos)
        expect(find.text('Mis Hábitos'), findsOneWidget,
            reason: 'Should show Habits page title, not blank spinner');

        // Verify bottom navigation is present
        expect(find.byType(BottomNavigationBar), findsOneWidget,
            reason: 'Should show bottom navigation, not loading state');

        // Verify FAB is present (add habit button)
        expect(find.byType(FloatingActionButton), findsOneWidget,
            reason: 'Should show FAB, indicating page loaded correctly');

        // Verify either empty state OR habit card is shown (not spinner)
        final hasContent = tester.any(
          find.byType(Card).or(find.text('Añade hábitos para empezar')),
        );
        expect(hasContent, true,
            reason:
                'Should show either habit cards or empty state message, not blank spinner');

        // Verify NO loading indicator is present
        expect(find.byType(CircularProgressIndicator), findsNothing,
            reason: 'Should NOT show loading spinner on habits page');
      },
    );

    testWidgets(
      'B. Direct navigation to Habits Page shows content without blank/spinner',
      (WidgetTester tester) async {
        // Build HomePage directly (simulating direct navigation or app restart)
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const HomePage(),
            ),
          ),
        );

        // CRITICAL: Verify page loads immediately without long spinner state
        await tester.pump(); // Initial frame
        await tester.pump(const Duration(milliseconds: 100)); // Allow async init

        // Page should start showing content quickly
        expect(find.text('Mis Hábitos'), findsOneWidget,
            reason: 'Title should appear immediately, not after long delay');

        // Wait for any remaining async operations
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify bottom navigation is present
        expect(find.byType(BottomNavigationBar), findsOneWidget,
            reason: 'Bottom nav should be present');

        // Verify FAB is present
        expect(find.byType(FloatingActionButton), findsOneWidget,
            reason: 'FAB should be visible');

        // Verify either empty state OR habit content is shown
        final hasContent = tester.any(
          find.byType(Card).or(find.text('Añade hábitos para empezar')),
        );
        expect(hasContent, true,
            reason: 'Should show content or empty state, not blank page');

        // Verify NO persistent loading indicator
        expect(find.byType(CircularProgressIndicator), findsNothing,
            reason:
                'Should NOT have persistent spinner - page should load quickly');
      },
    );

    testWidgets(
      'C. Habits Page stream emits initial state immediately',
      (WidgetTester tester) async {
        // This test verifies the stream provider doesn't cause blank state
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const HabitsPage(),
            ),
          ),
        );

        // CRITICAL: First pump should NOT show blank page
        await tester.pump();

        // Verify we don't get stuck in loading state
        // The page should show SOMETHING (loading, content, or empty state)
        final pageHasVisibleContent = tester.any(
          find.byType(AppBar).or(find.byType(FloatingActionButton)),
        );
        expect(pageHasVisibleContent, true,
            reason: 'Page should render UI elements immediately, not blank');

        // Complete async operations
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // After settling, should have full content
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // Should show either habits or empty state message
        final hasContent = tester.any(
          find.byType(Card).or(find.text('Añade hábitos para empezar')),
        );
        expect(hasContent, true);
      },
    );

    testWidgets(
      'D. Multiple habit selections → navigation shows all habits without spinner',
      (WidgetTester tester) async {
        // Build onboarding with multiple habit selection
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const OnboardingPage(),
              routes: {
                '/home': (context) => const HomePage(),
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Select 3 habits (maximum allowed)
        for (int i = 0; i < 3; i++) {
          final habitCard = find.byKey(Key('habit_card_$i'));
          await tester.tap(habitCard);
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Verify 3 habits selected
        expect(find.byIcon(Icons.check_circle), findsNWidgets(3));

        // Tap continue
        final continueButton = find.widgetWithText(ElevatedButton, 'Continuar');
        await tester.tap(continueButton);

        // Allow async operations
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // CRITICAL: Should navigate to habits page showing content
        expect(find.text('Mis Hábitos'), findsOneWidget);

        // Should show habit cards (3 created)
        expect(find.byType(Card), findsWidgets,
            reason:
                'Should show habit cards for the 3 created habits, not blank page');

        // No loading indicator
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'E. Empty habits state shows message immediately, not blank spinner',
      (WidgetTester tester) async {
        // Build habits page when no habits exist
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const HabitsPage(),
            ),
          ),
        );

        // Initial render
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Wait for stream to emit
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // CRITICAL: Should show empty state message, not blank page
        expect(
          find.textContaining('Añade hábitos'),
          findsOneWidget,
          reason:
              'Empty state should show message, not blank spinner indefinitely',
        );

        // Should have FAB to add habits
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // Should NOT have loading indicator
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  });
}
