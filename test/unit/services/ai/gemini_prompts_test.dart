import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ai/gemini_prompts.dart';

/// Test Suite 4: Prompt Template Extraction
/// Verifies that the extracted GeminiPrompts class generates correct
/// prompts with all required fields and respects language parameters.
void main() {
  group('Prompt Template Extraction Tests', () {
    /// Test 4.1: Generates correct structure
    test('includes all required fields in prompt', () {
      // Act
      final prompt = GeminiPrompts.microHabitGeneration(
        userGoal: 'Pray',
        languageCode: 'en',
        faithContext: 'Christian',
      );

      // Assert
      expect(prompt, contains('REQUIRED FIELDS'));
      expect(prompt, contains('scheduledTime'));
      expect(prompt, contains('trigger'));
      expect(prompt, contains('notifications'));
      expect(prompt, contains('action'));
      expect(prompt, contains('verse'));
      expect(prompt, contains('verseText'));
      expect(prompt, contains('purpose'));
      expect(prompt, contains('estimatedMinutes'));
    });

    /// Test 4.2: Respects language parameter
    test('prompt specifies correct language', () {
      // Act - Spanish
      final spanishPrompt = GeminiPrompts.microHabitGeneration(
        userGoal: 'Orar',
        languageCode: 'es',
        faithContext: 'Christian',
      );

      // Assert - Spanish
      expect(spanishPrompt, contains('Output language: es (Spanish)'));
      expect(spanishPrompt, contains('in Spanish'));
      expect(spanishPrompt, contains('User goal: "Orar"'));

      // Act - French
      final frenchPrompt = GeminiPrompts.microHabitGeneration(
        userGoal: 'Prier',
        languageCode: 'fr',
        faithContext: 'Christian',
      );

      // Assert - French
      expect(frenchPrompt, contains('Output language: fr (French)'));
      expect(frenchPrompt, contains('in French'));

      // Act - English (default)
      final englishPrompt = GeminiPrompts.microHabitGeneration(
        userGoal: 'Pray',
        languageCode: 'en',
        faithContext: 'Christian',
      );

      // Assert - English
      expect(englishPrompt, contains('Output language: en (English)'));
      expect(englishPrompt, contains('in English'));
    });
  });
}
