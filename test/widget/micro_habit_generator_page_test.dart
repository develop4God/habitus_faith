import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/features/habits/presentation/ai_generator/micro_habit_generator_page.dart';
import 'package:habitus_faith/core/providers/ai_providers.dart';
import 'package:habitus_faith/features/habits/domain/models/micro_habit.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('MicroHabitGeneratorPage Widget Tests', () {
    testWidgets('displays page title and form elements', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MicroHabitGeneratorPage(),
          ),
        ),
      );

      // Wait for all frames to settle
      await tester.pumpAndSettle();

      // Verify page title is displayed
      expect(find.text('Generate Micro-Habits'), findsOneWidget);
      
      // Verify "Powered by Gemini" badge
      expect(find.text('Powered by Gemini AI'), findsOneWidget);
      
      // Verify form fields exist
      expect(find.byType(TextFormField), findsNWidgets(2));
      
      // Verify generate button exists
      expect(find.text('Generate Habits'), findsOneWidget);
      
      // Verify rate limit info is displayed
      expect(find.textContaining('10 generations/month'), findsOneWidget);
    });

    testWidgets('validates goal input - empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MicroHabitGeneratorPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap generate button without entering goal
      await tester.tap(find.text('Generate Habits'));
      await tester.pumpAndSettle();

      // Verify validation error is shown
      expect(find.text('Please enter your goal'), findsOneWidget);
    });

    testWidgets('validates goal input - too short', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MicroHabitGeneratorPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter a short goal (less than 10 characters)
      await tester.enterText(
        find.byType(TextFormField).first,
        'Pray',
      );
      
      await tester.tap(find.text('Generate Habits'));
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.text('Goal must be at least 10 characters'), findsOneWidget);
    });

    testWidgets('disables generate button when loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            microHabitGeneratorProvider.overrideWith((ref) =>
                TestMicroHabitGenerator(isLoading: true)),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MicroHabitGeneratorPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify loading state is shown
      expect(find.text('Generating habits...'), findsOneWidget);
      
      // Verify button shows loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays remaining generations count', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            microHabitGeneratorProvider.overrideWith((ref) =>
                TestMicroHabitGenerator(remainingRequests: 5)),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MicroHabitGeneratorPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify remaining count is shown
      expect(find.textContaining('5 remaining'), findsOneWidget);
    });

    testWidgets('shows warning when few generations remain', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            microHabitGeneratorProvider.overrideWith((ref) =>
                TestMicroHabitGenerator(remainingRequests: 2)),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MicroHabitGeneratorPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify warning icon is present
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });
  });
}

/// Test implementation of MicroHabitGenerator for widget testing
class TestMicroHabitGenerator extends AutoDisposeAsyncNotifier<List<MicroHabit>> {
  final bool isLoading;
  final int remainingRequests;

  TestMicroHabitGenerator({
    this.isLoading = false,
    this.remainingRequests = 10,
  });

  @override
  Future<List<MicroHabit>> build() async {
    if (isLoading) {
      return Future.delayed(
        const Duration(seconds: 10),
        () => [],
      );
    }
    return [];
  }

  Future<void> generate(request) async {
    state = const AsyncValue.loading();
  }
}
