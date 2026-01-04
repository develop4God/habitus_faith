import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/services/simple_template_selector.dart';
import 'package:habitus_faith/features/habits/domain/services/simple_onboarding_scoring.dart';
import 'package:habitus_faith/features/habits/domain/config/onboarding_config.dart';

void main() {
  group('SimpleOnboardingFixes', () {
    group('Template Enum Validation', () {
      test('all template IDs match HabitTemplateId enum values', () {
        final invalidIds =
            SimpleTemplateSelector.validateTemplateEnumMapping();

        expect(
          invalidIds,
          isEmpty,
          reason:
              'All template IDs should have corresponding enum values. Invalid IDs: $invalidIds',
        );
      });

      test('fallback templates use valid enum IDs', () {
        final invalidIds =
            SimpleTemplateSelector.validateTemplateEnumMapping();

        expect(invalidIds, isEmpty);
      });

      test('HabitTemplateId enum has no duplicate IDs', () {
        final ids = HabitTemplateId.values.map((e) => e.id).toList();
        final uniqueIds = ids.toSet();

        expect(
          ids.length,
          equals(uniqueIds.length),
          reason: 'Enum should not have duplicate IDs',
        );
      });

      test('all HabitTemplateId enum values are used in templates', () {
        final enumIds = HabitTemplateId.values.map((e) => e.id).toSet();
        final templateIds = <String>{};

        // Collect all IDs used in templates
        for (final habitList in SimpleTemplateSelector.templates.values) {
          templateIds.addAll(habitList);
        }
        templateIds.addAll(SimpleTemplateSelector.fallbackTemplates);

        // Check that all enum values are used
        for (final enumId in enumIds) {
          expect(
            templateIds.contains(enumId),
            isTrue,
            reason:
                'Enum value "$enumId" should be used in at least one template',
          );
        }
      });
    });

    group('OnboardingConfig Constants', () {
      test('config values are reasonable', () {
        // Verify timing constants are sensible
        expect(
          OnboardingConfig.autoAdvanceDelay.inMilliseconds,
          greaterThan(0),
        );
        expect(
          OnboardingConfig.autoAdvanceDelay.inMilliseconds,
          lessThan(1000),
        );

        expect(
          OnboardingConfig.loadingDialogDelay.inMilliseconds,
          greaterThan(0),
        );
        expect(
          OnboardingConfig.loadingDialogDelay.inMilliseconds,
          lessThan(3000),
        );

        // Verify constraint constants
        expect(OnboardingConfig.maxGoals, equals(3));
        expect(OnboardingConfig.minHabits, equals(1));

        // Verify score thresholds match implementation
        expect(OnboardingConfig.scoreAdvancedThreshold, equals(10));
        expect(OnboardingConfig.scoreIntermediateThreshold, equals(7));
      });

      test('score thresholds create proper level ranges', () {
        // Basic: 4-6 (below intermediate threshold)
        final basicScore = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.faith],
          timeCommitment: TimeCommitment.medium,
          experienceLevel: ExperienceLevel.growing,
        );
        expect(basicScore.level, equals(ScoreLevel.basic));
        expect(
          basicScore.totalScore,
          lessThan(OnboardingConfig.scoreIntermediateThreshold),
        );

        // Intermediate: 7-9 (at or above intermediate, below advanced)
        final intermediateScore = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.faith, GoalType.wellness],
          timeCommitment: TimeCommitment.medium,
          experienceLevel: ExperienceLevel.growing,
        );
        expect(intermediateScore.level, equals(ScoreLevel.intermediate));
        expect(
          intermediateScore.totalScore,
          greaterThanOrEqualTo(OnboardingConfig.scoreIntermediateThreshold),
        );
        expect(
          intermediateScore.totalScore,
          lessThan(OnboardingConfig.scoreAdvancedThreshold),
        );

        // Advanced: 10+ (at or above advanced threshold)
        final advancedScore = SimpleOnboardingScoring.calculateScore(
          goals: [GoalType.faith, GoalType.wellness],
          timeCommitment: TimeCommitment.long,
          experienceLevel: ExperienceLevel.consistent,
        );
        expect(advancedScore.level, equals(ScoreLevel.advanced));
        expect(
          advancedScore.totalScore,
          greaterThanOrEqualTo(OnboardingConfig.scoreAdvancedThreshold),
        );
      });
    });

    group('Template Map Const Validation', () {
      test('templates map is const (compile-time constant)', () {
        // This test verifies that templates is const by checking
        // that it can be used in const contexts
        const testKey = ('faithBased', ScoreLevel.basic);
        const templates = SimpleTemplateSelector.templates;

        expect(templates.containsKey(testKey), isTrue);
      });

      test('fallback templates is const', () {
        const fallback = SimpleTemplateSelector.fallbackTemplates;
        expect(fallback, isNotEmpty);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('validateTemplateEnumMapping handles empty templates', () {
        // This is a structural test - templates should never be empty
        expect(SimpleTemplateSelector.templates, isNotEmpty);
      });

      test('all template lists are non-empty', () {
        for (final habitList in SimpleTemplateSelector.templates.values) {
          expect(
            habitList,
            isNotEmpty,
            reason: 'No template list should be empty',
          );
        }
      });

      test('no duplicate habit IDs within same template list', () {
        for (final entry in SimpleTemplateSelector.templates.entries) {
          final habitList = entry.value;
          final uniqueHabits = habitList.toSet();

          expect(
            habitList.length,
            equals(uniqueHabits.length),
            reason:
                'Template ${entry.key} should not have duplicate habit IDs',
          );
        }
      });
    });
  });
}
