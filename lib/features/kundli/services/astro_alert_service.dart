import 'package:flutter/material.dart';
import '../../../shared/models/kundali_data_model.dart';
import '../../../core/services/sweph_service.dart';
import '../models/astro_alert.dart';

/// Service for detecting and generating astrological alerts from Kundali data
class AstroAlertService {
  AstroAlertService._();

  /// Zodiac signs in order for calculations
  static const List<String> _zodiacSigns = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  /// Get the index of a zodiac sign (0-11)
  static int _getSignIndex(String sign) {
    return _zodiacSigns.indexOf(sign);
  }

  /// Calculate house position from one sign to another
  /// Returns 1-12 (1 = same sign, 2 = next sign, etc.)
  static int _getHouseFrom(String fromSign, String toSign) {
    final fromIndex = _getSignIndex(fromSign);
    final toIndex = _getSignIndex(toSign);
    if (fromIndex == -1 || toIndex == -1) return -1;
    return ((toIndex - fromIndex + 12) % 12) + 1;
  }

  /// Generate all applicable alerts for a given Kundali
  static List<AstroAlert> generateAlerts(KundaliData kundaliData) {
    final List<AstroAlert> alerts = [];

    // 1. Check for Sade Sati
    final sadeSatiAlert = _checkSadeSati(kundaliData);
    if (sadeSatiAlert != null) {
      alerts.add(sadeSatiAlert);
    }

    // 2. Check for Shani Dhaiya
    final dhaiyaAlert = _checkDhaiya(kundaliData);
    if (dhaiyaAlert != null) {
      alerts.add(dhaiyaAlert);
    }

    // 3. Check for Major Dasha (Rahu/Ketu/Saturn)
    final dashaAlert = _checkMajorDasha(kundaliData);
    if (dashaAlert != null) {
      alerts.add(dashaAlert);
    }

    // 4. Check for Manglik Dosha
    final manglikAlert = _checkManglikDosha(kundaliData);
    if (manglikAlert != null) {
      alerts.add(manglikAlert);
    }

    // 5. Check for Moon Affliction
    final moonAfflictionAlert = _checkMoonAffliction(kundaliData);
    if (moonAfflictionAlert != null) {
      alerts.add(moonAfflictionAlert);
    }

    // 6. Check for Positive Yogas
    final positiveYogaAlerts = _checkPositiveYogas(kundaliData);
    alerts.addAll(positiveYogaAlerts);

    // Sort by priority
    alerts.sort((a, b) => a.compareTo(b));

    return alerts;
  }

  /// Check for Shani Sade Sati
  /// Saturn transiting 12th, 1st, or 2nd from natal Moon
  static AstroAlert? _checkSadeSati(KundaliData kundaliData) {
    final moonSign = kundaliData.moonSign;
    final currentSaturnSign = _getCurrentSaturnSign();
    
    if (currentSaturnSign == null) return null;

    final houseFromMoon = _getHouseFrom(moonSign, currentSaturnSign);
    
    SadeSatiPhase? phase;
    if (houseFromMoon == 12) {
      phase = SadeSatiPhase.first;
    } else if (houseFromMoon == 1) {
      phase = SadeSatiPhase.peak;
    } else if (houseFromMoon == 2) {
      phase = SadeSatiPhase.third;
    }

    if (phase == null) return null;

    // Calculate approximate dates (Saturn spends ~2.5 years in each sign)
    final (startDate, endDate) = _getSaturnTransitDates(currentSaturnSign);

    return AstroAlert(
      id: 'sade_sati_${phase.name}',
      type: AlertType.warning,
      priority: AlertPriority.sadeSati,
      title: 'Shani Sade Sati',
      subtitle: phase.displayName,
      description: 'Saturn is transiting ${phase.position}, activating Sade Sati.',
      startDate: startDate,
      endDate: endDate,
      iconSymbol: '♄',
      planetName: 'Saturn',
      accentColor: AstroAlertColors.saturn,
      themeSummary: 'A phase of increased responsibility and growth through discipline',
      detailedExplanation: _getSadeSatiExplanation(phase),
      formationLogic: 'Saturn (Shani) is currently transiting $currentSaturnSign, '
          'which is the ${phase.position} relative to your natal Moon in $moonSign. '
          'This activates the ${phase.displayName.toLowerCase()} of Sade Sati.',
      effects: _getSadeSatiEffects(phase),
      remedies: _getSaturnRemedies(),
      sadeSatiPhase: phase,
    );
  }

  /// Check for Shani Dhaiya (Small Panoti)
  /// Saturn transiting 4th or 8th from natal Moon
  static AstroAlert? _checkDhaiya(KundaliData kundaliData) {
    final moonSign = kundaliData.moonSign;
    final currentSaturnSign = _getCurrentSaturnSign();
    
    if (currentSaturnSign == null) return null;

    final houseFromMoon = _getHouseFrom(moonSign, currentSaturnSign);
    
    DhaiyaPhase? phase;
    if (houseFromMoon == 4) {
      phase = DhaiyaPhase.fourth;
    } else if (houseFromMoon == 8) {
      phase = DhaiyaPhase.eighth;
    }

    if (phase == null) return null;

    final (startDate, endDate) = _getSaturnTransitDates(currentSaturnSign);

    return AstroAlert(
      id: 'dhaiya_${phase.name}',
      type: AlertType.warning,
      priority: AlertPriority.dhaiya,
      title: 'Shani Dhaiya',
      subtitle: phase.name,
      description: 'Saturn is transiting ${phase.position} from your Moon sign.',
      startDate: startDate,
      endDate: endDate,
      iconSymbol: '♄',
      planetName: 'Saturn',
      accentColor: AstroAlertColors.saturn,
      themeSummary: 'A period calling for patience and careful decision-making',
      detailedExplanation: _getDhaiyaExplanation(phase),
      formationLogic: 'Saturn (Shani) is currently transiting $currentSaturnSign, '
          'which is the ${phase.position} from your natal Moon in $moonSign. '
          'This creates ${phase.name}, also known as Small Panoti or Dhaiya.',
      effects: _getDhaiyaEffects(phase),
      remedies: _getSaturnRemedies(),
      dhaiyaPhase: phase,
    );
  }

  /// Check for Major Dasha (Rahu, Ketu, or Saturn as Mahadasha lord)
  static AstroAlert? _checkMajorDasha(KundaliData kundaliData) {
    final currentMahadasha = kundaliData.dashaInfo.currentMahadasha;
    
    if (currentMahadasha != 'Rahu' && 
        currentMahadasha != 'Ketu' && 
        currentMahadasha != 'Saturn') {
      return null;
    }

    final dashaInfo = kundaliData.dashaInfo;
    final startDate = dashaInfo.mahadashaStartDate ?? dashaInfo.startDate;
    final endDate = dashaInfo.mahadashaEndDate ?? dashaInfo.endDate;

    Color accentColor;
    String iconSymbol;
    String themeSummary;
    List<String> effects;

    switch (currentMahadasha) {
      case 'Rahu':
        accentColor = AstroAlertColors.rahu;
        iconSymbol = '☊';
        themeSummary = 'A period of intense ambition, unconventional paths, and material pursuits';
        effects = [
          'Strong desire for worldly success and recognition',
          'Unconventional approaches and risk-taking tendencies',
          'Foreign connections and overseas opportunities',
          'Need for grounding and spiritual practices',
          'Potential for sudden gains or unexpected changes',
        ];
        break;
      case 'Ketu':
        accentColor = AstroAlertColors.ketu;
        iconSymbol = '☋';
        themeSummary = 'A period of spiritual growth, detachment, and inner transformation';
        effects = [
          'Heightened spiritual awareness and intuition',
          'Natural inclination towards meditation and introspection',
          'Lessons in letting go and non-attachment',
          'Possible sense of isolation or withdrawal',
          'Deep karmic clearing and past-life influences',
        ];
        break;
      case 'Saturn':
      default:
        accentColor = AstroAlertColors.saturn;
        iconSymbol = '♄';
        themeSummary = 'A period emphasizing hard work, discipline, and karmic lessons';
        effects = [
          'Rewards for consistent effort and perseverance',
          'Lessons around responsibility and commitment',
          'Building long-term foundations',
          'Tests of patience and endurance',
          'Maturity through challenges',
        ];
        break;
    }

    return AstroAlert(
      id: 'mahadasha_$currentMahadasha',
      type: currentMahadasha == 'Ketu' ? AlertType.neutral : AlertType.warning,
      priority: AlertPriority.majorDasha,
      title: '$currentMahadasha Mahadasha',
      subtitle: 'Current Major Period',
      description: 'You are in the $currentMahadasha planetary period.',
      startDate: startDate,
      endDate: endDate,
      iconSymbol: iconSymbol,
      planetName: currentMahadasha,
      accentColor: accentColor,
      themeSummary: themeSummary,
      detailedExplanation: _getMahadashaExplanation(currentMahadasha),
      formationLogic: 'Based on your Moon\'s nakshatra at birth, you are currently '
          'running the $currentMahadasha Mahadasha (major planetary period) '
          'in the Vimshottari Dasha system. This period lasts '
          '${_getMahadashaDuration(currentMahadasha)} years.',
      effects: effects,
      remedies: _getMahadashaRemedies(currentMahadasha),
    );
  }

  /// Check for Manglik Dosha
  static AstroAlert? _checkManglikDosha(KundaliData kundaliData) {
    // Check if Manglik Dosha is already detected
    if (!kundaliData.doshas.contains('Manglik Dosha')) {
      return null;
    }

    // Get Mars position for additional details
    final mars = kundaliData.planetPositions['Mars'];
    final marsHouse = mars?.house ?? 0;

    String houseDescription;
    switch (marsHouse) {
      case 1:
        houseDescription = '1st House (Self/Personality)';
        break;
      case 4:
        houseDescription = '4th House (Home/Happiness)';
        break;
      case 7:
        houseDescription = '7th House (Marriage/Partnership)';
        break;
      case 8:
        houseDescription = '8th House (Transformation)';
        break;
      case 12:
        houseDescription = '12th House (Losses/Liberation)';
        break;
      default:
        houseDescription = 'a significant house';
    }

    return AstroAlert(
      id: 'manglik_dosha',
      type: AlertType.neutral,
      priority: AlertPriority.manglikDosha,
      title: 'Manglik Dosha',
      subtitle: 'Mars in $houseDescription',
      description: 'Mars is placed in a Manglik-forming house in your chart.',
      startDate: null, // Lifetime condition
      endDate: null,
      iconSymbol: '♂',
      planetName: 'Mars',
      accentColor: AstroAlertColors.mars,
      themeSummary: 'Consider Manglik matching for marriage compatibility',
      detailedExplanation: '''
Manglik Dosha (also known as Kuja Dosha or Mangal Dosha) is formed when Mars is placed in the 1st, 4th, 7th, 8th, or 12th house from the Ascendant.

In your chart, Mars is placed in the $houseDescription, which creates this yoga.

It's important to note that many charts have this placement, and its effects are often mitigated by various factors including:
• Mars in its own sign or exaltation
• Beneficial aspects from Jupiter or Venus
• Similar placement in partner's chart (Dosha cancellation)
• Age (effects are said to reduce after 28 years)

Traditional texts suggest considering Manglik matching during marriage, but many astrologers view this as just one of many factors in compatibility assessment.
''',
      formationLogic: 'Mars (Mangal) is positioned in the ${marsHouse}th house from '
          'your Ascendant. Houses 1, 4, 7, 8, and 12 are considered Manglik-forming '
          'positions as Mars brings its fiery, assertive energy to these sensitive '
          'areas of life.',
      effects: [
        'Passion and assertiveness in relationships',
        'Strong willpower and determination',
        'Importance of physical compatibility',
        'Traditional recommendation for Manglik matching',
        'Energy that can be channeled into sports or career',
      ],
      remedies: [
        'Recite Hanuman Chalisa on Tuesdays',
        'Donate red lentils or jaggery',
        'Wear a red coral after consultation',
        'Kumbh Vivah ritual (symbolic marriage)',
        'Practice patience and anger management',
      ],
    );
  }

  /// Check for Moon Affliction
  static AstroAlert? _checkMoonAffliction(KundaliData kundaliData) {
    final moon = kundaliData.planetPositions['Moon'];
    if (moon == null) return null;

    final List<String> afflictionReasons = [];

    // Check if Moon is in 6th, 8th, or 12th house
    if (moon.house == 6 || moon.house == 8 || moon.house == 12) {
      afflictionReasons.add('Moon in ${moon.house}th house (Dusthana)');
    }

    // Check for conjunction with malefics
    final saturn = kundaliData.planetPositions['Saturn'];
    final rahu = kundaliData.planetPositions['Rahu'];
    final ketu = kundaliData.planetPositions['Ketu'];

    if (saturn != null && moon.sign == saturn.sign) {
      afflictionReasons.add('Moon conjunct Saturn');
    }
    if (rahu != null && moon.sign == rahu.sign) {
      afflictionReasons.add('Moon conjunct Rahu');
    }
    if (ketu != null && moon.sign == ketu.sign) {
      afflictionReasons.add('Moon conjunct Ketu');
    }

    // Check for Saturn's aspect on Moon (Saturn aspects 3rd, 7th, and 10th from itself)
    if (saturn != null) {
      final saturnHouseFromMoon = _getHouseFrom(moon.sign, saturn.sign);
      if (saturnHouseFromMoon == 3 || saturnHouseFromMoon == 7 || saturnHouseFromMoon == 10) {
        afflictionReasons.add('Moon aspected by Saturn');
      }
    }

    if (afflictionReasons.isEmpty) return null;

    return AstroAlert(
      id: 'moon_affliction',
      type: AlertType.neutral,
      priority: AlertPriority.moonAffliction,
      title: 'Sensitive Moon Placement',
      subtitle: afflictionReasons.first,
      description: 'Your Moon has some challenging influences in the birth chart.',
      startDate: null,
      endDate: null,
      iconSymbol: '☽',
      planetName: 'Moon',
      accentColor: AstroAlertColors.moon,
      themeSummary: 'Your emotional nature may benefit from grounding practices',
      detailedExplanation: '''
The Moon represents the mind, emotions, and inner peace in Vedic astrology. When the Moon receives challenging influences, it can affect emotional stability and mental peace.

In your chart, the following factors are present:
${afflictionReasons.map((r) => '• $r').join('\n')}

This doesn't indicate anything negative about you—rather, it suggests that emotional self-care and grounding practices may be especially beneficial.

Many successful and spiritually evolved individuals have similar placements. The key is awareness and working consciously with this energy.
''',
      formationLogic: 'The Moon in your chart is influenced by: '
          '${afflictionReasons.join(', ')}. '
          'These combinations suggest a need for emotional awareness and self-care practices.',
      effects: [
        'Deep emotional sensitivity and intuition',
        'Benefit from regular meditation practice',
        'Need for stable, nurturing environments',
        'Strong inner life and introspective nature',
        'Potential for profound emotional wisdom',
      ],
      remedies: [
        'Practice meditation, especially on Mondays',
        'Wear pearls or moonstone (after consultation)',
        'Maintain a regular sleep schedule',
        'Connect with water bodies for peace',
        'Honor your mother and feminine energy',
      ],
    );
  }

  /// Check for positive yogas
  static List<AstroAlert> _checkPositiveYogas(KundaliData kundaliData) {
    final List<AstroAlert> alerts = [];
    final yogas = kundaliData.yogas;

    // Priority yogas to highlight
    final priorityYogas = <String, Map<String, dynamic>>{
      'Gajakesari Yoga': {
        'description': 'Jupiter in angular house from Moon brings wisdom and prosperity',
        'effects': [
          'Natural wisdom and good judgment',
          'Respect and recognition in society',
          'Success through ethical means',
          'Good fortune through knowledge',
          'Ability to inspire and guide others',
        ],
      },
      'Raja Yoga': {
        'description': 'Combination indicating leadership and authority',
        'effects': [
          'Leadership abilities and authority',
          'Success in government or politics',
          'Rise to prominent positions',
          'Support from influential people',
          'Kingly comforts and status',
        ],
      },
      'Dhana Yoga': {
        'description': 'Wealth-giving combination in your chart',
        'effects': [
          'Strong potential for wealth accumulation',
          'Multiple income sources',
          'Good financial judgment',
          'Material prosperity and comfort',
          'Generosity and ability to give',
        ],
      },
      'Hamsa Yoga': {
        'description': 'Jupiter in Kendra bestows wisdom and spirituality',
        'effects': [
          'Spiritual inclination and wisdom',
          'Respected teacher or guide',
          'Pure and ethical character',
          'Success through righteousness',
          'Divine protection and grace',
        ],
      },
      'Malavya Yoga': {
        'description': 'Venus in Kendra brings beauty, luxury and artistic talents',
        'effects': [
          'Artistic and creative abilities',
          'Luxurious lifestyle and comforts',
          'Attractive personality and charm',
          'Success in arts or beauty industry',
          'Happy married life',
        ],
      },
      'Budhaditya Yoga': {
        'description': 'Sun-Mercury conjunction enhances intellect and communication',
        'effects': [
          'Sharp intellect and analytical mind',
          'Excellent communication skills',
          'Success through knowledge and speech',
          'Government or administrative success',
          'Fame through intellectual pursuits',
        ],
      },
      'Lakshmi Yoga': {
        'description': 'Venus strong indicates blessings of Goddess Lakshmi',
        'effects': [
          'Wealth and material prosperity',
          'Beautiful surroundings and aesthetics',
          'Happiness in relationships',
          'Luxurious and comfortable life',
          'Artistic and creative success',
        ],
      },
    };

    for (var yoga in yogas) {
      if (priorityYogas.containsKey(yoga)) {
        final yogaInfo = priorityYogas[yoga]!;
        alerts.add(AstroAlert(
          id: 'yoga_${yoga.toLowerCase().replaceAll(' ', '_')}',
          type: AlertType.positive,
          priority: AlertPriority.positiveYoga,
          title: yoga,
          subtitle: 'Auspicious Yoga Present',
          description: yogaInfo['description'] as String,
          startDate: null,
          endDate: null,
          iconSymbol: '✦',
          planetName: null,
          accentColor: AstroAlertColors.positive,
          themeSummary: 'A beneficial combination blessing your chart',
          detailedExplanation: '''
$yoga is one of the auspicious combinations in Vedic astrology that enhances the positive potential of your chart.

${yogaInfo['description']}

This yoga is formed in your birth chart and remains a lifelong blessing. Its effects become more pronounced during favorable planetary periods (dashas) of the planets involved.
''',
          formationLogic: 'This yoga is formed based on specific planetary positions '
              'and combinations in your birth chart. It represents a harmonious '
              'alignment that enhances certain life areas.',
          effects: yogaInfo['effects'] as List<String>,
          remedies: null, // Positive yogas don't need remedies
        ));
      }
    }

    // Limit to max 2 positive yogas to avoid overwhelming
    return alerts.take(2).toList();
  }

  // ============ HELPER METHODS ============

  /// Get current Saturn sign from current date transit
  static String? _getCurrentSaturnSign() {
    try {
      final now = DateTime.now();
      final result = SwephService.instance.calculateKundli(
        birthDateTime: now,
        latitude: 28.6139, // Default Delhi coordinates for transit
        longitude: 77.2090,
        timezoneOffsetHours: 5.5,
        useAyanamsa: true,
      );
      return result.planets['Saturn']?.signName;
    } catch (e) {
      debugPrint('Error calculating current Saturn position: $e');
      // Fallback: Saturn is in Pisces from March 2025 onwards
      return 'Pisces';
    }
  }

  /// Get approximate Saturn transit dates for a sign
  static (DateTime?, DateTime?) _getSaturnTransitDates(String sign) {
    // Saturn transit dates (approximate)
    // Saturn moves through each sign in ~2.5 years
    switch (sign) {
      case 'Aquarius':
        return (DateTime(2023, 1, 17), DateTime(2025, 3, 29));
      case 'Pisces':
        return (DateTime(2025, 3, 29), DateTime(2028, 6, 1));
      case 'Aries':
        return (DateTime(2028, 6, 1), DateTime(2031, 8, 1));
      default:
        return (null, null);
    }
  }

  static String _getSadeSatiExplanation(SadeSatiPhase phase) {
    switch (phase) {
      case SadeSatiPhase.first:
        return '''
The First Phase of Sade Sati begins when Saturn enters the 12th house from your natal Moon sign.

This phase typically brings:
• Increased expenses or unexpected outflows
• Need to reassess priorities and values
• Potential changes in living situation
• Beginning of a period of self-reflection

This is a preparatory phase where Saturn begins its lessons gradually. It's an excellent time for spiritual practices and reducing unnecessary attachments.

Duration: Approximately 2.5 years
Current transit: Saturn in ${phase.position}
''';
      case SadeSatiPhase.peak:
        return '''
The Peak Phase of Sade Sati occurs when Saturn transits over your natal Moon sign.

This is considered the most significant phase, bringing:
• Deep emotional processing and maturity
• Tests of mental strength and resilience
• Important life lessons and karmic clearing
• Opportunity for profound personal growth

While this phase can feel challenging, it's often when the most significant positive transformation occurs. Many people emerge from this phase with greater wisdom and clarity.

Duration: Approximately 2.5 years
Current transit: Saturn directly over your Moon sign
''';
      case SadeSatiPhase.third:
        return '''
The Third Phase of Sade Sati occurs when Saturn moves to the 2nd house from your natal Moon.

This phase typically involves:
• Financial restructuring and lessons about resources
• Family matters coming into focus
• Speech and communication becoming important
• Gradual easing of Sade Sati's intensity

This is the concluding phase where the lessons of Sade Sati begin to integrate. You may start seeing the fruits of the discipline and changes made during earlier phases.

Duration: Approximately 2.5 years
Current transit: Saturn in ${phase.position}
''';
    }
  }

  static List<String> _getSadeSatiEffects(SadeSatiPhase phase) {
    switch (phase) {
      case SadeSatiPhase.first:
        return [
          'Period of introspection and inner work',
          'Releasing what no longer serves you',
          'Potential increase in expenses',
          'Changes in living situation possible',
          'Opportunity for spiritual growth',
        ];
      case SadeSatiPhase.peak:
        return [
          'Deep emotional and mental processing',
          'Tests of patience and endurance',
          'Karmic lessons coming to surface',
          'Opportunity for profound maturity',
          'Building unshakeable inner strength',
        ];
      case SadeSatiPhase.third:
        return [
          'Focus on finances and resources',
          'Family matters require attention',
          'Learning value-based communication',
          'Integration of lessons learned',
          'Gradual return of stability',
        ];
    }
  }

  static List<String> _getSaturnRemedies() {
    return [
      'Recite Shani mantra or Hanuman Chalisa on Saturdays',
      'Donate black sesame seeds, mustard oil, or iron items',
      'Serve and respect elderly people',
      'Feed crows or black dogs',
      'Practice discipline and honest hard work',
    ];
  }

  static String _getDhaiyaExplanation(DhaiyaPhase phase) {
    switch (phase) {
      case DhaiyaPhase.fourth:
        return '''
Kantak Shani occurs when Saturn transits the 4th house from your natal Moon sign.

The 4th house governs:
• Home, property, and domestic peace
• Mother and maternal relationships
• Mental peace and emotional comfort
• Vehicles and conveyances

During this transit, you may experience:
• Challenges related to property or home
• Need to address family responsibilities
• Tests of emotional stability
• Possible vehicle-related issues

This period, lasting approximately 2.5 years, teaches lessons about inner security and true sources of happiness.
''';
      case DhaiyaPhase.eighth:
        return '''
Ashtama Shani occurs when Saturn transits the 8th house from your natal Moon sign.

The 8th house governs:
• Transformation and change
• Hidden matters and secrets
• Longevity and chronic health
• Joint resources and inheritance

During this transit, you may experience:
• Unexpected changes or transformations
• Health matters requiring attention
• Financial restructuring
• Deep psychological processing

This powerful 2.5-year transit often brings profound transformation and can be a period of significant spiritual growth.
''';
    }
  }

  static List<String> _getDhaiyaEffects(DhaiyaPhase phase) {
    switch (phase) {
      case DhaiyaPhase.fourth:
        return [
          'Focus on home and property matters',
          'Mother or family may need support',
          'Mental peace requires conscious effort',
          'Vehicle or property decisions',
          'Building inner emotional security',
        ];
      case DhaiyaPhase.eighth:
        return [
          'Period of transformation and change',
          'Hidden matters may surface',
          'Health awareness becomes important',
          'Financial restructuring possible',
          'Deep psychological insights',
        ];
    }
  }

  static String _getMahadashaExplanation(String planet) {
    switch (planet) {
      case 'Rahu':
        return '''
Rahu Mahadasha is an 18-year period where the North Node of the Moon becomes the dominant planetary influence.

Rahu represents:
• Worldly desires and material ambitions
• Innovation and unconventional approaches
• Foreign lands and overseas connections
• Breaking of boundaries and taboos
• Technology and modern advancements

This period often brings:
• Intense focus on material achievement
• Unconventional life paths and careers
• Foreign travel or connections
• Need for spiritual grounding
• Lessons about desire and contentment

Rahu is neither purely benefic nor malefic—it amplifies what it touches. Conscious living and ethical choices are especially important during this period.
''';
      case 'Ketu':
        return '''
Ketu Mahadasha is a 7-year period where the South Node of the Moon becomes the dominant planetary influence.

Ketu represents:
• Spiritual liberation and moksha
• Past life karma and skills
• Detachment and letting go
• Intuition and psychic abilities
• Completion and endings

This period often brings:
• Heightened spiritual awareness
• Natural inclination toward meditation
• Sense of detachment from material pursuits
• Possible feelings of isolation
• Completion of karmic cycles

Ketu Mahadasha is excellent for spiritual practice but may feel confusing for purely material goals. Trust your intuition during this period.
''';
      case 'Saturn':
      default:
        return '''
Saturn Mahadasha is a 19-year period where Saturn becomes the dominant planetary influence.

Saturn represents:
• Discipline, hard work, and perseverance
• Karma and lessons from past actions
• Structure, limitation, and responsibility
• Elderly people and authority figures
• Time, patience, and long-term results

This period often brings:
• Rewards for consistent effort
• Important karmic lessons
• Rise through hard work
• Tests of patience and commitment
• Building lasting foundations

Saturn rewards genuine effort and punishes shortcuts. This period builds character and creates lasting achievements for those who embrace its lessons.
''';
    }
  }

  static int _getMahadashaDuration(String planet) {
    const durations = {
      'Sun': 6,
      'Moon': 10,
      'Mars': 7,
      'Rahu': 18,
      'Jupiter': 16,
      'Saturn': 19,
      'Mercury': 17,
      'Ketu': 7,
      'Venus': 20,
    };
    return durations[planet] ?? 0;
  }

  static List<String> _getMahadashaRemedies(String planet) {
    switch (planet) {
      case 'Rahu':
        return [
          'Recite Rahu mantra or Durga Chalisa',
          'Donate dark blue or black items on Saturdays',
          'Feed birds, especially crows',
          'Practice meditation and grounding',
          'Avoid deception and maintain honesty',
        ];
      case 'Ketu':
        return [
          'Recite Ketu mantra or Ganesh mantra',
          'Donate blankets to the needy',
          'Feed dogs and practice compassion',
          'Regular meditation practice',
          'Pilgrimage to spiritual places',
        ];
      case 'Saturn':
      default:
        return _getSaturnRemedies();
    }
  }
}

