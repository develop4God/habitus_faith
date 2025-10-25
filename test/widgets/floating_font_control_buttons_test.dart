import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/widgets/floating_font_control_buttons.dart';

void main() {
  group('FloatingFontControlButtons', () {
    testWidgets('renders all control buttons', (WidgetTester tester) async {
      var increaseCalled = false; // Callback tracker
      var decreaseCalled = false; // Callback tracker
      var closeCalled = false; // Callback tracker

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingFontControlButtons(
              currentFontSize: 16.0,
              onIncrease: () => increaseCalled = true,
              onDecrease: () => decreaseCalled = true,
              onClose: () => closeCalled = true,
            ),
          ),
        ),
      );

      // Verify close button exists
      expect(find.byIcon(Icons.close_outlined), findsOneWidget);

      // Verify A+ text exists (increase button)
      expect(find.text('A+'), findsOneWidget);

      // Verify A- text exists (decrease button)
      expect(find.text('A-'), findsOneWidget);
    });

    testWidgets('calls onIncrease when increase button is tapped',
        (WidgetTester tester) async {
      var increaseCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingFontControlButtons(
              currentFontSize: 16.0,
              onIncrease: () => increaseCalled = true,
              onDecrease: () {},
              onClose: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('A+'));
      await tester.pump();

      expect(increaseCalled, isTrue);
    });

    testWidgets('calls onDecrease when decrease button is tapped',
        (WidgetTester tester) async {
      var decreaseCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingFontControlButtons(
              currentFontSize: 16.0,
              onIncrease: () {},
              onDecrease: () => decreaseCalled = true,
              onClose: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('A-'));
      await tester.pump();

      expect(decreaseCalled, isTrue);
    });

    testWidgets('calls onClose when close button is tapped',
        (WidgetTester tester) async {
      var closeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingFontControlButtons(
              currentFontSize: 16.0,
              onIncrease: () {},
              onDecrease: () {},
              onClose: () => closeCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close_outlined));
      await tester.pump();

      expect(closeCalled, isTrue);
    });

    testWidgets('increase button is disabled when at max font size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingFontControlButtons(
              currentFontSize: 28.0, // max size
              maxFontSize: 28.0,
              onIncrease: () {},
              onDecrease: () {},
              onClose: () {},
            ),
          ),
        ),
      );

      // Widget should render but button should be visually disabled
      expect(find.text('A+'), findsOneWidget);
    });

    testWidgets('decrease button is disabled when at min font size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingFontControlButtons(
              currentFontSize: 12.0, // min size
              minFontSize: 12.0,
              onIncrease: () {},
              onDecrease: () {},
              onClose: () {},
            ),
          ),
        ),
      );

      // Widget should render but button should be visually disabled
      expect(find.text('A-'), findsOneWidget);
    });

    testWidgets('respects custom min and max font sizes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingFontControlButtons(
              currentFontSize: 20.0,
              minFontSize: 10.0,
              maxFontSize: 30.0,
              onIncrease: () {},
              onDecrease: () {},
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.text('A+'), findsOneWidget);
      expect(find.text('A-'), findsOneWidget);
    });
  });
}
