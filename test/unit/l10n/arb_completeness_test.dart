import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:habitus_faith/l10n/app_localizations_en.dart';
import 'package:habitus_faith/l10n/app_localizations_es.dart';
import 'package:habitus_faith/l10n/app_localizations_pt.dart';
import 'package:habitus_faith/l10n/app_localizations_fr.dart';
import 'package:habitus_faith/l10n/app_localizations_zh.dart';

/// Test suite to validate ARB translations completeness
/// Ensures all UI strings are available in ARB files (no hardcoded strings)
void main() {
  group('ARB Translations Completeness', () {
    late AppLocalizations en;
    late AppLocalizations es;
    late AppLocalizations pt;
    late AppLocalizations fr;
    late AppLocalizations zh;

    setUp(() {
      en = AppLocalizationsEn();
      es = AppLocalizationsEs();
      pt = AppLocalizationsPt();
      fr = AppLocalizationsFr();
      zh = AppLocalizationsZh();
    });

    group('Micro-Habits Generator - Page Titles', () {
      test('generateMicroHabits is available in all languages', () {
        expect(en.generateMicroHabits, isNotEmpty);
        expect(es.generateMicroHabits, isNotEmpty);
        expect(pt.generateMicroHabits, isNotEmpty);
        expect(fr.generateMicroHabits, isNotEmpty);
        expect(zh.generateMicroHabits, isNotEmpty);

        // Verify they are different (not all English)
        expect(es.generateMicroHabits, isNot(equals(en.generateMicroHabits)));
        expect(zh.generateMicroHabits, isNot(equals(en.generateMicroHabits)));
      });

      test('aiGeneratedHabits is available in all languages', () {
        expect(en.aiGeneratedHabits, isNotEmpty);
        expect(es.aiGeneratedHabits, isNotEmpty);
        expect(pt.aiGeneratedHabits, isNotEmpty);
        expect(fr.aiGeneratedHabits, isNotEmpty);
        expect(zh.aiGeneratedHabits, isNotEmpty);
      });

      test('generatedHabitsTitle is available in all languages', () {
        expect(en.generatedHabitsTitle, isNotEmpty);
        expect(es.generatedHabitsTitle, isNotEmpty);
        expect(pt.generatedHabitsTitle, isNotEmpty);
        expect(fr.generatedHabitsTitle, isNotEmpty);
        expect(zh.generatedHabitsTitle, isNotEmpty);
      });
    });

    group('Micro-Habits Generator - Form Fields', () {
      test('yourGoal is available in all languages', () {
        expect(en.yourGoal, isNotEmpty);
        expect(es.yourGoal, isNotEmpty);
        expect(pt.yourGoal, isNotEmpty);
        expect(fr.yourGoal, isNotEmpty);
        expect(zh.yourGoal, isNotEmpty);
      });

      test('goalHint is available in all languages', () {
        expect(en.goalHint, isNotEmpty);
        expect(es.goalHint, isNotEmpty);
        expect(pt.goalHint, isNotEmpty);
        expect(fr.goalHint, isNotEmpty);
        expect(zh.goalHint, isNotEmpty);
      });

      test('failurePattern is available in all languages', () {
        expect(en.failurePattern, isNotEmpty);
        expect(es.failurePattern, isNotEmpty);
        expect(pt.failurePattern, isNotEmpty);
        expect(fr.failurePattern, isNotEmpty);
        expect(zh.failurePattern, isNotEmpty);
      });

      test('failurePatternHint is available in all languages', () {
        expect(en.failurePatternHint, isNotEmpty);
        expect(es.failurePatternHint, isNotEmpty);
        expect(pt.failurePatternHint, isNotEmpty);
        expect(fr.failurePatternHint, isNotEmpty);
        expect(zh.failurePatternHint, isNotEmpty);
      });
    });

    group('Micro-Habits Generator - Validation Messages', () {
      test('goalRequired is available in all languages', () {
        expect(en.goalRequired, isNotEmpty);
        expect(es.goalRequired, isNotEmpty);
        expect(pt.goalRequired, isNotEmpty);
        expect(fr.goalRequired, isNotEmpty);
        expect(zh.goalRequired, isNotEmpty);
      });

      test('goalTooShort is available in all languages', () {
        expect(en.goalTooShort, isNotEmpty);
        expect(es.goalTooShort, isNotEmpty);
        expect(pt.goalTooShort, isNotEmpty);
        expect(fr.goalTooShort, isNotEmpty);
        expect(zh.goalTooShort, isNotEmpty);
      });

      test('goalTooLong is available in all languages', () {
        expect(en.goalTooLong, isNotEmpty);
        expect(es.goalTooLong, isNotEmpty);
        expect(pt.goalTooLong, isNotEmpty);
        expect(fr.goalTooLong, isNotEmpty);
        expect(zh.goalTooLong, isNotEmpty);
      });

      test('noHabitsSelected is available in all languages', () {
        expect(en.noHabitsSelected, isNotEmpty);
        expect(es.noHabitsSelected, isNotEmpty);
        expect(pt.noHabitsSelected, isNotEmpty);
        expect(fr.noHabitsSelected, isNotEmpty);
        expect(zh.noHabitsSelected, isNotEmpty);
      });
    });

    group('Micro-Habits Generator - Action Buttons', () {
      test('generateHabits is available in all languages', () {
        expect(en.generateHabits, isNotEmpty);
        expect(es.generateHabits, isNotEmpty);
        expect(pt.generateHabits, isNotEmpty);
        expect(fr.generateHabits, isNotEmpty);
        expect(zh.generateHabits, isNotEmpty);
      });

      test('saveSelected is available in all languages', () {
        expect(en.saveSelected, isNotEmpty);
        expect(es.saveSelected, isNotEmpty);
        expect(pt.saveSelected, isNotEmpty);
        expect(fr.saveSelected, isNotEmpty);
        expect(zh.saveSelected, isNotEmpty);
      });

      test('tryAgain is available in all languages', () {
        expect(en.tryAgain, isNotEmpty);
        expect(es.tryAgain, isNotEmpty);
        expect(pt.tryAgain, isNotEmpty);
        expect(fr.tryAgain, isNotEmpty);
        expect(zh.tryAgain, isNotEmpty);
      });
    });

    group('Micro-Habits Generator - Loading States', () {
      test('generating is available in all languages', () {
        expect(en.generating, isNotEmpty);
        expect(es.generating, isNotEmpty);
        expect(pt.generating, isNotEmpty);
        expect(fr.generating, isNotEmpty);
        expect(zh.generating, isNotEmpty);
      });

      test('generatingHabits is available in all languages', () {
        expect(en.generatingHabits, isNotEmpty);
        expect(es.generatingHabits, isNotEmpty);
        expect(pt.generatingHabits, isNotEmpty);
        expect(fr.generatingHabits, isNotEmpty);
        expect(zh.generatingHabits, isNotEmpty);
      });

      test('saving is available in all languages', () {
        expect(en.saving, isNotEmpty);
        expect(es.saving, isNotEmpty);
        expect(pt.saving, isNotEmpty);
        expect(fr.saving, isNotEmpty);
        expect(zh.saving, isNotEmpty);
      });
    });

    group('Micro-Habits Generator - Display Labels', () {
      test('bibleVerse is available in all languages', () {
        expect(en.bibleVerse, isNotEmpty);
        expect(es.bibleVerse, isNotEmpty);
        expect(pt.bibleVerse, isNotEmpty);
        expect(fr.bibleVerse, isNotEmpty);
        expect(zh.bibleVerse, isNotEmpty);
      });

      test('purpose is available in all languages', () {
        expect(en.purpose, isNotEmpty);
        expect(es.purpose, isNotEmpty);
        expect(pt.purpose, isNotEmpty);
        expect(fr.purpose, isNotEmpty);
        expect(zh.purpose, isNotEmpty);
      });

      test('selectHabitsToAdd is available in all languages', () {
        expect(en.selectHabitsToAdd, isNotEmpty);
        expect(es.selectHabitsToAdd, isNotEmpty);
        expect(pt.selectHabitsToAdd, isNotEmpty);
        expect(fr.selectHabitsToAdd, isNotEmpty);
        expect(zh.selectHabitsToAdd, isNotEmpty);
      });
    });

    group('Micro-Habits Generator - Feedback Messages', () {
      test('habitsAdded has placeholder for count', () {
        expect(en.habitsAdded(3), contains('3'));
        expect(es.habitsAdded(3), contains('3'));
        expect(pt.habitsAdded(3), contains('3'));
        expect(fr.habitsAdded(3), contains('3'));
        expect(zh.habitsAdded(3), contains('3'));
      });

      test('generationFailed is available in all languages', () {
        expect(en.generationFailed, isNotEmpty);
        expect(es.generationFailed, isNotEmpty);
        expect(pt.generationFailed, isNotEmpty);
        expect(fr.generationFailed, isNotEmpty);
        expect(zh.generationFailed, isNotEmpty);
      });

      test('rateLimitReached is available in all languages', () {
        expect(en.rateLimitReached, isNotEmpty);
        expect(es.rateLimitReached, isNotEmpty);
        expect(pt.rateLimitReached, isNotEmpty);
        expect(fr.rateLimitReached, isNotEmpty);
        expect(zh.rateLimitReached, isNotEmpty);
      });

      test('apiTimeout is available in all languages', () {
        expect(en.apiTimeout, isNotEmpty);
        expect(es.apiTimeout, isNotEmpty);
        expect(pt.apiTimeout, isNotEmpty);
        expect(fr.apiTimeout, isNotEmpty);
        expect(zh.apiTimeout, isNotEmpty);
      });

      test('invalidInput is available in all languages', () {
        expect(en.invalidInput, isNotEmpty);
        expect(es.invalidInput, isNotEmpty);
        expect(pt.invalidInput, isNotEmpty);
        expect(fr.invalidInput, isNotEmpty);
        expect(zh.invalidInput, isNotEmpty);
      });
    });

    group('Micro-Habits Generator - Information Placeholders', () {
      test('estimatedTime has placeholder for minutes', () {
        expect(en.estimatedTime(5), contains('5'));
        expect(es.estimatedTime(5), contains('5'));
        expect(pt.estimatedTime(5), contains('5'));
        expect(fr.estimatedTime(5), contains('5'));
        expect(zh.estimatedTime(5), contains('5'));
      });

      test('remaining has placeholder for count', () {
        expect(en.remaining(7), contains('7'));
        expect(es.remaining(7), contains('7'));
        expect(pt.remaining(7), contains('7'));
        expect(fr.remaining(7), contains('7'));
        expect(zh.remaining(7), contains('7'));
      });

      test('monthlyLimit has placeholder for limit', () {
        expect(en.monthlyLimit(10), contains('10'));
        expect(es.monthlyLimit(10), contains('10'));
        expect(pt.monthlyLimit(10), contains('10'));
        expect(fr.monthlyLimit(10), contains('10'));
        expect(zh.monthlyLimit(10), contains('10'));
      });

      test('generationsRemaining has placeholder for count', () {
        expect(en.generationsRemaining(5), contains('5'));
        expect(es.generationsRemaining(5), contains('5'));
        expect(pt.generationsRemaining(5), contains('5'));
        expect(fr.generationsRemaining(5), contains('5'));
        expect(zh.generationsRemaining(5), contains('5'));
      });
    });

    group('Micro-Habits Generator - Attribution', () {
      test('poweredByGemini is available in all languages', () {
        expect(en.poweredByGemini, isNotEmpty);
        expect(es.poweredByGemini, isNotEmpty);
        expect(pt.poweredByGemini, isNotEmpty);
        expect(fr.poweredByGemini, isNotEmpty);
        expect(zh.poweredByGemini, isNotEmpty);
      });
    });

    group('Translation Quality Checks', () {
      test('All languages have unique translations (not all English)', () {
        // Check a few key strings are actually translated
        final goalTexts = [
          en.yourGoal,
          es.yourGoal,
          pt.yourGoal,
          fr.yourGoal,
          zh.yourGoal,
        ];

        // Should have at least 4 unique values (some Romance languages might be similar)
        expect(goalTexts.toSet().length, greaterThanOrEqualTo(4));
      });

      test('Placeholders work correctly across all languages', () {
        // Test that placeholders are replaced, not just present as {count}
        expect(en.habitsAdded(3), isNot(contains('{count}')));
        expect(es.habitsAdded(3), isNot(contains('{count}')));
        expect(pt.habitsAdded(3), isNot(contains('{count}')));
        expect(fr.habitsAdded(3), isNot(contains('{count}')));
        expect(zh.habitsAdded(3), isNot(contains('{count}')));
      });

      test('No placeholder strings are empty', () {
        expect(en.estimatedTime(5), isNotEmpty);
        expect(en.remaining(7), isNotEmpty);
        expect(en.monthlyLimit(10), isNotEmpty);
        expect(en.generationsRemaining(5), isNotEmpty);
        expect(en.habitsAdded(3), isNotEmpty);
      });
    });
  });
}
