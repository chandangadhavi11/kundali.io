import 'package:flutter/material.dart';

/// Alert severity/type
enum AlertType { warning, neutral, positive }

/// Priority order for sorting alerts (lower index = higher priority)
enum AlertPriority {
  sadeSati,
  majorDasha,
  manglikDosha,
  moonAffliction,
  dhaiya,
  positiveYoga,
}

/// Sade Sati phase
enum SadeSatiPhase { first, peak, third }

/// Dhaiya phase
enum DhaiyaPhase { small, big }

/// Accent colors for different alert types
class AstroAlertColors {
  static const Color saturn = Color(0xFF6B8DD6); // Muted indigo / steel blue
  static const Color rahuKetu = Color(0xFF9B59B6); // Smoky purple
  static const Color positive = Color(0xFFD4AF37); // Gold accent
  static const Color moonAffliction = Color(0xFF2DD4BF); // Soft teal
  static const Color generalWarning = Color(0xFFF87171); // Coral/Red
  static const Color neutral = Color(0xFFA09CAC); // Grey/Neutral
}

/// Data model for an astrological alert
class AstroAlert {
  final String id;
  final AlertType type;
  final AlertPriority priority;
  final String title;
  final String subtitle;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String iconSymbol; // Planet symbol or emoji
  final Color accentColor;
  final String themeSummary;
  final String detailedExplanation;
  final List<String> effects;
  final List<String>? remedies;

  const AstroAlert({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.subtitle,
    required this.description,
    this.startDate,
    this.endDate,
    required this.iconSymbol,
    required this.accentColor,
    required this.themeSummary,
    required this.detailedExplanation,
    required this.effects,
    this.remedies,
  });

  /// Get priority index for sorting (lower = more important)
  int get priorityIndex => priority.index;

  /// Check if this is a high-priority alert
  bool get isHighPriority =>
      priority == AlertPriority.sadeSati ||
      priority == AlertPriority.majorDasha ||
      priority == AlertPriority.manglikDosha;
}
