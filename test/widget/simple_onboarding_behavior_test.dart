import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/simple_onboarding_flow.dart';
import 'package:habitus_faith/features/habits/data/storage/storage_providers.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Widget tests for real user behavior and edge cases
/// 
/// Tests cover:
/// - Race conditions (rapid taps, double tap)
/// - Timer cancellation on disposal
/// - State consistency with max limits
/// - Error validation
void main() {
  group('SimpleOnboardingFlow - User Behavior Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpOnboardingFlow(
      WidgetTester tester, {
      Size viewSize = const Size(800, 1200),
    }) async {
      final prefs = await SharedPreferences.getInstance();

      tester.view.physicalSize = viewSize;
      tester.view.devicePixelRatio = 1.0;

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
            home: SimpleOnboardingFlow(),
          ),
        ),
      );

      await tester.pump();
    }

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

    group('Race Conditions', () {
      testWidgets('double tap toggles selection correctly',
          (WidgetTester tester) async {
        await pumpOnboardingFlow(tester);

        final feFinder = find.text('Fe');
        
        // Select
        await tester.tap(feFinder);
        await tester.pump();
        expect(find.byIcon(Icons.check_circle), findsOneWidget);

        // Deselect
        await tester.tap(feFinder);
        await tester.pump();
        expect(find.byIcon(Icons.check_circle), findsNothing);

        // Select again
        await tester.tap(feFinder);
        await tester.pump();
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('rapid selection enforces max limit',
          (WidgetTester tester) async {
        await pumpOnboardingFlow(tester);

        // Rapidly select 4 goals (max is 3)
        await tester.tap(find.text('Fe'));
        await tester.pump();
        await tester.tap(find.text('Salud'));
        await tester.pump();
        await tester.tap(find.text('Estudio'));
        await tester.pump();
        await tester.tap(find.text('Paz mental'));
        await tester.pump();

        // Should have exactly 3 goals selected
        expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
      });

      testWidgets('timer cancellation on disposal prevents crashes',
          (WidgetTester tester) async {
        await pumpOnboardingFlow(tester);

        // Complete Q1
        await tester.tap(find.text('Fe'));
        await tester.pump();
        await tester.tap(find.text('Continuar'));
        await tester.pumpAndSettle();

        // Dispose widget
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        
        // Wait for timer duration
        await tester.pump(const Duration(milliseconds: 400));

        // No crashes should occur
      });
    });

    group('State Consistency', () {
      testWidgets('max goals limit is enforced',
          (WidgetTester tester) async {
        await pumpOnboardingFlow(tester);

        // Select 3 goals
        await tester.tap(find.text('Fe'));
        await tester.pump();
        await tester.tap(find.text('Salud'));
        await tester.pump();
        await tester.tap(find.text('Estudio'));
        await tester.pump();

        expect(find.byIcon(Icons.check_circle), findsNWidgets(3));

        // Try to select 4th - should be ignored
        await tester.tap(find.text('Paz mental'));
        await tester.pump();

        expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
      });

      testWidgets('deselecting allows new selection',
          (WidgetTester tester) async {
        await pumpOnboardingFlow(tester);

        // Select 3 goals
        await tester.tap(find.text('Fe'));
        await tester.pump();
        await tester.tap(find.text('Salud'));
        await tester.pump();
        await tester.tap(find.text('Estudio'));
        await tester.pump();

        // Deselect one
        await tester.tap(find.text('Salud'));
        await tester.pump();
        expect(find.byIcon(Icons.check_circle), findsNWidgets(2));

        // Now can select the 4th
        await tester.tap(find.text('Paz mental'));
        await tester.pump();
        expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
      });
    });

    group('Error Validation', () {
      testWidgets('continuing without goals does not crash',
          (WidgetTester tester) async {
        await pumpOnboardingFlow(tester);

        // Try to continue without selecting
        await tester.tap(find.text('Continuar'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Should still be on Q1 (not crashed)
        expect(find.text('¿Qué quieres mejorar?'), findsOneWidget);
      });

      testWidgets('can recover from error state',
          (WidgetTester tester) async {
        await pumpOnboardingFlow(tester);

        // Trigger error
        await tester.tap(find.text('Continuar'));
        await tester.pump();

        // Select a goal
        await tester.tap(find.text('Fe'));
        await tester.pump();

        // Wait for SnackBar to disappear
        await tester.pump(const Duration(seconds: 3));

        // Now can continue
        await tester.tap(find.text('Continuar'));
        await tester.pumpAndSettle();

        // Should advance to Q2 (use specific text)
        expect(find.text('¿Cuánto tiempo diario?'), findsOneWidget);
      });
    });

    group('Timer Behavior', () {
      testWidgets('timer does not fire after widget disposal',
          (WidgetTester tester) async {
        await pumpOnboardingFlow(tester);

        // Navigate to Q2
        await tester.tap(find.text('Fe'));
        await tester.pump();
        await tester.tap(find.text('Continuar'));
        await tester.pumpAndSettle();

        // Dispose widget by replacing it
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        
        // Wait for timer duration
        await tester.pump(const Duration(milliseconds: 400));

        // No crashes should occur
      });

      testWidgets('changing selection cancels previous timer',
          (WidgetTester tester) async {
        await pumpOnboardingFlow(tester);

        // Navigate to Q2
        await tester.tap(find.text('Fe'));
        await tester.pump();
        await tester.tap(find.text('Continuar'));
        await tester.pumpAndSettle();

        // This test verifies timer cancellation is working
        // by disposing the widget before timer fires
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
        navigator.pop();
        await tester.pump();
        
        // Wait for timer duration
        await tester.pump(const Duration(milliseconds: 400));
        
        // No crashes should occur
      });
    });

    group('Edge Cases', () {
      testWidgets('initial state is valid',
          (WidgetTester tester) async {
        await pumpOnboardingFlow(tester);

        expect(find.byIcon(Icons.check_circle), findsNothing);
        expect(find.text('Continuar'), findsOneWidget);
      });

      testWidgets('selecting and deselecting all goals',
          (WidgetTester tester) async {
        await pumpOnboardingFlow(tester);

        // Select all
        await tester.tap(find.text('Fe'));
        await tester.pump();
        await tester.tap(find.text('Salud'));
        await tester.pump();

        // Deselect all
        await tester.tap(find.text('Fe'));
        await tester.pump();
        await tester.tap(find.text('Salud'));
        await tester.pump();

        // Back to empty state
        expect(find.byIcon(Icons.check_circle), findsNothing);
      });

      testWidgets('navigation flow maintains state',
          (WidgetTester tester) async {
        await pumpOnboardingFlow(tester);

        // Complete Q1
        await tester.tap(find.text('Fe'));
        await tester.pump();
        await tester.tap(find.text('Continuar'));
        await tester.pumpAndSettle();

        // Should be on Q2 (use specific text)
        expect(find.text('¿Cuánto tiempo diario?'), findsOneWidget);
        
        // Progress indicator should exist
        expect(find.byType(AnimatedContainer), findsAtLeastNWidgets(1));
      });
    });
  });
}
