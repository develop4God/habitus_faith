import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/adaptive_onboarding_page.dart';
import 'package:habitus_faith/features/habits/data/storage/storage_providers.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Smoke tests for AdaptiveOnboardingPage
/// These verify the page loads and displays basic UI elements
void main() {
  group('AdaptiveOnboardingPage Smoke Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
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

    Future<void> pumpAdaptiveOnboardingPage(WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();

      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en', ''), Locale('es', '')],
            locale: Locale('es', ''),
            home: AdaptiveOnboardingPage(),
          ),
        ),
      );

      await tester.pump();
    }

    testWidgets('page loads without errors', (WidgetTester tester) async {
      await pumpAdaptiveOnboardingPage(tester);

      // Page should load (this will throw if there are build errors)
      expect(find.byType(AdaptiveOnboardingPage), findsOneWidget);
    });

    testWidgets('displays intro page with start button',
        (WidgetTester tester) async {
      await pumpAdaptiveOnboardingPage(tester);

      // Should show intro with start button
      expect(find.text('Comenzar'), findsOneWidget);
    });
  });
}
