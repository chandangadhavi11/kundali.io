import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class LanguageProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  Locale _currentLocale = const Locale('en');

  LanguageProvider(this._prefs) {
    _loadLanguage();
  }

  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;

  /// Get the native name for the current language
  String get currentLanguageName =>
      AppConstants.supportedLanguages[_currentLocale.languageCode] ?? 'English';

  /// List of all supported locales
  static List<Locale> get supportedLocales => AppConstants.supportedLocaleCodes
      .map((code) => Locale(code))
      .toList();

  void _loadLanguage() {
    final languageCode = _prefs.getString(AppConstants.languageKey) ?? 'en';
    // Validate that the language code is supported
    if (AppConstants.supportedLanguages.containsKey(languageCode)) {
      _currentLocale = Locale(languageCode);
    } else {
      _currentLocale = const Locale('en');
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (AppConstants.supportedLanguages.containsKey(languageCode)) {
      _currentLocale = Locale(languageCode);
      notifyListeners(); // Notify immediately so UI updates
      await _prefs.setString(AppConstants.languageKey, languageCode);
    }
  }

  /// Check if a language code is supported
  bool isLanguageSupported(String languageCode) {
    return AppConstants.supportedLanguages.containsKey(languageCode);
  }

  /// Get native name for a language code
  String getNativeLanguageName(String languageCode) {
    return AppConstants.supportedLanguages[languageCode] ?? languageCode;
  }

  /// Get all supported languages as a list of maps for UI display
  List<Map<String, String>> get languagesList {
    return AppConstants.supportedLanguages.entries
        .map((e) => {'code': e.key, 'name': e.value})
        .toList();
  }
}
