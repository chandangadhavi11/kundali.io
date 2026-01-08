import 'package:flutter/material.dart';

/// Shared color constants for Kundli Display screens
class KundliDisplayColors {
  KundliDisplayColors._();

  static const bgPrimary = Color(0xFF0D0B14);
  static const bgSecondary = Color(0xFF131020);
  static const surfaceColor = Color(0xFF1A1625);
  static const borderColor = Color(0xFF2A2438);
  static const accentPrimary = Color(0xFFD4AF37);
  static const accentSecondary = Color(0xFFA78BFA);
  static const textPrimary = Color(0xFFF8F7FC);
  static const textSecondary = Color(0xFF9B95A8);
  static const textMuted = Color(0xFF6B6478);
  
  // Planet colors
  static const sunColor = Color(0xFFFFB347);
  static const moonColor = Color(0xFFE8E8E8);
  static const marsColor = Color(0xFFFF6B6B);
  static const mercuryColor = Color(0xFF7DD87D);
  static const jupiterColor = Color(0xFFFFD700);
  static const venusColor = Color(0xFFFFB6C1);
  static const saturnColor = Color(0xFF6B8DD6);
  static const rahuColor = Color(0xFF9B59B6);
  static const ketuColor = Color(0xFF8B4513);
  static const uranusColor = Color(0xFF00CED1);
  static const neptuneColor = Color(0xFF4169E1);
  static const plutoColor = Color(0xFF8B0000);
  
  // Yoga/Dosha colors
  static const yogaGreen = Color(0xFF6EE7B7);
  static const doshaRed = Color(0xFFF87171);
}

/// Get planet color by name
Color getPlanetColor(String planet) {
  switch (planet.toLowerCase()) {
    case 'sun':
    case 'surya':
      return KundliDisplayColors.sunColor;
    case 'moon':
    case 'chandra':
      return KundliDisplayColors.moonColor;
    case 'mars':
    case 'mangal':
      return KundliDisplayColors.marsColor;
    case 'mercury':
    case 'budh':
      return KundliDisplayColors.mercuryColor;
    case 'jupiter':
    case 'guru':
      return KundliDisplayColors.jupiterColor;
    case 'venus':
    case 'shukra':
      return KundliDisplayColors.venusColor;
    case 'saturn':
    case 'shani':
      return KundliDisplayColors.saturnColor;
    case 'rahu':
      return KundliDisplayColors.rahuColor;
    case 'ketu':
      return KundliDisplayColors.ketuColor;
    case 'uranus':
      return KundliDisplayColors.uranusColor;
    case 'neptune':
      return KundliDisplayColors.neptuneColor;
    case 'pluto':
      return KundliDisplayColors.plutoColor;
    default:
      return KundliDisplayColors.textSecondary;
  }
}

/// Get planet symbol by name
String getPlanetSymbol(String planet) {
  switch (planet.toLowerCase()) {
    case 'sun':
    case 'surya':
      return '☉';
    case 'moon':
    case 'chandra':
      return '☽';
    case 'mars':
    case 'mangal':
      return '♂';
    case 'mercury':
    case 'budh':
      return '☿';
    case 'jupiter':
    case 'guru':
      return '♃';
    case 'venus':
    case 'shukra':
      return '♀';
    case 'saturn':
    case 'shani':
      return '♄';
    case 'rahu':
      return '☊';
    case 'ketu':
      return '☋';
    case 'uranus':
      return '♅';
    case 'neptune':
      return '♆';
    case 'pluto':
      return '⯓';
    default:
      return '•';
  }
}

/// Get planet image path
String getPlanetImagePath(String planet) {
  return 'assets/images/planets/${planet.toLowerCase()}.png';
}

/// Get premium planet colors matching actual image visual palette
Color getPlanetColorPremium(String planet) {
  const colors = {
    'sun': Color(0xFFFF9500),      // Intense fiery orange/yellow
    'moon': Color(0xFF9BC4E2),     // Silvery blue, ethereal
    'mars': Color(0xFFE84C30),     // Fiery red/orange
    'mercury': Color(0xFF5CAD8A),  // Teal/green
    'jupiter': Color(0xFFE8943A),  // Warm amber/orange
    'venus': Color(0xFFF5A878),    // Soft peachy pink
    'saturn': Color(0xFFD4943A),   // Golden orange
    'rahu': Color(0xFF9B7BF7),     // Mystical purple
    'ketu': Color(0xFF2DD4BF),     // Cyan/teal
  };
  return colors[planet.toLowerCase()] ?? const Color(0xFFA09CAC);
}

/// Get zodiac image path
String getZodiacImagePath(String sign) {
  return 'assets/images/zodiac/${sign.toLowerCase()}.png';
}

/// Get zodiac sign symbol
String getSignSymbol(String sign) {
  const symbols = {
    'Aries': '♈',
    'Taurus': '♉',
    'Gemini': '♊',
    'Cancer': '♋',
    'Leo': '♌',
    'Virgo': '♍',
    'Libra': '♎',
    'Scorpio': '♏',
    'Sagittarius': '♐',
    'Capricorn': '♑',
    'Aquarius': '♒',
    'Pisces': '♓',
  };
  return symbols[sign] ?? '?';
}

/// Get zodiac sign color based on visual palette from images
Color getSignColor(String sign) {
  const colors = {
    'Aries': Color(0xFFD4A84B),      // Golden yellow
    'Taurus': Color(0xFF4ECDC4),     // Cool blue/teal
    'Gemini': Color(0xFFE85A6B),     // Deep red/coral
    'Cancer': Color(0xFFB794F6),     // Lavender/violet
    'Leo': Color(0xFFE07B4C),        // Burnt orange
    'Virgo': Color(0xFFF5A6C4),      // Soft pink
    'Libra': Color(0xFF6BCB77),      // Mint green
    'Scorpio': Color(0xFFD9652B),    // Dark orange
    'Sagittarius': Color(0xFFE040FB), // Magenta
    'Capricorn': Color(0xFFB8956B),  // Earthy brown
    'Aquarius': Color(0xFF40E0D0),   // Turquoise
    'Pisces': Color(0xFF64B5F6),     // Ocean blue
  };
  return colors[sign] ?? const Color(0xFFA09CAC);
}

