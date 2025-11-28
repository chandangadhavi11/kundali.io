class AppConstants {
  // App Info
  static const String appName = 'Kundali';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String baseUrl = 'https://api.kundaliapp.com/v1';
  static const String aiChatEndpoint = '/ai/chat';
  static const String horoscopeEndpoint = '/horoscope';
  static const String panchangEndpoint = '/panchang';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userProfileKey = 'user_profile';
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';
  static const String onboardingKey = 'onboarding_completed';
  static const String savedKundlisKey = 'saved_kundlis';

  // Limits
  static const int freeAiQuestionsPerDay = 3;
  static const int maxSavedProfiles = 10;
  static const int maxNameLength = 50;

  // Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration apiTimeout = Duration(seconds: 30);

  // Zodiac Signs
  static const List<String> zodiacSigns = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
  ];

  static const List<String> zodiacSignsHindi = [
    'मेष',
    'वृषभ',
    'मिथुन',
    'कर्क',
    'सिंह',
    'कन्या',
    'तुला',
    'वृश्चिक',
    'धनु',
    'मकर',
    'कुंभ',
    'मीन',
  ];

  // Planets
  static const List<String> planets = [
    'Sun',
    'Moon',
    'Mars',
    'Mercury',
    'Jupiter',
    'Venus',
    'Saturn',
    'Rahu',
    'Ketu',
  ];

  static const List<String> planetsHindi = [
    'सूर्य',
    'चंद्र',
    'मंगल',
    'बुध',
    'बृहस्पति',
    'शुक्र',
    'शनि',
    'राहु',
    'केतु',
  ];

  // Nakshatras
  static const List<String> nakshatras = [
    'Ashwini',
    'Bharani',
    'Krittika',
    'Rohini',
    'Mrigashira',
    'Ardra',
    'Punarvasu',
    'Pushya',
    'Ashlesha',
    'Magha',
    'Purva Phalguni',
    'Uttara Phalguni',
    'Hasta',
    'Chitra',
    'Swati',
    'Vishakha',
    'Anuradha',
    'Jyeshtha',
    'Mula',
    'Purva Ashadha',
    'Uttara Ashadha',
    'Shravana',
    'Dhanishta',
    'Shatabhisha',
    'Purva Bhadrapada',
    'Uttara Bhadrapada',
    'Revati',
  ];

  // Chart Styles
  static const List<String> chartStyles = ['North Indian', 'South Indian'];

  // Languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'hi': 'हिन्दी',
  };

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';

  // Validation
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^\+?[0-9]{10,13}$';

  // Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String onboardingImage1 = 'assets/images/onboarding1.png';
  static const String onboardingImage2 = 'assets/images/onboarding2.png';
  static const String onboardingImage3 = 'assets/images/onboarding3.png';

  // Animation Assets
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
}


