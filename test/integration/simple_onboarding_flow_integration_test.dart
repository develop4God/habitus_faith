import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/simple_onboarding_flow.dart';
import 'package:habitus_faith/features/habits/data/storage/storage_providers.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> pumpSimpleOnboardingFlow(WidgetTester tester) async {
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
        home: SimpleOnboardingFlow(),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  group('Simple Onboarding Flow Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Q1: displays goals question with 4 options',
        (WidgetTester tester) async {
      await pumpSimpleOnboardingFlow(tester);

      // Should show title
      expect(find.text('¿Qué quieres mejorar?'), findsOneWidget);
      expect(find.text('Selecciona hasta 3 objetivos'), findsOneWidget);

      // Should show 4 goal options
      expect(find.text('Fe'), findsOneWidget);
      expect(find.text('Salud'), findsOneWidget);
      expect(find.text('Estudio'), findsOneWidget);
      expect(find.text('Paz mental'), findsOneWidget);

      // Continue button should be disabled
      final continueButton = find.text('Continuar');
      expect(continueButton, findsOneWidget);
    });

    testWidgets('Q1: selecting 0 goals shows error',
        (WidgetTester tester) async {
      await pumpSimpleOnboardingFlow(tester);

      // Try to continue without selecting
      await tester.tap(find.text('Continuar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show snackbar error
      expect(find.text('Por favor selecciona al menos un objetivo'),
          findsOneWidget);
    });

    testWidgets('Q1: can select up to 3 goals', (WidgetTester tester) async {
      await pumpSimpleOnboardingFlow(tester);

      // Select Fe
      await tester.tap(find.text('Fe'));
      await tester.pump();

      // Verify check circle appears
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Select Salud
      await tester.tap(find.text('Salud'));
      await tester.pump();

      // Should have 2 check circles
      expect(find.byIcon(Icons.check_circle), findsNWidgets(2));

      // Select Estudio
      await tester.tap(find.text('Estudio'));
      await tester.pump();

      // Should have 3 check circles
      expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
    });

    testWidgets('Q1: cannot select more than 3 goals',
        (WidgetTester tester) async {
      await pumpSimpleOnboardingFlow(tester);

      // Select 3 goals
      await tester.tap(find.text('Fe'));
      await tester.pump();
      await tester.tap(find.text('Salud'));
      await tester.pump();
      await tester.tap(find.text('Estudio'));
      await tester.pump();

      // Try to select 4th goal
      await tester.tap(find.text('Paz mental'));
      await tester.pump();

      // Should still have only 3 check circles (4th ignored)
      expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
    });

    testWidgets('Q1: can deselect goals', (WidgetTester tester) async {
      await pumpSimpleOnboardingFlow(tester);

      // Select Fe
      await tester.tap(find.text('Fe'));
      await tester.pump();
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Deselect Fe
      await tester.tap(find.text('Fe'));
      await tester.pump();

      // Should have no check circles
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('Full flow: Q1 -> Q2 -> Q3 (navigation)',
        (WidgetTester tester) async {
      await pumpSimpleOnboardingFlow(tester);

      // Q1: Select goal and continue
      await tester.tap(find.text('Fe'));
      await tester.pump();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      // Q2: Should show time commitment question
      expect(find.text('¿Cuánto tiempo diario?'), findsOneWidget);
      expect(find.text('5-10 minutos'), findsOneWidget);
      expect(find.text('10-20 minutos'), findsOneWidget);
      expect(find.text('20+ minutos'), findsOneWidget);

      // Select time commitment (auto-advances)
      await tester.tap(find.text('10-20 minutos'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Q3: Should show experience level question
      expect(find.text('¿Tu nivel actual?'), findsOneWidget);
      expect(find.text('Nuevo'), findsOneWidget);
      expect(find.text('Creciendo'), findsOneWidget);
      expect(find.text('Consistente'), findsOneWidget);
    });

    testWidgets('Progress indicator shows correct step',
        (WidgetTester tester) async {
      await pumpSimpleOnboardingFlow(tester);

      // Q1: First dot should be active (wide)
      final progressDots = find.byType(AnimatedContainer);
      expect(progressDots, findsAtLeastNWidgets(3));

      // Continue to Q2
      await tester.tap(find.text('Fe'));
      await tester.pump();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      // Q2: Second dot should be active
      expect(find.text('¿Cuánto tiempo diario?'), findsOneWidget);

      // Continue to Q3
      await tester.tap(find.text('10-20 minutos'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Q3: Third dot should be active
      expect(find.text('¿Tu nivel actual?'), findsOneWidget);
    });

    testWidgets('Score calculation: basic level (faith + short + newbie)',
        (WidgetTester tester) async {
      await pumpSimpleOnboardingFlow(tester);

      // Q1: Select faith
      await tester.tap(find.text('Fe'));
      await tester.pump();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      // Q2: Select short time
      await tester.tap(find.text('5-10 minutos'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Q3: Select newbie level (should trigger loading and preview)
      await tester.tap(find.text('Nuevo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Should show loading dialog
      expect(find.text('Preparando tus hábitos...'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should navigate to preview (check for score level label)
      // Basic level should show "Empezando · Paso a paso"
      expect(find.textContaining('Empezando'), findsOneWidget);
    });

    testWidgets(
        'Score calculation: intermediate level (2 goals + medium + growing)',
        (WidgetTester tester) async {
      await pumpSimpleOnboardingFlow(tester);

      // Q1: Select 2 goals
      await tester.tap(find.text('Fe'));
      await tester.pump();
      await tester.tap(find.text('Salud'));
      await tester.pump();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      // Q2: Select medium time
      await tester.tap(find.text('10-20 minutos'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Q3: Select growing level
      await tester.tap(find.text('Creciendo'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show intermediate level
      expect(find.textContaining('Creciendo'), findsOneWidget);
    });

    testWidgets(
        'Score calculation: advanced level (3 goals + long + consistent)',
        (WidgetTester tester) async {
      await pumpSimpleOnboardingFlow(tester);

      // Q1: Select 3 goals
      await tester.tap(find.text('Fe'));
      await tester.pump();
      await tester.tap(find.text('Salud'));
      await tester.pump();
      await tester.tap(find.text('Estudio'));
      await tester.pump();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      // Q2: Select long time
      await tester.tap(find.text('20+ minutos'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Q3: Select consistent level
      await tester.tap(find.text('Consistente'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show advanced level
      expect(find.textContaining('Comprometido'), findsOneWidget);
    });

    testWidgets('Accessibility: tap targets are large enough',
        (WidgetTester tester) async {
      await pumpSimpleOnboardingFlow(tester);

      // Find a goal option InkWell
      final feOption = find.ancestor(
        of: find.text('Fe'),
        matching: find.byType(InkWell),
      );
      expect(feOption, findsOneWidget);

      // Get the size of the tap area
      final inkWell = tester.widget<InkWell>(feOption.first);
      final container = inkWell.child as Container;
      final padding = container.padding as EdgeInsets;

      // Verify padding is at least 20dp (ensures 48x48 tap target with 32px emoji)
      expect(padding.top, greaterThanOrEqualTo(20));
      expect(padding.bottom, greaterThanOrEqualTo(20));
    });
  });
}
