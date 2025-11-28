class Horoscope {
  final String sign;
  final DateTime date;
  final String period; // Daily, Weekly, Monthly, Yearly
  final String general;
  final String love;
  final String career;
  final String health;
  final String finance;
  final int luckyNumber;
  final String luckyColor;
  final String mood;
  final String compatibility;
  final int rating; // Overall rating for the day (1-5)
  final String? luckyTime; // Lucky time of the day

  Horoscope({
    required this.sign,
    required this.date,
    required this.period,
    required this.general,
    required this.love,
    required this.career,
    required this.health,
    required this.finance,
    required this.luckyNumber,
    required this.luckyColor,
    required this.mood,
    required this.compatibility,
    this.rating = 4, // Default rating
    this.luckyTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'sign': sign,
      'date': date.toIso8601String(),
      'period': period,
      'general': general,
      'love': love,
      'career': career,
      'health': health,
      'finance': finance,
      'luckyNumber': luckyNumber,
      'luckyColor': luckyColor,
      'mood': mood,
      'compatibility': compatibility,
      'rating': rating,
      'luckyTime': luckyTime,
    };
  }

  factory Horoscope.fromMap(Map<String, dynamic> map) {
    return Horoscope(
      sign: map['sign'],
      date: DateTime.parse(map['date']),
      period: map['period'],
      general: map['general'],
      love: map['love'],
      career: map['career'],
      health: map['health'],
      finance: map['finance'],
      luckyNumber: map['luckyNumber'],
      luckyColor: map['luckyColor'],
      mood: map['mood'],
      compatibility: map['compatibility'],
      rating: map['rating'] ?? 4,
      luckyTime: map['luckyTime'],
    );
  }
}
