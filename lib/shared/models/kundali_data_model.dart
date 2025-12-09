import '../../core/services/kundali_calculation_service.dart';

/// Complete Kundali data model
class KundaliData {
  // Basic Information
  final String id;
  final String name;
  final DateTime birthDateTime;
  final String birthPlace;
  final double latitude;
  final double longitude;
  final String timezone;
  final String gender;

  // Chart Style Preferences
  final ChartStyle chartStyle;
  final String language;

  // Calculated Data (currently static)
  final AscendantInfo ascendant;
  final Map<String, PlanetPosition> planetPositions;
  final List<House> houses;
  final DashaInfo dashaInfo;
  final Map<String, PlanetPosition>? navamsaChart;
  
  // Multi-Dasha System
  final YoginiDashaInfo? yoginiDashaInfo;
  final CharDashaInfo? charDashaInfo;

  // Additional Info
  final String moonSign;
  final String sunSign;
  final String birthNakshatra;
  final int birthNakshatraPada;
  final List<String> yogas;
  final List<String> doshas;

  // Metadata
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPrimary;

  KundaliData({
    required this.id,
    required this.name,
    required this.birthDateTime,
    required this.birthPlace,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.gender,
    this.chartStyle = ChartStyle.northIndian,
    this.language = 'English',
    required this.ascendant,
    required this.planetPositions,
    required this.houses,
    required this.dashaInfo,
    this.navamsaChart,
    this.yoginiDashaInfo,
    this.charDashaInfo,
    required this.moonSign,
    required this.sunSign,
    required this.birthNakshatra,
    required this.birthNakshatraPada,
    this.yogas = const [],
    this.doshas = const [],
    required this.createdAt,
    this.updatedAt,
    this.isPrimary = false,
  });

  /// Create from birth details using Swiss Ephemeris calculations
  factory KundaliData.fromBirthDetails({
    required String id,
    required String name,
    required DateTime birthDateTime,
    required String birthPlace,
    required double latitude,
    required double longitude,
    required String timezone,
    required String gender,
    ChartStyle chartStyle = ChartStyle.northIndian,
    String language = 'English',
    bool isPrimary = false,
  }) {
    // Clear any cached results to ensure fresh calculation
    KundaliCalculationService.clearCache();
    
    // Use unified calculation to avoid multiple Swiss Ephemeris calls
    final unifiedResult = KundaliCalculationService.calculateAll(
      birthDateTime: birthDateTime,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );

    final planetPositions = unifiedResult.planetPositions;
    final ascendant = unifiedResult.ascendant;
    final houses = unifiedResult.houses;

    // Calculate Navamsa chart (D9) - this is pure calculation, no sweph call
    final navamsaChart = KundaliCalculationService.calculateNavamsaChart(planetPositions);

    // Calculate Dasha info based on Moon's nakshatra - this is pure calculation, no sweph call
    final moonPosition = planetPositions['Moon'];
    final dashaInfo = moonPosition != null
        ? KundaliCalculationService.calculateDashaInfo(birthDateTime, moonPosition.longitude)
        : KundaliCalculationService.getSampleDashaInfo(birthDateTime);

    // Calculate Yogini Dasha (36-year cycle)
    final yoginiDashaInfo = moonPosition != null
        ? KundaliCalculationService.calculateYoginiDasha(birthDateTime, moonPosition.longitude)
        : null;

    // Calculate Char Dasha (Jaimini system)
    final charDashaInfo = KundaliCalculationService.calculateCharDasha(
      birthDateTime,
      ascendant,
      planetPositions,
      navamsaChart,
    );

    // Extract key information from calculated data
    final moonSign = planetPositions['Moon']?.sign ?? 'Aries';
    final sunSign = planetPositions['Sun']?.sign ?? 'Aries';
    final birthNakshatra = planetPositions['Moon']?.nakshatra ?? 'Ashwini';
    
    // Get nakshatra pada from Moon's position
    int birthNakshatraPada = 1;
    if (moonPosition != null) {
      final nakshatraSpan = 360.0 / 27.0;
      final degreeInNakshatra = moonPosition.longitude % nakshatraSpan;
      final padaSpan = nakshatraSpan / 4.0;
      birthNakshatraPada = (degreeInNakshatra / padaSpan).floor() + 1;
    }

    // Detect yogas based on planetary positions
    final yogas = _detectYogas(planetPositions, ascendant);
    
    // Detect doshas based on planetary positions
    final doshas = _detectDoshas(planetPositions);

    return KundaliData(
      id: id,
      name: name,
      birthDateTime: birthDateTime,
      birthPlace: birthPlace,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
      gender: gender,
      chartStyle: chartStyle,
      language: language,
      ascendant: ascendant,
      planetPositions: planetPositions,
      houses: houses,
      dashaInfo: dashaInfo,
      navamsaChart: navamsaChart,
      yoginiDashaInfo: yoginiDashaInfo,
      charDashaInfo: charDashaInfo,
      moonSign: moonSign,
      sunSign: sunSign,
      birthNakshatra: birthNakshatra,
      birthNakshatraPada: birthNakshatraPada,
      yogas: yogas,
      doshas: doshas,
      createdAt: DateTime.now(),
      isPrimary: isPrimary,
    );
  }
  
  /// Helper to check if a house is a Kendra (1, 4, 7, 10)
  static bool _isKendra(int house) => house == 1 || house == 4 || house == 7 || house == 10;
  
  /// Helper to check if a house is a Trikona (1, 5, 9)
  static bool _isTrikona(int house) => house == 1 || house == 5 || house == 9;
  
  /// Helper to check if planets are conjunct (same sign)
  static bool _areConjunct(PlanetPosition? p1, PlanetPosition? p2) {
    if (p1 == null || p2 == null) return false;
    return p1.sign == p2.sign;
  }
  
  /// Helper to get house distance from Moon
  static int _houseFromMoon(PlanetPosition? planet, PlanetPosition? moon) {
    if (planet == null || moon == null) return -1;
    return ((planet.house - moon.house + 12) % 12) + 1;
  }

  /// Detect yogas based on planetary positions (expanded with 15+ yogas)
  static List<String> _detectYogas(
    Map<String, PlanetPosition> positions,
    AscendantInfo ascendant,
  ) {
    final yogas = <String>[];
    
    final sun = positions['Sun'];
    final moon = positions['Moon'];
    final mars = positions['Mars'];
    final mercury = positions['Mercury'];
    final jupiter = positions['Jupiter'];
    final venus = positions['Venus'];
    final saturn = positions['Saturn'];
    
    // ============ PANCHA MAHAPURUSHA YOGAS ============
    
    // Hamsa Yoga: Jupiter in kendra in own/exalted sign
    if (jupiter != null) {
      final isKendra = _isKendra(jupiter.house);
      final isStrong = jupiter.sign == 'Sagittarius' || jupiter.sign == 'Pisces' || jupiter.sign == 'Cancer';
      if (isKendra && isStrong) {
        yogas.add('Hamsa Yoga');
      }
    }
    
    // Malavya Yoga: Venus in kendra in own/exalted sign
    if (venus != null) {
      final isKendra = _isKendra(venus.house);
      final isStrong = venus.sign == 'Taurus' || venus.sign == 'Libra' || venus.sign == 'Pisces';
      if (isKendra && isStrong) {
        yogas.add('Malavya Yoga');
      }
    }
    
    // Bhadra Yoga: Mercury in kendra in own/exalted sign
    if (mercury != null) {
      final isKendra = _isKendra(mercury.house);
      final isStrong = mercury.sign == 'Gemini' || mercury.sign == 'Virgo';
      if (isKendra && isStrong) {
        yogas.add('Bhadra Yoga');
      }
    }
    
    // Ruchaka Yoga: Mars in kendra in own/exalted sign
    if (mars != null) {
      final isKendra = _isKendra(mars.house);
      final isStrong = mars.sign == 'Aries' || mars.sign == 'Scorpio' || mars.sign == 'Capricorn';
      if (isKendra && isStrong) {
        yogas.add('Ruchaka Yoga');
      }
    }
    
    // Sasa Yoga: Saturn in kendra in own/exalted sign
    if (saturn != null) {
      final isKendra = _isKendra(saturn.house);
      final isStrong = saturn.sign == 'Capricorn' || saturn.sign == 'Aquarius' || saturn.sign == 'Libra';
      if (isKendra && isStrong) {
        yogas.add('Sasa Yoga');
      }
    }
    
    // ============ RAJA YOGAS ============
    
    // Gajakesari Yoga: Jupiter in kendra (1,4,7,10) from Moon
    if (moon != null && jupiter != null) {
      final distanceFromMoon = _houseFromMoon(jupiter, moon);
      if (distanceFromMoon == 1 || distanceFromMoon == 4 || distanceFromMoon == 7 || distanceFromMoon == 10) {
        yogas.add('Gajakesari Yoga');
      }
    }
    
    // Budhaditya Yoga: Sun and Mercury conjunct
    if (_areConjunct(sun, mercury)) {
      yogas.add('Budhaditya Yoga');
    }
    
    // Chandra-Mangal Yoga: Moon and Mars conjunct
    if (_areConjunct(moon, mars)) {
      yogas.add('Chandra-Mangal Yoga');
    }
    
    // Lakshmi Yoga: Venus in own/exalted sign and 9th lord strong
    if (venus != null) {
      final venusStrong = venus.sign == 'Taurus' || venus.sign == 'Libra' || venus.sign == 'Pisces';
      final venusInKendra = _isKendra(venus.house);
      if (venusStrong && venusInKendra) {
        yogas.add('Lakshmi Yoga');
      }
    }
    
    // ============ DHANA YOGAS ============
    
    // Dhana Yoga: 2nd and 11th lords connected (simplified: planets in 2nd and 11th)
    final planetsIn2nd = positions.values.where((p) => p.house == 2).toList();
    final planetsIn11th = positions.values.where((p) => p.house == 11).toList();
    if (planetsIn2nd.isNotEmpty && planetsIn11th.isNotEmpty) {
      // Check if benefics are involved
      final beneficsIn2nd = planetsIn2nd.where((p) => 
        p.planet == 'Jupiter' || p.planet == 'Venus' || p.planet == 'Mercury' || p.planet == 'Moon'
      ).isNotEmpty;
      final beneficsIn11th = planetsIn11th.where((p) => 
        p.planet == 'Jupiter' || p.planet == 'Venus' || p.planet == 'Mercury' || p.planet == 'Moon'
      ).isNotEmpty;
      if (beneficsIn2nd || beneficsIn11th) {
        yogas.add('Dhana Yoga');
      }
    }
    
    // ============ LUNAR YOGAS ============
    
    // Sunafa Yoga: Planet (not Sun/Rahu/Ketu) in 2nd from Moon
    if (moon != null) {
      final moonHouse = moon.house;
      final secondFromMoon = (moonHouse % 12) + 1;
      final planetsInSecondFromMoon = positions.values.where((p) => 
        p.house == secondFromMoon && 
        p.planet != 'Sun' && p.planet != 'Rahu' && p.planet != 'Ketu' && p.planet != 'Moon'
      ).toList();
      if (planetsInSecondFromMoon.isNotEmpty) {
        yogas.add('Sunafa Yoga');
      }
      
      // Anafa Yoga: Planet (not Sun/Rahu/Ketu) in 12th from Moon
      final twelfthFromMoon = moonHouse == 1 ? 12 : moonHouse - 1;
      final planetsInTwelfthFromMoon = positions.values.where((p) => 
        p.house == twelfthFromMoon && 
        p.planet != 'Sun' && p.planet != 'Rahu' && p.planet != 'Ketu' && p.planet != 'Moon'
      ).toList();
      if (planetsInTwelfthFromMoon.isNotEmpty) {
        yogas.add('Anafa Yoga');
      }
      
      // Durudhura Yoga: Planets in both 2nd and 12th from Moon
      if (planetsInSecondFromMoon.isNotEmpty && planetsInTwelfthFromMoon.isNotEmpty) {
        yogas.add('Durudhura Yoga');
      }
    }
    
    // ============ OTHER BENEFIC YOGAS ============
    
    // Amala Yoga: Only benefic in 10th house
    final planetsIn10th = positions.values.where((p) => p.house == 10).toList();
    if (planetsIn10th.length == 1) {
      final planetIn10th = planetsIn10th.first;
      if (planetIn10th.planet == 'Jupiter' || planetIn10th.planet == 'Venus' || 
          planetIn10th.planet == 'Mercury' || planetIn10th.planet == 'Moon') {
        yogas.add('Amala Yoga');
      }
    }
    
    // Saraswati Yoga: Jupiter, Venus, Mercury in Kendra/Trikona, Jupiter strong
    if (jupiter != null && venus != null && mercury != null) {
      final jupiterInKendraTrikona = _isKendra(jupiter.house) || _isTrikona(jupiter.house);
      final venusInKendraTrikona = _isKendra(venus.house) || _isTrikona(venus.house);
      final mercuryInKendraTrikona = _isKendra(mercury.house) || _isTrikona(mercury.house);
      final jupiterStrong = jupiter.sign == 'Sagittarius' || jupiter.sign == 'Pisces' || jupiter.sign == 'Cancer';
      
      if (jupiterInKendraTrikona && venusInKendraTrikona && mercuryInKendraTrikona && jupiterStrong) {
        yogas.add('Saraswati Yoga');
      }
    }
    
    // Gaja Yoga: Benefic lord of 9th in 9th house
    final planetsIn9th = positions.values.where((p) => p.house == 9).toList();
    if (planetsIn9th.isNotEmpty) {
      final beneficIn9th = planetsIn9th.where((p) => 
        p.planet == 'Jupiter' || p.planet == 'Venus'
      ).isNotEmpty;
      if (beneficIn9th) {
        yogas.add('Bhagya Yoga');
      }
    }
    
    // Viparita Raja Yoga: 6th/8th/12th lords in dusthana (6,8,12)
    final planetsIn6th = positions.values.where((p) => p.house == 6).toList();
    final planetsIn8th = positions.values.where((p) => p.house == 8).toList();
    final planetsIn12th = positions.values.where((p) => p.house == 12).toList();
    if (planetsIn6th.isNotEmpty || planetsIn8th.isNotEmpty || planetsIn12th.isNotEmpty) {
      // Simplified: check if malefics are in dusthana (good placement for malefics)
      final maleficsInDusthana = [
        ...planetsIn6th.where((p) => p.planet == 'Saturn' || p.planet == 'Mars' || p.planet == 'Rahu'),
        ...planetsIn8th.where((p) => p.planet == 'Saturn' || p.planet == 'Mars' || p.planet == 'Rahu'),
        ...planetsIn12th.where((p) => p.planet == 'Saturn' || p.planet == 'Mars' || p.planet == 'Rahu'),
      ];
      if (maleficsInDusthana.length >= 2) {
        yogas.add('Viparita Raja Yoga');
      }
    }
    
    return yogas;
  }
  
  /// Detect doshas based on planetary positions (expanded with more doshas)
  static List<String> _detectDoshas(Map<String, PlanetPosition> positions) {
    final doshas = <String>[];
    
    final sun = positions['Sun'];
    final moon = positions['Moon'];
    final mars = positions['Mars'];
    final jupiter = positions['Jupiter'];
    final saturn = positions['Saturn'];
    final rahu = positions['Rahu'];
    final ketu = positions['Ketu'];
    
    // ============ MAJOR DOSHAS ============
    
    // Manglik Dosha: Mars in 1, 4, 7, 8, or 12 house
    if (mars != null) {
      final marsHouse = mars.house;
      if (marsHouse == 1 || marsHouse == 4 || marsHouse == 7 || marsHouse == 8 || marsHouse == 12) {
        doshas.add('Manglik Dosha');
      }
    }
    
    // Kaal Sarp Dosha: All planets between Rahu and Ketu
    if (rahu != null && ketu != null) {
      final rahuLong = rahu.longitude;
      final ketuLong = ketu.longitude;
      bool allBetween = true;
      
      for (var entry in positions.entries) {
        if (entry.key == 'Rahu' || entry.key == 'Ketu') continue;
        // Skip outer planets
        if (entry.key == 'Uranus' || entry.key == 'Neptune' || entry.key == 'Pluto') continue;
        
        final planetLong = entry.value.longitude;
        
        // Check if planet is between Rahu and Ketu
        bool isBetween;
        if (rahuLong < ketuLong) {
          isBetween = planetLong > rahuLong && planetLong < ketuLong;
        } else {
          isBetween = planetLong > rahuLong || planetLong < ketuLong;
        }
        
        if (!isBetween) {
          allBetween = false;
          break;
        }
      }
      
      if (allBetween) {
        doshas.add('Kaal Sarp Dosha');
      }
    }
    
    // Pitra Dosha: Sun conjunct with Rahu or Ketu
    if (sun != null) {
      if (_areConjunct(sun, rahu) || _areConjunct(sun, ketu)) {
        doshas.add('Pitra Dosha');
      }
    }
    
    // ============ GRAHAN DOSHAS ============
    
    // Surya Grahan Dosha: Sun with Rahu or Ketu
    if (_areConjunct(sun, rahu)) {
      doshas.add('Surya Grahan Dosha');
    }
    if (_areConjunct(sun, ketu)) {
      doshas.add('Surya Grahan Dosha');
    }
    
    // Chandra Grahan Dosha: Moon with Rahu or Ketu
    if (_areConjunct(moon, rahu)) {
      doshas.add('Chandra Grahan Dosha');
    }
    if (_areConjunct(moon, ketu)) {
      doshas.add('Chandra Grahan Dosha');
    }
    
    // ============ OTHER DOSHAS ============
    
    // Shrapit Dosha: Saturn and Rahu conjunct
    if (_areConjunct(saturn, rahu)) {
      doshas.add('Shrapit Dosha');
    }
    
    // Guru Chandal Yoga (Dosha): Jupiter and Rahu conjunct
    if (_areConjunct(jupiter, rahu)) {
      doshas.add('Guru Chandal Yoga');
    }
    
    // Kemdrum Dosha: No planets in 2nd or 12th from Moon
    if (moon != null) {
      final moonHouse = moon.house;
      final secondFromMoon = (moonHouse % 12) + 1;
      final twelfthFromMoon = moonHouse == 1 ? 12 : moonHouse - 1;
      
      final planetsIn2ndFromMoon = positions.values.where((p) => 
        p.house == secondFromMoon && 
        p.planet != 'Sun' && p.planet != 'Rahu' && p.planet != 'Ketu' && p.planet != 'Moon'
      ).toList();
      
      final planetsIn12thFromMoon = positions.values.where((p) => 
        p.house == twelfthFromMoon && 
        p.planet != 'Sun' && p.planet != 'Rahu' && p.planet != 'Ketu' && p.planet != 'Moon'
      ).toList();
      
      if (planetsIn2ndFromMoon.isEmpty && planetsIn12thFromMoon.isEmpty) {
        doshas.add('Kemdrum Dosha');
      }
    }
    
    // Angarak Dosha: Mars and Rahu conjunct
    if (_areConjunct(mars, rahu)) {
      doshas.add('Angarak Dosha');
    }
    
    // Remove duplicates
    return doshas.toSet().toList();
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDateTime': birthDateTime.toIso8601String(),
      'birthPlace': birthPlace,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'gender': gender,
      'chartStyle': chartStyle.toString(),
      'language': language,
      'moonSign': moonSign,
      'sunSign': sunSign,
      'birthNakshatra': birthNakshatra,
      'birthNakshatraPada': birthNakshatraPada,
      'yogas': yogas,
      'doshas': doshas,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isPrimary': isPrimary,
      'ascendant': {
        'longitude': ascendant.longitude,
        'sign': ascendant.sign,
        'signDegree': ascendant.signDegree,
        'nakshatra': ascendant.nakshatra,
      },
      'planetPositions': planetPositions.map(
        (key, value) => MapEntry(key, {
          'longitude': value.longitude,
          'sign': value.sign,
          'signDegree': value.signDegree,
          'nakshatra': value.nakshatra,
          'house': value.house,
          'isRetrograde': value.isRetrograde,
        }),
      ),
      'houses': houses.map((h) => {
        'number': h.number,
        'sign': h.sign,
        'cuspDegree': h.cuspDegree,
        'planets': h.planets,
      }).toList(),
      'dashaInfo': {
        'currentMahadasha': dashaInfo.currentMahadasha,
        'remainingYears': dashaInfo.remainingYears,
        'startDate': dashaInfo.startDate.toIso8601String(),
        'sequence': dashaInfo.sequence.map((s) => {
          'planet': s.planet,
          'years': s.years,
        }).toList(),
      },
    };
  }

  /// Default dasha sequence for fallback
  static const _defaultDashaSequence = [
    DashaPeriod('Ketu', 7),
    DashaPeriod('Venus', 20),
    DashaPeriod('Sun', 6),
    DashaPeriod('Moon', 10),
    DashaPeriod('Mars', 7),
    DashaPeriod('Rahu', 18),
    DashaPeriod('Jupiter', 16),
    DashaPeriod('Saturn', 19),
    DashaPeriod('Mercury', 17),
  ];

  /// Create from JSON without recalculating (for loading from storage)
  factory KundaliData.fromJson(Map<String, dynamic> json) {
    // Parse chart style
    ChartStyle chartStyle = ChartStyle.northIndian;
    if (json['chartStyle'] != null) {
      final styleStr = json['chartStyle'].toString();
      if (styleStr.contains('southIndian')) {
        chartStyle = ChartStyle.southIndian;
      }
    }

    // Parse ascendant
    final ascJson = json['ascendant'] as Map<String, dynamic>;
    final ascendant = AscendantInfo(
      longitude: (ascJson['longitude'] as num).toDouble(),
      sign: ascJson['sign'] as String,
      signDegree: (ascJson['signDegree'] as num).toDouble(),
      nakshatra: ascJson['nakshatra'] as String,
    );

    // Parse planet positions
    final planetsJson = json['planetPositions'] as Map<String, dynamic>;
    final planetPositions = planetsJson.map((key, value) {
      final pJson = value as Map<String, dynamic>;
      return MapEntry(
        key,
        PlanetPosition(
          planet: key,
          longitude: (pJson['longitude'] as num).toDouble(),
          sign: pJson['sign'] as String,
          signDegree: (pJson['signDegree'] as num).toDouble(),
          nakshatra: pJson['nakshatra'] as String,
          house: pJson['house'] as int? ?? 1,
          isRetrograde: pJson['isRetrograde'] as bool? ?? false,
        ),
      );
    });

    // Parse houses
    final birthDt = DateTime.parse(json['birthDateTime'] as String);
    final lat = (json['latitude'] as num).toDouble();
    final lon = (json['longitude'] as num).toDouble();
    final tz = json['timezone'] as String;
    
    List<House> houses = [];
    if (json['houses'] != null) {
      final housesJson = json['houses'] as List<dynamic>;
      houses = housesJson.map((hJson) {
        final h = hJson as Map<String, dynamic>;
        return House(
          number: h['number'] as int,
          sign: h['sign'] as String,
          cuspDegree: (h['cuspDegree'] as num?)?.toDouble() ?? 0.0,
          planets: (h['planets'] as List<dynamic>?)?.cast<String>() ?? [],
        );
      }).toList();
    } else {
      // Generate basic houses if not stored (fallback)
      houses = KundaliCalculationService.calculateHouses(
        birthDateTime: birthDt,
        latitude: lat,
        longitude: lon,
        timezone: tz,
        planetPositions: planetPositions,
      );
    }

    // Parse dasha info
    final dashaJson = json['dashaInfo'] as Map<String, dynamic>?;
    DashaInfo dashaInfo;
    if (dashaJson != null) {
      final sequenceJson = dashaJson['sequence'] as List<dynamic>?;
      final sequence = sequenceJson?.map((s) {
        final sMap = s as Map<String, dynamic>;
        return DashaPeriod(sMap['planet'] as String, sMap['years'] as int);
      }).toList() ?? _defaultDashaSequence;
      
      dashaInfo = DashaInfo(
        currentMahadasha: dashaJson['currentMahadasha'] as String? ?? 'Ketu',
        remainingYears: (dashaJson['remainingYears'] as num?)?.toDouble() ?? 7.0,
        startDate: dashaJson['startDate'] != null
            ? DateTime.parse(dashaJson['startDate'] as String)
            : DateTime.now(),
        sequence: sequence,
      );
    } else {
      // Fallback dasha calculation if not stored
      final moonPos = planetPositions['Moon'];
      final birthDt = DateTime.parse(json['birthDateTime'] as String);
      dashaInfo = moonPos != null
          ? KundaliCalculationService.calculateDashaInfo(birthDt, moonPos.longitude)
          : KundaliCalculationService.getSampleDashaInfo(birthDt);
    }

    // Calculate Yogini and Char Dasha on load (not stored in JSON for simplicity)
    final moonPos = planetPositions['Moon'];
    final yoginiDashaInfo = moonPos != null
        ? KundaliCalculationService.calculateYoginiDasha(birthDt, moonPos.longitude)
        : null;
    
    final navamsaChart = KundaliCalculationService.calculateNavamsaChart(planetPositions);
    final charDashaInfo = KundaliCalculationService.calculateCharDasha(
      birthDt,
      ascendant,
      planetPositions,
      navamsaChart,
    );

    return KundaliData(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDateTime: DateTime.parse(json['birthDateTime'] as String),
      birthPlace: json['birthPlace'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String,
      gender: json['gender'] as String,
      chartStyle: chartStyle,
      language: json['language'] as String? ?? 'English',
      ascendant: ascendant,
      planetPositions: planetPositions,
      houses: houses,
      dashaInfo: dashaInfo,
      navamsaChart: navamsaChart,
      yoginiDashaInfo: yoginiDashaInfo,
      charDashaInfo: charDashaInfo,
      moonSign: json['moonSign'] as String? ?? planetPositions['Moon']?.sign ?? 'Aries',
      sunSign: json['sunSign'] as String? ?? planetPositions['Sun']?.sign ?? 'Aries',
      birthNakshatra: json['birthNakshatra'] as String? ?? planetPositions['Moon']?.nakshatra ?? 'Ashwini',
      birthNakshatraPada: json['birthNakshatraPada'] as int? ?? 1,
      yogas: (json['yogas'] as List<dynamic>?)?.cast<String>() ?? [],
      doshas: (json['doshas'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  /// Create a copy with updated values
  KundaliData copyWith({
    ChartStyle? chartStyle,
    String? language,
    bool? isPrimary,
  }) {
    return KundaliData(
      id: id,
      name: name,
      birthDateTime: birthDateTime,
      birthPlace: birthPlace,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
      gender: gender,
      chartStyle: chartStyle ?? this.chartStyle,
      language: language ?? this.language,
      ascendant: ascendant,
      planetPositions: planetPositions,
      houses: houses,
      dashaInfo: dashaInfo,
      navamsaChart: navamsaChart,
      yoginiDashaInfo: yoginiDashaInfo,
      charDashaInfo: charDashaInfo,
      moonSign: moonSign,
      sunSign: sunSign,
      birthNakshatra: birthNakshatra,
      birthNakshatraPada: birthNakshatraPada,
      yogas: yogas,
      doshas: doshas,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

/// Chart display style
enum ChartStyle { northIndian, southIndian, western }

/// Extension for chart style display
extension ChartStyleExtension on ChartStyle {
  String get displayName {
    switch (this) {
      case ChartStyle.northIndian:
        return 'North Indian';
      case ChartStyle.southIndian:
        return 'South Indian';
      case ChartStyle.western:
        return 'Western';
    }
  }
}

/// Kundali chart types (Divisional charts)
enum KundaliType {
  // Primary Charts
  lagna, // D1 - Main birth chart (Ascendant based)
  chandra, // Moon chart - houses from Moon sign
  surya, // Sun chart - houses from Sun sign
  bhavaChalit, // Bhava Chalit - cusp-based houses
  // Shodasavarga (16 Divisional Charts)
  hora, // D2 - Wealth
  drekkana, // D3 - Siblings, courage
  chaturthamsa, // D4 - Property, fortune
  saptamsa, // D7 - Children, progeny
  navamsa, // D9 - Marriage, dharma, spiritual life
  dasamsa, // D10 - Career, profession
  dwadasamsa, // D12 - Parents
  shodasamsa, // D16 - Vehicles, comforts
  vimsamsa, // D20 - Spiritual progress
  chaturvimsamsa, // D24 - Education, learning
  bhamsa, // D27 - Strength, weakness (Nakshatramsa)
  trimshamsa, // D30 - Misfortunes, evils
  khavedamsa, // D40 - Auspicious effects
  akshavedamsa, // D45 - General indications
  shashtiamsa, // D60 - Past life karma
  // Special Charts
  sudarshan, // Sudarshan Chakra - Triple chart view
  ashtakavarga, // Ashtakavarga - Point-based strength
}

/// Extension for Kundali type display
extension KundaliTypeExtension on KundaliType {
  String get displayName {
    switch (this) {
      case KundaliType.lagna:
        return 'Lagna Kundali';
      case KundaliType.chandra:
        return 'Moon Chart';
      case KundaliType.surya:
        return 'Sun Chart';
      case KundaliType.bhavaChalit:
        return 'Chalit Kundali';
      case KundaliType.hora:
        return 'Hora Chart';
      case KundaliType.drekkana:
        return 'Drekkana Chart';
      case KundaliType.chaturthamsa:
        return 'Chaturthamsha';
      case KundaliType.saptamsa:
        return 'Saptamsha';
      case KundaliType.navamsa:
        return 'Navamsha Kundali';
      case KundaliType.dasamsa:
        return 'Dasamsha Chart';
      case KundaliType.dwadasamsa:
        return 'Dwadashamsha';
      case KundaliType.shodasamsa:
        return 'Shodashamsha';
      case KundaliType.vimsamsa:
        return 'Vimshamsha';
      case KundaliType.chaturvimsamsa:
        return 'Chaturvimshamsha';
      case KundaliType.bhamsa:
        return 'Bhamsha Chart';
      case KundaliType.trimshamsa:
        return 'Trimshamsha';
      case KundaliType.khavedamsa:
        return 'Khavedamsha';
      case KundaliType.akshavedamsa:
        return 'Akshavedamsha';
      case KundaliType.shashtiamsa:
        return 'Shashtiamsha';
      case KundaliType.sudarshan:
        return 'Sudarshan Chakra';
      case KundaliType.ashtakavarga:
        return 'Ashtakavarga';
    }
  }

  String get shortName {
    switch (this) {
      case KundaliType.lagna:
        return 'Rasi/D1';
      case KundaliType.chandra:
        return 'Chandra';
      case KundaliType.surya:
        return 'Surya';
      case KundaliType.bhavaChalit:
        return 'Bhava';
      case KundaliType.hora:
        return 'D2';
      case KundaliType.drekkana:
        return 'D3';
      case KundaliType.chaturthamsa:
        return 'D4';
      case KundaliType.saptamsa:
        return 'D7';
      case KundaliType.navamsa:
        return 'D9';
      case KundaliType.dasamsa:
        return 'D10';
      case KundaliType.dwadasamsa:
        return 'D12';
      case KundaliType.shodasamsa:
        return 'D16';
      case KundaliType.vimsamsa:
        return 'D20';
      case KundaliType.chaturvimsamsa:
        return 'D24';
      case KundaliType.bhamsa:
        return 'D27';
      case KundaliType.trimshamsa:
        return 'D30';
      case KundaliType.khavedamsa:
        return 'D40';
      case KundaliType.akshavedamsa:
        return 'D45';
      case KundaliType.shashtiamsa:
        return 'D60';
      case KundaliType.sudarshan:
        return 'Chakra';
      case KundaliType.ashtakavarga:
        return 'AV';
    }
  }

  String get subtitle {
    switch (this) {
      case KundaliType.lagna:
        return 'Rasi Chart / D1 Chart';
      case KundaliType.chandra:
        return 'Chandra Kundali';
      case KundaliType.surya:
        return 'Surya Kundali';
      case KundaliType.bhavaChalit:
        return 'Bhava Chalit Chart';
      case KundaliType.hora:
        return 'Wealth Chart';
      case KundaliType.drekkana:
        return 'Siblings & Courage';
      case KundaliType.chaturthamsa:
        return 'Property & Fortune';
      case KundaliType.saptamsa:
        return 'Children & Progeny';
      case KundaliType.navamsa:
        return 'D9 - Marriage & Dharma';
      case KundaliType.dasamsa:
        return 'Career & Profession';
      case KundaliType.dwadasamsa:
        return 'Parents';
      case KundaliType.shodasamsa:
        return 'Vehicles & Comforts';
      case KundaliType.vimsamsa:
        return 'Spiritual Progress';
      case KundaliType.chaturvimsamsa:
        return 'Education & Learning';
      case KundaliType.bhamsa:
        return 'Nakshatramsa';
      case KundaliType.trimshamsa:
        return 'Misfortunes';
      case KundaliType.khavedamsa:
        return 'Auspicious Effects';
      case KundaliType.akshavedamsa:
        return 'General Indications';
      case KundaliType.shashtiamsa:
        return 'Past Life Karma';
      case KundaliType.sudarshan:
        return 'Triple Chart View';
      case KundaliType.ashtakavarga:
        return 'Point-based Strength';
    }
  }

  String get description {
    switch (this) {
      case KundaliType.lagna:
        return 'Overall life, self';
      case KundaliType.chandra:
        return 'Mind, emotions';
      case KundaliType.surya:
        return 'Soul, career, father';
      case KundaliType.bhavaChalit:
        return 'Cusp-based houses';
      case KundaliType.hora:
        return 'Wealth, finances';
      case KundaliType.drekkana:
        return 'Siblings, courage';
      case KundaliType.chaturthamsa:
        return 'Property, fortune';
      case KundaliType.saptamsa:
        return 'Children, progeny';
      case KundaliType.navamsa:
        return 'Marriage, dharma';
      case KundaliType.dasamsa:
        return 'Career, profession';
      case KundaliType.dwadasamsa:
        return 'Parents';
      case KundaliType.shodasamsa:
        return 'Vehicles, comforts';
      case KundaliType.vimsamsa:
        return 'Spiritual progress';
      case KundaliType.chaturvimsamsa:
        return 'Education, learning';
      case KundaliType.bhamsa:
        return 'Strength, weakness';
      case KundaliType.trimshamsa:
        return 'Misfortunes';
      case KundaliType.khavedamsa:
        return 'Auspicious effects';
      case KundaliType.akshavedamsa:
        return 'General indications';
      case KundaliType.shashtiamsa:
        return 'Past life karma';
      case KundaliType.sudarshan:
        return 'Triple chart view';
      case KundaliType.ashtakavarga:
        return 'Strength analysis';
    }
  }

  String get category {
    switch (this) {
      case KundaliType.lagna:
      case KundaliType.chandra:
      case KundaliType.surya:
      case KundaliType.bhavaChalit:
        return 'Primary';
      case KundaliType.sudarshan:
      case KundaliType.ashtakavarga:
        return 'Special';
      default:
        return 'Divisional';
    }
  }

  int? get division {
    switch (this) {
      case KundaliType.hora:
        return 2;
      case KundaliType.drekkana:
        return 3;
      case KundaliType.chaturthamsa:
        return 4;
      case KundaliType.saptamsa:
        return 7;
      case KundaliType.navamsa:
        return 9;
      case KundaliType.dasamsa:
        return 10;
      case KundaliType.dwadasamsa:
        return 12;
      case KundaliType.shodasamsa:
        return 16;
      case KundaliType.vimsamsa:
        return 20;
      case KundaliType.chaturvimsamsa:
        return 24;
      case KundaliType.bhamsa:
        return 27;
      case KundaliType.trimshamsa:
        return 30;
      case KundaliType.khavedamsa:
        return 40;
      case KundaliType.akshavedamsa:
        return 45;
      case KundaliType.shashtiamsa:
        return 60;
      default:
        return null;
    }
  }
}
