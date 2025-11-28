class PlanetPosition {
  final String planet;
  final String sign;
  final double degree;
  final int house;
  final String nakshatra;
  final bool isRetrograde;

  PlanetPosition({
    required this.planet,
    required this.sign,
    required this.degree,
    required this.house,
    required this.nakshatra,
    required this.isRetrograde,
  });

  String get formattedDegree {
    final degrees = degree.floor();
    final minutes = ((degree - degrees) * 60).floor();
    return '$degrees°$minutes\'';
  }

  Map<String, dynamic> toMap() {
    return {
      'planet': planet,
      'sign': sign,
      'degree': degree,
      'house': house,
      'nakshatra': nakshatra,
      'isRetrograde': isRetrograde,
    };
  }

  factory PlanetPosition.fromMap(Map<String, dynamic> map) {
    return PlanetPosition(
      planet: map['planet'],
      sign: map['sign'],
      degree: map['degree'],
      house: map['house'],
      nakshatra: map['nakshatra'],
      isRetrograde: map['isRetrograde'],
    );
  }
}


