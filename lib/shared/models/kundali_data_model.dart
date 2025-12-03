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
    // Calculate planetary positions using Swiss Ephemeris
    final planetPositions = KundaliCalculationService.calculatePlanetaryPositions(
      birthDateTime: birthDateTime,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
    
    // Calculate ascendant using Swiss Ephemeris
    final ascendant = KundaliCalculationService.calculateAscendant(
      birthDateTime: birthDateTime,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
    
    // Calculate houses using Swiss Ephemeris
    final houses = KundaliCalculationService.calculateHouses(
      birthDateTime: birthDateTime,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
      planetPositions: planetPositions,
    );
    
    // Calculate Navamsa chart (D9)
    final navamsaChart = KundaliCalculationService.calculateNavamsaChart(planetPositions);
    
    // Calculate Dasha info based on Moon's nakshatra
    final moonPosition = planetPositions['Moon'];
    final dashaInfo = moonPosition != null
        ? KundaliCalculationService.calculateDashaInfo(birthDateTime, moonPosition.longitude)
        : KundaliCalculationService.getSampleDashaInfo(birthDateTime);

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
  
  /// Detect yogas based on planetary positions
  static List<String> _detectYogas(
    Map<String, PlanetPosition> positions,
    AscendantInfo ascendant,
  ) {
    final yogas = <String>[];
    
    // Gajakesari Yoga: Jupiter in kendra (1,4,7,10) from Moon
    final moon = positions['Moon'];
    final jupiter = positions['Jupiter'];
    if (moon != null && jupiter != null) {
      final moonHouse = moon.house;
      final jupiterHouse = jupiter.house;
      final distance = ((jupiterHouse - moonHouse).abs()) % 12;
      if (distance == 0 || distance == 3 || distance == 6 || distance == 9) {
        yogas.add('Gajakesari Yoga');
      }
    }
    
    // Budhaditya Yoga: Sun and Mercury conjunct
    final sun = positions['Sun'];
    final mercury = positions['Mercury'];
    if (sun != null && mercury != null && sun.sign == mercury.sign) {
      yogas.add('Budhaditya Yoga');
    }
    
    // Hamsa Yoga: Jupiter in kendra in own/exalted sign
    if (jupiter != null) {
      final jupiterHouse = jupiter.house;
      final isKendra = jupiterHouse == 1 || jupiterHouse == 4 || jupiterHouse == 7 || jupiterHouse == 10;
      final isStrong = jupiter.sign == 'Sagittarius' || jupiter.sign == 'Pisces' || jupiter.sign == 'Cancer';
      if (isKendra && isStrong) {
        yogas.add('Hamsa Yoga');
      }
    }
    
    // Malavya Yoga: Venus in kendra in own/exalted sign
    final venus = positions['Venus'];
    if (venus != null) {
      final venusHouse = venus.house;
      final isKendra = venusHouse == 1 || venusHouse == 4 || venusHouse == 7 || venusHouse == 10;
      final isStrong = venus.sign == 'Taurus' || venus.sign == 'Libra' || venus.sign == 'Pisces';
      if (isKendra && isStrong) {
        yogas.add('Malavya Yoga');
      }
    }
    
    // Bhadra Yoga: Mercury in kendra in own/exalted sign
    if (mercury != null) {
      final mercuryHouse = mercury.house;
      final isKendra = mercuryHouse == 1 || mercuryHouse == 4 || mercuryHouse == 7 || mercuryHouse == 10;
      final isStrong = mercury.sign == 'Gemini' || mercury.sign == 'Virgo';
      if (isKendra && isStrong) {
        yogas.add('Bhadra Yoga');
      }
    }
    
    // Ruchaka Yoga: Mars in kendra in own/exalted sign
    final mars = positions['Mars'];
    if (mars != null) {
      final marsHouse = mars.house;
      final isKendra = marsHouse == 1 || marsHouse == 4 || marsHouse == 7 || marsHouse == 10;
      final isStrong = mars.sign == 'Aries' || mars.sign == 'Scorpio' || mars.sign == 'Capricorn';
      if (isKendra && isStrong) {
        yogas.add('Ruchaka Yoga');
      }
    }
    
    // Sasa Yoga: Saturn in kendra in own/exalted sign
    final saturn = positions['Saturn'];
    if (saturn != null) {
      final saturnHouse = saturn.house;
      final isKendra = saturnHouse == 1 || saturnHouse == 4 || saturnHouse == 7 || saturnHouse == 10;
      final isStrong = saturn.sign == 'Capricorn' || saturn.sign == 'Aquarius' || saturn.sign == 'Libra';
      if (isKendra && isStrong) {
        yogas.add('Sasa Yoga');
      }
    }
    
    return yogas;
  }
  
  /// Detect doshas based on planetary positions
  static List<String> _detectDoshas(Map<String, PlanetPosition> positions) {
    final doshas = <String>[];
    
    // Manglik Dosha: Mars in 1, 4, 7, 8, or 12 house
    final mars = positions['Mars'];
    if (mars != null) {
      final marsHouse = mars.house;
      if (marsHouse == 1 || marsHouse == 4 || marsHouse == 7 || marsHouse == 8 || marsHouse == 12) {
        doshas.add('Manglik Dosha');
      }
    }
    
    // Kaal Sarp Dosha: All planets between Rahu and Ketu
    final rahu = positions['Rahu'];
    final ketu = positions['Ketu'];
    if (rahu != null && ketu != null) {
      final rahuLong = rahu.longitude;
      final ketuLong = ketu.longitude;
      bool allBetween = true;
      
      for (var entry in positions.entries) {
        if (entry.key == 'Rahu' || entry.key == 'Ketu') continue;
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
    
    // Pitra Dosha: Sun conjunct with Rahu or Ketu, or Sun in 9th house with malefic
    final sun = positions['Sun'];
    if (sun != null && rahu != null) {
      if (sun.sign == rahu.sign) {
        doshas.add('Pitra Dosha');
      }
    }
    
    return doshas;
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
      'dashaInfo': {
        'currentMahadasha': dashaInfo.currentMahadasha,
        'remainingYears': dashaInfo.remainingYears,
        'startDate': dashaInfo.startDate.toIso8601String(),
      },
    };
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
