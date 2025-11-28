import 'planet_position.dart';

class Kundli {
  final String id;
  final String name;
  final DateTime birthDate;
  final DateTime birthTime;
  final String birthPlace;
  final double latitude;
  final double longitude;
  final String gender;
  final String ascendant;
  final String moonSign;
  final String sunSign;
  final String nakshatra;
  final List<PlanetPosition> planetPositions;
  final List<String> houses;
  final Map<String, dynamic> dashas;
  final DateTime createdAt;

  Kundli({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    required this.latitude,
    required this.longitude,
    required this.gender,
    required this.ascendant,
    required this.moonSign,
    required this.sunSign,
    required this.nakshatra,
    required this.planetPositions,
    required this.houses,
    required this.dashas,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'birthTime': birthTime.toIso8601String(),
      'birthPlace': birthPlace,
      'latitude': latitude,
      'longitude': longitude,
      'gender': gender,
      'ascendant': ascendant,
      'moonSign': moonSign,
      'sunSign': sunSign,
      'nakshatra': nakshatra,
      'planetPositions': planetPositions.map((p) => p.toMap()).toList(),
      'houses': houses,
      'dashas': dashas,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Kundli.fromMap(Map<String, dynamic> map) {
    return Kundli(
      id: map['id'],
      name: map['name'],
      birthDate: DateTime.parse(map['birthDate']),
      birthTime: DateTime.parse(map['birthTime']),
      birthPlace: map['birthPlace'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      gender: map['gender'],
      ascendant: map['ascendant'],
      moonSign: map['moonSign'],
      sunSign: map['sunSign'],
      nakshatra: map['nakshatra'],
      planetPositions:
          (map['planetPositions'] as List)
              .map((p) => PlanetPosition.fromMap(p))
              .toList(),
      houses: List<String>.from(map['houses']),
      dashas: map['dashas'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
