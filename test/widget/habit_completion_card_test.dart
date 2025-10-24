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
        name: 'Morning Prayer',
        description: 'Pray each morning',
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

      testWidgets('displays default emoji when none provided',
          (WidgetTester tester) async {
        final habitWithoutEmoji = testHabit.copyWith(emoji: null);
        await tester.pumpWidget(createApp(habitWithoutEmoji));
        await tester.pump();

        expect(find.text('✨'), findsOneWidget,
            reason: 'Default emoji should be displayed when none provided');
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
        expect(find.text('5'), findsOneWidget,
            reason: 'Current streak number should be displayed');
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
      testWidgets('incomplete habit has elevated appearance',
          (WidgetTester tester) async {
        await tester.pumpWidget(createApp(testHabit));
        await tester.pump();

        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, 3,
            reason: 'Incomplete habit should have elevation of 3');
      });

      testWidgets('completed habit has border and lower elevation',
          (WidgetTester tester) async {
        final completedHabit = testHabit.copyWith(completedToday: true);
        await tester.pumpWidget(createApp(completedHabit));
        await tester.pump();

        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, 1,
            reason: 'Completed habit should have elevation of 1');
        
        final shape = card.shape as RoundedRectangleBorder;
        expect(shape.side.color, const Color(0xff10b981),
            reason: 'Completed habit should have green border');
        expect(shape.side.width, 2,
            reason: 'Border should be 2 pixels wide');
      });

      testWidgets('shows checkmark icon when completed',
          (WidgetTester tester) async {
        final completedHabit = testHabit.copyWith(completedToday: true);
        await tester.pumpWidget(createApp(completedHabit));
        await tester.pump();

        expect(find.byIcon(Icons.check_circle), findsOneWidget,
            reason: 'Checkmark icon should be displayed for completed habit');
      });

      testWidgets('does not show checkmark when incomplete',
          (WidgetTester tester) async {
        await tester.pumpWidget(createApp(testHabit));
        await tester.pump();

        expect(find.byIcon(Icons.check_circle), findsNothing,
            reason: 'Checkmark should not be displayed for incomplete habit');
      });
    });

    group('Tap Interaction', () {
      testWidgets('calls onTap when tapped and incomplete',
          (WidgetTester tester) async {
        await tester.pumpWidget(createApp(testHabit));
        await tester.pump();

        tapCalled = false;
        await tester.tap(find.byType(HabitCompletionCard));
        await tester.pumpAndSettle(); // Wait for animation

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
      testWidgets('shows both current and longest streaks',
          (WidgetTester tester) async {
        final habitWithStreaks = testHabit.copyWith(
          currentStreak: 7,
          longestStreak: 15,
        );
        await tester.pumpWidget(createApp(habitWithStreaks));
        await tester.pump();

        expect(find.text('7'), findsOneWidget,
            reason: 'Current streak should be displayed');
        expect(find.text('15'), findsOneWidget,
            reason: 'Longest streak should be displayed');
        expect(find.byIcon(Icons.local_fire_department), findsOneWidget,
            reason: 'Fire icon for current streak');
        expect(find.byIcon(Icons.emoji_events), findsOneWidget,
            reason: 'Trophy icon for longest streak');
      });

      testWidgets('shows zero streaks correctly', (WidgetTester tester) async {
        await tester.pumpWidget(createApp(testHabit));
        await tester.pump();

        expect(find.text('0'), findsNWidgets(2),
            reason: 'Both streaks should show 0 initially');
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
          name: 'This is a very long habit name that should wrap to multiple lines',
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

        expect(find.text('999'), findsOneWidget,
            reason: 'Large current streak number should be displayed');
        expect(find.text('1234'), findsOneWidget,
            reason: 'Large longest streak number should be displayed');
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
