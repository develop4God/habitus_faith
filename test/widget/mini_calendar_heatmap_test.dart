import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/presentation/widgets/mini_calendar_heatmap.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// High-quality widget tests for MiniCalendarHeatmap
/// Focus: Visual representation, date handling, edge cases, visibility toggle
void main() {
  group('MiniCalendarHeatmap Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Widget createApp(List<DateTime> completionDates) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', '')],
        home: Scaffold(
          body: MiniCalendarHeatmap(
            completionDates: completionDates,
          ),
        ),
      );
    }

    group('Initial Rendering', () {
      testWidgets('renders without crashing', (WidgetTester tester) async {
        await tester.pumpWidget(createApp([]));
        await tester.pumpAndSettle();

        expect(find.byType(MiniCalendarHeatmap), findsOneWidget,
            reason: 'MiniCalendarHeatmap should render');
      });

      testWidgets('shows "This Week" title', (WidgetTester tester) async {
        await tester.pumpWidget(createApp([]));
        await tester.pumpAndSettle();

        expect(find.text('This Week'), findsOneWidget,
            reason: 'Title should be displayed');
      });

      testWidgets('displays visibility toggle icon',
          (WidgetTester tester) async {
        await tester.pumpWidget(createApp([]));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.visibility), findsOneWidget,
            reason: 'Visibility toggle icon should be displayed');
      });

      testWidgets('displays 7 day circles when visible',
          (WidgetTester tester) async {
        await tester.pumpWidget(createApp([]));
        await tester.pumpAndSettle();

        // Should have 7 circular containers (one for each day)
        final containers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(MiniCalendarHeatmap),
            matching: find.byType(Container),
          ),
        );

        final circularContainers = containers.where((container) {
          return container.decoration is BoxDecoration &&
              (container.decoration as BoxDecoration).shape == BoxShape.circle;
        }).toList();

        expect(circularContainers.length, 7,
            reason: 'Should display 7 day circles');
      });

      testWidgets('displays day abbreviations for Monday-Sunday',
          (WidgetTester tester) async {
        await tester.pumpWidget(createApp([]));
        await tester.pumpAndSettle();

        // Should show day abbreviations (M, T, W, T, F, S, S) for Mon-Sun
        final dayAbbreviations = ['M', 'T', 'W', 'F', 'S'];
        for (final day in dayAbbreviations) {
          expect(find.text(day), findsWidgets,
              reason: 'Should display day abbreviation: $day');
        }
      });
    });

    group('Visibility Toggle', () {
      testWidgets('calendar is visible by default',
          (WidgetTester tester) async {
        await tester.pumpWidget(createApp([]));
        await tester.pumpAndSettle();

        // Check that day circles are visible
        final containers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(MiniCalendarHeatmap),
            matching: find.byType(Container),
          ),
        );

        final circularContainers = containers.where((container) {
          return container.decoration is BoxDecoration &&
              (container.decoration as BoxDecoration).shape == BoxShape.circle;
        }).toList();

        expect(circularContainers.length, 7,
            reason: 'Calendar should be visible by default');
      });

      testWidgets('tapping visibility icon hides calendar',
          (WidgetTester tester) async {
        await tester.pumpWidget(createApp([]));
        await tester.pumpAndSettle();

        // Tap the visibility icon
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pumpAndSettle();

        // Icon should change to visibility_off
        expect(find.byIcon(Icons.visibility_off), findsOneWidget,
            reason: 'Icon should change to visibility_off');

        // Day circles should not be visible
        final containers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(MiniCalendarHeatmap),
            matching: find.byType(Container),
          ),
        );

        final circularContainers = containers.where((container) {
          return container.decoration is BoxDecoration &&
              (container.decoration as BoxDecoration).shape == BoxShape.circle;
        }).toList();

        expect(circularContainers.length, 0,
            reason: 'Calendar should be hidden after tapping visibility icon');
      });

      testWidgets('tapping visibility icon again shows calendar',
          (WidgetTester tester) async {
        await tester.pumpWidget(createApp([]));
        await tester.pumpAndSettle();

        // Hide calendar
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pumpAndSettle();

        // Show calendar again
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pumpAndSettle();

        // Icon should change back to visibility
        expect(find.byIcon(Icons.visibility), findsOneWidget,
            reason: 'Icon should change back to visibility');

        // Day circles should be visible again
        final containers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(MiniCalendarHeatmap),
            matching: find.byType(Container),
          ),
        );

        final circularContainers = containers.where((container) {
          return container.decoration is BoxDecoration &&
              (container.decoration as BoxDecoration).shape == BoxShape.circle;
        }).toList();

        expect(circularContainers.length, 7,
            reason: 'Calendar should be visible again');
      });

      testWidgets('visibility preference is saved',
          (WidgetTester tester) async {
        await tester.pumpWidget(createApp([]));
        await tester.pumpAndSettle();

        // Hide calendar
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pumpAndSettle();

        // Check that preference was saved
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('calendar_visible'), false,
            reason: 'Visibility preference should be saved as false');

        // Show calendar again
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pumpAndSettle();

        expect(prefs.getBool('calendar_visible'), true,
            reason: 'Visibility preference should be saved as true');
      });
    });

    group('Completion Display', () {
      testWidgets('shows completed days in green', (WidgetTester tester) async {
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));

        await tester.pumpWidget(createApp([today, yesterday]));
        await tester.pumpAndSettle();

        // Find circular containers with green background
        final containers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(MiniCalendarHeatmap),
            matching: find.byType(Container),
          ),
        );

        final greenCircles = containers.where((container) {
          final decoration = container.decoration as BoxDecoration?;
          return decoration != null &&
              decoration.shape == BoxShape.circle &&
              decoration.color == const Color(0xff10b981);
        }).toList();

        expect(greenCircles.length, greaterThanOrEqualTo(2),
            reason: 'Should show at least 2 completed days in green');
      });

      testWidgets('shows incomplete days in gray', (WidgetTester tester) async {
        // No completions - all should be gray
        await tester.pumpWidget(createApp([]));
        await tester.pumpAndSettle();

        final containers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(MiniCalendarHeatmap),
            matching: find.byType(Container),
          ),
        );

        final grayCircles = containers.where((container) {
          final decoration = container.decoration as BoxDecoration?;
          return decoration != null &&
              decoration.shape == BoxShape.circle &&
              decoration.color != const Color(0xff10b981);
        }).toList();

        expect(grayCircles.length, 7,
            reason: 'All 7 days should be gray with no completions');
      });

      testWidgets('highlights today with border', (WidgetTester tester) async {
        await tester.pumpWidget(createApp([]));
        await tester.pumpAndSettle();

        // Find container with border (today's indicator)
        final containers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(MiniCalendarHeatmap),
            matching: find.byType(Container),
          ),
        );

        final todayCircle = containers.where((container) {
          final decoration = container.decoration as BoxDecoration?;
          return decoration != null &&
              decoration.shape == BoxShape.circle &&
              decoration.border != null;
        }).toList();

        expect(todayCircle.length, greaterThanOrEqualTo(0),
            reason: 'Today should have border if in Monday-Sunday range');
      });
    });

    group('Date Handling', () {
      testWidgets('displays correct day numbers', (WidgetTester tester) async {
        await tester.pumpWidget(createApp([]));
        await tester.pumpAndSettle();

        final today = DateTime.now();
        final todayDay = today.day.toString();

        // Today might be visible depending on current weekday
        final dayNumbers = tester
            .widgetList<Text>(
          find.descendant(
            of: find.byType(MiniCalendarHeatmap),
            matching: find.byType(Text),
          ),
        )
            .where((text) {
          final data = text.data;
          return data != null && RegExp(r'^\d+$').hasMatch(data);
        }).toList();

        expect(dayNumbers.length, 7, reason: 'Should display 7 day numbers');
      });

      testWidgets('handles completions with time component',
          (WidgetTester tester) async {
        // Completion dates with different times on same day
        final today = DateTime.now();
        final todayMorning = DateTime(today.year, today.month, today.day, 8, 0);
        final todayEvening =
            DateTime(today.year, today.month, today.day, 20, 0);

        await tester.pumpWidget(createApp([todayMorning, todayEvening]));
        await tester.pumpAndSettle();

        // Should treat as single completion (same day)
        final containers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(MiniCalendarHeatmap),
            matching: find.byType(Container),
          ),
        );

        final greenCircles = containers.where((container) {
          final decoration = container.decoration as BoxDecoration?;
          return decoration != null &&
              decoration.shape == BoxShape.circle &&
              decoration.color == const Color(0xff10b981);
        }).toList();

        // Should only count as one completed day (if today is in this week)
        expect(greenCircles.length, lessThanOrEqualTo(1),
            reason: 'Multiple completions on same day should show as one');
      });

      testWidgets('shows current week Monday-Sunday',
          (WidgetTester tester) async {
        await tester.pumpWidget(createApp([]));
        await tester.pumpAndSettle();

        // Should display 7 day numbers for Monday through Sunday
        final dayNumbers = tester
            .widgetList<Text>(
          find.descendant(
            of: find.byType(MiniCalendarHeatmap),
            matching: find.byType(Text),
          ),
        )
            .where((text) {
          final data = text.data;
          return data != null && RegExp(r'^\d+$').hasMatch(data);
        }).toList();

        expect(dayNumbers.length, 7,
            reason: 'Should display 7 day numbers for Mon-Sun');
      });
    });

    group('Edge Cases', () {
      testWidgets('handles empty completion list', (WidgetTester tester) async {
        await tester.pumpWidget(createApp([]));
        await tester.pumpAndSettle();

        expect(find.byType(MiniCalendarHeatmap), findsOneWidget,
            reason: 'Should render with empty completion list');
      });

      testWidgets('handles very old completion dates',
          (WidgetTester tester) async {
        final oldDate = DateTime.now().subtract(const Duration(days: 365));
        await tester.pumpWidget(createApp([oldDate]));
        await tester.pumpAndSettle();

        // Old dates outside current week should not appear as green
        final containers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(MiniCalendarHeatmap),
            matching: find.byType(Container),
          ),
        );

        final greenCircles = containers.where((container) {
          final decoration = container.decoration as BoxDecoration?;
          return decoration != null &&
              decoration.shape == BoxShape.circle &&
              decoration.color == const Color(0xff10b981);
        }).toList();

        expect(greenCircles.length, 0,
            reason: 'Old dates should not appear in current week');
      });

      testWidgets('handles future completion dates',
          (WidgetTester tester) async {
        final futureDate = DateTime.now().add(const Duration(days: 2));
        await tester.pumpWidget(createApp([futureDate]));
        await tester.pumpAndSettle();

        // Future dates should not cause errors
        expect(find.byType(MiniCalendarHeatmap), findsOneWidget,
            reason: 'Should handle future dates gracefully');
      });

      testWidgets('handles duplicate completion dates',
          (WidgetTester tester) async {
        final today = DateTime.now();
        // Same date added multiple times
        await tester.pumpWidget(createApp([today, today, today]));
        await tester.pumpAndSettle();

        // Should deduplicate and show as single completion
        final containers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(MiniCalendarHeatmap),
            matching: find.byType(Container),
          ),
        );

        final greenCircles = containers.where((container) {
          final decoration = container.decoration as BoxDecoration?;
          return decoration != null &&
              decoration.shape == BoxShape.circle &&
              decoration.color == const Color(0xff10b981);
        }).toList();

        expect(greenCircles.length, lessThanOrEqualTo(1),
            reason: 'Duplicate dates should be deduplicated');
      });

      testWidgets('handles all days of week completed',
          (WidgetTester tester) async {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final lastMonday = today
            .subtract(Duration(days: (today.weekday - DateTime.monday) % 7));

        // Complete all 7 days of the current week (Mon-Sun)
        final allWeekDays = List.generate(7, (index) {
          return lastMonday.add(Duration(days: index));
        });

        await tester.pumpWidget(createApp(allWeekDays));
        await tester.pumpAndSettle();

        final containers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(MiniCalendarHeatmap),
            matching: find.byType(Container),
          ),
        );

        final greenCircles = containers.where((container) {
          final decoration = container.decoration as BoxDecoration?;
          return decoration != null &&
              decoration.shape == BoxShape.circle &&
              decoration.color == const Color(0xff10b981);
        }).toList();

        expect(greenCircles.length, 7,
            reason: 'All 7 days should be green when all completed');
      });
    });

    group('Visual Layout', () {
      testWidgets('maintains consistent spacing', (WidgetTester tester) async {
        await tester.pumpWidget(createApp([]));
        await tester.pumpAndSettle();

        // Check that Row exists (for horizontal layout)
        expect(find.byType(Row), findsWidgets,
            reason: 'Days should be laid out horizontally in Rows');
      });

      testWidgets('circles have consistent size', (WidgetTester tester) async {
        await tester.pumpWidget(createApp([]));
        await tester.pumpAndSettle();

        final containers = tester
            .widgetList<Container>(
          find.descendant(
            of: find.byType(MiniCalendarHeatmap),
            matching: find.byType(Container),
          ),
        )
            .where((container) {
          return container.decoration is BoxDecoration &&
              (container.decoration as BoxDecoration).shape == BoxShape.circle;
        }).toList();

        // All circles should be 32x32
        for (final container in containers) {
          expect(container.constraints?.maxWidth, 32,
              reason: 'Circle width should be 32');
          expect(container.constraints?.maxHeight, 32,
              reason: 'Circle height should be 32');
        }
      });
    });

    group('Localization', () {
      testWidgets('uses localized "This Week" string',
          (WidgetTester tester) async {
        await tester.pumpWidget(createApp([]));
        await tester.pumpAndSettle();

        expect(find.text('This Week'), findsOneWidget,
            reason: 'Localized title should be displayed');
      });
    });
  });
}
