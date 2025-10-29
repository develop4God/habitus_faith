import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Supported languages
enum AppLanguage {
  english('en', 'English', '🇬🇧'),
  spanish('es', 'Español', '🇪🇸'),
  french('fr', 'Français', '🇫🇷'),
  portuguese('pt', 'Português', '🇵🇹'),
  chinese('zh', '中文', '🇨🇳');

  const AppLanguage(this.code, this.name, this.flag);
  final String code;
  final String name;
  final String flag;

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.spanish, // Default to Spanish
    );
  }
}

// Provider for current app language
final appLanguageProvider =
    StateNotifierProvider<AppLanguageNotifier, Locale>((ref) {
  return AppLanguageNotifier();
});

class AppLanguageNotifier extends StateNotifier<Locale> {
  AppLanguageNotifier() : super(const Locale('es', '')) {
    _loadLanguage();
  }

  static const String _languageKey = 'locale';

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'es';
      state = Locale(languageCode, '');
    } catch (e) {
      // Default to Spanish if loading fails
      state = const Locale('es', '');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      state = Locale(languageCode, '');
    } catch (e) {
      // Handle error silently, keep current state
    }
  }

  String get currentLanguageCode => state.languageCode;

  AppLanguage get currentLanguage => AppLanguage.fromCode(currentLanguageCode);
}
