import 'onboarding_models.dart';

/// Question type for adaptive onboarding flow
enum QuestionType { singleChoice, multiChoice }

/// Represents a single onboarding question
class OnboardingQuestion {
  final String id;
  final String title;
  final QuestionType type;
  final List<QuestionOption> options;
  final int? maxSelections; // for multi-select questions
  final bool isRequired;

  const OnboardingQuestion({
    required this.id,
    required this.title,
    required this.type,
    required this.options,
    this.maxSelections,
    this.isRequired = true,
  });
}

/// Option for a question
class QuestionOption {
  final String id;
  final String emoji;
  final String text;
  final String? description;

  const QuestionOption({
    required this.id,
    required this.emoji,
    required this.text,
    this.description,
  });
}

/// Conditional message shown based on answers
class ConditionalMessage {
  final String title;
  final String message;
  final String? verseReference;
  final String? verseText;

  const ConditionalMessage({
    required this.title,
    required this.message,
    this.verseReference,
    this.verseText,
  });
}

/// Q1: Intent Detection (Branch Point)
const intentQuestion = OnboardingQuestion(
  id: 'intent',
  title: '¿Cuál es tu principal motivación para usar habitus+faith?',
  type: QuestionType.singleChoice,
  options: [
    QuestionOption(
      id: 'faithBased',
      emoji: '🙏',
      text: 'Fortalecer mi vida espiritual',
      description: 'Enfoque en oración, Biblia y crecimiento en fe',
    ),
    QuestionOption(
      id: 'wellness',
      emoji: '💪',
      text: 'Mejorar mi organización y salud',
      description: 'Enfoque en productividad, salud y bienestar',
    ),
    QuestionOption(
      id: 'both',
      emoji: '✨',
      text: 'Ambos: fe y bienestar',
      description: 'Integrar espiritualidad con vida práctica',
    ),
  ],
);

/// Q2a: Spiritual Motivation (Faith path)
const spiritualMotivationQuestion = OnboardingQuestion(
  id: 'spiritualMotivation',
  title: '¿Qué te motiva en tu caminar con Dios?',
  type: QuestionType.multiChoice,
  maxSelections: 3,
  options: [
    QuestionOption(
      id: 'closerToGod',
      emoji: '🔥',
      text: 'Sentirme más cerca de Dios',
    ),
    QuestionOption(
      id: 'understandBible',
      emoji: '📖',
      text: 'Entender mejor la Biblia',
    ),
    QuestionOption(
      id: 'prayerDiscipline',
      emoji: '🙏',
      text: 'Tener disciplina en oración',
    ),
    QuestionOption(
      id: 'overcomeHabits',
      emoji: '💪',
      text: 'Superar hábitos negativos',
    ),
    QuestionOption(
      id: 'growInFaith',
      emoji: '✝️',
      text: 'Crecer en mi caminar con Dios',
    ),
  ],
);

/// Q3a: Current Faith Walk
const faithWalkQuestion = OnboardingQuestion(
  id: 'faithWalk',
  title: '¿Cómo describirías tu caminar actual con Dios?',
  type: QuestionType.singleChoice,
  options: [
    QuestionOption(id: 'new', emoji: '🌱', text: 'Soy nuevo en la fe'),
    QuestionOption(
      id: 'growing',
      emoji: '🌿',
      text: 'Creciendo pero inconsistente',
    ),
    QuestionOption(
      id: 'mature',
      emoji: '🌳',
      text: 'Maduro pero necesito renovación',
    ),
    QuestionOption(
      id: 'passionate',
      emoji: '🔥',
      text: 'Apasionado y comprometido',
    ),
  ],
);

/// Q2b: Wellness Goals (Wellness path)
const wellnessGoalsQuestion = OnboardingQuestion(
  id: 'wellnessGoals',
  title: '¿Qué aspectos de tu vida quieres mejorar?',
  type: QuestionType.multiChoice,
  maxSelections: 3,
  options: [
    QuestionOption(
      id: 'timeManagement',
      emoji: '⏰',
      text: 'Organizar mejor mi tiempo',
    ),
    QuestionOption(
      id: 'physicalHealth',
      emoji: '💪',
      text: 'Mejorar mi salud física',
    ),
    QuestionOption(
      id: 'reduceStress',
      emoji: '😌',
      text: 'Reducir estrés y ansiedad',
    ),
    QuestionOption(id: 'productivity', emoji: '📚', text: 'Ser más productivo'),
    QuestionOption(id: 'betterSleep', emoji: '😴', text: 'Dormir mejor'),
  ],
);

/// Q3b: Current State (Wellness path)
const currentStateQuestion = OnboardingQuestion(
  id: 'currentState',
  title: '¿En qué punto estás ahora?',
  type: QuestionType.singleChoice,
  options: [
    QuestionOption(id: 'starting', emoji: '🆕', text: 'Comenzando desde cero'),
    QuestionOption(
      id: 'inconsistent',
      emoji: '📊',
      text: 'Tengo algunos hábitos pero inconsistentes',
    ),
    QuestionOption(
      id: 'optimizing',
      emoji: '🎯',
      text: 'Busco optimizar lo que ya hago',
    ),
    QuestionOption(
      id: 'disciplined',
      emoji: '🚀',
      text: 'Muy disciplinado, quiero más',
    ),
  ],
);

/// Q4: Main Challenge (Universal)
const mainChallengeQuestion = OnboardingQuestion(
  id: 'mainChallenge',
  title: '¿Cuál es tu mayor desafío?',
  type: QuestionType.singleChoice,
  options: [
    QuestionOption(id: 'lackOfTime', emoji: '⏰', text: 'Falta de tiempo'),
    QuestionOption(
      id: 'lackOfMotivation',
      emoji: '😴',
      text: 'Falta de motivación',
    ),
    QuestionOption(
      id: 'dontKnowStart',
      emoji: '🤯',
      text: 'No sé por dónde empezar',
    ),
    QuestionOption(
      id: 'givingUp',
      emoji: '😔',
      text: 'Rendirme después de fallar',
    ),
  ],
);

/// Q5: Support System (Universal)
const supportSystemQuestion = OnboardingQuestion(
  id: 'supportSystem',
  title: '¿Cómo es tu red de apoyo?',
  type: QuestionType.singleChoice,
  options: [
    QuestionOption(
      id: 'strong',
      emoji: '👌',
      text: 'Fuerte: tengo personas en quienes apoyarme',
    ),
    QuestionOption(
      id: 'normal',
      emoji: '🤔',
      text: 'Normal: a veces me siento solo',
    ),
    QuestionOption(
      id: 'weak',
      emoji: '😔',
      text: 'Débil: me siento bastante solo',
    ),
  ],
);

/// Conditional encouragement messages

/// Biblical encouragement for faith users with weak support
const biblicalEncouragement = ConditionalMessage(
  title: 'No estás solo',
  message: 'Dios está contigo en cada paso. Él es tu fortaleza y tu refugio.',
  verseReference: 'Isaías 41:10',
  verseText:
      'Así que no temas, porque yo estoy contigo; no te angusties, porque yo soy tu Dios. Te fortaleceré y te ayudaré; te sostendré con mi diestra victoriosa.',
);

/// Community encouragement for wellness users with weak support
const communityEncouragement = ConditionalMessage(
  title: 'Estamos juntos en esto',
  message:
      '¡No estás solo! Miles de usuarios están en el mismo camino que tú. Juntos podemos lograr nuestros objetivos.',
);

/// Get questions based on user intent
List<OnboardingQuestion> getQuestionsForIntent(UserIntent intent) {
  final questions = <OnboardingQuestion>[intentQuestion];

  switch (intent) {
    case UserIntent.faithBased:
      questions.addAll([spiritualMotivationQuestion, faithWalkQuestion]);
      break;
    case UserIntent.wellness:
      questions.addAll([wellnessGoalsQuestion, currentStateQuestion]);
      break;
    case UserIntent.both:
      questions.addAll([
        spiritualMotivationQuestion,
        wellnessGoalsQuestion,
        faithWalkQuestion,
      ]);
      break;
  }

  // Add universal questions
  questions.addAll([mainChallengeQuestion, supportSystemQuestion]);

  return questions;
}

/// Get encouragement message based on intent and support level
ConditionalMessage? getEncouragementMessage(
  UserIntent intent,
  String supportLevel,
) {
  if (supportLevel != 'weak') {
    return null; // Only show for weak support
  }

  switch (intent) {
    case UserIntent.faithBased:
    case UserIntent.both:
      return biblicalEncouragement;
    case UserIntent.wellness:
      return communityEncouragement;
  }
}
