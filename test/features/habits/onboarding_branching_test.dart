import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/onboarding_models.dart';
import 'package:habitus_faith/features/habits/presentation/onboarding/onboarding_questions.dart';

/// Test onboarding branching logic for all 3 paths
void main() {
  group('OnboardingProfile', () {
    test('toJson and fromJson work correctly for faith-based profile', () {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod', 'understandBible'],
        challenge: 'lackOfTime',
        supportLevel: 'strong',
        spiritualMaturity: 'growing',
        commitment: '¡Voy a crecer en mi fe!',
        completedAt: DateTime(2024, 1, 1),
      );

      final json = profile.toJson();
      final restored = OnboardingProfile.fromJson(json);

      expect(restored.primaryIntent, profile.primaryIntent);
      expect(restored.motivations, profile.motivations);
      expect(restored.challenge, profile.challenge);
      expect(restored.supportLevel, profile.supportLevel);
      expect(restored.spiritualMaturity, profile.spiritualMaturity);
      expect(restored.commitment, profile.commitment);
      expect(restored.completedAt, profile.completedAt);
    });

    test('toJson and fromJson work correctly for wellness profile', () {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.wellness,
        motivations: ['timeManagement', 'physicalHealth'],
        challenge: 'lackOfMotivation',
        supportLevel: 'normal',
        spiritualMaturity: null, // wellness users don't have this
        commitment: '¡Voy a conseguir mi objetivo!',
        completedAt: DateTime(2024, 1, 1),
      );

      final json = profile.toJson();
      final restored = OnboardingProfile.fromJson(json);

      expect(restored.primaryIntent, profile.primaryIntent);
      expect(restored.spiritualMaturity, isNull);
    });

    test('toJson and fromJson work correctly for both profile', () {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.both,
        motivations: ['closerToGod', 'timeManagement', 'physicalHealth'],
        challenge: 'givingUp',
        supportLevel: 'weak',
        spiritualMaturity: 'new',
        commitment: '¡Voy a crecer en mi fe y mejorar mi vida!',
        completedAt: DateTime(2024, 1, 1),
      );

      final json = profile.toJson();
      final restored = OnboardingProfile.fromJson(json);

      expect(restored.primaryIntent, UserIntent.both);
      expect(restored.motivations.length, 3);
      expect(restored.spiritualMaturity, isNotNull);
    });

    test('copyWith creates new instance with updated fields', () {
      final profile = OnboardingProfile(
        primaryIntent: UserIntent.faithBased,
        motivations: ['closerToGod'],
        challenge: 'lackOfTime',
        supportLevel: 'strong',
        spiritualMaturity: 'growing',
        commitment: 'test',
        completedAt: DateTime(2024, 1, 1),
      );

      final updated = profile.copyWith(
        challenge: 'lackOfMotivation',
        supportLevel: 'weak',
      );

      expect(updated.challenge, 'lackOfMotivation');
      expect(updated.supportLevel, 'weak');
      expect(updated.primaryIntent, profile.primaryIntent);
      expect(updated.motivations, profile.motivations);
    });
  });

  group('UserIntent', () {
    test('toJson and fromJson work correctly', () {
      expect(UserIntent.faithBased.toJson(), 'faithBased');
      expect(UserIntent.wellness.toJson(), 'wellness');
      expect(UserIntent.both.toJson(), 'both');

      expect(UserIntent.fromJson('faithBased'), UserIntent.faithBased);
      expect(UserIntent.fromJson('wellness'), UserIntent.wellness);
      expect(UserIntent.fromJson('both'), UserIntent.both);
    });
  });

  group('Question Flow Branching', () {
    test('faith path includes spiritual questions', () {
      final questions = getQuestionsForIntent(UserIntent.faithBased);

      expect(questions.length, 5); // intent + 2 faith + 2 universal
      expect(questions.any((q) => q.id == 'spiritualMotivation'), isTrue);
      expect(questions.any((q) => q.id == 'faithWalk'), isTrue);
      expect(questions.any((q) => q.id == 'mainChallenge'), isTrue);
      expect(questions.any((q) => q.id == 'supportSystem'), isTrue);

      // Should NOT include wellness questions
      expect(questions.any((q) => q.id == 'wellnessGoals'), isFalse);
      expect(questions.any((q) => q.id == 'currentState'), isFalse);
    });

    test('wellness path includes wellness questions', () {
      final questions = getQuestionsForIntent(UserIntent.wellness);

      expect(questions.length, 5); // intent + 2 wellness + 2 universal
      expect(questions.any((q) => q.id == 'wellnessGoals'), isTrue);
      expect(questions.any((q) => q.id == 'currentState'), isTrue);
      expect(questions.any((q) => q.id == 'mainChallenge'), isTrue);
      expect(questions.any((q) => q.id == 'supportSystem'), isTrue);

      // Should NOT include faith questions
      expect(questions.any((q) => q.id == 'spiritualMotivation'), isFalse);
      expect(questions.any((q) => q.id == 'faithWalk'), isFalse);
    });

    test('both path includes faith and wellness questions', () {
      final questions = getQuestionsForIntent(UserIntent.both);

      expect(questions.length, 6); // intent + 3 both-specific + 2 universal
      expect(questions.any((q) => q.id == 'spiritualMotivation'), isTrue);
      expect(questions.any((q) => q.id == 'wellnessGoals'), isTrue);
      expect(questions.any((q) => q.id == 'faithWalk'), isTrue);
      expect(questions.any((q) => q.id == 'mainChallenge'), isTrue);
      expect(questions.any((q) => q.id == 'supportSystem'), isTrue);
    });

    test('all paths start with intent question', () {
      final faithQuestions = getQuestionsForIntent(UserIntent.faithBased);
      final wellnessQuestions = getQuestionsForIntent(UserIntent.wellness);
      final bothQuestions = getQuestionsForIntent(UserIntent.both);

      expect(faithQuestions.first.id, 'intent');
      expect(wellnessQuestions.first.id, 'intent');
      expect(bothQuestions.first.id, 'intent');
    });
  });

  group('Conditional Encouragement Messages', () {
    test('faith users with weak support get biblical encouragement', () {
      final message = getEncouragementMessage(UserIntent.faithBased, 'weak');

      expect(message, isNotNull);
      expect(message!.verseReference, 'Isaías 41:10');
      expect(message.verseText, isNotNull);
      expect(message.verseText, contains('no temas'));
    });

    test('wellness users with weak support get community encouragement', () {
      final message = getEncouragementMessage(UserIntent.wellness, 'weak');

      expect(message, isNotNull);
      expect(message!.verseReference, isNull); // No Bible verse for wellness
      expect(message.message, contains('Miles de usuarios'));
    });

    test('both users with weak support get biblical encouragement', () {
      final message = getEncouragementMessage(UserIntent.both, 'weak');

      expect(message, isNotNull);
      expect(message!.verseReference, 'Isaías 41:10');
    });

    test('strong support users get no encouragement message', () {
      final faithMessage =
          getEncouragementMessage(UserIntent.faithBased, 'strong');
      final wellnessMessage =
          getEncouragementMessage(UserIntent.wellness, 'strong');
      final bothMessage = getEncouragementMessage(UserIntent.both, 'strong');

      expect(faithMessage, isNull);
      expect(wellnessMessage, isNull);
      expect(bothMessage, isNull);
    });

    test('normal support users get no encouragement message', () {
      final message = getEncouragementMessage(UserIntent.faithBased, 'normal');
      expect(message, isNull);
    });
  });

  group('Question Types', () {
    test('intent question is single choice', () {
      expect(intentQuestion.type, QuestionType.singleChoice);
      expect(intentQuestion.options.length, 3);
    });

    test('spiritual motivation is multi-choice with max 3', () {
      expect(spiritualMotivationQuestion.type, QuestionType.multiChoice);
      expect(spiritualMotivationQuestion.maxSelections, 3);
      expect(spiritualMotivationQuestion.options.length, 5);
    });

    test('wellness goals is multi-choice with max 3', () {
      expect(wellnessGoalsQuestion.type, QuestionType.multiChoice);
      expect(wellnessGoalsQuestion.maxSelections, 3);
      expect(wellnessGoalsQuestion.options.length, 5);
    });

    test('faith walk is single choice', () {
      expect(faithWalkQuestion.type, QuestionType.singleChoice);
      expect(faithWalkQuestion.options.length, 4);
    });

    test('current state is single choice', () {
      expect(currentStateQuestion.type, QuestionType.singleChoice);
      expect(currentStateQuestion.options.length, 4);
    });

    test('main challenge is single choice', () {
      expect(mainChallengeQuestion.type, QuestionType.singleChoice);
      expect(mainChallengeQuestion.options.length, 4);
    });

    test('support system is single choice', () {
      expect(supportSystemQuestion.type, QuestionType.singleChoice);
      expect(supportSystemQuestion.options.length, 3);
    });
  });

  group('Question Options', () {
    test('intent question has correct option IDs', () {
      final optionIds = intentQuestion.options.map((o) => o.id).toList();
      expect(optionIds, containsAll(['faithBased', 'wellness', 'both']));
    });

    test('all questions have emojis', () {
      final allQuestions = [
        intentQuestion,
        spiritualMotivationQuestion,
        faithWalkQuestion,
        wellnessGoalsQuestion,
        currentStateQuestion,
        mainChallengeQuestion,
        supportSystemQuestion,
      ];

      for (final question in allQuestions) {
        for (final option in question.options) {
          expect(option.emoji.isNotEmpty, isTrue,
              reason: 'Option ${option.id} should have emoji');
        }
      }
    });

    test('all questions have titles', () {
      final allQuestions = [
        intentQuestion,
        spiritualMotivationQuestion,
        faithWalkQuestion,
        wellnessGoalsQuestion,
        currentStateQuestion,
        mainChallengeQuestion,
        supportSystemQuestion,
      ];

      for (final question in allQuestions) {
        expect(question.title.isNotEmpty, isTrue);
        expect(question.id.isNotEmpty, isTrue);
      }
    });
  });
}
