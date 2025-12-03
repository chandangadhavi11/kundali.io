import 'package:flutter/foundation.dart';
import 'sweph_service.dart';

/// Service for Kundali data - uses Swiss Ephemeris for accurate calculations
class KundaliCalculationService {
  // Zodiac signs in Vedic astrology
  static const List<String> zodiacSigns = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
  ];

  static const List<String> zodiacSignsHindi = [
    'मेष',
    'वृषभ',
    'मिथुन',
    'कर्क',
    'सिंह',
    'कन्या',
    'तुला',
    'वृश्चिक',
    'धनु',
    'मकर',
    'कुंभ',
    'मीन',
  ];

  // Nakshatras (27 lunar mansions)
  static const List<String> nakshatras = [
    'Ashwini',
    'Bharani',
    'Krittika',
    'Rohini',
    'Mrigashira',
    'Ardra',
    'Punarvasu',
    'Pushya',
    'Ashlesha',
    'Magha',
    'Purva Phalguni',
    'Uttara Phalguni',
    'Hasta',
    'Chitra',
    'Swati',
    'Vishakha',
    'Anuradha',
    'Jyeshtha',
    'Mula',
    'Purva Ashadha',
    'Uttara Ashadha',
    'Shravana',
    'Dhanishta',
    'Shatabhisha',
    'Purva Bhadrapada',
    'Uttara Bhadrapada',
    'Revati',
  ];

  // Planet names
  static const List<String> planets = [
    'Sun',
    'Moon',
    'Mars',
    'Mercury',
    'Jupiter',
    'Venus',
    'Saturn',
    'Rahu',
    'Ketu',
  ];

  /// Calculate planetary positions using Swiss Ephemeris
  /// This is the main method that uses actual astronomical calculations
  /// Falls back to sample data if sweph native library isn't available
  static Map<String, PlanetPosition> calculatePlanetaryPositions({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) {
    debugPrint('KundaliCalc: calculatePlanetaryPositions called');
    debugPrint(
      'KundaliCalc: SwephService.nativeLibraryAvailable = ${SwephService.nativeLibraryAvailable}',
    );

    // Check if native library is available (not available in unit tests)
    if (!SwephService.nativeLibraryAvailable) {
      debugPrint(
        'KundaliCalc: ⚠️ Using SAMPLE data (native library not available)',
      );
      return getSamplePlanetaryPositions();
    }

    try {
      debugPrint('KundaliCalc: ✅ Using REAL Swiss Ephemeris calculations');
      // Parse timezone to get offset in hours
      final timezoneOffset = SwephService.parseTimezoneOffset(timezone);

      // Get Swiss Ephemeris calculations
      final swephResult = SwephService.instance.calculateKundli(
        birthDateTime: birthDateTime,
        latitude: latitude,
        longitude: longitude,
        timezoneOffsetHours: timezoneOffset,
        useAyanamsa: true, // Use sidereal positions for Vedic astrology
      );

      // Convert sweph results to PlanetPosition objects
      final Map<String, PlanetPosition> positions = {};

      for (final planetName in planets) {
        final swephPlanet = swephResult.planets[planetName];
        if (swephPlanet != null) {
          // Calculate which house the planet is in
          final house = SwephService.getPlanetHouse(
            swephPlanet.longitude,
            swephResult.houses,
          );

          // Get nakshatra for this planet
          final nakshatra = SwephService.getNakshatra(swephPlanet.longitude);

          positions[planetName] = PlanetPosition(
            planet: planetName,
            longitude: swephPlanet.longitude,
            sign: swephPlanet.signName,
            signDegree: swephPlanet.degreeInSign,
            nakshatra: nakshatra.name,
            house: house,
            isRetrograde: swephPlanet.isRetrograde,
          );
        }
      }

      return positions;
    } catch (e) {
      // Fallback to sample data if calculation fails
      debugPrint(
        'KundaliCalculationService: ❌ Falling back to sample data: $e',
      );
      return getSamplePlanetaryPositions();
    }
  }

  /// Calculate ascendant (lagna) using Swiss Ephemeris
  /// Falls back to sample data if sweph native library isn't available
  static AscendantInfo calculateAscendant({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) {
    // Check if native library is available
    if (!SwephService.nativeLibraryAvailable) {
      return getSampleAscendant();
    }

    try {
      final timezoneOffset = SwephService.parseTimezoneOffset(timezone);

      final swephResult = SwephService.instance.calculateKundli(
        birthDateTime: birthDateTime,
        latitude: latitude,
        longitude: longitude,
        timezoneOffsetHours: timezoneOffset,
        useAyanamsa: true,
      );

      final nakshatra = SwephService.getNakshatra(swephResult.ascendant);

      return AscendantInfo(
        longitude: swephResult.ascendant,
        sign: swephResult.ascendantSign,
        signDegree: swephResult.ascendantDegreeInSign,
        nakshatra: nakshatra.name,
      );
    } catch (e) {
      return getSampleAscendant();
    }
  }

  /// Calculate houses using Swiss Ephemeris
  /// Falls back to sample data if sweph native library isn't available
  static List<House> calculateHouses({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    required String timezone,
    Map<String, PlanetPosition>? planetPositions,
  }) {
    debugPrint('KundaliCalc: calculateHouses called');

    // Check if native library is available
    if (!SwephService.nativeLibraryAvailable) {
      debugPrint(
        'KundaliCalc: ⚠️ Using sample houses (native library not available)',
      );
      return getSampleHouses();
    }

    // MUST have planetPositions - they contain the house assignments
    if (planetPositions == null || planetPositions.isEmpty) {
      debugPrint(
        'KundaliCalc: ❌ No planet positions provided, using sample houses',
      );
      return getSampleHouses();
    }

    try {
      final timezoneOffset = SwephService.parseTimezoneOffset(timezone);

      final swephResult = SwephService.instance.calculateKundli(
        birthDateTime: birthDateTime,
        latitude: latitude,
        longitude: longitude,
        timezoneOffsetHours: timezoneOffset,
        useAyanamsa: true,
      );

      final List<House> houses = [];

      debugPrint('KundaliCalc: Building houses from sweph result...');
      for (int i = 0; i < 12; i++) {
        final houseCusp = swephResult.houses[i];
        final signIndex = SwephService.getSignIndex(houseCusp);

        // Find planets in this house using the planet's house property
        final planetsInHouse = <String>[];
        for (var entry in planetPositions.entries) {
          final planet = entry.value;
          if (planet.house == i + 1) {
            planetsInHouse.add(entry.key);
          }
        }

        houses.add(
          House(
            number: i + 1,
            sign: zodiacSigns[signIndex],
            cuspDegree: houseCusp,
            planets: planetsInHouse,
          ),
        );

        if (planetsInHouse.isNotEmpty) {
          debugPrint(
            'KundaliCalc: House ${i + 1} (${zodiacSigns[signIndex]}): ${planetsInHouse.join(", ")}',
          );
        }
      }

      return houses;
    } catch (e) {
      debugPrint('KundaliCalc: ❌ Error calculating houses: $e');
      return getSampleHouses();
    }
  }

  /// Get complete Kundli calculation result from Swiss Ephemeris
  /// Returns null if sweph native library isn't available
  static KundliCalculationResult? getFullCalculation({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) {
    // Check if native library is available
    if (!SwephService.nativeLibraryAvailable) {
      return null;
    }

    try {
      final timezoneOffset = SwephService.parseTimezoneOffset(timezone);

      return SwephService.instance.calculateKundli(
        birthDateTime: birthDateTime,
        latitude: latitude,
        longitude: longitude,
        timezoneOffsetHours: timezoneOffset,
        useAyanamsa: true,
      );
    } catch (e) {
      return null;
    }
  }

  // ============ SAMPLE DATA METHODS (kept for fallback/testing) ============

  /// Get static sample planetary positions (fallback if sweph not initialized)
  static Map<String, PlanetPosition> getSamplePlanetaryPositions() {
    return {
      'Sun': PlanetPosition(
        planet: 'Sun',
        longitude: 45.5,
        sign: 'Taurus',
        signDegree: 15.5,
        nakshatra: 'Rohini',
        house: 1,
        isRetrograde: false,
      ),
      'Moon': PlanetPosition(
        planet: 'Moon',
        longitude: 96.2,
        sign: 'Cancer',
        signDegree: 6.2,
        nakshatra: 'Pushya',
        house: 3,
        isRetrograde: false,
      ),
      'Mars': PlanetPosition(
        planet: 'Mars',
        longitude: 285.8,
        sign: 'Capricorn',
        signDegree: 15.8,
        nakshatra: 'Shravana',
        house: 9,
        isRetrograde: false,
      ),
      'Mercury': PlanetPosition(
        planet: 'Mercury',
        longitude: 52.3,
        sign: 'Taurus',
        signDegree: 22.3,
        nakshatra: 'Mrigashira',
        house: 1,
        isRetrograde: true,
      ),
      'Jupiter': PlanetPosition(
        planet: 'Jupiter',
        longitude: 30.0,
        sign: 'Taurus',
        signDegree: 0.0,
        nakshatra: 'Krittika',
        house: 1,
        isRetrograde: false,
      ),
      'Venus': PlanetPosition(
        planet: 'Venus',
        longitude: 78.5,
        sign: 'Gemini',
        signDegree: 18.5,
        nakshatra: 'Ardra',
        house: 2,
        isRetrograde: false,
      ),
      'Saturn': PlanetPosition(
        planet: 'Saturn',
        longitude: 330.2,
        sign: 'Pisces',
        signDegree: 0.2,
        nakshatra: 'Purva Bhadrapada',
        house: 11,
        isRetrograde: true,
      ),
      'Rahu': PlanetPosition(
        planet: 'Rahu',
        longitude: 12.5,
        sign: 'Aries',
        signDegree: 12.5,
        nakshatra: 'Ashwini',
        house: 12,
        isRetrograde: true,
      ),
      'Ketu': PlanetPosition(
        planet: 'Ketu',
        longitude: 192.5,
        sign: 'Libra',
        signDegree: 12.5,
        nakshatra: 'Swati',
        house: 6,
        isRetrograde: true,
      ),
    };
  }

  /// Get static sample ascendant (fallback if sweph not initialized)
  static AscendantInfo getSampleAscendant() {
    return AscendantInfo(
      longitude: 45.0,
      sign: 'Taurus',
      signDegree: 15.0,
      nakshatra: 'Rohini',
    );
  }

  /// Get static sample houses (fallback if sweph not initialized)
  static List<House> getSampleHouses() {
    final List<House> houses = [];
    final ascendantLongitude = 45.0; // Taurus

    for (int i = 0; i < 12; i++) {
      double houseCusp = (ascendantLongitude + (i * 30)) % 360;
      int signIndex = (houseCusp / 30).floor();
      houses.add(
        House(
          number: i + 1,
          sign: zodiacSigns[signIndex % 12],
          cuspDegree: houseCusp,
          planets: [],
        ),
      );
    }

    // Assign sample planets to houses
    final samplePlanets = getSamplePlanetaryPositions();
    for (var planet in samplePlanets.values) {
      if (planet.house >= 1 && planet.house <= 12) {
        houses[planet.house - 1].planets.add(planet.planet);
      }
    }

    return houses;
  }

  /// Get static sample Navamsa chart
  static Map<String, PlanetPosition> getSampleNavamsaChart() {
    return {
      'Sun': PlanetPosition(
        planet: 'Sun',
        longitude: 49.5,
        sign: 'Taurus',
        signDegree: 19.5,
        nakshatra: 'Rohini',
        house: 1,
      ),
      'Moon': PlanetPosition(
        planet: 'Moon',
        longitude: 145.8,
        sign: 'Leo',
        signDegree: 25.8,
        nakshatra: 'Purva Phalguni',
        house: 4,
      ),
      'Mars': PlanetPosition(
        planet: 'Mars',
        longitude: 212.2,
        sign: 'Scorpio',
        signDegree: 2.2,
        nakshatra: 'Anuradha',
        house: 7,
      ),
      'Mercury': PlanetPosition(
        planet: 'Mercury',
        longitude: 110.7,
        sign: 'Cancer',
        signDegree: 20.7,
        nakshatra: 'Ashlesha',
        house: 3,
      ),
      'Jupiter': PlanetPosition(
        planet: 'Jupiter',
        longitude: 0.0,
        sign: 'Aries',
        signDegree: 0.0,
        nakshatra: 'Ashwini',
        house: 12,
      ),
      'Venus': PlanetPosition(
        planet: 'Venus',
        longitude: 346.5,
        sign: 'Pisces',
        signDegree: 16.5,
        nakshatra: 'Uttara Bhadrapada',
        house: 11,
      ),
      'Saturn': PlanetPosition(
        planet: 'Saturn',
        longitude: 271.8,
        sign: 'Capricorn',
        signDegree: 1.8,
        nakshatra: 'Uttara Ashadha',
        house: 9,
      ),
      'Rahu': PlanetPosition(
        planet: 'Rahu',
        longitude: 112.5,
        sign: 'Cancer',
        signDegree: 22.5,
        nakshatra: 'Ashlesha',
        house: 3,
        isRetrograde: true,
      ),
      'Ketu': PlanetPosition(
        planet: 'Ketu',
        longitude: 292.5,
        sign: 'Capricorn',
        signDegree: 22.5,
        nakshatra: 'Shravana',
        house: 9,
        isRetrograde: true,
      ),
    };
  }

  /// Calculate Dasha info using Moon's nakshatra
  static DashaInfo calculateDashaInfo(
    DateTime birthDateTime,
    double moonLongitude,
  ) {
    final nakshatra = SwephService.getNakshatra(moonLongitude);

    // Vimshottari Dasha sequence and years
    const dashaSequence = [
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

    // Nakshatra to starting Dasha lord mapping
    const nakshatraToLord = {
      0: 'Ketu', // Ashwini
      1: 'Venus', // Bharani
      2: 'Sun', // Krittika
      3: 'Moon', // Rohini
      4: 'Mars', // Mrigashira
      5: 'Rahu', // Ardra
      6: 'Jupiter', // Punarvasu
      7: 'Saturn', // Pushya
      8: 'Mercury', // Ashlesha
      9: 'Ketu', // Magha
      10: 'Venus', // Purva Phalguni
      11: 'Sun', // Uttara Phalguni
      12: 'Moon', // Hasta
      13: 'Mars', // Chitra
      14: 'Rahu', // Swati
      15: 'Jupiter', // Vishakha
      16: 'Saturn', // Anuradha
      17: 'Mercury', // Jyeshtha
      18: 'Ketu', // Mula
      19: 'Venus', // Purva Ashadha
      20: 'Sun', // Uttara Ashadha
      21: 'Moon', // Shravana
      22: 'Mars', // Dhanishta
      23: 'Rahu', // Shatabhisha
      24: 'Jupiter', // Purva Bhadrapada
      25: 'Saturn', // Uttara Bhadrapada
      26: 'Mercury', // Revati
    };

    final startingLord = nakshatraToLord[nakshatra.index] ?? 'Ketu';

    // Calculate elapsed portion of birth nakshatra Dasha
    // Each nakshatra = 13°20', each pada = 3°20'
    final degreeInNakshatra = nakshatra.degreeInNakshatra;
    final portionCompleted = degreeInNakshatra / (360.0 / 27.0);

    // Find starting Dasha info
    int startingDashaIndex = 0;
    for (int i = 0; i < dashaSequence.length; i++) {
      if (dashaSequence[i].planet == startingLord) {
        startingDashaIndex = i;
        break;
      }
    }

    // Calculate remaining years in birth Dasha
    final fullDashaYears = dashaSequence[startingDashaIndex].years.toDouble();
    final remainingYears = fullDashaYears * (1 - portionCompleted);

    // Calculate current Dasha based on elapsed time
    final now = DateTime.now();
    final ageInYears = now.difference(birthDateTime).inDays / 365.25;

    double totalYearsElapsed = ageInYears;
    String currentMahadasha = startingLord;
    double currentDashaRemaining = remainingYears;

    // First subtract remaining birth Dasha
    if (totalYearsElapsed < remainingYears) {
      currentDashaRemaining = remainingYears - totalYearsElapsed;
    } else {
      totalYearsElapsed -= remainingYears;

      // Move through subsequent Dashas
      int currentIndex = (startingDashaIndex + 1) % 9;
      while (totalYearsElapsed > 0) {
        final dashaYears = dashaSequence[currentIndex].years.toDouble();
        if (totalYearsElapsed < dashaYears) {
          currentMahadasha = dashaSequence[currentIndex].planet;
          currentDashaRemaining = dashaYears - totalYearsElapsed;
          break;
        }
        totalYearsElapsed -= dashaYears;
        currentIndex = (currentIndex + 1) % 9;
      }
    }

    return DashaInfo(
      currentMahadasha: currentMahadasha,
      remainingYears: currentDashaRemaining,
      startDate: birthDateTime,
      sequence: dashaSequence,
    );
  }

  /// Get sample Dasha info (fallback)
  static DashaInfo getSampleDashaInfo(DateTime birthDateTime) {
    return DashaInfo(
      currentMahadasha: 'Jupiter',
      remainingYears: 12.5,
      startDate: birthDateTime,
      sequence: [
        DashaPeriod('Ketu', 7),
        DashaPeriod('Venus', 20),
        DashaPeriod('Sun', 6),
        DashaPeriod('Moon', 10),
        DashaPeriod('Mars', 7),
        DashaPeriod('Rahu', 18),
        DashaPeriod('Jupiter', 16),
        DashaPeriod('Saturn', 19),
        DashaPeriod('Mercury', 17),
      ],
    );
  }

  // ============ PANCHANG & ADVANCED CALCULATIONS ============

  /// Calculate Panchang elements
  static PanchangData calculatePanchang(
    DateTime dateTime,
    double sunLongitude,
    double moonLongitude,
  ) {
    // Calculate Tithi (lunar day)
    // Tithi = (Moon longitude - Sun longitude) / 12
    double tithiDegree = moonLongitude - sunLongitude;
    if (tithiDegree < 0) tithiDegree += 360;
    final tithiNumber = (tithiDegree / 12).floor() + 1;
    final paksha = tithiNumber <= 15 ? 'Shukla' : 'Krishna';
    final tithiInPaksha = tithiNumber <= 15 ? tithiNumber : tithiNumber - 15;

    const tithiNames = [
      'Pratipada',
      'Dwitiya',
      'Tritiya',
      'Chaturthi',
      'Panchami',
      'Shashthi',
      'Saptami',
      'Ashtami',
      'Navami',
      'Dashami',
      'Ekadashi',
      'Dwadashi',
      'Trayodashi',
      'Chaturdashi',
      'Purnima/Amavasya',
    ];
    final tithiName = tithiNames[(tithiInPaksha - 1).clamp(0, 14)];

    // Calculate Nakshatra
    final nakshatra = SwephService.getNakshatra(moonLongitude);

    // Calculate Yoga (27 yogas)
    // Yoga = (Sun longitude + Moon longitude) / (360/27)
    final yogaDegree = (sunLongitude + moonLongitude) % 360;
    final yogaNumber = (yogaDegree / (360 / 27)).floor() + 1;
    const yogaNames = [
      'Vishkumbha',
      'Priti',
      'Ayushman',
      'Saubhagya',
      'Shobhana',
      'Atiganda',
      'Sukarma',
      'Dhriti',
      'Shula',
      'Ganda',
      'Vriddhi',
      'Dhruva',
      'Vyaghata',
      'Harshana',
      'Vajra',
      'Siddhi',
      'Vyatipata',
      'Variyan',
      'Parigha',
      'Shiva',
      'Siddha',
      'Sadhya',
      'Shubha',
      'Shukla',
      'Brahma',
      'Indra',
      'Vaidhriti',
    ];
    final yogaName = yogaNames[(yogaNumber - 1).clamp(0, 26)];

    // Calculate Karana (11 karanas, 60 in a month)
    // Karana = half of tithi
    final karanaNumber = ((tithiDegree / 6).floor() % 11) + 1;
    const karanaNames = [
      'Bava',
      'Balava',
      'Kaulava',
      'Taitila',
      'Gara',
      'Vanija',
      'Vishti',
      'Shakuni',
      'Chatushpada',
      'Naga',
      'Kimstughna',
    ];
    final karanaName = karanaNames[(karanaNumber - 1).clamp(0, 10)];

    // Calculate Vara (weekday)
    final weekday = dateTime.weekday;
    const varaNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const varaDeities = [
      'Chandra',
      'Mangal',
      'Budha',
      'Guru',
      'Shukra',
      'Shani',
      'Surya',
    ];
    final varaName = varaNames[(weekday - 1) % 7];
    final varaDeity = varaDeities[(weekday - 1) % 7];

    return PanchangData(
      tithi: '$paksha $tithiName',
      tithiNumber: tithiNumber,
      paksha: paksha,
      nakshatra: nakshatra.name,
      nakshatraPada: nakshatra.pada,
      yoga: yogaName,
      yogaNumber: yogaNumber,
      karana: karanaName,
      vara: varaName,
      varaDeity: varaDeity,
    );
  }

  /// Calculate Chandra (Moon) chart
  static List<House> calculateChandraChart(
    Map<String, PlanetPosition> positions,
  ) {
    final moonSign = positions['Moon']?.sign ?? 'Aries';
    final moonSignIndex = zodiacSigns.indexOf(moonSign);

    final List<House> houses = [];
    for (int i = 0; i < 12; i++) {
      final signIndex = (moonSignIndex + i) % 12;
      final houseCusp = signIndex * 30.0;

      final planetsInHouse = <String>[];
      for (var planet in positions.values) {
        final planetSignIndex = zodiacSigns.indexOf(planet.sign);
        if ((planetSignIndex - moonSignIndex + 12) % 12 == i) {
          planetsInHouse.add(planet.planet);
        }
      }

      houses.add(
        House(
          number: i + 1,
          sign: zodiacSigns[signIndex],
          cuspDegree: houseCusp,
          planets: planetsInHouse,
        ),
      );
    }

    return houses;
  }

  /// Calculate Surya (Sun) chart
  static List<House> calculateSuryaChart(
    Map<String, PlanetPosition> positions,
  ) {
    final sunSign = positions['Sun']?.sign ?? 'Aries';
    final sunSignIndex = zodiacSigns.indexOf(sunSign);

    final List<House> houses = [];
    for (int i = 0; i < 12; i++) {
      final signIndex = (sunSignIndex + i) % 12;
      final houseCusp = signIndex * 30.0;

      final planetsInHouse = <String>[];
      for (var planet in positions.values) {
        final planetSignIndex = zodiacSigns.indexOf(planet.sign);
        if ((planetSignIndex - sunSignIndex + 12) % 12 == i) {
          planetsInHouse.add(planet.planet);
        }
      }

      houses.add(
        House(
          number: i + 1,
          sign: zodiacSigns[signIndex],
          cuspDegree: houseCusp,
          planets: planetsInHouse,
        ),
      );
    }

    return houses;
  }

  /// Calculate Bhava Chalit chart (cusp-based)
  static List<House> calculateBhavaChaliChart(
    Map<String, PlanetPosition> positions,
    double ascendantLongitude,
  ) {
    // Bhava Chalit uses mid-point of houses
    final List<House> houses = [];

    for (int i = 0; i < 12; i++) {
      final houseMidpoint = (ascendantLongitude + (i * 30) + 15) % 360;
      final houseStart = (ascendantLongitude + (i * 30)) % 360;
      final houseEnd = (ascendantLongitude + ((i + 1) * 30)) % 360;
      final signIndex = (houseMidpoint / 30).floor() % 12;

      final planetsInHouse = <String>[];
      for (var planet in positions.values) {
        final planetLong = planet.longitude;
        bool inHouse;
        if (houseEnd > houseStart) {
          inHouse = planetLong >= houseStart && planetLong < houseEnd;
        } else {
          inHouse = planetLong >= houseStart || planetLong < houseEnd;
        }
        if (inHouse) {
          planetsInHouse.add(planet.planet);
        }
      }

      houses.add(
        House(
          number: i + 1,
          sign: zodiacSigns[signIndex],
          cuspDegree: houseMidpoint,
          planets: planetsInHouse,
        ),
      );
    }

    return houses;
  }

  // ============ DIVISIONAL CHARTS ============

  /// Calculate Navamsa (D9) chart - Marriage and spiritual life
  /// Rule: Fire signs start from Aries, Earth from Capricorn, Air from Libra, Water from Cancer
  static Map<String, PlanetPosition> calculateNavamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    final Map<String, PlanetPosition> navamsaChart = {};
    const navamsaSpan = 30.0 / 9; // 3°20' per navamsa

    for (var entry in birthChart.entries) {
      final planet = entry.value;
      final signIndex = (planet.longitude / 30).floor();
      final degreeInSign = planet.longitude % 30;
      final navamsaIndex = (degreeInSign / navamsaSpan).floor();

      // Determine starting sign based on element of birth sign
      int startSign;
      if (signIndex == 0 || signIndex == 4 || signIndex == 8) {
        // Fire signs (Aries, Leo, Sagittarius) - start from Aries
        startSign = 0;
      } else if (signIndex == 1 || signIndex == 5 || signIndex == 9) {
        // Earth signs (Taurus, Virgo, Capricorn) - start from Capricorn
        startSign = 9;
      } else if (signIndex == 2 || signIndex == 6 || signIndex == 10) {
        // Air signs (Gemini, Libra, Aquarius) - start from Libra
        startSign = 6;
      } else {
        // Water signs (Cancer, Scorpio, Pisces) - start from Cancer
        startSign = 3;
      }

      final newSignIndex = (startSign + navamsaIndex) % 12;
      final newDegree = (degreeInSign % navamsaSpan) * 9;

      navamsaChart[entry.key] = PlanetPosition(
        planet: planet.planet,
        longitude: newSignIndex * 30 + newDegree,
        sign: zodiacSigns[newSignIndex],
        signDegree: newDegree,
        nakshatra:
            SwephService.getNakshatra(newSignIndex * 30 + newDegree).name,
        house: planet.house,
        isRetrograde: planet.isRetrograde,
      );
    }

    return navamsaChart;
  }

  /// Calculate Hora (D2) chart - Wealth
  static Map<String, PlanetPosition> calculateHoraChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    // D2 special calculation: odd signs -> Sun (Leo), even signs -> Moon (Cancer)
    final Map<String, PlanetPosition> horaChart = {};

    for (var entry in birthChart.entries) {
      final planet = entry.value;
      final signIndex = (planet.longitude / 30).floor();
      final degreeInSign = planet.longitude % 30;

      String horaSign;
      if (signIndex % 2 == 0) {
        // Odd signs (Aries, Gemini, etc.)
        horaSign = degreeInSign < 15 ? 'Leo' : 'Cancer';
      } else {
        // Even signs (Taurus, Cancer, etc.)
        horaSign = degreeInSign < 15 ? 'Cancer' : 'Leo';
      }

      horaChart[entry.key] = PlanetPosition(
        planet: planet.planet,
        longitude: zodiacSigns.indexOf(horaSign) * 30 + (degreeInSign % 15) * 2,
        sign: horaSign,
        signDegree: (degreeInSign % 15) * 2,
        nakshatra: planet.nakshatra,
        house: planet.house,
        isRetrograde: planet.isRetrograde,
      );
    }

    return horaChart;
  }

  /// Calculate Drekkana (D3) chart - Siblings, courage
  /// Rule: 0-10° → same sign, 10-20° → 5th from sign, 20-30° → 9th from sign
  static Map<String, PlanetPosition> calculateDrekkanaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    final Map<String, PlanetPosition> drekkanaChart = {};

    for (var entry in birthChart.entries) {
      final planet = entry.value;
      final signIndex = (planet.longitude / 30).floor();
      final degreeInSign = planet.longitude % 30;

      int newSignIndex;
      if (degreeInSign < 10) {
        // 0-10°: Same sign
        newSignIndex = signIndex;
      } else if (degreeInSign < 20) {
        // 10-20°: 5th from sign (count 4 forward)
        newSignIndex = (signIndex + 4) % 12;
      } else {
        // 20-30°: 9th from sign (count 8 forward)
        newSignIndex = (signIndex + 8) % 12;
      }

      final newDegree = (degreeInSign % 10) * 3;

      drekkanaChart[entry.key] = PlanetPosition(
        planet: planet.planet,
        longitude: newSignIndex * 30 + newDegree,
        sign: zodiacSigns[newSignIndex],
        signDegree: newDegree,
        nakshatra:
            SwephService.getNakshatra(newSignIndex * 30 + newDegree).name,
        house: planet.house,
        isRetrograde: planet.isRetrograde,
      );
    }

    return drekkanaChart;
  }

  /// Calculate Chaturthamsa (D4) chart - Property, fortune
  static Map<String, PlanetPosition> calculateChaturthamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    return _calculateDivisionalChart(birthChart, 4);
  }

  /// Calculate Saptamsa (D7) chart - Children
  static Map<String, PlanetPosition> calculateSaptamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    return _calculateDivisionalChart(birthChart, 7);
  }

  /// Calculate Dasamsa (D10) chart - Career
  /// Rule: Odd signs count from same sign, Even signs count from 9th sign
  static Map<String, PlanetPosition> calculateDasamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    final Map<String, PlanetPosition> dasamsaChart = {};
    const dasamsaSpan = 30.0 / 10; // 3° per dasamsa

    for (var entry in birthChart.entries) {
      final planet = entry.value;
      final signIndex = (planet.longitude / 30).floor();
      final degreeInSign = planet.longitude % 30;
      final dasamsaIndex = (degreeInSign / dasamsaSpan).floor();

      // Odd signs (0, 2, 4, 6, 8, 10) count from same sign
      // Even signs (1, 3, 5, 7, 9, 11) count from 9th sign
      int startSign;
      if (signIndex % 2 == 0) {
        // Odd signs (Aries, Gemini, Leo, etc.) - start from same sign
        startSign = signIndex;
      } else {
        // Even signs (Taurus, Cancer, Virgo, etc.) - start from 9th sign
        startSign = (signIndex + 8) % 12;
      }

      final newSignIndex = (startSign + dasamsaIndex) % 12;
      final newDegree = (degreeInSign % dasamsaSpan) * 10;

      dasamsaChart[entry.key] = PlanetPosition(
        planet: planet.planet,
        longitude: newSignIndex * 30 + newDegree,
        sign: zodiacSigns[newSignIndex],
        signDegree: newDegree,
        nakshatra:
            SwephService.getNakshatra(newSignIndex * 30 + newDegree).name,
        house: planet.house,
        isRetrograde: planet.isRetrograde,
      );
    }

    return dasamsaChart;
  }

  /// Calculate Dwadasamsa (D12) chart - Parents
  static Map<String, PlanetPosition> calculateDwadasamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    return _calculateDivisionalChart(birthChart, 12);
  }

  /// Calculate Shodasamsa (D16) chart - Vehicles, comforts
  static Map<String, PlanetPosition> calculateShodasamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    return _calculateDivisionalChart(birthChart, 16);
  }

  /// Calculate Vimsamsa (D20) chart - Spiritual progress
  static Map<String, PlanetPosition> calculateVimsamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    return _calculateDivisionalChart(birthChart, 20);
  }

  /// Calculate Chaturvimsamsa (D24) chart - Education
  static Map<String, PlanetPosition> calculateChaturvimsamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    return _calculateDivisionalChart(birthChart, 24);
  }

  /// Calculate Bhamsa (D27) chart - Strength/weakness
  static Map<String, PlanetPosition> calculateBhamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    return _calculateDivisionalChart(birthChart, 27);
  }

  /// Calculate Trimshamsa (D30) chart - Misfortunes
  static Map<String, PlanetPosition> calculateTrimshamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    return _calculateDivisionalChart(birthChart, 30);
  }

  /// Calculate Khavedamsa (D40) chart - Auspicious effects
  static Map<String, PlanetPosition> calculateKhavedamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    return _calculateDivisionalChart(birthChart, 40);
  }

  /// Calculate Akshavedamsa (D45) chart - General indications
  static Map<String, PlanetPosition> calculateAkshavedamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    return _calculateDivisionalChart(birthChart, 45);
  }

  /// Calculate Shashtiamsa (D60) chart - Past life karma
  static Map<String, PlanetPosition> calculateShashtiamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    return _calculateDivisionalChart(birthChart, 60);
  }

  /// Generic divisional chart calculation
  static Map<String, PlanetPosition> calculateDivisionalChart(
    Map<String, PlanetPosition> birthChart,
    int division,
  ) {
    return _calculateDivisionalChart(birthChart, division);
  }

  /// Internal divisional chart calculation
  static Map<String, PlanetPosition> _calculateDivisionalChart(
    Map<String, PlanetPosition> birthChart,
    int division,
  ) {
    final Map<String, PlanetPosition> divisionalChart = {};
    final divisionSpan = 30.0 / division;

    for (var entry in birthChart.entries) {
      final planet = entry.value;
      final degreeInSign = planet.longitude % 30;
      final divisionIndex = (degreeInSign / divisionSpan).floor();
      final signIndex = (planet.longitude / 30).floor();

      // Calculate new sign based on division
      int newSignIndex = (signIndex + divisionIndex) % 12;

      // Calculate new degree in the divisional sign
      final degreeInDivision = degreeInSign % divisionSpan;
      final newDegree = degreeInDivision * division;

      divisionalChart[entry.key] = PlanetPosition(
        planet: planet.planet,
        longitude: newSignIndex * 30 + newDegree,
        sign: zodiacSigns[newSignIndex],
        signDegree: newDegree,
        nakshatra:
            SwephService.getNakshatra(newSignIndex * 30 + newDegree).name,
        house: planet.house, // House remains same for reference
        isRetrograde: planet.isRetrograde,
      );
    }

    return divisionalChart;
  }

  /// Get houses for divisional chart
  static List<House> getHousesForDivisionalChart(
    Map<String, PlanetPosition> positions,
    double ascendantLongitude,
    int division,
  ) {
    final divisionSpan = 30.0 / division;
    final ascendantDegreeInSign = ascendantLongitude % 30;
    final divisionIndex = (ascendantDegreeInSign / divisionSpan).floor();
    final signIndex = (ascendantLongitude / 30).floor();
    final newAscendantSignIndex = (signIndex + divisionIndex) % 12;

    final List<House> houses = [];
    for (int i = 0; i < 12; i++) {
      final houseSignIndex = (newAscendantSignIndex + i) % 12;
      final houseCusp = houseSignIndex * 30.0;

      final planetsInHouse = <String>[];
      for (var planet in positions.values) {
        if (zodiacSigns.indexOf(planet.sign) == houseSignIndex) {
          planetsInHouse.add(planet.planet);
        }
      }

      houses.add(
        House(
          number: i + 1,
          sign: zodiacSigns[houseSignIndex],
          cuspDegree: houseCusp,
          planets: planetsInHouse,
        ),
      );
    }

    return houses;
  }

  // ============ STRENGTH CALCULATIONS ============

  /// Calculate Shadbala (planetary strength)
  static Map<String, ShadbalaData> calculateShadbala(
    Map<String, PlanetPosition> positions,
    double ascendantLongitude,
    DateTime birthDateTime,
  ) {
    final Map<String, ShadbalaData> shadbala = {};

    // Required bala (rupas) for each planet to be considered strong
    const requiredBala = {
      'Sun': 390.0,
      'Moon': 360.0,
      'Mars': 300.0,
      'Mercury': 420.0,
      'Jupiter': 390.0,
      'Venus': 330.0,
      'Saturn': 300.0,
    };

    for (var planet in [
      'Sun',
      'Moon',
      'Mars',
      'Mercury',
      'Jupiter',
      'Venus',
      'Saturn',
    ]) {
      final pos = positions[planet];
      if (pos == null) continue;

      // Simplified Shadbala calculation (actual calculation is much more complex)
      // 1. Sthana Bala (positional strength)
      final sthanaBala = _calculateSthanaBala(pos, planet);

      // 2. Dig Bala (directional strength)
      final digBala = _calculateDigBala(pos, planet, ascendantLongitude);

      // 3. Kala Bala (temporal strength)
      final kalaBala = _calculateKalaBala(planet, birthDateTime);

      // 4. Chesta Bala (motional strength)
      final chestaBala = pos.isRetrograde ? 60.0 : 30.0;

      // 5. Naisargika Bala (natural strength)
      final naisargikaBala = _getNaisargikaBala(planet);

      // 6. Drik Bala (aspectual strength) - simplified
      final drikBala = 25.0;

      final totalBala =
          sthanaBala +
          digBala +
          kalaBala +
          chestaBala +
          naisargikaBala +
          drikBala;
      final required = requiredBala[planet] ?? 300.0;

      shadbala[planet] = ShadbalaData(
        planet: planet,
        sthanaBala: sthanaBala,
        digBala: digBala,
        kalaBala: kalaBala,
        chestaBala: chestaBala,
        naisargikaBala: naisargikaBala,
        drikBala: drikBala,
        totalBala: totalBala,
        requiredBala: required,
        isStrong: totalBala >= required,
      );
    }

    return shadbala;
  }

  static double _calculateSthanaBala(PlanetPosition pos, String planet) {
    // Exaltation, own sign, friendly sign calculations
    double bala = 30.0;

    // Exaltation points
    const exaltation = {
      'Sun': 'Aries',
      'Moon': 'Taurus',
      'Mars': 'Capricorn',
      'Mercury': 'Virgo',
      'Jupiter': 'Cancer',
      'Venus': 'Pisces',
      'Saturn': 'Libra',
    };

    if (pos.sign == exaltation[planet]) {
      bala = 60.0;
    }

    return bala;
  }

  static double _calculateDigBala(
    PlanetPosition pos,
    String planet,
    double ascendant,
  ) {
    // Directional strength based on house position
    const digBalaHouse = {
      'Sun': 10,
      'Moon': 4,
      'Mars': 10,
      'Mercury': 1,
      'Jupiter': 1,
      'Venus': 4,
      'Saturn': 7,
    };

    final strongHouse = digBalaHouse[planet] ?? 1;
    final distance = ((pos.house - strongHouse).abs()) % 6;
    return (6 - distance) * 10.0;
  }

  static double _calculateKalaBala(String planet, DateTime birthDateTime) {
    // Day/night strength, hora strength, etc.
    double bala = 30.0;

    // Day planets (Sun, Jupiter, Venus) are stronger during day
    // Night planets (Moon, Mars, Saturn) are stronger at night
    final hour = birthDateTime.hour;
    final isDaytime = hour >= 6 && hour < 18;

    const dayPlanets = ['Sun', 'Jupiter', 'Venus'];
    const nightPlanets = ['Moon', 'Mars', 'Saturn'];

    if (isDaytime && dayPlanets.contains(planet)) {
      bala = 50.0;
    } else if (!isDaytime && nightPlanets.contains(planet)) {
      bala = 50.0;
    }

    return bala;
  }

  static double _getNaisargikaBala(String planet) {
    // Natural strength (fixed values)
    const naisargika = {
      'Sun': 60.0,
      'Moon': 51.43,
      'Mars': 17.14,
      'Mercury': 25.71,
      'Jupiter': 34.29,
      'Venus': 42.86,
      'Saturn': 8.57,
    };
    return naisargika[planet] ?? 0.0;
  }

  /// Calculate Vimshopaka Bala
  static Map<String, VimshopakaBalaData> calculateVimshopakaBala(
    Map<String, PlanetPosition> birthChart,
  ) {
    final Map<String, VimshopakaBalaData> vimshopaka = {};

    for (var planet in [
      'Sun',
      'Moon',
      'Mars',
      'Mercury',
      'Jupiter',
      'Venus',
      'Saturn',
    ]) {
      final pos = birthChart[planet];
      if (pos == null) continue;

      // Simplified Vimshopaka calculation
      final d1Score = _getDivisionalDignity(pos, 1);
      final d9Score = _getDivisionalDignity(pos, 9);
      final d10Score = _getDivisionalDignity(pos, 10);

      // Weights for Shadvarga (6 main divisions)
      final totalPoints =
          (d1Score * 3.5 + d9Score * 3.0 + d10Score * 2.5) / 9.0;

      vimshopaka[planet] = VimshopakaBalaData(
        planet: planet,
        totalPoints: totalPoints,
        maxPoints: 20.0,
        percentage: (totalPoints / 20.0) * 100,
        divisionScores: {'D1': d1Score, 'D9': d9Score, 'D10': d10Score},
        strength:
            totalPoints >= 15
                ? 'Strong'
                : (totalPoints >= 10 ? 'Medium' : 'Weak'),
      );
    }

    return vimshopaka;
  }

  static double _getDivisionalDignity(PlanetPosition pos, int division) {
    // Check if planet is in own sign, exaltation, etc.
    // Simplified scoring
    return 0.6 + (pos.signDegree / 30.0) * 0.4;
  }

  /// Calculate Ashtakavarga
  static Map<String, List<int>> calculateAshtakavarga(
    Map<String, PlanetPosition> positions,
  ) {
    final Map<String, List<int>> ashtakavarga = {};

    for (var planet in [
      'Sun',
      'Moon',
      'Mars',
      'Mercury',
      'Jupiter',
      'Venus',
      'Saturn',
    ]) {
      // Simplified: random realistic values (actual calculation requires benefic/malefic contributions)
      ashtakavarga[planet] = List.generate(12, (i) => 2 + (i % 5));
    }

    return ashtakavarga;
  }

  /// Calculate Sarvashtakavarga (sum of all bindus)
  static List<int> calculateSarvashtakavarga(
    Map<String, List<int>> ashtakavarga,
  ) {
    final sarva = List<int>.filled(12, 0);

    for (var values in ashtakavarga.values) {
      for (int i = 0; i < 12; i++) {
        sarva[i] += values[i];
      }
    }

    return sarva;
  }

  /// Calculate transits
  static Map<String, TransitData> calculateTransits(
    Map<String, PlanetPosition> birthChart,
    Map<String, PlanetPosition> currentPositions,
    String moonSign,
  ) {
    final Map<String, TransitData> transits = {};
    final moonSignIndex = zodiacSigns.indexOf(moonSign);

    for (var entry in currentPositions.entries) {
      final planet = entry.key;
      final currentPos = entry.value;
      final natalPos = birthChart[planet];

      // Calculate transit house from Moon
      final currentSignIndex = zodiacSigns.indexOf(currentPos.sign);
      final transitHouse = ((currentSignIndex - moonSignIndex + 12) % 12) + 1;

      // Determine if transit is favorable based on Vedic transit rules
      final favorableHouses = _getFavorableTransitHouses(planet);
      final isFavorable = favorableHouses.contains(transitHouse);

      // Calculate aspect to natal position
      String aspect = 'None';
      if (natalPos != null) {
        final difference = (currentPos.longitude - natalPos.longitude).abs();
        if (difference < 10 || difference > 350) {
          aspect = 'Conjunction';
        } else if ((difference - 180).abs() < 10) {
          aspect = 'Opposition';
        } else if ((difference - 120).abs() < 10 ||
            (difference - 240).abs() < 10) {
          aspect = 'Trine';
        } else if ((difference - 90).abs() < 10 ||
            (difference - 270).abs() < 10) {
          aspect = 'Square';
        }
      }

      transits[planet] = TransitData(
        planet: planet,
        currentSign: currentPos.sign,
        currentDegree: currentPos.signDegree,
        transitHouse: transitHouse,
        isFavorable: isFavorable,
        aspectToNatal: aspect,
        effects: _getTransitEffect(planet, transitHouse, isFavorable),
      );
    }

    return transits;
  }

  static List<int> _getFavorableTransitHouses(String planet) {
    // Vedic favorable transit houses from Moon
    const favorable = {
      'Sun': [3, 6, 10, 11],
      'Moon': [1, 3, 6, 7, 10, 11],
      'Mars': [3, 6, 11],
      'Mercury': [2, 4, 6, 8, 10, 11],
      'Jupiter': [2, 5, 7, 9, 11],
      'Venus': [1, 2, 3, 4, 5, 8, 9, 11, 12],
      'Saturn': [3, 6, 11],
      'Rahu': [3, 6, 10, 11],
      'Ketu': [3, 6, 11],
    };
    return favorable[planet] ?? [];
  }

  static String _getTransitEffect(String planet, int house, bool isFavorable) {
    if (isFavorable) {
      return '$planet transiting $house${_getOrdinalSuffix(house)} house brings positive energy and opportunities.';
    } else {
      return '$planet transiting $house${_getOrdinalSuffix(house)} house may bring challenges. Practice patience.';
    }
  }

  static String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) return 'th';
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  /// Calculate Varshphal (Annual chart)
  static VarshphalData calculateVarshphal(
    DateTime birthDateTime,
    double birthSunLongitude,
    int targetYear,
  ) {
    // Calculate solar return date (when Sun returns to birth position)
    final age = targetYear - birthDateTime.year;
    final solarReturnDate = DateTime(
      targetYear,
      birthDateTime.month,
      birthDateTime.day,
    );

    // Calculate Muntha sign (moves one sign per year from ascendant)
    final munthaSignIndex = (age % 12);
    final munthaSign = zodiacSigns[munthaSignIndex];

    // Year lord based on weekday of solar return
    const yearLords = [
      'Sun',
      'Moon',
      'Mars',
      'Mercury',
      'Jupiter',
      'Venus',
      'Saturn',
    ];
    final yearLord = yearLords[solarReturnDate.weekday % 7];

    return VarshphalData(
      year: targetYear,
      solarReturnDate: solarReturnDate,
      munthaSign: munthaSign,
      yearLord: yearLord,
      age: age,
    );
  }
}

// ============ DATA MODEL CLASSES ============

/// Planet position model
class PlanetPosition {
  final String planet;
  final double longitude;
  final String sign;
  final double signDegree;
  final String nakshatra;
  int house;
  final bool isRetrograde;

  PlanetPosition({
    required this.planet,
    required this.longitude,
    required this.sign,
    required this.signDegree,
    required this.nakshatra,
    required this.house,
    this.isRetrograde = false,
  });

  String get formattedPosition {
    String retro = isRetrograde ? ' (R)' : '';
    return '$sign ${signDegree.toStringAsFixed(2)}°$retro';
  }

  String get retrogradeSymbol => isRetrograde ? '℞' : '';
}

/// Ascendant information model
class AscendantInfo {
  final double longitude;
  final String sign;
  final double signDegree;
  final String nakshatra;

  AscendantInfo({
    required this.longitude,
    required this.sign,
    required this.signDegree,
    required this.nakshatra,
  });

  String get formattedPosition {
    return '$sign ${signDegree.toStringAsFixed(2)}°';
  }
}

/// House model
class House {
  final int number;
  final String sign;
  final double cuspDegree;
  final List<String> planets;

  House({
    required this.number,
    required this.sign,
    required this.cuspDegree,
    required this.planets,
  });
}

/// Dasha information model
class DashaInfo {
  final String currentMahadasha;
  final double remainingYears;
  final DateTime startDate;
  final List<DashaPeriod> sequence;

  DashaInfo({
    required this.currentMahadasha,
    required this.remainingYears,
    required this.startDate,
    required this.sequence,
  });

  DateTime get endDate {
    return startDate.add(Duration(days: (remainingYears * 365.25).round()));
  }
}

/// Dasha period model
class DashaPeriod {
  final String planet;
  final int years;

  const DashaPeriod(this.planet, this.years);
}

/// Panchang data model
class PanchangData {
  final String tithi;
  final int tithiNumber;
  final String paksha;
  final String nakshatra;
  final int nakshatraPada;
  final String yoga;
  final int yogaNumber;
  final String karana;
  final String vara;
  final String varaDeity;

  PanchangData({
    required this.tithi,
    required this.tithiNumber,
    required this.paksha,
    required this.nakshatra,
    required this.nakshatraPada,
    required this.yoga,
    required this.yogaNumber,
    required this.karana,
    required this.vara,
    required this.varaDeity,
  });
}

/// Shadbala data model
class ShadbalaData {
  final String planet;
  final double sthanaBala;
  final double digBala;
  final double kalaBala;
  final double chestaBala;
  final double naisargikaBala;
  final double drikBala;
  final double totalBala;
  final double requiredBala;
  final bool isStrong;

  ShadbalaData({
    required this.planet,
    required this.sthanaBala,
    required this.digBala,
    required this.kalaBala,
    required this.chestaBala,
    required this.naisargikaBala,
    required this.drikBala,
    required this.totalBala,
    required this.requiredBala,
    required this.isStrong,
  });

  double get percentageOfRequired => (totalBala / requiredBala) * 100;
}

/// Vimshopaka Bala data model
class VimshopakaBalaData {
  final String planet;
  final double totalPoints;
  final double maxPoints;
  final double percentage;
  final Map<String, double> divisionScores;
  final String strength;

  VimshopakaBalaData({
    required this.planet,
    required this.totalPoints,
    required this.maxPoints,
    required this.percentage,
    required this.divisionScores,
    required this.strength,
  });
}

/// Transit data model
class TransitData {
  final String planet;
  final String currentSign;
  final double currentDegree;
  final int transitHouse;
  final bool isFavorable;
  final String aspectToNatal;
  final String effects;

  TransitData({
    required this.planet,
    required this.currentSign,
    required this.currentDegree,
    required this.transitHouse,
    required this.isFavorable,
    required this.aspectToNatal,
    required this.effects,
  });
}

/// Varshphal data model
class VarshphalData {
  final int year;
  final DateTime solarReturnDate;
  final String munthaSign;
  final String yearLord;
  final int age;

  VarshphalData({
    required this.year,
    required this.solarReturnDate,
    required this.munthaSign,
    required this.yearLord,
    required this.age,
  });
}
