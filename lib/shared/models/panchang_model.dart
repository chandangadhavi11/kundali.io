class Panchang {
  final DateTime date;
  final String tithi;
  final String nakshatra;
  final String yoga;
  final String karana;
  final String vara;
  final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;
  final String rahuKaal;
  final String gulikai;
  final String yamaganda;
  final String abhijitMuhurat;
  final List<String> festivals;
  final List<String> auspiciousTimings;
  final List<String> inauspiciousTimings;

  Panchang({
    required this.date,
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.vara,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.rahuKaal,
    required this.gulikai,
    required this.yamaganda,
    required this.abhijitMuhurat,
    required this.festivals,
    required this.auspiciousTimings,
    required this.inauspiciousTimings,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'tithi': tithi,
      'nakshatra': nakshatra,
      'yoga': yoga,
      'karana': karana,
      'vara': vara,
      'sunrise': sunrise,
      'sunset': sunset,
      'moonrise': moonrise,
      'moonset': moonset,
      'rahuKaal': rahuKaal,
      'gulikai': gulikai,
      'yamaganda': yamaganda,
      'abhijitMuhurat': abhijitMuhurat,
      'festivals': festivals,
      'auspiciousTimings': auspiciousTimings,
      'inauspiciousTimings': inauspiciousTimings,
    };
  }

  factory Panchang.fromMap(Map<String, dynamic> map) {
    return Panchang(
      date: DateTime.parse(map['date']),
      tithi: map['tithi'],
      nakshatra: map['nakshatra'],
      yoga: map['yoga'],
      karana: map['karana'],
      vara: map['vara'],
      sunrise: map['sunrise'],
      sunset: map['sunset'],
      moonrise: map['moonrise'],
      moonset: map['moonset'],
      rahuKaal: map['rahuKaal'],
      gulikai: map['gulikai'],
      yamaganda: map['yamaganda'],
      abhijitMuhurat: map['abhijitMuhurat'],
      festivals: List<String>.from(map['festivals']),
      auspiciousTimings: List<String>.from(map['auspiciousTimings']),
      inauspiciousTimings: List<String>.from(map['inauspiciousTimings']),
    );
  }
}


