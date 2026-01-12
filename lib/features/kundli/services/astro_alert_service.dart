import 'package:flutter/material.dart';
import 'package:kundali_app/l10n/generated/app_localizations.dart';
import '../models/astro_alert.dart';
import '../../../shared/models/kundali_data_model.dart';
import '../../../core/services/kundali_calculation_service.dart';
import '../../../core/services/sweph_service.dart';

/// Service to detect and generate astrological alerts from Kundali data
class AstroAlertService {
  // Cache for transit Saturn sign (keyed by date)
  static final Map<String, String> _saturnSignCache = {};

  /// Generate all applicable alerts for the given Kundali data
  /// [transitDate] - optional date for transit calculations (defaults to now)
  /// [l10n] - optional localization for generating localized alert titles
  static List<AstroAlert> generateAlerts(
    KundaliData kundaliData, {
    DateTime? transitDate,
    AppLocalizations? l10n,
  }) {
    final List<AstroAlert> alerts = [];

    // Get transiting Saturn sign for Sade Sati / Dhaiya detection
    final effectiveDate = transitDate ?? DateTime.now();
    final transitSaturnSign = _getSaturnSignForDate(kundaliData, effectiveDate);

    // Detect various conditions
    final sadeSati = _detectSadeSati(kundaliData, transitSaturnSign, l10n);
    if (sadeSati != null) alerts.add(sadeSati);

    final dhaiya = _detectShaniDhaiya(kundaliData, transitSaturnSign, l10n);
    if (dhaiya != null) alerts.add(dhaiya);

    final majorDasha = _detectMajorDasha(kundaliData, l10n);
    if (majorDasha != null) alerts.add(majorDasha);

    final manglik = _detectManglikDosha(kundaliData, l10n);
    if (manglik != null) alerts.add(manglik);

    final moonAffliction = _detectMoonAffliction(kundaliData, l10n);
    if (moonAffliction != null) alerts.add(moonAffliction);

    alerts.addAll(_detectPositiveYogas(kundaliData, l10n));

    // Sort by priority
    alerts.sort((a, b) => a.priorityIndex.compareTo(b.priorityIndex));

    return alerts;
  }

  /// Get Saturn's sign for a specific date
  /// Uses cache to avoid recalculating for the same day
  static String _getSaturnSignForDate(KundaliData data, DateTime date) {
    // Cache key is date only (YYYY-MM-DD) since Saturn moves slowly
    final cacheKey = '${date.year}-${date.month}-${date.day}';

    if (_saturnSignCache.containsKey(cacheKey)) {
      return _saturnSignCache[cacheKey]!;
    }

    // Try to calculate Saturn position using Swiss Ephemeris
    try {
      if (SwephService.nativeLibraryAvailable) {
        final transitResult = KundaliCalculationService.calculateAll(
          birthDateTime: date,
          latitude: data.latitude,
          longitude: data.longitude,
          timezone: data.timezone,
        );

        final transitSaturn = transitResult.planetPositions['Saturn'];
        if (transitSaturn != null) {
          _saturnSignCache[cacheKey] = transitSaturn.sign;
          // Keep cache size manageable
          if (_saturnSignCache.length > 100) {
            _saturnSignCache.remove(_saturnSignCache.keys.first);
          }
          return transitSaturn.sign;
        }
      }
    } catch (e) {
      debugPrint('AstroAlertService: Error calculating transit: $e');
    }

    // Fallback: Use hardcoded Saturn position based on known astronomy
    final saturnSign = _getHardcodedSaturnSign(date);
    _saturnSignCache[cacheKey] = saturnSign;
    return saturnSign;
  }

  /// Get Saturn's sign based on known transit dates (fallback)
  static String _getHardcodedSaturnSign(DateTime date) {
    // Saturn transit dates (sidereal/Vedic)
    // These are approximate - Saturn has brief retrogrades
    if (date.isBefore(DateTime(2023, 1, 17))) {
      return 'Capricorn';
    } else if (date.isBefore(DateTime(2025, 3, 29))) {
      return 'Aquarius';
    } else if (date.isBefore(DateTime(2028, 2, 6))) {
      // Saturn in Pisces with brief Aries excursion in 2027
      if (date.isAfter(DateTime(2027, 6, 1)) &&
          date.isBefore(DateTime(2027, 11, 1))) {
        return 'Aries'; // Brief Aries transit
      }
      return 'Pisces';
    } else if (date.isBefore(DateTime(2031, 4, 1))) {
      return 'Aries';
    } else if (date.isBefore(DateTime(2034, 7, 1))) {
      return 'Taurus';
    } else {
      return 'Gemini';
    }
  }

  /// Get the zodiac sign index (0-11) from sign name
  static int _getSignIndex(String sign) {
    const signs = [
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
    return signs.indexOf(sign);
  }

  /// Calculate houses away (positive = forward in zodiac)
  static int _getHousesAway(String fromSign, String toSign) {
    final from = _getSignIndex(fromSign);
    final to = _getSignIndex(toSign);
    if (from == -1 || to == -1) return -1;
    return (to - from + 12) % 12;
  }

  /// Detect Shani Sade Sati
  /// Sade Sati occurs when Saturn TRANSITS 12th, 1st, or 2nd from Moon sign
  static AstroAlert? _detectSadeSati(
    KundaliData data,
    String transitSaturnSign,
    AppLocalizations? l10n,
  ) {
    final moonSign = data.moonSign;
    final housesAway = _getHousesAway(moonSign, transitSaturnSign);

    // Sade Sati: Saturn in 12th (11), 1st (0), or 2nd (1) from Moon
    SadeSatiPhase? phase;
    String phaseLabel = '';

    if (housesAway == 11) {
      phase = SadeSatiPhase.first;
      phaseLabel = l10n?.alert_risingPhase ?? 'Rising Phase (1st)';
    } else if (housesAway == 0) {
      phase = SadeSatiPhase.peak;
      phaseLabel = l10n?.alert_peakPhase ?? 'Peak Phase';
    } else if (housesAway == 1) {
      phase = SadeSatiPhase.third;
      phaseLabel = l10n?.alert_settingPhase ?? 'Setting Phase (3rd)';
    }

    if (phase == null) return null;

    final transitDates = _getSaturnTransitDates(transitSaturnSign);

    return AstroAlert(
      id: 'sade_sati_${phase.name}',
      type: AlertType.warning,
      priority: AlertPriority.sadeSati,
      title: l10n?.alert_sadeSati ?? 'Shani Sade Sati',
      subtitle: phaseLabel,
      description:
          'Saturn is transiting through your $phaseLabel of Sade Sati. Moon sign: $moonSign, Saturn in: $transitSaturnSign.',
      startDate: transitDates['start'],
      endDate: transitDates['end'],
      iconSymbol: '♄',
      accentColor: AstroAlertColors.saturn,
      themeSummary:
          l10n?.alert_theme_sadeSati ??
          'A period of transformation, discipline, and inner growth.',
      detailedExplanation:
          '''Sade Sati is a 7.5-year transit of Saturn through the 12th, 1st, and 2nd houses from your Moon sign ($moonSign). This is not a period of punishment, but rather a time when Saturn teaches important life lessons.

During the $phaseLabel:
${phase == SadeSatiPhase.first ? '• Focus shifts to introspection and releasing old patterns\n• Hidden matters may come to surface for resolution' : ''}
${phase == SadeSatiPhase.peak ? '• Most intense period of transformation\n• Direct impact on emotional well-being and self-identity\n• Opportunities for significant personal growth' : ''}
${phase == SadeSatiPhase.third ? '• Integration of lessons learned\n• Gradual easing of pressures\n• Building new foundations based on wisdom gained' : ''}

This transit ultimately strengthens character and brings maturity.''',
      effects: [
        'Increased responsibilities and life restructuring',
        'Deeper self-awareness and emotional maturity',
        'Patience and perseverance are rewarded',
        'Long-term foundations being established',
      ],
      remedies: [
        'Chant "Om Sham Shanicharaya Namaha" on Saturdays',
        'Donate black sesame seeds or mustard oil',
        'Practice patience and avoid impulsive decisions',
        'Serve the elderly and underprivileged',
      ],
    );
  }

  /// Detect Shani Dhaiya (Small Panoti)
  /// Dhaiya occurs when Saturn TRANSITS 4th or 8th from Moon sign
  static AstroAlert? _detectShaniDhaiya(
    KundaliData data,
    String transitSaturnSign,
    AppLocalizations? l10n,
  ) {
    final moonSign = data.moonSign;
    final housesAway = _getHousesAway(moonSign, transitSaturnSign);

    // Dhaiya: Saturn in 4th (3) or 8th (7) from Moon
    DhaiyaPhase? phase;
    String houseLabel = '';

    if (housesAway == 3) {
      phase = DhaiyaPhase.small;
      houseLabel = '4th house';
    } else if (housesAway == 7) {
      phase = DhaiyaPhase.big;
      houseLabel = '8th house';
    }

    if (phase == null) return null;

    return AstroAlert(
      id: 'dhaiya_${phase.name}',
      type: AlertType.neutral,
      priority: AlertPriority.dhaiya,
      title: l10n?.alert_shaniDhaiya ?? 'Shani Dhaiya',
      subtitle:
          l10n?.alert_saturnIn(houseLabel) ?? 'Saturn in $houseLabel from Moon',
      description:
          'Saturn is transiting your $houseLabel from Moon sign ($moonSign).',
      iconSymbol: '♄',
      accentColor: AstroAlertColors.saturn,
      themeSummary:
          phase == DhaiyaPhase.small
              ? (l10n?.alert_theme_dhaiyaDomestic ??
                  'A 2.5-year period requiring patience in domestic and emotional matters.')
              : (l10n?.alert_theme_dhaiyaTransform ??
                  'A 2.5-year period requiring patience in transformations and changes.'),
      detailedExplanation: '''Shani Dhaiya, also known as Small Panoti, occurs when Saturn transits the 4th or 8th house from your Moon sign. This is a 2.5-year period that, while less intense than Sade Sati, still requires mindfulness.

${phase == DhaiyaPhase.small ? '''When Saturn transits the 4th house:
• Focus on home, property, and emotional security
• Mother's health may need attention
• Inner peace requires conscious effort
• Good time to make long-term property decisions''' : '''When Saturn transits the 8th house:
• Transformation and regeneration themes
• Joint finances and shared resources in focus
• Deep psychological insights possible
• Research and investigation favored'''}''',
      effects: [
        phase == DhaiyaPhase.small
            ? 'Domestic matters require attention'
            : 'Transformation in shared resources',
        'Patience needed in daily life',
        'Good for introspection',
      ],
      remedies: [
        'Recite Hanuman Chalisa on Saturdays',
        'Light a sesame oil lamp on Saturday evenings',
        'Practice mindfulness and stress management',
      ],
    );
  }

  /// Detect major Dasha (Rahu, Ketu, Saturn)
  static AstroAlert? _detectMajorDasha(
    KundaliData data,
    AppLocalizations? l10n,
  ) {
    final dashaInfo = data.dashaInfo;

    final currentDasha = dashaInfo.currentMahadasha.toLowerCase();
    final isRahu = currentDasha.contains('rahu');
    final isKetu = currentDasha.contains('ketu');
    final isSaturn =
        currentDasha.contains('saturn') || currentDasha.contains('shani');

    if (!isRahu && !isKetu && !isSaturn) return null;

    String planet = isRahu ? 'Rahu' : (isKetu ? 'Ketu' : 'Saturn');
    String symbol = isRahu ? '☊' : (isKetu ? '☋' : '♄');
    Color color =
        (isRahu || isKetu)
            ? AstroAlertColors.rahuKetu
            : AstroAlertColors.saturn;

    return AstroAlert(
      id: 'dasha_$planet',
      type: AlertType.neutral,
      priority: AlertPriority.majorDasha,
      title: l10n?.alert_mahadasha(planet) ?? '$planet Mahadasha',
      subtitle: l10n?.alert_currentMajorPeriod ?? 'Current major period',
      description: 'You are in the $planet Mahadasha period.',
      startDate: dashaInfo.mahadashaStartDate,
      endDate: dashaInfo.mahadashaEndDate,
      iconSymbol: symbol,
      accentColor: color,
      themeSummary: _getDashaSummary(planet),
      detailedExplanation: _getDashaExplanation(planet),
      effects: _getDashaEffects(planet),
      remedies: _getDashaRemedies(planet),
    );
  }

  static String _getDashaSummary(String planet) {
    switch (planet) {
      case 'Rahu':
        return 'A period of worldly ambitions, unconventional paths, and material pursuits.';
      case 'Ketu':
        return 'A period of spiritual growth, detachment, and inner wisdom.';
      case 'Saturn':
        return 'A period of discipline, hard work, and karmic lessons.';
      default:
        return '';
    }
  }

  static String _getDashaExplanation(String planet) {
    switch (planet) {
      case 'Rahu':
        return '''Rahu Mahadasha is an 18-year period that amplifies desires and worldly ambitions. Rahu represents our unfulfilled desires and the areas where we seek growth.

Key themes:
• Strong drive for success and recognition
• Unconventional approaches may bring results
• Foreign connections and travel possible
• Technology and innovation favored
• Important to stay grounded and ethical''';
      case 'Ketu':
        return '''Ketu Mahadasha is a 7-year period of spiritual evolution and detachment. Ketu represents liberation from material attachments.

Key themes:
• Spiritual inclinations strengthen
• Past-life talents may emerge
• Detachment from worldly matters
• Intuition and psychic abilities heightened
• Research and occult studies favored''';
      case 'Saturn':
        return '''Saturn Mahadasha is a 19-year period of discipline, responsibility, and karmic settlements. Saturn teaches through experience.

Key themes:
• Hard work and perseverance rewarded
• Slow but steady progress
• Authority and structure important
• Career building opportunities
• Justice and fairness emphasized''';
      default:
        return '';
    }
  }

  static List<String> _getDashaEffects(String planet) {
    switch (planet) {
      case 'Rahu':
        return [
          'Amplified ambitions and desires',
          'Unconventional success paths',
          'Foreign opportunities',
          'Technology and innovation gains',
        ];
      case 'Ketu':
        return [
          'Spiritual awakening',
          'Intuitive insights',
          'Past karma resolution',
          'Detachment and liberation',
        ];
      case 'Saturn':
        return [
          'Discipline brings rewards',
          'Career responsibilities increase',
          'Karmic lessons unfold',
          'Long-term stability building',
        ];
      default:
        return [];
    }
  }

  static List<String> _getDashaRemedies(String planet) {
    switch (planet) {
      case 'Rahu':
        return [
          'Chant "Om Raam Rahave Namaha"',
          'Donate to the underprivileged',
          'Avoid intoxicants and unethical practices',
          'Worship Lord Ganesha',
        ];
      case 'Ketu':
        return [
          'Chant "Om Kem Ketave Namaha"',
          'Practice meditation regularly',
          'Donate blankets to the needy',
          'Worship Lord Ganesha',
        ];
      case 'Saturn':
        return [
          'Chant "Om Sham Shanicharaya Namaha"',
          'Serve the elderly and workers',
          'Practice patience and discipline',
          'Donate black items on Saturdays',
        ];
      default:
        return [];
    }
  }

  /// Detect Manglik Dosha
  static AstroAlert? _detectManglikDosha(
    KundaliData data,
    AppLocalizations? l10n,
  ) {
    final marsPosition = data.planetPositions['Mars'];
    if (marsPosition == null) return null;

    // Check if Mars is in 1st, 4th, 7th, 8th, or 12th house
    final manglikHouses = [1, 4, 7, 8, 12];
    final marsInManglikHouse = manglikHouses.contains(marsPosition.house);

    // Also check if it's already detected in doshas (doshas is List<String>)
    final hasManglikDosha = data.doshas.any(
      (d) =>
          d.toLowerCase().contains('manglik') ||
          d.toLowerCase().contains('mangal'),
    );

    if (!marsInManglikHouse && !hasManglikDosha) return null;

    final houseToShow =
        marsInManglikHouse
            ? marsPosition.house
            : (hasManglikDosha ? _extractManglikHouse(data.doshas) : 7);

    return AstroAlert(
      id: 'manglik_dosha',
      type: AlertType.neutral,
      priority: AlertPriority.manglikDosha,
      title: l10n?.alert_manglikDosha ?? 'Manglik Dosha',
      subtitle:
          l10n?.alert_marsInHouse(_getOrdinal(houseToShow)) ??
          'Mars in ${_getOrdinal(houseToShow)} house',
      description:
          'Mars is placed in the ${_getOrdinal(houseToShow)} house of your birth chart.',
      iconSymbol: '♂',
      accentColor: AstroAlertColors.generalWarning,
      themeSummary:
          l10n?.alert_theme_manglik ??
          'Mars energy influences relationships and requires understanding for harmony.',
      detailedExplanation:
          '''Manglik Dosha occurs when Mars is placed in the 1st, 4th, 7th, 8th, or 12th house from the Ascendant. This is one of the most discussed doshas in Vedic astrology, particularly regarding marriage compatibility.

Important perspective:
• Manglik Dosha is very common (approximately 50% of people have it)
• Its effects vary based on Mars's sign, aspects, and conjunctions
• Many natural cancellations exist (after age 28, if Mars is in own sign, etc.)
• Both partners having Manglik Dosha is considered balancing

Mars in the ${_getOrdinal(houseToShow)} house specifically influences:
${_getManglikHouseEffect(houseToShow)}''',
      effects: [
        'Strong willpower and determination',
        'Passionate nature in relationships',
        'Need for independence and space',
        'Leadership qualities',
      ],
      remedies: [
        'Chant "Om Angarakaya Namaha" on Tuesdays',
        'Perform Kumbh Vivah if recommended',
        'Donate red lentils on Tuesdays',
        'Channel Mars energy through physical activities',
      ],
    );
  }

  static int _extractManglikHouse(List<String> doshas) {
    // Try to extract house number from dosha string
    for (final d in doshas) {
      if (d.toLowerCase().contains('manglik')) {
        final regex = RegExp(r'(\d+)');
        final match = regex.firstMatch(d);
        if (match != null) {
          return int.tryParse(match.group(1)!) ?? 7;
        }
      }
    }
    return 7; // Default
  }

  static String _getManglikHouseEffect(int house) {
    switch (house) {
      case 1:
        return '• Strong personality and self-assertion\n• Natural leadership abilities';
      case 4:
        return '• Passionate about home and property\n• Strong attachment to family';
      case 7:
        return '• Intense approach to partnerships\n• Need for an equally strong partner';
      case 8:
        return '• Deep transformative energy\n• Interest in mysteries and research';
      case 12:
        return '• Expenses on good causes\n• Spiritual warrior energy';
      default:
        return '';
    }
  }

  /// Detect Moon affliction
  static AstroAlert? _detectMoonAffliction(
    KundaliData data,
    AppLocalizations? l10n,
  ) {
    final moonPosition = data.planetPositions['Moon'];
    if (moonPosition == null) return null;

    final dusthanaHouses = [6, 8, 12];
    final isInDusthana = dusthanaHouses.contains(moonPosition.house);

    // Check for conjunction with malefics
    final saturn = data.planetPositions['Saturn'];
    final rahu = data.planetPositions['Rahu'];
    final ketu = data.planetPositions['Ketu'];

    bool isConjunctMalefic = false;
    String conjunctPlanet = '';

    if (saturn != null && saturn.sign == moonPosition.sign) {
      isConjunctMalefic = true;
      conjunctPlanet = 'Saturn';
    } else if (rahu != null && rahu.sign == moonPosition.sign) {
      isConjunctMalefic = true;
      conjunctPlanet = 'Rahu';
    } else if (ketu != null && ketu.sign == moonPosition.sign) {
      isConjunctMalefic = true;
      conjunctPlanet = 'Ketu';
    }

    if (!isInDusthana && !isConjunctMalefic) return null;

    String subtitle = '';
    if (isConjunctMalefic) {
      subtitle =
          l10n?.alert_moonWith(conjunctPlanet) ?? 'Moon with $conjunctPlanet';
    } else {
      subtitle =
          l10n?.alert_moonInHouse(_getOrdinal(moonPosition.house)) ??
          'Moon in ${_getOrdinal(moonPosition.house)} house';
    }

    return AstroAlert(
      id: 'moon_affliction',
      type: AlertType.neutral,
      priority: AlertPriority.moonAffliction,
      title: l10n?.alert_lunarSensitivity ?? 'Lunar Sensitivity',
      subtitle: subtitle,
      description:
          'Your Moon placement suggests heightened emotional sensitivity.',
      iconSymbol: '☽',
      accentColor: AstroAlertColors.moonAffliction,
      themeSummary:
          l10n?.alert_theme_lunar ??
          'Enhanced intuition and emotional depth that benefits from mindful practices.',
      detailedExplanation: '''Your Moon placement indicates a sensitive and intuitive emotional nature. This is not a weakness but rather a gift that, when understood, provides deep insight and empathy.

${isConjunctMalefic ? '''Moon conjunct $conjunctPlanet:
${conjunctPlanet == 'Saturn' ? '• Deep, serious emotional nature\n• Wisdom through emotional experiences\n• Strong sense of responsibility' : ''}
${conjunctPlanet == 'Rahu' ? '• Intense emotional experiences\n• Strong desires and ambitions\n• Innovative thinking patterns' : ''}
${conjunctPlanet == 'Ketu' ? '• Spiritual and intuitive nature\n• Detachment abilities\n• Past-life emotional wisdom' : ''}''' : '''Moon in ${_getOrdinal(moonPosition.house)} house:
${moonPosition.house == 6 ? '• Service-oriented emotional fulfillment\n• Healing abilities' : ''}
${moonPosition.house == 8 ? '• Deep psychological insight\n• Transformative emotional experiences' : ''}
${moonPosition.house == 12 ? '• Rich inner life and spirituality\n• Compassion for all beings' : ''}'''}

These placements often indicate old souls with much to offer the world.''',
      effects: [
        'Deep emotional intelligence',
        'Strong intuitive abilities',
        'Empathy and compassion',
        'Need for emotional self-care',
      ],
      remedies: [
        'Practice meditation and mindfulness',
        'Spend time near water',
        'Wear pearl or moonstone (if suitable)',
        'Honor the Moon on Mondays',
      ],
    );
  }

  /// Detect positive yogas
  static List<AstroAlert> _detectPositiveYogas(
    KundaliData data,
    AppLocalizations? l10n,
  ) {
    final List<AstroAlert> alerts = [];

    for (final yogaString in data.yogas) {
      final nameLower = yogaString.toLowerCase();

      // Only highlight major beneficial yogas
      if (nameLower.contains('raja') ||
          nameLower.contains('dhana') ||
          nameLower.contains('gajakesari') ||
          nameLower.contains('budhaditya') ||
          nameLower.contains('hamsa') ||
          nameLower.contains('malavya') ||
          nameLower.contains('ruchaka') ||
          nameLower.contains('bhadra') ||
          nameLower.contains('sasa')) {
        // Parse the yoga string - format is typically "Yoga Name: Description" or just "Yoga Name"
        final parts = yogaString.split(':');
        final yogaName = parts[0].trim();
        final yogaDescription =
            parts.length > 1
                ? parts[1].trim()
                : 'A beneficial yoga in your chart.';

        alerts.add(
          AstroAlert(
            id: 'yoga_${yogaName.toLowerCase().replaceAll(' ', '_')}',
            type: AlertType.positive,
            priority: AlertPriority.positiveYoga,
            title: yogaName,
            subtitle: l10n?.alert_shubhYoga ?? 'Auspicious Yoga',
            description: yogaDescription,
            iconSymbol: '✦',
            accentColor: AstroAlertColors.positive,
            themeSummary:
                l10n?.alert_theme_yoga ??
                'A powerful yoga bringing positive influences to your life.',
            detailedExplanation:
                '''$yogaName is a beneficial yoga in your chart.

$yogaDescription

This yoga enhances specific areas of life and provides natural strengths that you can leverage for success and fulfillment.''',
            effects: [
              'Natural talents and abilities',
              'Favorable circumstances in related areas',
              'Positive karmic support',
            ],
          ),
        );

        // Limit to 2 yoga alerts
        if (alerts.length >= 2) break;
      }
    }

    return alerts;
  }

  /// Get ordinal string (1st, 2nd, 3rd, etc.)
  static String _getOrdinal(int number) {
    if (number >= 11 && number <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  /// Get approximate Saturn transit dates (simplified)
  static Map<String, DateTime> _getSaturnTransitDates(String sign) {
    // Saturn spends approximately 2.5 years in each sign
    // These are approximate transit periods
    final now = DateTime.now();
    final Map<String, Map<String, DateTime>> saturnTransits = {
      'Capricorn': {
        'start': DateTime(2020, 1, 24),
        'end': DateTime(2023, 1, 17),
      },
      'Aquarius': {
        'start': DateTime(2023, 1, 17),
        'end': DateTime(2025, 3, 29),
      },
      'Pisces': {'start': DateTime(2025, 3, 29), 'end': DateTime(2028, 2, 6)},
      'Aries': {'start': DateTime(2028, 2, 6), 'end': DateTime(2031, 4, 1)},
      'Taurus': {'start': DateTime(2031, 4, 1), 'end': DateTime(2034, 7, 1)},
      'Gemini': {'start': DateTime(2034, 7, 1), 'end': DateTime(2037, 9, 1)},
      'Cancer': {'start': DateTime(2037, 9, 1), 'end': DateTime(2040, 11, 1)},
      'Leo': {'start': DateTime(2040, 11, 1), 'end': DateTime(2044, 1, 1)},
      'Virgo': {'start': DateTime(2044, 1, 1), 'end': DateTime(2047, 3, 1)},
      'Libra': {'start': DateTime(2047, 3, 1), 'end': DateTime(2050, 5, 1)},
      'Scorpio': {'start': DateTime(2050, 5, 1), 'end': DateTime(2053, 7, 1)},
      'Sagittarius': {
        'start': DateTime(2053, 7, 1),
        'end': DateTime(2056, 9, 1),
      },
    };

    return saturnTransits[sign] ??
        {'start': now, 'end': now.add(const Duration(days: 912))};
  }

  /// Clear cached transit data
  static void clearCache() {
    _saturnSignCache.clear();
  }
}
