import 'package:flutter/material.dart';
import '../../domain/models/risk_level.dart';

/// Visual indicator showing abandonment risk for a habit
/// Displays color-coded dot and text based on risk level:
/// - Low risk (< 0.3): Green dot, no text
/// - Medium risk (0.3-0.65): Yellow dot, "At risk"
/// - High risk (> 0.65): Red dot, "High risk" with warning icon
class AbandonmentRiskIndicator extends StatelessWidget {
  final double risk; // 0.0-1.0 probability

  const AbandonmentRiskIndicator({super.key, required this.risk});

  @override
  Widget build(BuildContext context) {
    final riskLevel = RiskThresholds.fromValue(risk);

    switch (riskLevel) {
      case RiskLevel.low:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );

      case RiskLevel.medium:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.orange.shade600,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              riskLevel.displayName,
              style: TextStyle(
                fontSize: 11,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

      case RiskLevel.high:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              riskLevel.displayName,
              style: TextStyle(
                fontSize: 11,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.warning_amber_rounded,
              size: 14,
              color: Colors.red.shade700,
            ),
          ],
        );
    }
  }
}
