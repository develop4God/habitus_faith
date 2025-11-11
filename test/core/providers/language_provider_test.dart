import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/core/providers/language_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLanguage Enum Tests', () {
    test('should have 5 supported languages', () {
      expect(AppLanguage.values.length, equals(5));
    });

    test('should have correct language codes', () {
      expect(AppLanguage.english.code, equals('en'));
      expect(AppLanguage.spanish.code, equals('es'));
      expect(AppLanguage.french.code, equals('fr'));
      expect(AppLanguage.portuguese.code, equals('pt'));
      expect(AppLanguage.chinese.code, equals('zh'));
    });

    test('should have correct language names', () {
      expect(AppLanguage.english.name, equals('English'));
      expect(AppLanguage.spanish.name, equals('Español'));
      expect(AppLanguage.french.name, equals('Français'));
      expect(AppLanguage.portuguese.name, equals('Português'));
      expect(AppLanguage.chinese.name, equals('中文'));
    });

    test('should have flag emoji for each language', () {
      for (final language in AppLanguage.values) {
        expect(language.flag, isNotEmpty);
        expect(language.flag.length, greaterThan(0));
      }
    });

    test('fromCode should return correct language', () {
      expect(AppLanguage.fromCode('en'), equals(AppLanguage.english));
      expect(AppLanguage.fromCode('es'), equals(AppLanguage.spanish));
      expect(AppLanguage.fromCode('fr'), equals(AppLanguage.french));
      expect(AppLanguage.fromCode('pt'), equals(AppLanguage.portuguese));
      expect(AppLanguage.fromCode('zh'), equals(AppLanguage.chinese));
    });

    test('fromCode should default to Spanish for invalid code', () {
      expect(AppLanguage.fromCode('invalid'), equals(AppLanguage.spanish));
      expect(AppLanguage.fromCode(''), equals(AppLanguage.spanish));
      expect(AppLanguage.fromCode('de'), equals(AppLanguage.spanish));
    });
  });

  group('AppLanguageNotifier Tests', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should default to Spanish locale', () async {
      final notifier = container.read(appLanguageProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100)); // Wait for load

      expect(notifier.state.languageCode, equals('es'));
    });

    test('should load saved language from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'locale': 'en'});
      final newContainer = ProviderContainer();
      addTearDown(newContainer.dispose);

      final notifier = newContainer.read(appLanguageProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100)); // Wait for load

      expect(notifier.state.languageCode, equals('en'));
    });

    test('setLanguage should update state', () async {
      final notifier = container.read(appLanguageProvider.notifier);

      await notifier.setLanguage('en');
      expect(notifier.state.languageCode, equals('en'));

      await notifier.setLanguage('fr');
      expect(notifier.state.languageCode, equals('fr'));
    });

    test('setLanguage should persist to SharedPreferences', () async {
      final notifier = container.read(appLanguageProvider.notifier);

      await notifier.setLanguage('zh');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locale'), equals('zh'));
    });

    test('currentLanguageCode should return current language code', () async {
      final notifier = container.read(appLanguageProvider.notifier);

      await notifier.setLanguage('pt');
      expect(notifier.currentLanguageCode, equals('pt'));
    });

    test('currentLanguage should return correct AppLanguage', () async {
      final notifier = container.read(appLanguageProvider.notifier);

      await notifier.setLanguage('en');
      expect(notifier.currentLanguage, equals(AppLanguage.english));

      await notifier.setLanguage('es');
      expect(notifier.currentLanguage, equals(AppLanguage.spanish));

      await notifier.setLanguage('fr');
      expect(notifier.currentLanguage, equals(AppLanguage.french));

      await notifier.setLanguage('pt');
      expect(notifier.currentLanguage, equals(AppLanguage.portuguese));

      await notifier.setLanguage('zh');
      expect(notifier.currentLanguage, equals(AppLanguage.chinese));
    });
  });

  group('Language Provider State Management Tests', () {
    test('should handle rapid language changes', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appLanguageProvider.notifier);

      // Rapidly change languages
      await notifier.setLanguage('en');
      await notifier.setLanguage('es');
      await notifier.setLanguage('fr');
      await notifier.setLanguage('pt');
      await notifier.setLanguage('zh');

      // Final state should be Chinese
      expect(notifier.state.languageCode, equals('zh'));
    });

    test('should maintain state consistency across provider reads', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appLanguageProvider.notifier);
      await notifier.setLanguage('fr');

      // Read provider multiple times
      final locale1 = container.read(appLanguageProvider);
      final locale2 = container.read(appLanguageProvider);
      final locale3 = container.read(appLanguageProvider);

      expect(locale1.languageCode, equals('fr'));
      expect(locale2.languageCode, equals('fr'));
      expect(locale3.languageCode, equals('fr'));
    });

    test('should notify listeners when language changes', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appLanguageProvider.notifier);

      final locales = <String>[];
      container.listen<Locale>(appLanguageProvider, (previous, next) {
        locales.add(next.languageCode);
      });

      await notifier.setLanguage('en');
      await notifier.setLanguage('es');
      await notifier.setLanguage('fr');

      expect(locales, contains('en'));
      expect(locales, contains('es'));
      expect(locales, contains('fr'));
    });
  });

  group('Edge Cases and Error Handling', () {
    test('should handle empty SharedPreferences gracefully', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appLanguageProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      // Should default to Spanish
      expect(notifier.state.languageCode, equals('es'));
    });

    test('should handle invalid language code in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'locale': 'invalid'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appLanguageProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      // Should load the invalid code but fromCode will default to Spanish
      expect(notifier.state.languageCode, equals('invalid'));
      expect(notifier.currentLanguage, equals(AppLanguage.spanish));
    });

    test('should handle all supported languages sequentially', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appLanguageProvider.notifier);

      for (final language in AppLanguage.values) {
        await notifier.setLanguage(language.code);
        expect(notifier.state.languageCode, equals(language.code));
        expect(notifier.currentLanguage, equals(language));
      }
    });

    test(
      'should preserve language across provider container dispose',
      () async {
        SharedPreferences.setMockInitialValues({});

        // First container
        final container1 = ProviderContainer();
        final notifier1 = container1.read(appLanguageProvider.notifier);
        await notifier1.setLanguage('zh');
        container1.dispose();

        // Second container should load saved language
        final container2 = ProviderContainer();
        addTearDown(container2.dispose);
        final notifier2 = container2.read(appLanguageProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier2.state.languageCode, equals('zh'));
      },
    );

    test('should handle setting same language multiple times', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appLanguageProvider.notifier);

      await notifier.setLanguage('en');
      await notifier.setLanguage('en');
      await notifier.setLanguage('en');

      expect(notifier.state.languageCode, equals('en'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locale'), equals('en'));
    });
  });

  group('Language Persistence Tests', () {
    test('should persist each language correctly', () async {
      for (final language in AppLanguage.values) {
        SharedPreferences.setMockInitialValues({});
        final container = ProviderContainer();

        final notifier = container.read(appLanguageProvider.notifier);
        await notifier.setLanguage(language.code);

        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getString('locale'),
          equals(language.code),
          reason: 'Language ${language.name} should persist correctly',
        );

        container.dispose();
      }
    });

    test('should load persisted language correctly', () async {
      for (final language in AppLanguage.values) {
        SharedPreferences.setMockInitialValues({'locale': language.code});
        final container = ProviderContainer();

        final notifier = container.read(appLanguageProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          notifier.state.languageCode,
          equals(language.code),
          reason: 'Should load ${language.name} correctly',
        );

        container.dispose();
      }
    });
  });

  group('Locale Object Tests', () {
    test('should create valid Locale objects', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appLanguageProvider.notifier);

      for (final language in AppLanguage.values) {
        await notifier.setLanguage(language.code);
        final locale = notifier.state;

        expect(locale.languageCode, equals(language.code));
        expect(locale.countryCode, isEmpty);
      }
    });
  });
}
