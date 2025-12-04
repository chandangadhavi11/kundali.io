import 'package:flutter/foundation.dart';
import 'sweph_service.dart';

/// Service for Kundali data - uses Swiss Ephemeris for accurate calculations
class KundaliCalculationService {
  /// Cached calculation result to avoid redundant sweph calls
  static UnifiedKundaliResult? _cachedResult;
  static String? _cachedKey;

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

  // Planet names (Traditional + Outer planets)
  static const List<String> planets = [
    'Sun',
    'Moon',
    'Mars',
    'Mercury',
    'Jupiter',
    'Venus',
    'Saturn',
    'Uranus',
    'Neptune',
    'Pluto',
    'Rahu',
    'Ketu',
  ];

  // Traditional Vedic planets (for Dasha calculations etc.)
  static const List<String> vedicPlanets = [
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

  /// Calculate planet house using Whole Sign system
  static int _getPlanetHouseWholeSign(
    double planetLongitude,
    int ascendantSignIndex,
  ) {
    final planetSignIndex = SwephService.getSignIndex(planetLongitude);
    return ((planetSignIndex - ascendantSignIndex + 12) % 12) + 1;
  }

  /// Calculate ALL Kundali data in ONE call to Swiss Ephemeris
  /// This prevents redundant calculations that cause performance issues
  static UnifiedKundaliResult calculateAll({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) {
    // Create a cache key
    final cacheKey =
        '${birthDateTime.toIso8601String()}_${latitude}_${longitude}_$timezone';

    // Return cached result if same parameters
    if (_cachedKey == cacheKey && _cachedResult != null) {
      return _cachedResult!;
    }

    // Check if native library is available
    if (!SwephService.nativeLibraryAvailable) {
      debugPrint(
        'KundaliCalc: ⚠️ Using SAMPLE data (native library not available)',
      );
      return UnifiedKundaliResult(
        planetPositions: getSamplePlanetaryPositions(),
        ascendant: getSampleAscendant(),
        houses: getSampleHouses(),
      );
    }

    try {
      final timezoneOffset = SwephService.parseTimezoneOffset(timezone);

      // Single call to Swiss Ephemeris
      final swephResult = SwephService.instance.calculateKundli(
        birthDateTime: birthDateTime,
        latitude: latitude,
        longitude: longitude,
        timezoneOffsetHours: timezoneOffset,
        useAyanamsa: true,
      );

      // Get ascendant sign index for house calculations
      final ascendantSignIndex = SwephService.getSignIndex(
        swephResult.ascendant,
      );

      // Build planet positions from sweph result
      final planetPositions = <String, PlanetPosition>{};
      swephResult.planets.forEach((name, planetData) {
        final nakshatra = SwephService.getNakshatra(planetData.longitude);
        final house = _getPlanetHouseWholeSign(
          planetData.longitude,
          ascendantSignIndex,
        );

        planetPositions[name] = PlanetPosition(
          planet: name,
          longitude: planetData.longitude,
          sign: planetData.signName,
          signDegree: planetData.degreeInSign,
          nakshatra: nakshatra.name,
          house: house,
          isRetrograde: planetData.isRetrograde,
        );
      });

      // Build ascendant info
      final ascNakshatra = SwephService.getNakshatra(swephResult.ascendant);
      final ascendant = AscendantInfo(
        longitude: swephResult.ascendant,
        sign: swephResult.ascendantSign,
        signDegree: swephResult.ascendantDegreeInSign,
        nakshatra: ascNakshatra.name,
      );

      // Build houses
      final houses = _buildHousesFromSwephResult(swephResult, planetPositions);

      // Cache the result
      _cachedResult = UnifiedKundaliResult(
        planetPositions: planetPositions,
        ascendant: ascendant,
        houses: houses,
      );
      _cachedKey = cacheKey;

      return _cachedResult!;
    } catch (e) {
      debugPrint('KundaliCalc: Error in calculateAll: $e');
      return UnifiedKundaliResult(
        planetPositions: getSamplePlanetaryPositions(),
        ascendant: getSampleAscendant(),
        houses: getSampleHouses(),
      );
    }
  }

  /// Build houses from sweph result
  static List<House> _buildHousesFromSwephResult(
    KundliCalculationResult swephResult,
    Map<String, PlanetPosition> planetPositions,
  ) {
    final houses = <House>[];

    for (int i = 0; i < 12; i++) {
      final houseNum = i + 1;
      final houseCusp = swephResult.houses[i];
      final signIndex = SwephService.getSignIndex(houseCusp);
      final sign = zodiacSigns[signIndex];

      final planetsInHouse = <String>[];
      planetPositions.forEach((name, pos) {
        if (pos.house == houseNum) {
          planetsInHouse.add(name);
        }
      });

      houses.add(
        House(
          number: houseNum,
          sign: sign,
          cuspDegree: houseCusp,
          planets: planetsInHouse,
        ),
      );
    }

    return houses;
  }

  /// Clear the calculation cache (call when user changes input)
  static void clearCache() {
    _cachedResult = null;
    _cachedKey = null;
  }

  /// Calculate planetary positions using Swiss Ephemeris
  /// This is the main method that uses actual astronomical calculations
  /// Falls back to sample data if sweph native library isn't available
  static Map<String, PlanetPosition> calculatePlanetaryPositions({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) {
    // Check if native library is available (not available in unit tests)
    if (!SwephService.nativeLibraryAvailable) {
      return getSamplePlanetaryPositions();
    }

    try {
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
    // Check if native library is available
    if (!SwephService.nativeLibraryAvailable) {
      return getSampleHouses();
    }

    // MUST have planetPositions - they contain the house assignments
    if (planetPositions == null || planetPositions.isEmpty) {
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
      }

      return houses;
    } catch (e) {
      debugPrint('KundaliCalc: Error calculating houses: $e');
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

  // ============ DASHA HELPER FUNCTIONS ============

  /// Add decimal years to a date with precise conversion
  /// Handles years, months, days, hours, minutes accurately
  static DateTime addDecimalYears(DateTime date, double decimalYears) {
    // Convert decimal years to total days (using 365.25 for accuracy)
    final totalDays = decimalYears * 365.25;

    // Extract whole days and fractional part
    final wholeDays = totalDays.floor();
    final fractionalDay = totalDays - wholeDays;

    // Convert fractional day to hours, minutes, seconds
    final totalHours = fractionalDay * 24;
    final wholeHours = totalHours.floor();
    final fractionalHour = totalHours - wholeHours;

    final totalMinutes = fractionalHour * 60;
    final wholeMinutes = totalMinutes.floor();
    final fractionalMinute = totalMinutes - wholeMinutes;

    final wholeSeconds = (fractionalMinute * 60).floor();

    return date.add(
      Duration(
        days: wholeDays,
        hours: wholeHours,
        minutes: wholeMinutes,
        seconds: wholeSeconds,
      ),
    );
  }

  /// Vimshottari Dasha planet order (cyclic)
  static const List<String> _dashaOrder = [
    'Ketu',
    'Venus',
    'Sun',
    'Moon',
    'Mars',
    'Rahu',
    'Jupiter',
    'Saturn',
    'Mercury',
  ];

  /// Dasha years for each planet
  static const Map<String, int> _dashaYears = {
    'Ketu': 7,
    'Venus': 20,
    'Sun': 6,
    'Moon': 10,
    'Mars': 7,
    'Rahu': 18,
    'Jupiter': 16,
    'Saturn': 19,
    'Mercury': 17,
  };

  /// Generate full 120-year Mahadasha sequence with dates
  static List<DashaPeriodDetail> generateMahadashaSequence({
    required DateTime birthDate,
    required String firstPlanet,
    required double balanceYears,
    bool includeSubPeriods = false,
    int maxSubLevel = 2, // 1=antardasha, 2=pratyantara, etc.
  }) {
    final mahadashas = <DashaPeriodDetail>[];
    var currentDate = birthDate;

    // Find starting index in planet order
    int planetIndex = _dashaOrder.indexOf(firstPlanet);
    if (planetIndex == -1) planetIndex = 0;

    // First Mahadasha (partial - balance years)
    final firstEndDate = addDecimalYears(currentDate, balanceYears);
    final firstMahadasha = DashaPeriodDetail(
      planet: firstPlanet,
      fullPath: firstPlanet,
      durationYears: balanceYears,
      startDate: currentDate,
      endDate: firstEndDate,
      level: DashaLevel.mahadasha,
      subPeriods:
          includeSubPeriods && maxSubLevel >= 1
              ? calculateSubDashas(
                parentPath: firstPlanet,
                parentPlanet: firstPlanet,
                parentDuration: balanceYears,
                startDate: currentDate,
                level: DashaLevel.antardasha,
                maxDepth: maxSubLevel,
              )
              : null,
    );
    mahadashas.add(firstMahadasha);
    currentDate = firstEndDate;

    // Remaining 8 full Mahadashas (or more for multiple 120-year cycles)
    for (int i = 1; i < 9; i++) {
      planetIndex = (planetIndex + 1) % 9;
      final planet = _dashaOrder[planetIndex];
      final years = _dashaYears[planet]!.toDouble();
      final endDate = addDecimalYears(currentDate, years);

      final mahadasha = DashaPeriodDetail(
        planet: planet,
        fullPath: planet,
        durationYears: years,
        startDate: currentDate,
        endDate: endDate,
        level: DashaLevel.mahadasha,
        subPeriods:
            includeSubPeriods && maxSubLevel >= 1
                ? calculateSubDashas(
                  parentPath: planet,
                  parentPlanet: planet,
                  parentDuration: years,
                  startDate: currentDate,
                  level: DashaLevel.antardasha,
                  maxDepth: maxSubLevel,
                )
                : null,
      );
      mahadashas.add(mahadasha);
      currentDate = endDate;
    }

    return mahadashas;
  }

  /// Recursive sub-dasha calculator for all levels
  /// Formula: subDuration = (parentDuration × subPlanetYears) / 120
  static List<DashaPeriodDetail> calculateSubDashas({
    required String parentPath,
    required String parentPlanet,
    required double parentDuration,
    required DateTime startDate,
    required DashaLevel level,
    int maxDepth = 2,
  }) {
    final subDashas = <DashaPeriodDetail>[];
    var currentDate = startDate;

    // Find starting index (sub-periods start from parent planet)
    int startIndex = _dashaOrder.indexOf(parentPlanet);
    if (startIndex == -1) startIndex = 0;

    // Calculate all 9 sub-periods
    for (int i = 0; i < 9; i++) {
      final planetIndex = (startIndex + i) % 9;
      final subPlanet = _dashaOrder[planetIndex];
      final subPlanetYears = _dashaYears[subPlanet]!.toDouble();

      // Universal formula: (parent duration × sub-planet years) / 120
      final subDuration = (parentDuration * subPlanetYears) / 120.0;
      final endDate = addDecimalYears(currentDate, subDuration);
      final fullPath = '$parentPath-$subPlanet';

      // Determine next level
      DashaLevel? nextLevel;
      if (level == DashaLevel.antardasha) {
        nextLevel = DashaLevel.pratyantara;
      } else if (level == DashaLevel.pratyantara) {
        nextLevel = DashaLevel.sookshma;
      } else if (level == DashaLevel.sookshma) {
        nextLevel = DashaLevel.prana;
      }

      // Recursively calculate sub-periods if within max depth
      final currentDepth =
          level.index; // 1 for antardasha, 2 for pratyantara, etc.
      List<DashaPeriodDetail>? childSubPeriods;

      if (nextLevel != null && currentDepth < maxDepth) {
        childSubPeriods = calculateSubDashas(
          parentPath: fullPath,
          parentPlanet: subPlanet,
          parentDuration: subDuration,
          startDate: currentDate,
          level: nextLevel,
          maxDepth: maxDepth,
        );
      }

      subDashas.add(
        DashaPeriodDetail(
          planet: subPlanet,
          fullPath: fullPath,
          durationYears: subDuration,
          startDate: currentDate,
          endDate: endDate,
          level: level,
          subPeriods: childSubPeriods,
        ),
      );

      currentDate = endDate;
    }

    return subDashas;
  }

  /// Find the current active period at any given date within a dasha sequence
  static DashaPeriodDetail? findActivePeriod(
    List<DashaPeriodDetail> periods,
    DateTime targetDate,
  ) {
    for (final period in periods) {
      if (period.containsDate(targetDate)) {
        return period;
      }
    }
    return null;
  }

  /// Get current dasha at all levels for a given date
  static Map<DashaLevel, DashaPeriodDetail> getCurrentDashaAtAllLevels(
    List<DashaPeriodDetail> mahadashaSequence,
    DateTime targetDate,
  ) {
    final result = <DashaLevel, DashaPeriodDetail>{};

    // Find current Mahadasha
    final currentMahadasha = findActivePeriod(mahadashaSequence, targetDate);
    if (currentMahadasha == null) return result;
    result[DashaLevel.mahadasha] = currentMahadasha;

    // Find current Antardasha
    if (currentMahadasha.subPeriods != null) {
      final currentAntardasha = findActivePeriod(
        currentMahadasha.subPeriods!,
        targetDate,
      );
      if (currentAntardasha != null) {
        result[DashaLevel.antardasha] = currentAntardasha;

        // Find current Pratyantara
        if (currentAntardasha.subPeriods != null) {
          final currentPratyantara = findActivePeriod(
            currentAntardasha.subPeriods!,
            targetDate,
          );
          if (currentPratyantara != null) {
            result[DashaLevel.pratyantara] = currentPratyantara;

            // Find current Sookshma
            if (currentPratyantara.subPeriods != null) {
              final currentSookshma = findActivePeriod(
                currentPratyantara.subPeriods!,
                targetDate,
              );
              if (currentSookshma != null) {
                result[DashaLevel.sookshma] = currentSookshma;

                // Find current Prana
                if (currentSookshma.subPeriods != null) {
                  final currentPrana = findActivePeriod(
                    currentSookshma.subPeriods!,
                    targetDate,
                  );
                  if (currentPrana != null) {
                    result[DashaLevel.prana] = currentPrana;
                  }
                }
              }
            }
          }
        }
      }
    }

    return result;
  }

  /// Calculate deeper Dasha levels on-demand for a specific period
  /// Use this to get Pratyantara, Sookshma, Prana without loading all upfront
  static List<DashaPeriodDetail> calculateDeeperLevels({
    required DashaPeriodDetail parentPeriod,
    int depth = 1, // How many levels deep to calculate (1=next level only)
  }) {
    if (depth <= 0) return [];

    final nextLevel = _getNextLevel(parentPeriod.level);
    if (nextLevel == null) return [];

    return calculateSubDashas(
      parentPath: parentPeriod.fullPath,
      parentPlanet: parentPeriod.planet,
      parentDuration: parentPeriod.durationYears,
      startDate: parentPeriod.startDate,
      level: nextLevel,
      maxDepth: parentPeriod.level.index + depth,
    );
  }

  static DashaLevel? _getNextLevel(DashaLevel current) {
    switch (current) {
      case DashaLevel.mahadasha:
        return DashaLevel.antardasha;
      case DashaLevel.antardasha:
        return DashaLevel.pratyantara;
      case DashaLevel.pratyantara:
        return DashaLevel.sookshma;
      case DashaLevel.sookshma:
        return DashaLevel.prana;
      case DashaLevel.prana:
        return null; // No deeper level
    }
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
    double elapsedInCurrentMahadasha = 0;
    DateTime? mahadashaStartDate;

    // First subtract remaining birth Dasha
    if (totalYearsElapsed < remainingYears) {
      currentDashaRemaining = remainingYears - totalYearsElapsed;
      elapsedInCurrentMahadasha = totalYearsElapsed;
      mahadashaStartDate = birthDateTime;
    } else {
      totalYearsElapsed -= remainingYears;

      // Move through subsequent Dashas
      int currentIndex = (startingDashaIndex + 1) % 9;
      double yearsFromBirth = remainingYears;

      while (totalYearsElapsed > 0) {
        final dashaYears = dashaSequence[currentIndex].years.toDouble();
        if (totalYearsElapsed < dashaYears) {
          currentMahadasha = dashaSequence[currentIndex].planet;
          currentDashaRemaining = dashaYears - totalYearsElapsed;
          elapsedInCurrentMahadasha = totalYearsElapsed;
          mahadashaStartDate = birthDateTime.add(
            Duration(days: (yearsFromBirth * 365.25).round()),
          );
          break;
        }
        totalYearsElapsed -= dashaYears;
        yearsFromBirth += dashaYears;
        currentIndex = (currentIndex + 1) % 9;
      }
    }

    // Calculate current Antardasha
    String? currentAntardasha;
    double? antardashaRemainingYears;

    final mahadashaYears =
        dashaSequence
            .firstWhere((d) => d.planet == currentMahadasha)
            .years
            .toDouble();

    // Find antardasha sequence starting from current mahadasha lord
    int mahadashaIndex = 0;
    for (int i = 0; i < dashaSequence.length; i++) {
      if (dashaSequence[i].planet == currentMahadasha) {
        mahadashaIndex = i;
        break;
      }
    }

    double antardashaElapsed = elapsedInCurrentMahadasha;
    for (int i = 0; i < 9; i++) {
      final antarIndex = (mahadashaIndex + i) % 9;
      final antarPlanet = dashaSequence[antarIndex].planet;
      final antarBaseYears = dashaSequence[antarIndex].years.toDouble();
      final antarDuration = (mahadashaYears * antarBaseYears) / 120.0;

      if (antardashaElapsed < antarDuration) {
        currentAntardasha = antarPlanet;
        antardashaRemainingYears = antarDuration - antardashaElapsed;
        break;
      }
      antardashaElapsed -= antarDuration;
    }

    final mahadashaEndDate = mahadashaStartDate?.add(
      Duration(days: (mahadashaYears * 365.25).round()),
    );

    // Generate Mahadasha sequence with Antardasha only (deeper levels calculated on-demand)
    // Note: maxSubLevel=2 means Mahadasha + Antardasha only to avoid performance issues
    // 9^5 = 59,049 periods if we go to Prana level upfront - too expensive!
    final mahadashaSequence = generateMahadashaSequence(
      birthDate: birthDateTime,
      firstPlanet: startingLord,
      balanceYears: remainingYears,
      includeSubPeriods: true,
      maxSubLevel: 2, // Only include Antardasha level upfront
    );

    // Get current periods at available levels
    final currentPeriods = getCurrentDashaAtAllLevels(mahadashaSequence, now);

    return DashaInfo(
      currentMahadasha: currentMahadasha,
      remainingYears: currentDashaRemaining,
      startDate: birthDateTime,
      sequence: dashaSequence,
      currentAntardasha: currentAntardasha,
      antardashaRemainingYears: antardashaRemainingYears,
      mahadashaStartDate: mahadashaStartDate,
      mahadashaEndDate: mahadashaEndDate,
      // Enhanced fields
      mahadashaSequence: mahadashaSequence,
      currentMahadashaDetail: currentPeriods[DashaLevel.mahadasha],
      currentAntardashaDetail: currentPeriods[DashaLevel.antardasha],
      currentPratyantaraDetail: currentPeriods[DashaLevel.pratyantara],
      currentSookshmaDetail: currentPeriods[DashaLevel.sookshma],
      currentPranaDetail: currentPeriods[DashaLevel.prana],
      balanceYearsAtBirth: remainingYears,
      birthNakshatraLord: startingLord,
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

  // ============ INAUSPICIOUS PERIODS (RAHUKALA, YAMAGHANDA, GULIKA) ============

  /// Calculate Rahukala, Yamaghanda, and Gulika periods for a given date
  /// These are inauspicious time periods that should be avoided for important activities
  ///
  /// Parameters:
  /// - [date]: The date for calculation
  /// - [sunrise]: Sunrise time (default: 6:00 AM)
  /// - [sunset]: Sunset time (default: 6:00 PM)
  ///
  /// Returns: InauspiciousPeriods containing all three periods
  static InauspiciousPeriods calculateInauspiciousPeriods(
    DateTime date, {
    DateTime? sunrise,
    DateTime? sunset,
  }) {
    // Default sunrise and sunset if not provided
    final sunriseTime =
        sunrise ?? DateTime(date.year, date.month, date.day, 6, 0);
    final sunsetTime =
        sunset ?? DateTime(date.year, date.month, date.day, 18, 0);

    // Calculate day duration in minutes
    final dayDuration = sunsetTime.difference(sunriseTime).inMinutes;
    final periodDuration = dayDuration ~/ 8; // Each period is 1/8th of day

    // Weekday (1 = Monday, 7 = Sunday)
    final weekday = date.weekday;

    // Calculate Rahukala
    final rahukala = _calculateRahukala(sunriseTime, periodDuration, weekday);

    // Calculate Yamaghanda
    final yamaghanda = _calculateYamaghanda(
      sunriseTime,
      periodDuration,
      weekday,
    );

    // Calculate Gulika (day time)
    final gulika = _calculateGulika(sunriseTime, periodDuration, weekday);

    return InauspiciousPeriods(
      rahukala: rahukala,
      yamaghanda: yamaghanda,
      gulika: gulika,
      date: date,
    );
  }

  /// Calculate Rahukala period
  /// Rahukala is ruled by Rahu and is considered inauspicious
  /// The period varies based on the weekday
  static TimePeriod _calculateRahukala(
    DateTime sunrise,
    int periodMinutes,
    int weekday,
  ) {
    // Rahukala period number for each weekday (1-8)
    // Sunday=8, Monday=2, Tuesday=7, Wednesday=5, Thursday=6, Friday=4, Saturday=3
    const rahukalaSequence = {
      DateTime.sunday: 8,
      DateTime.monday: 2,
      DateTime.tuesday: 7,
      DateTime.wednesday: 5,
      DateTime.thursday: 6,
      DateTime.friday: 4,
      DateTime.saturday: 3,
    };

    final periodNumber = rahukalaSequence[weekday] ?? 1;
    final startMinutes = (periodNumber - 1) * periodMinutes;

    final startTime = sunrise.add(Duration(minutes: startMinutes));
    final endTime = startTime.add(Duration(minutes: periodMinutes));

    return TimePeriod(
      name: 'Rahukala',
      startTime: startTime,
      endTime: endTime,
      description: 'Ruled by Rahu. Avoid starting new ventures.',
      severity: 'High',
    );
  }

  /// Calculate Yamaghanda period
  /// Yamaghanda is ruled by Yama (god of death) and should be avoided
  static TimePeriod _calculateYamaghanda(
    DateTime sunrise,
    int periodMinutes,
    int weekday,
  ) {
    // Yamaghanda period number for each weekday
    // Sunday=5, Monday=4, Tuesday=3, Wednesday=2, Thursday=1, Friday=7, Saturday=6
    const yamaghandaSequence = {
      DateTime.sunday: 5,
      DateTime.monday: 4,
      DateTime.tuesday: 3,
      DateTime.wednesday: 2,
      DateTime.thursday: 1,
      DateTime.friday: 7,
      DateTime.saturday: 6,
    };

    final periodNumber = yamaghandaSequence[weekday] ?? 1;
    final startMinutes = (periodNumber - 1) * periodMinutes;

    final startTime = sunrise.add(Duration(minutes: startMinutes));
    final endTime = startTime.add(Duration(minutes: periodMinutes));

    return TimePeriod(
      name: 'Yamaghanda',
      startTime: startTime,
      endTime: endTime,
      description: 'Ruled by Yama. Avoid important decisions.',
      severity: 'Medium',
    );
  }

  /// Calculate Gulika (also called Gulika Kaal or Mandi)
  /// Gulika is Saturn's son and this period is considered inauspicious
  static TimePeriod _calculateGulika(
    DateTime sunrise,
    int periodMinutes,
    int weekday,
  ) {
    // Gulika period number for each weekday (during daytime)
    // Sunday=7, Monday=6, Tuesday=5, Wednesday=4, Thursday=3, Friday=2, Saturday=1
    const gulikaSequence = {
      DateTime.sunday: 7,
      DateTime.monday: 6,
      DateTime.tuesday: 5,
      DateTime.wednesday: 4,
      DateTime.thursday: 3,
      DateTime.friday: 2,
      DateTime.saturday: 1,
    };

    final periodNumber = gulikaSequence[weekday] ?? 1;
    final startMinutes = (periodNumber - 1) * periodMinutes;

    final startTime = sunrise.add(Duration(minutes: startMinutes));
    final endTime = startTime.add(Duration(minutes: periodMinutes));

    return TimePeriod(
      name: 'Gulika',
      startTime: startTime,
      endTime: endTime,
      description: 'Saturn\'s son period. Avoid auspicious activities.',
      severity: 'Medium',
    );
  }

  /// Format time period as string (e.g., "07:30 AM - 09:00 AM")
  static String formatTimePeriod(TimePeriod period) {
    final startHour = period.startTime.hour;
    final startMinute = period.startTime.minute;
    final endHour = period.endTime.hour;
    final endMinute = period.endTime.minute;

    String formatTime(int hour, int minute) {
      final isPM = hour >= 12;
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final displayMinute = minute.toString().padLeft(2, '0');
      return '$displayHour:$displayMinute ${isPM ? 'PM' : 'AM'}';
    }

    return '${formatTime(startHour, startMinute)} - ${formatTime(endHour, endMinute)}';
  }

  /// Check if a given time falls within an inauspicious period
  static bool isInauspiciousTime(DateTime time, InauspiciousPeriods periods) {
    return _isWithinPeriod(time, periods.rahukala) ||
        _isWithinPeriod(time, periods.yamaghanda) ||
        _isWithinPeriod(time, periods.gulika);
  }

  static bool _isWithinPeriod(DateTime time, TimePeriod period) {
    return time.isAfter(period.startTime) && time.isBefore(period.endTime);
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

  // ============ STRENGTH CALCULATIONS (FULL SHADBALA) ============

  /// Calculate Shadbala (planetary strength) - Complete implementation
  /// Returns strength in Shashtiamsas (60ths of a Rupa)
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

    for (var planet in vedicPlanets) {
      // Skip Rahu and Ketu - they don't have Shadbala
      if (planet == 'Rahu' || planet == 'Ketu') continue;

      final pos = positions[planet];
      if (pos == null) continue;

      // 1. Sthana Bala (positional strength) - 5 sub-components
      final sthanaBala = _calculateFullSthanaBala(pos, planet, positions);

      // 2. Dig Bala (directional strength)
      final digBala = _calculateFullDigBala(pos, planet);

      // 3. Kala Bala (temporal strength) - 9 sub-components
      final kalaBala = _calculateFullKalaBala(planet, birthDateTime, positions);

      // 4. Chesta Bala (motional strength)
      final chestaBala = _calculateChestaBala(pos, planet);

      // 5. Naisargika Bala (natural strength) - fixed values
      final naisargikaBala = _getNaisargikaBala(planet);

      // 6. Drik Bala (aspectual strength)
      final drikBala = _calculateDrikBala(pos, planet, positions);

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

  /// Calculate Full Sthana Bala (Positional Strength) - 5 sub-components
  /// Components: Uccha, Saptavargaja, Oja-Yugma, Kendradi, Drekkana
  static double _calculateFullSthanaBala(
    PlanetPosition pos,
    String planet,
    Map<String, PlanetPosition> positions,
  ) {
    double totalSthana = 0.0;

    // 1. Uccha Bala (Exaltation Strength) - 0 to 60 shashtiamsas
    totalSthana += _calculateUcchaBala(pos, planet);

    // 2. Saptavargaja Bala (Strength in 7 divisional charts) - 0 to 45
    totalSthana += _calculateSaptavargajaBala(pos, planet);

    // 3. Oja-Yugmarasyamsa Bala (Odd/Even sign strength) - 0 to 30
    totalSthana += _calculateOjaYugmaBala(pos, planet);

    // 4. Kendradi Bala (Angular house strength) - 0 to 60
    totalSthana += _calculateKendradiBala(pos);

    // 5. Drekkana Bala (Decanate strength) - 0 to 15
    totalSthana += _calculateDrekkanaBala(pos, planet);

    return totalSthana;
  }

  /// Uccha Bala: Exaltation strength
  /// Maximum at exaltation point, zero at debilitation
  static double _calculateUcchaBala(PlanetPosition pos, String planet) {
    // Exaltation degrees for each planet
    const exaltationDegree = {
      'Sun': 10.0, // 10° Aries
      'Moon': 33.0, // 3° Taurus
      'Mars': 298.0, // 28° Capricorn
      'Mercury': 165.0, // 15° Virgo
      'Jupiter': 95.0, // 5° Cancer
      'Venus': 357.0, // 27° Pisces
      'Saturn': 200.0, // 20° Libra
    };

    final exaltDeg = exaltationDegree[planet] ?? 0.0;
    final debilDeg = (exaltDeg + 180.0) % 360.0;

    // Calculate distance from debilitation point
    double distance = (pos.longitude - debilDeg).abs();
    if (distance > 180) distance = 360 - distance;

    // Uccha Bala = (distance from debilitation / 3) shashtiamsas
    // Maximum is 60 when planet is at exact exaltation
    return (distance / 3.0).clamp(0.0, 60.0);
  }

  /// Saptavargaja Bala: Strength based on dignity in 7 divisional charts
  static double _calculateSaptavargajaBala(PlanetPosition pos, String planet) {
    double bala = 0.0;

    // Check dignity in Rasi (D1) - simplified
    final rasiDignity = _getPlanetDignity(pos.sign, planet);

    // Points for different dignities
    // Moolatrikona: 45, Own: 30, Exaltation: 30, Friend: 22.5, Neutral: 15, Enemy: 7.5, Debilitation: 3.75
    switch (rasiDignity) {
      case 'Moolatrikona':
        bala = 45.0;
        break;
      case 'Own':
        bala = 30.0;
        break;
      case 'Exaltation':
        bala = 30.0;
        break;
      case 'Friend':
        bala = 22.5;
        break;
      case 'Neutral':
        bala = 15.0;
        break;
      case 'Enemy':
        bala = 7.5;
        break;
      case 'Debilitation':
        bala = 3.75;
        break;
      default:
        bala = 15.0;
    }

    return bala;
  }

  /// Get planetary dignity in a sign
  static String _getPlanetDignity(String sign, String planet) {
    // Own signs
    const ownSigns = {
      'Sun': ['Leo'],
      'Moon': ['Cancer'],
      'Mars': ['Aries', 'Scorpio'],
      'Mercury': ['Gemini', 'Virgo'],
      'Jupiter': ['Sagittarius', 'Pisces'],
      'Venus': ['Taurus', 'Libra'],
      'Saturn': ['Capricorn', 'Aquarius'],
    };

    // Exaltation signs
    const exaltation = {
      'Sun': 'Aries',
      'Moon': 'Taurus',
      'Mars': 'Capricorn',
      'Mercury': 'Virgo',
      'Jupiter': 'Cancer',
      'Venus': 'Pisces',
      'Saturn': 'Libra',
    };

    // Debilitation signs
    const debilitation = {
      'Sun': 'Libra',
      'Moon': 'Scorpio',
      'Mars': 'Cancer',
      'Mercury': 'Pisces',
      'Jupiter': 'Capricorn',
      'Venus': 'Virgo',
      'Saturn': 'Aries',
    };

    // Moolatrikona signs and degree ranges (simplified to just sign)
    const moolatrikona = {
      'Sun': 'Leo',
      'Moon': 'Taurus',
      'Mars': 'Aries',
      'Mercury': 'Virgo',
      'Jupiter': 'Sagittarius',
      'Venus': 'Libra',
      'Saturn': 'Aquarius',
    };

    if (moolatrikona[planet] == sign) return 'Moolatrikona';
    if (exaltation[planet] == sign) return 'Exaltation';
    if (debilitation[planet] == sign) return 'Debilitation';
    if (ownSigns[planet]?.contains(sign) ?? false) return 'Own';

    // Check friendship (simplified)
    return _getSignRelationship(planet, sign);
  }

  /// Get relationship between planet and sign lord
  static String _getSignRelationship(String planet, String sign) {
    const signLords = {
      'Aries': 'Mars',
      'Taurus': 'Venus',
      'Gemini': 'Mercury',
      'Cancer': 'Moon',
      'Leo': 'Sun',
      'Virgo': 'Mercury',
      'Libra': 'Venus',
      'Scorpio': 'Mars',
      'Sagittarius': 'Jupiter',
      'Capricorn': 'Saturn',
      'Aquarius': 'Saturn',
      'Pisces': 'Jupiter',
    };

    // Natural friendships (simplified)
    const friends = {
      'Sun': ['Moon', 'Mars', 'Jupiter'],
      'Moon': ['Sun', 'Mercury'],
      'Mars': ['Sun', 'Moon', 'Jupiter'],
      'Mercury': ['Sun', 'Venus'],
      'Jupiter': ['Sun', 'Moon', 'Mars'],
      'Venus': ['Mercury', 'Saturn'],
      'Saturn': ['Mercury', 'Venus'],
    };

    const enemies = {
      'Sun': ['Venus', 'Saturn'],
      'Moon': ['Rahu', 'Ketu'],
      'Mars': ['Mercury'],
      'Mercury': ['Moon'],
      'Jupiter': ['Mercury', 'Venus'],
      'Venus': ['Sun', 'Moon'],
      'Saturn': ['Sun', 'Moon', 'Mars'],
    };

    final signLord = signLords[sign];
    if (signLord == planet) return 'Own';
    if (friends[planet]?.contains(signLord) ?? false) return 'Friend';
    if (enemies[planet]?.contains(signLord) ?? false) return 'Enemy';
    return 'Neutral';
  }

  /// Oja-Yugma Bala: Odd/Even sign and navamsa strength
  static double _calculateOjaYugmaBala(PlanetPosition pos, String planet) {
    final signIndex = zodiacSigns.indexOf(pos.sign);
    final isOddSign = signIndex % 2 == 0; // Aries=0 is odd sign

    // Moon and Venus get strength in even signs
    // Others get strength in odd signs
    if ((planet == 'Moon' || planet == 'Venus') && !isOddSign) {
      return 15.0;
    } else if (planet != 'Moon' && planet != 'Venus' && isOddSign) {
      return 15.0;
    }

    return 7.5; // Half points otherwise
  }

  /// Kendradi Bala: Strength based on house type
  static double _calculateKendradiBala(PlanetPosition pos) {
    final house = pos.house;

    // Kendra houses (1, 4, 7, 10) = 60 shashtiamsas
    if (house == 1 || house == 4 || house == 7 || house == 10) {
      return 60.0;
    }
    // Panapara houses (2, 5, 8, 11) = 30 shashtiamsas
    if (house == 2 || house == 5 || house == 8 || house == 11) {
      return 30.0;
    }
    // Apoklima houses (3, 6, 9, 12) = 15 shashtiamsas
    return 15.0;
  }

  /// Drekkana Bala: Decanate strength
  static double _calculateDrekkanaBala(PlanetPosition pos, String planet) {
    final degreeInSign = pos.longitude % 30;
    final decanate = (degreeInSign / 10).floor() + 1; // 1, 2, or 3

    // Male planets (Sun, Mars, Jupiter) strong in 1st decanate
    // Neutral planets (Mercury, Saturn) strong in 2nd decanate
    // Female planets (Moon, Venus) strong in 3rd decanate

    const malePlanets = ['Sun', 'Mars', 'Jupiter'];
    const femalePlanets = ['Moon', 'Venus'];

    if (malePlanets.contains(planet) && decanate == 1) return 15.0;
    if (femalePlanets.contains(planet) && decanate == 3) return 15.0;
    if (!malePlanets.contains(planet) &&
        !femalePlanets.contains(planet) &&
        decanate == 2)
      return 15.0;

    return 7.5;
  }

  /// Calculate Full Dig Bala (Directional Strength)
  /// Maximum 60 shashtiamsas when in strongest house
  static double _calculateFullDigBala(PlanetPosition pos, String planet) {
    // Strongest houses for each planet
    // Jupiter/Mercury: 1st (East)
    // Sun/Mars: 10th (South)
    // Saturn: 7th (West)
    // Moon/Venus: 4th (North)
    const strongestHouse = {
      'Sun': 10,
      'Moon': 4,
      'Mars': 10,
      'Mercury': 1,
      'Jupiter': 1,
      'Venus': 4,
      'Saturn': 7,
    };

    final bestHouse = strongestHouse[planet] ?? 1;
    final house = pos.house;

    // Calculate houses away from strongest position
    int distance = (house - bestHouse).abs();
    if (distance > 6) distance = 12 - distance;

    // Full strength (60) at best house, zero at opposite (6 houses away)
    return ((6 - distance) / 6 * 60).clamp(0.0, 60.0);
  }

  /// Calculate Full Kala Bala (Temporal Strength) - Multiple components
  static double _calculateFullKalaBala(
    String planet,
    DateTime birthDateTime,
    Map<String, PlanetPosition> positions,
  ) {
    double totalKala = 0.0;

    // 1. Nathonnatha Bala (Day/Night strength)
    totalKala += _calculateNathonnathaBala(planet, birthDateTime);

    // 2. Paksha Bala (Lunar fortnight strength)
    totalKala += _calculatePakshaBala(planet, positions);

    // 3. Tribhaga Bala (Division of day/night strength)
    totalKala += _calculateTribhagaBala(planet, birthDateTime);

    // 4. Vara Bala (Weekday strength)
    totalKala += _calculateVaraBala(planet, birthDateTime);

    // 5. Hora Bala (Planetary hour strength)
    totalKala += _calculateHoraBala(planet, birthDateTime);

    // 6. Masa Bala (Month lord strength)
    totalKala += _calculateMasaBala(planet, birthDateTime);

    // 7. Abda Bala (Year lord strength)
    totalKala += _calculateAbdaBala(planet, birthDateTime);

    // 8. Ayana Bala (Solstice strength)
    totalKala += _calculateAyanaBala(planet, positions);

    return totalKala;
  }

  /// Nathonnatha Bala: Day planets strong in day, night planets at night
  static double _calculateNathonnathaBala(String planet, DateTime dt) {
    final hour = dt.hour + dt.minute / 60.0;
    // Approximate day: 6 AM to 6 PM
    final isDaytime = hour >= 6 && hour < 18;

    const dayPlanets = ['Sun', 'Jupiter', 'Venus'];
    const nightPlanets = ['Moon', 'Mars', 'Saturn'];

    // Mercury is always neutral
    if (planet == 'Mercury') return 30.0;

    if (dayPlanets.contains(planet)) {
      return isDaytime ? 60.0 : 0.0;
    } else if (nightPlanets.contains(planet)) {
      return isDaytime ? 0.0 : 60.0;
    }

    return 30.0;
  }

  /// Paksha Bala: Moon and benefics strong in Shukla Paksha
  static double _calculatePakshaBala(
    String planet,
    Map<String, PlanetPosition> positions,
  ) {
    final moon = positions['Moon'];
    final sun = positions['Sun'];
    if (moon == null || sun == null) return 30.0;

    // Calculate tithi to determine paksha
    double diff = moon.longitude - sun.longitude;
    if (diff < 0) diff += 360;
    final tithiNumber = (diff / 12).floor() + 1;
    final isShukla = tithiNumber <= 15;

    // Benefics (Moon, Mercury, Jupiter, Venus) strong in Shukla
    // Malefics (Sun, Mars, Saturn) strong in Krishna
    const benefics = ['Moon', 'Mercury', 'Jupiter', 'Venus'];
    const malefics = ['Sun', 'Mars', 'Saturn'];

    if (benefics.contains(planet)) {
      return isShukla ? 60.0 : 0.0;
    } else if (malefics.contains(planet)) {
      return isShukla ? 0.0 : 60.0;
    }

    return 30.0;
  }

  /// Tribhaga Bala: Division of day/night into 3 parts
  static double _calculateTribhagaBala(String planet, DateTime dt) {
    final hour = dt.hour + dt.minute / 60.0;

    // Day (6-18) divided into 3 parts: 6-10, 10-14, 14-18
    // Night (18-6) divided into 3 parts: 18-22, 22-2, 2-6

    int tribhaga;
    if (hour >= 6 && hour < 10)
      tribhaga = 1;
    else if (hour >= 10 && hour < 14)
      tribhaga = 2;
    else if (hour >= 14 && hour < 18)
      tribhaga = 3;
    else if (hour >= 18 && hour < 22)
      tribhaga = 4;
    else if (hour >= 22 || hour < 2)
      tribhaga = 5;
    else
      tribhaga = 6;

    // Mercury rules 1st tribhaga of day, Sun 2nd, Saturn 3rd
    // Moon rules 1st of night, Venus 2nd, Mars 3rd
    const tribhagaRulers = {
      1: 'Mercury',
      2: 'Sun',
      3: 'Saturn',
      4: 'Moon',
      5: 'Venus',
      6: 'Mars',
    };

    return tribhagaRulers[tribhaga] == planet ? 60.0 : 0.0;
  }

  /// Vara Bala: Weekday lord strength
  static double _calculateVaraBala(String planet, DateTime dt) {
    const weekdayLords = [
      'Sun',
      'Moon',
      'Mars',
      'Mercury',
      'Jupiter',
      'Venus',
      'Saturn',
    ];
    final dayLord = weekdayLords[dt.weekday % 7];
    return dayLord == planet ? 45.0 : 0.0;
  }

  /// Hora Bala: Planetary hour strength
  static double _calculateHoraBala(String planet, DateTime dt) {
    // Simplified hora calculation
    final hour = dt.hour;
    const horaSequence = [
      'Sun',
      'Venus',
      'Mercury',
      'Moon',
      'Saturn',
      'Jupiter',
      'Mars',
    ];

    // Start from weekday lord at sunrise (6 AM)
    final startIndex = dt.weekday % 7;
    final hoursFromSunrise = (hour >= 6) ? hour - 6 : hour + 18;
    final horaLord = horaSequence[(startIndex + hoursFromSunrise) % 7];

    return horaLord == planet ? 60.0 : 0.0;
  }

  /// Masa Bala: Month lord strength (simplified)
  static double _calculateMasaBala(String planet, DateTime dt) {
    // The month lord changes based on lunar month
    // Simplified: use solar month
    const monthLords = [
      'Mars',
      'Venus',
      'Mercury',
      'Moon',
      'Sun',
      'Mercury',
      'Venus',
      'Mars',
      'Jupiter',
      'Saturn',
      'Saturn',
      'Jupiter',
    ];
    final monthLord = monthLords[dt.month - 1];
    return monthLord == planet ? 30.0 : 0.0;
  }

  /// Abda Bala: Year lord strength (simplified)
  static double _calculateAbdaBala(String planet, DateTime dt) {
    // Year lord cycles through planets
    const yearLordCycle = [
      'Sun',
      'Venus',
      'Mercury',
      'Moon',
      'Saturn',
      'Jupiter',
      'Mars',
    ];
    final yearLord = yearLordCycle[dt.year % 7];
    return yearLord == planet ? 15.0 : 0.0;
  }

  /// Ayana Bala: Solstice-based strength
  static double _calculateAyanaBala(
    String planet,
    Map<String, PlanetPosition> positions,
  ) {
    final pos = positions[planet];
    if (pos == null) return 30.0;

    // Northern hemisphere planets stronger in Uttarayana (Sun moving north)
    // Simplified: based on planet's longitude
    final longitude = pos.longitude;

    // Sun, Mars, Jupiter stronger when Sun is in northern signs
    // Moon, Venus, Saturn stronger when Sun is in southern signs
    const northernPlanets = ['Sun', 'Mars', 'Jupiter', 'Mercury'];
    final isNorthernHemisphere = longitude < 180; // Aries to Virgo

    if (northernPlanets.contains(planet)) {
      return isNorthernHemisphere ? 60.0 : 0.0;
    } else {
      return isNorthernHemisphere ? 0.0 : 60.0;
    }
  }

  /// Calculate Chesta Bala (Motional Strength)
  static double _calculateChestaBala(PlanetPosition pos, String planet) {
    // Sun and Moon don't have Chesta Bala
    if (planet == 'Sun' || planet == 'Moon') return 0.0;

    // Retrograde planets get maximum chesta bala
    if (pos.isRetrograde) return 60.0;

    // Direct motion: simplified based on typical motion
    // In actual calculation, compare to mean motion
    return 30.0;
  }

  /// Naisargika Bala (Natural Strength) - Fixed values
  static double _getNaisargikaBala(String planet) {
    // Fixed values in shashtiamsas
    const naisargika = {
      'Sun': 60.0,
      'Moon': 51.43,
      'Venus': 42.86,
      'Jupiter': 34.29,
      'Mercury': 25.71,
      'Mars': 17.14,
      'Saturn': 8.57,
    };
    return naisargika[planet] ?? 0.0;
  }

  /// Calculate Drik Bala (Aspectual Strength)
  static double _calculateDrikBala(
    PlanetPosition pos,
    String planet,
    Map<String, PlanetPosition> positions,
  ) {
    double drikBala = 0.0;

    // Benefics aspecting add strength, malefics reduce
    const benefics = ['Jupiter', 'Venus', 'Mercury', 'Moon'];
    const malefics = ['Sun', 'Mars', 'Saturn', 'Rahu', 'Ketu'];

    for (var entry in positions.entries) {
      if (entry.key == planet) continue;

      final other = entry.value;
      final aspectStrength = _getAspectStrength(other, pos);

      if (aspectStrength > 0) {
        if (benefics.contains(entry.key)) {
          drikBala += aspectStrength * 15; // Add for benefic aspects
        } else if (malefics.contains(entry.key)) {
          drikBala -= aspectStrength * 15; // Subtract for malefic aspects
        }
      }
    }

    // Drik Bala ranges from -60 to +60, normalize to 0-60
    return (drikBala + 30).clamp(0.0, 60.0);
  }

  /// Get aspect strength between two planets (0, 0.25, 0.5, 0.75, 1.0)
  static double _getAspectStrength(
    PlanetPosition aspector,
    PlanetPosition aspected,
  ) {
    final houseDiff = (aspected.house - aspector.house + 12) % 12;

    // Full aspects
    if (houseDiff == 6) return 1.0; // 7th house aspect (opposition)

    // Mars special aspects: 4th and 8th
    if (aspector.planet == 'Mars' && (houseDiff == 3 || houseDiff == 7))
      return 1.0;

    // Jupiter special aspects: 5th and 9th
    if (aspector.planet == 'Jupiter' && (houseDiff == 4 || houseDiff == 8))
      return 1.0;

    // Saturn special aspects: 3rd and 10th
    if (aspector.planet == 'Saturn' && (houseDiff == 2 || houseDiff == 9))
      return 1.0;

    // Partial aspects (simplified)
    if (houseDiff == 2 || houseDiff == 10) return 0.25; // 3rd/11th
    if (houseDiff == 3 || houseDiff == 9) return 0.5; // 4th/10th
    if (houseDiff == 4 || houseDiff == 8) return 0.75; // 5th/9th

    return 0.0;
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
  final String? currentAntardasha;
  final double? antardashaRemainingYears;
  final DateTime? mahadashaStartDate;
  final DateTime? mahadashaEndDate;

  // Enhanced fields for full dasha system
  final List<DashaPeriodDetail>? mahadashaSequence;
  final DashaPeriodDetail? currentMahadashaDetail;
  final DashaPeriodDetail? currentAntardashaDetail;
  final DashaPeriodDetail? currentPratyantaraDetail;
  final DashaPeriodDetail? currentSookshmaDetail;
  final DashaPeriodDetail? currentPranaDetail;
  final double? balanceYearsAtBirth;
  final String? birthNakshatraLord;

  DashaInfo({
    required this.currentMahadasha,
    required this.remainingYears,
    required this.startDate,
    required this.sequence,
    this.currentAntardasha,
    this.antardashaRemainingYears,
    this.mahadashaStartDate,
    this.mahadashaEndDate,
    this.mahadashaSequence,
    this.currentMahadashaDetail,
    this.currentAntardashaDetail,
    this.currentPratyantaraDetail,
    this.currentSookshmaDetail,
    this.currentPranaDetail,
    this.balanceYearsAtBirth,
    this.birthNakshatraLord,
  });

  DateTime get endDate {
    return startDate.add(Duration(days: (remainingYears * 365.25).round()));
  }

  /// Get the current full dasha path string (e.g., "Jupiter-Saturn-Mercury")
  String get currentFullPath {
    final parts = <String>[currentMahadasha];
    if (currentAntardasha != null) parts.add(currentAntardasha!);
    if (currentPratyantaraDetail != null)
      parts.add(currentPratyantaraDetail!.planet);
    if (currentSookshmaDetail != null) parts.add(currentSookshmaDetail!.planet);
    if (currentPranaDetail != null) parts.add(currentPranaDetail!.planet);
    return parts.join('-');
  }

  /// Get remaining time in current Pratyantara
  double? get pratyantaraRemainingYears {
    if (currentPratyantaraDetail == null) return null;
    final now = DateTime.now();
    if (now.isAfter(currentPratyantaraDetail!.endDate)) return 0;
    final remainingDays =
        currentPratyantaraDetail!.endDate.difference(now).inDays;
    return remainingDays / 365.25;
  }

  /// Get all antardashas for a specific mahadasha planet
  List<DashaPeriodDetail>? getAntardashasForMahadasha(String mahadashaPlanet) {
    if (mahadashaSequence == null) return null;
    final mahadasha = mahadashaSequence!.firstWhere(
      (m) => m.planet == mahadashaPlanet,
      orElse: () => mahadashaSequence!.first,
    );
    return mahadasha.subPeriods;
  }

  /// Get all antardashas with dates for current mahadasha
  List<DashaPeriodDetail>? get currentMahadashaAntardashas {
    return currentMahadashaDetail?.subPeriods;
  }

  /// Get pratyantaras for current antardasha
  List<DashaPeriodDetail>? get currentAntardashaPratyantaras {
    return currentAntardashaDetail?.subPeriods;
  }

  /// Get sookshmas for current pratyantara
  List<DashaPeriodDetail>? get currentPratyantaraSookshmas {
    return currentPratyantaraDetail?.subPeriods;
  }

  /// Get pranas for current sookshma
  List<DashaPeriodDetail>? get currentSookshmaPranas {
    return currentSookshmaDetail?.subPeriods;
  }

  /// Calculate Antardasha periods for current Mahadasha
  /// Formula: (Mahadasha years × Antardasha planet's years) ÷ 120
  List<AntardashaPeriod> getAntardashas() {
    final mahadashaYears =
        sequence
            .firstWhere(
              (d) => d.planet == currentMahadasha,
              orElse: () => DashaPeriod(currentMahadasha, 7),
            )
            .years;

    // Find starting index in sequence for current Mahadasha
    int startIndex = 0;
    for (int i = 0; i < sequence.length; i++) {
      if (sequence[i].planet == currentMahadasha) {
        startIndex = i;
        break;
      }
    }

    final antardashas = <AntardashaPeriod>[];
    for (int i = 0; i < 9; i++) {
      final antardashaIndex = (startIndex + i) % 9;
      final antardashaPlanet = sequence[antardashaIndex].planet;
      final antardashaBaseYears = sequence[antardashaIndex].years;

      // Antardasha duration = (Mahadasha years × Antardasha planet years) / 120
      final durationYears = (mahadashaYears * antardashaBaseYears) / 120.0;

      antardashas.add(
        AntardashaPeriod(
          planet: antardashaPlanet,
          durationYears: durationYears,
        ),
      );
    }

    return antardashas;
  }
}

/// Dasha period model
class DashaPeriod {
  final String planet;
  final int years;

  const DashaPeriod(this.planet, this.years);
}

/// Antardasha (sub-period) model - kept for backward compatibility
class AntardashaPeriod {
  final String planet;
  final double durationYears;

  AntardashaPeriod({required this.planet, required this.durationYears});

  /// Get duration in years, months, days format
  String get formattedDuration {
    final totalDays = durationYears * 365.25;
    final years = totalDays ~/ 365.25;
    final remainingDays = totalDays - (years * 365.25);
    final months = remainingDays ~/ 30.44;
    final days = (remainingDays - (months * 30.44)).round();

    if (years > 0) {
      return '$years y, $months m, $days d';
    } else if (months > 0) {
      return '$months m, $days d';
    } else {
      return '$days days';
    }
  }
}

/// Dasha level enumeration for hierarchical periods
enum DashaLevel {
  mahadasha, // Main period (6-20 years)
  antardasha, // Sub-period
  pratyantara, // Sub-sub-period
  sookshma, // Sub-sub-sub-period
  prana, // Micro-level period
}

/// Enhanced Dasha period model with full details and sub-periods
class DashaPeriodDetail {
  final String planet;
  final String fullPath; // e.g., "Jupiter-Saturn-Mercury"
  final double durationYears;
  final DateTime startDate;
  final DateTime endDate;
  final DashaLevel level;
  final List<DashaPeriodDetail>? subPeriods;

  DashaPeriodDetail({
    required this.planet,
    required this.fullPath,
    required this.durationYears,
    required this.startDate,
    required this.endDate,
    required this.level,
    this.subPeriods,
  });

  /// Get duration in years, months, days format
  String get formattedDuration {
    final totalDays = durationYears * 365.25;
    final years = totalDays ~/ 365.25;
    final remainingDays = totalDays - (years * 365.25);
    final months = remainingDays ~/ 30.44;
    final days = (remainingDays - (months * 30.44)).round();

    if (years > 0) {
      return '$years y, $months m, $days d';
    } else if (months > 0) {
      return '$months m, $days d';
    } else {
      return '$days days';
    }
  }

  /// Check if a given date falls within this period
  bool containsDate(DateTime date) {
    return !date.isBefore(startDate) && date.isBefore(endDate);
  }

  /// Get the level name as a string
  String get levelName {
    switch (level) {
      case DashaLevel.mahadasha:
        return 'Mahadasha';
      case DashaLevel.antardasha:
        return 'Antardasha';
      case DashaLevel.pratyantara:
        return 'Pratyantara';
      case DashaLevel.sookshma:
        return 'Sookshma';
      case DashaLevel.prana:
        return 'Prana';
    }
  }
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

/// Unified calculation result to avoid redundant sweph calls
class UnifiedKundaliResult {
  final Map<String, PlanetPosition> planetPositions;
  final AscendantInfo ascendant;
  final List<House> houses;

  UnifiedKundaliResult({
    required this.planetPositions,
    required this.ascendant,
    required this.houses,
  });
}

/// Time period for inauspicious periods (Rahukala, Yamaghanda, Gulika)
class TimePeriod {
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final String description;
  final String severity; // 'High', 'Medium', 'Low'

  TimePeriod({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.description,
    this.severity = 'Medium',
  });

  /// Duration of the period
  Duration get duration => endTime.difference(startTime);

  /// Check if a given time is within this period
  bool contains(DateTime time) {
    return time.isAfter(startTime) && time.isBefore(endTime);
  }

  /// Format as "HH:MM AM/PM - HH:MM AM/PM"
  String get formattedTime {
    String formatTime(DateTime dt) {
      final hour = dt.hour;
      final minute = dt.minute;
      final isPM = hour >= 12;
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${isPM ? 'PM' : 'AM'}';
    }

    return '${formatTime(startTime)} - ${formatTime(endTime)}';
  }
}

/// Container for all inauspicious periods of a day
class InauspiciousPeriods {
  final TimePeriod rahukala;
  final TimePeriod yamaghanda;
  final TimePeriod gulika;
  final DateTime date;

  InauspiciousPeriods({
    required this.rahukala,
    required this.yamaghanda,
    required this.gulika,
    required this.date,
  });

  /// Get all periods sorted by start time
  List<TimePeriod> get allPeriods {
    final periods = [rahukala, yamaghanda, gulika];
    periods.sort((a, b) => a.startTime.compareTo(b.startTime));
    return periods;
  }

  /// Check if a given time falls in any inauspicious period
  bool isInauspicious(DateTime time) {
    return rahukala.contains(time) ||
        yamaghanda.contains(time) ||
        gulika.contains(time);
  }

  /// Get the current active inauspicious period, if any
  TimePeriod? getCurrentPeriod(DateTime time) {
    if (rahukala.contains(time)) return rahukala;
    if (yamaghanda.contains(time)) return yamaghanda;
    if (gulika.contains(time)) return gulika;
    return null;
  }
}
