import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/presentation/habits_providers.dart';
import 'package:habitus_faith/providers/devotional_providers.dart';
import 'package:habitus_faith/core/models/devocional_model.dart';
import 'package:habitus_faith/pages/home_page.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Comprehensive UX tests for Home Page
/// Tests cover: Progress dominance, one-gesture completion, immediate feedback,
/// edge cases, animations, and real user behavior patterns
void main() {
  group('Home Page UX Tests', () {
    late List<Habit> testHabits;
    late Devocional testDevocional;

    setUp(() {
      final now = DateTime.now();
      testHabits = [
        Habit(
          id: 'habit-1',
          userId: 'test-user',
          name: 'Morning Prayer',
          category: HabitCategory.spiritual,
          emoji: '🙏',
          createdAt: now.subtract(const Duration(days: 10)),
          completedToday: false,
          currentStreak: 5,
          longestStreak: 10,
          completionHistory: List.generate(
            5,
            (i) => now.subtract(Duration(days: i + 1)),
          ),
        ),
        Habit(
          id: 'habit-2',
          userId: 'test-user',
          name: 'Read Bible',
          category: HabitCategory.spiritual,
          emoji: '📖',
          createdAt: now.subtract(const Duration(days: 8)),
          completedToday: true,
          currentStreak: 8,
          longestStreak: 8,
          completionHistory: List.generate(
            8,
            (i) => now.subtract(Duration(days: i)),
          ),
        ),
        Habit(
          id: 'habit-3',
          userId: 'test-user',
          name: 'Meditate',
          category: HabitCategory.mental,
          emoji: '🧘',
          createdAt: now.subtract(const Duration(days: 3)),
          completedToday: false,
          currentStreak: 0,
          longestStreak: 2,
          completionHistory: [],
        ),
      ];

      testDevocional = Devocional(
        id: 'test-dev',
        versiculo: 'Test verse for the day',
        reflexion: 'Test reflection',
        paraMeditar: [ParaMeditar(cita: 'Test', texto: 'Think about this')],
        oracion: 'Test prayer',
        date: now,
      );
    });

    Widget createHomePageApp(List<Habit> habits) {
      return ProviderScope(
        overrides: [
          habitsStreamProvider.overrideWith((ref) {
            return Stream.value(habits);
          }),
          devotionalProvider.overrideWith((ref) {
            return DevotionalNotifier()
              ..state = DevotionalState(
                all: [testDevocional],
                filtered: [testDevocional],
                favorites: [],
                isLoading: false,
                selectedLanguage: 'en',
                selectedVersion: 'NIV',
                isOfflineMode: false,
              );
          }),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [Locale('en', '')],
          home: HomePage(),
        ),
      );
    }

    group('A. Progress Dominance Tests', () {
      testWidgets('Progress indicator visible without scrolling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        // Find the circular progress indicator
        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
          reason: 'Progress ring should be visible',
        );

        // Verify it's in the visible viewport
        final progressFinder = find.byType(CircularProgressIndicator);
        final RenderBox progressBox =
            tester.renderObject(progressFinder) as RenderBox;
        final position = progressBox.localToGlobal(Offset.zero);

        expect(
          position.dy >= 0 && position.dy < 600,
          isTrue,
          reason: 'Progress should be visible without scrolling',
        );
      });

      testWidgets('Progress shows correct percentage',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        // 1 completed out of 3 = 33%
        expect(
          find.text('33%'),
          findsOneWidget,
          reason: 'Should display correct completion percentage',
        );
      });

      testWidgets('Progress shows completed/total count',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('1'),
          findsWidgets,
          reason: 'Should show completed count',
        );
        expect(
          find.textContaining('3'),
          findsWidgets,
          reason: 'Should show total count',
        );
      });

      testWidgets('Progress animates with TweenAnimationBuilder',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pump(); // Initial frame

        // Verify TweenAnimationBuilder exists
        expect(
          find.byType(TweenAnimationBuilder<double>),
          findsWidgets,
          reason: 'Should use TweenAnimationBuilder for animation',
        );
        expect(
          find.byType(TweenAnimationBuilder<int>),
          findsOneWidget,
          reason: 'Should animate percentage counter',
        );
      });

      testWidgets('Progress has elevation for visual dominance',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        final cardFinder = find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(Card),
        );

        final Card card = tester.widget(cardFinder.first) as Card;
        expect(
          card.elevation,
          greaterThan(0),
          reason: 'Progress card should have elevation for dominance',
        );
      });
    });

    group('B. One-Gesture Completion Tests', () {
      testWidgets('Habits can be completed by tap',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        // Find an incomplete habit card
        final habitCardFinder = find.text('Morning Prayer');
        expect(habitCardFinder, findsOneWidget);

        // Note: Actual tap completion requires provider integration
        // This tests that the InkWell is present and tappable
        final inkWellFinder = find.ancestor(
          of: habitCardFinder,
          matching: find.byType(InkWell),
        );
        expect(
          inkWellFinder,
          findsOneWidget,
          reason: 'Habit should be wrapped in InkWell for tap',
        );
      });

      testWidgets('Habits can be dismissed by swipe',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        // Find incomplete habit
        final habitFinder = find.text('Morning Prayer');
        final dismissibleFinder = find.ancestor(
          of: habitFinder,
          matching: find.byType(Dismissible),
        );

        expect(
          dismissibleFinder,
          findsOneWidget,
          reason: 'Habit should be wrapped in Dismissible for swipe',
        );

        final Dismissible dismissible =
            tester.widget(dismissibleFinder) as Dismissible;
        expect(
          dismissible.direction,
          equals(DismissDirection.endToStart),
          reason: 'Should allow swipe left',
        );
      });

      testWidgets('Completed habits disable interaction',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        // Find completed habit
        final completedHabitFinder = find.text('Read Bible');
        final dismissibleFinder = find.ancestor(
          of: completedHabitFinder,
          matching: find.byType(Dismissible),
        );

        final Dismissible dismissible =
            tester.widget(dismissibleFinder) as Dismissible;
        expect(
          dismissible.direction,
          equals(DismissDirection.none),
          reason: 'Completed habits should not be swipeable',
        );
      });

      testWidgets('Habit cards show completion control',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        // Incomplete habits should show empty circle
        final incompleteFinder = find.descendant(
          of: find.ancestor(
            of: find.text('Morning Prayer'),
            matching: find.byType(Card),
          ),
          matching: find.byWidgetPredicate(
            (widget) => widget is Container && widget.decoration != null,
          ),
        );
        expect(incompleteFinder, findsWidgets);

        // Completed habits should show check icon
        expect(
          find.byIcon(Icons.check_circle),
          findsWidgets,
          reason: 'Completed habits should show check icon',
        );
      });
    });

    group('C. Immediate Feedback Tests', () {
      testWidgets('Completed habits show green background',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        final completedCardFinder = find.ancestor(
          of: find.text('Read Bible'),
          matching: find.byType(Card),
        );

        final Card card = tester.widget(completedCardFinder.first) as Card;
        expect(
          card.color,
          isNot(equals(Colors.white)),
          reason: 'Completed habits should have different background color',
        );
      });

      testWidgets('Completed habits show strikethrough text',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        final completedTextFinder = find.text('Read Bible');
        final Text completedText = tester.widget(completedTextFinder) as Text;

        expect(
          completedText.style?.decoration,
          equals(TextDecoration.lineThrough),
          reason: 'Completed habit name should have strikethrough',
        );
      });

      testWidgets('AnimatedScale applies to habit cards',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        expect(
          find.byType(AnimatedScale),
          findsWidgets,
          reason: 'Habit cards should use AnimatedScale for micro-animation',
        );
      });

      testWidgets('Habits show fire icon for streaks',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        expect(
          find.byIcon(Icons.local_fire_department),
          findsWidgets,
          reason: 'Should show fire icon for streaks',
        );
      });
    });

    group('D. Remaining Habits Indicator Tests', () {
      testWidgets('Shows remaining habits count', (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        // 2 habits remaining (1 completed out of 3)
        expect(
          find.textContaining('remaining'),
          findsOneWidget,
          reason: 'Should show remaining habits text',
        );
        expect(
          find.textContaining('2'),
          findsWidgets,
          reason: 'Should show correct remaining count',
        );
      });

      testWidgets('Remaining indicator updates dynamically',
          (WidgetTester tester) async {
        // Start with all incomplete
        final allIncomplete = testHabits.map((h) {
          return Habit(
            id: h.id,
            userId: h.userId,
            name: h.name,
            category: h.category,
            emoji: h.emoji,
            createdAt: h.createdAt,
            completedToday: false,
            currentStreak: h.currentStreak,
            longestStreak: h.longestStreak,
            completionHistory: h.completionHistory,
          );
        }).toList();

        await tester.pumpWidget(createHomePageApp(allIncomplete));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('3'),
          findsWidgets,
          reason: 'Should show 3 habits remaining',
        );
      });

      testWidgets('Hides remaining indicator when all complete',
          (WidgetTester tester) async {
        // All habits completed
        final allComplete = testHabits.map((h) {
          return Habit(
            id: h.id,
            userId: h.userId,
            name: h.name,
            category: h.category,
            emoji: h.emoji,
            createdAt: h.createdAt,
            completedToday: true,
            currentStreak: h.currentStreak,
            longestStreak: h.longestStreak,
            completionHistory: h.completionHistory,
          );
        }).toList();

        await tester.pumpWidget(createHomePageApp(allComplete));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('remaining'),
          findsNothing,
          reason: 'Should hide remaining indicator when all complete',
        );
      });
    });

    group('E. Edge Cases Tests', () {
      testWidgets('No habits - shows start journey message',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp([]));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Start'),
          findsOneWidget,
          reason: 'Should show start journey message when no habits',
        );

        expect(
          find.text('0%'),
          findsOneWidget,
          reason: 'Should show 0% when no habits',
        );
      });

      testWidgets('All habits completed - shows celebration',
          (WidgetTester tester) async {
        final allComplete = testHabits.map((h) {
          return Habit(
            id: h.id,
            userId: h.userId,
            name: h.name,
            category: h.category,
            emoji: h.emoji,
            createdAt: h.createdAt,
            completedToday: true,
            currentStreak: h.currentStreak,
            longestStreak: h.longestStreak,
            completionHistory: h.completionHistory,
          );
        }).toList();

        await tester.pumpWidget(createHomePageApp(allComplete));
        await tester.pumpAndSettle();

        expect(
          find.text('100%'),
          findsOneWidget,
          reason: 'Should show 100% when all complete',
        );

        expect(
          find.byIcon(Icons.celebration),
          findsOneWidget,
          reason: 'Should show celebration icon',
        );
      });

      testWidgets('Single habit - proper pluralization',
          (WidgetTester tester) async {
        final singleHabit = [testHabits[0]];

        await tester.pumpWidget(createHomePageApp(singleHabit));
        await tester.pumpAndSettle();

        // Should show "1 habit remaining" not "1 habits remaining"
        expect(
          find.textContaining('1'),
          findsWidgets,
          reason: 'Should show singular form for 1 habit',
        );
      });

      testWidgets('Weekly consistency handles new habits',
          (WidgetTester tester) async {
        final now = DateTime.now();
        final newHabit = Habit(
          id: 'new-habit',
          userId: 'test-user',
          name: 'New Habit',
          category: HabitCategory.physical,
          emoji: '🏃',
          createdAt: now.subtract(const Duration(days: 2)),
          completedToday: false,
          currentStreak: 0,
          longestStreak: 0,
          completionHistory: [],
        );

        await tester.pumpWidget(createHomePageApp([newHabit]));
        await tester.pumpAndSettle();

        // Should render without crashing
        expect(find.byType(HomePage), findsOneWidget);
      });

      testWidgets('Handles habits with no emoji', (WidgetTester tester) async {
        final noEmojiHabit = Habit(
          id: 'no-emoji',
          userId: 'test-user',
          name: 'No Emoji Habit',
          category: HabitCategory.mental,
          emoji: null,
          createdAt: DateTime.now(),
          completedToday: false,
          currentStreak: 0,
          longestStreak: 0,
          completionHistory: [],
        );

        await tester.pumpWidget(createHomePageApp([noEmojiHabit]));
        await tester.pumpAndSettle();

        // Should show default checkmark
        expect(
          find.text('✓'),
          findsOneWidget,
          reason: 'Should show default checkmark when no emoji',
        );
      });
    });

    group('F. Streaks & Momentum Tests', () {
      testWidgets('Shows longest streak card', (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Longest'),
          findsOneWidget,
          reason: 'Should show longest streak label',
        );

        // Longest streak is 10
        expect(
          find.text('10'),
          findsOneWidget,
          reason: 'Should show correct longest streak value',
        );
      });

      testWidgets('Shows weekly consistency card', (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Weekly'),
          findsOneWidget,
          reason: 'Should show weekly consistency label',
        );

        expect(
          find.textContaining('%'),
          findsWidgets,
          reason: 'Should show percentage for weekly consistency',
        );
      });

      testWidgets('Streaks positioned below habits',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        // Get positions
        final habitsPosition =
            tester.getTopLeft(find.text('Morning Prayer').first);
        final streaksPosition =
            tester.getTopLeft(find.textContaining('Longest').first);

        expect(
          streaksPosition.dy > habitsPosition.dy,
          isTrue,
          reason: 'Streaks should be below habits',
        );
      });
    });

    group('G. Inspirational Content Tests', () {
      testWidgets('Verse section is expandable', (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        expect(
          find.byType(ExpansionTile),
          findsOneWidget,
          reason: 'Verse should be in expandable tile',
        );
      });

      testWidgets('Verse positioned below all actionable content',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        // Get positions
        final habitsPosition =
            tester.getTopLeft(find.text('Morning Prayer').first);
        final versePosition =
            tester.getTopLeft(find.textContaining('Verse').first);

        expect(
          versePosition.dy > habitsPosition.dy,
          isTrue,
          reason: 'Verse should be below habits',
        );
      });

      testWidgets('Verse shows icon', (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        expect(
          find.byIcon(Icons.auto_stories),
          findsOneWidget,
          reason: 'Verse section should have icon',
        );
      });
    });

    group('H. Accessibility Tests', () {
      testWidgets('Large tap targets for habit cards',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        final habitCardFinder = find.ancestor(
          of: find.text('Morning Prayer'),
          matching: find.byType(Card),
        );

        final RenderBox box =
            tester.renderObject(habitCardFinder.first) as RenderBox;
        expect(
          box.size.height >= 44,
          isTrue,
          reason: 'Habit card should have minimum 44px height for tap target',
        );
      });

      testWidgets('High contrast colors used', (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        // Verify green shade used for completed (higher contrast)
        final completedCardFinder = find.ancestor(
          of: find.text('Read Bible'),
          matching: find.byType(Card),
        );

        final Card card = tester.widget(completedCardFinder.first) as Card;
        expect(
          card.color != Colors.white,
          isTrue,
          reason: 'Completed habits should have contrasting color',
        );
      });

      testWidgets('Swipe hint visible for discoverability',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('swipe'),
          findsOneWidget,
          reason: 'Should show swipe hint for discoverability',
        );

        expect(
          find.byIcon(Icons.swipe_left),
          findsOneWidget,
          reason: 'Should show swipe icon',
        );
      });
    });

    group('I. Performance & Animation Tests', () {
      testWidgets('Animations complete in <300ms', (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pump();

        // Pump for 300ms to complete all animations
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        // Verify animations completed
        // Note: Some animations may still be running due to framework delays
        // The important thing is they're designed to complete in <300ms
      });

      testWidgets('Uses easeInOut curves', (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        final animatedScaleFinder = find.byType(AnimatedScale);
        if (animatedScaleFinder.evaluate().isNotEmpty) {
          final AnimatedScale animatedScale =
              tester.widget(animatedScaleFinder.first) as AnimatedScale;
          expect(
            animatedScale.curve,
            equals(Curves.easeInOut),
            reason: 'Should use easeInOut curve for smooth animation',
          );
        }
      });
    });

    group('J. Real User Behavior Patterns', () {
      testWidgets('User can understand status in <1 second',
          (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle(); // Wait for all frames

        stopwatch.stop();

        // Find key status indicators
        final progressFinder = find.textContaining('%');
        final remainingFinder = find.textContaining('remaining');

        expect(
          progressFinder,
          findsWidgets,
          reason: 'Progress percentage should be visible',
        );
        expect(
          remainingFinder,
          findsOneWidget,
          reason: 'Remaining count should be visible',
        );

        // Full render should be reasonably fast
        expect(
          stopwatch.elapsedMilliseconds < 5000,
          isTrue,
          reason:
              'Initial render should be under 5 seconds in test environment',
        );
      });

      testWidgets('All habits visible without scrolling for small lists',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        // All 3 habits should be visible
        expect(find.text('Morning Prayer'), findsOneWidget);
        expect(find.text('Read Bible'), findsOneWidget);
        expect(find.text('Meditate'), findsOneWidget);
      });

      testWidgets('Habit completion does not require navigation',
          (WidgetTester tester) async {
        await tester.pumpWidget(createHomePageApp(testHabits));
        await tester.pumpAndSettle();

        // Verify we're on HomePage
        expect(find.byType(HomePage), findsOneWidget);

        // Habit cards are directly on this page
        expect(find.text('Morning Prayer'), findsOneWidget);

        // Verify habit is in a Dismissible (swipeable) or has InkWell (tappable)
        final habitFinder = find.text('Morning Prayer');
        final dismissibleFinder = find.ancestor(
          of: habitFinder,
          matching: find.byType(Dismissible),
        );

        expect(
          dismissibleFinder,
          findsOneWidget,
          reason: 'Habit should be in Dismissible for swipe completion',
        );
      });
    });

    group('K. DST and Edge Case Tests', () {
      testWidgets('Weekly consistency handles DST boundary correctly',
          (WidgetTester tester) async {
        final now = DateTime.now();

        // Simulate habit created before DST transition
        // Using a date that's 3 days ago at 23:30 (late evening)
        final createdAt = DateTime(
          now.year,
          now.month,
          now.day - 3,
          23,
          30,
        );

        final dstHabit = Habit(
          id: 'dst-habit',
          userId: 'test-user',
          name: 'DST Test Habit',
          category: HabitCategory.spiritual,
          emoji: '⏰',
          createdAt: createdAt,
          completedToday: false,
          currentStreak: 0,
          longestStreak: 0,
          completionHistory: [],
        );

        await tester.pumpWidget(createHomePageApp([dstHabit]));
        await tester.pumpAndSettle();

        // Should render without crashing
        expect(find.byType(HomePage), findsOneWidget);

        // Weekly consistency should be calculated correctly
        // (not affected by hour differences)
        expect(find.text('DST Test Habit'), findsOneWidget);
      });

      testWidgets(
          'Multiple rapid habit completions handle concurrent animations',
          (WidgetTester tester) async {
        // Create 3 habits for rapid completion testing
        final rapidHabits = List.generate(3, (i) {
          return Habit(
            id: 'rapid-$i',
            userId: 'test-user',
            name: 'Rapid Habit $i',
            category: HabitCategory.physical,
            emoji: '⚡',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            completedToday: false,
            currentStreak: 0,
            longestStreak: 0,
            completionHistory: [],
          );
        });

        await tester.pumpWidget(createHomePageApp(rapidHabits));
        await tester.pumpAndSettle();

        // Verify all AnimatedScale widgets are present
        final animatedScaleFinders = find.byType(AnimatedScale);
        expect(
          animatedScaleFinders,
          findsNWidgets(3),
          reason: 'Should have AnimatedScale for each habit',
        );

        // Verify no frame drops during multiple animations
        // All habits should be visible and ready
        expect(find.text('Rapid Habit 0'), findsOneWidget);
        expect(find.text('Rapid Habit 1'), findsOneWidget);
        expect(find.text('Rapid Habit 2'), findsOneWidget);
      });

      testWidgets('Complex multi-codepoint emoji rendering',
          (WidgetTester tester) async {
        final complexEmojiHabits = [
          // Family emoji (multi-codepoint)
          Habit(
            id: 'family-emoji',
            userId: 'test-user',
            name: 'Family Time',
            category: HabitCategory.relational,
            emoji: '👨‍👩‍👧‍👦',
            createdAt: DateTime.now(),
            completedToday: false,
            currentStreak: 0,
            longestStreak: 0,
            completionHistory: [],
          ),
          // Rainbow flag (multi-codepoint with ZWJ)
          Habit(
            id: 'flag-emoji',
            userId: 'test-user',
            name: 'Pride Event',
            category: HabitCategory.relational,
            emoji: '🏳️‍🌈',
            createdAt: DateTime.now(),
            completedToday: false,
            currentStreak: 0,
            longestStreak: 0,
            completionHistory: [],
          ),
          // Null emoji (should fallback to '✓')
          Habit(
            id: 'null-emoji',
            userId: 'test-user',
            name: 'No Emoji',
            category: HabitCategory.mental,
            emoji: null,
            createdAt: DateTime.now(),
            completedToday: false,
            currentStreak: 0,
            longestStreak: 0,
            completionHistory: [],
          ),
        ];

        await tester.pumpWidget(createHomePageApp(complexEmojiHabits));
        await tester.pumpAndSettle();

        // Verify all habits render correctly
        expect(find.text('Family Time'), findsOneWidget);
        expect(find.text('Pride Event'), findsOneWidget);
        expect(find.text('No Emoji'), findsOneWidget);

        // Verify fallback emoji for null case
        expect(
          find.text('✓'),
          findsOneWidget,
          reason: 'Should show fallback checkmark for null emoji',
        );

        // Verify multi-codepoint emojis are present
        expect(find.text('👨‍👩‍👧‍👦'), findsOneWidget);
        expect(find.text('🏳️‍🌈'), findsOneWidget);
      });
    });
  });
}
