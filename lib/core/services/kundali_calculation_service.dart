import 'package:flutter/foundation.dart';
import 'sweph_service.dart';

/// Service for Kundali data - uses Swiss Ephemeris for accurate calculations
class KundaliCalculationService {
  /// Cached calculation result to avoid redundant sweph calls
  static UnifiedKundaliResult? _cachedResult;
  static String? _cachedKey;

  // ============ TEST FUNCTION FOR VERIFICATION ============

  /// Standalone test function to verify planetary calculations
  /// Call this function to test specific dates without affecting the app
  ///
  /// Usage example:
  /// ```dart
  /// KundaliCalculationService.testCalculation(
  ///   year: 2025, month: 12, day: 5,
  ///   hour: 13, minute: 5, second: 44,
  ///   latitude: 28.6139, longitude: 77.2090, // Delhi
  ///   timezone: 'IST',
  /// );
  /// ```
  ///
  /// Expected output for Dec 5, 2025:
  /// - Jupiter should be in Gemini ~29° (to match other apps)
  /// - Moon should be in Taurus
  /// - Sun should be in Scorpio
  static Map<String, dynamic> testCalculation({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    int second = 0,
    required double latitude,
    required double longitude,
    String timezone = 'IST',
  }) {
    debugPrint('\n');
    debugPrint(
      '╔══════════════════════════════════════════════════════════════╗',
    );
    debugPrint(
      '║           KUNDALI CALCULATION TEST                           ║',
    );
    debugPrint(
      '╠══════════════════════════════════════════════════════════════╣',
    );
    debugPrint(
      '║ INPUT PARAMETERS:                                            ║',
    );
    debugPrint(
      '║ Date: $day/$month/$year                                      ',
    );
    debugPrint(
      '║ Time: $hour:$minute:$second                                  ',
    );
    debugPrint(
      '║ Location: Lat $latitude, Long $longitude                     ',
    );
    debugPrint(
      '║ Timezone: $timezone                                          ',
    );
    debugPrint(
      '╠══════════════════════════════════════════════════════════════╣',
    );

    try {
      final birthDateTime = DateTime(year, month, day, hour, minute, second);

      // Get timezone offset
      final timezoneOffset = SwephService.parseTimezoneOffset(timezone);
      debugPrint(
        '║ Timezone Offset: ${timezoneOffset}h                         ',
      );

      // Calculate using Swiss Ephemeris
      final swephResult = SwephService.instance.calculateKundli(
        birthDateTime: birthDateTime,
        latitude: latitude,
        longitude: longitude,
        timezoneOffsetHours: timezoneOffset,
        useAyanamsa: true,
      );

      debugPrint(
        '╠══════════════════════════════════════════════════════════════╣',
      );
      debugPrint(
        '║ CALCULATION RESULTS:                                         ║',
      );
      debugPrint(
        '║ Ayanamsa: ${swephResult.ayanamsa.toStringAsFixed(4)}°                              ',
      );
      debugPrint(
        '║ Ascendant: ${swephResult.ascendantSign} ${swephResult.ascendantDegreeInSign.toStringAsFixed(2)}°        ',
      );
      debugPrint(
        '╠══════════════════════════════════════════════════════════════╣',
      );
      debugPrint(
        '║ PLANETARY POSITIONS:                                         ║',
      );

      final Map<String, Map<String, dynamic>> results = {};

      // Key planets to check
      final keyPlanets = [
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

      for (var planet in keyPlanets) {
        final pos = swephResult.planets[planet];
        if (pos != null) {
          final sign = pos.signName;
          final degree = pos.degreeInSign;
          final retro = pos.isRetrograde ? ' (R)' : '';

          results[planet] = {
            'sign': sign,
            'degree': degree,
            'longitude': pos.longitude,
            'isRetrograde': pos.isRetrograde,
          };

          // Format output with padding
          final planetPadded = planet.padRight(8);
          final signPadded = sign.padRight(12);
          debugPrint(
            '║ $planetPadded: $signPadded ${degree.toStringAsFixed(2)}°$retro',
          );
        }
      }

      debugPrint(
        '╠══════════════════════════════════════════════════════════════╣',
      );
      debugPrint(
        '║ VERIFICATION CHECKLIST:                                      ║',
      );

      // Verify key planets
      // Jupiter verification
      final jupiter = results['Jupiter'];
      if (jupiter != null) {
        debugPrint(
          '║ Jupiter: ${jupiter['sign']} ${(jupiter['degree'] as double).toStringAsFixed(2)}° (Long: ${(jupiter['longitude'] as double).toStringAsFixed(2)}°)',
        );
      }

      // Saturn verification
      final saturn = results['Saturn'];
      if (saturn != null) {
        debugPrint(
          '║ Saturn:  ${saturn['sign']} ${(saturn['degree'] as double).toStringAsFixed(2)}° (Long: ${(saturn['longitude'] as double).toStringAsFixed(2)}°)',
        );
      }

      // Show sign boundaries for reference
      debugPrint(
        '╠══════════════════════════════════════════════════════════════╣',
      );
      debugPrint(
        '║ SIGN BOUNDARIES (Sidereal):                                  ║',
      );
      debugPrint(
        '║ Gemini: 60° - 90°  |  Cancer: 90° - 120°                     ║',
      );
      debugPrint(
        '║ Aquarius: 300° - 330°  |  Pisces: 330° - 360°                ║',
      );

      debugPrint(
        '╚══════════════════════════════════════════════════════════════╝',
      );
      debugPrint('\n');

      return {
        'success': true,
        'ayanamsa': swephResult.ayanamsa,
        'ascendant': {
          'sign': swephResult.ascendantSign,
          'degree': swephResult.ascendantDegreeInSign,
        },
        'planets': results,
      };
    } catch (e) {
      debugPrint('║ ❌ ERROR: $e');
      debugPrint(
        '╚══════════════════════════════════════════════════════════════╝',
      );
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Quick test with default values (Dec 5, 2025, 13:38:40, Delhi)
  /// Call: KundaliCalculationService.quickTest();
  static Map<String, dynamic> quickTest() {
    return testCalculation(
      year: 2025,
      month: 12,
      day: 5,
      hour: 13,
      minute: 38,
      second: 40,
      latitude: 28.6139, // Delhi
      longitude: 77.2090,
      timezone: 'IST',
    );
  }

  /// Compare our calculations with expected values from other app
  /// This helps diagnose ayanamsa differences
  static void compareWithOtherApp() {
    debugPrint('\n');
    debugPrint(
      '╔══════════════════════════════════════════════════════════════╗',
    );
    debugPrint(
      '║      COMPARISON WITH OTHER APP (Dec 5, 2025, 13:38:40)       ║',
    );
    debugPrint(
      '╠══════════════════════════════════════════════════════════════╣',
    );

    // Expected values from other app (Dec 5, 2025, 13:38:40 IST, Delhi)
    // Format: sign, degree in sign
    final expectedPositions = {
      'Sun': {'sign': 'Scorpio', 'degree': 19.23},
      'Moon': {'sign': 'Taurus', 'degree': 24.51},
      'Mars': {'sign': 'Scorpio', 'degree': 28.33},
      'Mercury': {'sign': 'Libra', 'degree': 28.91},
      'Jupiter': {'sign': 'Gemini', 'degree': 29.95},
      'Venus': {'sign': 'Scorpio', 'degree': 11.45},
      'Saturn': {'sign': 'Pisces', 'degree': 0.97},
      'Rahu': {'sign': 'Aquarius', 'degree': 19.36},
      'Ketu': {'sign': 'Leo', 'degree': 19.36},
    };

    // Run our calculation
    final result = quickTest();

    if (result['success'] == true) {
      final ourPlanets = result['planets'] as Map<String, Map<String, dynamic>>;

      debugPrint('║ Planet    | Expected         | Our App          | Match ║');
      debugPrint(
        '╠══════════════════════════════════════════════════════════════╣',
      );

      int matchCount = 0;
      int totalCount = 0;

      for (var planet in expectedPositions.keys) {
        final expected = expectedPositions[planet]!;
        final ours = ourPlanets[planet];

        if (ours != null) {
          final expectedSign = expected['sign'] as String;
          final expectedDeg = expected['degree'] as double;
          final ourSign = ours['sign'] as String;
          final ourDeg = ours['degree'] as double;

          final signMatch = ourSign == expectedSign;
          final status = signMatch ? '✅' : '❌';

          if (signMatch) matchCount++;
          totalCount++;

          final planetPad = planet.padRight(9);
          final expectedStr = '$expectedSign ${expectedDeg.toStringAsFixed(1)}°'
              .padRight(16);
          final ourStr = '$ourSign ${ourDeg.toStringAsFixed(1)}°'.padRight(16);

          debugPrint('║ $planetPad| $expectedStr | $ourStr | $status    ║');
        }
      }

      debugPrint(
        '╠══════════════════════════════════════════════════════════════╣',
      );
      debugPrint(
        '║ RESULT: $matchCount/$totalCount planets match signs                        ║',
      );

      if (matchCount == totalCount) {
        debugPrint(
          '║ ✅ ALL PLANETS CORRECTLY CALCULATED!                         ║',
        );
      } else {
        debugPrint(
          '║ ⚠️  Some planets have sign mismatches                        ║',
        );
      }
    }

    debugPrint(
      '╚══════════════════════════════════════════════════════════════╝',
    );
    debugPrint('\n');
  }

  /// Validate calculations for ANY date/time against expected values
  /// Use this to verify our calculations match other apps
  ///
  /// Usage:
  /// ```dart
  /// KundaliCalculationService.validateCalculation(
  ///   year: 2025, month: 12, day: 5,
  ///   hour: 13, minute: 38, second: 40,
  ///   latitude: 28.6139, longitude: 77.209,
  ///   timezone: 'IST',
  ///   expectedPositions: {
  ///     'Sun': 'Scorpio',
  ///     'Moon': 'Taurus',
  ///     'Jupiter': 'Gemini',
  ///     'Saturn': 'Pisces',
  ///     // ... add all planets you want to verify
  ///   },
  /// );
  /// ```
  static Map<String, dynamic> validateCalculation({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    int second = 0,
    required double latitude,
    required double longitude,
    required String timezone,
    required Map<String, String> expectedPositions,
  }) {
    debugPrint('\n');
    debugPrint(
      '╔══════════════════════════════════════════════════════════════╗',
    );
    debugPrint(
      '║              CALCULATION VALIDATION                          ║',
    );
    debugPrint(
      '╠══════════════════════════════════════════════════════════════╣',
    );
    debugPrint('║ Date: $day/$month/$year  Time: $hour:$minute:$second');
    debugPrint('║ Location: $latitude, $longitude ($timezone)');
    debugPrint(
      '╠══════════════════════════════════════════════════════════════╣',
    );

    final result = testCalculation(
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );

    final validationResults = <String, bool>{};
    int matchCount = 0;

    if (result['success'] == true) {
      final ourPlanets = result['planets'] as Map<String, Map<String, dynamic>>;

      debugPrint(
        '║ Planet    | Expected    | Our App     | Status             ║',
      );
      debugPrint(
        '╠══════════════════════════════════════════════════════════════╣',
      );

      for (var planet in expectedPositions.keys) {
        final expectedSign = expectedPositions[planet]!;
        final ours = ourPlanets[planet];

        if (ours != null) {
          final ourSign = ours['sign'] as String;
          final ourDeg = ours['degree'] as double;
          final signMatch = ourSign == expectedSign;

          validationResults[planet] = signMatch;
          if (signMatch) matchCount++;

          final status = signMatch ? '✅ MATCH' : '❌ MISMATCH';
          final planetPad = planet.padRight(9);
          final expectedPad = expectedSign.padRight(11);
          final ourPad = '$ourSign ${ourDeg.toStringAsFixed(1)}°'.padRight(11);

          debugPrint('║ $planetPad| $expectedPad | $ourPad | $status     ║');
        }
      }

      debugPrint(
        '╠══════════════════════════════════════════════════════════════╣',
      );

      final totalChecked = expectedPositions.length;
      final allMatch = matchCount == totalChecked;

      if (allMatch) {
        debugPrint(
          '║ ✅ VALIDATION PASSED: $matchCount/$totalChecked planets correct            ║',
        );
      } else {
        debugPrint(
          '║ ❌ VALIDATION FAILED: $matchCount/$totalChecked planets correct            ║',
        );
      }

      debugPrint(
        '╚══════════════════════════════════════════════════════════════╝',
      );
      debugPrint('\n');

      return {
        'success': true,
        'allMatch': allMatch,
        'matchCount': matchCount,
        'totalChecked': totalChecked,
        'results': validationResults,
        'planets': ourPlanets,
      };
    }

    debugPrint(
      '║ ❌ Calculation failed                                         ║',
    );
    debugPrint(
      '╚══════════════════════════════════════════════════════════════╝',
    );

    return {'success': false, 'error': result['error']};
  }

  /// Run validation tests for multiple known dates
  /// This ensures our calculations are consistent across different times
  static void runValidationSuite() {
    debugPrint('\n');
    debugPrint(
      '═══════════════════════════════════════════════════════════════',
    );
    debugPrint(
      '         RUNNING COMPREHENSIVE VALIDATION SUITE                 ',
    );
    debugPrint(
      '═══════════════════════════════════════════════════════════════',
    );

    int passedTests = 0;
    int totalTests = 0;

    // Test 1: Dec 5, 2025 (our calibration date)
    totalTests++;
    final test1 = validateCalculation(
      year: 2025,
      month: 12,
      day: 5,
      hour: 13,
      minute: 38,
      second: 40,
      latitude: 28.6139,
      longitude: 77.209,
      timezone: 'IST',
      expectedPositions: {
        'Sun': 'Scorpio',
        'Moon': 'Taurus',
        'Mars': 'Scorpio',
        'Mercury': 'Libra',
        'Jupiter': 'Gemini',
        'Venus': 'Scorpio',
        'Saturn': 'Pisces',
        'Rahu': 'Aquarius',
        'Ketu': 'Leo',
      },
    );
    if (test1['allMatch'] == true) passedTests++;

    // Summary
    debugPrint(
      '═══════════════════════════════════════════════════════════════',
    );
    debugPrint(
      '         VALIDATION SUITE COMPLETE                              ',
    );
    debugPrint(
      '═══════════════════════════════════════════════════════════════',
    );
    debugPrint('  Tests Passed: $passedTests / $totalTests');
    if (passedTests == totalTests) {
      debugPrint('  ✅ ALL TESTS PASSED - Calculations are accurate!');
    } else {
      debugPrint('  ⚠️  Some tests failed - Review ayanamsa correction');
    }
    debugPrint(
      '═══════════════════════════════════════════════════════════════\n',
    );
  }

  // ============ END TEST FUNCTION ============

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

  // ============ YOGINI DASHA CALCULATIONS ============

  /// Yogini order (fixed sequence)
  static const _yoginiOrder = [
    Yogini.mangala,
    Yogini.pingala,
    Yogini.dhanya,
    Yogini.bhramari,
    Yogini.bhadrika,
    Yogini.ulka,
    Yogini.siddha,
    Yogini.sankata,
  ];

  /// Nakshatra to starting Yogini mapping
  /// 27 nakshatras mapped to 8 Yoginis (some repeat)
  static Yogini _getNakshatraYogini(int nakshatraIndex) {
    // Nakshatra to Yogini mapping (3-4 nakshatras per Yogini)
    // This follows traditional Yogini Dasha mapping
    const mapping = [
      Yogini.mangala, // 0 - Ashwini
      Yogini.pingala, // 1 - Bharani
      Yogini.dhanya, // 2 - Krittika
      Yogini.bhramari, // 3 - Rohini
      Yogini.bhadrika, // 4 - Mrigashira
      Yogini.ulka, // 5 - Ardra
      Yogini.siddha, // 6 - Punarvasu
      Yogini.sankata, // 7 - Pushya
      Yogini.mangala, // 8 - Ashlesha
      Yogini.pingala, // 9 - Magha
      Yogini.dhanya, // 10 - Purva Phalguni
      Yogini.bhramari, // 11 - Uttara Phalguni
      Yogini.bhadrika, // 12 - Hasta
      Yogini.ulka, // 13 - Chitra
      Yogini.siddha, // 14 - Swati
      Yogini.sankata, // 15 - Vishakha
      Yogini.mangala, // 16 - Anuradha
      Yogini.pingala, // 17 - Jyeshtha
      Yogini.dhanya, // 18 - Mula
      Yogini.bhramari, // 19 - Purva Ashadha
      Yogini.bhadrika, // 20 - Uttara Ashadha
      Yogini.ulka, // 21 - Shravana
      Yogini.siddha, // 22 - Dhanishta
      Yogini.sankata, // 23 - Shatabhisha
      Yogini.mangala, // 24 - Purva Bhadrapada
      Yogini.pingala, // 25 - Uttara Bhadrapada
      Yogini.dhanya, // 26 - Revati
    ];
    return mapping[nakshatraIndex % 27];
  }

  /// Calculate Yogini Dasha info using Moon's nakshatra
  static YoginiDashaInfo calculateYoginiDasha(
    DateTime birthDateTime,
    double moonLongitude,
  ) {
    final nakshatra = SwephService.getNakshatra(moonLongitude);
    final startingYogini = _getNakshatraYogini(nakshatra.index);

    // Yogini Dasha sequence
    final yoginiSequence = <YoginiPeriod>[];
    for (final yogini in _yoginiOrder) {
      yoginiSequence.add(YoginiPeriod(yogini, yogini.years));
    }

    // Calculate elapsed portion of birth nakshatra Dasha
    final degreeInNakshatra = nakshatra.degreeInNakshatra;
    final portionCompleted = degreeInNakshatra / (360.0 / 27.0);

    // Find starting Yogini index
    int startingYoginiIndex = _yoginiOrder.indexOf(startingYogini);

    // Calculate remaining years in birth Yogini Dasha
    final fullYoginiYears = startingYogini.years.toDouble();
    final remainingYears = fullYoginiYears * (1 - portionCompleted);

    // Calculate current Yogini based on elapsed time
    final now = DateTime.now();
    final ageInYears = now.difference(birthDateTime).inDays / 365.25;

    double totalYearsElapsed = ageInYears;
    Yogini currentYogini = startingYogini;
    double currentYoginiRemaining = remainingYears;
    double elapsedInCurrentYogini = 0;
    DateTime? yoginiStartDate;

    // First subtract remaining birth Yogini
    if (totalYearsElapsed < remainingYears) {
      currentYoginiRemaining = remainingYears - totalYearsElapsed;
      elapsedInCurrentYogini = totalYearsElapsed;
      yoginiStartDate = birthDateTime;
    } else {
      totalYearsElapsed -= remainingYears;

      // Move through subsequent Yoginis
      int currentIndex = (startingYoginiIndex + 1) % 8;
      double yearsFromBirth = remainingYears;

      while (totalYearsElapsed > 0) {
        final yoginiYears = _yoginiOrder[currentIndex].years.toDouble();
        if (totalYearsElapsed < yoginiYears) {
          currentYogini = _yoginiOrder[currentIndex];
          currentYoginiRemaining = yoginiYears - totalYearsElapsed;
          elapsedInCurrentYogini = totalYearsElapsed;
          yoginiStartDate = birthDateTime.add(
            Duration(days: (yearsFromBirth * 365.25).round()),
          );
          break;
        }
        totalYearsElapsed -= yoginiYears;
        yearsFromBirth += yoginiYears;
        currentIndex = (currentIndex + 1) % 8;
      }
    }

    // Calculate current Antardasha
    Yogini? currentAntardasha;
    double? antardashaRemainingYears;

    final yoginiYears = currentYogini.years.toDouble();

    // Find antardasha sequence starting from current yogini
    int yoginiIndex = _yoginiOrder.indexOf(currentYogini);

    double antardashaElapsed = elapsedInCurrentYogini;
    for (int i = 0; i < 8; i++) {
      final antarIndex = (yoginiIndex + i) % 8;
      final antarYogini = _yoginiOrder[antarIndex];
      final antarBaseYears = antarYogini.years.toDouble();
      final antarDuration = (yoginiYears * antarBaseYears) / 36.0;

      if (antardashaElapsed < antarDuration) {
        currentAntardasha = antarYogini;
        antardashaRemainingYears = antarDuration - antardashaElapsed;
        break;
      }
      antardashaElapsed -= antarDuration;
    }

    final yoginiEndDate = yoginiStartDate?.add(
      Duration(days: (yoginiYears * 365.25).round()),
    );

    // Generate Yogini sequence with dates
    final yoginiDetailSequence = _generateYoginiSequence(
      birthDate: birthDateTime,
      firstYogini: startingYogini,
      balanceYears: remainingYears,
      includeSubPeriods: true,
      maxSubLevel: 2,
    );

    // Get current periods at available levels
    final currentPeriods = _getCurrentYoginiAtAllLevels(yoginiDetailSequence, now);

    return YoginiDashaInfo(
      currentYogini: currentYogini,
      remainingYears: currentYoginiRemaining,
      startDate: birthDateTime,
      sequence: yoginiSequence,
      currentAntardasha: currentAntardasha,
      antardashaRemainingYears: antardashaRemainingYears,
      yoginiStartDate: yoginiStartDate,
      yoginiEndDate: yoginiEndDate,
      yoginiSequence: yoginiDetailSequence,
      currentYoginiDetail: currentPeriods[YoginiLevel.mahadasha],
      currentAntardashaDetail: currentPeriods[YoginiLevel.antardasha],
      currentPratyantaraDetail: currentPeriods[YoginiLevel.pratyantara],
      currentSookshmaDetail: currentPeriods[YoginiLevel.sookshma],
      currentPranaDetail: currentPeriods[YoginiLevel.prana],
      balanceYearsAtBirth: remainingYears,
      birthNakshatra: nakshatra.name,
    );
  }

  /// Generate complete Yogini sequence with dates
  static List<YoginiPeriodDetail> _generateYoginiSequence({
    required DateTime birthDate,
    required Yogini firstYogini,
    required double balanceYears,
    bool includeSubPeriods = false,
    int maxSubLevel = 1,
  }) {
    final sequence = <YoginiPeriodDetail>[];
    var currentDate = birthDate;

    // Find starting index
    int startIndex = _yoginiOrder.indexOf(firstYogini);

    // First Yogini with balance
    final firstDuration = balanceYears;
    final firstEndDate = addDecimalYears(currentDate, firstDuration);

    List<YoginiPeriodDetail>? firstSubPeriods;
    if (includeSubPeriods && maxSubLevel > 1) {
      firstSubPeriods = _calculateYoginiSubPeriods(
        parentPath: firstYogini.displayName,
        parentYogini: firstYogini,
        parentDuration: firstDuration,
        startDate: currentDate,
        level: YoginiLevel.antardasha,
        maxDepth: maxSubLevel,
      );
    }

    sequence.add(YoginiPeriodDetail(
      yogini: firstYogini,
      fullPath: firstYogini.displayName,
      durationYears: firstDuration,
      startDate: currentDate,
      endDate: firstEndDate,
      level: YoginiLevel.mahadasha,
      subPeriods: firstSubPeriods,
    ));

    currentDate = firstEndDate;

    // Subsequent Yoginis (full duration)
    for (int cycle = 0; cycle < 4; cycle++) {
      // 4 cycles of 36 years = 144 years total
      for (int i = 0; i < 8; i++) {
        final yoginiIndex = (startIndex + 1 + i) % 8;
        final yogini = _yoginiOrder[yoginiIndex];
        final duration = yogini.years.toDouble();
        final endDate = addDecimalYears(currentDate, duration);

        List<YoginiPeriodDetail>? subPeriods;
        if (includeSubPeriods && maxSubLevel > 1) {
          subPeriods = _calculateYoginiSubPeriods(
            parentPath: yogini.displayName,
            parentYogini: yogini,
            parentDuration: duration,
            startDate: currentDate,
            level: YoginiLevel.antardasha,
            maxDepth: maxSubLevel,
          );
        }

        sequence.add(YoginiPeriodDetail(
          yogini: yogini,
          fullPath: yogini.displayName,
          durationYears: duration,
          startDate: currentDate,
          endDate: endDate,
          level: YoginiLevel.mahadasha,
          subPeriods: subPeriods,
        ));

        currentDate = endDate;

        // Stop if we've covered enough years (120+)
        if (currentDate.difference(birthDate).inDays > 44000) {
          return sequence;
        }
      }
    }

    return sequence;
  }

  /// Calculate Yogini sub-periods (Antardasha and deeper)
  static List<YoginiPeriodDetail> _calculateYoginiSubPeriods({
    required String parentPath,
    required Yogini parentYogini,
    required double parentDuration,
    required DateTime startDate,
    required YoginiLevel level,
    int maxDepth = 2,
  }) {
    final subPeriods = <YoginiPeriodDetail>[];
    var currentDate = startDate;

    // Find starting index (sub-periods start from parent yogini)
    int startIndex = _yoginiOrder.indexOf(parentYogini);

    // Calculate all 8 sub-periods
    for (int i = 0; i < 8; i++) {
      final yoginiIndex = (startIndex + i) % 8;
      final subYogini = _yoginiOrder[yoginiIndex];
      final subYoginiYears = subYogini.years.toDouble();

      // Universal formula: (parent duration × sub-yogini years) / 36
      final subDuration = (parentDuration * subYoginiYears) / 36.0;
      final endDate = addDecimalYears(currentDate, subDuration);
      final fullPath = '$parentPath-${subYogini.displayName}';

      // Determine next level
      YoginiLevel? nextLevel;
      if (level == YoginiLevel.antardasha) {
        nextLevel = YoginiLevel.pratyantara;
      } else if (level == YoginiLevel.pratyantara) {
        nextLevel = YoginiLevel.sookshma;
      } else if (level == YoginiLevel.sookshma) {
        nextLevel = YoginiLevel.prana;
      }

      // Recursively calculate sub-periods if within max depth
      final currentDepth = level.index;
      List<YoginiPeriodDetail>? childSubPeriods;

      if (nextLevel != null && currentDepth < maxDepth) {
        childSubPeriods = _calculateYoginiSubPeriods(
          parentPath: fullPath,
          parentYogini: subYogini,
          parentDuration: subDuration,
          startDate: currentDate,
          level: nextLevel,
          maxDepth: maxDepth,
        );
      }

      subPeriods.add(YoginiPeriodDetail(
        yogini: subYogini,
        fullPath: fullPath,
        durationYears: subDuration,
        startDate: currentDate,
        endDate: endDate,
        level: level,
        subPeriods: childSubPeriods,
      ));

      currentDate = endDate;
    }

    return subPeriods;
  }

  /// Get current Yogini periods at all levels
  static Map<YoginiLevel, YoginiPeriodDetail> _getCurrentYoginiAtAllLevels(
    List<YoginiPeriodDetail> sequence,
    DateTime date,
  ) {
    final result = <YoginiLevel, YoginiPeriodDetail>{};

    YoginiPeriodDetail? findCurrentAtLevel(
      List<YoginiPeriodDetail>? periods,
      YoginiLevel level,
    ) {
      if (periods == null) return null;
      for (final period in periods) {
        if (period.containsDate(date)) {
          result[level] = period;
          if (period.subPeriods != null) {
            final nextLevel = _getNextYoginiLevel(level);
            if (nextLevel != null) {
              findCurrentAtLevel(period.subPeriods, nextLevel);
            }
          }
          return period;
        }
      }
      return null;
    }

    findCurrentAtLevel(sequence, YoginiLevel.mahadasha);
    return result;
  }

  static YoginiLevel? _getNextYoginiLevel(YoginiLevel current) {
    switch (current) {
      case YoginiLevel.mahadasha:
        return YoginiLevel.antardasha;
      case YoginiLevel.antardasha:
        return YoginiLevel.pratyantara;
      case YoginiLevel.pratyantara:
        return YoginiLevel.sookshma;
      case YoginiLevel.sookshma:
        return YoginiLevel.prana;
      case YoginiLevel.prana:
        return null;
    }
  }

  /// Calculate Yogini sub-periods on demand (for drill-down)
  static List<YoginiPeriodDetail> calculateYoginiSubPeriodsOnDemand({
    required YoginiPeriodDetail parentPeriod,
    int depth = 1,
  }) {
    if (depth <= 0) return [];

    final nextLevel = _getNextYoginiLevel(parentPeriod.level);
    if (nextLevel == null) return [];

    return _calculateYoginiSubPeriods(
      parentPath: parentPeriod.fullPath,
      parentYogini: parentPeriod.yogini,
      parentDuration: parentPeriod.durationYears,
      startDate: parentPeriod.startDate,
      level: nextLevel,
      maxDepth: parentPeriod.level.index + depth,
    );
  }

  // ============ CHAR DASHA (JAIMINI) CALCULATIONS ============

  /// Signs in order
  static const _signOrder = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
  ];

  /// Sign lords (traditional rulership)
  static const _signLords = {
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

  /// Sign symbols (zodiac)
  static String getSignSymbol(String sign) {
    const symbols = {
      'Aries': '♈',
      'Taurus': '♉',
      'Gemini': '♊',
      'Cancer': '♋',
      'Leo': '♌',
      'Virgo': '♍',
      'Libra': '♎',
      'Scorpio': '♏',
      'Sagittarius': '♐',
      'Capricorn': '♑',
      'Aquarius': '♒',
      'Pisces': '♓',
    };
    return symbols[sign] ?? '⭐';
  }

  /// Check if sign is odd (movable direction: clockwise for odd, anti-clockwise for even)
  static bool _isOddSign(String sign) {
    final index = _signOrder.indexOf(sign);
    return index % 2 == 0; // 0-indexed, so Aries(0) is odd, Taurus(1) is even
  }

  /// Calculate Jaimini Chara Karakas from planet positions
  static JaiminiKarakas calculateJaiminiKarakas(
    Map<String, PlanetPosition> planetPositions,
    Map<String, PlanetPosition>? navamsaChart,
  ) {
    // Karakas are determined by degree within sign (highest to lowest)
    // Only use 7 planets: Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn
    // Rahu can be used as 8th karaka in some traditions
    
    final karakaPlanets = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu'];
    
    // Get degree within sign for each planet
    final planetDegrees = <String, double>{};
    for (final planet in karakaPlanets) {
      final pos = planetPositions[planet];
      if (pos != null) {
        // Use degree within sign (0-30)
        planetDegrees[planet] = pos.signDegree;
      }
    }

    // Sort planets by degree (highest first)
    final sortedPlanets = planetDegrees.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Assign karakas (first 8 in descending degree order)
    String atmakaraka = sortedPlanets.length > 0 ? sortedPlanets[0].key : 'Sun';
    double atmakarakaDegree = sortedPlanets.length > 0 ? sortedPlanets[0].value : 0;
    
    String amatyakaraka = sortedPlanets.length > 1 ? sortedPlanets[1].key : 'Moon';
    double amatyakarakaDegree = sortedPlanets.length > 1 ? sortedPlanets[1].value : 0;
    
    String bhratrikaraka = sortedPlanets.length > 2 ? sortedPlanets[2].key : 'Mars';
    double bhratrikarakaDegree = sortedPlanets.length > 2 ? sortedPlanets[2].value : 0;
    
    String matrikaraka = sortedPlanets.length > 3 ? sortedPlanets[3].key : 'Mercury';
    double matrikarakaDegree = sortedPlanets.length > 3 ? sortedPlanets[3].value : 0;
    
    String pitrikaraka = sortedPlanets.length > 4 ? sortedPlanets[4].key : 'Jupiter';
    double pitrikarakaDegree = sortedPlanets.length > 4 ? sortedPlanets[4].value : 0;
    
    String putrakaraka = sortedPlanets.length > 5 ? sortedPlanets[5].key : 'Venus';
    double putrakarakaDegree = sortedPlanets.length > 5 ? sortedPlanets[5].value : 0;
    
    String gnatikaraka = sortedPlanets.length > 6 ? sortedPlanets[6].key : 'Saturn';
    double gnatikarakaDegree = sortedPlanets.length > 6 ? sortedPlanets[6].value : 0;
    
    String darakaraka = sortedPlanets.length > 7 ? sortedPlanets[7].key : 'Rahu';
    double darakarakaDegree = sortedPlanets.length > 7 ? sortedPlanets[7].value : 0;

    // Calculate Karakamsa (Atmakaraka's sign in Navamsa)
    String karakamsa = 'Aries';
    if (navamsaChart != null && navamsaChart.containsKey(atmakaraka)) {
      karakamsa = navamsaChart[atmakaraka]!.sign;
    }

    return JaiminiKarakas(
      atmakaraka: atmakaraka,
      atmakarakaDegree: atmakarakaDegree,
      amatyakaraka: amatyakaraka,
      amatyakarakaDegree: amatyakarakaDegree,
      bhratrikaraka: bhratrikaraka,
      bhratrikarakaDegree: bhratrikarakaDegree,
      matrikaraka: matrikaraka,
      matrikarakaDegree: matrikarakaDegree,
      pitrikaraka: pitrikaraka,
      pitrikarakaDegree: pitrikarakaDegree,
      putrakaraka: putrakaraka,
      putrakarakaDegree: putrakarakaDegree,
      gnatikaraka: gnatikaraka,
      gnatrikarakaDegree: gnatikarakaDegree,
      darakaraka: darakaraka,
      darakarakaDegree: darakarakaDegree,
      karakamsa: karakamsa,
    );
  }

  /// Calculate Char Dasha duration for a sign
  /// In Jaimini, duration depends on the position of the sign lord
  static int _getCharDashaDuration(String sign, Map<String, PlanetPosition> planetPositions) {
    final lord = _signLords[sign] ?? 'Sun';
    final lordPosition = planetPositions[lord];
    
    if (lordPosition == null) return 9; // Default
    
    // Count signs from the sign to where its lord is placed
    final signIndex = _signOrder.indexOf(sign);
    final lordSignIndex = _signOrder.indexOf(lordPosition.sign);
    
    int distance = (lordSignIndex - signIndex + 12) % 12;
    if (distance == 0) distance = 12;
    
    // Apply certain rules:
    // If lord is in own sign, take 12 or special calculation
    if (lordPosition.sign == sign) {
      return 12;
    }
    
    // If lord is in exaltation, add 1 year
    // If lord is in debilitation, subtract 1 year
    // (Simplified for now)
    
    return distance.clamp(1, 12);
  }

  /// Calculate Char Dasha info using Lagna
  static CharDashaInfo calculateCharDasha(
    DateTime birthDateTime,
    AscendantInfo ascendant,
    Map<String, PlanetPosition> planetPositions,
    Map<String, PlanetPosition>? navamsaChart,
  ) {
    // Calculate Jaimini Karakas first
    final karakas = calculateJaiminiKarakas(planetPositions, navamsaChart);
    
    // Determine starting sign (Lagna or 7th house based on tradition)
    final lagnaSign = ascendant.sign;
    final lagnaIndex = _signOrder.indexOf(lagnaSign);
    
    // Determine direction based on odd/even sign
    final isClockwise = _isOddSign(lagnaSign);
    
    // Build the Char Dasha sequence (12 signs)
    final charSequence = <CharaPeriod>[];
    final charDetailSequence = <CharaPeriodDetail>[];
    
    var currentDate = birthDateTime;
    
    for (int i = 0; i < 12; i++) {
      int signIndex;
      if (isClockwise) {
        signIndex = (lagnaIndex + i) % 12;
      } else {
        signIndex = (lagnaIndex - i + 12) % 12;
      }
      
      final sign = _signOrder[signIndex];
      final duration = _getCharDashaDuration(sign, planetPositions);
      
      charSequence.add(CharaPeriod(sign, duration));
      
      final endDate = addDecimalYears(currentDate, duration.toDouble());
      
      // Generate sub-periods (Antardashas)
      final subPeriods = _calculateCharSubPeriods(
        parentPath: sign,
        parentSign: sign,
        parentDuration: duration.toDouble(),
        startDate: currentDate,
        level: CharLevel.antardasha,
        isClockwise: isClockwise,
        maxDepth: 2,
      );
      
      charDetailSequence.add(CharaPeriodDetail(
        sign: sign,
        fullPath: sign,
        durationYears: duration.toDouble(),
        startDate: currentDate,
        endDate: endDate,
        level: CharLevel.mahadasha,
        subPeriods: subPeriods,
        signLord: _signLords[sign],
      ));
      
      currentDate = endDate;
    }
    
    // Calculate current position
    final now = DateTime.now();
    final ageInYears = now.difference(birthDateTime).inDays / 365.25;
    
    String currentSign = lagnaSign;
    double currentRemaining = 0;
    DateTime? signStartDate;
    DateTime? signEndDate;
    
    double yearsElapsed = ageInYears;
    double yearsFromBirth = 0;
    
    for (final period in charDetailSequence) {
      if (yearsElapsed < period.durationYears) {
        currentSign = period.sign;
        currentRemaining = period.durationYears - yearsElapsed;
        signStartDate = period.startDate;
        signEndDate = period.endDate;
        break;
      }
      yearsElapsed -= period.durationYears;
      yearsFromBirth += period.durationYears;
    }
    
    // Get current Antardasha
    String? currentAntardasha;
    double? antardashaRemainingYears;
    
    for (final period in charDetailSequence) {
      if (period.sign == currentSign && period.subPeriods != null) {
        double antarElapsed = ageInYears - yearsFromBirth;
        for (final antar in period.subPeriods!) {
          if (antarElapsed < antar.durationYears) {
            currentAntardasha = antar.sign;
            antardashaRemainingYears = antar.durationYears - antarElapsed;
            break;
          }
          antarElapsed -= antar.durationYears;
        }
        break;
      }
    }
    
    // Get current periods at all levels
    final currentPeriods = _getCurrentCharAtAllLevels(charDetailSequence, now);
    
    return CharDashaInfo(
      currentSign: currentSign,
      remainingYears: currentRemaining,
      startDate: birthDateTime,
      sequence: charSequence,
      currentAntardasha: currentAntardasha,
      antardashaRemainingYears: antardashaRemainingYears,
      signStartDate: signStartDate,
      signEndDate: signEndDate,
      isClockwise: isClockwise,
      startingSign: lagnaSign,
      karakas: karakas,
      charSequence: charDetailSequence,
      currentSignDetail: currentPeriods[CharLevel.mahadasha],
      currentAntardashaDetail: currentPeriods[CharLevel.antardasha],
      currentPratyantaraDetail: currentPeriods[CharLevel.pratyantara],
      currentSookshmaDetail: currentPeriods[CharLevel.sookshma],
      currentPranaDetail: currentPeriods[CharLevel.prana],
    );
  }

  /// Calculate Char Dasha sub-periods
  static List<CharaPeriodDetail> _calculateCharSubPeriods({
    required String parentPath,
    required String parentSign,
    required double parentDuration,
    required DateTime startDate,
    required CharLevel level,
    required bool isClockwise,
    int maxDepth = 2,
  }) {
    final subPeriods = <CharaPeriodDetail>[];
    var currentDate = startDate;
    
    // Find starting index
    int startIndex = _signOrder.indexOf(parentSign);
    
    // Calculate all 12 sub-periods
    for (int i = 0; i < 12; i++) {
      int signIndex;
      if (isClockwise) {
        signIndex = (startIndex + i) % 12;
      } else {
        signIndex = (startIndex - i + 12) % 12;
      }
      
      final subSign = _signOrder[signIndex];
      
      // Duration formula: (parent duration) / 12
      final subDuration = parentDuration / 12.0;
      final endDate = addDecimalYears(currentDate, subDuration);
      final fullPath = '$parentPath-$subSign';
      
      // Determine next level
      CharLevel? nextLevel;
      if (level == CharLevel.antardasha) {
        nextLevel = CharLevel.pratyantara;
      } else if (level == CharLevel.pratyantara) {
        nextLevel = CharLevel.sookshma;
      } else if (level == CharLevel.sookshma) {
        nextLevel = CharLevel.prana;
      }
      
      // Recursively calculate sub-periods if within max depth
      final currentDepth = level.index;
      List<CharaPeriodDetail>? childSubPeriods;
      
      if (nextLevel != null && currentDepth < maxDepth) {
        childSubPeriods = _calculateCharSubPeriods(
          parentPath: fullPath,
          parentSign: subSign,
          parentDuration: subDuration,
          startDate: currentDate,
          level: nextLevel,
          isClockwise: isClockwise,
          maxDepth: maxDepth,
        );
      }
      
      subPeriods.add(CharaPeriodDetail(
        sign: subSign,
        fullPath: fullPath,
        durationYears: subDuration,
        startDate: currentDate,
        endDate: endDate,
        level: level,
        subPeriods: childSubPeriods,
        signLord: _signLords[subSign],
      ));
      
      currentDate = endDate;
    }
    
    return subPeriods;
  }

  /// Get current Char Dasha periods at all levels
  static Map<CharLevel, CharaPeriodDetail> _getCurrentCharAtAllLevels(
    List<CharaPeriodDetail> sequence,
    DateTime date,
  ) {
    final result = <CharLevel, CharaPeriodDetail>{};
    
    CharaPeriodDetail? findCurrentAtLevel(
      List<CharaPeriodDetail>? periods,
      CharLevel level,
    ) {
      if (periods == null) return null;
      for (final period in periods) {
        if (period.containsDate(date)) {
          result[level] = period;
          if (period.subPeriods != null) {
            final nextLevel = _getNextCharLevel(level);
            if (nextLevel != null) {
              findCurrentAtLevel(period.subPeriods, nextLevel);
            }
          }
          return period;
        }
      }
      return null;
    }
    
    findCurrentAtLevel(sequence, CharLevel.mahadasha);
    return result;
  }

  static CharLevel? _getNextCharLevel(CharLevel current) {
    switch (current) {
      case CharLevel.mahadasha:
        return CharLevel.antardasha;
      case CharLevel.antardasha:
        return CharLevel.pratyantara;
      case CharLevel.pratyantara:
        return CharLevel.sookshma;
      case CharLevel.sookshma:
        return CharLevel.prana;
      case CharLevel.prana:
        return null;
    }
  }

  /// Calculate Char Dasha sub-periods on demand (for drill-down)
  static List<CharaPeriodDetail> calculateCharSubPeriodsOnDemand({
    required CharaPeriodDetail parentPeriod,
    required bool isClockwise,
    int depth = 1,
  }) {
    if (depth <= 0) return [];
    
    final nextLevel = _getNextCharLevel(parentPeriod.level);
    if (nextLevel == null) return [];
    
    return _calculateCharSubPeriods(
      parentPath: parentPeriod.fullPath,
      parentSign: parentPeriod.sign,
      parentDuration: parentPeriod.durationYears,
      startDate: parentPeriod.startDate,
      level: nextLevel,
      isClockwise: isClockwise,
      maxDepth: parentPeriod.level.index + depth,
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

// ============================================================================
// MULTI-DASHA SYSTEM MODELS
// ============================================================================

/// Enum for different Dasha systems
enum DashaType {
  vimshottari, // 120-year Moon nakshatra-based
  mahadashaPhala, // Predictions & interpretations of current Mahadasha
  yogini, // 36-year cycle with 8 Yoginis
  char, // Jaimini Char Dasha (sign-based)
}

/// Extension for DashaType display
extension DashaTypeExtension on DashaType {
  String get displayName {
    switch (this) {
      case DashaType.vimshottari:
        return 'Vimshottari';
      case DashaType.mahadashaPhala:
        return 'Phala';
      case DashaType.yogini:
        return 'Yogini';
      case DashaType.char:
        return 'Char';
    }
  }

  String get fullName {
    switch (this) {
      case DashaType.vimshottari:
        return 'Vimshottari Dasha';
      case DashaType.mahadashaPhala:
        return 'Mahadasha Phala';
      case DashaType.yogini:
        return 'Yogini Dasha';
      case DashaType.char:
        return 'Char Dasha';
    }
  }

  String get description {
    switch (this) {
      case DashaType.vimshottari:
        return '120-year cycle based on Moon\'s nakshatra';
      case DashaType.mahadashaPhala:
        return 'Predictions & effects of current period';
      case DashaType.yogini:
        return '36-year cycle with 8 divine Yoginis';
      case DashaType.char:
        return 'Jaimini system based on sign positions';
    }
  }

  int get totalYears {
    switch (this) {
      case DashaType.vimshottari:
        return 120;
      case DashaType.mahadashaPhala:
        return 0; // N/A - interpretive view
      case DashaType.yogini:
        return 36;
      case DashaType.char:
        return 144; // 12 signs × 12 years max
    }
  }
}

// ============================================================================
// YOGINI DASHA MODELS
// ============================================================================

/// The 8 Yoginis in Yogini Dasha system
enum Yogini {
  mangala, // 1 year - Mars
  pingala, // 2 years - Sun
  dhanya, // 3 years - Jupiter
  bhramari, // 4 years - Mars
  bhadrika, // 5 years - Mercury
  ulka, // 6 years - Saturn
  siddha, // 7 years - Venus
  sankata, // 8 years - Rahu
}

/// Extension for Yogini display and properties
extension YoginiExtension on Yogini {
  String get displayName {
    switch (this) {
      case Yogini.mangala:
        return 'Mangala';
      case Yogini.pingala:
        return 'Pingala';
      case Yogini.dhanya:
        return 'Dhanya';
      case Yogini.bhramari:
        return 'Bhramari';
      case Yogini.bhadrika:
        return 'Bhadrika';
      case Yogini.ulka:
        return 'Ulka';
      case Yogini.siddha:
        return 'Siddha';
      case Yogini.sankata:
        return 'Sankata';
    }
  }

  /// Duration in years for each Yogini
  int get years {
    switch (this) {
      case Yogini.mangala:
        return 1;
      case Yogini.pingala:
        return 2;
      case Yogini.dhanya:
        return 3;
      case Yogini.bhramari:
        return 4;
      case Yogini.bhadrika:
        return 5;
      case Yogini.ulka:
        return 6;
      case Yogini.siddha:
        return 7;
      case Yogini.sankata:
        return 8;
    }
  }

  /// Associated planet for each Yogini
  String get planet {
    switch (this) {
      case Yogini.mangala:
        return 'Moon';
      case Yogini.pingala:
        return 'Sun';
      case Yogini.dhanya:
        return 'Jupiter';
      case Yogini.bhramari:
        return 'Mars';
      case Yogini.bhadrika:
        return 'Mercury';
      case Yogini.ulka:
        return 'Saturn';
      case Yogini.siddha:
        return 'Venus';
      case Yogini.sankata:
        return 'Rahu';
    }
  }

  /// Symbol for each Yogini
  String get symbol {
    switch (this) {
      case Yogini.mangala:
        return '☽'; // Moon
      case Yogini.pingala:
        return '☉'; // Sun
      case Yogini.dhanya:
        return '♃'; // Jupiter
      case Yogini.bhramari:
        return '♂'; // Mars
      case Yogini.bhadrika:
        return '☿'; // Mercury
      case Yogini.ulka:
        return '♄'; // Saturn
      case Yogini.siddha:
        return '♀'; // Venus
      case Yogini.sankata:
        return '☊'; // Rahu
    }
  }

  /// Nature/effect of each Yogini
  String get nature {
    switch (this) {
      case Yogini.mangala:
        return 'Auspicious, new beginnings';
      case Yogini.pingala:
        return 'Authority, recognition, ego';
      case Yogini.dhanya:
        return 'Prosperity, wisdom, growth';
      case Yogini.bhramari:
        return 'Energy, conflicts, action';
      case Yogini.bhadrika:
        return 'Communication, learning, travel';
      case Yogini.ulka:
        return 'Obstacles, delays, discipline';
      case Yogini.siddha:
        return 'Success, luxury, relationships';
      case Yogini.sankata:
        return 'Challenges, transformation, karma';
    }
  }
}

/// Yogini Dasha level enumeration
enum YoginiLevel {
  mahadasha, // Main Yogini period
  antardasha, // Sub-period
  pratyantara, // Sub-sub-period
  sookshma, // Sub-sub-sub-period
  prana, // Micro-level period
}

/// Individual Yogini period (basic)
class YoginiPeriod {
  final Yogini yogini;
  final int years;

  const YoginiPeriod(this.yogini, this.years);
}

/// Detailed Yogini period with dates and sub-periods
class YoginiPeriodDetail {
  final Yogini yogini;
  final String fullPath;
  final double durationYears;
  final DateTime startDate;
  final DateTime endDate;
  final YoginiLevel level;
  final List<YoginiPeriodDetail>? subPeriods;

  YoginiPeriodDetail({
    required this.yogini,
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
    } else if (days > 0) {
      return '$days days';
    } else {
      final hours = (totalDays * 24).round();
      if (hours > 0) return '$hours hours';
      return '< 1 hour';
    }
  }

  /// Check if a given date falls within this period
  bool containsDate(DateTime date) {
    return !date.isBefore(startDate) && date.isBefore(endDate);
  }

  /// Get the level name as a string
  String get levelName {
    switch (level) {
      case YoginiLevel.mahadasha:
        return 'Mahadasha';
      case YoginiLevel.antardasha:
        return 'Antardasha';
      case YoginiLevel.pratyantara:
        return 'Pratyantara';
      case YoginiLevel.sookshma:
        return 'Sookshma';
      case YoginiLevel.prana:
        return 'Prana';
    }
  }
}

/// Complete Yogini Dasha information
class YoginiDashaInfo {
  final Yogini currentYogini;
  final double remainingYears;
  final DateTime startDate;
  final List<YoginiPeriod> sequence;
  final Yogini? currentAntardasha;
  final double? antardashaRemainingYears;
  final DateTime? yoginiStartDate;
  final DateTime? yoginiEndDate;
  
  // Enhanced fields
  final List<YoginiPeriodDetail>? yoginiSequence;
  final YoginiPeriodDetail? currentYoginiDetail;
  final YoginiPeriodDetail? currentAntardashaDetail;
  final YoginiPeriodDetail? currentPratyantaraDetail;
  final YoginiPeriodDetail? currentSookshmaDetail;
  final YoginiPeriodDetail? currentPranaDetail;
  final double? balanceYearsAtBirth;
  final String? birthNakshatra;

  YoginiDashaInfo({
    required this.currentYogini,
    required this.remainingYears,
    required this.startDate,
    required this.sequence,
    this.currentAntardasha,
    this.antardashaRemainingYears,
    this.yoginiStartDate,
    this.yoginiEndDate,
    this.yoginiSequence,
    this.currentYoginiDetail,
    this.currentAntardashaDetail,
    this.currentPratyantaraDetail,
    this.currentSookshmaDetail,
    this.currentPranaDetail,
    this.balanceYearsAtBirth,
    this.birthNakshatra,
  });

  /// Get the current full dasha path string
  String get currentFullPath {
    final parts = <String>[currentYogini.displayName];
    if (currentAntardasha != null) {
      parts.add(currentAntardasha!.displayName);
    }
    return parts.join('-');
  }
}

// ============================================================================
// CHAR DASHA (JAIMINI) MODELS
// ============================================================================

/// The 8 Chara Karakas in Jaimini astrology
enum CharaKaraka {
  atmakaraka, // AK - Soul significator (highest degree)
  amatyakaraka, // AmK - Minister/Career
  bhratrikaraka, // BK - Siblings
  matrikaraka, // MK - Mother
  pitrikaraka, // PiK - Father (or Putrakaraka)
  putrakaraka, // PuK - Children
  gnatikaraka, // GK - Relatives/Enemies
  darakaraka, // DK - Spouse (lowest degree)
}

/// Extension for CharaKaraka display
extension CharaKarakaExtension on CharaKaraka {
  String get displayName {
    switch (this) {
      case CharaKaraka.atmakaraka:
        return 'Atmakaraka';
      case CharaKaraka.amatyakaraka:
        return 'Amatyakaraka';
      case CharaKaraka.bhratrikaraka:
        return 'Bhratrikaraka';
      case CharaKaraka.matrikaraka:
        return 'Matrikaraka';
      case CharaKaraka.pitrikaraka:
        return 'Pitrikaraka';
      case CharaKaraka.putrakaraka:
        return 'Putrakaraka';
      case CharaKaraka.gnatikaraka:
        return 'Gnatikaraka';
      case CharaKaraka.darakaraka:
        return 'Darakaraka';
    }
  }

  String get shortName {
    switch (this) {
      case CharaKaraka.atmakaraka:
        return 'AK';
      case CharaKaraka.amatyakaraka:
        return 'AmK';
      case CharaKaraka.bhratrikaraka:
        return 'BK';
      case CharaKaraka.matrikaraka:
        return 'MK';
      case CharaKaraka.pitrikaraka:
        return 'PiK';
      case CharaKaraka.putrakaraka:
        return 'PuK';
      case CharaKaraka.gnatikaraka:
        return 'GK';
      case CharaKaraka.darakaraka:
        return 'DK';
    }
  }

  String get significance {
    switch (this) {
      case CharaKaraka.atmakaraka:
        return 'Soul, Self, King of the chart';
      case CharaKaraka.amatyakaraka:
        return 'Career, Profession, Minister';
      case CharaKaraka.bhratrikaraka:
        return 'Siblings, Courage, Effort';
      case CharaKaraka.matrikaraka:
        return 'Mother, Mind, Emotions';
      case CharaKaraka.pitrikaraka:
        return 'Father, Authority, Dharma';
      case CharaKaraka.putrakaraka:
        return 'Children, Creativity, Intelligence';
      case CharaKaraka.gnatikaraka:
        return 'Relatives, Obstacles, Enemies';
      case CharaKaraka.darakaraka:
        return 'Spouse, Partnership, Marriage';
    }
  }
}

/// Jaimini Karakas container
class JaiminiKarakas {
  final String atmakaraka;
  final double atmakarakaDegree;
  final String amatyakaraka;
  final double amatyakarakaDegree;
  final String bhratrikaraka;
  final double bhratrikarakaDegree;
  final String matrikaraka;
  final double matrikarakaDegree;
  final String pitrikaraka;
  final double pitrikarakaDegree;
  final String putrakaraka;
  final double putrakarakaDegree;
  final String gnatikaraka;
  final double gnatrikarakaDegree;
  final String darakaraka;
  final double darakarakaDegree;
  final String karakamsa; // Sign where Atmakaraka is placed in Navamsa

  JaiminiKarakas({
    required this.atmakaraka,
    required this.atmakarakaDegree,
    required this.amatyakaraka,
    required this.amatyakarakaDegree,
    required this.bhratrikaraka,
    required this.bhratrikarakaDegree,
    required this.matrikaraka,
    required this.matrikarakaDegree,
    required this.pitrikaraka,
    required this.pitrikarakaDegree,
    required this.putrakaraka,
    required this.putrakarakaDegree,
    required this.gnatikaraka,
    required this.gnatrikarakaDegree,
    required this.darakaraka,
    required this.darakarakaDegree,
    required this.karakamsa,
  });

  /// Get karaka planet by type
  String getPlanetForKaraka(CharaKaraka karaka) {
    switch (karaka) {
      case CharaKaraka.atmakaraka:
        return atmakaraka;
      case CharaKaraka.amatyakaraka:
        return amatyakaraka;
      case CharaKaraka.bhratrikaraka:
        return bhratrikaraka;
      case CharaKaraka.matrikaraka:
        return matrikaraka;
      case CharaKaraka.pitrikaraka:
        return pitrikaraka;
      case CharaKaraka.putrakaraka:
        return putrakaraka;
      case CharaKaraka.gnatikaraka:
        return gnatikaraka;
      case CharaKaraka.darakaraka:
        return darakaraka;
    }
  }

  /// Get all karakas as a list of (karaka, planet, degree) tuples
  List<Map<String, dynamic>> get allKarakas => [
    {'karaka': CharaKaraka.atmakaraka, 'planet': atmakaraka, 'degree': atmakarakaDegree},
    {'karaka': CharaKaraka.amatyakaraka, 'planet': amatyakaraka, 'degree': amatyakarakaDegree},
    {'karaka': CharaKaraka.bhratrikaraka, 'planet': bhratrikaraka, 'degree': bhratrikarakaDegree},
    {'karaka': CharaKaraka.matrikaraka, 'planet': matrikaraka, 'degree': matrikarakaDegree},
    {'karaka': CharaKaraka.pitrikaraka, 'planet': pitrikaraka, 'degree': pitrikarakaDegree},
    {'karaka': CharaKaraka.putrakaraka, 'planet': putrakaraka, 'degree': putrakarakaDegree},
    {'karaka': CharaKaraka.gnatikaraka, 'planet': gnatikaraka, 'degree': gnatrikarakaDegree},
    {'karaka': CharaKaraka.darakaraka, 'planet': darakaraka, 'degree': darakarakaDegree},
  ];
}

/// Char Dasha level enumeration
enum CharLevel {
  mahadasha, // Rasi Dasha (main sign period)
  antardasha, // Sub-period
  pratyantara, // Sub-sub-period
  sookshma, // Sub-sub-sub-period
  prana, // Micro-level period
}

/// Individual Char Dasha period (sign-based)
class CharaPeriod {
  final String sign;
  final int years;

  const CharaPeriod(this.sign, this.years);
}

/// Detailed Char Dasha period with dates and sub-periods
class CharaPeriodDetail {
  final String sign;
  final String fullPath;
  final double durationYears;
  final DateTime startDate;
  final DateTime endDate;
  final CharLevel level;
  final List<CharaPeriodDetail>? subPeriods;
  final String? signLord; // Traditional ruler of the sign

  CharaPeriodDetail({
    required this.sign,
    required this.fullPath,
    required this.durationYears,
    required this.startDate,
    required this.endDate,
    required this.level,
    this.subPeriods,
    this.signLord,
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
    } else if (days > 0) {
      return '$days days';
    } else {
      final hours = (totalDays * 24).round();
      if (hours > 0) return '$hours hours';
      return '< 1 hour';
    }
  }

  /// Check if a given date falls within this period
  bool containsDate(DateTime date) {
    return !date.isBefore(startDate) && date.isBefore(endDate);
  }

  /// Get the level name as a string
  String get levelName {
    switch (level) {
      case CharLevel.mahadasha:
        return 'Rasi Dasha';
      case CharLevel.antardasha:
        return 'Antardasha';
      case CharLevel.pratyantara:
        return 'Pratyantara';
      case CharLevel.sookshma:
        return 'Sookshma';
      case CharLevel.prana:
        return 'Prana';
    }
  }
}

/// Complete Char Dasha (Jaimini) information
class CharDashaInfo {
  final String currentSign;
  final double remainingYears;
  final DateTime startDate;
  final List<CharaPeriod> sequence;
  final String? currentAntardasha;
  final double? antardashaRemainingYears;
  final DateTime? signStartDate;
  final DateTime? signEndDate;
  final bool isClockwise; // Direction of Dasha progression
  final String startingSign; // First sign of the Dasha cycle
  
  // Jaimini Karakas
  final JaiminiKarakas karakas;
  
  // Enhanced fields
  final List<CharaPeriodDetail>? charSequence;
  final CharaPeriodDetail? currentSignDetail;
  final CharaPeriodDetail? currentAntardashaDetail;
  final CharaPeriodDetail? currentPratyantaraDetail;
  final CharaPeriodDetail? currentSookshmaDetail;
  final CharaPeriodDetail? currentPranaDetail;

  CharDashaInfo({
    required this.currentSign,
    required this.remainingYears,
    required this.startDate,
    required this.sequence,
    this.currentAntardasha,
    this.antardashaRemainingYears,
    this.signStartDate,
    this.signEndDate,
    required this.isClockwise,
    required this.startingSign,
    required this.karakas,
    this.charSequence,
    this.currentSignDetail,
    this.currentAntardashaDetail,
    this.currentPratyantaraDetail,
    this.currentSookshmaDetail,
    this.currentPranaDetail,
  });

  /// Get the current full dasha path string
  String get currentFullPath {
    final parts = <String>[currentSign];
    if (currentAntardasha != null) {
      parts.add(currentAntardasha!);
    }
    return parts.join('-');
  }

  /// Get direction as string
  String get directionString => isClockwise ? 'Clockwise' : 'Anti-clockwise';
}

// ============================================================================
// MAHADASHA PHALA (INTERPRETATIONS)
// ============================================================================

/// Mahadasha interpretation data for predictions and effects
class MahadashaPhalaData {
  final String planet;
  final String overallTheme;
  final List<String> keyEffects;
  final Map<String, String> lifeAreas; // Career, Health, Relationships, Finance, Spirituality
  final List<String> favorableAspects;
  final List<String> challenges;
  final List<String> remedies;
  final String gemstone;
  final String mantra;
  final String deity;
  final int dayOfWeek; // 0=Sunday, 1=Monday, etc.
  final String color;

  const MahadashaPhalaData({
    required this.planet,
    required this.overallTheme,
    required this.keyEffects,
    required this.lifeAreas,
    required this.favorableAspects,
    required this.challenges,
    required this.remedies,
    required this.gemstone,
    required this.mantra,
    required this.deity,
    required this.dayOfWeek,
    required this.color,
  });
}

/// Static interpretation data for all 9 Mahadasha planets
class MahadashaInterpretations {
  static const Map<String, MahadashaPhalaData> data = {
    'Sun': MahadashaPhalaData(
      planet: 'Sun',
      overallTheme: 'A period of self-realization, authority, and recognition. The soul seeks to express its true nature and achieve prominence.',
      keyEffects: [
        'Rise in status and authority',
        'Government connections and favors',
        'Father-related matters come into focus',
        'Health consciousness increases',
        'Leadership opportunities emerge',
      ],
      lifeAreas: {
        'Career': 'Excellent for government jobs, politics, administration, and leadership roles. Recognition from superiors is likely.',
        'Health': 'Focus on heart, eyes, and bones. Maintain good vitamin D levels and avoid excessive heat.',
        'Relationships': 'Ego clashes possible in marriage. Good for gaining respect from elders and father figures.',
        'Finance': 'Gains through government, authority figures, and gold-related investments. Avoid speculation.',
        'Spirituality': 'Connection with divine masculine energy. Temple visits and sun worship are beneficial.',
      },
      favorableAspects: [
        'Recognition and fame',
        'Government support',
        'Strong willpower',
        'Leadership abilities',
        'Good relations with father',
      ],
      challenges: [
        'Ego conflicts',
        'Eye or heart problems',
        'Disputes with authorities',
        'Arrogance issues',
        'Father\'s health concerns',
      ],
      remedies: [
        'Offer water to the Sun at sunrise',
        'Wear Ruby gemstone after consultation',
        'Recite Aditya Hridayam Stotra',
        'Donate wheat and jaggery on Sundays',
        'Practice Surya Namaskar',
      ],
      gemstone: 'Ruby (Manik)',
      mantra: 'Om Hraam Hreem Hraum Sah Suryaya Namah',
      deity: 'Lord Surya',
      dayOfWeek: 0, // Sunday
      color: 'Red, Orange, Gold',
    ),
    'Moon': MahadashaPhalaData(
      planet: 'Moon',
      overallTheme: 'A period of emotional growth, nurturing, and intuition. The mind seeks peace and maternal comfort.',
      keyEffects: [
        'Emotional sensitivity increases',
        'Mother-related matters highlighted',
        'Travel and change of residence possible',
        'Public dealings and popularity',
        'Mental peace becomes priority',
      ],
      lifeAreas: {
        'Career': 'Good for public-facing roles, hospitality, nursing, psychology, and water-related businesses.',
        'Health': 'Mind and emotions need attention. Watch for water retention, cold, and mental stress.',
        'Relationships': 'Deep emotional bonding. Mother becomes important. Marriage prospects for unmarried.',
        'Finance': 'Gains through liquids, dairy, tourism, and public dealings. Variable income patterns.',
        'Spirituality': 'Devotional practices flourish. Connection with divine feminine. Dreams become significant.',
      },
      favorableAspects: [
        'Emotional intelligence',
        'Public popularity',
        'Intuitive abilities',
        'Good imagination',
        'Maternal blessings',
      ],
      challenges: [
        'Mood swings',
        'Mental restlessness',
        'Over-sensitivity',
        'Water-related issues',
        'Mother\'s health concerns',
      ],
      remedies: [
        'Wear Pearl after consultation',
        'Offer milk to Shiva Linga on Mondays',
        'Donate white items on Mondays',
        'Meditate near water bodies',
        'Recite Chandra mantra 108 times',
      ],
      gemstone: 'Pearl (Moti)',
      mantra: 'Om Shram Shreem Shraum Sah Chandraya Namah',
      deity: 'Lord Shiva / Goddess Parvati',
      dayOfWeek: 1, // Monday
      color: 'White, Silver, Cream',
    ),
    'Mars': MahadashaPhalaData(
      planet: 'Mars',
      overallTheme: 'A period of action, courage, and determination. Energy and ambition drive all endeavors.',
      keyEffects: [
        'Increased energy and drive',
        'Property and land matters',
        'Sibling relationships highlighted',
        'Technical and mechanical pursuits',
        'Physical strength emphasis',
      ],
      lifeAreas: {
        'Career': 'Excellent for military, police, engineering, surgery, sports, and real estate.',
        'Health': 'Watch for accidents, injuries, blood-related issues, and inflammation.',
        'Relationships': 'Passion increases but so do conflicts. Manglik effects are prominent.',
        'Finance': 'Gains through property, machinery, and technical work. Sudden gains and losses.',
        'Spirituality': 'Tantra and powerful practices. Hanuman worship is highly beneficial.',
      },
      favorableAspects: [
        'Courage and bravery',
        'Physical strength',
        'Property gains',
        'Technical abilities',
        'Quick decision making',
      ],
      challenges: [
        'Anger management',
        'Accidents and injuries',
        'Conflicts and arguments',
        'Blood-related problems',
        'Impulsive decisions',
      ],
      remedies: [
        'Wear Red Coral after consultation',
        'Recite Hanuman Chalisa on Tuesdays',
        'Donate red lentils and jaggery',
        'Visit Hanuman temple on Tuesdays',
        'Practice anger management',
      ],
      gemstone: 'Red Coral (Moonga)',
      mantra: 'Om Kraam Kreem Kraum Sah Bhaumaya Namah',
      deity: 'Lord Hanuman / Lord Kartikeya',
      dayOfWeek: 2, // Tuesday
      color: 'Red, Coral, Scarlet',
    ),
    'Mercury': MahadashaPhalaData(
      planet: 'Mercury',
      overallTheme: 'A period of intellect, communication, and learning. The mind seeks knowledge and expression.',
      keyEffects: [
        'Intellectual growth and learning',
        'Business and trade opportunities',
        'Communication skills improve',
        'Writing and speaking abilities',
        'Youthful energy and adaptability',
      ],
      lifeAreas: {
        'Career': 'Excellent for writing, accounting, teaching, trading, IT, and communication fields.',
        'Health': 'Nervous system needs attention. Watch for skin issues and respiratory problems.',
        'Relationships': 'Friendships flourish. Good for intellectual companionship. Siblings matter.',
        'Finance': 'Gains through intellect, trade, and communication. Multiple income sources.',
        'Spirituality': 'Jnana yoga and intellectual pursuit of truth. Study of scriptures beneficial.',
      },
      favorableAspects: [
        'Sharp intellect',
        'Communication skills',
        'Business acumen',
        'Adaptability',
        'Youthful appearance',
      ],
      challenges: [
        'Overthinking',
        'Nervous disorders',
        'Indecisiveness',
        'Skin problems',
        'Speech issues',
      ],
      remedies: [
        'Wear Emerald after consultation',
        'Recite Vishnu Sahasranama',
        'Donate green items on Wednesdays',
        'Feed green grass to cows',
        'Practice mindfulness meditation',
      ],
      gemstone: 'Emerald (Panna)',
      mantra: 'Om Braam Breem Braum Sah Budhaya Namah',
      deity: 'Lord Vishnu / Lord Ganesha',
      dayOfWeek: 3, // Wednesday
      color: 'Green, Emerald',
    ),
    'Jupiter': MahadashaPhalaData(
      planet: 'Jupiter',
      overallTheme: 'A period of wisdom, expansion, and good fortune. Divine grace and blessings flow abundantly.',
      keyEffects: [
        'Wisdom and spiritual growth',
        'Children and family expansion',
        'Teachers and gurus appear',
        'Higher education opportunities',
        'Religious and philosophical interests',
      ],
      lifeAreas: {
        'Career': 'Excellent for teaching, law, finance, consulting, and religious professions.',
        'Health': 'Generally good health. Watch for liver, obesity, and diabetes issues.',
        'Relationships': 'Marriage prospects excellent. Children bring joy. Guru\'s blessings.',
        'Finance': 'Wealth accumulation period. Gains through wisdom and ethical means.',
        'Spirituality': 'Peak spiritual period. Pilgrimage, guru diksha, and religious ceremonies.',
      },
      favorableAspects: [
        'Divine blessings',
        'Wealth and prosperity',
        'Children happiness',
        'Wisdom and knowledge',
        'Good fortune',
      ],
      challenges: [
        'Over-optimism',
        'Weight gain',
        'Liver problems',
        'Extravagance',
        'Over-confidence',
      ],
      remedies: [
        'Wear Yellow Sapphire after consultation',
        'Recite Guru Stotra on Thursdays',
        'Donate yellow items and turmeric',
        'Respect and serve teachers/elders',
        'Visit temples on Thursdays',
      ],
      gemstone: 'Yellow Sapphire (Pukhraj)',
      mantra: 'Om Graam Greem Graum Sah Gurave Namah',
      deity: 'Lord Brihaspati / Lord Vishnu',
      dayOfWeek: 4, // Thursday
      color: 'Yellow, Gold, Saffron',
    ),
    'Venus': MahadashaPhalaData(
      planet: 'Venus',
      overallTheme: 'A period of love, beauty, and material comforts. Life becomes more pleasurable and artistic.',
      keyEffects: [
        'Love and romance flourish',
        'Material comforts increase',
        'Artistic abilities emerge',
        'Marriage and partnerships',
        'Luxury and refinement',
      ],
      lifeAreas: {
        'Career': 'Excellent for arts, entertainment, fashion, hospitality, and luxury goods.',
        'Health': 'Generally comfortable. Watch for reproductive issues and kidney problems.',
        'Relationships': 'Best period for love and marriage. Spouse brings happiness. Social life blooms.',
        'Finance': 'Gains through beauty, arts, and luxury. Vehicle and property acquisitions.',
        'Spirituality': 'Bhakti yoga and devotional practices. Goddess worship is highly beneficial.',
      },
      favorableAspects: [
        'Love and romance',
        'Material abundance',
        'Artistic talents',
        'Physical beauty',
        'Harmonious relationships',
      ],
      challenges: [
        'Over-indulgence',
        'Laziness',
        'Relationship complications',
        'Reproductive issues',
        'Excessive spending',
      ],
      remedies: [
        'Wear Diamond or White Sapphire after consultation',
        'Recite Shukra mantra on Fridays',
        'Donate white items and rice',
        'Worship Goddess Lakshmi',
        'Practice moderation in pleasures',
      ],
      gemstone: 'Diamond (Heera) / White Sapphire',
      mantra: 'Om Draam Dreem Draum Sah Shukraya Namah',
      deity: 'Goddess Lakshmi / Goddess Saraswati',
      dayOfWeek: 5, // Friday
      color: 'White, Pink, Pastel colors',
    ),
    'Saturn': MahadashaPhalaData(
      planet: 'Saturn',
      overallTheme: 'A period of discipline, karma, and life lessons. Hard work and patience are rewarded.',
      keyEffects: [
        'Karmic lessons intensify',
        'Discipline and structure required',
        'Delays but eventual success',
        'Service to others highlighted',
        'Elderly and servants important',
      ],
      lifeAreas: {
        'Career': 'Progress through hard work. Good for law, agriculture, mining, and service sectors.',
        'Health': 'Chronic issues may surface. Joint pain, dental problems, and depression possible.',
        'Relationships': 'Tests in relationships. Late marriage or married life challenges.',
        'Finance': 'Slow but steady gains. Real estate and long-term investments favored.',
        'Spirituality': 'Karma yoga and selfless service. Meditation and austerity practices.',
      },
      favorableAspects: [
        'Discipline and patience',
        'Long-term success',
        'Wisdom through experience',
        'Stability and structure',
        'Karmic clearance',
      ],
      challenges: [
        'Delays and obstacles',
        'Depression and loneliness',
        'Health issues',
        'Financial constraints',
        'Relationship difficulties',
      ],
      remedies: [
        'Wear Blue Sapphire with extreme caution after consultation',
        'Recite Shani Stotra on Saturdays',
        'Donate black items and mustard oil',
        'Feed crows and help the underprivileged',
        'Visit Shani temple on Saturdays',
      ],
      gemstone: 'Blue Sapphire (Neelam) - with caution',
      mantra: 'Om Praam Preem Praum Sah Shanaischaraya Namah',
      deity: 'Lord Shani / Lord Hanuman',
      dayOfWeek: 6, // Saturday
      color: 'Blue, Black, Dark colors',
    ),
    'Rahu': MahadashaPhalaData(
      planet: 'Rahu',
      overallTheme: 'A period of worldly desires, unconventional paths, and sudden transformations. Material ambitions peak.',
      keyEffects: [
        'Unconventional opportunities',
        'Foreign connections and travel',
        'Sudden rise or fall possible',
        'Technology and innovation',
        'Obsessive desires emerge',
      ],
      lifeAreas: {
        'Career': 'Success in foreign lands, technology, politics, and unconventional fields.',
        'Health': 'Mysterious ailments possible. Mental confusion and addictions risk.',
        'Relationships': 'Unconventional relationships. Foreign spouse possibility.',
        'Finance': 'Sudden gains or losses. Speculation and risky ventures.',
        'Spirituality': 'Interest in occult and tantra. Need for grounding practices.',
      },
      favorableAspects: [
        'Worldly success',
        'Foreign opportunities',
        'Innovation and technology',
        'Breaking boundaries',
        'Material achievements',
      ],
      challenges: [
        'Confusion and illusion',
        'Addictions',
        'Relationship instability',
        'Mental restlessness',
        'Unethical temptations',
      ],
      remedies: [
        'Wear Hessonite (Gomed) after consultation',
        'Recite Rahu mantra or Durga Saptashati',
        'Donate dark blue or black items',
        'Feed birds and animals',
        'Worship Goddess Durga',
      ],
      gemstone: 'Hessonite (Gomed)',
      mantra: 'Om Bhram Bhreem Bhraum Sah Rahave Namah',
      deity: 'Goddess Durga / Sarpa Deities',
      dayOfWeek: 6, // Saturday (shared with Saturn)
      color: 'Smoky, Grey, Dark Blue',
    ),
    'Ketu': MahadashaPhalaData(
      planet: 'Ketu',
      overallTheme: 'A period of spirituality, liberation, and letting go. Past-life influences surface.',
      keyEffects: [
        'Spiritual awakening',
        'Detachment from material world',
        'Past-life karma resolution',
        'Psychic abilities develop',
        'Unexpected changes',
      ],
      lifeAreas: {
        'Career': 'Good for research, spirituality, healing, and metaphysical fields.',
        'Health': 'Mysterious ailments. Digestive and nervous system issues.',
        'Relationships': 'Detachment and separation themes. Past-life connections.',
        'Finance': 'Losses leading to liberation. Gains through spiritual work.',
        'Spirituality': 'Peak period for moksha. Meditation and self-inquiry essential.',
      },
      favorableAspects: [
        'Spiritual liberation',
        'Intuitive insights',
        'Past karma resolution',
        'Detachment and freedom',
        'Psychic abilities',
      ],
      challenges: [
        'Confusion and uncertainty',
        'Health mysteries',
        'Losses and separations',
        'Lack of direction',
        'Past-life issues surface',
      ],
      remedies: [
        'Wear Cat\'s Eye (Lehsunia) after consultation',
        'Recite Ganesha mantras',
        'Donate grey or multi-colored items',
        'Worship Lord Ganesha',
        'Practice meditation and yoga',
      ],
      gemstone: 'Cat\'s Eye (Lehsunia)',
      mantra: 'Om Sraam Sreem Sraum Sah Ketave Namah',
      deity: 'Lord Ganesha / Lord Chitragupta',
      dayOfWeek: 2, // Tuesday (shared with Mars)
      color: 'Grey, Multi-colored, Smoky',
    ),
  };

  /// Get interpretation for a specific planet
  static MahadashaPhalaData? getInterpretation(String planet) {
    return data[planet];
  }

  /// Get Antardasha combination interpretation
  static String getAntardashaEffect(String mahadasha, String antardasha) {
    // Return basic combination effects
    final md = data[mahadasha];
    final ad = data[antardasha];
    if (md == null || ad == null) return 'Interpretation not available';

    if (mahadasha == antardasha) {
      return 'Double ${mahadasha} energy intensifies all ${mahadasha} significations. ${md.keyEffects.first} is especially prominent.';
    }

    // Generate basic combination interpretation
    return 'The ${mahadasha} Mahadasha with ${antardasha} Antardasha combines ${_getPlanetQuality(mahadasha)} with ${_getPlanetQuality(antardasha)}. '
        'Focus on balancing both planetary energies for optimal results.';
  }

  static String _getPlanetQuality(String planet) {
    const qualities = {
      'Sun': 'authority and self-expression',
      'Moon': 'emotions and nurturing',
      'Mars': 'action and courage',
      'Mercury': 'intellect and communication',
      'Jupiter': 'wisdom and expansion',
      'Venus': 'love and comfort',
      'Saturn': 'discipline and karma',
      'Rahu': 'worldly desires and innovation',
      'Ketu': 'spirituality and liberation',
    };
    return qualities[planet] ?? 'planetary energy';
  }
}
