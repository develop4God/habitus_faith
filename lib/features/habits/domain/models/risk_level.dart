/// Risk level classification for habit abandonment
enum RiskLevel {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'At Risk';
      case RiskLevel.high:
        return 'High Risk';
    }
  }

  String get description {
    switch (this) {
      case RiskLevel.low:
        return 'You\'re doing great! Keep up the good work.';
      case RiskLevel.medium:
        return 'We notice some inconsistency. Consider adjusting your approach.';
      case RiskLevel.high:
        return 'High risk of abandonment. Let\'s make this easier to maintain.';
    }
  }
}

/// Risk level thresholds for habit abandonment
class RiskThresholds {
  /// Threshold between low and medium risk
  static const double mediumRiskThreshold = 0.3;

  /// Threshold between medium and high risk
  static const double highRiskThreshold = 0.65;

  /// Classify risk value into a RiskLevel
  static RiskLevel fromValue(double risk) {
    if (risk < mediumRiskThreshold) return RiskLevel.low;
    if (risk < highRiskThreshold) return RiskLevel.medium;
    return RiskLevel.high;
  }

  /// Check if risk is at or above intervention threshold
  static bool requiresIntervention(double risk) {
    return risk >= highRiskThreshold;
  }
}
