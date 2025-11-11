import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/presentation/widgets/abandonment_risk_indicator.dart';
import 'package:habitus_faith/features/habits/domain/models/risk_level.dart';

void main() {
  group('AbandonmentRiskIndicator', () {
    testWidgets('shows green dot for low risk (< 0.3)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AbandonmentRiskIndicator(risk: 0.2)),
        ),
      );

      // Should show green dot
      final greenDot = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == Colors.green,
      );
      expect(greenDot, findsOneWidget);

      // Should not show text for low risk
      expect(find.text('At Risk'), findsNothing);
      expect(find.text('High Risk'), findsNothing);
    });

    testWidgets('shows orange indicator with text for medium risk (0.3-0.65)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AbandonmentRiskIndicator(risk: 0.5)),
        ),
      );

      // Should show orange dot
      final orangeDot = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color ==
                Colors.orange.shade600,
      );
      expect(orangeDot, findsOneWidget);

      // Should show "At Risk" text
      expect(find.text('At Risk'), findsOneWidget);
    });

    testWidgets(
      'shows red indicator with warning icon for high risk (> 0.65)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: AbandonmentRiskIndicator(risk: 0.8)),
          ),
        );

        // Should show red dot
        final redDot = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color == Colors.red,
        );
        expect(redDot, findsOneWidget);

        // Should show "High Risk" text
        expect(find.text('High Risk'), findsOneWidget);

        // Should show warning icon
        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      },
    );

    testWidgets('handles edge case risk = mediumRiskThreshold (boundary)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AbandonmentRiskIndicator(
              risk: RiskThresholds.mediumRiskThreshold,
            ),
          ),
        ),
      );

      // Should show medium risk (orange)
      expect(find.text('At Risk'), findsOneWidget);
    });

    testWidgets('handles edge case risk = highRiskThreshold (boundary)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AbandonmentRiskIndicator(
              risk: RiskThresholds.highRiskThreshold,
            ),
          ),
        ),
      );

      // Should show high risk (red)
      expect(find.text('High Risk'), findsOneWidget);
    });

    testWidgets('handles risk = 0.0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AbandonmentRiskIndicator(risk: 0.0)),
        ),
      );

      // Should show low risk (green)
      final greenDot = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == Colors.green,
      );
      expect(greenDot, findsOneWidget);
    });

    testWidgets('handles risk = 1.0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AbandonmentRiskIndicator(risk: 1.0)),
        ),
      );

      // Should show high risk (red)
      expect(find.text('High Risk'), findsOneWidget);
    });
  });
}
