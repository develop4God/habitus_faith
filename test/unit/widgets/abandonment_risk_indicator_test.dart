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
    });

    testWidgets('shows orange indicator for medium risk (0.3-0.65)', (
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
    });

    testWidgets(
      'shows orange indicator for high risk (> 0.65)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: AbandonmentRiskIndicator(risk: 0.8)),
          ),
        );

        // Should show orange dot (high risk also shows orange per implementation)
        final orangeDot = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color ==
                  Colors.orange.shade600,
        );
        expect(orangeDot, findsOneWidget);
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

      // At boundary (0.3), should show orange (medium risk)
      final orangeDot = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color ==
                Colors.orange.shade600,
      );
      expect(orangeDot, findsOneWidget);
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

      // At boundary (0.65), should show orange (high risk per implementation)
      final orangeDot = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color ==
                Colors.orange.shade600,
      );
      expect(orangeDot, findsOneWidget);
    });

    testWidgets('handles risk = 1.0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AbandonmentRiskIndicator(risk: 1.0)),
        ),
      );

      // Maximum risk should show orange
      final orangeDot = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color ==
                Colors.orange.shade600,
      );
      expect(orangeDot, findsOneWidget);
    });
  });
}
