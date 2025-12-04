import 'kundali_data_model.dart';

/// Complete compatibility result model
class CompatibilityResult {
  final String id;
  final KundaliData person1;
  final KundaliData person2;
  final int totalScore; // out of 36
  final Map<String, KutaScore> kutaScores; // 8 kutas
  final List<DoshaInfo> doshas;
  final String overallVerdict; // Excellent/Good/Average/Poor
  final LoveCompatibility? loveCompatibility;
  final DateTime matchedAt;

  CompatibilityResult({
    required this.id,
    required this.person1,
    required this.person2,
    required this.totalScore,
    required this.kutaScores,
    required this.doshas,
    required this.overallVerdict,
    this.loveCompatibility,
    required this.matchedAt,
  });

  /// Get score as percentage
  double get scorePercentage => (totalScore / 36) * 100;

  /// Check if match is recommended
  bool get isRecommended => totalScore >= 18;

  /// Get a brief summary
  String get summary {
    return '${person1.name} & ${person2.name}: $totalScore/36 - $overallVerdict Match';
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'person1Id': person1.id,
      'person1Name': person1.name,
      'person1MoonSign': person1.moonSign,
      'person1Nakshatra': person1.birthNakshatra,
      'person2Id': person2.id,
      'person2Name': person2.name,
      'person2MoonSign': person2.moonSign,
      'person2Nakshatra': person2.birthNakshatra,
      'totalScore': totalScore,
      'kutaScores': kutaScores.map((key, value) => MapEntry(key, value.toJson())),
      'doshas': doshas.map((d) => d.toJson()).toList(),
      'overallVerdict': overallVerdict,
      'loveCompatibility': loveCompatibility?.toJson(),
      'matchedAt': matchedAt.toIso8601String(),
    };
  }

  /// Create copy with modifications
  CompatibilityResult copyWith({
    String? id,
    KundaliData? person1,
    KundaliData? person2,
    int? totalScore,
    Map<String, KutaScore>? kutaScores,
    List<DoshaInfo>? doshas,
    String? overallVerdict,
    LoveCompatibility? loveCompatibility,
    DateTime? matchedAt,
  }) {
    return CompatibilityResult(
      id: id ?? this.id,
      person1: person1 ?? this.person1,
      person2: person2 ?? this.person2,
      totalScore: totalScore ?? this.totalScore,
      kutaScores: kutaScores ?? this.kutaScores,
      doshas: doshas ?? this.doshas,
      overallVerdict: overallVerdict ?? this.overallVerdict,
      loveCompatibility: loveCompatibility ?? this.loveCompatibility,
      matchedAt: matchedAt ?? this.matchedAt,
    );
  }
}

/// Individual Kuta score model
class KutaScore {
  final String name;
  final int obtained;
  final int maximum;
  final String description;
  final String impact;

  KutaScore({
    required this.name,
    required this.obtained,
    required this.maximum,
    required this.description,
    required this.impact,
  });

  /// Get score as percentage
  double get percentage => maximum > 0 ? (obtained / maximum) * 100 : 0;

  /// Check if score is good
  bool get isGood => obtained >= (maximum / 2);

  /// Check if score is excellent
  bool get isExcellent => obtained == maximum;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'obtained': obtained,
      'maximum': maximum,
      'description': description,
      'impact': impact,
    };
  }

  /// Create from JSON
  factory KutaScore.fromJson(Map<String, dynamic> json) {
    return KutaScore(
      name: json['name'] ?? '',
      obtained: json['obtained'] ?? 0,
      maximum: json['maximum'] ?? 0,
      description: json['description'] ?? '',
      impact: json['impact'] ?? '',
    );
  }
}

/// Dosha information model
class DoshaInfo {
  final String name;
  final bool present;
  final String severity; // None, Low, Medium, High, Cancelled
  final String description;
  final List<String> remedies;

  DoshaInfo({
    required this.name,
    required this.present,
    required this.severity,
    required this.description,
    required this.remedies,
  });

  /// Check if dosha needs attention
  bool get needsAttention => present && severity != 'None' && severity != 'Cancelled';

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'present': present,
      'severity': severity,
      'description': description,
      'remedies': remedies,
    };
  }

  /// Create from JSON
  factory DoshaInfo.fromJson(Map<String, dynamic> json) {
    return DoshaInfo(
      name: json['name'] ?? '',
      present: json['present'] ?? false,
      severity: json['severity'] ?? 'None',
      description: json['description'] ?? '',
      remedies: List<String>.from(json['remedies'] ?? []),
    );
  }
}

/// Love compatibility model (Sun Sign based)
class LoveCompatibility {
  final int percentage;
  final String description;
  final List<String> strengths;
  final List<String> challenges;

  LoveCompatibility({
    required this.percentage,
    required this.description,
    required this.strengths,
    required this.challenges,
  });

  /// Get compatibility level
  String get level {
    if (percentage >= 85) return 'Excellent';
    if (percentage >= 70) return 'Good';
    if (percentage >= 55) return 'Average';
    return 'Challenging';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'percentage': percentage,
      'description': description,
      'strengths': strengths,
      'challenges': challenges,
    };
  }

  /// Create from JSON
  factory LoveCompatibility.fromJson(Map<String, dynamic> json) {
    return LoveCompatibility(
      percentage: json['percentage'] ?? 0,
      description: json['description'] ?? '',
      strengths: List<String>.from(json['strengths'] ?? []),
      challenges: List<String>.from(json['challenges'] ?? []),
    );
  }
}

/// Simplified match history item for storage
class MatchHistoryItem {
  final String id;
  final String person1Name;
  final String person1MoonSign;
  final String person2Name;
  final String person2MoonSign;
  final int totalScore;
  final String verdict;
  final DateTime matchedAt;

  MatchHistoryItem({
    required this.id,
    required this.person1Name,
    required this.person1MoonSign,
    required this.person2Name,
    required this.person2MoonSign,
    required this.totalScore,
    required this.verdict,
    required this.matchedAt,
  });

  /// Create from CompatibilityResult
  factory MatchHistoryItem.fromResult(CompatibilityResult result) {
    return MatchHistoryItem(
      id: result.id,
      person1Name: result.person1.name,
      person1MoonSign: result.person1.moonSign,
      person2Name: result.person2.name,
      person2MoonSign: result.person2.moonSign,
      totalScore: result.totalScore,
      verdict: result.overallVerdict,
      matchedAt: result.matchedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'person1Name': person1Name,
      'person1MoonSign': person1MoonSign,
      'person2Name': person2Name,
      'person2MoonSign': person2MoonSign,
      'totalScore': totalScore,
      'verdict': verdict,
      'matchedAt': matchedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory MatchHistoryItem.fromJson(Map<String, dynamic> json) {
    return MatchHistoryItem(
      id: json['id'] ?? '',
      person1Name: json['person1Name'] ?? '',
      person1MoonSign: json['person1MoonSign'] ?? '',
      person2Name: json['person2Name'] ?? '',
      person2MoonSign: json['person2MoonSign'] ?? '',
      totalScore: json['totalScore'] ?? 0,
      verdict: json['verdict'] ?? '',
      matchedAt: DateTime.parse(json['matchedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}



