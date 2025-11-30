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
      houses.add(
        House(
          number: i + 1,
          sign: _getZodiacSign(houseCusp),
          cuspDegree: houseCusp,
          planets: [],
        ),
      );
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
      houses.add(
        House(
          number: i + 1,
          sign: _getZodiacSign(houseCusp),
          cuspDegree: houseCusp,
          planets: [],
        ),
      );
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
      houses.add(
        House(
          number: i + 1,
          sign: _getZodiacSign(houseCusp),
          cuspDegree: houseCusp,
          planets: [],
        ),
      );
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

  // ============ ADDITIONAL DIVISIONAL CHARTS ============

  /// Calculate Bhava Chalit Chart - cusp-based house system
  static List<House> calculateBhavaChaliChart(
    Map<String, PlanetPosition> planetPositions,
    double ascendantLongitude,
  ) {
    List<House> houses = [];

    // In Bhava Chalit, each house cusp is exactly 30° from the ascendant
    // but planets may shift houses based on their actual cusp positions
    for (int i = 0; i < 12; i++) {
      double houseCusp = (ascendantLongitude + (i * 30)) % 360;
      houses.add(
        House(
          number: i + 1,
          sign: _getZodiacSign(houseCusp),
          cuspDegree: houseCusp,
          planets: [],
        ),
      );
    }

    // Assign planets based on cusp midpoints (Bhava Madhya)
    for (var planet in planetPositions.values) {
      int houseNumber = 1;
      for (int i = 0; i < 12; i++) {
        double currentCusp = houses[i].cuspDegree;
        double nextCusp = houses[(i + 1) % 12].cuspDegree;
        if (nextCusp < currentCusp) nextCusp += 360;

        double planetLong = planet.longitude;
        if (planetLong < currentCusp) planetLong += 360;

        if (planetLong >= currentCusp && planetLong < nextCusp) {
          houseNumber = i + 1;
          break;
        }
      }
      houses[houseNumber - 1].planets.add(planet.planet);
    }

    return houses;
  }

  /// Calculate Hora (D2) chart - Wealth
  static Map<String, PlanetPosition> calculateHoraChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    Map<String, PlanetPosition> horaChart = {};

    for (var entry in birthChart.entries) {
      String planet = entry.key;
      PlanetPosition position = entry.value;

      // D2: Each sign is divided into 2 parts of 15° each
      // Odd signs: first half = Sun (Leo), second half = Moon (Cancer)
      // Even signs: first half = Moon (Cancer), second half = Sun (Leo)
      int signIndex = (position.longitude / 30).floor();
      double signDegree = position.longitude % 30;
      bool isOddSign = signIndex % 2 == 0;
      bool isFirstHalf = signDegree < 15;

      double horaLong;
      if (isOddSign) {
        horaLong = isFirstHalf ? 120 : 90; // Leo or Cancer
      } else {
        horaLong = isFirstHalf ? 90 : 120; // Cancer or Leo
      }
      horaLong += (signDegree * 2) % 30;

      horaChart[planet] = PlanetPosition(
        planet: planet,
        longitude: horaLong,
        sign: _getZodiacSign(horaLong),
        signDegree: horaLong % 30,
        nakshatra: _getNakshatra(horaLong),
        house: 1,
      );
    }

    return horaChart;
  }

  /// Calculate Drekkana (D3) chart - Siblings, courage
  static Map<String, PlanetPosition> calculateDrekkanaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    Map<String, PlanetPosition> drekkanaChart = {};

    for (var entry in birthChart.entries) {
      String planet = entry.key;
      PlanetPosition position = entry.value;

      // D3: Each sign is divided into 3 parts of 10° each
      double drekkanaDegree = position.longitude * 3;
      drekkanaDegree = drekkanaDegree % 360;

      drekkanaChart[planet] = PlanetPosition(
        planet: planet,
        longitude: drekkanaDegree,
        sign: _getZodiacSign(drekkanaDegree),
        signDegree: drekkanaDegree % 30,
        nakshatra: _getNakshatra(drekkanaDegree),
        house: 1,
      );
    }

    return drekkanaChart;
  }

  /// Calculate Chaturthamsa (D4) chart - Property, fortune
  static Map<String, PlanetPosition> calculateChaturthamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    Map<String, PlanetPosition> chaturthamsaChart = {};

    for (var entry in birthChart.entries) {
      String planet = entry.key;
      PlanetPosition position = entry.value;

      // D4: Each sign is divided into 4 parts of 7°30' each
      double chaturthamsaDegree = position.longitude * 4;
      chaturthamsaDegree = chaturthamsaDegree % 360;

      chaturthamsaChart[planet] = PlanetPosition(
        planet: planet,
        longitude: chaturthamsaDegree,
        sign: _getZodiacSign(chaturthamsaDegree),
        signDegree: chaturthamsaDegree % 30,
        nakshatra: _getNakshatra(chaturthamsaDegree),
        house: 1,
      );
    }

    return chaturthamsaChart;
  }

  /// Calculate Shodasamsa (D16) chart - Vehicles, comforts
  static Map<String, PlanetPosition> calculateShodasamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    Map<String, PlanetPosition> shodasamsaChart = {};

    for (var entry in birthChart.entries) {
      String planet = entry.key;
      PlanetPosition position = entry.value;

      // D16: Each sign is divided into 16 parts
      double shodasamsaDegree = position.longitude * 16;
      shodasamsaDegree = shodasamsaDegree % 360;

      shodasamsaChart[planet] = PlanetPosition(
        planet: planet,
        longitude: shodasamsaDegree,
        sign: _getZodiacSign(shodasamsaDegree),
        signDegree: shodasamsaDegree % 30,
        nakshatra: _getNakshatra(shodasamsaDegree),
        house: 1,
      );
    }

    return shodasamsaChart;
  }

  /// Calculate Vimsamsa (D20) chart - Spiritual progress
  static Map<String, PlanetPosition> calculateVimsamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    Map<String, PlanetPosition> vimsamsaChart = {};

    for (var entry in birthChart.entries) {
      String planet = entry.key;
      PlanetPosition position = entry.value;

      // D20: Each sign is divided into 20 parts
      double vimsamsaDegree = position.longitude * 20;
      vimsamsaDegree = vimsamsaDegree % 360;

      vimsamsaChart[planet] = PlanetPosition(
        planet: planet,
        longitude: vimsamsaDegree,
        sign: _getZodiacSign(vimsamsaDegree),
        signDegree: vimsamsaDegree % 30,
        nakshatra: _getNakshatra(vimsamsaDegree),
        house: 1,
      );
    }

    return vimsamsaChart;
  }

  /// Calculate Chaturvimsamsa (D24) chart - Education, learning
  static Map<String, PlanetPosition> calculateChaturvimsamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    Map<String, PlanetPosition> chaturvimsamsaChart = {};

    for (var entry in birthChart.entries) {
      String planet = entry.key;
      PlanetPosition position = entry.value;

      // D24: Each sign is divided into 24 parts
      double chaturvimsamsaDegree = position.longitude * 24;
      chaturvimsamsaDegree = chaturvimsamsaDegree % 360;

      chaturvimsamsaChart[planet] = PlanetPosition(
        planet: planet,
        longitude: chaturvimsamsaDegree,
        sign: _getZodiacSign(chaturvimsamsaDegree),
        signDegree: chaturvimsamsaDegree % 30,
        nakshatra: _getNakshatra(chaturvimsamsaDegree),
        house: 1,
      );
    }

    return chaturvimsamsaChart;
  }

  /// Calculate Bhamsa/Nakshatramsa (D27) chart - Strength, weakness
  static Map<String, PlanetPosition> calculateBhamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    Map<String, PlanetPosition> bhamsaChart = {};

    for (var entry in birthChart.entries) {
      String planet = entry.key;
      PlanetPosition position = entry.value;

      // D27: Each sign is divided into 27 parts (Nakshatras)
      double bhamsaDegree = position.longitude * 27;
      bhamsaDegree = bhamsaDegree % 360;

      bhamsaChart[planet] = PlanetPosition(
        planet: planet,
        longitude: bhamsaDegree,
        sign: _getZodiacSign(bhamsaDegree),
        signDegree: bhamsaDegree % 30,
        nakshatra: _getNakshatra(bhamsaDegree),
        house: 1,
      );
    }

    return bhamsaChart;
  }

  /// Calculate Khavedamsa (D40) chart - Auspicious effects
  static Map<String, PlanetPosition> calculateKhavedamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    Map<String, PlanetPosition> khavedamsaChart = {};

    for (var entry in birthChart.entries) {
      String planet = entry.key;
      PlanetPosition position = entry.value;

      // D40: Each sign is divided into 40 parts
      double khavedamsaDegree = position.longitude * 40;
      khavedamsaDegree = khavedamsaDegree % 360;

      khavedamsaChart[planet] = PlanetPosition(
        planet: planet,
        longitude: khavedamsaDegree,
        sign: _getZodiacSign(khavedamsaDegree),
        signDegree: khavedamsaDegree % 30,
        nakshatra: _getNakshatra(khavedamsaDegree),
        house: 1,
      );
    }

    return khavedamsaChart;
  }

  /// Calculate Akshavedamsa (D45) chart - General indications
  static Map<String, PlanetPosition> calculateAkshavedamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    Map<String, PlanetPosition> akshavedamsaChart = {};

    for (var entry in birthChart.entries) {
      String planet = entry.key;
      PlanetPosition position = entry.value;

      // D45: Each sign is divided into 45 parts
      double akshavedamsaDegree = position.longitude * 45;
      akshavedamsaDegree = akshavedamsaDegree % 360;

      akshavedamsaChart[planet] = PlanetPosition(
        planet: planet,
        longitude: akshavedamsaDegree,
        sign: _getZodiacSign(akshavedamsaDegree),
        signDegree: akshavedamsaDegree % 30,
        nakshatra: _getNakshatra(akshavedamsaDegree),
        house: 1,
      );
    }

    return akshavedamsaChart;
  }

  /// Calculate Shashtiamsa (D60) chart - Past life karma
  static Map<String, PlanetPosition> calculateShashtiamsaChart(
    Map<String, PlanetPosition> birthChart,
  ) {
    Map<String, PlanetPosition> shashtiamsaChart = {};

    for (var entry in birthChart.entries) {
      String planet = entry.key;
      PlanetPosition position = entry.value;

      // D60: Each sign is divided into 60 parts
      double shashtiamsaDegree = position.longitude * 60;
      shashtiamsaDegree = shashtiamsaDegree % 360;

      shashtiamsaChart[planet] = PlanetPosition(
        planet: planet,
        longitude: shashtiamsaDegree,
        sign: _getZodiacSign(shashtiamsaDegree),
        signDegree: shashtiamsaDegree % 30,
        nakshatra: _getNakshatra(shashtiamsaDegree),
        house: 1,
      );
    }

    return shashtiamsaChart;
  }

  // ============ SPECIAL CHARTS ============

  /// Calculate Ashtakavarga points for each planet and sign
  /// Returns a map of planet -> list of 12 points (one per sign)
  static Map<String, List<int>> calculateAshtakavarga(
    Map<String, PlanetPosition> planetPositions,
  ) {
    // Benefic points contributed by each planet from various positions
    // This is a simplified version - full Ashtakavarga has complex rules
    Map<String, List<int>> ashtakavarga = {};

    final mainPlanets = [
      'Sun',
      'Moon',
      'Mars',
      'Mercury',
      'Jupiter',
      'Venus',
      'Saturn',
    ];

    for (var planet in mainPlanets) {
      List<int> points = List.filled(12, 0);

      // Calculate points based on positions from each contributing planet
      for (var contributor in mainPlanets) {
        if (planetPositions.containsKey(contributor)) {
          int contributorSign =
              (planetPositions[contributor]!.longitude / 30).floor();

          // Simplified calculation: add points based on house positions
          // In actual Ashtakavarga, each planet has specific benefic positions
          List<int> beneficHouses = _getBeneficHouses(planet, contributor);

          for (int house in beneficHouses) {
            int targetSign = (contributorSign + house - 1) % 12;
            points[targetSign]++;
          }
        }
      }

      // Add lagna contribution
      ashtakavarga[planet] = points;
    }

    return ashtakavarga;
  }

  /// Get benefic house positions for Ashtakavarga
  static List<int> _getBeneficHouses(String planet, String from) {
    // Simplified benefic house positions
    // Full Ashtakavarga has specific rules for each planet combination
    const beneficRules = {
      'Sun': [1, 2, 4, 7, 8, 9, 10, 11],
      'Moon': [3, 6, 7, 8, 10, 11],
      'Mars': [3, 5, 6, 10, 11],
      'Mercury': [1, 2, 4, 6, 8, 10, 11],
      'Jupiter': [1, 2, 3, 4, 7, 8, 10, 11],
      'Venus': [1, 2, 3, 4, 5, 8, 9, 11, 12],
      'Saturn': [3, 5, 6, 11],
    };

    return beneficRules[planet] ?? [1, 4, 7, 10];
  }

  /// Calculate Sarvashtakavarga (total points for all signs)
  static List<int> calculateSarvashtakavarga(
    Map<String, List<int>> ashtakavarga,
  ) {
    List<int> sav = List.filled(12, 0);

    for (var points in ashtakavarga.values) {
      for (int i = 0; i < 12; i++) {
        sav[i] += points[i];
      }
    }

    return sav;
  }

  /// Get generic divisional chart based on division number
  static Map<String, PlanetPosition> calculateDivisionalChart(
    Map<String, PlanetPosition> birthChart,
    int division,
  ) {
    Map<String, PlanetPosition> divisionalChart = {};

    for (var entry in birthChart.entries) {
      String planet = entry.key;
      PlanetPosition position = entry.value;

      double divisionalDegree = position.longitude * division;
      divisionalDegree = divisionalDegree % 360;

      divisionalChart[planet] = PlanetPosition(
        planet: planet,
        longitude: divisionalDegree,
        sign: _getZodiacSign(divisionalDegree),
        signDegree: divisionalDegree % 30,
        nakshatra: _getNakshatra(divisionalDegree),
        house: 1,
      );
    }

    return divisionalChart;
  }

  // ============ PANCHANG CALCULATIONS ============

  /// Calculate Panchang details for a given date/time
  static PanchangData calculatePanchang(
    DateTime dateTime,
    double sunLongitude,
    double moonLongitude,
  ) {
    // Calculate Tithi (lunar day) - based on Moon-Sun angular distance
    double tithiAngle = (moonLongitude - sunLongitude + 360) % 360;
    int tithiNumber = (tithiAngle / 12).floor() + 1;
    if (tithiNumber > 30) tithiNumber = 1;

    // Tithi names
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
    String tithi = tithiNames[(tithiNumber - 1) % 15];
    String paksha = tithiNumber <= 15 ? 'Shukla' : 'Krishna';

    // Calculate Nakshatra from Moon position
    int nakshatraIndex = (moonLongitude / 13.333333).floor();
    String nakshatra = nakshatras[nakshatraIndex % 27];
    int nakshatraPada = ((moonLongitude % 13.333333) / 3.333333).floor() + 1;

    // Calculate Yoga (Sun + Moon longitude / 13.333)
    double yogaAngle = (sunLongitude + moonLongitude) % 360;
    int yogaNumber = (yogaAngle / 13.333333).floor() + 1;
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
    String yoga = yogaNames[(yogaNumber - 1) % 27];

    // Calculate Karana (half of tithi)
    int karanaNumber = ((tithiAngle / 6).floor() % 60) + 1;
    const karanaNames = [
      'Bava',
      'Balava',
      'Kaulava',
      'Taitila',
      'Garaja',
      'Vanija',
      'Vishti',
      'Shakuni',
      'Chatushpada',
      'Naga',
      'Kimstughna',
    ];
    String karana = karanaNames[karanaNumber % 11];

    // Calculate Vara (weekday)
    const varaNames = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    const varaDeities = [
      'Surya',
      'Chandra',
      'Mangal',
      'Budha',
      'Guru',
      'Shukra',
      'Shani',
    ];
    String vara = varaNames[dateTime.weekday % 7];
    String varaDeity = varaDeities[dateTime.weekday % 7];

    return PanchangData(
      tithi: tithi,
      tithiNumber: tithiNumber,
      paksha: paksha,
      nakshatra: nakshatra,
      nakshatraPada: nakshatraPada,
      yoga: yoga,
      yogaNumber: yogaNumber,
      karana: karana,
      vara: vara,
      varaDeity: varaDeity,
    );
  }

  // ============ SHADBALA (SIX STRENGTHS) ============

  /// Calculate Shadbala for all planets
  static Map<String, ShadbalaData> calculateShadbala(
    Map<String, PlanetPosition> planetPositions,
    double ascendantLongitude,
    DateTime birthDateTime,
  ) {
    Map<String, ShadbalaData> shadbala = {};

    for (var entry in planetPositions.entries) {
      String planet = entry.key;
      PlanetPosition position = entry.value;

      if (planet == 'Rahu' || planet == 'Ketu')
        continue; // Nodes don't have Shadbala

      // 1. Sthana Bala (Positional Strength) - based on sign placement
      double sthanaBala = _calculateSthanaBala(planet, position);

      // 2. Dig Bala (Directional Strength) - based on house position
      double digBala = _calculateDigBala(planet, position.house);

      // 3. Kala Bala (Temporal Strength) - based on time factors
      double kalaBala = _calculateKalaBala(planet, birthDateTime);

      // 4. Chesta Bala (Motional Strength) - based on planetary motion
      double chestaBala = _calculateChestaBala(planet);

      // 5. Naisargika Bala (Natural Strength) - inherent planetary strength
      double naisargikaBala = _calculateNaisargikaBala(planet);

      // 6. Drik Bala (Aspectual Strength) - based on aspects received
      double drikBala = _calculateDrikBala(planet, planetPositions);

      double totalBala =
          sthanaBala +
          digBala +
          kalaBala +
          chestaBala +
          naisargikaBala +
          drikBala;

      shadbala[planet] = ShadbalaData(
        planet: planet,
        sthanaBala: sthanaBala,
        digBala: digBala,
        kalaBala: kalaBala,
        chestaBala: chestaBala,
        naisargikaBala: naisargikaBala,
        drikBala: drikBala,
        totalBala: totalBala,
        requiredBala: _getRequiredBala(planet),
        isStrong: totalBala >= _getRequiredBala(planet),
      );
    }

    return shadbala;
  }

  static double _calculateSthanaBala(String planet, PlanetPosition position) {
    // Simplified: Check if planet is in own sign, exaltation, etc.
    const exaltationSigns = {
      'Sun': 'Aries',
      'Moon': 'Taurus',
      'Mars': 'Capricorn',
      'Mercury': 'Virgo',
      'Jupiter': 'Cancer',
      'Venus': 'Pisces',
      'Saturn': 'Libra',
    };
    const debilitationSigns = {
      'Sun': 'Libra',
      'Moon': 'Scorpio',
      'Mars': 'Cancer',
      'Mercury': 'Pisces',
      'Jupiter': 'Capricorn',
      'Venus': 'Virgo',
      'Saturn': 'Aries',
    };
    const ownSigns = {
      'Sun': ['Leo'],
      'Moon': ['Cancer'],
      'Mars': ['Aries', 'Scorpio'],
      'Mercury': ['Gemini', 'Virgo'],
      'Jupiter': ['Sagittarius', 'Pisces'],
      'Venus': ['Taurus', 'Libra'],
      'Saturn': ['Capricorn', 'Aquarius'],
    };

    if (position.sign == exaltationSigns[planet]) return 60.0;
    if (position.sign == debilitationSigns[planet]) return 15.0;
    if (ownSigns[planet]?.contains(position.sign) ?? false) return 45.0;
    return 30.0;
  }

  static double _calculateDigBala(String planet, int house) {
    // Directional strength based on house placement
    const digBalaHouses = {
      'Sun': 10,
      'Moon': 4,
      'Mars': 10,
      'Mercury': 1,
      'Jupiter': 1,
      'Venus': 4,
      'Saturn': 7,
    };
    int bestHouse = digBalaHouses[planet] ?? 1;
    int distance = (house - bestHouse).abs();
    if (distance > 6) distance = 12 - distance;
    return 60.0 - (distance * 10);
  }

  static double _calculateKalaBala(String planet, DateTime dateTime) {
    // Simplified temporal strength
    int hour = dateTime.hour;
    bool isDayTime = hour >= 6 && hour < 18;
    const diurnalPlanets = ['Sun', 'Jupiter', 'Saturn'];
    const nocturnalPlanets = ['Moon', 'Mars', 'Venus'];

    if (diurnalPlanets.contains(planet)) return isDayTime ? 45.0 : 25.0;
    if (nocturnalPlanets.contains(planet)) return isDayTime ? 25.0 : 45.0;
    return 35.0;
  }

  static double _calculateChestaBala(String planet) {
    // Simplified: Would need actual ephemeris for retrograde detection
    return 30.0; // Average value
  }

  static double _calculateNaisargikaBala(String planet) {
    const naturalStrengths = {
      'Sun': 60.0,
      'Moon': 51.43,
      'Mars': 17.14,
      'Mercury': 25.71,
      'Jupiter': 34.29,
      'Venus': 42.86,
      'Saturn': 8.57,
    };
    return naturalStrengths[planet] ?? 30.0;
  }

  static double _calculateDrikBala(
    String planet,
    Map<String, PlanetPosition> positions,
  ) {
    // Simplified aspectual strength
    return 25.0; // Average value
  }

  static double _getRequiredBala(String planet) {
    const requiredBala = {
      'Sun': 390.0,
      'Moon': 360.0,
      'Mars': 300.0,
      'Mercury': 420.0,
      'Jupiter': 390.0,
      'Venus': 330.0,
      'Saturn': 300.0,
    };
    return requiredBala[planet] ?? 300.0;
  }

  // ============ VIMSHOPAKA BALA ============

  /// Calculate Vimshopaka Bala (divisional chart strength)
  static Map<String, VimshopakaBalaData> calculateVimshopakaBala(
    Map<String, PlanetPosition> birthChart,
  ) {
    Map<String, VimshopakaBalaData> vimshopaka = {};

    // Division weights for Shadvarga scheme
    const divisionWeights = {
      1: 6.0, // D1 - Rashi
      2: 2.0, // D2 - Hora
      3: 4.0, // D3 - Drekkana
      9: 5.0, // D9 - Navamsa
      12: 2.0, // D12 - Dwadasamsa
      30: 1.0, // D30 - Trimshamsa
    };

    for (var entry in birthChart.entries) {
      String planet = entry.key;
      if (planet == 'Rahu' || planet == 'Ketu') continue;

      double totalPoints = 0;
      Map<String, double> divisionScores = {};

      for (var divEntry in divisionWeights.entries) {
        int division = divEntry.key;
        double weight = divEntry.value;

        // Calculate position in this division
        double divPos = (entry.value.longitude * division) % 360;
        String divSign = _getZodiacSign(divPos);

        // Check dignity in this division
        double dignityScore = _getDivisionalDignity(planet, divSign);
        double weightedScore = dignityScore * weight;
        totalPoints += weightedScore;
        divisionScores['D$division'] = dignityScore;
      }

      vimshopaka[planet] = VimshopakaBalaData(
        planet: planet,
        totalPoints: totalPoints,
        maxPoints: 20.0,
        percentage: (totalPoints / 20.0) * 100,
        divisionScores: divisionScores,
        strength:
            totalPoints >= 15
                ? 'Strong'
                : totalPoints >= 10
                ? 'Medium'
                : 'Weak',
      );
    }

    return vimshopaka;
  }

  static double _getDivisionalDignity(String planet, String sign) {
    // Simplified dignity scoring
    const exaltationSigns = {
      'Sun': 'Aries',
      'Moon': 'Taurus',
      'Mars': 'Capricorn',
      'Mercury': 'Virgo',
      'Jupiter': 'Cancer',
      'Venus': 'Pisces',
      'Saturn': 'Libra',
    };
    const ownSigns = {
      'Sun': ['Leo'],
      'Moon': ['Cancer'],
      'Mars': ['Aries', 'Scorpio'],
      'Mercury': ['Gemini', 'Virgo'],
      'Jupiter': ['Sagittarius', 'Pisces'],
      'Venus': ['Taurus', 'Libra'],
      'Saturn': ['Capricorn', 'Aquarius'],
    };

    if (sign == exaltationSigns[planet]) return 1.0;
    if (ownSigns[planet]?.contains(sign) ?? false) return 0.75;
    return 0.5;
  }

  // ============ TRANSIT ANALYSIS (GOCHAR) ============

  /// Calculate current transits and their effects
  static Map<String, TransitData> calculateTransits(
    Map<String, PlanetPosition> birthChart,
    Map<String, PlanetPosition> currentPositions,
    String moonSign,
  ) {
    Map<String, TransitData> transits = {};
    int moonSignIndex = zodiacSigns.indexOf(moonSign);

    for (var entry in currentPositions.entries) {
      String planet = entry.key;
      PlanetPosition currentPos = entry.value;
      PlanetPosition? natalPos = birthChart[planet];

      // Calculate house from Moon (for transit analysis)
      int currentSignIndex = zodiacSigns.indexOf(currentPos.sign);
      int transitHouse = ((currentSignIndex - moonSignIndex + 12) % 12) + 1;

      // Determine if transit is favorable
      bool isFavorable = _isTransitFavorable(planet, transitHouse);

      // Calculate aspect to natal position
      String aspectToNatal = 'None';
      if (natalPos != null) {
        double angle = (currentPos.longitude - natalPos.longitude + 360) % 360;
        if (angle < 10 || angle > 350)
          aspectToNatal = 'Conjunction';
        else if ((angle > 85 && angle < 95) || (angle > 265 && angle < 275))
          aspectToNatal = 'Square';
        else if ((angle > 115 && angle < 125) || (angle > 235 && angle < 245))
          aspectToNatal = 'Trine';
        else if (angle > 175 && angle < 185)
          aspectToNatal = 'Opposition';
      }

      transits[planet] = TransitData(
        planet: planet,
        currentSign: currentPos.sign,
        currentDegree: currentPos.signDegree,
        transitHouse: transitHouse,
        isFavorable: isFavorable,
        aspectToNatal: aspectToNatal,
        effects: _getTransitEffects(planet, transitHouse),
      );
    }

    return transits;
  }

  static bool _isTransitFavorable(String planet, int house) {
    // Vedic Gochar rules - favorable houses from Moon
    const favorableHouses = {
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
    return favorableHouses[planet]?.contains(house) ?? false;
  }

  static String _getTransitEffects(String planet, int house) {
    const effects = {
      1: 'Focus on self, health, new beginnings',
      2: 'Financial matters, family, speech',
      3: 'Communication, courage, siblings',
      4: 'Home, mother, emotional peace',
      5: 'Creativity, children, romance',
      6: 'Health, enemies, daily work',
      7: 'Partnerships, marriage, business',
      8: 'Transformation, occult, inheritance',
      9: 'Fortune, higher learning, travel',
      10: 'Career, status, authority',
      11: 'Gains, friends, aspirations',
      12: 'Expenses, spirituality, isolation',
    };
    return effects[house] ?? '';
  }

  // ============ DETAILED DASHA ANALYSIS ============

  /// Calculate Antardasha periods within a Mahadasha
  static List<AntardashaData> calculateAntardasha(
    String mahadashaPlanet,
    DateTime mahadashaStart,
    double mahadashaDuration,
  ) {
    List<AntardashaData> antardashas = [];
    const dashaSequence = [
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
    const dashaDurations = {
      'Sun': 6.0,
      'Moon': 10.0,
      'Mars': 7.0,
      'Rahu': 18.0,
      'Jupiter': 16.0,
      'Saturn': 19.0,
      'Mercury': 17.0,
      'Ketu': 7.0,
      'Venus': 20.0,
    };

    int startIndex = dashaSequence.indexOf(mahadashaPlanet);
    DateTime currentStart = mahadashaStart;

    for (int i = 0; i < 9; i++) {
      String antarPlanet = dashaSequence[(startIndex + i) % 9];
      double antarDuration =
          (dashaDurations[mahadashaPlanet]! * dashaDurations[antarPlanet]!) /
          120;
      int antarDays = (antarDuration * 365.25).round();

      DateTime antarEnd = currentStart.add(Duration(days: antarDays));

      antardashas.add(
        AntardashaData(
          planet: antarPlanet,
          startDate: currentStart,
          endDate: antarEnd,
          durationYears: antarDuration,
          isActive:
              DateTime.now().isAfter(currentStart) &&
              DateTime.now().isBefore(antarEnd),
        ),
      );

      currentStart = antarEnd;
    }

    return antardashas;
  }

  /// Calculate Pratyantardasha within an Antardasha
  static List<PratyantardashaData> calculatePratyantardasha(
    String antarPlanet,
    DateTime antarStart,
    double antarDuration,
  ) {
    List<PratyantardashaData> pratyantardashas = [];
    const dashaSequence = [
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
    const dashaDurations = {
      'Sun': 6.0,
      'Moon': 10.0,
      'Mars': 7.0,
      'Rahu': 18.0,
      'Jupiter': 16.0,
      'Saturn': 19.0,
      'Mercury': 17.0,
      'Ketu': 7.0,
      'Venus': 20.0,
    };

    int startIndex = dashaSequence.indexOf(antarPlanet);
    DateTime currentStart = antarStart;

    for (int i = 0; i < 9; i++) {
      String pratyantarPlanet = dashaSequence[(startIndex + i) % 9];
      double pratyantarDuration =
          (antarDuration * dashaDurations[pratyantarPlanet]!) / 120;
      int pratyantarDays = (pratyantarDuration * 365.25).round();

      DateTime pratyantarEnd = currentStart.add(Duration(days: pratyantarDays));

      pratyantardashas.add(
        PratyantardashaData(
          planet: pratyantarPlanet,
          startDate: currentStart,
          endDate: pratyantarEnd,
          durationDays: pratyantarDays,
          isActive:
              DateTime.now().isAfter(currentStart) &&
              DateTime.now().isBefore(pratyantarEnd),
        ),
      );

      currentStart = pratyantarEnd;
    }

    return pratyantardashas;
  }

  // ============ VARSHPHAL (ANNUAL CHART) ============

  /// Calculate Varshphal (Solar Return) chart
  static VarshphalData calculateVarshphal(
    DateTime birthDateTime,
    double birthSunLongitude,
    int targetYear,
  ) {
    // Calculate when Sun returns to birth position in target year
    // Simplified: actual calculation requires precise ephemeris
    DateTime solarReturn = DateTime(
      targetYear,
      birthDateTime.month,
      birthDateTime.day,
    );

    // Adjust for actual solar return (approximately)
    int yearDiff = targetYear - birthDateTime.year;
    int dayAdjustment = (yearDiff * 0.2422).round(); // Account for leap years
    solarReturn = solarReturn.add(Duration(days: dayAdjustment));

    // Muntha - progresses one sign per year
    int munthaSignIndex = ((birthDateTime.month - 1 + yearDiff) % 12);
    String munthaSi = zodiacSigns[munthaSignIndex];

    // Year Lord - based on weekday of solar return
    const yearLords = [
      'Sun',
      'Moon',
      'Mars',
      'Mercury',
      'Jupiter',
      'Venus',
      'Saturn',
    ];
    String yearLord = yearLords[solarReturn.weekday % 7];

    return VarshphalData(
      year: targetYear,
      solarReturnDate: solarReturn,
      munthaSign: munthaSi,
      yearLord: yearLord,
      age: yearDiff,
    );
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

// ============ NEW MODEL CLASSES ============

/// Panchang data
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

/// Shadbala data for a planet
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

/// Vimshopaka Bala data
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

/// Transit data
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

/// Antardasha data
class AntardashaData {
  final String planet;
  final DateTime startDate;
  final DateTime endDate;
  final double durationYears;
  final bool isActive;

  AntardashaData({
    required this.planet,
    required this.startDate,
    required this.endDate,
    required this.durationYears,
    required this.isActive,
  });

  int get durationDays => endDate.difference(startDate).inDays;
}

/// Pratyantardasha data
class PratyantardashaData {
  final String planet;
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;
  final bool isActive;

  PratyantardashaData({
    required this.planet,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.isActive,
  });
}

/// Varshphal data
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
