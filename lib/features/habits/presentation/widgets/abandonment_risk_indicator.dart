import 'package:flutter/material.dart';
import '../../domain/models/risk_level.dart';

/// Visual indicator showing abandonment risk for a habit
/// Displays color-coded dot only:
/// - Low risk (< 0.3): Green dot
/// - Medium risk (0.3-0.65): Orange dot
/// - High risk (> 0.65): Orange dot
class AbandonmentRiskIndicator extends StatelessWidget {
  final double risk; // 0.0-1.0 probability

  const AbandonmentRiskIndicator({super.key, required this.risk});

  @override
  Widget build(BuildContext context) {
    final riskLevel = RiskThresholds.fromValue(risk);

    Color dotColor;
    switch (riskLevel) {
      case RiskLevel.low:
        dotColor = Colors.green;
        break;
      case RiskLevel.medium:
      case RiskLevel.high:
        dotColor = Colors.orange.shade600;
        break;
    }

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
