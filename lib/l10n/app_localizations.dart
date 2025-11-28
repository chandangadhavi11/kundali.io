import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // App Name
  String get appName => _localizedValues[locale.languageCode]!['appName']!;

  // Authentication
  String get welcome => _localizedValues[locale.languageCode]!['welcome']!;
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get signup => _localizedValues[locale.languageCode]!['signup']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get confirmPassword =>
      _localizedValues[locale.languageCode]!['confirmPassword']!;
  String get forgotPassword =>
      _localizedValues[locale.languageCode]!['forgotPassword']!;
  String get continueWithGoogle =>
      _localizedValues[locale.languageCode]!['continueWithGoogle']!;
  String get continueWithFacebook =>
      _localizedValues[locale.languageCode]!['continueWithFacebook']!;
  String get guestMode => _localizedValues[locale.languageCode]!['guestMode']!;

  // Navigation
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get horoscope => _localizedValues[locale.languageCode]!['horoscope']!;
  String get panchang => _localizedValues[locale.languageCode]!['panchang']!;
  String get chat => _localizedValues[locale.languageCode]!['chat']!;
  String get profile => _localizedValues[locale.languageCode]!['profile']!;

  // Home Screen
  String get dailyHoroscope =>
      _localizedValues[locale.languageCode]!['dailyHoroscope']!;
  String get generateKundli =>
      _localizedValues[locale.languageCode]!['generateKundli']!;
  String get panchangToday =>
      _localizedValues[locale.languageCode]!['panchangToday']!;
  String get talkToAstrologer =>
      _localizedValues[locale.languageCode]!['talkToAstrologer']!;
  String get kundliMatching =>
      _localizedValues[locale.languageCode]!['kundliMatching']!;

  // Kundli
  String get name => _localizedValues[locale.languageCode]!['name']!;
  String get dateOfBirth =>
      _localizedValues[locale.languageCode]!['dateOfBirth']!;
  String get timeOfBirth =>
      _localizedValues[locale.languageCode]!['timeOfBirth']!;
  String get placeOfBirth =>
      _localizedValues[locale.languageCode]!['placeOfBirth']!;
  String get gender => _localizedValues[locale.languageCode]!['gender']!;
  String get male => _localizedValues[locale.languageCode]!['male']!;
  String get female => _localizedValues[locale.languageCode]!['female']!;
  String get other => _localizedValues[locale.languageCode]!['other']!;

  // Common
  String get submit => _localizedValues[locale.languageCode]!['submit']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get share => _localizedValues[locale.languageCode]!['share']!;
  String get download => _localizedValues[locale.languageCode]!['download']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get success => _localizedValues[locale.languageCode]!['success']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get theme => _localizedValues[locale.languageCode]!['theme']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'Kundali',
      'welcome': 'Welcome',
      'login': 'Login',
      'signup': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'forgotPassword': 'Forgot Password?',
      'continueWithGoogle': 'Continue with Google',
      'continueWithFacebook': 'Continue with Facebook',
      'guestMode': 'Continue as Guest',
      'home': 'Home',
      'horoscope': 'Horoscope',
      'panchang': 'Panchang',
      'chat': 'Chat',
      'profile': 'Profile',
      'dailyHoroscope': 'Daily Horoscope',
      'generateKundli': 'Generate Kundli',
      'panchangToday': 'Panchang Today',
      'talkToAstrologer': 'Talk to Astrologer',
      'kundliMatching': 'Kundli Matching',
      'name': 'Name',
      'dateOfBirth': 'Date of Birth',
      'timeOfBirth': 'Time of Birth',
      'placeOfBirth': 'Place of Birth',
      'gender': 'Gender',
      'male': 'Male',
      'female': 'Female',
      'other': 'Other',
      'submit': 'Submit',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'share': 'Share',
      'download': 'Download',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'settings': 'Settings',
      'language': 'Language',
      'theme': 'Theme',
      'logout': 'Logout',
    },
    'hi': {
      'appName': 'कुंडली',
      'welcome': 'स्वागत है',
      'login': 'लॉगिन',
      'signup': 'साइन अप',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'confirmPassword': 'पासवर्ड की पुष्टि करें',
      'forgotPassword': 'पासवर्ड भूल गए?',
      'continueWithGoogle': 'Google से जारी रखें',
      'continueWithFacebook': 'Facebook से जारी रखें',
      'guestMode': 'अतिथि के रूप में जारी रखें',
      'home': 'होम',
      'horoscope': 'राशिफल',
      'panchang': 'पंचांग',
      'chat': 'चैट',
      'profile': 'प्रोफ़ाइल',
      'dailyHoroscope': 'दैनिक राशिफल',
      'generateKundli': 'कुंडली बनाएं',
      'panchangToday': 'आज का पंचांग',
      'talkToAstrologer': 'ज्योतिषी से बात करें',
      'kundliMatching': 'कुंडली मिलान',
      'name': 'नाम',
      'dateOfBirth': 'जन्म तिथि',
      'timeOfBirth': 'जन्म समय',
      'placeOfBirth': 'जन्म स्थान',
      'gender': 'लिंग',
      'male': 'पुरुष',
      'female': 'महिला',
      'other': 'अन्य',
      'submit': 'जमा करें',
      'cancel': 'रद्द करें',
      'save': 'सहेजें',
      'delete': 'हटाएं',
      'share': 'साझा करें',
      'download': 'डाउनलोड',
      'loading': 'लोड हो रहा है...',
      'error': 'त्रुटि',
      'success': 'सफलता',
      'settings': 'सेटिंग्स',
      'language': 'भाषा',
      'theme': 'थीम',
      'logout': 'लॉगआउट',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}


