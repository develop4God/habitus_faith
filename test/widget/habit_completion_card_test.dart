import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/presentation/widgets/habit_completion_card.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// High-quality widget tests for HabitCompletionCard
/// Focus: Tap interactions, visual states, animations
void main() {
  group('HabitCompletionCard Widget Tests', () {
    late Habit testHabit;
    bool tapCalled = false;

    setUp(() {
      tapCalled = false;
      testHabit = Habit(
        id: 'test-habit-1',
        userId: 'test-user-1',
        name: 'Morning Prayer',
        description: 'Pray each morning',
        category: HabitCategory.prayer,
        emoji: '🙏',
        createdAt: DateTime.now(),
        completedToday: false,
        currentStreak: 0,
        longestStreak: 0,
        completionHistory: [],
      );
    });

    Widget createApp(Habit habit, {bool isCompleting = false}) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', '')],
        home: Scaffold(
          body: HabitCompletionCard(
            habit: habit,
            onTap: () {
              tapCalled = true;
            },
            isCompleting: isCompleting,
          ),
        ),
      );
    }

    group('Initial Rendering', () {
      testWidgets('renders without crashing', (WidgetTester tester) async {
        await tester.pumpWidget(createApp(testHabit));
        await tester.pump();

        expect(find.byType(HabitCompletionCard), findsOneWidget,
            reason: 'HabitCompletionCard should render');
      });

      testWidgets('displays habit name', (WidgetTester tester) async {
        await tester.pumpWidget(createApp(testHabit));
        await tester.pump();

        expect(find.text('Morning Prayer'), findsOneWidget,
            reason: 'Habit name should be displayed');
      });

      testWidgets('displays habit emoji', (WidgetTester tester) async {
        await tester.pumpWidget(createApp(testHabit));
        await tester.pump();

        expect(find.text('🙏'), findsOneWidget,
            reason: 'Habit emoji should be displayed');
      });

      testWidgets('displays emoji when provided', (WidgetTester tester) async {
        await tester.pumpWidget(createApp(testHabit));
        await tester.pump();

        expect(find.text('🙏'), findsOneWidget,
            reason: 'Habit emoji should be displayed');
      });

      testWidgets('displays streak badges', (WidgetTester tester) async {
        final habitWithStreak = testHabit.copyWith(
          currentStreak: 5,
          longestStreak: 10,
        );
        await tester.pumpWidget(createApp(habitWithStreak));
        await tester.pump();

        expect(find.byIcon(Icons.local_fire_department), findsOneWidget,
            reason: 'Fire icon for current streak should be displayed');
        expect(find.textContaining('5 día'), findsOneWidget,
            reason: 'Current streak text should be displayed');
      });

      testWidgets('has unique key with habit ID', (WidgetTester tester) async {
        await tester.pumpWidget(createApp(testHabit));
        await tester.pump();

        expect(find.byKey(const Key('habit_completion_card_test-habit-1')),
            findsOneWidget,
            reason: 'Card should have unique key with habit ID');
      });
    });

    group('Visual States', () {
      testWidgets('incomplete habit has flat card with border',
          (WidgetTester tester) async {
        await tester.pumpWidget(createApp(testHabit));
        await tester.pump();

        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, 0,
            reason: 'Card should have flat elevation');
        
        final shape = card.shape as RoundedRectangleBorder;
        expect(shape.side.width, 1, 
            reason: 'Should have a border');
      });

      testWidgets('completed habit has visual distinction',
          (WidgetTester tester) async {
        final completedHabit = testHabit.copyWith(completedToday: true);
        await tester.pumpWidget(createApp(completedHabit));
        await tester.pump();

        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, 0,
            reason: 'Card should have flat elevation');

        // Check for checkbox icon indicating completion
        expect(find.byIcon(Icons.check), findsOneWidget,
            reason: 'Completed habit should show check icon');
      });

      testWidgets('habit text has strikethrough when completed',
          (WidgetTester tester) async {
        final completedHabit = testHabit.copyWith(completedToday: true);
        await tester.pumpWidget(createApp(completedHabit));
        await tester.pump();

        final textFinder = find.text('Morning Prayer');
        expect(textFinder, findsOneWidget);
        
        final text = tester.widget<Text>(textFinder);
        expect(text.style?.decoration, TextDecoration.lineThrough,
            reason: 'Completed habit text should have strikethrough');
      });
    });

    group('Tap Interaction', () {
      testWidgets('responds to tap when incomplete',
          (WidgetTester tester) async {
        await tester.pumpWidget(createApp(testHabit));
        await tester.pump();

        tapCalled = false;
        await tester.tap(find.byType(HabitCompletionCard));
        await tester.pump(); // Start animation
        await tester.pump(const Duration(
            milliseconds: 1600)); // Wait for animation to complete
        await tester
            .pump(const Duration(milliseconds: 600)); // Wait for callback delay

        expect(tapCalled, true,
            reason: 'onTap should be called when incomplete habit is tapped');
      });

      testWidgets('does not call onTap when already completed',
          (WidgetTester tester) async {
        final completedHabit = testHabit.copyWith(completedToday: true);
        await tester.pumpWidget(createApp(completedHabit));
        await tester.pump();

        tapCalled = false;
        await tester.tap(find.byType(HabitCompletionCard));
        await tester.pump();

        expect(tapCalled, false,
            reason: 'onTap should not be called when habit already completed');
      });

      testWidgets('does not call onTap when isCompleting is true',
          (WidgetTester tester) async {
        await tester.pumpWidget(createApp(testHabit, isCompleting: true));
        await tester.pump();

        tapCalled = false;
        await tester.tap(find.byType(HabitCompletionCard));
        await tester.pump();

        expect(tapCalled, false,
            reason: 'onTap should not be called during async completion');
      });
    });

    group('Streak Display', () {
      testWidgets('shows current streak with fire icon',
          (WidgetTester tester) async {
        final habitWithStreaks = testHabit.copyWith(
          currentStreak: 7,
          longestStreak: 15,
        );
        await tester.pumpWidget(createApp(habitWithStreaks));
        await tester.pump();

        expect(find.textContaining('7 día'), findsOneWidget,
            reason: 'Current streak should be displayed with text');
        expect(find.byIcon(Icons.local_fire_department), findsOneWidget,
            reason: 'Fire icon for current streak');
      });

      testWidgets('hides streak when zero', (WidgetTester tester) async {
        await tester.pumpWidget(createApp(testHabit));
        await tester.pump();

        expect(find.byIcon(Icons.local_fire_department), findsNothing,
            reason: 'Should not show fire icon when streak is 0');
      });
    });

    group('Edge Cases', () {
      testWidgets('handles multiple rapid taps gracefully',
          (WidgetTester tester) async {
        await tester.pumpWidget(createApp(testHabit));
        await tester.pump();

        // Rapid taps
        await tester.tap(find.byType(HabitCompletionCard));
        await tester.tap(find.byType(HabitCompletionCard));
        await tester.tap(find.byType(HabitCompletionCard));
        await tester.pump();

        // Should handle gracefully without crashing
        expect(find.byType(HabitCompletionCard), findsOneWidget,
            reason: 'Card should still be rendered after rapid taps');
      });

      testWidgets('handles very long habit names', (WidgetTester tester) async {
        final longNameHabit = testHabit.copyWith(
          name:
              'This is a very long habit name that should wrap to multiple lines',
        );
        await tester.pumpWidget(createApp(longNameHabit));
        await tester.pump();

        expect(find.textContaining('This is a very long'), findsOneWidget,
            reason: 'Long habit name should be displayed');
      });

      testWidgets('handles very large streak numbers',
          (WidgetTester tester) async {
        final largeStreakHabit = testHabit.copyWith(
          currentStreak: 999,
          longestStreak: 1234,
        );
        await tester.pumpWidget(createApp(largeStreakHabit));
        await tester.pump();

        expect(find.textContaining('999'), findsOneWidget,
            reason: 'Large current streak number should be displayed');
      });
    });

    group('Localization', () {
      testWidgets('uses localized strings', (WidgetTester tester) async {
        await tester.pumpWidget(createApp(testHabit));
        await tester.pump();

        // Card should render with localized content
        expect(find.byType(HabitCompletionCard), findsOneWidget,
            reason: 'Card with localized content should render');
      });
    });
  });
}
