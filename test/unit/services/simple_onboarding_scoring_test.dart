import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/services/simple_onboarding_scoring.dart';

void main() {
  group('SimpleOnboardingScoring', () {
    group('calculateScore', () {
      test('minimum score (4): 1 goal + short time + newbie', () {
        final score = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.faith],
          timeCommitment: TimeCommitment.short,
          experienceLevel: ExperienceLevel.newbie,
        );

        expect(score.totalScore, equals(4)); // 1*2 + 1 + 1 = 4
        expect(score.level, equals(ScoreLevel.basic));
        expect(score.primaryIntent, equals('faithBased'));
      });

      test('maximum score (12): 3 goals + long time + consistent', () {
        final score = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.faith, GoalType.wellness, GoalType.study],
          timeCommitment: TimeCommitment.long,
          experienceLevel: ExperienceLevel.consistent,
        );

        expect(score.totalScore, equals(12)); // 3*2 + 3 + 3 = 12
        expect(score.level, equals(ScoreLevel.advanced));
        expect(score.primaryIntent, equals('faithBased')); // Faith has priority
      });

      test('intermediate score (8): 2 goals + medium time + growing', () {
        final score = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.wellness, GoalType.study],
          timeCommitment: TimeCommitment.medium,
          experienceLevel: ExperienceLevel.growing,
        );

        expect(score.totalScore, equals(8)); // 2*2 + 2 + 2 = 8
        expect(score.level, equals(ScoreLevel.intermediate));
        expect(
            score.primaryIntent, equals('wellness')); // Wellness has priority
      });

      test('score level boundaries: basic (4-6)', () {
        // Score = 6
        final score = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.peace],
          timeCommitment: TimeCommitment.medium,
          experienceLevel: ExperienceLevel.growing,
        );

        expect(score.totalScore, equals(6)); // 1*2 + 2 + 2 = 6
        expect(score.level, equals(ScoreLevel.basic));
      });

      test('score level boundaries: intermediate (7-9)', () {
        // Score = 8
        final score = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.faith, GoalType.wellness],
          timeCommitment: TimeCommitment.medium,
          experienceLevel: ExperienceLevel.growing,
        );

        expect(score.totalScore, equals(8)); // 2*2 + 2 + 2 = 8
        expect(score.level, equals(ScoreLevel.intermediate));
      });

      test('score level boundaries: advanced (10+)', () {
        // Score = 10
        final score = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.faith, GoalType.wellness],
          timeCommitment: TimeCommitment.long,
          experienceLevel: ExperienceLevel.consistent,
        );

        expect(score.totalScore, equals(10)); // 2*2 + 3 + 3 = 10
        expect(score.level, equals(ScoreLevel.advanced));
      });
    });

    group('primary intent logic', () {
      test('single goal: faith -> faithBased', () {
        final score = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.faith],
          timeCommitment: TimeCommitment.medium,
          experienceLevel: ExperienceLevel.growing,
        );

        expect(score.primaryIntent, equals('faithBased'));
      });

      test('single goal: wellness -> wellness', () {
        final score = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.wellness],
          timeCommitment: TimeCommitment.medium,
          experienceLevel: ExperienceLevel.growing,
        );

        expect(score.primaryIntent, equals('wellness'));
      });

      test('single goal: study -> study', () {
        final score = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.study],
          timeCommitment: TimeCommitment.medium,
          experienceLevel: ExperienceLevel.growing,
        );

        expect(score.primaryIntent, equals('study'));
      });

      test('single goal: peace -> peace', () {
        final score = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.peace],
          timeCommitment: TimeCommitment.medium,
          experienceLevel: ExperienceLevel.growing,
        );

        expect(score.primaryIntent, equals('peace'));
      });

      test('multiple goals with faith: faith has priority', () {
        final score = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.wellness, GoalType.faith, GoalType.study],
          timeCommitment: TimeCommitment.medium,
          experienceLevel: ExperienceLevel.growing,
        );

        expect(score.primaryIntent, equals('faithBased'));
      });

      test('multiple goals without faith: wellness has priority', () {
        final score = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.study, GoalType.wellness, GoalType.peace],
          timeCommitment: TimeCommitment.medium,
          experienceLevel: ExperienceLevel.growing,
        );

        expect(score.primaryIntent, equals('wellness'));
      });

      test('multiple goals: study + peace -> mixed', () {
        final score = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.study, GoalType.peace],
          timeCommitment: TimeCommitment.medium,
          experienceLevel: ExperienceLevel.growing,
        );

        expect(score.primaryIntent, equals('mixed'));
      });
    });

    group('edge cases', () {
      test('throws ArgumentError when goals is empty', () {
        expect(
          () => SimpleOnboardingScoring.calculateScore(
            goals: [],
            timeCommitment: TimeCommitment.medium,
            experienceLevel: ExperienceLevel.growing,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError when more than 3 goals', () {
        expect(
          () => SimpleOnboardingScoring.calculateScore(
            goals: [
              GoalType.faith,
              GoalType.wellness,
              GoalType.study,
              GoalType.peace
            ],
            timeCommitment: TimeCommitment.medium,
            experienceLevel: ExperienceLevel.growing,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('exactly 3 goals is valid', () {
        final score = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.faith, GoalType.wellness, GoalType.study],
          timeCommitment: TimeCommitment.medium,
          experienceLevel: ExperienceLevel.growing,
        );

        expect(score.goals.length, equals(3));
        expect(score.totalScore, equals(10)); // 3*2 + 2 + 2 = 10
      });
    });

    group('getScoreLevelLabel', () {
      test('basic level label', () {
        final score = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.faith],
          timeCommitment: TimeCommitment.short,
          experienceLevel: ExperienceLevel.newbie,
        );

        expect(score.getScoreLevelLabel(), equals('Empezando · Paso a paso'));
      });

      test('intermediate level label', () {
        final score = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.faith, GoalType.wellness],
          timeCommitment: TimeCommitment.medium,
          experienceLevel: ExperienceLevel.growing,
        );

        expect(score.getScoreLevelLabel(),
            equals('Creciendo · Ritmo sostenible'));
      });

      test('advanced level label', () {
        final score = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.faith, GoalType.wellness, GoalType.study],
          timeCommitment: TimeCommitment.long,
          experienceLevel: ExperienceLevel.consistent,
        );

        expect(score.getScoreLevelLabel(),
            equals('Comprometido · Desafío constante'));
      });
    });

    group('all score combinations (4-12 range)', () {
      test('score range validation', () {
        final scores = <int>[];

        // Test various combinations
        for (final goalCount in [1, 2, 3]) {
          final goals = [GoalType.faith, GoalType.wellness, GoalType.study]
              .take(goalCount)
              .toList();

          for (final time in TimeCommitment.values) {
            for (final level in ExperienceLevel.values) {
              final score = SimpleOnboardingScoring.calculateScore(
                goals: goals,
                timeCommitment: time,
                experienceLevel: level,
              );
              scores.add(score.totalScore);
            }
          }
        }

        // Verify we have scores in the expected range
        expect(scores.every((s) => s >= 4 && s <= 12), isTrue);
        expect(scores.reduce((a, b) => a < b ? a : b),
            equals(4)); // Min score
        expect(scores.reduce((a, b) => a > b ? a : b),
            equals(12)); // Max score
      });
    });
  });
}
