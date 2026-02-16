import '../../config/ai_config.dart';

/// Centralized prompts for Gemini AI service
/// Extracted for maintainability and testing
class GeminiPrompts {
  /// Generates prompt for micro-habit generation
  static String microHabitGeneration({
    required String userGoal,
    String? failurePattern,
    required String faithContext,
    required String languageCode,
  }) {
    // Language name mapping for clearer instructions
    final languageNames = {
      'en': 'English',
      'es': 'Spanish',
      'pt': 'Portuguese',
      'fr': 'French',
      'zh': 'Chinese',
    };
    final languageName = languageNames[languageCode] ?? 'English';

    return '''
User goal: "$userGoal"
${failurePattern != null ? 'Failure pattern: $failurePattern' : ''}
Faith context: $faithContext
Output language: $languageCode ($languageName)

Generate EXACTLY ${AiConfig.habitsPerGeneration} micro-habits in $languageName.

REQUIRED FIELDS (output in $languageName):
1. action: specific action with number/time (e.g., "Pray 10 minutes", "Read 3 chapters")
2. verse: Bible reference (e.g., "Psalm 5:3", "John 3:16")
3. verseText: full verse text in $languageName
4. purpose: why this helps achieve the goal (in $languageName)
5. estimatedMinutes: 1-${AiConfig.maxHabitMinutes}
6. scheduledTime: "HH:mm" format (24-hour, e.g., "07:00") - optimal time for this habit
7. trigger: when/where context (e.g., "Right after waking up", "Before breakfast")
8. notifications: array of notification objects with time, title, body

EXAMPLE (for Spanish output):
{
  "action": "Oración matutina de 10 minutos",
  "verse": "Salmos 5:3",
  "verseText": "Oh Jehová, de mañana oirás mi voz; De mañana me presentaré delante de ti, y esperaré.",
  "purpose": "Conectar espiritualmente antes de empezar el día laboral",
  "estimatedMinutes": 10,
  "scheduledTime": "07:00",
  "trigger": "Inmediatamente después de despertar, antes de revisar el teléfono",
  "notifications": [
    {
      "time": "06:55",
      "title": "🙏 En 5 min: Tiempo con Dios",
      "body": "Prepara tu espacio de oración"
    }
  ]
}

STRICT RULES:
- Output ALL text content in $languageName (action, verseText, purpose, trigger, notification title/body)
- Actions must be CONCRETE: include numbers, times, or specific triggers
- Purpose must explain the LOGICAL CONNECTION between action and goal
- scheduledTime should be optimal time of day for this habit
- trigger should provide clear context of when/where to do the habit
- Include at least 1 notification per habit with appropriate timing
- Notification times should be 5-10 minutes before scheduledTime
- Tone: practical, motivational, focused on user's goal

Respond ONLY with valid JSON array (no markdown, no ```json):
[{...}, {...}, {...}]
''';
  }
}
