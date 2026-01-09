import 'package:flutter/material.dart';

/// Alert type classification for styling
enum AlertType {
  /// Challenging or cautionary influence (e.g., Sade Sati)
  warning,
  
  /// Neutral or informational influence
  neutral,
  
  /// Beneficial or positive influence (e.g., Raja Yoga)
  positive,
}

/// Alert priority for sorting - lower index = higher priority
enum AlertPriority {
  /// Shani Sade Sati - highest priority
  sadeSati(0),
  
  /// Major Dasha (Rahu/Ketu/Shani as Mahadasha lord)
  majorDasha(1),
  
  /// Manglik Dosha
  manglikDosha(2),
  
  /// Moon Affliction
  moonAffliction(3),
  
  /// Shani Dhaiya (Small Panoti)
  dhaiya(4),
  
  /// Positive Yogas - lowest priority
  positiveYoga(5);

  final int value;
  const AlertPriority(this.value);
}

/// Sade Sati phase enumeration
enum SadeSatiPhase {
  /// Saturn in 12th from Moon - Rising phase
  first('1st Phase (Rising)', '12th from Moon'),
  
  /// Saturn in 1st (same as Moon) - Peak phase
  peak('Peak Phase', 'Transiting Moon Sign'),
  
  /// Saturn in 2nd from Moon - Setting phase
  third('3rd Phase (Setting)', '2nd from Moon');

  final String displayName;
  final String position;
  const SadeSatiPhase(this.displayName, this.position);
}

/// Dhaiya phase enumeration
enum DhaiyaPhase {
  /// Saturn in 4th from Moon
  fourth('4th from Moon', 'Kantak Shani'),
  
  /// Saturn in 8th from Moon
  eighth('8th from Moon', 'Ashtama Shani');

  final String position;
  final String name;
  const DhaiyaPhase(this.position, this.name);
}

/// Complete model for astrological alerts/influences
class AstroAlert {
  /// Unique identifier for this alert
  final String id;
  
  /// Type of alert for styling purposes
  final AlertType type;
  
  /// Priority for sorting (lower = higher priority)
  final AlertPriority priority;
  
  /// Main title of the alert (e.g., "Shani Sade Sati")
  final String title;
  
  /// Subtitle with phase/type info (e.g., "Peak Phase")
  final String subtitle;
  
  /// Brief one-line description
  final String description;
  
  /// Start date of this influence (if time-bound)
  final DateTime? startDate;
  
  /// End date of this influence (if time-bound)
  final DateTime? endDate;
  
  /// Planet/celestial symbol for the icon
  final String iconSymbol;
  
  /// Planet name for fetching image
  final String? planetName;
  
  /// Accent color for this alert type
  final Color accentColor;
  
  /// One-line theme/impact summary
  final String themeSummary;
  
  /// Detailed explanation for bottom sheet
  final String detailedExplanation;
  
  /// Formation logic/reasoning
  final String formationLogic;
  
  /// List of effects/impacts
  final List<String> effects;
  
  /// Optional remedies (future-ready)
  final List<String>? remedies;
  
  /// For Sade Sati: which phase
  final SadeSatiPhase? sadeSatiPhase;
  
  /// For Dhaiya: which phase
  final DhaiyaPhase? dhaiyaPhase;

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
    this.planetName,
    required this.accentColor,
    required this.themeSummary,
    required this.detailedExplanation,
    required this.formationLogic,
    required this.effects,
    this.remedies,
    this.sadeSatiPhase,
    this.dhaiyaPhase,
  });

  /// Compare by priority for sorting
  int compareTo(AstroAlert other) {
    return priority.value.compareTo(other.priority.value);
  }

  /// Get formatted date range string
  String? get dateRangeString {
    if (startDate == null && endDate == null) return null;
    
    final start = startDate != null 
        ? _formatDate(startDate!) 
        : 'Unknown';
    final end = endDate != null 
        ? _formatDate(endDate!) 
        : 'Ongoing';
    
    return '$start – $end';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Create a copy with updated values
  AstroAlert copyWith({
    String? id,
    AlertType? type,
    AlertPriority? priority,
    String? title,
    String? subtitle,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? iconSymbol,
    String? planetName,
    Color? accentColor,
    String? themeSummary,
    String? detailedExplanation,
    String? formationLogic,
    List<String>? effects,
    List<String>? remedies,
    SadeSatiPhase? sadeSatiPhase,
    DhaiyaPhase? dhaiyaPhase,
  }) {
    return AstroAlert(
      id: id ?? this.id,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      iconSymbol: iconSymbol ?? this.iconSymbol,
      planetName: planetName ?? this.planetName,
      accentColor: accentColor ?? this.accentColor,
      themeSummary: themeSummary ?? this.themeSummary,
      detailedExplanation: detailedExplanation ?? this.detailedExplanation,
      formationLogic: formationLogic ?? this.formationLogic,
      effects: effects ?? this.effects,
      remedies: remedies ?? this.remedies,
      sadeSatiPhase: sadeSatiPhase ?? this.sadeSatiPhase,
      dhaiyaPhase: dhaiyaPhase ?? this.dhaiyaPhase,
    );
  }
}

/// Predefined accent colors for different alert types
class AstroAlertColors {
  AstroAlertColors._();

  /// Saturn / Sade Sati / Dhaiya - Muted steel blue
  static const Color saturn = Color(0xFF6B8DD6);

  /// Rahu - Smoky purple
  static const Color rahu = Color(0xFF9B59B6);

  /// Ketu - Dark teal
  static const Color ketu = Color(0xFF2DD4BF);

  /// Mars / Manglik - Coral red
  static const Color mars = Color(0xFFF87171);

  /// Moon affliction - Soft silver/teal
  static const Color moon = Color(0xFF9BC4E2);

  /// Positive yoga - Gold
  static const Color positive = Color(0xFFD4AF37);

  /// Get color based on priority
  static Color forPriority(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.sadeSati:
      case AlertPriority.dhaiya:
        return saturn;
      case AlertPriority.majorDasha:
        return rahu;
      case AlertPriority.manglikDosha:
        return mars;
      case AlertPriority.moonAffliction:
        return moon;
      case AlertPriority.positiveYoga:
        return positive;
    }
  }
}

