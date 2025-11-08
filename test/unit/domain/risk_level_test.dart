import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/models/risk_level.dart';

void main() {
  group('RiskThresholds', () {
    test('classifies low risk correctly', () {
      expect(RiskThresholds.fromValue(0.0), RiskLevel.low);
      expect(RiskThresholds.fromValue(0.1), RiskLevel.low);
      expect(RiskThresholds.fromValue(0.29), RiskLevel.low);
    });

    test('classifies medium risk correctly', () {
      expect(RiskThresholds.fromValue(0.3), RiskLevel.medium);
      expect(RiskThresholds.fromValue(0.4), RiskLevel.medium);
      expect(RiskThresholds.fromValue(0.64), RiskLevel.medium);
    });

    test('classifies high risk correctly', () {
      expect(RiskThresholds.fromValue(0.65), RiskLevel.high);
      expect(RiskThresholds.fromValue(0.8), RiskLevel.high);
      expect(RiskThresholds.fromValue(1.0), RiskLevel.high);
    });

    test('requiresIntervention returns correct values', () {
      expect(RiskThresholds.requiresIntervention(0.0), false);
      expect(RiskThresholds.requiresIntervention(0.3), false);
      expect(RiskThresholds.requiresIntervention(0.64), false);
      expect(RiskThresholds.requiresIntervention(0.65), true);
      expect(RiskThresholds.requiresIntervention(0.8), true);
      expect(RiskThresholds.requiresIntervention(1.0), true);
    });
  });

  group('RiskLevel', () {
    test('has correct display names', () {
      expect(RiskLevel.low.displayName, 'Low Risk');
      expect(RiskLevel.medium.displayName, 'At Risk');
      expect(RiskLevel.high.displayName, 'High Risk');
    });

    test('has descriptions for all levels', () {
      expect(RiskLevel.low.description, isNotEmpty);
      expect(RiskLevel.medium.description, isNotEmpty);
      expect(RiskLevel.high.description, isNotEmpty);
    });
  });
}
