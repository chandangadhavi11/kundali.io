import '../../shared/models/kundali_data_model.dart';
import '../../shared/models/compatibility_result.dart';

/// Service for calculating Kundli compatibility (Gun Milan)
class CompatibilityService {
  // Nakshatra list for reference
  static const List<String> nakshatras = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni',
    'Uttara Phalguni', 'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha',
    'Jyeshtha', 'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana',
    'Dhanishta', 'Shatabhisha', 'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati',
  ];

  // Zodiac signs
  static const List<String> zodiacSigns = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
  ];

  // Varna (Caste) mapping - Brahmin(4), Kshatriya(3), Vaishya(2), Shudra(1)
  static const Map<String, int> varnaMap = {
    'Cancer': 4, 'Scorpio': 4, 'Pisces': 4, // Brahmin
    'Aries': 3, 'Leo': 3, 'Sagittarius': 3, // Kshatriya
    'Taurus': 2, 'Virgo': 2, 'Capricorn': 2, // Vaishya
    'Gemini': 1, 'Libra': 1, 'Aquarius': 1, // Shudra
  };

  // Vashya groups
  static const Map<String, String> vashyaMap = {
    'Aries': 'Chatushpad', 'Taurus': 'Chatushpad',
    'Leo': 'Vanchar', 'Sagittarius': 'Chatushpad',
    'Capricorn': 'Chatushpad',
    'Gemini': 'Dwipad', 'Virgo': 'Dwipad',
    'Libra': 'Dwipad', 'Aquarius': 'Dwipad',
    'Cancer': 'Jalachara', 'Pisces': 'Jalachara',
    'Scorpio': 'Keeta',
  };

  // Yoni (Animal) mapping for nakshatras
  static const Map<String, String> yoniMap = {
    'Ashwini': 'Horse', 'Shatabhisha': 'Horse',
    'Bharani': 'Elephant', 'Revati': 'Elephant',
    'Krittika': 'Sheep', 'Pushya': 'Sheep',
    'Rohini': 'Serpent', 'Mrigashira': 'Serpent',
    'Ardra': 'Dog', 'Mula': 'Dog',
    'Punarvasu': 'Cat', 'Ashlesha': 'Cat',
    'Magha': 'Rat', 'Purva Phalguni': 'Rat',
    'Uttara Phalguni': 'Cow', 'Uttara Bhadrapada': 'Cow',
    'Hasta': 'Buffalo', 'Swati': 'Buffalo',
    'Chitra': 'Tiger', 'Vishakha': 'Tiger',
    'Anuradha': 'Deer', 'Jyeshtha': 'Deer',
    'Purva Ashadha': 'Monkey', 'Shravana': 'Monkey',
    'Uttara Ashadha': 'Mongoose', 'Dhanishta': 'Lion',
    'Purva Bhadrapada': 'Lion',
  };

  // Yoni compatibility matrix (4=Best, 0=Worst)
  static const Map<String, Map<String, int>> yoniCompatibility = {
    'Horse': {'Horse': 4, 'Elephant': 2, 'Sheep': 2, 'Serpent': 2, 'Dog': 2, 'Cat': 2, 'Rat': 2, 'Cow': 1, 'Buffalo': 0, 'Tiger': 1, 'Deer': 1, 'Monkey': 2, 'Mongoose': 2, 'Lion': 1},
    'Elephant': {'Horse': 2, 'Elephant': 4, 'Sheep': 3, 'Serpent': 3, 'Dog': 2, 'Cat': 2, 'Rat': 2, 'Cow': 2, 'Buffalo': 3, 'Tiger': 1, 'Deer': 3, 'Monkey': 3, 'Mongoose': 2, 'Lion': 0},
    'Sheep': {'Horse': 2, 'Elephant': 3, 'Sheep': 4, 'Serpent': 3, 'Dog': 1, 'Cat': 2, 'Rat': 1, 'Cow': 3, 'Buffalo': 3, 'Tiger': 1, 'Deer': 2, 'Monkey': 0, 'Mongoose': 2, 'Lion': 1},
    'Serpent': {'Horse': 2, 'Elephant': 3, 'Sheep': 3, 'Serpent': 4, 'Dog': 2, 'Cat': 1, 'Rat': 1, 'Cow': 1, 'Buffalo': 2, 'Tiger': 2, 'Deer': 2, 'Monkey': 2, 'Mongoose': 0, 'Lion': 2},
    'Dog': {'Horse': 2, 'Elephant': 2, 'Sheep': 1, 'Serpent': 2, 'Dog': 4, 'Cat': 2, 'Rat': 1, 'Cow': 2, 'Buffalo': 2, 'Tiger': 2, 'Deer': 0, 'Monkey': 2, 'Mongoose': 1, 'Lion': 2},
    'Cat': {'Horse': 2, 'Elephant': 2, 'Sheep': 2, 'Serpent': 1, 'Dog': 2, 'Cat': 4, 'Rat': 0, 'Cow': 2, 'Buffalo': 2, 'Tiger': 1, 'Deer': 2, 'Monkey': 3, 'Mongoose': 2, 'Lion': 1},
    'Rat': {'Horse': 2, 'Elephant': 2, 'Sheep': 1, 'Serpent': 1, 'Dog': 1, 'Cat': 0, 'Rat': 4, 'Cow': 2, 'Buffalo': 2, 'Tiger': 2, 'Deer': 2, 'Monkey': 2, 'Mongoose': 1, 'Lion': 2},
    'Cow': {'Horse': 1, 'Elephant': 2, 'Sheep': 3, 'Serpent': 1, 'Dog': 2, 'Cat': 2, 'Rat': 2, 'Cow': 4, 'Buffalo': 3, 'Tiger': 0, 'Deer': 2, 'Monkey': 2, 'Mongoose': 2, 'Lion': 1},
    'Buffalo': {'Horse': 0, 'Elephant': 3, 'Sheep': 3, 'Serpent': 2, 'Dog': 2, 'Cat': 2, 'Rat': 2, 'Cow': 3, 'Buffalo': 4, 'Tiger': 1, 'Deer': 2, 'Monkey': 2, 'Mongoose': 2, 'Lion': 1},
    'Tiger': {'Horse': 1, 'Elephant': 1, 'Sheep': 1, 'Serpent': 2, 'Dog': 2, 'Cat': 1, 'Rat': 2, 'Cow': 0, 'Buffalo': 1, 'Tiger': 4, 'Deer': 1, 'Monkey': 2, 'Mongoose': 1, 'Lion': 2},
    'Deer': {'Horse': 1, 'Elephant': 3, 'Sheep': 2, 'Serpent': 2, 'Dog': 0, 'Cat': 2, 'Rat': 2, 'Cow': 2, 'Buffalo': 2, 'Tiger': 1, 'Deer': 4, 'Monkey': 2, 'Mongoose': 2, 'Lion': 1},
    'Monkey': {'Horse': 2, 'Elephant': 3, 'Sheep': 0, 'Serpent': 2, 'Dog': 2, 'Cat': 3, 'Rat': 2, 'Cow': 2, 'Buffalo': 2, 'Tiger': 2, 'Deer': 2, 'Monkey': 4, 'Mongoose': 2, 'Lion': 2},
    'Mongoose': {'Horse': 2, 'Elephant': 2, 'Sheep': 2, 'Serpent': 0, 'Dog': 1, 'Cat': 2, 'Rat': 1, 'Cow': 2, 'Buffalo': 2, 'Tiger': 1, 'Deer': 2, 'Monkey': 2, 'Mongoose': 4, 'Lion': 2},
    'Lion': {'Horse': 1, 'Elephant': 0, 'Sheep': 1, 'Serpent': 2, 'Dog': 2, 'Cat': 1, 'Rat': 2, 'Cow': 1, 'Buffalo': 1, 'Tiger': 2, 'Deer': 1, 'Monkey': 2, 'Mongoose': 2, 'Lion': 4},
  };

  // Gana (Temperament) mapping
  static const Map<String, String> ganaMap = {
    'Ashwini': 'Deva', 'Bharani': 'Manushya', 'Krittika': 'Rakshasa',
    'Rohini': 'Manushya', 'Mrigashira': 'Deva', 'Ardra': 'Manushya',
    'Punarvasu': 'Deva', 'Pushya': 'Deva', 'Ashlesha': 'Rakshasa',
    'Magha': 'Rakshasa', 'Purva Phalguni': 'Manushya', 'Uttara Phalguni': 'Manushya',
    'Hasta': 'Deva', 'Chitra': 'Rakshasa', 'Swati': 'Deva',
    'Vishakha': 'Rakshasa', 'Anuradha': 'Deva', 'Jyeshtha': 'Rakshasa',
    'Mula': 'Rakshasa', 'Purva Ashadha': 'Manushya', 'Uttara Ashadha': 'Manushya',
    'Shravana': 'Deva', 'Dhanishta': 'Rakshasa', 'Shatabhisha': 'Rakshasa',
    'Purva Bhadrapada': 'Manushya', 'Uttara Bhadrapada': 'Manushya', 'Revati': 'Deva',
  };

  // Nadi (Energy) mapping
  static const Map<String, String> nadiMap = {
    'Ashwini': 'Aadi', 'Bharani': 'Madhya', 'Krittika': 'Antya',
    'Rohini': 'Aadi', 'Mrigashira': 'Madhya', 'Ardra': 'Antya',
    'Punarvasu': 'Aadi', 'Pushya': 'Madhya', 'Ashlesha': 'Antya',
    'Magha': 'Aadi', 'Purva Phalguni': 'Madhya', 'Uttara Phalguni': 'Antya',
    'Hasta': 'Aadi', 'Chitra': 'Madhya', 'Swati': 'Antya',
    'Vishakha': 'Aadi', 'Anuradha': 'Madhya', 'Jyeshtha': 'Antya',
    'Mula': 'Aadi', 'Purva Ashadha': 'Madhya', 'Uttara Ashadha': 'Antya',
    'Shravana': 'Aadi', 'Dhanishta': 'Madhya', 'Shatabhisha': 'Antya',
    'Purva Bhadrapada': 'Aadi', 'Uttara Bhadrapada': 'Madhya', 'Revati': 'Antya',
  };

  // Sign lords for Graha Maitri
  static const Map<String, String> signLords = {
    'Aries': 'Mars', 'Taurus': 'Venus', 'Gemini': 'Mercury',
    'Cancer': 'Moon', 'Leo': 'Sun', 'Virgo': 'Mercury',
    'Libra': 'Venus', 'Scorpio': 'Mars', 'Sagittarius': 'Jupiter',
    'Capricorn': 'Saturn', 'Aquarius': 'Saturn', 'Pisces': 'Jupiter',
  };

  // Planetary friendships for Graha Maitri
  static const Map<String, Map<String, int>> planetaryFriendship = {
    'Sun': {'Moon': 1, 'Mars': 1, 'Jupiter': 1, 'Venus': -1, 'Saturn': -1, 'Mercury': 0, 'Sun': 1},
    'Moon': {'Sun': 1, 'Mercury': 1, 'Mars': 0, 'Jupiter': 0, 'Venus': 0, 'Saturn': 0, 'Moon': 1},
    'Mars': {'Sun': 1, 'Moon': 1, 'Jupiter': 1, 'Venus': 0, 'Saturn': 0, 'Mercury': -1, 'Mars': 1},
    'Mercury': {'Sun': 1, 'Venus': 1, 'Moon': -1, 'Mars': 0, 'Jupiter': 0, 'Saturn': 0, 'Mercury': 1},
    'Jupiter': {'Sun': 1, 'Moon': 1, 'Mars': 1, 'Venus': -1, 'Saturn': 0, 'Mercury': -1, 'Jupiter': 1},
    'Venus': {'Mercury': 1, 'Saturn': 1, 'Sun': -1, 'Moon': -1, 'Mars': 0, 'Jupiter': 0, 'Venus': 1},
    'Saturn': {'Mercury': 1, 'Venus': 1, 'Sun': -1, 'Moon': -1, 'Mars': -1, 'Jupiter': 0, 'Saturn': 1},
  };

  /// Calculate complete Ashtakoot score
  static CompatibilityResult calculateAshtakootScore(
    KundaliData person1,
    KundaliData person2,
  ) {
    final kutaScores = <String, KutaScore>{};
    int totalScore = 0;

    // 1. Varna Kuta (1 point max)
    final varnaScore = calculateVarna(person1.moonSign, person2.moonSign);
    kutaScores['varna'] = varnaScore;
    totalScore += varnaScore.obtained;

    // 2. Vashya Kuta (2 points max)
    final vashyaScore = calculateVashya(person1.moonSign, person2.moonSign);
    kutaScores['vashya'] = vashyaScore;
    totalScore += vashyaScore.obtained;

    // 3. Tara Kuta (3 points max)
    final taraScore = calculateTara(person1.birthNakshatra, person2.birthNakshatra);
    kutaScores['tara'] = taraScore;
    totalScore += taraScore.obtained;

    // 4. Yoni Kuta (4 points max)
    final yoniScore = calculateYoni(person1.birthNakshatra, person2.birthNakshatra);
    kutaScores['yoni'] = yoniScore;
    totalScore += yoniScore.obtained;

    // 5. Graha Maitri Kuta (5 points max)
    final grahaMaitriScore = calculateGrahaMaitri(person1.moonSign, person2.moonSign);
    kutaScores['grahaMaitri'] = grahaMaitriScore;
    totalScore += grahaMaitriScore.obtained;

    // 6. Gana Kuta (6 points max)
    final ganaScore = calculateGana(person1.birthNakshatra, person2.birthNakshatra);
    kutaScores['gana'] = ganaScore;
    totalScore += ganaScore.obtained;

    // 7. Bhakoot Kuta (7 points max)
    final bhakootScore = calculateBhakoot(person1.moonSign, person2.moonSign);
    kutaScores['bhakoot'] = bhakootScore;
    totalScore += bhakootScore.obtained;

    // 8. Nadi Kuta (8 points max)
    final nadiScore = calculateNadi(person1.birthNakshatra, person2.birthNakshatra);
    kutaScores['nadi'] = nadiScore;
    totalScore += nadiScore.obtained;

    // Detect Doshas
    final doshas = <DoshaInfo>[];
    
    // Check Mangal Dosha for both
    final mangalDosha1 = detectMangalDosha(person1);
    final mangalDosha2 = detectMangalDosha(person2);
    if (mangalDosha1.present || mangalDosha2.present) {
      final bothManglik = mangalDosha1.present && mangalDosha2.present;
      doshas.add(DoshaInfo(
        name: 'Mangal Dosha',
        present: true,
        severity: bothManglik ? 'Cancelled' : (mangalDosha1.present ? 'Person 1 is Manglik' : 'Person 2 is Manglik'),
        description: bothManglik 
            ? 'Both partners are Manglik, so the dosha is cancelled.'
            : 'One partner has Mangal Dosha. This may cause marital disharmony.',
        remedies: bothManglik ? [] : [
          'Perform Mangal Shanti Puja',
          'Wear Red Coral (Moonga) gemstone',
          'Chant Mangal Mantra on Tuesdays',
          'Fast on Tuesdays',
          'Kumbh Vivah ritual before marriage',
        ],
      ));
    }

    // Check Nadi Dosha
    if (nadiScore.obtained == 0) {
      doshas.add(DoshaInfo(
        name: 'Nadi Dosha',
        present: true,
        severity: 'High',
        description: 'Same Nadi indicates health issues for progeny and lack of mutual attraction.',
        remedies: [
          'Perform Nadi Nivaran Puja',
          'Donate gold and grains to Brahmins',
          'Chant Mahamrityunjaya Mantra',
          'Visit Trayambakeshwar Jyotirlinga',
        ],
      ));
    }

    // Calculate Love Compatibility
    final loveCompatibility = getSunSignCompatibility(person1.sunSign, person2.sunSign);

    // Determine verdict
    final verdict = _getVerdict(totalScore);

    return CompatibilityResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      person1: person1,
      person2: person2,
      totalScore: totalScore,
      kutaScores: kutaScores,
      doshas: doshas,
      overallVerdict: verdict,
      loveCompatibility: loveCompatibility,
      matchedAt: DateTime.now(),
    );
  }

  /// Calculate Varna Kuta (1 point max)
  static KutaScore calculateVarna(String moonSign1, String moonSign2) {
    final varna1 = varnaMap[moonSign1] ?? 1;
    final varna2 = varnaMap[moonSign2] ?? 1;
    
    // Groom's varna should be >= Bride's varna (traditionally)
    // For modern app, we check if they're compatible
    final score = varna1 >= varna2 ? 1 : 0;
    
    return KutaScore(
      name: 'Varna',
      obtained: score,
      maximum: 1,
      description: _getVarnaDescription(varna1, varna2),
      impact: score == 1 
          ? 'Good spiritual and ego compatibility'
          : 'May have ego clashes in relationship',
    );
  }

  static String _getVarnaDescription(int varna1, int varna2) {
    const varnaNames = {4: 'Brahmin', 3: 'Kshatriya', 2: 'Vaishya', 1: 'Shudra'};
    return '${varnaNames[varna1]} & ${varnaNames[varna2]}';
  }

  /// Calculate Vashya Kuta (2 points max)
  static KutaScore calculateVashya(String moonSign1, String moonSign2) {
    final vashya1 = vashyaMap[moonSign1] ?? 'Dwipad';
    final vashya2 = vashyaMap[moonSign2] ?? 'Dwipad';
    
    int score = 0;
    if (vashya1 == vashya2) {
      score = 2;
    } else if (_areVashyaCompatible(vashya1, vashya2)) {
      score = 1;
    }
    
    return KutaScore(
      name: 'Vashya',
      obtained: score,
      maximum: 2,
      description: '$vashya1 & $vashya2',
      impact: score == 2 
          ? 'Excellent mutual attraction and control'
          : score == 1 
              ? 'Moderate mutual attraction'
              : 'May lack mutual attraction',
    );
  }

  static bool _areVashyaCompatible(String v1, String v2) {
    const compatible = {
      'Chatushpad': ['Dwipad', 'Chatushpad'],
      'Dwipad': ['Chatushpad', 'Dwipad'],
      'Jalachara': ['Jalachara', 'Chatushpad'],
      'Vanchar': ['Vanchar', 'Chatushpad'],
      'Keeta': ['Keeta'],
    };
    return compatible[v1]?.contains(v2) ?? false;
  }

  /// Calculate Tara Kuta (3 points max)
  static KutaScore calculateTara(String nakshatra1, String nakshatra2) {
    final index1 = nakshatras.indexOf(nakshatra1);
    final index2 = nakshatras.indexOf(nakshatra2);
    
    if (index1 == -1 || index2 == -1) {
      return KutaScore(
        name: 'Tara',
        obtained: 0,
        maximum: 3,
        description: 'Unknown nakshatras',
        impact: 'Cannot determine compatibility',
      );
    }

    // Calculate Tara from person1 to person2
    int tara1 = ((index2 - index1) % 27) + 1;
    if (tara1 <= 0) tara1 += 27;
    tara1 = ((tara1 - 1) % 9) + 1;

    // Calculate Tara from person2 to person1
    int tara2 = ((index1 - index2) % 27) + 1;
    if (tara2 <= 0) tara2 += 27;
    tara2 = ((tara2 - 1) % 9) + 1;

    // Inauspicious Taras: 3 (Vipat), 5 (Pratyak), 7 (Naidhana)
    const inauspicious = [3, 5, 7];
    
    int score = 0;
    if (!inauspicious.contains(tara1) && !inauspicious.contains(tara2)) {
      score = 3;
    } else if (!inauspicious.contains(tara1) || !inauspicious.contains(tara2)) {
      score = (3 / 2).round();
    }

    return KutaScore(
      name: 'Tara',
      obtained: score,
      maximum: 3,
      description: 'Birth star harmony',
      impact: score == 3 
          ? 'Excellent health and fortune compatibility'
          : score > 0 
              ? 'Moderate birth star compatibility'
              : 'May face health or fortune challenges',
    );
  }

  /// Calculate Yoni Kuta (4 points max)
  static KutaScore calculateYoni(String nakshatra1, String nakshatra2) {
    final yoni1 = yoniMap[nakshatra1] ?? 'Horse';
    final yoni2 = yoniMap[nakshatra2] ?? 'Horse';
    
    final score = yoniCompatibility[yoni1]?[yoni2] ?? 2;
    
    return KutaScore(
      name: 'Yoni',
      obtained: score,
      maximum: 4,
      description: '$yoni1 & $yoni2',
      impact: score == 4 
          ? 'Excellent physical and sexual compatibility'
          : score >= 2 
              ? 'Good physical compatibility'
              : 'May have physical compatibility issues',
    );
  }

  /// Calculate Graha Maitri Kuta (5 points max)
  static KutaScore calculateGrahaMaitri(String moonSign1, String moonSign2) {
    final lord1 = signLords[moonSign1] ?? 'Sun';
    final lord2 = signLords[moonSign2] ?? 'Sun';
    
    final friendship1 = planetaryFriendship[lord1]?[lord2] ?? 0;
    final friendship2 = planetaryFriendship[lord2]?[lord1] ?? 0;
    
    int score = 0;
    if (friendship1 == 1 && friendship2 == 1) {
      score = 5; // Both friends
    } else if (friendship1 == 1 || friendship2 == 1) {
      score = 4; // One friend, one neutral
    } else if (friendship1 == 0 && friendship2 == 0) {
      score = 3; // Both neutral
    } else if (friendship1 == -1 && friendship2 == -1) {
      score = 0; // Both enemies
    } else {
      score = 1; // Mixed
    }
    
    return KutaScore(
      name: 'Graha Maitri',
      obtained: score,
      maximum: 5,
      description: '$lord1 & $lord2',
      impact: score >= 4 
          ? 'Excellent mental and emotional compatibility'
          : score >= 2 
              ? 'Moderate mental compatibility'
              : 'May have mental/emotional conflicts',
    );
  }

  /// Calculate Gana Kuta (6 points max)
  static KutaScore calculateGana(String nakshatra1, String nakshatra2) {
    final gana1 = ganaMap[nakshatra1] ?? 'Manushya';
    final gana2 = ganaMap[nakshatra2] ?? 'Manushya';
    
    int score = 0;
    if (gana1 == gana2) {
      score = 6;
    } else if ((gana1 == 'Deva' && gana2 == 'Manushya') ||
               (gana1 == 'Manushya' && gana2 == 'Deva')) {
      score = 5;
    } else if ((gana1 == 'Manushya' && gana2 == 'Rakshasa') ||
               (gana1 == 'Rakshasa' && gana2 == 'Manushya')) {
      score = 1;
    } else {
      score = 0; // Deva-Rakshasa
    }
    
    return KutaScore(
      name: 'Gana',
      obtained: score,
      maximum: 6,
      description: '$gana1 & $gana2',
      impact: score >= 5 
          ? 'Excellent temperament compatibility'
          : score >= 3 
              ? 'Moderate temperament match'
              : 'May have temperament conflicts',
    );
  }

  /// Calculate Bhakoot Kuta (7 points max)
  static KutaScore calculateBhakoot(String moonSign1, String moonSign2) {
    final index1 = zodiacSigns.indexOf(moonSign1);
    final index2 = zodiacSigns.indexOf(moonSign2);
    
    if (index1 == -1 || index2 == -1) {
      return KutaScore(
        name: 'Bhakoot',
        obtained: 0,
        maximum: 7,
        description: 'Unknown signs',
        impact: 'Cannot determine compatibility',
      );
    }

    // Calculate distance
    int distance = ((index2 - index1) % 12) + 1;
    
    // Inauspicious combinations: 2/12, 5/9, 6/8
    bool inauspicious = false;
    if (distance == 2 || distance == 12) inauspicious = true;
    if (distance == 5 || distance == 9) inauspicious = true;
    if (distance == 6 || distance == 8) inauspicious = true;
    
    final score = inauspicious ? 0 : 7;
    
    return KutaScore(
      name: 'Bhakoot',
      obtained: score,
      maximum: 7,
      description: '$moonSign1 - $moonSign2 ($distance houses)',
      impact: score == 7 
          ? 'Excellent financial and family prosperity'
          : 'May face financial or family challenges',
    );
  }

  /// Calculate Nadi Kuta (8 points max)
  static KutaScore calculateNadi(String nakshatra1, String nakshatra2) {
    final nadi1 = nadiMap[nakshatra1] ?? 'Madhya';
    final nadi2 = nadiMap[nakshatra2] ?? 'Madhya';
    
    // Same Nadi = 0 points (Nadi Dosha)
    final score = nadi1 == nadi2 ? 0 : 8;
    
    return KutaScore(
      name: 'Nadi',
      obtained: score,
      maximum: 8,
      description: '$nadi1 & $nadi2',
      impact: score == 8 
          ? 'Excellent health compatibility for progeny'
          : 'Nadi Dosha present - may affect progeny health',
    );
  }

  /// Detect Mangal Dosha
  static DoshaInfo detectMangalDosha(KundaliData kundali) {
    // Mars in 1st, 2nd, 4th, 7th, 8th, or 12th house indicates Mangal Dosha
    final marsPosition = kundali.planetPositions['Mars'];
    if (marsPosition == null) {
      return DoshaInfo(
        name: 'Mangal Dosha',
        present: false,
        severity: 'None',
        description: 'Mars position not found',
        remedies: [],
      );
    }

    final marsHouse = marsPosition.house;
    const manglikHouses = [1, 2, 4, 7, 8, 12];
    final isManglik = manglikHouses.contains(marsHouse);

    String severity = 'None';
    if (isManglik) {
      if (marsHouse == 7 || marsHouse == 8) {
        severity = 'High';
      } else if (marsHouse == 1 || marsHouse == 4) {
        severity = 'Medium';
      } else {
        severity = 'Low';
      }
    }

    return DoshaInfo(
      name: 'Mangal Dosha',
      present: isManglik,
      severity: severity,
      description: isManglik 
          ? 'Mars is placed in the ${_getOrdinal(marsHouse)} house'
          : 'No Mangal Dosha present',
      remedies: isManglik ? [
        'Perform Mangal Shanti Puja',
        'Wear Red Coral gemstone',
        'Chant Mangal Mantra on Tuesdays',
        'Fast on Tuesdays',
        'Kumbh Vivah before marriage',
      ] : [],
    );
  }

  static String _getOrdinal(int number) {
    if (number >= 11 && number <= 13) return '${number}th';
    switch (number % 10) {
      case 1: return '${number}st';
      case 2: return '${number}nd';
      case 3: return '${number}rd';
      default: return '${number}th';
    }
  }

  /// Get Sun Sign Compatibility for Love
  static LoveCompatibility getSunSignCompatibility(String sunSign1, String sunSign2) {
    final index1 = zodiacSigns.indexOf(sunSign1);
    final index2 = zodiacSigns.indexOf(sunSign2);
    
    if (index1 == -1 || index2 == -1) {
      return LoveCompatibility(
        percentage: 50,
        description: 'Unknown compatibility',
        strengths: [],
        challenges: [],
      );
    }

    // Calculate element compatibility
    const elements = ['Fire', 'Earth', 'Air', 'Water'];
    final element1 = elements[index1 % 4];
    final element2 = elements[index2 % 4];

    int basePercentage = 50;
    final strengths = <String>[];
    final challenges = <String>[];

    // Same element = highly compatible
    if (element1 == element2) {
      basePercentage = 85;
      strengths.add('Same elemental energy creates natural understanding');
      strengths.add('Similar approach to life and emotions');
    }
    // Compatible elements
    else if ((element1 == 'Fire' && element2 == 'Air') ||
             (element1 == 'Air' && element2 == 'Fire') ||
             (element1 == 'Earth' && element2 == 'Water') ||
             (element1 == 'Water' && element2 == 'Earth')) {
      basePercentage = 75;
      strengths.add('Complementary elements enhance each other');
      strengths.add('Good balance of energies');
    }
    // Challenging combinations
    else if ((element1 == 'Fire' && element2 == 'Water') ||
             (element1 == 'Water' && element2 == 'Fire') ||
             (element1 == 'Earth' && element2 == 'Air') ||
             (element1 == 'Air' && element2 == 'Earth')) {
      basePercentage = 55;
      challenges.add('Different elemental energies may clash');
      challenges.add('Need to work on understanding differences');
    }

    // Same sign bonus
    if (sunSign1 == sunSign2) {
      basePercentage = 90;
      strengths.add('Same sun sign creates deep understanding');
    }

    // Opposite signs (can be very compatible)
    if ((index2 - index1).abs() == 6) {
      basePercentage = 80;
      strengths.add('Opposite signs attract and complement');
    }

    // Add general strengths/challenges
    if (basePercentage >= 70) {
      strengths.add('Strong emotional connection potential');
      strengths.add('Natural attraction and chemistry');
    } else {
      challenges.add('May need effort to maintain harmony');
      challenges.add('Different communication styles');
    }

    return LoveCompatibility(
      percentage: basePercentage,
      description: _getLoveDescription(basePercentage),
      strengths: strengths,
      challenges: challenges,
    );
  }

  static String _getLoveDescription(int percentage) {
    if (percentage >= 85) return 'Soulmate potential! Exceptional romantic compatibility.';
    if (percentage >= 75) return 'Great match! Strong romantic connection likely.';
    if (percentage >= 65) return 'Good compatibility with effort.';
    if (percentage >= 55) return 'Average match. Requires understanding.';
    return 'Challenging but possible with patience.';
  }

  /// Get overall verdict based on score
  static String _getVerdict(int totalScore) {
    if (totalScore >= 32) return 'Excellent';
    if (totalScore >= 25) return 'Good';
    if (totalScore >= 18) return 'Average';
    return 'Poor';
  }

  /// Get verdict description
  static String getVerdictDescription(String verdict) {
    switch (verdict) {
      case 'Excellent':
        return 'This is a highly auspicious match! The couple is blessed with excellent compatibility across all dimensions.';
      case 'Good':
        return 'This is a favorable match with good compatibility. Minor differences can be easily managed.';
      case 'Average':
        return 'This match has moderate compatibility. Success requires understanding and adjustment from both partners.';
      case 'Poor':
        return 'This match has significant compatibility challenges. Consider consulting an astrologer for remedies.';
      default:
        return 'Unable to determine compatibility.';
    }
  }

  /// Get verdict color
  static int getVerdictColorValue(String verdict) {
    switch (verdict) {
      case 'Excellent': return 0xFF10B981; // Green
      case 'Good': return 0xFF60A5FA; // Blue
      case 'Average': return 0xFFFBBF24; // Yellow
      case 'Poor': return 0xFFEF4444; // Red
      default: return 0xFF9CA3AF; // Gray
    }
  }
}



