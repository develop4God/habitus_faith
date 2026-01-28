import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/services/simple_onboarding_scoring.dart';
import 'package:habitus_faith/features/habits/domain/services/simple_template_selector.dart';

void main() {
  group('SimpleTemplateSelector', () {
    group('selectTemplates', () {
      test('faithBased + basic -> prayer_5min equivalent', () {
        const score = OnboardingScore(
          totalScore: 4,
          level: ScoreLevel.basic,
          primaryIntent: PrimaryIntent.faithBased,
          goals: [GoalType.faith],
          timeCommitment: TimeCommitment.short,
          experienceLevel: ExperienceLevel.newbie,
        );

        final templates = SimpleTemplateSelector.selectTemplates(score);

        expect(templates, equals(['morning_prayer']));
      });

      test('faithBased + intermediate -> prayer + bible', () {
        const score = OnboardingScore(
          totalScore: 7,
          level: ScoreLevel.intermediate,
          primaryIntent: PrimaryIntent.faithBased,
          goals: [GoalType.faith, GoalType.study],
          timeCommitment: TimeCommitment.medium,
          experienceLevel: ExperienceLevel.growing,
        );

        final templates = SimpleTemplateSelector.selectTemplates(score);

        expect(templates, equals(['morning_prayer', 'bible_reading']));
      });

      test('faithBased + advanced -> prayer + bible + gratitude', () {
        const score = OnboardingScore(
          totalScore: 10,
          level: ScoreLevel.advanced,
          primaryIntent: PrimaryIntent.faithBased,
          goals: [GoalType.faith, GoalType.wellness],
          timeCommitment: TimeCommitment.long,
          experienceLevel: ExperienceLevel.consistent,
        );

        final templates = SimpleTemplateSelector.selectTemplates(score);

        expect(
          templates,
          equals(['morning_prayer', 'bible_reading', 'gratitude']),
        );
      });

      test('wellness + basic -> exercise', () {
        const score = OnboardingScore(
          totalScore: 4,
          level: ScoreLevel.basic,
          primaryIntent: PrimaryIntent.wellness,
          goals: [GoalType.wellness],
          timeCommitment: TimeCommitment.short,
          experienceLevel: ExperienceLevel.newbie,
        );

        final templates = SimpleTemplateSelector.selectTemplates(score);

        expect(templates, equals(['exercise']));
      });

      test('wellness + intermediate -> exercise + sleep', () {
        const score = OnboardingScore(
          totalScore: 7,
          level: ScoreLevel.intermediate,
          primaryIntent: PrimaryIntent.wellness,
          goals: [GoalType.wellness, GoalType.peace],
          timeCommitment: TimeCommitment.medium,
          experienceLevel: ExperienceLevel.growing,
        );

        final templates = SimpleTemplateSelector.selectTemplates(score);

        expect(templates, equals(['exercise', 'sleep']));
      });

      test('wellness + advanced -> exercise + sleep + healthy_eating', () {
        const score = OnboardingScore(
          totalScore: 10,
          level: ScoreLevel.advanced,
          primaryIntent: PrimaryIntent.wellness,
          goals: [GoalType.wellness, GoalType.study],
          timeCommitment: TimeCommitment.long,
          experienceLevel: ExperienceLevel.consistent,
        );

        final templates = SimpleTemplateSelector.selectTemplates(score);

        expect(templates, equals(['exercise', 'sleep', 'healthy_eating']));
      });

      test('mixed + basic -> meditation', () {
        const score = OnboardingScore(
          totalScore: 5,
          level: ScoreLevel.basic,
          primaryIntent: PrimaryIntent.mixed,
          goals: [GoalType.peace],
          timeCommitment: TimeCommitment.medium,
          experienceLevel: ExperienceLevel.newbie,
        );

        final templates = SimpleTemplateSelector.selectTemplates(score);

        expect(templates, equals(['meditation']));
      });

      test('study + basic -> learning', () {
        const score = OnboardingScore(
          totalScore: 4,
          level: ScoreLevel.basic,
          primaryIntent: PrimaryIntent.study,
          goals: [GoalType.study],
          timeCommitment: TimeCommitment.short,
          experienceLevel: ExperienceLevel.newbie,
        );

        final templates = SimpleTemplateSelector.selectTemplates(score);

        expect(templates, equals(['learning']));
      });

      test('peace + intermediate -> meditation + gratitude', () {
        const score = OnboardingScore(
          totalScore: 7,
          level: ScoreLevel.intermediate,
          primaryIntent: PrimaryIntent.peace,
          goals: [GoalType.peace],
          timeCommitment: TimeCommitment.medium,
          experienceLevel: ExperienceLevel.growing,
        );

        final templates = SimpleTemplateSelector.selectTemplates(score);

        expect(templates, equals(['meditation', 'gratitude']));
      });
    });

    group('fallback behavior', () {
      test('all intents have valid template mappings', () {
        // Test that each PrimaryIntent enum value has at least one template
        for (final intent in PrimaryIntent.values) {
          for (final level in ScoreLevel.values) {
            final score = OnboardingScore(
              totalScore: 7,
              level: level,
              primaryIntent: intent,
              goals: [GoalType.faith],
              timeCommitment: TimeCommitment.medium,
              experienceLevel: ExperienceLevel.growing,
            );

            final templates = SimpleTemplateSelector.selectTemplates(score);

            // Should return valid templates (not null or empty)
            expect(templates, isNotEmpty);
          }
        }
      });
    });

    group('getAllCombinations', () {
      test('returns all template combinations', () {
        final combinations = SimpleTemplateSelector.getAllCombinations();

        // Should have combinations for faithBased, wellness, mixed, study, peace
        // Each with 3 levels (basic, intermediate, advanced)
        expect(combinations.length, greaterThanOrEqualTo(9));

        // Verify some key combinations exist
        expect(
          combinations.contains((PrimaryIntent.faithBased, ScoreLevel.basic)),
          isTrue,
        );
        expect(
          combinations.contains((
            PrimaryIntent.wellness,
            ScoreLevel.intermediate,
          )),
          isTrue,
        );
        expect(
          combinations.contains((PrimaryIntent.study, ScoreLevel.advanced)),
          isTrue,
        );
      });
    });

    group('validateTemplates', () {
      test('all valid IDs returns empty list', () {
        final availableIds = {
          'morning_prayer',
          'bible_reading',
          'gratitude',
          'exercise',
          'sleep',
          'healthy_eating',
          'meditation',
          'learning',
          'creativity',
          'worship',
        };

        final missing = SimpleTemplateSelector.validateTemplates(availableIds);

        expect(missing, isEmpty);
      });

      test('missing IDs are reported', () {
        final availableIds = {
          'morning_prayer',
          // Missing other IDs
        };

        final missing = SimpleTemplateSelector.validateTemplates(availableIds);

        expect(missing, isNotEmpty);
        expect(missing.contains('bible_reading'), isTrue);
        expect(missing.contains('exercise'), isTrue);
      });
    });

    group('O(1) lookup verification', () {
      test('all 15 template combinations return valid results', () {
        final intents = [
          PrimaryIntent.faithBased,
          PrimaryIntent.wellness,
          PrimaryIntent.mixed,
          PrimaryIntent.study,
          PrimaryIntent.peace,
        ];
        final levels = [
          ScoreLevel.basic,
          ScoreLevel.intermediate,
          ScoreLevel.advanced,
        ];

        for (final intent in intents) {
          for (final level in levels) {
            final score = OnboardingScore(
              totalScore: level == ScoreLevel.basic
                  ? 4
                  : (level == ScoreLevel.intermediate ? 7 : 10),
              level: level,
              primaryIntent: intent,
              goals: [GoalType.faith],
              timeCommitment: TimeCommitment.medium,
              experienceLevel: ExperienceLevel.growing,
            );

            final templates = SimpleTemplateSelector.selectTemplates(score);

            // Should always return a non-empty list
            expect(templates, isNotEmpty);

            // Should be a list of strings (habit IDs)
            expect(templates, everyElement(isA<String>()));
          }
        }
      });
    });
  });
}
