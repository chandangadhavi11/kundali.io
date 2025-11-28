import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class LanguageProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  Locale _currentLocale = const Locale('en', '');

  LanguageProvider(this._prefs) {
    _loadLanguage();
  }

  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;

  void _loadLanguage() {
    final languageCode = _prefs.getString(AppConstants.languageKey) ?? 'en';
    _currentLocale = Locale(languageCode, '');
  }

  Future<void> changeLanguage(String languageCode) async {
    if (AppConstants.supportedLanguages.containsKey(languageCode)) {
      _currentLocale = Locale(languageCode, '');
      await _prefs.setString(AppConstants.languageKey, languageCode);
      notifyListeners();
    }
  }

  String getLocalizedText(String englishText, String hindiText) {
    return _currentLocale.languageCode == 'hi' ? hindiText : englishText;
  }
}


