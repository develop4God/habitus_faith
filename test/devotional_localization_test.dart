import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:habitus_faith/l10n/app_localizations_en.dart';
import 'package:habitus_faith/l10n/app_localizations_es.dart';
import 'package:habitus_faith/l10n/app_localizations_pt.dart';
import 'package:habitus_faith/l10n/app_localizations_fr.dart';
import 'package:habitus_faith/l10n/app_localizations_zh.dart';

void main() {
  group('Devotional Localization Tests', () {
    test('English localization should have all devotional keys', () {
      final l10n = AppLocalizationsEn();

      expect(l10n.readVerseFirst, equals('Read Verse First'));
      expect(l10n.reflection, equals('Reflection'));
      expect(l10n.forMeditation, equals('For Meditation'));
      expect(l10n.prayer, equals('Prayer'));
      expect(l10n.todayLabel, equals('Today'));
      expect(l10n.tomorrowLabel, equals('Tomorrow'));
    });

    test('Spanish localization should have all devotional keys', () {
      final l10n = AppLocalizationsEs();

      expect(l10n.readVerseFirst, equals('Leer Versículo Primero'));
      expect(l10n.reflection, equals('Reflexión'));
      expect(l10n.forMeditation, equals('Para Meditar'));
      expect(l10n.prayer, equals('Oración'));
      expect(l10n.todayLabel, equals('Hoy'));
      expect(l10n.tomorrowLabel, equals('Mañana'));
    });

    test('Portuguese localization should have all devotional keys', () {
      final l10n = AppLocalizationsPt();

      expect(l10n.readVerseFirst, equals('Ler Versículo Primeiro'));
      expect(l10n.reflection, equals('Reflexão'));
      expect(l10n.forMeditation, equals('Para Meditar'));
      expect(l10n.prayer, equals('Oração'));
      expect(l10n.todayLabel, equals('Hoje'));
      expect(l10n.tomorrowLabel, equals('Amanhã'));
    });

    test('French localization should have all devotional keys', () {
      final l10n = AppLocalizationsFr();

      expect(l10n.readVerseFirst, equals('Lire le Verset d\'Abord'));
      expect(l10n.reflection, equals('Réflexion'));
      expect(l10n.forMeditation, equals('Pour Méditer'));
      expect(l10n.prayer, equals('Prière'));
      expect(l10n.todayLabel, equals('Aujourd\'hui'));
      expect(l10n.tomorrowLabel, equals('Demain'));
    });

    test('Chinese localization should have all devotional keys', () {
      final l10n = AppLocalizationsZh();

      expect(l10n.readVerseFirst, equals('先读经文'));
      expect(l10n.reflection, equals('反思'));
      expect(l10n.forMeditation, equals('默想要点'));
      expect(l10n.prayer, equals('祷告'));
      expect(l10n.todayLabel, equals('今天'));
      expect(l10n.tomorrowLabel, equals('明天'));
    });
  });

  group('Devotional Date Display Tests', () {
    testWidgets('Should display "Today" for today\'s devotional in English',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(
            body: _TestDateWidget(),
          ),
        ),
      );

      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('Should display "Hoy" for today\'s devotional in Spanish',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('es'),
          home: Scaffold(
            body: _TestDateWidget(),
          ),
        ),
      );

      expect(find.text('Hoy'), findsOneWidget);
    });

    testWidgets('Should display "Hoje" for today\'s devotional in Portuguese',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('pt'),
          home: Scaffold(
            body: _TestDateWidget(),
          ),
        ),
      );

      expect(find.text('Hoje'), findsOneWidget);
    });

    testWidgets(
        'Should display "Aujourd\'hui" for today\'s devotional in French',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('fr'),
          home: Scaffold(
            body: _TestDateWidget(),
          ),
        ),
      );

      expect(find.text('Aujourd\'hui'), findsOneWidget);
    });

    testWidgets('Should display "今天" for today\'s devotional in Chinese',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('zh'),
          home: Scaffold(
            body: _TestDateWidget(),
          ),
        ),
      );

      expect(find.text('今天'), findsOneWidget);
    });
  });
}

class _TestDateWidget extends StatelessWidget {
  const _TestDateWidget();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Text(l10n.todayLabel);
  }
}
