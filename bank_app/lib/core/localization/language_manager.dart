import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager {
  static const String _storageKey = 'selected_language';
  static SharedPreferences? _prefs;

  static final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en', 'US'));

  static Locale get currentLocale => localeNotifier.value;

  static bool get isTurkish => currentLocale.languageCode == 'tr';

  /// Initialize the LanguageManager, loading the saved preference if available.
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedLang = _prefs?.getString(_storageKey);
      if (savedLang != null) {
        if (savedLang == 'tr') {
          localeNotifier.value = const Locale('tr', 'TR');
        } else {
          localeNotifier.value = const Locale('en', 'US');
        }
      } else {
        // Fallback to system language
        final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
        if (systemLocale.languageCode.startsWith('tr')) {
          localeNotifier.value = const Locale('tr', 'TR');
        }
      }
    } catch (e) {
      debugPrint('Failed to initialize SharedPreferences for language: $e');
    }
  }

  /// Update the language selection and save to persistent storage.
  static Future<void> setLanguage(String languageCode) async {
    if (languageCode == 'tr') {
      localeNotifier.value = const Locale('tr', 'TR');
    } else {
      localeNotifier.value = const Locale('en', 'US');
    }
    await _prefs?.setString(_storageKey, languageCode);
  }

  /// Translate static values inline based on current active locale.
  static String translate(String en, String tr) {
    return isTurkish ? tr : en;
  }
}
