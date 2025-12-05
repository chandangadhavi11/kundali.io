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

