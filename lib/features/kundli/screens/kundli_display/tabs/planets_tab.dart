import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../shared/floating_nav_bar.dart';

// ═══════════════════════════════════════════════════════════════════════════
// INSIGHT DATA MODEL - For interactive explanations
// ═══════════════════════════════════════════════════════════════════════════
class InsightData {
  final String title;
  final String value;
  final String description;
  final String significance;
  final List<String> keyPoints;
  final Color accentColor;
  final IconData icon;
  final String? imagePath;

  const InsightData({
    required this.title,
    required this.value,
    required this.description,
    required this.significance,
    required this.keyPoints,
    required this.accentColor,
    required this.icon,
    this.imagePath,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════════════════
class _DesignTokens {
  _DesignTokens._();

  // Spacing scale
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space6 = 6;
  static const double space8 = 8;
  static const double space10 = 10;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;

  // Border radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;

  // Typography
  static TextStyle get labelXs => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: _Colors.textTertiary,
  );

  static TextStyle get labelSm => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: _Colors.textSecondary,
  );

  static TextStyle get titleSm => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: _Colors.textPrimary,
  );

  static TextStyle get titleMd => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: _Colors.textPrimary,
  );

  static TextStyle get mono => GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: _Colors.textSecondary,
  );

  // Shadows
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
}

class _Colors {
  _Colors._();

  // Surfaces
  static const Color bgSecondary = Color(0xFF100E17);
  static const Color surface = Color(0xFF16141F);

  // Borders
  static const Color border = Color(0xFF2A2838);
  static const Color borderSubtle = Color(0xFF1E1C28);

  // Text
  static const Color textPrimary = Color(0xFFF5F4F8);
  static const Color textSecondary = Color(0xFFA09CAC);
  static const Color textTertiary = Color(0xFF6E6A7A);

  // Accent colors
  static const Color violet = Color(0xFF9580FF);
  static const Color emerald = Color(0xFF4ADE80);
  static const Color sky = Color(0xFF38BDF8);
  static const Color amber = Color(0xFFFBBF24);
  static const Color coral = Color(0xFFF87171);
  static const Color indigo = Color(0xFF6366F1);
  static const Color lavender = Color(0xFFA78BFA);
  static const Color gold = Color(0xFFCFAE54);
  static const Color rose = Color(0xFFF472B6);
  static const Color teal = Color(0xFF2DD4BF);
}

// ═══════════════════════════════════════════════════════════════════════════
// INSIGHT BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════
void _showInsightSheet(BuildContext context, InsightData insight) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (context) => _InsightBottomSheet(insight: insight),
  );
}

class _InsightBottomSheet extends StatefulWidget {
  final InsightData insight;

  const _InsightBottomSheet({required this.insight});

  @override
  State<_InsightBottomSheet> createState() => _InsightBottomSheetState();
}

class _InsightBottomSheetState extends State<_InsightBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insight = widget.insight;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: _Colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(
              color: insight.accentColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: insight.accentColor.withOpacity(0.15),
              blurRadius: 40,
              spreadRadius: -10,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: insight.accentColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with image
                    Row(
                      children: [
                        if (insight.imagePath != null)
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: insight.accentColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                insight.imagePath!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            insight.accentColor.withOpacity(
                                              0.2,
                                            ),
                                            insight.accentColor.withOpacity(
                                              0.05,
                                            ),
                                          ],
                                        ),
                                      ),
                                      child: Icon(
                                        insight.icon,
                                        size: 28,
                                        color: insight.accentColor,
                                      ),
                                    ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  insight.accentColor.withOpacity(0.2),
                                  insight.accentColor.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: insight.accentColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              insight.icon,
                              size: 28,
                              color: insight.accentColor,
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                insight.title.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: insight.accentColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                insight.value,
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: _Colors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            insight.accentColor.withOpacity(0.3),
                            insight.accentColor.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description
                    Text(
                      'What This Means',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: _Colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      insight.description,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: _Colors.textPrimary,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Significance card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: insight.accentColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: insight.accentColor.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: insight.accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              size: 16,
                              color: insight.accentColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Significance',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: insight.accentColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  insight.significance,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: _Colors.textPrimary,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Key points
                    if (insight.keyPoints.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Key Points',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: _Colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...insight.keyPoints.asMap().entries.map((entry) {
                        final index = entry.key;
                        final point = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: insight.accentColor.withOpacity(
                                    1.0 - (index * 0.12),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  point,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: _Colors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INSIGHT GENERATORS
// ═══════════════════════════════════════════════════════════════════════════
InsightData _getPlanetInsight(
  PlanetPosition planet,
  String dignity,
  String nature,
  bool isCombust,
  String nakshatraLord,
  int nakshatraPada,
) {
  final planetColor = _getPlanetColor(planet.planet);

  final planetDescriptions = {
    'Sun':
        'The Sun represents your soul, ego, vitality, and life force. It shows your core identity, self-expression, and relationship with authority. A strong Sun gives confidence, leadership qualities, and recognition.',
    'Moon':
        'The Moon represents your mind, emotions, and subconscious patterns. It shows your emotional nature, mental peace, and connection with the mother. A strong Moon gives emotional stability and intuition.',
    'Mars':
        'Mars represents courage, energy, aggression, and action. It shows your drive, competitive spirit, and how you assert yourself. A strong Mars gives determination, physical strength, and the ability to overcome obstacles.',
    'Mercury':
        'Mercury represents intellect, communication, and analytical ability. It shows your thinking patterns, speech, and business acumen. A strong Mercury gives sharp wit, good communication skills, and adaptability.',
    'Jupiter':
        'Jupiter represents wisdom, knowledge, expansion, and good fortune. It shows your philosophical outlook, teaching ability, and spiritual growth. A strong Jupiter brings blessings, optimism, and prosperity.',
    'Venus':
        'Venus represents love, beauty, pleasures, and relationships. It shows your romantic nature, artistic talents, and appreciation for luxury. A strong Venus gives charm, creativity, and harmonious relationships.',
    'Saturn':
        'Saturn represents discipline, responsibility, karma, and life lessons. It shows your endurance, work ethic, and areas of restriction. A strong Saturn gives perseverance, maturity, and long-lasting achievements.',
    'Rahu':
        'Rahu represents desires, obsessions, and worldly ambitions. It shows your unconventional side, foreign connections, and areas of intense focus. Rahu amplifies whatever it touches and drives material pursuits.',
    'Ketu':
        'Ketu represents spirituality, detachment, and past life karma. It shows your intuitive abilities, liberation tendencies, and areas where you seek transcendence. Ketu brings wisdom through letting go.',
  };

  final dignityInfo =
      dignity.isNotEmpty ? ' Currently $dignity in ${planet.sign}.' : '';
  final combustInfo =
      isCombust
          ? ' This planet is combust (too close to Sun), which reduces its strength.'
          : '';
  final retroInfo =
      planet.isRetrograde && planet.planet != 'Rahu' && planet.planet != 'Ketu'
          ? ' Currently retrograde, which intensifies its internal effects.'
          : '';

  return InsightData(
    title: 'Planet',
    value: planet.planet,
    description:
        '${planetDescriptions[planet.planet] ?? "This planet influences specific life areas."}$dignityInfo$combustInfo$retroInfo',
    significance:
        '${planet.planet} is placed in ${planet.sign} at ${planet.signDegree.toStringAsFixed(2)}° in House ${planet.house}. The Nakshatra is ${planet.nakshatra} (Pada $nakshatraPada), ruled by $nakshatraLord. This is a $nature planet.',
    keyPoints: [
      'Sign: ${planet.sign} (${_getSignSymbol(planet.sign)})',
      'House: ${planet.house}${_getOrdinal(planet.house)}',
      'Degree: ${planet.signDegree.toStringAsFixed(2)}°',
      'Nakshatra: ${planet.nakshatra} (Pada $nakshatraPada)',
      'Nakshatra Lord: $nakshatraLord',
      if (dignity.isNotEmpty) 'Dignity: $dignity',
      if (planet.isRetrograde &&
          planet.planet != 'Rahu' &&
          planet.planet != 'Ketu')
        'Status: Retrograde',
      if (isCombust) 'Status: Combust',
      'Nature: $nature',
    ],
    accentColor: planetColor,
    icon: Icons.blur_circular_rounded,
    imagePath: getPlanetImagePath(planet.planet),
  );
}

InsightData _getDignityInsight(String dignity, String planet, String sign) {
  final dignityDescriptions = {
    'Exalted':
        'The planet is exalted, meaning it\'s in its strongest possible position. Exalted planets give their best results and indicate areas of natural talent and blessing in your life.',
    'Debilitated':
        'The planet is debilitated, in its weakest position. While this can indicate challenges, it also shows areas for growth and spiritual development. The effects can be cancelled through various yogas.',
    'Own Sign':
        'The planet is in its own sign, feeling comfortable and at home. This gives stability and consistency in the areas the planet governs.',
    'Moolatrikona':
        'The planet is in its Moolatrikona sign, its second-best position after exaltation. This is considered a very powerful placement.',
    'Friendly':
        'The planet is in a friendly sign, where it receives support from the sign lord. This generally gives favorable results.',
    'Enemy':
        'The planet is in an enemy sign, creating some friction with the sign lord. This may require extra effort in related life areas.',
    'Neutral':
        'The planet is in a neutral sign, giving balanced results based on other chart factors.',
  };

  final dignityColor = _getDignityColor(dignity);

  return InsightData(
    title: 'Planetary Dignity',
    value: dignity,
    description:
        dignityDescriptions[dignity] ??
        'This dignity status affects how the planet expresses its energy.',
    significance:
        '$planet in $sign is $dignity. This affects the strength and quality of the planet\'s results in your life.',
    keyPoints: [
      'Planet: $planet',
      'Sign: $sign',
      'Dignity: $dignity',
      dignity == 'Exalted'
          ? 'Strength: Maximum (100%)'
          : dignity == 'Moolatrikona'
          ? 'Strength: Very High (85%)'
          : dignity == 'Own Sign'
          ? 'Strength: High (75%)'
          : dignity == 'Friendly'
          ? 'Strength: Good (60%)'
          : dignity == 'Neutral'
          ? 'Strength: Moderate (50%)'
          : dignity == 'Enemy'
          ? 'Strength: Reduced (35%)'
          : 'Strength: Low (25%)',
    ],
    accentColor: dignityColor,
    icon:
        dignity == 'Exalted'
            ? Icons.arrow_upward_rounded
            : dignity == 'Debilitated'
            ? Icons.arrow_downward_rounded
            : Icons.swap_vert_rounded,
  );
}

InsightData _getNakshatraInsight(String nakshatra, String lord, int pada) {
  final nakshatraInfo = {
    'Ashwini': {
      'deity': 'Ashwini Kumaras',
      'symbol': 'Horse head',
      'nature': 'Swift, healing',
    },
    'Bharani': {
      'deity': 'Yama',
      'symbol': 'Yoni',
      'nature': 'Restraint, transformation',
    },
    'Krittika': {
      'deity': 'Agni',
      'symbol': 'Razor/Flame',
      'nature': 'Sharp, cutting',
    },
    'Rohini': {
      'deity': 'Brahma',
      'symbol': 'Ox cart',
      'nature': 'Creative, growing',
    },
    'Mrigashira': {
      'deity': 'Soma',
      'symbol': 'Deer head',
      'nature': 'Searching, gentle',
    },
    'Ardra': {
      'deity': 'Rudra',
      'symbol': 'Teardrop',
      'nature': 'Stormy, transformative',
    },
    'Punarvasu': {
      'deity': 'Aditi',
      'symbol': 'Bow/Quiver',
      'nature': 'Renewal, return',
    },
    'Pushya': {
      'deity': 'Brihaspati',
      'symbol': 'Flower/Circle',
      'nature': 'Nourishing, auspicious',
    },
    'Ashlesha': {
      'deity': 'Nagas',
      'symbol': 'Serpent',
      'nature': 'Clinging, mystical',
    },
    'Magha': {
      'deity': 'Pitris',
      'symbol': 'Throne',
      'nature': 'Royal, ancestral',
    },
    'Purva Phalguni': {
      'deity': 'Bhaga',
      'symbol': 'Hammock',
      'nature': 'Pleasure, relaxation',
    },
    'Uttara Phalguni': {
      'deity': 'Aryaman',
      'symbol': 'Bed',
      'nature': 'Friendship, contracts',
    },
    'Hasta': {
      'deity': 'Savitar',
      'symbol': 'Hand',
      'nature': 'Skillful, crafty',
    },
    'Chitra': {
      'deity': 'Vishwakarma',
      'symbol': 'Jewel',
      'nature': 'Brilliant, creative',
    },
    'Swati': {
      'deity': 'Vayu',
      'symbol': 'Coral',
      'nature': 'Independent, flexible',
    },
    'Vishakha': {
      'deity': 'Indra-Agni',
      'symbol': 'Archway',
      'nature': 'Determined, goal-oriented',
    },
    'Anuradha': {
      'deity': 'Mitra',
      'symbol': 'Lotus',
      'nature': 'Friendship, devotion',
    },
    'Jyeshtha': {
      'deity': 'Indra',
      'symbol': 'Earring',
      'nature': 'Chief, protective',
    },
    'Mula': {
      'deity': 'Nirriti',
      'symbol': 'Roots',
      'nature': 'Uprooting, foundational',
    },
    'Purva Ashadha': {
      'deity': 'Apas',
      'symbol': 'Fan',
      'nature': 'Invincible, purifying',
    },
    'Uttara Ashadha': {
      'deity': 'Vishve Devas',
      'symbol': 'Tusk',
      'nature': 'Universal, victorious',
    },
    'Shravana': {
      'deity': 'Vishnu',
      'symbol': 'Ear',
      'nature': 'Listening, learning',
    },
    'Dhanishta': {
      'deity': 'Vasus',
      'symbol': 'Drum',
      'nature': 'Wealthy, musical',
    },
    'Shatabhisha': {
      'deity': 'Varuna',
      'symbol': 'Empty circle',
      'nature': 'Healing, mysterious',
    },
    'Purva Bhadrapada': {
      'deity': 'Aja Ekapada',
      'symbol': 'Sword',
      'nature': 'Intense, fiery',
    },
    'Uttara Bhadrapada': {
      'deity': 'Ahir Budhnya',
      'symbol': 'Twin/Serpent',
      'nature': 'Deep, wise',
    },
    'Revati': {
      'deity': 'Pushan',
      'symbol': 'Fish',
      'nature': 'Nourishing, protective',
    },
  };

  final info =
      nakshatraInfo[nakshatra] ??
      {'deity': 'Unknown', 'symbol': 'Unknown', 'nature': 'Unknown'};
  final lordColor = _getPlanetColor(lord);

  return InsightData(
    title: 'Nakshatra',
    value: '$nakshatra (Pada $pada)',
    description:
        '$nakshatra is one of the 27 lunar mansions in Vedic astrology. Its symbol is ${info['symbol']} and it embodies the quality of being ${info['nature']}. The presiding deity is ${info['deity']}.',
    significance:
        'This Nakshatra is ruled by $lord, which influences the Vimshottari Dasha sequence. Pada $pada of $nakshatra falls in the ${_getPadaSign(nakshatra, pada)} navamsa.',
    keyPoints: [
      'Nakshatra: $nakshatra',
      'Pada: $pada of 4',
      'Lord: $lord',
      'Deity: ${info['deity']}',
      'Symbol: ${info['symbol']}',
      'Nature: ${info['nature']}',
    ],
    accentColor: lordColor,
    icon: Icons.star_rounded,
  );
}

String _getPadaSign(String nakshatra, int pada) {
  // Simplified - each nakshatra's 4 padas correspond to different navamsa signs
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
  // This is a simplification - actual calculation is more complex
  return signs[(pada - 1) % 12];
}

String _getOrdinal(int n) {
  if (n == 1) return 'st';
  if (n == 2) return 'nd';
  if (n == 3) return 'rd';
  return 'th';
}

Color _getDignityColor(String dignity) {
  switch (dignity) {
    case 'Exalted':
      return const Color(0xFF6EE7B7);
    case 'Moolatrikona':
      return const Color(0xFF22D3EE);
    case 'Own Sign':
      return const Color(0xFF60A5FA);
    case 'Friendly':
      return const Color(0xFFA78BFA);
    case 'Neutral':
      return _Colors.textTertiary;
    case 'Enemy':
      return const Color(0xFFFBBF24);
    case 'Debilitated':
      return const Color(0xFFF87171);
    default:
      return _Colors.textTertiary;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NAVIGATION SECTION DATA
// ═══════════════════════════════════════════════════════════════════════════
// Planet order for consistent display
const _planetOrder = [
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

List<NavSection> _buildSections(List<String> planetNames) {
  final sections = <NavSection>[
    const NavSection(id: 'overview', label: 'Overview', color: _Colors.violet),
  ];

  for (final name in planetNames) {
    sections.add(
      NavSection(
        id: name.toLowerCase(),
        label: name,
        color: _getPlanetColor(name),
      ),
    );
  }

  return sections;
}

/// Planets Tab - Shows all planetary positions with comprehensive details
/// Premium, elegant UI with clear visual hierarchy
class PlanetsTab extends StatefulWidget {
  final KundaliData kundaliData;

  const PlanetsTab({super.key, required this.kundaliData});

  @override
  State<PlanetsTab> createState() => _PlanetsTabState();
}

class _PlanetsTabState extends State<PlanetsTab> {
  late final ScrollController _scrollController;
  final Map<String, GlobalKey> _sectionKeys = {};
  final Map<String, GlobalKey<_AnimatedSectionWrapperState>> _animatedKeys = {};
  late List<NavSection> _sections;
  late List<PlanetPosition> _sortedPlanets;
  int _activeIndex = 0;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Sort planets in proper order
    _sortedPlanets = _getSortedPlanets();

    // Build sections dynamically from actual planet data
    final planetNames = _sortedPlanets.map((p) => p.planet).toList();
    _sections = _buildSections(planetNames);

    // Initialize keys for each section
    for (final section in _sections) {
      _sectionKeys[section.id] = GlobalKey();
      _animatedKeys[section.id] = GlobalKey<_AnimatedSectionWrapperState>();
    }
  }

  List<PlanetPosition> _getSortedPlanets() {
    final planets = widget.kundaliData.planetPositions.values.toList();
    planets.sort((a, b) {
      final aIndex = _planetOrder.indexOf(a.planet);
      final bIndex = _planetOrder.indexOf(b.planet);
      if (aIndex == -1 && bIndex == -1) return 0;
      if (aIndex == -1) return 1;
      if (bIndex == -1) return -1;
      return aIndex.compareTo(bIndex);
    });
    return planets;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isScrolling) return;

    final viewportHeight = _scrollController.position.viewportDimension;
    final triggerPoint = viewportHeight * 0.3;

    int newActiveIndex = 0;

    for (int i = 0; i < _sections.length; i++) {
      final key = _sectionKeys[_sections[i].id];
      if (key?.currentContext != null) {
        final box = key!.currentContext!.findRenderObject() as RenderBox?;
        if (box != null) {
          final position = box.localToGlobal(Offset.zero);
          if (position.dy <= triggerPoint + 100) {
            newActiveIndex = i;
          }
        }
      }
    }

    if (newActiveIndex != _activeIndex) {
      setState(() => _activeIndex = newActiveIndex);
    }
  }

  Future<void> _scrollToSection(int index) async {
    final section = _sections[index];
    final key = _sectionKeys[section.id];

    if (key?.currentContext == null) return;

    HapticFeedback.lightImpact();

    setState(() {
      _isScrolling = true;
      _activeIndex = index;
    });

    await Scrollable.ensureVisible(
      key!.currentContext!,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );

    // Trigger the section highlight animation
    _animatedKeys[section.id]?.currentState?.triggerHighlight();

    setState(() => _isScrolling = false);
  }

  @override
  Widget build(BuildContext context) {
    final sunPosition = widget.kundaliData.planetPositions['Sun'];
    final stats = _calculatePlanetStats(_sortedPlanets, sunPosition);

    return Stack(
      children: [
        // Scrollable content
        SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Section
              _AnimatedSectionWrapper(
                key: _animatedKeys['overview'],
                sectionKey: _sectionKeys['overview']!,
                accentColor: _Colors.violet,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _AnimatedSectionHeader(
                      title: 'Overview',
                      subtitle: 'Planetary positions summary',
                      accentColor: _Colors.violet,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      child: _SummaryCard(
                        stats: stats,
                        totalPlanets: _sortedPlanets.length,
                      ),
                    ),
                    const SizedBox(height: _DesignTokens.space16),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: const _DignityLegend(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // Individual Planet Cards
              ..._sortedPlanets.map((planet) {
                final sectionId = planet.planet.toLowerCase();
                final sectionKey = _sectionKeys[sectionId];
                final animatedKey = _animatedKeys[sectionId];
                final color = _getPlanetColor(planet.planet);
                final dignity = _calculateDignity(planet.planet, planet.sign);
                final nakshatraLord = _getNakshatraLord(planet.nakshatra);
                final nakshatraPada = _calculateNakshatraPada(planet.longitude);
                final isCombust = _checkCombustion(planet, sunPosition);
                final nature = _getPlanetNature(planet.planet);

                // Skip if section keys not found (shouldn't happen, but safety check)
                if (sectionKey == null) {
                  return _PlanetCard(
                    planet: planet,
                    color: color,
                    dignity: dignity,
                    nakshatraLord: nakshatraLord,
                    nakshatraPada: nakshatraPada,
                    isCombust: isCombust,
                    nature: nature,
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: _DesignTokens.space12),
                  child: _AnimatedSectionWrapper(
                    key: animatedKey,
                    sectionKey: sectionKey,
                    accentColor: color,
                    child: _AnimatedCardWrapper(
                      child: _PlanetCard(
                        planet: planet,
                        color: color,
                        dignity: dignity,
                        nakshatraLord: nakshatraLord,
                        nakshatraPada: nakshatraPada,
                        isCombust: isCombust,
                        nature: nature,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // Floating bottom navigation
        Positioned(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          child: FloatingNavBar(
            sections: _sections,
            activeIndex: _activeIndex,
            onTap: _scrollToSection,
          ),
        ),
      ],
    );
  }

  Map<String, int> _calculatePlanetStats(
    List<PlanetPosition> planets,
    PlanetPosition? sunPosition,
  ) {
    int exalted = 0;
    int debilitated = 0;
    int retrograde = 0;
    int combust = 0;

    for (final planet in planets) {
      final dignity = _calculateDignity(planet.planet, planet.sign);
      if (dignity == 'Exalted') exalted++;
      if (dignity == 'Debilitated') debilitated++;
      if (planet.isRetrograde &&
          planet.planet != 'Rahu' &&
          planet.planet != 'Ketu') {
        retrograde++;
      }
      if (_checkCombustion(planet, sunPosition)) combust++;
    }

    return {
      'exalted': exalted,
      'debilitated': debilitated,
      'retrograde': retrograde,
      'combust': combust,
    };
  }

  String _calculateDignity(String planetName, String sign) {
    const exaltation = {
      'Sun': 'Aries',
      'Moon': 'Taurus',
      'Mars': 'Capricorn',
      'Mercury': 'Virgo',
      'Jupiter': 'Cancer',
      'Venus': 'Pisces',
      'Saturn': 'Libra',
      'Rahu': 'Taurus',
      'Ketu': 'Scorpio',
    };

    const debilitation = {
      'Sun': 'Libra',
      'Moon': 'Scorpio',
      'Mars': 'Cancer',
      'Mercury': 'Pisces',
      'Jupiter': 'Capricorn',
      'Venus': 'Virgo',
      'Saturn': 'Aries',
      'Rahu': 'Scorpio',
      'Ketu': 'Taurus',
    };

    const ownSigns = {
      'Sun': ['Leo'],
      'Moon': ['Cancer'],
      'Mars': ['Aries', 'Scorpio'],
      'Mercury': ['Gemini', 'Virgo'],
      'Jupiter': ['Sagittarius', 'Pisces'],
      'Venus': ['Taurus', 'Libra'],
      'Saturn': ['Capricorn', 'Aquarius'],
      'Rahu': ['Aquarius'],
      'Ketu': ['Scorpio'],
    };

    const moolatrikona = {
      'Sun': 'Leo',
      'Moon': 'Taurus',
      'Mars': 'Aries',
      'Mercury': 'Virgo',
      'Jupiter': 'Sagittarius',
      'Venus': 'Libra',
      'Saturn': 'Aquarius',
    };

    if (exaltation[planetName] == sign) return 'Exalted';
    if (debilitation[planetName] == sign) return 'Debilitated';
    if (ownSigns[planetName]?.contains(sign) == true) {
      if (moolatrikona[planetName] == sign) return 'Moolatrikona';
      return 'Own Sign';
    }

    final friendlyEnemy = _getFriendlyEnemyStatus(planetName, sign);
    if (friendlyEnemy.isNotEmpty) return friendlyEnemy;

    return '';
  }

  String _getFriendlyEnemyStatus(String planet, String sign) {
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
      'Moon': <String>[],
      'Mars': ['Mercury'],
      'Mercury': ['Moon'],
      'Jupiter': ['Mercury', 'Venus'],
      'Venus': ['Sun', 'Moon'],
      'Saturn': ['Sun', 'Moon', 'Mars'],
    };

    final signLord = signLords[sign];
    if (signLord == null) return '';

    if (friends[planet]?.contains(signLord) == true) return 'Friendly';
    if (enemies[planet]?.contains(signLord) == true) return 'Enemy';

    return 'Neutral';
  }

  String _getNakshatraLord(String nakshatra) {
    const lords = {
      'Ashwini': 'Ketu',
      'Bharani': 'Venus',
      'Krittika': 'Sun',
      'Rohini': 'Moon',
      'Mrigashira': 'Mars',
      'Ardra': 'Rahu',
      'Punarvasu': 'Jupiter',
      'Pushya': 'Saturn',
      'Ashlesha': 'Mercury',
      'Magha': 'Ketu',
      'Purva Phalguni': 'Venus',
      'Uttara Phalguni': 'Sun',
      'Hasta': 'Moon',
      'Chitra': 'Mars',
      'Swati': 'Rahu',
      'Vishakha': 'Jupiter',
      'Anuradha': 'Saturn',
      'Jyeshtha': 'Mercury',
      'Mula': 'Ketu',
      'Purva Ashadha': 'Venus',
      'Uttara Ashadha': 'Sun',
      'Shravana': 'Moon',
      'Dhanishta': 'Mars',
      'Shatabhisha': 'Rahu',
      'Purva Bhadrapada': 'Jupiter',
      'Uttara Bhadrapada': 'Saturn',
      'Revati': 'Mercury',
    };
    return lords[nakshatra] ?? 'Unknown';
  }

  int _calculateNakshatraPada(double longitude) {
    // Each nakshatra = 360°/27 = 13.333...°
    // Each pada = 360°/108 = 3.333...°
    const double nakshatraSpan = 360.0 / 27.0;
    const double padaSpan = 360.0 / 108.0;

    final nakshatraPosition = longitude % nakshatraSpan;
    final pada = (nakshatraPosition / padaSpan).floor() + 1;
    return pada.clamp(1, 4);
  }

  bool _checkCombustion(PlanetPosition planet, PlanetPosition? sunPosition) {
    if (sunPosition == null ||
        planet.planet == 'Sun' ||
        planet.planet == 'Rahu' ||
        planet.planet == 'Ketu') {
      return false;
    }

    const combustionOrbs = {
      'Moon': 12.0,
      'Mars': 17.0,
      'Mercury': 14.0,
      'Jupiter': 11.0,
      'Venus': 10.0,
      'Saturn': 15.0,
    };

    final orb = combustionOrbs[planet.planet];
    if (orb == null) return false;

    double distance = (planet.longitude - sunPosition.longitude).abs();
    if (distance > 180) distance = 360 - distance;

    return distance <= orb;
  }

  String _getPlanetNature(String planet) {
    const benefics = ['Jupiter', 'Venus', 'Moon', 'Mercury'];
    const malefics = ['Sun', 'Mars', 'Saturn', 'Rahu', 'Ketu'];

    if (benefics.contains(planet)) return 'Benefic';
    if (malefics.contains(planet)) return 'Malefic';
    return 'Neutral';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATED SECTION WRAPPER
// ═══════════════════════════════════════════════════════════════════════════
class _AnimatedSectionWrapper extends StatefulWidget {
  final GlobalKey sectionKey;
  final Color accentColor;
  final Widget child;

  const _AnimatedSectionWrapper({
    super.key,
    required this.sectionKey,
    required this.accentColor,
    required this.child,
  });

  @override
  State<_AnimatedSectionWrapper> createState() =>
      _AnimatedSectionWrapperState();
}

class _AnimatedSectionWrapperState extends State<_AnimatedSectionWrapper> {
  bool _isHighlighted = false;

  void triggerHighlight() {
    HapticFeedback.lightImpact();
    setState(() => _isHighlighted = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isHighlighted = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SectionAnimationProvider(
      isHighlighted: _isHighlighted,
      accentColor: widget.accentColor,
      child: Container(key: widget.sectionKey, child: widget.child),
    );
  }
}

class _SectionAnimationProvider extends InheritedWidget {
  final bool isHighlighted;
  final Color accentColor;

  const _SectionAnimationProvider({
    required this.isHighlighted,
    required this.accentColor,
    required super.child,
  });

  static _SectionAnimationProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_SectionAnimationProvider>();
  }

  @override
  bool updateShouldNotify(_SectionAnimationProvider oldWidget) {
    return isHighlighted != oldWidget.isHighlighted;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATED CARD WRAPPER
// ═══════════════════════════════════════════════════════════════════════════
class _AnimatedCardWrapper extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedCardWrapper({required this.child, this.delay = 0});

  @override
  State<_AnimatedCardWrapper> createState() => _AnimatedCardWrapperState();
}

class _AnimatedCardWrapperState extends State<_AnimatedCardWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.025,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.025,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 65,
      ),
    ]).animate(_controller);

    _shadowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 70,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = _SectionAnimationProvider.of(context);
    if (provider?.isHighlighted == true) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _controller.forward(from: 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = _SectionAnimationProvider.of(context);
    final accentColor = provider?.accentColor ?? _Colors.violet;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = _scaleAnimation.value;
        final shadow = _shadowAnimation.value;

        return Transform.scale(
          scale: scale,
          child: Container(
            decoration:
                shadow > 0.01
                    ? BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        _DesignTokens.radiusLg,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(shadow * 0.2),
                          blurRadius: 16 * shadow,
                          spreadRadius: -4,
                          offset: Offset(0, 4 * shadow),
                        ),
                      ],
                    )
                    : null,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATED SECTION HEADER
// ═══════════════════════════════════════════════════════════════════════════
class _AnimatedSectionHeader extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Color accentColor;

  const _AnimatedSectionHeader({
    required this.title,
    this.subtitle,
    required this.accentColor,
  });

  @override
  State<_AnimatedSectionHeader> createState() => _AnimatedSectionHeaderState();
}

class _AnimatedSectionHeaderState extends State<_AnimatedSectionHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _underlineAnimation;
  late Animation<double> _textPulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _underlineAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    );

    _textPulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 70,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = _SectionAnimationProvider.of(context);
    if (provider?.isHighlighted == true) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final textPulse = _textPulseAnimation.value;
        final underlineWidth = _underlineAnimation.value;

        final textColor =
            Color.lerp(
              _Colors.textTertiary,
              widget.accentColor,
              textPulse * 0.8,
            )!;

        return Padding(
          padding: const EdgeInsets.only(left: _DesignTokens.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: textColor,
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle!,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: _Colors.textTertiary,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth * 0.25;
                  return Container(
                    height: 2,
                    width: maxWidth * underlineWidth,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(
                        0.6 + textPulse * 0.4,
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUMMARY CARD - Interactive
// ═══════════════════════════════════════════════════════════════════════════
class _SummaryCard extends StatefulWidget {
  final Map<String, int> stats;
  final int totalPlanets;

  const _SummaryCard({required this.stats, required this.totalPlanets});

  @override
  State<_SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<_SummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.selectionClick();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    _showInsightSheet(
      context,
      InsightData(
        title: 'Graha Sthiti',
        value: 'Planetary Overview',
        description:
            'Graha Sthiti shows the positions of all nine planets (Navagrahas) in your birth chart. These positions are calculated using the Swiss Ephemeris for astronomical precision and then mapped to the Vedic sidereal zodiac.',
        significance:
            'Your chart has ${widget.totalPlanets} planets positioned across different signs and houses. ${widget.stats['exalted'] ?? 0} planet(s) are exalted (strongest), ${widget.stats['debilitated'] ?? 0} are debilitated, ${widget.stats['retrograde'] ?? 0} are retrograde, and ${widget.stats['combust'] ?? 0} are combust.',
        keyPoints: [
          'Total Planets: ${widget.totalPlanets}',
          'Exalted: ${widget.stats['exalted'] ?? 0} (Maximum strength)',
          'Debilitated: ${widget.stats['debilitated'] ?? 0} (Need remedies)',
          'Retrograde: ${widget.stats['retrograde'] ?? 0} (Internal effects)',
          'Combust: ${widget.stats['combust'] ?? 0} (Hidden energy)',
          'Calculations: Swiss Ephemeris + Lahiri Ayanamsa',
        ],
        accentColor: _Colors.violet,
        icon: Icons.blur_on_rounded,
      ),
    );
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _Colors.surface,
                borderRadius: BorderRadius.circular(_DesignTokens.radiusLg),
                border: Border.all(
                  color:
                      _isPressed
                          ? _Colors.violet.withOpacity(0.3)
                          : _Colors.borderSubtle,
                  width: 1,
                ),
                boxShadow: _DesignTokens.shadowSm,
              ),
              child: child,
            ),
          );
        },
        child: Column(
          children: [
            // Header row
            Row(
              children: [
                // Planet count badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _Colors.violet.withOpacity(_isPressed ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(_DesignTokens.radiusMd),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.totalPlanets}',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _Colors.violet,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Graha Sthiti',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _Colors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 150),
                            opacity: _isPressed ? 1.0 : 0.4,
                            child: Icon(
                              Icons.info_outline_rounded,
                              size: 14,
                              color: _Colors.violet,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Planetary positions via Swiss Ephemeris',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _Colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Stats row - interactive chips
            Row(
              children: [
                _InteractiveStatChip(
                  value: widget.stats['exalted'] ?? 0,
                  label: 'Exalt',
                  color: _Colors.emerald,
                  description:
                      'Exalted planets are in their strongest position, giving maximum positive results.',
                ),
                const SizedBox(width: 6),
                _InteractiveStatChip(
                  value: widget.stats['debilitated'] ?? 0,
                  label: 'Debil',
                  color: _Colors.coral,
                  description:
                      'Debilitated planets are in their weakest position, requiring remedies for better results.',
                ),
                const SizedBox(width: 6),
                _InteractiveStatChip(
                  value: widget.stats['retrograde'] ?? 0,
                  label: 'Retro',
                  color: _Colors.amber,
                  description:
                      'Retrograde planets move backwards (apparent motion), intensifying internal effects.',
                ),
                const SizedBox(width: 6),
                _InteractiveStatChip(
                  value: widget.stats['combust'] ?? 0,
                  label: 'Comb',
                  color: _Colors.coral,
                  description:
                      'Combust planets are too close to Sun, their energy gets hidden or weakened.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveStatChip extends StatefulWidget {
  final int value;
  final String label;
  final Color color;
  final String description;

  const _InteractiveStatChip({
    required this.value,
    required this.label,
    required this.color,
    required this.description,
  });

  @override
  State<_InteractiveStatChip> createState() => _InteractiveStatChipState();
}

class _InteractiveStatChipState extends State<_InteractiveStatChip> {
  bool _isPressed = false;

  void _showStatInsight() {
    if (widget.value == 0) return;

    HapticFeedback.selectionClick();
    _showInsightSheet(
      context,
      InsightData(
        title: 'Planetary Status',
        value: '${widget.value} ${widget.label}',
        description: widget.description,
        significance:
            'You have ${widget.value} planet(s) with this status in your birth chart.',
        keyPoints: [
          'Count: ${widget.value} planets',
          'Status: ${widget.label}',
          widget.description,
        ],
        accentColor: widget.color,
        icon:
            widget.label == 'Exalt'
                ? Icons.arrow_upward_rounded
                : widget.label == 'Debil'
                ? Icons.arrow_downward_rounded
                : widget.label == 'Retro'
                ? Icons.replay_rounded
                : Icons.whatshot_rounded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.value > 0;

    return Expanded(
      child: GestureDetector(
        onTapDown: isActive ? (_) => setState(() => _isPressed = true) : null,
        onTapUp:
            isActive
                ? (_) {
                  setState(() => _isPressed = false);
                  _showStatInsight();
                }
                : null,
        onTapCancel: isActive ? () => setState(() => _isPressed = false) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:
                isActive
                    ? widget.color.withOpacity(_isPressed ? 0.2 : 0.1)
                    : _Colors.bgSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  _isPressed && isActive
                      ? widget.color.withOpacity(0.4)
                      : Colors.transparent,
              width: 1,
            ),
            boxShadow:
                _isPressed && isActive
                    ? [
                      BoxShadow(
                        color: widget.color.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: -2,
                      ),
                    ]
                    : null,
          ),
          child: Column(
            children: [
              Text(
                '${widget.value}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isActive ? widget.color : _Colors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color:
                      isActive
                          ? widget.color.withOpacity(0.8)
                          : _Colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DIGNITY LEGEND - Interactive
// ═══════════════════════════════════════════════════════════════════════════
class _DignityLegend extends StatelessWidget {
  const _DignityLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _Colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _Colors.violet.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.format_list_bulleted_rounded,
                  size: 12,
                  color: _Colors.violet,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Planetary Dignities',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _Colors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                'Tap planets for details',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: _Colors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _InteractiveLegendDot(
                  label: 'Exalted',
                  shortLabel: 'Exalt',
                  color: const Color(0xFF6EE7B7),
                  description:
                      'Maximum strength - the planet gives its best results',
                ),
                _InteractiveLegendDot(
                  label: 'Moolatrikona',
                  shortLabel: 'Moola',
                  color: const Color(0xFF22D3EE),
                  description: 'Second strongest position after exaltation',
                ),
                _InteractiveLegendDot(
                  label: 'Own Sign',
                  shortLabel: 'Own',
                  color: const Color(0xFF60A5FA),
                  description:
                      'Planet in its own sign - comfortable and stable',
                ),
                _InteractiveLegendDot(
                  label: 'Friendly',
                  shortLabel: 'Friend',
                  color: const Color(0xFFA78BFA),
                  description:
                      'Planet in a friendly sign - supportive environment',
                ),
                _InteractiveLegendDot(
                  label: 'Neutral',
                  shortLabel: 'Neutral',
                  color: const Color(0xFF9CA3AF),
                  description: 'Neither strong nor weak - balanced results',
                ),
                _InteractiveLegendDot(
                  label: 'Enemy',
                  shortLabel: 'Enemy',
                  color: const Color(0xFFFBBF24),
                  description: 'Planet in an enemy sign - extra effort needed',
                ),
                _InteractiveLegendDot(
                  label: 'Debilitated',
                  shortLabel: 'Debil',
                  color: const Color(0xFFF87171),
                  description: 'Weakest position - may need remedial measures',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveLegendDot extends StatefulWidget {
  final String label;
  final String shortLabel;
  final Color color;
  final String description;

  const _InteractiveLegendDot({
    required this.label,
    required this.shortLabel,
    required this.color,
    required this.description,
  });

  @override
  State<_InteractiveLegendDot> createState() => _InteractiveLegendDotState();
}

class _InteractiveLegendDotState extends State<_InteractiveLegendDot> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        _showInsightSheet(
          context,
          InsightData(
            title: 'Planetary Dignity',
            value: widget.label,
            description: widget.description,
            significance:
                'Planetary dignity determines how strongly a planet can express its energy in your chart.',
            keyPoints: [
              'Dignity: ${widget.label}',
              widget.description,
              'Affects planetary strength and results',
            ],
            accentColor: widget.color,
            icon:
                widget.label == 'Exalted'
                    ? Icons.arrow_upward_rounded
                    : widget.label == 'Debilitated'
                    ? Icons.arrow_downward_rounded
                    : Icons.swap_vert_rounded,
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(_isPressed ? 0.2 : 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.color.withOpacity(_isPressed ? 0.4 : 0.15),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              widget.shortLabel,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PLANET CARD - Interactive Premium Design
// ═══════════════════════════════════════════════════════════════════════════
class _PlanetCard extends StatefulWidget {
  final PlanetPosition planet;
  final Color color;
  final String dignity;
  final String nakshatraLord;
  final int nakshatraPada;
  final bool isCombust;
  final String nature;

  const _PlanetCard({
    required this.planet,
    required this.color,
    required this.dignity,
    required this.nakshatraLord,
    required this.nakshatraPada,
    required this.isCombust,
    required this.nature,
  });

  @override
  State<_PlanetCard> createState() => _PlanetCardState();
}

class _PlanetCardState extends State<_PlanetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.selectionClick();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    _showInsightSheet(
      context,
      _getPlanetInsight(
        widget.planet,
        widget.dignity,
        widget.nature,
        widget.isCombust,
        widget.nakshatraLord,
        widget.nakshatraPada,
      ),
    );
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  String _shortenDignity(String dignity) {
    switch (dignity) {
      case 'Moolatrikona':
        return 'Moola';
      case 'Own Sign':
        return 'Own';
      case 'Debilitated':
        return 'Debil';
      default:
        return dignity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dignityColor = _getDignityColor(widget.dignity);
    final isRetrograde =
        widget.planet.isRetrograde &&
        widget.planet.planet != 'Rahu' &&
        widget.planet.planet != 'Ketu';

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                color: _Colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      _isPressed
                          ? widget.color.withOpacity(0.4)
                          : _Colors.borderSubtle,
                  width: _isPressed ? 1.5 : 1,
                ),
                boxShadow:
                    _isPressed
                        ? [
                          BoxShadow(
                            color: widget.color.withOpacity(0.2),
                            blurRadius: 16,
                            spreadRadius: -2,
                          ),
                        ]
                        : null,
              ),
              child: child,
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main content with left accent
            IntrinsicHeight(
              child: Row(
                children: [
                  // Left accent bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: _isPressed ? 4 : 3,
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                      boxShadow:
                          _isPressed
                              ? [
                                BoxShadow(
                                  color: widget.color.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: -2,
                                ),
                              ]
                              : null,
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Planet image with premium shadow
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                // Ambient shadow
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: -3,
                                  offset: const Offset(0, 4),
                                ),
                                // Color accent glow - enhanced on press
                                BoxShadow(
                                  color: widget.color.withOpacity(
                                    _isPressed ? 0.35 : 0.15,
                                  ),
                                  blurRadius: _isPressed ? 14 : 8,
                                  spreadRadius: _isPressed ? 0 : -2,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.asset(
                                getPlanetImagePath(widget.planet.planet),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to symbol
                                  return Container(
                                    color: widget.color.withOpacity(0.1),
                                    child: Center(
                                      child: Text(
                                        _getPlanetSymbol(widget.planet.planet),
                                        style: TextStyle(
                                          fontSize: 22,
                                          color: widget.color,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Info column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Name row with badges
                                Row(
                                  children: [
                                    Text(
                                      widget.planet.planet,
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: _Colors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    // Nature dot
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color:
                                            widget.nature == 'Benefic'
                                                ? _Colors.emerald
                                                : _Colors.coral,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: (widget.nature == 'Benefic'
                                                    ? _Colors.emerald
                                                    : _Colors.coral)
                                                .withOpacity(0.4),
                                            blurRadius: 4,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isRetrograde) ...[
                                      const SizedBox(width: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _Colors.amber.withOpacity(
                                            0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          'ℜ',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: _Colors.amber,
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (widget.isCombust) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.whatshot_rounded,
                                        size: 13,
                                        color: _Colors.coral,
                                      ),
                                    ],
                                    const Spacer(),
                                    // Info icon hint
                                    AnimatedOpacity(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      opacity: _isPressed ? 1.0 : 0.4,
                                      child: Icon(
                                        Icons.info_outline_rounded,
                                        size: 14,
                                        color: widget.color,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Badge row
                                Row(
                                  children: [
                                    // House badge
                                    _InteractiveBadge(
                                      label: 'H${widget.planet.house}',
                                      color: _Colors.sky,
                                      onTap: () {
                                        // Could show house insight
                                      },
                                    ),
                                    if (widget.dignity.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      _InteractiveBadge(
                                        label: _shortenDignity(widget.dignity),
                                        color: dignityColor,
                                        onTap: () {
                                          _showInsightSheet(
                                            context,
                                            _getDignityInsight(
                                              widget.dignity,
                                              widget.planet.planet,
                                              widget.planet.sign,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Position info - single compact row
                                Row(
                                  children: [
                                    // Zodiac sign image
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: getZodiacColor(
                                              widget.planet.sign,
                                            ).withOpacity(0.2),
                                            blurRadius: 4,
                                            spreadRadius: -1,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.asset(
                                          getZodiacImagePath(
                                            widget.planet.sign,
                                          ),
                                          width: 16,
                                          height: 16,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              color: getZodiacColor(
                                                widget.planet.sign,
                                              ).withOpacity(0.1),
                                              child: Center(
                                                child: Text(
                                                  _getSignSymbol(
                                                    widget.planet.sign,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: getZodiacColor(
                                                      widget.planet.sign,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      widget.planet.sign,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: _Colors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      ' · ',
                                      style: TextStyle(
                                        color: _Colors.textTertiary,
                                      ),
                                    ),
                                    Text(
                                      '${widget.planet.signDegree.toStringAsFixed(1)}°',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: _Colors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Nakshatra row - tappable
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    _showInsightSheet(
                                      context,
                                      _getNakshatraInsight(
                                        widget.planet.nakshatra,
                                        widget.nakshatraLord,
                                        widget.nakshatraPada,
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        size: 11,
                                        color: _Colors.amber.withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.planet.nakshatra,
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: _Colors.amber.withOpacity(0.8),
                                        ),
                                      ),
                                      Text(
                                        ' P${widget.nakshatraPada}',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: _Colors.textTertiary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: 12,
                                        color: _Colors.amber.withOpacity(0.4),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Combustion warning - minimal
            if (widget.isCombust)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _Colors.coral.withOpacity(0.08),
                      _Colors.coral.withOpacity(0.04),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(13),
                    bottomRight: Radius.circular(13),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _Colors.coral.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        size: 12,
                        color: _Colors.coral,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Combust · Reduced planetary strength due to Sun proximity',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: _Colors.coral.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INTERACTIVE BADGE
// ═══════════════════════════════════════════════════════════════════════════
class _InteractiveBadge extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _InteractiveBadge({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_InteractiveBadge> createState() => _InteractiveBadgeState();
}

class _InteractiveBadgeState extends State<_InteractiveBadge> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(_isPressed ? 0.25 : 0.12),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: widget.color.withOpacity(_isPressed ? 0.4 : 0.0),
            width: 1,
          ),
        ),
        child: Text(
          widget.label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════
/// Planet colors based on actual image visual palette
Color _getPlanetColor(String planet) {
  const colors = {
    // Sun - Intense fiery orange/yellow with golden glow
    'Sun': Color(0xFFFF9500),
    // Moon - Silvery blue, ethereal icy glow
    'Moon': Color(0xFF9BC4E2),
    // Mars - Fiery red/orange with intense crimson
    'Mars': Color(0xFFE84C30),
    // Mercury - Teal/green with golden undertones
    'Mercury': Color(0xFF5CAD8A),
    // Jupiter - Warm amber/orange with golden bands
    'Jupiter': Color(0xFFE8943A),
    // Venus - Soft peachy pink with warm clouds
    'Venus': Color(0xFFF5A878),
    // Saturn - Golden orange with warm ring tones
    'Saturn': Color(0xFFD4943A),
    // Rahu - Mystical purple/violet aura
    'Rahu': Color(0xFF9B7BF7),
    // Ketu - Cyan/teal with mystical glow
    'Ketu': Color(0xFF2DD4BF),
    // Neptune - Deep ocean blue
    'Neptune': Color(0xFF3B7DD8),
    // Uranus - Light cyan/aqua with soft rings
    'Uranus': Color(0xFF67E8F9),
    // Pluto - Dark reddish maroon/burgundy
    'Pluto': Color(0xFF8B5A6B),
  };
  return colors[planet] ?? _Colors.textSecondary;
}

String _getPlanetSymbol(String planet) {
  const symbols = {
    'Sun': '☉',
    'Moon': '☽',
    'Mars': '♂',
    'Mercury': '☿',
    'Jupiter': '♃',
    'Venus': '♀',
    'Saturn': '♄',
    'Rahu': '☊',
    'Ketu': '☋',
  };
  return symbols[planet] ?? '•';
}

String _getSignSymbol(String sign) {
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
  return symbols[sign] ?? '?';
}

/// Get zodiac sign color based on the visual palette from images
Color getZodiacColor(String sign) {
  const colors = {
    // Aries - Golden yellow, warm amber, soft brown
    'Aries': Color(0xFFD4A84B),
    // Taurus - Cool blue, teal, icy cyan
    'Taurus': Color(0xFF4ECDC4),
    // Gemini - Deep red, coral, rose pink
    'Gemini': Color(0xFFE85A6B),
    // Cancer - Lavender, violet, soft purple
    'Cancer': Color(0xFFB794F6),
    // Leo - Burnt orange, copper, warm peach
    'Leo': Color(0xFFE07B4C),
    // Virgo - Soft pink, blush, light rose
    'Virgo': Color(0xFFF5A6C4),
    // Libra - Mint green, emerald, pastel green
    'Libra': Color(0xFF6BCB77),
    // Scorpio - Dark orange, rust, deep amber
    'Scorpio': Color(0xFFD9652B),
    // Sagittarius - Magenta, violet, neon purple
    'Sagittarius': Color(0xFFE040FB),
    // Capricorn - Earthy brown, tan, muted orange
    'Capricorn': Color(0xFFB8956B),
    // Aquarius - Turquoise, aqua green, teal
    'Aquarius': Color(0xFF40E0D0),
    // Pisces - Ocean blue, sky blue, soft cyan
    'Pisces': Color(0xFF64B5F6),
  };
  return colors[sign] ?? const Color(0xFFA09CAC);
}

/// Get zodiac sign image path
String getZodiacImagePath(String sign) {
  return 'assets/images/zodiac/${sign.toLowerCase()}.png';
}

/// Get planet image path
String getPlanetImagePath(String planet) {
  return 'assets/images/planets/${planet.toLowerCase()}.png';
}
