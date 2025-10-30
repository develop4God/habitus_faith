import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';

void main() {
  group('Translation Homologation Verification', () {
    test('All translations are available for habits page in all languages', () {
      final locales = ['en', 'fr', 'es', 'pt', 'zh'];

      for (final locale in locales) {
        final l10n = lookupAppLocalizations(Locale(locale));

        // Test key habit page translations
        expect(l10n.myHabits, isNotEmpty,
            reason: 'myHabits should not be empty for $locale');
        expect(l10n.noHabits, isNotEmpty,
            reason: 'noHabits should not be empty for $locale');
        expect(l10n.addHabit, isNotEmpty,
            reason: 'addHabit should not be empty for $locale');
        expect(l10n.deleteHabit, isNotEmpty,
            reason: 'deleteHabit should not be empty for $locale');
        expect(l10n.editHabit, isNotEmpty,
            reason: 'editHabit should not be empty for $locale');
        expect(l10n.habitCompleted, isNotEmpty,
            reason: 'habitCompleted should not be empty for $locale');
        expect(l10n.currentStreak, isNotEmpty,
            reason: 'currentStreak should not be empty for $locale');
        expect(l10n.longestStreak, isNotEmpty,
            reason: 'longestStreak should not be empty for $locale');
        expect(l10n.category, isNotEmpty,
            reason: 'category should not be empty for $locale');
        expect(l10n.difficulty, isNotEmpty,
            reason: 'difficulty should not be empty for $locale');
        expect(l10n.save, isNotEmpty,
            reason: 'save should not be empty for $locale');
        expect(l10n.cancel, isNotEmpty,
            reason: 'cancel should not be empty for $locale');
        expect(l10n.delete, isNotEmpty,
            reason: 'delete should not be empty for $locale');
        expect(l10n.uncheck, isNotEmpty,
            reason: 'uncheck should not be empty for $locale');

        // Test parameterized translations
        final habitName = 'Test Habit';
        final deleteConfirm = l10n.deleteHabitConfirm(habitName);
        expect(deleteConfirm, contains(habitName),
            reason: 'deleteHabitConfirm should contain habit name for $locale');

        final riskPercent = 85;
        final riskMsg = l10n.riskPercentage(riskPercent);
        expect(riskMsg, contains('85'),
            reason: 'riskPercentage should contain percentage for $locale');
      }
    });

    test('All predefined habit translations are available', () {
      final locales = ['en', 'fr', 'es', 'pt', 'zh'];

      for (final locale in locales) {
        final l10n = lookupAppLocalizations(Locale(locale));

        // Test predefined habit translations
        expect(l10n.predefinedHabit_morningPrayer_name, isNotEmpty);
        expect(l10n.predefinedHabit_morningPrayer_description, isNotEmpty);
        expect(l10n.predefinedHabit_bibleReading_name, isNotEmpty);
        expect(l10n.predefinedHabit_bibleReading_description, isNotEmpty);
        expect(l10n.predefinedHabit_worship_name, isNotEmpty);
        expect(l10n.predefinedHabit_worship_description, isNotEmpty);
        expect(l10n.predefinedHabit_exercise_name, isNotEmpty);
        expect(l10n.predefinedHabit_exercise_description, isNotEmpty);
      }
    });

    test('Category translations are available in all languages', () {
      final locales = ['en', 'fr', 'es', 'pt', 'zh'];

      for (final locale in locales) {
        final l10n = lookupAppLocalizations(Locale(locale));

        expect(l10n.spiritual, isNotEmpty,
            reason: 'spiritual should not be empty for $locale');
        expect(l10n.physical, isNotEmpty,
            reason: 'physical should not be empty for $locale');
        expect(l10n.mental, isNotEmpty,
            reason: 'mental should not be empty for $locale');
        expect(l10n.relational, isNotEmpty,
            reason: 'relational should not be empty for $locale');
      }
    });
  });
}
