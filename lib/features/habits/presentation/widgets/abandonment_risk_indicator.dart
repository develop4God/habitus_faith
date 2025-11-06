import 'package:flutter/material.dart';

/// Visual indicator showing abandonment risk for a habit
/// Displays color-coded dot and text based on risk level:
/// - Low risk (< 0.3): Green dot, no text
/// - Medium risk (0.3-0.65): Yellow dot, "At risk"
/// - High risk (> 0.65): Red dot, "High risk" with warning icon
class AbandonmentRiskIndicator extends StatelessWidget {
  final double risk; // 0.0-1.0 probability

  const AbandonmentRiskIndicator({
    super.key,
    required this.risk,
  });

  @override
  Widget build(BuildContext context) {
    // Low risk - don't show anything intrusive
    if (risk < 0.3) {
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
    }

    // Medium risk - show yellow indicator
    if (risk < 0.65) {
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
            'At risk',
            style: TextStyle(
              fontSize: 11,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    // High risk - show red indicator with warning
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
          'High risk',
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
