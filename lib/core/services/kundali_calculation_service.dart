import 'dart:math' as math;

/// Service for astronomical and astrological calculations
class KundaliCalculationService {
  // Ayanamsha constants
  static const double lahiriAyanamsha2024 = 24.1567; // Degrees for 2024
  static const double ayanamshaYearlyRate = 0.01396; // Degrees per year

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

  /// Calculate Julian Day Number
  static double calculateJulianDay(DateTime dateTime) {
    int year = dateTime.year;
    int month = dateTime.month;
    int day = dateTime.day;
    double hour =
        dateTime.hour + dateTime.minute / 60.0 + dateTime.second / 3600.0;

    if (month <= 2) {
      year -= 1;
      month += 12;
    }

    int a = (year / 100).floor();
    int b = 2 - a + (a / 4).floor();

    double jd =
        (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524.5 +
        hour / 24.0;

    return jd;
  }

  /// Calculate Local Sidereal Time
  static double calculateLocalSiderealTime(double jd, double longitude) {
    double t = (jd - 2451545.0) / 36525.0;
    double gmst =
        280.46061837 +
        360.98564736629 * (jd - 2451545.0) +
        0.000387933 * t * t -
        t * t * t / 38710000.0;

    gmst = gmst % 360;
    if (gmst < 0) gmst += 360;

    double lst = gmst + longitude;
    lst = lst % 360;
    if (lst < 0) lst += 360;

    return lst;
  }

  /// Calculate Ayanamsha for a given date
  static double calculateAyanamsha(DateTime dateTime) {
    int yearDiff = dateTime.year - 2024;
    return lahiriAyanamsha2024 + (yearDiff * ayanamshaYearlyRate);
  }

  /// Calculate planetary positions (simplified ephemeris)
  static Map<String, PlanetPosition> calculatePlanetaryPositions(
    DateTime birthDateTime,
    double latitude,
    double longitude,
  ) {
    double jd = calculateJulianDay(birthDateTime);
    double ayanamsha = calculateAyanamsha(birthDateTime);
    Map<String, PlanetPosition> positions = {};

    // Simplified planetary calculations (in real app, use Swiss Ephemeris or similar)
    // These are approximations for demonstration

    // Sun position (approximate)
    double sunLongitude = _calculateSunPosition(jd);
    sunLongitude = (sunLongitude - ayanamsha) % 360;
    if (sunLongitude < 0) sunLongitude += 360;
    positions['Sun'] = PlanetPosition(
      planet: 'Sun',
      longitude: sunLongitude,
      sign: _getZodiacSign(sunLongitude),
      signDegree: sunLongitude % 30,
      nakshatra: _getNakshatra(sunLongitude),
      house: 1, // Will be calculated based on ascendant
    );

    // Moon position (approximate)
    double moonLongitude = _calculateMoonPosition(jd);
    moonLongitude = (moonLongitude - ayanamsha) % 360;
    if (moonLongitude < 0) moonLongitude += 360;
    positions['Moon'] = PlanetPosition(
      planet: 'Moon',
      longitude: moonLongitude,
      sign: _getZodiacSign(moonLongitude),
      signDegree: moonLongitude % 30,
      nakshatra: _getNakshatra(moonLongitude),
      house: 1,
    );

    // Other planets (simplified calculations)
    positions['Mars'] = _calculatePlanetPosition('Mars', jd, ayanamsha);
    positions['Mercury'] = _calculatePlanetPosition('Mercury', jd, ayanamsha);
    positions['Jupiter'] = _calculatePlanetPosition('Jupiter', jd, ayanamsha);
    positions['Venus'] = _calculatePlanetPosition('Venus', jd, ayanamsha);
    positions['Saturn'] = _calculatePlanetPosition('Saturn', jd, ayanamsha);

    // Rahu and Ketu (Moon's nodes)
    double rahuLongitude = _calculateRahuPosition(jd);
    rahuLongitude = (rahuLongitude - ayanamsha) % 360;
    if (rahuLongitude < 0) rahuLongitude += 360;
    positions['Rahu'] = PlanetPosition(
      planet: 'Rahu',
      longitude: rahuLongitude,
      sign: _getZodiacSign(rahuLongitude),
      signDegree: rahuLongitude % 30,
      nakshatra: _getNakshatra(rahuLongitude),
      house: 1,
    );

    // Ketu is always 180 degrees opposite to Rahu
    double ketuLongitude = (rahuLongitude + 180) % 360;
    positions['Ketu'] = PlanetPosition(
      planet: 'Ketu',
      longitude: ketuLongitude,
      sign: _getZodiacSign(ketuLongitude),
      signDegree: ketuLongitude % 30,
      nakshatra: _getNakshatra(ketuLongitude),
      house: 1,
    );

    return positions;
  }

  /// Calculate Ascendant (Lagna)
  static AscendantInfo calculateAscendant(
    DateTime birthDateTime,
    double latitude,
    double longitude,
  ) {
    double jd = calculateJulianDay(birthDateTime);
    double lst = calculateLocalSiderealTime(jd, longitude);
    double ayanamsha = calculateAyanamsha(birthDateTime);

    // Simplified ascendant calculation
    // In reality, this requires complex trigonometric calculations
    // double eclipticObliquity = 23.4397; // Not used in simplified calculation
    double ascendantLongitude = lst;

    // Apply corrections based on latitude
    double correction =
        math.atan(
          math.tan(latitude * math.pi / 180) *
              math.sin(ascendantLongitude * math.pi / 180),
        ) *
        180 /
        math.pi;
    ascendantLongitude = (ascendantLongitude + correction - ayanamsha) % 360;
    if (ascendantLongitude < 0) ascendantLongitude += 360;

    return AscendantInfo(
      longitude: ascendantLongitude,
      sign: _getZodiacSign(ascendantLongitude),
      signDegree: ascendantLongitude % 30,
      nakshatra: _getNakshatra(ascendantLongitude),
    );
  }

  /// Calculate houses based on ascendant
  static List<House> calculateHouses(double ascendantLongitude) {
    List<House> houses = [];

    for (int i = 0; i < 12; i++) {
      double houseCusp = (ascendantLongitude + (i * 30)) % 360;
      houses.add(
        House(
          number: i + 1,
          sign: _getZodiacSign(houseCusp),
          cuspDegree: houseCusp,
          planets: [], // Will be filled later
        ),
      );
    }

    return houses;
  }

  /// Assign planets to houses
  static void assignPlanetsToHouses(
    List<House> houses,
    Map<String, PlanetPosition> planets,
    double ascendantLongitude,
  ) {
    for (var planet in planets.values) {
      // Calculate which house the planet falls in
      double relativePosition = (planet.longitude - ascendantLongitude) % 360;
      if (relativePosition < 0) relativePosition += 360;

      int houseNumber = (relativePosition / 30).floor() + 1;
      if (houseNumber > 12) houseNumber = 1;

      planet.house = houseNumber;
      houses[houseNumber - 1].planets.add(planet.planet);
    }
  }

  /// Calculate Vimshottari Dasha
  static DashaInfo calculateVimshottariDasha(
    DateTime birthDateTime,
    double moonLongitude,
  ) {
    // Vimshottari Dasha sequence and durations
    final dashaSequence = [
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

    // Find birth nakshatra and calculate dasha
    String nakshatra = _getNakshatra(moonLongitude);
    int nakshatraIndex = nakshatras.indexOf(nakshatra);

    // Each nakshatra is ruled by a planet in sequence
    int dashaStartIndex = (nakshatraIndex ~/ 3) % 9;

    // Calculate elapsed portion of current nakshatra
    double nakshatraDegree = (moonLongitude % 360) * 27 / 360;
    double elapsedPortion = nakshatraDegree % 1;

    // Calculate remaining years in birth dasha
    double remainingYears =
        dashaSequence[dashaStartIndex].years * (1 - elapsedPortion);

    return DashaInfo(
      currentMahadasha: dashaSequence[dashaStartIndex].planet,
      remainingYears: remainingYears,
      startDate: birthDateTime,
      sequence: dashaSequence,
    );
  }

  // Helper methods

  static double _calculateSunPosition(double jd) {
    double d = jd - 2451545.0;
    double g = (357.529 + 0.98560028 * d) % 360;
    double q = (280.459 + 0.98564736 * d) % 360;
    double l =
        q +
        1.915 * math.sin(g * math.pi / 180) +
        0.020 * math.sin(2 * g * math.pi / 180);
    return l % 360;
  }

  static double _calculateMoonPosition(double jd) {
    double d = jd - 2451545.0;
    double l = (218.316 + 13.176396 * d) % 360;
    double m = (134.963 + 13.064993 * d) % 360;
    // double f = (93.272 + 13.229350 * d) % 360; // Not used in simplified calculation

    double longitude = l + 6.289 * math.sin(m * math.pi / 180);
    return longitude % 360;
  }

  static PlanetPosition _calculatePlanetPosition(
    String planet,
    double jd,
    double ayanamsha,
  ) {
    // Simplified orbital calculations for demonstration
    // In production, use precise ephemeris data
    Map<String, double> orbitalPeriods = {
      'Mercury': 87.97,
      'Venus': 224.70,
      'Mars': 686.98,
      'Jupiter': 4332.59,
      'Saturn': 10759.22,
    };

    double d = jd - 2451545.0;
    double period = orbitalPeriods[planet] ?? 365.25;
    double meanAnomaly = (360 / period) * d;
    double longitude = (meanAnomaly + _getPlanetOffset(planet)) % 360;

    longitude = (longitude - ayanamsha) % 360;
    if (longitude < 0) longitude += 360;

    return PlanetPosition(
      planet: planet,
      longitude: longitude,
      sign: _getZodiacSign(longitude),
      signDegree: longitude % 30,
      nakshatra: _getNakshatra(longitude),
      house: 1,
    );
  }

  static double _calculateRahuPosition(double jd) {
    double d = jd - 2451545.0;
    double longitude = (125.04 - 0.052954 * d) % 360;
    if (longitude < 0) longitude += 360;
    return longitude;
  }

  static double _getPlanetOffset(String planet) {
    // Base offsets for planets (simplified)
    Map<String, double> offsets = {
      'Mercury': 48.33,
      'Venus': 76.68,
      'Mars': 49.56,
      'Jupiter': 100.46,
      'Saturn': 113.67,
    };
    return offsets[planet] ?? 0;
  }

  static String _getZodiacSign(double longitude) {
    int signIndex = (longitude / 30).floor();
    return zodiacSigns[signIndex % 12];
  }

  static String _getNakshatra(double longitude) {
    double nakshatraDegree = longitude * 27 / 360;
    int nakshatraIndex = nakshatraDegree.floor();
    return nakshatras[nakshatraIndex % 27];
  }

  /// Calculate Navamsa (D9) chart positions
  static Map<String, PlanetPosition> calculateNavamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    Map<String, PlanetPosition> navamsaChart = {};

    for (var entry in birthChart.entries) {
      String planet = entry.key;
      PlanetPosition position = entry.value;

      // Calculate Navamsa position
      // Each sign is divided into 9 parts of 3°20' each
      double navamsaDegree = position.longitude * 9;
      navamsaDegree = navamsaDegree % 360;

      navamsaChart[planet] = PlanetPosition(
        planet: planet,
        longitude: navamsaDegree,
        sign: _getZodiacSign(navamsaDegree),
        signDegree: navamsaDegree % 30,
        nakshatra: _getNakshatra(navamsaDegree),
        house: 1, // Will be recalculated
      );
    }

    return navamsaChart;
  }

  /// Calculate Chandra (Moon) chart - houses based on Moon sign
  static List<House> calculateChandraChart(
    Map<String, PlanetPosition> planetPositions,
  ) {
    final moonPosition = planetPositions['Moon']!;
    final moonSignIndex = zodiacSigns.indexOf(moonPosition.sign);
    final moonLongitude = moonSignIndex * 30.0;
    
    List<House> houses = [];
    for (int i = 0; i < 12; i++) {
      double houseCusp = (moonLongitude + (i * 30)) % 360;
      houses.add(House(
        number: i + 1,
        sign: _getZodiacSign(houseCusp),
        cuspDegree: houseCusp,
        planets: [],
      ));
    }
    
    // Assign planets to houses based on Moon
    for (var planet in planetPositions.values) {
      double relativePosition = (planet.longitude - moonLongitude) % 360;
      if (relativePosition < 0) relativePosition += 360;
      int houseNumber = (relativePosition / 30).floor() + 1;
      if (houseNumber > 12) houseNumber = 1;
      houses[houseNumber - 1].planets.add(planet.planet);
    }
    
    return houses;
  }

  /// Calculate Surya (Sun) chart - houses based on Sun sign
  static List<House> calculateSuryaChart(
    Map<String, PlanetPosition> planetPositions,
  ) {
    final sunPosition = planetPositions['Sun']!;
    final sunSignIndex = zodiacSigns.indexOf(sunPosition.sign);
    final sunLongitude = sunSignIndex * 30.0;
    
    List<House> houses = [];
    for (int i = 0; i < 12; i++) {
      double houseCusp = (sunLongitude + (i * 30)) % 360;
      houses.add(House(
        number: i + 1,
        sign: _getZodiacSign(houseCusp),
        cuspDegree: houseCusp,
        planets: [],
      ));
    }
    
    // Assign planets to houses based on Sun
    for (var planet in planetPositions.values) {
      double relativePosition = (planet.longitude - sunLongitude) % 360;
      if (relativePosition < 0) relativePosition += 360;
      int houseNumber = (relativePosition / 30).floor() + 1;
      if (houseNumber > 12) houseNumber = 1;
      houses[houseNumber - 1].planets.add(planet.planet);
    }
    
    return houses;
  }

  /// Calculate Dasamsa (D10) chart - Career
  static Map<String, PlanetPosition> calculateDasamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    Map<String, PlanetPosition> dasamsaChart = {};

    for (var entry in birthChart.entries) {
      String planet = entry.key;
      PlanetPosition position = entry.value;

      // D10: Each sign is divided into 10 parts of 3° each
      double dasamsaDegree = position.longitude * 10;
      dasamsaDegree = dasamsaDegree % 360;

      dasamsaChart[planet] = PlanetPosition(
        planet: planet,
        longitude: dasamsaDegree,
        sign: _getZodiacSign(dasamsaDegree),
        signDegree: dasamsaDegree % 30,
        nakshatra: _getNakshatra(dasamsaDegree),
        house: 1,
      );
    }

    return dasamsaChart;
  }

  /// Calculate Saptamsa (D7) chart - Children
  static Map<String, PlanetPosition> calculateSaptamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    Map<String, PlanetPosition> saptamsaChart = {};

    for (var entry in birthChart.entries) {
      String planet = entry.key;
      PlanetPosition position = entry.value;

      // D7: Each sign is divided into 7 parts
      double saptamsaDegree = position.longitude * 7;
      saptamsaDegree = saptamsaDegree % 360;

      saptamsaChart[planet] = PlanetPosition(
        planet: planet,
        longitude: saptamsaDegree,
        sign: _getZodiacSign(saptamsaDegree),
        signDegree: saptamsaDegree % 30,
        nakshatra: _getNakshatra(saptamsaDegree),
        house: 1,
      );
    }

    return saptamsaChart;
  }

  /// Calculate Dwadasamsa (D12) chart - Parents
  static Map<String, PlanetPosition> calculateDwadasamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    Map<String, PlanetPosition> dwadasamsaChart = {};

    for (var entry in birthChart.entries) {
      String planet = entry.key;
      PlanetPosition position = entry.value;

      // D12: Each sign is divided into 12 parts of 2°30' each
      double dwadasamsaDegree = position.longitude * 12;
      dwadasamsaDegree = dwadasamsaDegree % 360;

      dwadasamsaChart[planet] = PlanetPosition(
        planet: planet,
        longitude: dwadasamsaDegree,
        sign: _getZodiacSign(dwadasamsaDegree),
        signDegree: dwadasamsaDegree % 30,
        nakshatra: _getNakshatra(dwadasamsaDegree),
        house: 1,
      );
    }

    return dwadasamsaChart;
  }

  /// Calculate Trimshamsa (D30) chart - Misfortunes
  static Map<String, PlanetPosition> calculateTrimshamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    Map<String, PlanetPosition> trimshamsaChart = {};

    for (var entry in birthChart.entries) {
      String planet = entry.key;
      PlanetPosition position = entry.value;

      // D30: Each sign is divided into 30 parts of 1° each
      double trimshamsaDegree = position.longitude * 30;
      trimshamsaDegree = trimshamsaDegree % 360;

      trimshamsaChart[planet] = PlanetPosition(
        planet: planet,
        longitude: trimshamsaDegree,
        sign: _getZodiacSign(trimshamsaDegree),
        signDegree: trimshamsaDegree % 30,
        nakshatra: _getNakshatra(trimshamsaDegree),
        house: 1,
      );
    }

    return trimshamsaChart;
  }

  /// Get houses for a divisional chart
  static List<House> getHousesForDivisionalChart(
    Map<String, PlanetPosition> divisionalPositions,
    double ascendantLongitude,
    int division,
  ) {
    // Calculate divisional ascendant
    double divisionalAscendant = (ascendantLongitude * division) % 360;
    
    List<House> houses = [];
    for (int i = 0; i < 12; i++) {
      double houseCusp = (divisionalAscendant + (i * 30)) % 360;
      houses.add(House(
        number: i + 1,
        sign: _getZodiacSign(houseCusp),
        cuspDegree: houseCusp,
        planets: [],
      ));
    }
    
    // Assign planets to houses
    for (var planet in divisionalPositions.values) {
      double relativePosition = (planet.longitude - divisionalAscendant) % 360;
      if (relativePosition < 0) relativePosition += 360;
      int houseNumber = (relativePosition / 30).floor() + 1;
      if (houseNumber > 12) houseNumber = 1;
      planet.house = houseNumber;
      houses[houseNumber - 1].planets.add(planet.planet);
    }
    
    return houses;
  }
}

/// Model classes for Kundali data

class PlanetPosition {
  final String planet;
  final double longitude;
  final String sign;
  final double signDegree;
  final String nakshatra;
  int house;

  PlanetPosition({
    required this.planet,
    required this.longitude,
    required this.sign,
    required this.signDegree,
    required this.nakshatra,
    required this.house,
  });

  String get formattedPosition {
    return '$sign ${signDegree.toStringAsFixed(2)}°';
  }
}

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

class DashaPeriod {
  final String planet;
  final int years;

  DashaPeriod(this.planet, this.years);
}
