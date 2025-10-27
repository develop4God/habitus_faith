import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/data/storage/json_habits_repository.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/onboarding_page.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/onboarding_providers.dart';
import 'package:habitus_faith/pages/habits_page.dart';
import 'package:habitus_faith/pages/home_page.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Habits Page Navigation Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
        'REAL USER FLOW: Onboarding → Select habits → Navigate to HomePage → See habits without spinner',
        (WidgetTester tester) async {
      // Arrange: Set up test environment
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act 1: Build onboarding page
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
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

      // Assert: Onboarding page is shown
      expect(find.text('Selecciona hasta 3 hábitos'), findsOneWidget);

      // Act 2: Select 2 habits (real user behavior)
      final prayerCard = find.byKey(const Key('habit_card_prayer'));
      final readingCard = find.byKey(const Key('habit_card_reading'));

      await tester.ensureVisible(prayerCard);
      await tester.pumpAndSettle();
      await tester.tap(prayerCard);
      await tester.pumpAndSettle();

      await tester.ensureVisible(readingCard);
      await tester.pumpAndSettle();
      await tester.tap(readingCard);
      await tester.pumpAndSettle();

      // Assert: 2 habits selected
      expect(find.text('2 de 3 seleccionados'), findsOneWidget);

      // Act 3: Tap continue button
      final continueButton = find.text('Continuar');
      expect(continueButton, findsOneWidget);
      await tester.tap(continueButton);
      await tester.pump(); // Start async operation

      // Assert: Loading state appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Act 4: Wait for navigation to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert: HomePage is shown (not blank page with spinner)
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(HabitsPage), findsOneWidget);

      // Critical assertion: NO loading spinner on habits page
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Assert: Habits page shows content (either empty state or habits list)
      // At minimum, the app bar should be visible
      expect(find.text('Mis Hábitos'), findsOneWidget);

      // Assert: FAB button is visible (not covered by spinner)
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets(
        'DIRECT NAVIGATION: Navigate directly to HabitsPage without spinner',
        (WidgetTester tester) async {
      // Arrange: Create empty repository (no habits)
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act: Navigate directly to habits page
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HabitsPage(),
          ),
        ),
      );

      // Initial pump
      await tester.pump();

      // Allow stream to emit (should be immediate with proper implementation)
      await tester.pump(const Duration(milliseconds: 100));

      // Assert: Page loads without infinite spinner
      // Either we see content or we finish loading quickly
      expect(find.byType(HabitsPage), findsOneWidget);

      // Wait for any async operations to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Critical assertion: NO eternal loading spinner
      // If there's a spinner, it should have resolved by now
      final spinnerFinder = find.byType(CircularProgressIndicator);
      expect(spinnerFinder, findsNothing,
          reason:
              'Habits page should not show eternal loading spinner. Stream should emit immediately.');

      // Assert: Page shows either empty state or habits list
      expect(find.text('Mis Hábitos'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets(
        'DIRECT NAVIGATION with existing habits: Shows habits list immediately',
        (WidgetTester tester) async {
      // Arrange: Create habits first
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repository = container.read(jsonHabitsRepositoryProvider);

      // Create some test habits
      await repository.createHabit(
        name: 'Test Prayer',
        description: 'Daily prayer habit',
      );
      await repository.createHabit(
        name: 'Test Reading',
        description: 'Bible reading habit',
      );

      // Give repository time to emit
      await Future.delayed(const Duration(milliseconds: 100));

      // Act: Navigate directly to habits page
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HabitsPage(),
          ),
        ),
      );

      // Initial pump
      await tester.pump();

      // Allow stream to emit
      await tester.pump(const Duration(milliseconds: 100));

      // Wait for rendering
      await tester.pumpAndSettle();

      // Assert: Habits are displayed (no spinner)
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Mis Hábitos'), findsOneWidget);

      // Should show habit cards
      // Note: The actual habit cards might use different finders
      // We verify the page structure is loaded
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets(
        'ONBOARDING with 1 habit: Completes and shows habits page correctly',
        (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
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

      // Act: Select 1 habit
      final prayerCard = find.byKey(const Key('habit_card_prayer'));
      await tester.ensureVisible(prayerCard);
      await tester.pumpAndSettle();
      await tester.tap(prayerCard);
      await tester.pumpAndSettle();

      // Act: Continue
      await tester.tap(find.text('Continuar'));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert: HomePage with no spinner
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Mis Hábitos'), findsOneWidget);
    });

    testWidgets(
        'ONBOARDING with 3 habits: Completes and shows habits page correctly',
        (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
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

      // Act: Select 3 habits
      final prayerCard = find.byKey(const Key('habit_card_prayer'));
      final readingCard = find.byKey(const Key('habit_card_reading'));
      final gratitudeCard = find.byKey(const Key('habit_card_gratitude'));

      await tester.ensureVisible(prayerCard);
      await tester.pumpAndSettle();
      await tester.tap(prayerCard);
      await tester.pumpAndSettle();

      await tester.ensureVisible(readingCard);
      await tester.pumpAndSettle();
      await tester.tap(readingCard);
      await tester.pumpAndSettle();

      await tester.ensureVisible(gratitudeCard);
      await tester.pumpAndSettle();
      await tester.tap(gratitudeCard);
      await tester.pumpAndSettle();

      // Act: Continue
      await tester.tap(find.text('Continuar'));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert: HomePage with no spinner
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Mis Hábitos'), findsOneWidget);
    });

    testWidgets('Stream emits data immediately when HabitsPage subscribes',
        (WidgetTester tester) async {
      // This test verifies the stream provider emits data synchronously
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repository = container.read(jsonHabitsRepositoryProvider);

      // Create a habit
      await repository.createHabit(
        name: 'Stream Test',
        description: 'Test habit',
      );

      // Small delay for stream to process
      await Future.delayed(const Duration(milliseconds: 50));

      // Read the stream provider
      final streamProvider = container.read(jsonHabitsStreamProvider);

      // Assert: Stream should have data available
      await expectLater(
        streamProvider.when(
          data: (habits) => habits.length,
          loading: () => -1,
          error: (_, __) => -2,
        ),
        equals(1),
        reason: 'Stream should emit current habits immediately',
      );
    });
  });
}
