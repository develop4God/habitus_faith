import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/templates/template_scoring_engine.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/onboarding_models.dart';

void main() {
  late TemplateScoringEngine engine;

  setUp(() {
    engine = TemplateScoringEngine();
  });

  group('TemplateScoringEngine', () {
    test('exact match returns perfect score', () {
      // Create identical user and template
      const user = UserProfileVector(
        primaryIntent: UserIntent.faithBased,
        supportLevel: 'normal',
        challenge: 'lackOfTime',
        motivations: ['closerToGod', 'prayerDiscipline'],
        spiritualMaturity: 'new',
      );

      const template = TemplateMetadata(
        patternId:
            'faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new',
        primaryIntent: UserIntent.faithBased,
        supportLevel: 'normal',
        challenge: 'lackOfTime',
        motivations: ['closerToGod', 'prayerDiscipline'],
        spiritualMaturity: 'new',
      );

      final score = engine.calculateScore(user, template);

      expect(score.totalScore, equals(1.0));
      expect(score.confidence, equals(MatchConfidence.excellent));
      expect(score.dimensionScores['intent'], equals(1.0));
      expect(score.dimensionScores['supportLevel'], equals(1.0));
      expect(score.dimensionScores['challenge'], equals(1.0));
      expect(score.dimensionScores['motivations'], equals(1.0));
      expect(score.dimensionScores['spiritualMaturity'], equals(1.0));
    });

    test('intent weight is 40% of total score', () {
      // User with faithBased intent
      const user = UserProfileVector(
        primaryIntent: UserIntent.faithBased,
        supportLevel: 'normal',
        challenge: 'lackOfTime',
        motivations: ['closerToGod'],
        spiritualMaturity: 'new',
      );

      // Template with wellness intent (0.0 intent score)
      const template = TemplateMetadata(
        patternId: 'wellness_normal_lackOfTime_closerToGod_new',
        primaryIntent: UserIntent.wellness,
        supportLevel: 'normal',
        challenge: 'lackOfTime',
        motivations: ['closerToGod'],
        spiritualMaturity: 'new',
      );

      final score = engine.calculateScore(user, template);

      // All other dimensions are perfect (1.0)
      // Total = 0.0*0.40 + 1.0*0.20 + 1.0*0.20 + 1.0*0.15 + 1.0*0.05 = 0.60
      expect(score.dimensionScores['intent'], equals(0.0));
      expect(score.totalScore, closeTo(0.60, 0.001));
    });

    test('different intents return score 0.0 unless both', () {
      const user = UserProfileVector(
        primaryIntent: UserIntent.faithBased,
        supportLevel: 'normal',
        challenge: 'lackOfTime',
        motivations: ['closerToGod'],
        spiritualMaturity: 'new',
      );

      const wellnessTemplate = TemplateMetadata(
        patternId: 'wellness_normal_lackOfTime_closerToGod_new',
        primaryIntent: UserIntent.wellness,
        supportLevel: 'normal',
        challenge: 'lackOfTime',
        motivations: ['closerToGod'],
        spiritualMaturity: 'new',
      );

      final score = engine.calculateScore(user, wellnessTemplate);
      expect(score.dimensionScores['intent'], equals(0.0));

      // Test 'both' compatibility
      const bothTemplate = TemplateMetadata(
        patternId: 'both_normal_lackOfTime_closerToGod_new',
        primaryIntent: UserIntent.both,
        supportLevel: 'normal',
        challenge: 'lackOfTime',
        motivations: ['closerToGod'],
        spiritualMaturity: 'new',
      );

      final bothScore = engine.calculateScore(user, bothTemplate);
      expect(bothScore.dimensionScores['intent'], equals(0.7));
    });

    test('support level similarity follows defined map', () {
      const user = UserProfileVector(
        primaryIntent: UserIntent.faithBased,
        supportLevel: 'growing',
        challenge: 'lackOfTime',
        motivations: ['closerToGod'],
        spiritualMaturity: 'new',
      );

      // Test exact match
      const exactTemplate = TemplateMetadata(
        patternId: 'faithBased_growing_lackOfTime_closerToGod_new',
        primaryIntent: UserIntent.faithBased,
        supportLevel: 'growing',
        challenge: 'lackOfTime',
        motivations: ['closerToGod'],
        spiritualMaturity: 'new',
      );
      final exactScore = engine.calculateScore(user, exactTemplate);
      expect(exactScore.dimensionScores['supportLevel'], equals(1.0));

      // Test strong↔growing similarity (0.7)
      const strongTemplate = TemplateMetadata(
        patternId: 'faithBased_strong_lackOfTime_closerToGod_new',
        primaryIntent: UserIntent.faithBased,
        supportLevel: 'strong',
        challenge: 'lackOfTime',
        motivations: ['closerToGod'],
        spiritualMaturity: 'new',
      );
      final strongScore = engine.calculateScore(user, strongTemplate);
      expect(strongScore.dimensionScores['supportLevel'], equals(0.7));

      // Test growing↔inconsistent similarity (0.6)
      const inconsistentTemplate = TemplateMetadata(
        patternId: 'faithBased_inconsistent_lackOfTime_closerToGod_new',
        primaryIntent: UserIntent.faithBased,
        supportLevel: 'inconsistent',
        challenge: 'lackOfTime',
        motivations: ['closerToGod'],
        spiritualMaturity: 'new',
      );
      final inconsistentScore =
          engine.calculateScore(user, inconsistentTemplate);
      expect(inconsistentScore.dimensionScores['supportLevel'], equals(0.6));
    });

    test('motivation scoring uses Jaccard correctly', () {
      const user = UserProfileVector(
        primaryIntent: UserIntent.faithBased,
        supportLevel: 'normal',
        challenge: 'lackOfTime',
        motivations: ['closerToGod', 'prayerDiscipline', 'growInFaith'],
        spiritualMaturity: 'new',
      );

      // Test exact match
      const exactTemplate = TemplateMetadata(
        patternId:
            'faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new',
        primaryIntent: UserIntent.faithBased,
        supportLevel: 'normal',
        challenge: 'lackOfTime',
        motivations: ['closerToGod', 'prayerDiscipline', 'growInFaith'],
        spiritualMaturity: 'new',
      );
      final exactScore = engine.calculateScore(user, exactTemplate);
      expect(exactScore.dimensionScores['motivations'], equals(1.0));

      // Test partial overlap
      // User: [closerToGod, prayerDiscipline, growInFaith]
      // Template: [closerToGod, understandBible]
      // Intersection: [closerToGod] = 1
      // Union: [closerToGod, prayerDiscipline, growInFaith, understandBible] = 4
      // Jaccard = 1/4 = 0.25
      const partialTemplate = TemplateMetadata(
        patternId:
            'faithBased_normal_lackOfTime_closerToGod_understandBible_new',
        primaryIntent: UserIntent.faithBased,
        supportLevel: 'normal',
        challenge: 'lackOfTime',
        motivations: ['closerToGod', 'understandBible'],
        spiritualMaturity: 'new',
      );
      final partialScore = engine.calculateScore(user, partialTemplate);
      expect(partialScore.dimensionScores['motivations'], equals(0.25));

      // Test no overlap
      const noOverlapTemplate = TemplateMetadata(
        patternId: 'faithBased_normal_lackOfTime_betterSleep_reduceStress_new',
        primaryIntent: UserIntent.faithBased,
        supportLevel: 'normal',
        challenge: 'lackOfTime',
        motivations: ['betterSleep', 'reduceStress'],
        spiritualMaturity: 'new',
      );
      final noOverlapScore = engine.calculateScore(user, noOverlapTemplate);
      expect(noOverlapScore.dimensionScores['motivations'], equals(0.0));
    });

    test('best match selection among multiple templates', () {
      const user = UserProfileVector(
        primaryIntent: UserIntent.faithBased,
        supportLevel: 'normal',
        challenge: 'lackOfTime',
        motivations: ['closerToGod', 'prayerDiscipline'],
        spiritualMaturity: 'new',
      );

      final templates = [
        const TemplateMetadata(
          patternId:
              'wellness_normal_lackOfTime_closerToGod_prayerDiscipline_new',
          primaryIntent: UserIntent.wellness,
          supportLevel: 'normal',
          challenge: 'lackOfTime',
          motivations: ['closerToGod', 'prayerDiscipline'],
          spiritualMaturity: 'new',
        ),
        const TemplateMetadata(
          patternId:
              'faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new',
          primaryIntent: UserIntent.faithBased,
          supportLevel: 'normal',
          challenge: 'lackOfTime',
          motivations: ['closerToGod', 'prayerDiscipline'],
          spiritualMaturity: 'new',
        ),
        const TemplateMetadata(
          patternId:
              'faithBased_strong_lackOfTime_closerToGod_prayerDiscipline_new',
          primaryIntent: UserIntent.faithBased,
          supportLevel: 'strong',
          challenge: 'lackOfTime',
          motivations: ['closerToGod', 'prayerDiscipline'],
          spiritualMaturity: 'new',
        ),
      ];

      final scores =
          templates.map((t) => engine.calculateScore(user, t)).toList();

      // Second template (exact match) should have highest score
      expect(scores[1].totalScore, greaterThan(scores[0].totalScore));
      expect(scores[1].totalScore, greaterThan(scores[2].totalScore));
      expect(scores[1].totalScore, equals(1.0));
    });

    test('score below threshold returns low confidence', () {
      const user = UserProfileVector(
        primaryIntent: UserIntent.faithBased,
        supportLevel: 'normal',
        challenge: 'lackOfTime',
        motivations: ['closerToGod', 'prayerDiscipline'],
        spiritualMaturity: 'new',
      );

      // Create a very poor match
      const template = TemplateMetadata(
        patternId: 'wellness_inconsistent_givingUp_betterSleep_reduceStress',
        primaryIntent: UserIntent.wellness,
        supportLevel: 'inconsistent',
        challenge: 'givingUp',
        motivations: ['betterSleep', 'reduceStress'],
        spiritualMaturity: null,
      );

      final score = engine.calculateScore(user, template);

      expect(score.totalScore, lessThan(0.75));
      expect(score.confidence, equals(MatchConfidence.low));
    });

    test('dimension scores sum correctly with weights', () {
      const user = UserProfileVector(
        primaryIntent: UserIntent.faithBased,
        supportLevel: 'growing',
        challenge: 'lackOfTime',
        motivations: ['closerToGod', 'prayerDiscipline'],
        spiritualMaturity: 'new',
      );

      const template = TemplateMetadata(
        patternId: 'faithBased_strong_dontKnowStart_closerToGod_growing',
        primaryIntent: UserIntent.faithBased,
        supportLevel: 'strong',
        challenge: 'dontKnowStart',
        motivations: ['closerToGod'],
        spiritualMaturity: 'growing',
      );

      final score = engine.calculateScore(user, template);

      // Manually calculate expected score
      const intentScore = 1.0; // exact match
      const supportScore = 0.7; // growing->strong
      const challengeScore = 0.6; // same domain (time)
      const motivationsScore = 0.5; // Jaccard: 1/3
      const maturityScore = 0.7; // adjacent levels

      const expectedTotal = (intentScore * 0.40) +
          (supportScore * 0.20) +
          (challengeScore * 0.20) +
          (motivationsScore * 0.15) +
          (maturityScore * 0.05);

      expect(score.totalScore, closeTo(expectedTotal, 0.001));
      expect(score.dimensionScores['intent'], equals(intentScore));
      expect(score.dimensionScores['supportLevel'], equals(supportScore));
      expect(score.dimensionScores['challenge'], equals(challengeScore));
      expect(score.dimensionScores['motivations'], equals(motivationsScore));
      expect(score.dimensionScores['spiritualMaturity'], equals(maturityScore));
    });
  });

  group('TemplateMetadata.fromPatternId', () {
    test('parses valid pattern ID correctly', () {
      final metadata = TemplateMetadata.fromPatternId(
        'faithBased_normal_lackOfTime_closerToGod_prayerDiscipline_new',
      );

      expect(metadata.primaryIntent, equals(UserIntent.faithBased));
      expect(metadata.supportLevel, equals('normal'));
      expect(metadata.challenge, equals('lackOfTime'));
      expect(metadata.motivations, equals(['closerToGod', 'prayerDiscipline']));
      expect(metadata.spiritualMaturity, equals('new'));
    });

    test('parses wellness pattern without maturity', () {
      final metadata = TemplateMetadata.fromPatternId(
        'wellness_normal_lackOfMotivation_betterSleep_reduceStress',
      );

      expect(metadata.primaryIntent, equals(UserIntent.wellness));
      expect(metadata.supportLevel, equals('normal'));
      expect(metadata.challenge, equals('lackOfMotivation'));
      expect(metadata.motivations, equals(['betterSleep', 'reduceStress']));
      expect(metadata.spiritualMaturity, isNull);
    });

    test('throws on invalid pattern ID', () {
      expect(
        () => TemplateMetadata.fromPatternId('invalid'),
        throwsArgumentError,
      );
    });
  });

  group('MatchConfidence', () {
    test('fromScore assigns correct confidence levels', () {
      expect(
          MatchConfidence.fromScore(0.95), equals(MatchConfidence.excellent));
      expect(
          MatchConfidence.fromScore(0.90), equals(MatchConfidence.excellent));
      expect(MatchConfidence.fromScore(0.85), equals(MatchConfidence.good));
      expect(MatchConfidence.fromScore(0.75), equals(MatchConfidence.good));
      expect(MatchConfidence.fromScore(0.70), equals(MatchConfidence.low));
      expect(MatchConfidence.fromScore(0.50), equals(MatchConfidence.low));
    });
  });

  group('UserProfileVector', () {
    test('fromProfile creates correct vector', () {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'prayerDiscipline'],
        challenge: 'lackOfTime',
        supportLevel: 'normal',
        spiritualMaturity: 'new',
        commitment: 'daily',
        completedAt: DateTime.now(),
      );

      final vector = UserProfileVector.fromProfile(profile);

      expect(vector.primaryIntent, equals(UserIntent.faithBased));
      expect(vector.supportLevel, equals('normal'));
      expect(vector.challenge, equals('lackOfTime'));
      expect(vector.motivations, equals(['closerToGod', 'prayerDiscipline']));
      expect(vector.spiritualMaturity, equals('new'));
    });
  });

  group('Custom weights', () {
    test('allows custom weight configuration', () {
      final customEngine = TemplateScoringEngine(
        intentWeight: 0.50,
        supportLevelWeight: 0.15,
        challengeWeight: 0.15,
        motivationsWeight: 0.15,
        spiritualMaturityWeight: 0.05,
      );

      const user = UserProfileVector(
        primaryIntent: UserIntent.faithBased,
        supportLevel: 'normal',
        challenge: 'lackOfTime',
        motivations: ['closerToGod'],
        spiritualMaturity: 'new',
      );

      const template = TemplateMetadata(
        patternId: 'wellness_normal_lackOfTime_closerToGod_new',
        primaryIntent: UserIntent.wellness,
        supportLevel: 'normal',
        challenge: 'lackOfTime',
        motivations: ['closerToGod'],
        spiritualMaturity: 'new',
      );

      final score = customEngine.calculateScore(user, template);

      // With custom weights, intent is now 50%
      // Total = 0.0*0.50 + 1.0*0.15 + 1.0*0.15 + 1.0*0.15 + 1.0*0.05 = 0.50
      expect(score.totalScore, closeTo(0.50, 0.001));
    });

    test('validates weights sum to 1.0', () {
      expect(
        () => TemplateScoringEngine(
          intentWeight: 0.40,
          supportLevelWeight: 0.20,
          challengeWeight: 0.20,
          motivationsWeight: 0.15,
          spiritualMaturityWeight: 0.10, // Sum = 1.05
        ),
        throwsArgumentError,
      );
    });
  });
}
