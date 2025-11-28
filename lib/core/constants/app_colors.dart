import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Warm, spiritual tones
  static const Color primary = Color(0xFFFF6B35); // Saffron Orange
  static const Color primaryLight = Color(0xFFFF9F68);
  static const Color primaryDark = Color(0xFFE55100);

  // Secondary Colors - Deep cosmic blues
  static const Color secondary = Color(0xFF2E3192); // Deep Blue
  static const Color secondaryLight = Color(0xFF5B5FC7);
  static const Color secondaryDark = Color(0xFF1A1B5C);

  // Accent Colors
  static const Color accent = Color(0xFFFFC947); // Golden Yellow
  static const Color accentLight = Color(0xFFFFD978);
  static const Color accentDark = Color(0xFFE5A820);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Zodiac Sign Colors
  static const Map<String, Color> zodiacColors = {
    'aries': Color(0xFFFF4444),
    'taurus': Color(0xFF66BB6A),
    'gemini': Color(0xFFFFD54F),
    'cancer': Color(0xFF90CAF9),
    'leo': Color(0xFFFFB74D),
    'virgo': Color(0xFF8D6E63),
    'libra': Color(0xFFEC407A),
    'scorpio': Color(0xFF8B0000),
    'sagittarius': Color(0xFF9C27B0),
    'capricorn': Color(0xFF5D4037),
    'aquarius': Color(0xFF00ACC1),
    'pisces': Color(0xFF7E57C2),
  };

  // Planet Colors
  static const Map<String, Color> planetColors = {
    'sun': Color(0xFFFF9800),
    'moon': Color(0xFFE0E0E0),
    'mars': Color(0xFFFF5252),
    'mercury': Color(0xFF4CAF50),
    'jupiter': Color(0xFFFFEB3B),
    'venus': Color(0xFFE91E63),
    'saturn': Color(0xFF607D8B),
    'rahu': Color(0xFF3F51B5),
    'ketu': Color(0xFF9E9E9E),
  };

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cosmicGradient = LinearGradient(
    colors: [Color(0xFF1A1B5C), Color(0xFF2E3192), Color(0xFF5B5FC7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}


