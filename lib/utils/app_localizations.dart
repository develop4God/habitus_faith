import 'dart:convert';
import 'package:flutter/services.dart';

class AppLocalizations {
  final String languageCode;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.languageCode);

  static AppLocalizations of(String languageCode) {
    return AppLocalizations(languageCode);
  }

  Future<bool> load() async {
    try {
      String jsonString =
          await rootBundle.loadString('lib/i18n/$languageCode.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings =
          jsonMap.map((key, value) => MapEntry(key, value.toString()));
      return true;
    } catch (e) {
      // Fallback to Spanish if loading fails
      String jsonString = await rootBundle.loadString('lib/i18n/es.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings =
          jsonMap.map((key, value) => MapEntry(key, value.toString()));
      return true;
    }
  }

  String translate(String key, {Map<String, String>? params}) {
    String value = _localizedStrings[key] ?? key;
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue);
      });
    }
    return value;
  }

  String get appName => translate('app_name');
  String get bibleReader => translate('bible_reader');
  String get search => translate('search');
  String get share => translate('share');
  String get copy => translate('copy');
  String get copied => translate('copied');
  String get shared => translate('shared');
  String versionChanged(String version) =>
      translate('version_changed', params: {'version': version});
  String get selectVersion => translate('select_version');
  String get book => translate('book');
  String get chapter => translate('chapter');
  String get verse => translate('verse');
  String get noVerses => translate('no_verses');
  String get loading => translate('loading');
  String get newFeature => translate('new_feature');
  String get copyright => translate('copyright');
  String get home => translate('home');
  String get bible => translate('bible');
  String get plans => translate('plans');
  String get discover => translate('discover');
  String get more => translate('more');
}
