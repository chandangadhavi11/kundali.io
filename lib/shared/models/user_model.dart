import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final DateTime birthDate;
  final DateTime birthTime;
  final String birthPlace;
  final String gender;
  final String zodiacSign;
  final String moonSign;
  final String ascendant;
  final String? profileImage;
  final bool isPremium;
  final DateTime? premiumExpiryDate;
  final String preferredLanguage;
  final String chartStyle;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    required this.gender,
    required this.zodiacSign,
    required this.moonSign,
    required this.ascendant,
    this.profileImage,
    this.isPremium = false,
    this.premiumExpiryDate,
    this.preferredLanguage = 'en',
    this.chartStyle = 'North Indian',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate.toIso8601String(),
      'birthTime': birthTime.toIso8601String(),
      'birthPlace': birthPlace,
      'gender': gender,
      'zodiacSign': zodiacSign,
      'moonSign': moonSign,
      'ascendant': ascendant,
      'profileImage': profileImage,
      'isPremium': isPremium,
      'premiumExpiryDate': premiumExpiryDate?.toIso8601String(),
      'preferredLanguage': preferredLanguage,
      'chartStyle': chartStyle,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      birthDate: DateTime.parse(map['birthDate']),
      birthTime: DateTime.parse(map['birthTime']),
      birthPlace: map['birthPlace'] ?? '',
      gender: map['gender'] ?? '',
      zodiacSign: map['zodiacSign'] ?? '',
      moonSign: map['moonSign'] ?? '',
      ascendant: map['ascendant'] ?? '',
      profileImage: map['profileImage'],
      isPremium: map['isPremium'] ?? false,
      premiumExpiryDate:
          map['premiumExpiryDate'] != null
              ? DateTime.parse(map['premiumExpiryDate'])
              : null,
      preferredLanguage: map['preferredLanguage'] ?? 'en',
      chartStyle: map['chartStyle'] ?? 'North Indian',
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    DateTime? birthDate,
    DateTime? birthTime,
    String? birthPlace,
    String? gender,
    String? zodiacSign,
    String? moonSign,
    String? ascendant,
    String? profileImage,
    bool? isPremium,
    DateTime? premiumExpiryDate,
    String? preferredLanguage,
    String? chartStyle,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      birthPlace: birthPlace ?? this.birthPlace,
      gender: gender ?? this.gender,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      moonSign: moonSign ?? this.moonSign,
      ascendant: ascendant ?? this.ascendant,
      profileImage: profileImage ?? this.profileImage,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      chartStyle: chartStyle ?? this.chartStyle,
    );
  }
}


