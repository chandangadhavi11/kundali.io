import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sweph/sweph.dart';

/// Custom asset loader using Flutter's rootBundle
class FlutterAssetLoader with AssetLoader {
  @override
  Future<Uint8List> load(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      return byteData.buffer.asUint8List();
    } catch (e) {
      debugPrint('SwephService: Failed to load asset $assetPath: $e');
      rethrow;
    }
  }
}

/// Service for Swiss Ephemeris calculations using the sweph package.
/// This service provides accurate planetary positions for Vedic astrology (Kundli).
class SwephService {
  static SwephService? _instance;
  static bool _isInitialized = false;
  static bool _nativeLibraryAvailable = false;

  SwephService._();

  /// Get the singleton instance of SwephService
  static SwephService get instance {
    _instance ??= SwephService._();
    return _instance!;
  }

  /// Check if the service is initialized
  static bool get isInitialized => _isInitialized;

  /// Check if native library is available (false in unit tests)
  static bool get nativeLibraryAvailable => _nativeLibraryAvailable;

  /// Initialize the Swiss Ephemeris library with bundled ephemeris files.
  /// This must be called once at app startup.
  static Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('SwephService: Already initialized');
      return;
    }

    debugPrint('SwephService: Starting initialization...');

    try {
      // Get the application documents directory for ephemeris file caching
      final appDocDir = await getApplicationDocumentsDirectory();
      final epheFilesPath = '${appDocDir.path}/sweph_ephe';
      debugPrint('SwephService: Ephemeris path: $epheFilesPath');

      await Sweph.init(
        epheAssets: [
          "packages/sweph/assets/ephe/seas_18.se1",
          "packages/sweph/assets/ephe/semo_18.se1",
          "packages/sweph/assets/ephe/sepl_18.se1",
          "packages/sweph/assets/ephe/sefstars.txt",
        ],
        assetLoader: FlutterAssetLoader(),
        epheFilesPath: epheFilesPath,
      );

      _isInitialized = true;
      _nativeLibraryAvailable = true;
      debugPrint('SwephService: ✅ Initialized successfully with Swiss Ephemeris!');
    } catch (e) {
      debugPrint('SwephService: ❌ Failed to initialize: $e');
      _isInitialized = true;
      _nativeLibraryAvailable = false;
    }
  }

  /// Calculate planetary positions for a given birth date, time, and location.
  KundliCalculationResult calculateKundli({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    required double timezoneOffsetHours,
    bool useAyanamsa = true,
  }) {
    debugPrint('SwephService: ========== CALCULATING KUNDLI ==========');
    debugPrint('SwephService: Birth: $birthDateTime');
    debugPrint('SwephService: Location: $latitude, $longitude');
    debugPrint('SwephService: Timezone: $timezoneOffsetHours hours');

    // Step 1: Convert local time to UT (Universal Time)
    final double hourDecimal = birthDateTime.hour +
        birthDateTime.minute / 60.0 +
        birthDateTime.second / 3600.0;

    // Calculate Julian Day in local time first
    final double julianDayLocal = Sweph.swe_julday(
      birthDateTime.year,
      birthDateTime.month,
      birthDateTime.day,
      hourDecimal,
      CalendarType.SE_GREG_CAL,
    );

    // Adjust for timezone to get UT (subtract timezone offset)
    final double julianDayUT = julianDayLocal - (timezoneOffsetHours / 24.0);
    debugPrint('SwephService: Julian Day UT: $julianDayUT');

    // Step 2: Set Ayanamsa for Vedic calculations (Lahiri)
    if (useAyanamsa) {
      Sweph.swe_set_sid_mode(
        SiderealMode.SE_SIDM_LAHIRI,
        SiderealModeFlag.SE_SIDBIT_NONE,
        0,
        0,
      );
    }

    // Step 3: Get Ayanamsa value
    final double ayanamsaValue = useAyanamsa
        ? Sweph.swe_get_ayanamsa_ut(julianDayUT)
        : 0.0;
    debugPrint('SwephService: Ayanamsa (Lahiri): ${ayanamsaValue.toStringAsFixed(4)}°');

    // Step 4: Calculate houses (TROPICAL first, then convert to sidereal)
    // Using Placidus for house cusps calculation
    final housesData = Sweph.swe_houses(julianDayUT, latitude, longitude, Hsys.P);

    // Get tropical ascendant
    final double tropicalAscendant = housesData.ascmc[AscmcIndex.SE_ASC.index];
    final double tropicalMC = housesData.ascmc[AscmcIndex.SE_MC.index];

    debugPrint('SwephService: Tropical Ascendant: ${tropicalAscendant.toStringAsFixed(2)}°');

    // Convert ascendant to sidereal
    final double siderealAscendant = _normalizeDegree(tropicalAscendant - ayanamsaValue);
    final double siderealMC = _normalizeDegree(tropicalMC - ayanamsaValue);

    debugPrint('SwephService: Sidereal Ascendant: ${siderealAscendant.toStringAsFixed(2)}° (${getSignName(siderealAscendant)})');

    // For Vedic astrology, use WHOLE SIGN houses
    // House 1 starts at 0° of the ascendant sign
    final int ascendantSignIndex = getSignIndex(siderealAscendant);
    final List<double> siderealHouseCusps = List.generate(12, (i) {
      return ((ascendantSignIndex + i) % 12) * 30.0;
    });

    debugPrint('SwephService: House cusps (whole sign): ${siderealHouseCusps.map((h) => getSignName(h)).join(', ')}');

    // Step 5: Calculate planetary positions (TROPICAL, then convert)
    final Map<String, PlanetaryPosition> planets = {};

    // Calculate flags - use Swiss Ephemeris with speed
    final SwephFlag calcFlag = SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED;

    // Sun
    planets['Sun'] = _calculatePlanet(HeavenlyBody.SE_SUN, julianDayUT, calcFlag, ayanamsaValue);
    // Moon
    planets['Moon'] = _calculatePlanet(HeavenlyBody.SE_MOON, julianDayUT, calcFlag, ayanamsaValue);
    // Mars
    planets['Mars'] = _calculatePlanet(HeavenlyBody.SE_MARS, julianDayUT, calcFlag, ayanamsaValue);
    // Mercury
    planets['Mercury'] = _calculatePlanet(HeavenlyBody.SE_MERCURY, julianDayUT, calcFlag, ayanamsaValue);
    // Jupiter
    planets['Jupiter'] = _calculatePlanet(HeavenlyBody.SE_JUPITER, julianDayUT, calcFlag, ayanamsaValue);
    // Venus
    planets['Venus'] = _calculatePlanet(HeavenlyBody.SE_VENUS, julianDayUT, calcFlag, ayanamsaValue);
    // Saturn
    planets['Saturn'] = _calculatePlanet(HeavenlyBody.SE_SATURN, julianDayUT, calcFlag, ayanamsaValue);
    // Rahu (True Node)
    planets['Rahu'] = _calculatePlanet(HeavenlyBody.SE_TRUE_NODE, julianDayUT, calcFlag, ayanamsaValue);

    // Ketu is 180° opposite to Rahu
    final rahuPos = planets['Rahu']!;
    planets['Ketu'] = PlanetaryPosition(
      longitude: _normalizeDegree(rahuPos.longitude + 180.0),
      latitude: -rahuPos.latitude,
      distance: rahuPos.distance,
      speedLongitude: rahuPos.speedLongitude,
      speedLatitude: rahuPos.speedLatitude,
      isRetrograde: true, // Rahu/Ketu always retrograde in Vedic
    );

    // Log all planetary positions
    debugPrint('SwephService: === PLANETARY POSITIONS ===');
    for (final entry in planets.entries) {
      final p = entry.value;
      final house = _getPlanetHouseWholeSign(p.longitude, ascendantSignIndex);
      debugPrint('SwephService: ${entry.key}: ${p.longitude.toStringAsFixed(2)}° = ${p.signName} ${p.degreeInSign.toStringAsFixed(2)}° | House $house ${p.isRetrograde ? "(R)" : ""}');
    }

    return KundliCalculationResult(
      julianDay: julianDayUT,
      planets: planets,
      houses: siderealHouseCusps,
      ascendant: siderealAscendant,
      mc: siderealMC,
      ayanamsa: ayanamsaValue,
      calculatedAt: DateTime.now(),
    );
  }

  /// Calculate position of a single planet (returns SIDEREAL position)
  PlanetaryPosition _calculatePlanet(
    HeavenlyBody body,
    double julianDay,
    SwephFlag flags,
    double ayanamsa,
  ) {
    try {
      // Get tropical position
      final result = Sweph.swe_calc_ut(julianDay, body, flags);

      // Convert to sidereal by subtracting ayanamsa
      final siderealLongitude = _normalizeDegree(result.longitude - ayanamsa);

      return PlanetaryPosition(
        longitude: siderealLongitude,
        latitude: result.latitude,
        distance: result.distance,
        speedLongitude: result.speedInLongitude,
        speedLatitude: result.speedInLatitude,
        isRetrograde: result.speedInLongitude < 0,
      );
    } catch (e) {
      debugPrint('SwephService: Error calculating planet: $e');
      return PlanetaryPosition(
        longitude: 0,
        latitude: 0,
        distance: 0,
        speedLongitude: 0,
        speedLatitude: 0,
        isRetrograde: false,
      );
    }
  }

  /// Get house number for a planet using WHOLE SIGN system
  static int _getPlanetHouseWholeSign(double planetLongitude, int ascendantSignIndex) {
    final planetSignIndex = getSignIndex(planetLongitude);
    // House = (planet sign - ascendant sign + 12) % 12 + 1
    return ((planetSignIndex - ascendantSignIndex + 12) % 12) + 1;
  }

  /// Normalize degree to 0-360 range
  double _normalizeDegree(double degree) {
    double normalized = degree % 360.0;
    if (normalized < 0) normalized += 360.0;
    return normalized;
  }

  /// Get zodiac sign from longitude (0-11 index)
  static int getSignIndex(double longitude) {
    double normalized = longitude % 360.0;
    if (normalized < 0) normalized += 360.0;
    return (normalized / 30.0).floor() % 12;
  }

  /// Get zodiac sign name from longitude
  static String getSignName(double longitude) {
    const signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer',
      'Leo', 'Virgo', 'Libra', 'Scorpio',
      'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    return signs[getSignIndex(longitude)];
  }

  /// Get degree within sign (0-30)
  static double getDegreeInSign(double longitude) {
    double normalized = longitude % 360.0;
    if (normalized < 0) normalized += 360.0;
    return normalized % 30.0;
  }

  /// Get nakshatra (lunar mansion) from longitude
  static NakshatraInfo getNakshatra(double longitude) {
    const nakshatras = [
      'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira',
      'Ardra', 'Punarvasu', 'Pushya', 'Ashlesha', 'Magha',
      'Purva Phalguni', 'Uttara Phalguni', 'Hasta', 'Chitra', 'Swati',
      'Vishakha', 'Anuradha', 'Jyeshtha', 'Mula', 'Purva Ashadha',
      'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha',
      'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
    ];

    double normalized = longitude % 360.0;
    if (normalized < 0) normalized += 360.0;

    const nakshatraSpan = 360.0 / 27.0; // 13.333...°
    final nakshatraIndex = (normalized / nakshatraSpan).floor() % 27;

    const padaSpan = nakshatraSpan / 4.0; // 3.333...°
    final degreeInNakshatra = normalized % nakshatraSpan;
    final pada = (degreeInNakshatra / padaSpan).floor() + 1;

    return NakshatraInfo(
      name: nakshatras[nakshatraIndex],
      index: nakshatraIndex,
      pada: pada,
      degreeInNakshatra: degreeInNakshatra,
    );
  }

  /// Calculate which house a planet is in (Whole Sign system)
  static int getPlanetHouse(double planetLongitude, List<double> houseCusps) {
    // For whole sign houses, find which sign the planet is in
    // and match it to the house cusp signs
    final planetSignIndex = getSignIndex(planetLongitude);

    for (int i = 0; i < 12; i++) {
      final houseSignIndex = getSignIndex(houseCusps[i]);
      if (houseSignIndex == planetSignIndex) {
        return i + 1;
      }
    }
    return 1;
  }

  /// Parse timezone string to offset in hours
  static double parseTimezoneOffset(String timezone) {
    final tzAbbreviations = {
      'IST': 5.5,
      'UTC': 0.0,
      'GMT': 0.0,
      'EST': -5.0,
      'EDT': -4.0,
      'CST': -6.0,
      'CDT': -5.0,
      'MST': -7.0,
      'MDT': -6.0,
      'PST': -8.0,
      'PDT': -7.0,
      'CET': 1.0,
      'CEST': 2.0,
      'JST': 9.0,
      'AEST': 10.0,
      'AEDT': 11.0,
    };

    final upperTimezone = timezone.toUpperCase().trim();
    if (tzAbbreviations.containsKey(upperTimezone)) {
      return tzAbbreviations[upperTimezone]!;
    }

    String numericPart = timezone;
    if (timezone.toUpperCase().startsWith('UTC')) {
      numericPart = timezone.substring(3);
    } else if (timezone.toUpperCase().startsWith('GMT')) {
      numericPart = timezone.substring(3);
    }

    final colonMatch = RegExp(r'([+-]?)(\d{1,2}):(\d{2})').firstMatch(numericPart);
    if (colonMatch != null) {
      final sign = colonMatch.group(1) == '-' ? -1.0 : 1.0;
      final hours = double.parse(colonMatch.group(2)!);
      final minutes = double.parse(colonMatch.group(3)!);
      return sign * (hours + minutes / 60.0);
    }

    final decimalMatch = RegExp(r'([+-]?)(\d+\.?\d*)').firstMatch(numericPart);
    if (decimalMatch != null) {
      final sign = decimalMatch.group(1) == '-' ? -1.0 : 1.0;
      return sign * double.parse(decimalMatch.group(2)!);
    }

    return 0.0;
  }
}

/// Result of planetary position calculation
class PlanetaryPosition {
  final double longitude;
  final double latitude;
  final double distance;
  final double speedLongitude;
  final double speedLatitude;
  final bool isRetrograde;

  PlanetaryPosition({
    required this.longitude,
    required this.latitude,
    required this.distance,
    required this.speedLongitude,
    required this.speedLatitude,
    required this.isRetrograde,
  });

  String get signName => SwephService.getSignName(longitude);
  int get signIndex => SwephService.getSignIndex(longitude);
  double get degreeInSign => SwephService.getDegreeInSign(longitude);

  @override
  String toString() {
    final retro = isRetrograde ? ' (R)' : '';
    return '$signName ${degreeInSign.toStringAsFixed(2)}°$retro';
  }
}

/// Complete Kundli calculation result
class KundliCalculationResult {
  final double julianDay;
  final Map<String, PlanetaryPosition> planets;
  final List<double> houses;
  final double ascendant;
  final double mc;
  final double ayanamsa;
  final DateTime calculatedAt;

  KundliCalculationResult({
    required this.julianDay,
    required this.planets,
    required this.houses,
    required this.ascendant,
    required this.mc,
    required this.ayanamsa,
    required this.calculatedAt,
  });

  String get ascendantSign => SwephService.getSignName(ascendant);
  double get ascendantDegreeInSign => SwephService.getDegreeInSign(ascendant);

  NakshatraInfo get moonNakshatra {
    final moon = planets['Moon'];
    if (moon == null) {
      return NakshatraInfo(name: 'Unknown', index: 0, pada: 1, degreeInNakshatra: 0);
    }
    return SwephService.getNakshatra(moon.longitude);
  }
}

/// Nakshatra information
class NakshatraInfo {
  final String name;
  final int index;
  final int pada;
  final double degreeInNakshatra;

  NakshatraInfo({
    required this.name,
    required this.index,
    required this.pada,
    required this.degreeInNakshatra,
  });

  @override
  String toString() => '$name Pada $pada';
}
