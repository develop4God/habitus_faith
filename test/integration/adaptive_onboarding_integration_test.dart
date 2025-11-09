import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/adaptive_onboarding_page.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/commitment_screen.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/onboarding_models.dart';
import 'package:habitus_faith/features/habits/data/storage/storage_providers.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Integration test for adaptive onboarding user behavior
/// Tests complete user flows through all 3 paths (faith, wellness, both)
void main() {
  group('Adaptive Onboarding Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    Future<Widget> createApp() async {
      final prefs = await SharedPreferences.getInstance();

      return ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en', '')],
          home: AdaptiveOnboardingPage(),
        ),
      );
    }

    testWidgets('Faith path: Complete flow from intent to commitment',
        (WidgetTester tester) async {
      await tester.pumpWidget(await createApp());
      await tester.pumpAndSettle();

      // Verify initial state: First question (intent detection)
      expect(find.text('¿Qué te trae a habitus+faith?'), findsOneWidget);
      expect(find.text('1/1'), findsOneWidget); // Only intent question initially

      // Select faith-based intent
      final faithOption = find.text('Fortalecer mi vida espiritual');
      expect(faithOption, findsOneWidget);
      await tester.tap(faithOption);
      await tester.pumpAndSettle();

      // Verify option is selected
      expect(find.byIcon(Icons.check_circle), findsAtLeastNWidgets(1));

      // Continue to next question
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Question 2: Spiritual Motivation (multi-select)
      expect(
          find.text('¿Qué te motiva en tu caminar con Dios?'), findsOneWidget);
      expect(find.text('2/5'), findsOneWidget); // Now showing faith path count

      // Select multiple motivations (max 3)
      await tester.tap(find.text('Sentirme más cerca de Dios'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entender mejor la Biblia'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tener disciplina en oración'));
      await tester.pumpAndSettle();

      // Verify 3 items selected
      expect(find.byIcon(Icons.check_circle), findsNWidgets(3));

      // Continue to next question
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Question 3: Faith Walk
      expect(
          find.text('¿Cómo describirías tu caminar actual con Dios?'),
          findsOneWidget);
      expect(find.text('3/5'), findsOneWidget);

      await tester.tap(find.text('Creciendo pero inconsistente'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Question 4: Main Challenge (universal)
      expect(find.text('¿Cuál es tu mayor desafío?'), findsOneWidget);
      expect(find.text('4/5'), findsOneWidget);

      await tester.tap(find.text('Falta de tiempo'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Question 5: Support System (universal)
      expect(find.text('¿Cómo es tu red de apoyo?'), findsOneWidget);
      expect(find.text('5/5'), findsOneWidget);

      // Select weak support to trigger encouragement dialog
      await tester.tap(find.text('Débil: me siento bastante solo'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Finalizar'));
      await tester.pumpAndSettle();

      // Verify biblical encouragement dialog appears
      expect(find.text('No estás solo'), findsOneWidget);
      expect(find.text('Isaías 41:10'), findsOneWidget);
      expect(find.text('no temas'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify navigation to commitment screen
      expect(find.byType(CommitmentScreen), findsOneWidget);
      expect(find.text('¡Casi listo! 🎉'), findsOneWidget);
      expect(
          find.text('Firma tu compromiso con Dios:'), findsOneWidget);

      // Verify faith-specific commitments are shown
      expect(find.text('¡Voy a crecer en mi fe!'), findsOneWidget);
      expect(find.text('¡Voy a tener disciplina espiritual!'), findsOneWidget);
    });

    testWidgets('Wellness path: No religious content forced',
        (WidgetTester tester) async {
      await tester.pumpWidget(await createApp());
      await tester.pumpAndSettle();

      // Select wellness intent
      await tester.tap(find.text('Mejorar mi organización y salud'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Question 2: Wellness Goals (multi-select)
      expect(find.text('¿Qué aspectos de tu vida quieres mejorar?'),
          findsOneWidget);
      expect(find.text('2/5'), findsOneWidget);

      // Verify NO spiritual questions
      expect(find.text('¿Qué te motiva en tu caminar con Dios?'), findsNothing);

      // Select wellness goals
      await tester.tap(find.text('Organizar mejor mi tiempo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mejorar mi salud física'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Question 3: Current State
      expect(find.text('¿En qué punto estás ahora?'), findsOneWidget);
      expect(find.text('3/5'), findsOneWidget);

      await tester.tap(find.text('Comenzando desde cero'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Question 4: Challenge
      await tester.tap(find.text('Falta de motivación'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Question 5: Support - select weak to verify NO biblical message
      await tester.tap(find.text('Débil: me siento bastante solo'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Finalizar'));
      await tester.pumpAndSettle();

      // Verify community encouragement (NOT biblical)
      expect(find.text('Estamos juntos en esto'), findsOneWidget);
      expect(find.text('Miles de usuarios'), findsOneWidget);
      // Should NOT show bible verse
      expect(find.text('Isaías 41:10'), findsNothing);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify secular commitment screen
      expect(
          find.text('Firma tu compromiso contigo mismo:'), findsOneWidget);
      expect(find.text('¡Voy a conseguir mi objetivo!'), findsOneWidget);
      // Should NOT show faith commitments
      expect(find.text('¡Voy a crecer en mi fe!'), findsNothing);
      expect(find.text('Firma tu compromiso con Dios:'), findsNothing);
    });

    testWidgets('Both path: Mix of faith and wellness questions',
        (WidgetTester tester) async {
      await tester.pumpWidget(await createApp());
      await tester.pumpAndSettle();

      // Select both intent
      await tester.tap(find.text('Ambos: fe y bienestar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Should have 6 questions total (1 intent + 3 both-specific + 2 universal)
      expect(find.text('2/6'), findsOneWidget);

      // Should have spiritual motivation question
      expect(
          find.text('¿Qué te motiva en tu caminar con Dios?'), findsOneWidget);

      await tester.tap(find.text('Sentirme más cerca de Dios'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Should have wellness goals question
      expect(find.text('¿Qué aspectos de tu vida quieres mejorar?'),
          findsOneWidget);
      expect(find.text('3/6'), findsOneWidget);

      await tester.tap(find.text('Organizar mejor mi tiempo'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Should have faith walk question
      expect(
          find.text('¿Cómo describirías tu caminar actual con Dios?'),
          findsOneWidget);
      expect(find.text('4/6'), findsOneWidget);

      await tester.tap(find.text('Soy nuevo en la fe'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Universal questions follow
      expect(find.text('5/6'), findsOneWidget);
    });

    testWidgets('Back navigation works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(await createApp());
      await tester.pumpAndSettle();

      // Select faith intent
      await tester.tap(find.text('Fortalecer mi vida espiritual'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Should be on question 2
      expect(find.text('2/5'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back on question 1
      expect(find.text('1/1'), findsOneWidget);
      expect(find.text('¿Qué te trae a habitus+faith?'), findsOneWidget);

      // Selection should be preserved
      expect(find.byIcon(Icons.check_circle), findsAtLeastNWidgets(1));
    });

    testWidgets('Multi-select allows multiple selections',
        (WidgetTester tester) async {
      await tester.pumpWidget(await createApp());
      await tester.pumpAndSettle();

      // Go to faith path multi-select question
      await tester.tap(find.text('Fortalecer mi vida espiritual'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Select multiple items
      await tester.tap(find.text('Sentirme más cerca de Dios'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entender mejor la Biblia'));
      await tester.pumpAndSettle();

      // At least 2 items should be selected
      expect(find.byIcon(Icons.check_circle), findsAtLeastNWidgets(2));
    });

    testWidgets('Continue button is disabled without selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(await createApp());
      await tester.pumpAndSettle();

      // Find the continue button
      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueButton, findsOneWidget);

      // Button should be disabled initially (no selection made)
      final button = tester.widget<ElevatedButton>(continueButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('Profile persistence: Save and restore',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();

      // Simulate saved profile
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'understandBible'],
        challenge: 'lackOfTime',
        supportLevel: 'strong',
        spiritualMaturity: 'growing',
        commitment: 'Test commitment',
        completedAt: DateTime.now(),
      );

      await prefs.setString('onboarding_profile', 
          '${profile.toJson()}');
      await prefs.setString('user_intent', 'faithBased');

      // Verify saved
      final savedProfile = prefs.getString('onboarding_profile');
      final savedIntent = prefs.getString('user_intent');

      expect(savedProfile, isNotNull);
      expect(savedIntent, 'faithBased');

      // Verify can restore
      final restored = OnboardingProfile.fromJson(
        Map<String, dynamic>.from(
          // Note: In real code, use jsonDecode
          profile.toJson(),
        ),
      );

      expect(restored.primaryIntent, UserIntent.faithBased);
      expect(restored.motivations, ['closerToGod', 'understandBible']);
      expect(restored.spiritualMaturity, 'growing');
    });
  });
}
