import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../widgets/moon_phase_widget.dart';
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
// DESIGN SYSTEM TOKENS
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

    _slideAnimation = Tween<double>(begin: 0.3, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

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
                    // Header
                    Row(
                      children: [
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
                                    1.0 - (index * 0.15),
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
// TAPPABLE INSIGHT WRAPPER
// ═══════════════════════════════════════════════════════════════════════════
class _TappableInsight extends StatefulWidget {
  final Widget child;
  final InsightData insight;
  final BorderRadius? borderRadius;

  const _TappableInsight({
    required this.child,
    required this.insight,
    this.borderRadius,
  });

  @override
  State<_TappableInsight> createState() => _TappableInsightState();
}

class _TappableInsightState extends State<_TappableInsight>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
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
    _showInsightSheet(context, widget.insight);
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
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ??
                    BorderRadius.circular(_DesignTokens.radiusLg),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: widget.insight.accentColor.withOpacity(0.15),
                          blurRadius: 12,
                          spreadRadius: -2,
                        ),
                      ]
                    : null,
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INSIGHT GENERATORS
// ═══════════════════════════════════════════════════════════════════════════
InsightData _getTithiInsight(PanchangData panchang, String tithiLord) {
  final tithiDescriptions = {
    1: 'Pratipada - First lunar day, new beginnings and fresh starts',
    2: 'Dwitiya - Second lunar day, partnerships and relationships',
    3: 'Tritiya - Third lunar day, creativity and artistic pursuits',
    4: 'Chaturthi - Fourth lunar day, associated with Lord Ganesha',
    5: 'Panchami - Fifth lunar day, knowledge and learning',
    6: 'Shashthi - Sixth lunar day, associated with Lord Kartikeya',
    7: 'Saptami - Seventh lunar day, travel and movement',
    8: 'Ashtami - Eighth lunar day, associated with Goddess Durga',
    9: 'Navami - Ninth lunar day, worship and devotion',
    10: 'Dashami - Tenth lunar day, victory and success',
    11: 'Ekadashi - Eleventh lunar day, spiritual fasting day',
    12: 'Dwadashi - Twelfth lunar day, completion of vows',
    13: 'Trayodashi - Thirteenth lunar day, auspicious for new ventures',
    14: 'Chaturdashi - Fourteenth lunar day, transition period',
    15: 'Purnima/Amavasya - Full/New Moon, peak lunar energy',
  };

  return InsightData(
    title: 'Tithi',
    value: panchang.tithi,
    description: 'Tithi is the lunar day in the Hindu calendar, representing the angle between the Sun and Moon. Each Tithi has its own energy and is ruled by a specific planet. ${tithiDescriptions[panchang.tithiNumber] ?? ""}',
    significance: 'Your birth Tithi is ${panchang.tithi} (${panchang.tithiNumber}/15 in ${panchang.paksha} Paksha), ruled by $tithiLord. This influences your emotional nature and the lunar energy you carry.',
    keyPoints: [
      'Tithi Number: ${panchang.tithiNumber} of 15',
      'Paksha: ${panchang.paksha} (${panchang.paksha == "Shukla" ? "Waxing" : "Waning"} Moon)',
      'Tithi Lord: $tithiLord',
      'Each Tithi spans approximately 12 degrees of Moon-Sun elongation',
      'Tithis are used for muhurta (auspicious timing)',
    ],
    accentColor: _Colors.emerald,
    icon: Icons.brightness_2_rounded,
  );
}

InsightData _getNakshatraInsight(PanchangData panchang) {
  final nakshatraLords = {
    'Ashwini': 'Ketu', 'Bharani': 'Venus', 'Krittika': 'Sun',
    'Rohini': 'Moon', 'Mrigashira': 'Mars', 'Ardra': 'Rahu',
    'Punarvasu': 'Jupiter', 'Pushya': 'Saturn', 'Ashlesha': 'Mercury',
    'Magha': 'Ketu', 'Purva Phalguni': 'Venus', 'Uttara Phalguni': 'Sun',
    'Hasta': 'Moon', 'Chitra': 'Mars', 'Swati': 'Rahu',
    'Vishakha': 'Jupiter', 'Anuradha': 'Saturn', 'Jyeshtha': 'Mercury',
    'Mula': 'Ketu', 'Purva Ashadha': 'Venus', 'Uttara Ashadha': 'Sun',
    'Shravana': 'Moon', 'Dhanishta': 'Mars', 'Shatabhisha': 'Rahu',
    'Purva Bhadrapada': 'Jupiter', 'Uttara Bhadrapada': 'Saturn', 'Revati': 'Mercury',
  };

  final lord = nakshatraLords[panchang.nakshatra] ?? 'Unknown';

  return InsightData(
    title: 'Nakshatra',
    value: '${panchang.nakshatra} (Pada ${panchang.nakshatraPada})',
    description: 'Nakshatra is the lunar mansion or star constellation where the Moon was positioned at birth. There are 27 Nakshatras, each spanning 13°20\' of the zodiac. Each Nakshatra has 4 Padas (quarters) of 3°20\' each.',
    significance: 'The Moon in ${panchang.nakshatra} Nakshatra, Pada ${panchang.nakshatraPada}, shapes your inner emotional nature, instincts, and subconscious patterns. The Nakshatra lord $lord influences your Vimshottari Dasha sequence.',
    keyPoints: [
      'Nakshatra: ${panchang.nakshatra}',
      'Pada (Quarter): ${panchang.nakshatraPada} of 4',
      'Nakshatra Lord: $lord',
      'Each Nakshatra has a presiding deity and specific qualities',
      'Determines the starting Mahadasha in Vimshottari Dasha system',
    ],
    accentColor: _Colors.amber,
    icon: Icons.star_rounded,
  );
}

InsightData _getYogaInsight(PanchangData panchang, String yogaType) {
  final yogaDescriptions = {
    'Vishkumbha': 'Obstacle-creating yoga, challenges may arise',
    'Priti': 'Love and affection, favorable for relationships',
    'Ayushman': 'Long life, good health prospects',
    'Saubhagya': 'Good fortune and prosperity',
    'Shobhana': 'Beauty and brilliance, artistic success',
    'Atiganda': 'Danger and obstacles, caution advised',
    'Sukarma': 'Good deeds, favorable for righteous actions',
    'Dhriti': 'Steadfastness and determination',
    'Shula': 'Sharp, piercing - challenges in endeavors',
    'Ganda': 'Danger, obstacles in path',
    'Vriddhi': 'Growth and increase, expansion',
    'Dhruva': 'Fixed, stable - lasting achievements',
    'Vyaghata': 'Destruction, setbacks possible',
    'Harshana': 'Joy and happiness, celebrations',
    'Vajra': 'Hard, strong - both protection and difficulty',
    'Siddhi': 'Accomplishment and success',
    'Vyatipata': 'Calamity - one of the most inauspicious',
    'Variyan': 'Comfort and ease, favorable',
    'Parigha': 'Obstruction - like a barrier',
    'Shiva': 'Auspicious, blessings of Lord Shiva',
    'Siddha': 'Accomplished, successful endeavors',
    'Sadhya': 'Achievable, goals can be accomplished',
    'Shubha': 'Auspicious and beneficial',
    'Shukla': 'Pure and white, clarity',
    'Brahma': 'Creative power, knowledge',
    'Indra': 'Power and leadership',
    'Vaidhriti': 'Discord - the most inauspicious yoga',
  };

  final yogaColor = yogaType == 'Auspicious' ? _Colors.emerald : 
                    yogaType == 'Inauspicious' ? _Colors.coral : _Colors.sky;

  return InsightData(
    title: 'Yoga',
    value: '${panchang.yoga} (${panchang.yogaNumber}/27)',
    description: 'Yoga in Panchang is calculated from the combined longitude of the Sun and Moon. There are 27 Yogas, each spanning 13°20\'. ${yogaDescriptions[panchang.yoga] ?? "This Yoga influences the overall energy of the day."}',
    significance: 'Your birth Yoga is ${panchang.yoga}, which is considered $yogaType. This cosmic combination of Sun and Moon energies influences your life path and the general fortune you carry.',
    keyPoints: [
      'Yoga: ${panchang.yoga}',
      'Number: ${panchang.yogaNumber} of 27',
      'Type: $yogaType',
      'Formula: (Sun longitude + Moon longitude) ÷ 13°20\'',
      'Affects overall auspiciousness of the birth moment',
    ],
    accentColor: yogaColor,
    icon: Icons.link_rounded,
  );
}

InsightData _getKaranaInsight(PanchangData panchang, String karanaType) {
  final karanaDescriptions = {
    'Bava': 'Lion - Courage, leadership, administrative work',
    'Balava': 'Tiger - Strength, aggressive pursuits',
    'Kaulava': 'Pig - Friendships, social activities',
    'Taitila': 'Donkey - Jewelry, ornaments, property',
    'Gara': 'Elephant - Agriculture, construction',
    'Vanija': 'Merchant - Trade, business, commerce',
    'Vishti': 'Bhadra - Inauspicious, avoid important work',
    'Shakuni': 'Bird - Legal matters, disputes (Fixed)',
    'Chatushpada': 'Four-footed - Animal husbandry (Fixed)',
    'Naga': 'Serpent - Destruction, powerful rituals (Fixed)',
    'Kimstughna': 'Dead creature - Auspicious, destroys obstacles (Fixed)',
  };

  final karanaColor = karanaType.contains('Bhadra') ? _Colors.coral : _Colors.violet;

  return InsightData(
    title: 'Karana',
    value: panchang.karana,
    description: 'Karana is half of a Tithi, with 11 Karanas repeating to make 60 half-Tithis in a lunar month. 7 are movable (Chara) and 4 are fixed (Sthira). ${karanaDescriptions[panchang.karana] ?? "Each Karana has its own characteristics."}',
    significance: 'Born in ${panchang.karana} Karana, which is $karanaType. Karanas influence specific activities and the energy of the half-day period.',
    keyPoints: [
      'Karana: ${panchang.karana}',
      'Type: $karanaType',
      '7 Movable (Chara): Bava to Vishti, repeat 8 times',
      '4 Fixed (Sthira): Shakuni, Chatushpada, Naga, Kimstughna',
      'Vishti (Bhadra) is considered inauspicious',
    ],
    accentColor: karanaColor,
    icon: Icons.hourglass_bottom_rounded,
  );
}

InsightData _getVaraInsight(PanchangData panchang) {
  final varaInfo = {
    'Sunday': {'lord': 'Sun', 'deity': 'Surya', 'color': _Colors.gold, 'nature': 'Royal, authoritative, government-related activities'},
    'Monday': {'lord': 'Moon', 'deity': 'Chandra', 'color': _Colors.emerald, 'nature': 'Emotional, nurturing, travel, public dealings'},
    'Tuesday': {'lord': 'Mars', 'deity': 'Mangal', 'color': _Colors.coral, 'nature': 'Courageous, competitive, martial activities'},
    'Wednesday': {'lord': 'Mercury', 'deity': 'Budha', 'color': _Colors.teal, 'nature': 'Intellectual, commercial, communication'},
    'Thursday': {'lord': 'Jupiter', 'deity': 'Brihaspati', 'color': _Colors.amber, 'nature': 'Spiritual, educational, auspicious beginnings'},
    'Friday': {'lord': 'Venus', 'deity': 'Shukra', 'color': _Colors.rose, 'nature': 'Artistic, romantic, luxurious activities'},
    'Saturday': {'lord': 'Saturn', 'deity': 'Shani', 'color': _Colors.lavender, 'nature': 'Disciplined, karmic, hard work, patience'},
  };

  final info = varaInfo[panchang.vara] ?? {'lord': 'Unknown', 'deity': 'Unknown', 'color': _Colors.textSecondary, 'nature': ''};

  return InsightData(
    title: 'Vara (Weekday)',
    value: panchang.vara,
    description: 'Vara is the weekday, one of the five limbs of Panchang. Each day is ruled by a planet, influencing the energy and suitable activities for that day. ${info['nature']}',
    significance: 'Born on ${panchang.vara}, ruled by ${info['lord']}. This planetary influence colors your personality and the types of activities that come naturally to you.',
    keyPoints: [
      'Vara: ${panchang.vara}',
      'Vara Lord: ${info['lord']}',
      'Presiding Deity: ${panchang.varaDeity}',
      'Each Vara has specific auspicious and inauspicious hours',
      'Vara lord placement in chart strengthens its effects',
    ],
    accentColor: info['color'] as Color,
    icon: Icons.calendar_today_rounded,
  );
}

InsightData _getMoonPhaseInsight(PanchangData panchang, double illumination) {
  final phaseType = panchang.paksha == 'Shukla' ? 'Waxing' : 'Waning';
  String phase;
  if (panchang.tithiNumber == 15) {
    phase = panchang.paksha == 'Shukla' ? 'Full Moon (Purnima)' : 'New Moon (Amavasya)';
  } else if (panchang.tithiNumber <= 3) {
    phase = panchang.paksha == 'Shukla' ? 'Waxing Crescent' : 'Waning Gibbous';
  } else if (panchang.tithiNumber <= 7) {
    phase = panchang.paksha == 'Shukla' ? 'First Quarter' : 'Third Quarter';
  } else if (panchang.tithiNumber <= 11) {
    phase = panchang.paksha == 'Shukla' ? 'Waxing Gibbous' : 'Waning Crescent';
  } else {
    phase = panchang.paksha == 'Shukla' ? 'Nearly Full' : 'Nearly New';
  }

  return InsightData(
    title: 'Moon Phase',
    value: phase,
    description: 'The Moon phase at birth indicates the relationship between the Sun and Moon, reflecting the interplay of consciousness (Sun) and mind (Moon). A ${phaseType.toLowerCase()} moon suggests ${panchang.paksha == "Shukla" ? "growth, expansion, and building energy" : "release, introspection, and completion energy"}.',
    significance: 'Born during ${panchang.paksha} Paksha with ${illumination.toStringAsFixed(0)}% illumination. This indicates a ${panchang.paksha == "Shukla" ? "more outgoing, action-oriented nature with growing vitality" : "more introspective, wisdom-seeking nature with releasing tendencies"}.',
    keyPoints: [
      'Phase: $phase',
      'Paksha: ${panchang.paksha} ($phaseType)',
      'Illumination: ${illumination.toStringAsFixed(1)}%',
      'Tithi: ${panchang.tithi} (${panchang.tithiNumber}/15)',
      'Moon phase affects emotional patterns and life cycles',
    ],
    accentColor: _Colors.indigo,
    icon: Icons.nightlight_round,
  );
}

InsightData _getHoraInsight(String hora, DateTime birthTime) {
  final horaInfo = {
    'Sun': {'nature': 'Authority, leadership, government work, fame', 'color': _Colors.gold},
    'Moon': {'nature': 'Travel, emotions, public, nurturing', 'color': _Colors.emerald},
    'Mars': {'nature': 'Courage, competition, action, sports', 'color': _Colors.coral},
    'Mercury': {'nature': 'Communication, learning, business, writing', 'color': _Colors.teal},
    'Jupiter': {'nature': 'Education, spirituality, expansion, wisdom', 'color': _Colors.amber},
    'Venus': {'nature': 'Arts, relationships, beauty, pleasures', 'color': _Colors.rose},
    'Saturn': {'nature': 'Discipline, hard work, patience, service', 'color': _Colors.lavender},
  };

  final info = horaInfo[hora] ?? {'nature': '', 'color': _Colors.textSecondary};

  return InsightData(
    title: 'Hora',
    value: '$hora Hora',
    description: 'Hora divides each day into 24 planetary hours, with each hour ruled by a planet in a specific sequence. The Hora at birth indicates the planetary influence active at that moment. ${info['nature']}',
    significance: 'Born during $hora Hora, you carry the energy of $hora in your personality and approach to life. Activities related to $hora come naturally to you.',
    keyPoints: [
      'Birth Hora: $hora',
      'Time: ${DateFormat('HH:mm').format(birthTime)}',
      'Hora sequence follows: Sun→Venus→Mercury→Moon→Saturn→Jupiter→Mars',
      'Each hora lasts approximately 1 hour',
      'Hora influences the energy available for activities',
    ],
    accentColor: info['color'] as Color,
    icon: Icons.access_time_rounded,
  );
}

InsightData _getInauspiciousPeriodInsight(TimePeriod period, Color color) {
  final descriptions = {
    'Rahu Kala': 'Rahu Kala is the most inauspicious period of the day, ruled by the shadow planet Rahu. Starting new ventures, important meetings, or auspicious activities should be avoided during this time. However, activities related to Rahu (foreign connections, unconventional work) may actually benefit.',
    'Yamaghanda': 'Yamaghanda, also called Yama Ghantaka, is ruled by Yama, the god of death. This period is considered inauspicious for starting journeys, especially in the direction governed by Yama that day. Medical treatments and risky activities should be avoided.',
    'Gulika': 'Gulika Kala, ruled by Saturn\'s son Gulika (Mandi), is associated with poison and hidden dangers. While generally avoided for new beginnings, it\'s considered good for activities requiring secrecy or dealing with underground matters.',
  };

  return InsightData(
    title: 'Inauspicious Period',
    value: period.name,
    description: descriptions[period.name] ?? period.description,
    significance: 'Birth during ${period.name} (${period.formattedTime}) suggests specific karmic lessons related to this period\'s ruler. Understanding this helps in timing important life decisions.',
    keyPoints: [
      'Period: ${period.name}',
      'Time: ${period.formattedTime}',
      'Duration: Approximately 1.5 hours',
      period.name == 'Rahu Kala' ? 'Most important inauspicious period' :
      period.name == 'Yamaghanda' ? 'Avoid travels and risky activities' :
      'Related to hidden matters and secrecy',
      'Each weekday has different timings for these periods',
    ],
    accentColor: color,
    icon: period.name == 'Rahu Kala' ? Icons.do_not_disturb_on_rounded :
          period.name == 'Yamaghanda' ? Icons.warning_rounded :
          Icons.brightness_3_rounded,
  );
}

InsightData _getVarshphalInsight(VarshphalData varshphal) {
  return InsightData(
    title: 'Varshphal',
    value: 'Solar Return ${varshphal.year}',
    description: 'Varshphal (Annual Horoscope) is the chart cast for the exact moment when the Sun returns to its birth position each year. It provides insights into the themes, opportunities, and challenges for that specific year of life.',
    significance: 'At age ${varshphal.age}, your Muntha (progressed Ascendant) is in ${varshphal.munthaSign}, and the Year Lord is ${varshphal.yearLord}. These factors shape the major themes of this year.',
    keyPoints: [
      'Year: ${varshphal.year}',
      'Age: ${varshphal.age} years',
      'Solar Return: ${DateFormat('d MMM yyyy').format(varshphal.solarReturnDate)}',
      'Muntha Sign: ${varshphal.munthaSign}',
      'Year Lord: ${varshphal.yearLord}',
    ],
    accentColor: _Colors.amber,
    icon: Icons.wb_sunny_rounded,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// NAVIGATION SECTION DATA
// ═══════════════════════════════════════════════════════════════════════════
const _sections = [
  NavSection(id: 'moon', label: 'Moon', color: _Colors.indigo),
  NavSection(id: 'elements', label: 'Elements', color: _Colors.emerald),
  NavSection(id: 'hora', label: 'Hora', color: _Colors.sky),
  NavSection(id: 'periods', label: 'Periods', color: _Colors.coral),
  NavSection(id: 'varshphal', label: 'Varshphal', color: _Colors.amber),
];

/// Panchang Tab - Shows birth panchang, inauspicious periods, and varshphal
/// Premium, elegant UI with clear visual hierarchy
class PanchangTab extends StatefulWidget {
  final KundaliData kundaliData;

  const PanchangTab({super.key, required this.kundaliData});

  @override
  State<PanchangTab> createState() => _PanchangTabState();
}

class _PanchangTabState extends State<PanchangTab> {
  late final ScrollController _scrollController;
  final Map<String, GlobalKey> _sectionKeys = {};
  final Map<String, GlobalKey<_AnimatedSectionWrapperState>> _animatedKeys = {};
  int _activeIndex = 0;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    for (final section in _sections) {
      _sectionKeys[section.id] = GlobalKey();
      _animatedKeys[section.id] = GlobalKey<_AnimatedSectionWrapperState>();
    }
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

    _animatedKeys[section.id]?.currentState?.triggerHighlight();

    setState(() => _isScrolling = false);
  }

  @override
  Widget build(BuildContext context) {
    final sunPos = widget.kundaliData.planetPositions['Sun'];
    final moonPos = widget.kundaliData.planetPositions['Moon'];

    // Calculate Panchang from actual Sun/Moon positions
    final panchang = KundaliCalculationService.calculatePanchang(
      widget.kundaliData.birthDateTime,
      sunPos?.longitude ?? 0,
      moonPos?.longitude ?? 0,
    );

    // Calculate Varshphal for current year
    final varshphal = KundaliCalculationService.calculateVarshphal(
      widget.kundaliData.birthDateTime,
      sunPos?.longitude ?? 0,
      DateTime.now().year,
    );

    // Calculate inauspicious periods
    final inauspiciousPeriods = KundaliCalculationService.calculateInauspiciousPeriods(
      widget.kundaliData.birthDateTime,
    );

    // Calculate Hora at birth
    final hora = _calculateHora(widget.kundaliData.birthDateTime);

    // Derive additional Panchang details
    final tithiLord = _getTithiLord(panchang.tithiNumber, panchang.paksha);
    final yogaType = _getYogaType(panchang.yogaNumber);
    final karanaType = _getKaranaType(panchang.karana);

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
      physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════════════════
              // MOON PHASE SECTION
          // ═══════════════════════════════════════════════════════════════
              _AnimatedSectionWrapper(
                key: _animatedKeys['moon'],
                sectionKey: _sectionKeys['moon']!,
                accentColor: _Colors.indigo,
                child: _AnimatedCardWrapper(
                  child: _MoonPhaseHeroCard(
            panchang: panchang,
            moonPos: moonPos,
            sunPos: sunPos,
                    birthDateTime: widget.kundaliData.birthDateTime,
                  ),
                ),
          ),

              const SizedBox(height: _DesignTokens.space24),

          // ═══════════════════════════════════════════════════════════════
          // PANCHANG ELEMENTS
          // ═══════════════════════════════════════════════════════════════
              _AnimatedSectionWrapper(
                key: _animatedKeys['elements'],
                sectionKey: _sectionKeys['elements']!,
                accentColor: _Colors.emerald,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
            title: 'Five Limbs of Time',
            subtitle: 'Panchang elements at birth',
                      accentColor: _Colors.emerald,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: _PanchangElementsGrid(
            panchang: panchang,
            tithiLord: tithiLord,
            yogaType: yogaType,
            karanaType: karanaType,
                      ),
                    ),
                  ],
                ),
          ),

              const SizedBox(height: _DesignTokens.space24),

          // ═══════════════════════════════════════════════════════════════
          // HORA & WEEKDAY
          // ═══════════════════════════════════════════════════════════════
              _AnimatedSectionWrapper(
                key: _animatedKeys['hora'],
                sectionKey: _sectionKeys['hora']!,
                accentColor: _Colors.sky,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
            title: 'Hora & Weekday',
            subtitle: 'Planetary hour and day influences',
                      accentColor: _Colors.sky,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: Row(
            children: [
              Expanded(
                            child: _HoraCard(hora: hora, birthTime: widget.kundaliData.birthDateTime),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _WeekdayCard(panchang: panchang),
              ),
            ],
                      ),
                    ),
                  ],
                ),
          ),

              const SizedBox(height: _DesignTokens.space24),

          // ═══════════════════════════════════════════════════════════════
          // INAUSPICIOUS PERIODS
          // ═══════════════════════════════════════════════════════════════
              _AnimatedSectionWrapper(
                key: _animatedKeys['periods'],
                sectionKey: _sectionKeys['periods']!,
                accentColor: _Colors.coral,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
            title: 'Inauspicious Periods',
                      subtitle: 'On ${DateFormat('EEEE').format(widget.kundaliData.birthDateTime)}',
                      accentColor: _Colors.coral,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: _InauspiciousPeriodsCard(
            periods: inauspiciousPeriods,
                        birthDateTime: widget.kundaliData.birthDateTime,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

          // ═══════════════════════════════════════════════════════════════
              // VARSHPHAL
          // ═══════════════════════════════════════════════════════════════
              _AnimatedSectionWrapper(
                key: _animatedKeys['varshphal'],
                sectionKey: _sectionKeys['varshphal']!,
                accentColor: _Colors.amber,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
            title: 'Varshphal ${varshphal.year}',
            subtitle: 'Solar Return / Annual Horoscope',
                      accentColor: _Colors.amber,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: _VarshphalCard(varshphal: varshphal),
                    ),
                  ],
                ),
              ),
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

  String _calculateHora(DateTime dateTime) {
    const weekdayRulers = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'];
    const horaSequence = ['Sun', 'Venus', 'Mercury', 'Moon', 'Saturn', 'Jupiter', 'Mars'];

    final weekday = dateTime.weekday % 7;
    final dayRuler = weekdayRulers[weekday];
    final startIndex = horaSequence.indexOf(dayRuler);
    final hoursSinceSunrise = (dateTime.hour - 6 + 24) % 24;
    final horaIndex = (startIndex + hoursSinceSunrise) % 7;

    return horaSequence[horaIndex];
  }

  String _getTithiLord(int tithiNumber, String paksha) {
    const tithiLords = [
      'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn',
      'Rahu', 'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn',
    ];
    final index = (tithiNumber - 1) % 15;
    return tithiLords[index];
  }

  String _getYogaType(int yogaNumber) {
    // Inauspicious Yogas per traditional Vedic astrology:
    // 1-Vishkumbha, 6-Atiganda, 9-Shula, 10-Ganda, 13-Vyaghata,
    // 15-Vajra, 17-Vyatipata, 19-Parigha, 27-Vaidhriti
    const inauspiciousYogas = [1, 6, 9, 10, 13, 15, 17, 19, 27];

    // Auspicious Yogas per traditional Vedic astrology:
    // 2-Priti, 3-Ayushman, 4-Saubhagya, 5-Shobhana, 7-Sukarma, 8-Dhriti,
    // 11-Vriddhi, 12-Dhruva, 14-Harshana, 16-Siddhi, 18-Variyan, 20-Shiva,
    // 21-Siddha, 22-Sadhya, 23-Shubha, 24-Shukla, 25-Brahma, 26-Indra
    const auspiciousYogas = [2, 3, 4, 5, 7, 8, 11, 12, 14, 16, 18, 20, 21, 22, 23, 24, 25, 26];

    if (inauspiciousYogas.contains(yogaNumber)) return 'Inauspicious';
    if (auspiciousYogas.contains(yogaNumber)) return 'Auspicious';
    return 'Neutral';
  }

  String _getKaranaType(String karana) {
    const movableKaranas = ['Bava', 'Balava', 'Kaulava', 'Taitila', 'Gara', 'Vanija', 'Vishti'];
    const fixedKaranas = ['Shakuni', 'Chatushpada', 'Naga', 'Kimstughna'];

    if (movableKaranas.contains(karana)) {
      if (karana == 'Vishti') return 'Bhadra (Avoid)';
      return 'Chara (Movable)';
    }
    if (fixedKaranas.contains(karana)) return 'Sthira (Fixed)';
    return 'Unknown';
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
  State<_AnimatedSectionWrapper> createState() => _AnimatedSectionWrapperState();
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
    return context.dependOnInheritedWidgetOfExactType<_SectionAnimationProvider>();
  }

  @override
  bool updateShouldNotify(_SectionAnimationProvider oldWidget) {
    return isHighlighted != oldWidget.isHighlighted;
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
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)),
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

        final textColor = Color.lerp(
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
                  final maxWidth = math.min(constraints.maxWidth * 0.3, 40.0);
                  return Container(
                    height: 2,
                    width: maxWidth * underlineWidth,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.6 + textPulse * 0.4),
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
        tween: Tween(begin: 1.0, end: 1.025).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.025, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 65,
      ),
    ]).animate(_controller);

    _shadowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)),
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
            decoration: shadow > 0.01
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(_DesignTokens.radiusLg),
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
// MOON PHASE HERO CARD - Interactive
// ═══════════════════════════════════════════════════════════════════════════
class _MoonPhaseHeroCard extends StatefulWidget {
  final PanchangData panchang;
  final PlanetPosition? moonPos;
  final PlanetPosition? sunPos;
  final DateTime birthDateTime;

  const _MoonPhaseHeroCard({
    required this.panchang,
    required this.moonPos,
    required this.sunPos,
    required this.birthDateTime,
  });

  @override
  State<_MoonPhaseHeroCard> createState() => _MoonPhaseHeroCardState();
}

class _MoonPhaseHeroCardState extends State<_MoonPhaseHeroCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  double _calculateIllumination(int tithi, String paksha) {
    if (paksha == 'Shukla') {
      return (tithi / 15.0) * 100;
    } else {
      return ((15 - tithi + 1) / 15.0) * 100;
    }
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.selectionClick();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    final illumination = _calculateIllumination(
      widget.panchang.tithiNumber,
      widget.panchang.paksha,
    );
    _showInsightSheet(
      context,
      _getMoonPhaseInsight(widget.panchang, illumination),
    );
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  Color _getPakshaColor() {
    return widget.panchang.paksha == 'Shukla'
        ? const Color(0xFFFBBF24) // Amber for Shukla (bright)
        : const Color(0xFF8B5CF6); // Violet for Krishna (dark)
  }

  @override
  Widget build(BuildContext context) {
    final moonLong = widget.moonPos?.longitude ?? 0;
    final sunLong = widget.sunPos?.longitude ?? 0;
    double elongation = moonLong - sunLong;
    if (elongation < 0) elongation += 360;

    final phaseDescription = _getPhaseDescription(
      widget.panchang.tithiNumber,
      widget.panchang.paksha,
    );
    final illumination = _calculateIllumination(
      widget.panchang.tithiNumber,
      widget.panchang.paksha,
    );
    final pakshaColor = _getPakshaColor();

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF141218),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF262432),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Moon Phase + Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Moon Phase Visualization
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A181F),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: pakshaColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: MoonPhaseWidget(
                              tithiNumber: widget.panchang.tithiNumber,
                              paksha: widget.panchang.paksha,
                              size: 64,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: pakshaColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${illumination.toStringAsFixed(0)}% lit',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: pakshaColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Tithi Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Paksha Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: pakshaColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${widget.panchang.paksha.toUpperCase()} PAKSHA',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: pakshaColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Tithi Name
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.panchang.tithi,
                                    style: GoogleFonts.instrumentSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                  color: const Color(0xFF6E6A7A),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Phase Description
                            Text(
                              phaseDescription,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF9590A0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Date/Time Row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A181F),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF2A2838),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: const Color(0xFF7C7889),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('d MMMM yyyy').format(widget.birthDateTime),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFE8E6EE),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 1,
                          height: 16,
                          color: const Color(0xFF2A2838),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: const Color(0xFF7C7889),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('EEEE, HH:mm').format(widget.birthDateTime),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFB8B5C2),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Moon Stats Row
                  Row(
                    children: [
                      _CompactMoonStat(
                        icon: Icons.nightlight_round,
                        label: 'Moon Sign',
                        value: widget.moonPos?.sign ?? '?',
                        color: _Colors.emerald,
                      ),
                      const SizedBox(width: 8),
                      _CompactMoonStat(
                        icon: Icons.straighten_rounded,
                        label: 'Degree',
                        value:
                            '${(widget.moonPos?.signDegree ?? 0).toStringAsFixed(1)}°',
                        color: _Colors.sky,
                      ),
                      const SizedBox(width: 8),
                      _CompactMoonStat(
                        icon: Icons.compare_arrows_rounded,
                        label: 'Elongation',
                        value: '${elongation.toStringAsFixed(1)}°',
                        color: _Colors.violet,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Compact Moon Stat Widget
class _CompactMoonStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _CompactMoonStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.15),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF7C7889),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _getPhaseDescription(int tithi, String paksha) {
  if (paksha == 'Shukla') {
    if (tithi <= 3) return 'Waxing Crescent';
    if (tithi <= 7) return 'First Quarter';
    if (tithi <= 11) return 'Waxing Gibbous';
    if (tithi <= 14) return 'Nearly Full';
    return 'Full Moon (Purnima)';
  } else {
    if (tithi <= 3) return 'Waning Gibbous';
    if (tithi <= 7) return 'Third Quarter';
    if (tithi <= 11) return 'Waning Crescent';
    if (tithi <= 14) return 'Nearly New';
    return 'New Moon (Amavasya)';
  }
}


// ═══════════════════════════════════════════════════════════════════════════
// PANCHANG ELEMENTS GRID - Elegant Minimal Design
// ═══════════════════════════════════════════════════════════════════════════
class _PanchangElementsGrid extends StatelessWidget {
  final PanchangData panchang;
  final String tithiLord;
  final String yogaType;
  final String karanaType;

  const _PanchangElementsGrid({
    required this.panchang,
    required this.tithiLord,
    required this.yogaType,
    required this.karanaType,
  });

  @override
  Widget build(BuildContext context) {
    final yogaColor = _getYogaTypeColor(yogaType);
    final karanaColor =
        karanaType.contains('Bhadra') ? _Colors.coral : _Colors.violet;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0B12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ElegantPanchangTile(
                  symbol: '☽',
                  label: 'Tithi',
                  value: panchang.tithi,
                  detail: tithiLord,
                  detailPrefix: 'Lord',
                  position: _TilePosition.topLeft,
                  insight: _getTithiInsight(panchang, tithiLord),
                ),
              ),
              Expanded(
                child: _ElegantPanchangTile(
                  symbol: '✦',
                  label: 'Nakshatra',
                  value: panchang.nakshatra,
                  detail: 'Pada ${panchang.nakshatraPada}',
                  position: _TilePosition.topRight,
                  insight: _getNakshatraInsight(panchang),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _ElegantPanchangTile(
                  symbol: '☯',
                  label: 'Yoga',
                  value: panchang.yoga,
                  detail: yogaType,
                  badge: '${panchang.yogaNumber}/27',
                  badgeColor: yogaColor,
                  position: _TilePosition.bottomLeft,
                  insight: _getYogaInsight(panchang, yogaType),
                ),
              ),
              Expanded(
                child: _ElegantPanchangTile(
                  symbol: '⧗',
                  label: 'Karana',
                  value: panchang.karana,
                  detail: karanaType,
                  badgeColor: karanaColor,
                  showWarning: karanaType.contains('Bhadra'),
                  position: _TilePosition.bottomRight,
                  insight: _getKaranaInsight(panchang, karanaType),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getYogaTypeColor(String type) {
    switch (type) {
      case 'Auspicious':
        return _Colors.emerald;
      case 'Inauspicious':
        return _Colors.coral;
      default:
        return _Colors.sky;
    }
  }
}

enum _TilePosition { topLeft, topRight, bottomLeft, bottomRight }

class _ElegantPanchangTile extends StatefulWidget {
  final String symbol;
  final String label;
  final String value;
  final String detail;
  final String? detailPrefix;
  final String? badge;
  final Color? badgeColor;
  final bool showWarning;
  final _TilePosition position;
  final InsightData insight;

  const _ElegantPanchangTile({
    required this.symbol,
    required this.label,
    required this.value,
    required this.detail,
    this.detailPrefix,
    this.badge,
    this.badgeColor,
    this.showWarning = false,
    required this.position,
    required this.insight,
  });

  @override
  State<_ElegantPanchangTile> createState() => _ElegantPanchangTileState();
}

class _ElegantPanchangTileState extends State<_ElegantPanchangTile> {
  bool _isPressed = false;

  BorderRadius _getBorderRadius() {
    const r = Radius.circular(14);
    const s = Radius.circular(4);
    switch (widget.position) {
      case _TilePosition.topLeft:
        return const BorderRadius.only(topLeft: r, topRight: s, bottomLeft: s, bottomRight: s);
      case _TilePosition.topRight:
        return const BorderRadius.only(topLeft: s, topRight: r, bottomLeft: s, bottomRight: s);
      case _TilePosition.bottomLeft:
        return const BorderRadius.only(topLeft: s, topRight: s, bottomLeft: r, bottomRight: s);
      case _TilePosition.bottomRight:
        return const BorderRadius.only(topLeft: s, topRight: s, bottomLeft: s, bottomRight: r);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.badgeColor ?? const Color(0xFF6B7280);
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        _showInsightSheet(context, widget.insight);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: _isPressed 
              ? const Color(0xFF1A1820)
              : const Color(0xFF141218),
          borderRadius: _getBorderRadius(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with symbol and label
            Row(
              children: [
                // Symbol
                Text(
                  widget.symbol,
                  style: TextStyle(
                    fontSize: 13,
                    color: _isPressed 
                        ? _Colors.textSecondary 
                        : const Color(0xFF4A4654),
                  ),
                ),
                const SizedBox(width: 6),
                // Label
                Expanded(
                  child: Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B6779),
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                // Badge or warning indicator
                if (widget.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.badge!,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: accentColor.withOpacity(0.8),
                      ),
                    ),
                  ),
                if (widget.showWarning)
                  Icon(
                    Icons.error_outline_rounded,
                    size: 12,
                    color: _Colors.coral.withOpacity(0.6),
                  ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Main value
            Text(
              widget.value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _Colors.textPrimary,
                letterSpacing: -0.2,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // Detail text with optional prefix
            Row(
              children: [
                if (widget.detailPrefix != null) ...[
                  Text(
                    '${widget.detailPrefix}: ',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF5A5666),
                    ),
                  ),
                ],
                Expanded(
                  child: Text(
                    widget.detail,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: widget.detailPrefix != null 
                          ? const Color(0xFF9D99A9)
                          : (widget.badgeColor ?? const Color(0xFF8A8698)),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HORA CARD - Interactive
// ═══════════════════════════════════════════════════════════════════════════
class _HoraCard extends StatefulWidget {
  final String hora;
  final DateTime birthTime;

  const _HoraCard({required this.hora, required this.birthTime});

  @override
  State<_HoraCard> createState() => _HoraCardState();
}

class _HoraCardState extends State<_HoraCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
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
      _getHoraInsight(widget.hora, widget.birthTime),
    );
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  Color _getHoraColor(String planet) {
    const colors = {
      'Sun': Color(0xFFD4AF37),
      'Moon': Color(0xFF6EE7B7),
      'Mars': Color(0xFFF87171),
      'Mercury': Color(0xFF34D399),
      'Jupiter': Color(0xFFFBBF24),
      'Venus': Color(0xFFF472B6),
      'Saturn': Color(0xFF9CA3AF),
    };
    return colors[planet] ?? _Colors.textTertiary;
  }

  String _getHoraSymbol(String planet) {
    const symbols = {
      'Sun': '☉',
      'Moon': '☽',
      'Mars': '♂',
      'Mercury': '☿',
      'Jupiter': '♃',
      'Venus': '♀',
      'Saturn': '♄',
    };
    return symbols[planet] ?? '•';
  }

  String _getHoraDescription(String planet) {
    const descriptions = {
      'Sun': 'Authority, government work, leadership',
      'Moon': 'Travel, emotions, public dealing',
      'Mars': 'Courage, competition, action',
      'Mercury': 'Communication, learning, business',
      'Jupiter': 'Education, spirituality, expansion',
      'Venus': 'Arts, relationships, pleasures',
      'Saturn': 'Hard work, discipline, patience',
    };
    return descriptions[planet] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final horaColor = _getHoraColor(widget.hora);

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
              duration: const Duration(milliseconds: 100),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _Colors.surface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(_DesignTokens.radiusMd),
                border: Border.all(
                  color: horaColor.withOpacity(_isPressed ? 0.4 : 0.2),
                  width: _isPressed ? 1 : 0.5,
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: horaColor.withOpacity(0.15),
                          blurRadius: 12,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        horaColor.withOpacity(0.2),
                        horaColor.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getHoraSymbol(widget.hora),
                    style: TextStyle(fontSize: 18, color: horaColor),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Birth Hora',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: _Colors.textTertiary,
                        ),
                      ),
                      Text(
                        '${widget.hora} Hora',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _Colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: horaColor.withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _getHoraDescription(widget.hora),
              style: GoogleFonts.inter(
                fontSize: 9,
                color: _Colors.textTertiary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WEEKDAY CARD - Interactive
// ═══════════════════════════════════════════════════════════════════════════
class _WeekdayCard extends StatefulWidget {
  final PanchangData panchang;

  const _WeekdayCard({required this.panchang});

  @override
  State<_WeekdayCard> createState() => _WeekdayCardState();
}

class _WeekdayCardState extends State<_WeekdayCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
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
    _showInsightSheet(context, _getVaraInsight(widget.panchang));
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  String _getVaraLord(String vara) {
    const lords = {
      'Sunday': 'Sun',
      'Monday': 'Moon',
      'Tuesday': 'Mars',
      'Wednesday': 'Mercury',
      'Thursday': 'Jupiter',
      'Friday': 'Venus',
      'Saturday': 'Saturn',
    };
    return lords[vara] ?? 'Unknown';
  }

  Color _getVaraColor(String vara) {
    const colors = {
      'Sunday': Color(0xFFD4AF37),
      'Monday': Color(0xFF6EE7B7),
      'Tuesday': Color(0xFFF87171),
      'Wednesday': Color(0xFF34D399),
      'Thursday': Color(0xFFFBBF24),
      'Friday': Color(0xFFF472B6),
      'Saturday': Color(0xFF9CA3AF),
    };
    return colors[vara] ?? _Colors.textTertiary;
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
    };
    return symbols[planet] ?? '•';
  }

  @override
  Widget build(BuildContext context) {
    final varaLord = _getVaraLord(widget.panchang.vara);
    final varaColor = _getVaraColor(widget.panchang.vara);

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
              duration: const Duration(milliseconds: 100),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _Colors.surface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(_DesignTokens.radiusMd),
                border: Border.all(
                  color: varaColor.withOpacity(_isPressed ? 0.4 : 0.2),
                  width: _isPressed ? 1 : 0.5,
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: varaColor.withOpacity(0.15),
                          blurRadius: 12,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        varaColor.withOpacity(0.2),
                        varaColor.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getPlanetSymbol(varaLord),
                    style: TextStyle(fontSize: 18, color: varaColor),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vara (Weekday)',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: _Colors.textTertiary,
                        ),
                      ),
                      Text(
                        widget.panchang.vara,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _Colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: varaColor.withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Lord: ',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: _Colors.textTertiary,
                  ),
                ),
                Text(
                  varaLord,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: varaColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '• ${widget.panchang.varaDeity}',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: _Colors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INAUSPICIOUS PERIODS CARD
// ═══════════════════════════════════════════════════════════════════════════
class _InauspiciousPeriodsCard extends StatelessWidget {
  final InauspiciousPeriods periods;
  final DateTime birthDateTime;

  const _InauspiciousPeriodsCard({
    required this.periods,
    required this.birthDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final currentPeriod = periods.getCurrentPeriod(birthDateTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Colors.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(_DesignTokens.radiusLg),
        border: Border.all(
          color: _Colors.coral.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          if (currentPeriod != null) ...[
            _BirthWarningBanner(period: currentPeriod),
            const SizedBox(height: 14),
          ],

          _InauspiciousPeriodRow(
            period: periods.rahukala,
            color: _Colors.coral,
            icon: Icons.do_not_disturb_on_rounded,
          ),
          const SizedBox(height: 8),
          _InauspiciousPeriodRow(
            period: periods.yamaghanda,
            color: _Colors.amber,
            icon: Icons.warning_rounded,
          ),
          const SizedBox(height: 8),
          _InauspiciousPeriodRow(
            period: periods.gulika,
            color: _Colors.violet,
            icon: Icons.brightness_3_rounded,
          ),

          const SizedBox(height: 14),

          _InauspiciousTimeline(
            periods: periods,
            birthDateTime: birthDateTime,
          ),
        ],
      ),
    );
  }
}

class _BirthWarningBanner extends StatelessWidget {
  final TimePeriod period;

  const _BirthWarningBanner({required this.period});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _Colors.coral.withOpacity(0.15),
            _Colors.coral.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(_DesignTokens.radiusMd),
        border: Border.all(
          color: _Colors.coral.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _Colors.coral.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: _Colors.coral,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Birth during ${period.name}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _Colors.coral,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  period.description,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: _Colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InauspiciousPeriodRow extends StatefulWidget {
  final TimePeriod period;
  final Color color;
  final IconData icon;

  const _InauspiciousPeriodRow({
    required this.period,
    required this.color,
    required this.icon,
  });

  @override
  State<_InauspiciousPeriodRow> createState() => _InauspiciousPeriodRowState();
}

class _InauspiciousPeriodRowState extends State<_InauspiciousPeriodRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
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
      _getInauspiciousPeriodInsight(widget.period, widget.color),
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
              duration: const Duration(milliseconds: 100),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(_isPressed ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.color.withOpacity(_isPressed ? 0.25 : 0.12),
                  width: _isPressed ? 1 : 0.5,
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: widget.color.withOpacity(0.15),
                          blurRadius: 10,
                          spreadRadius: -2,
                        ),
                      ]
                    : null,
              ),
              child: child,
            ),
          );
        },
        child: Row(
          children: [
            Icon(widget.icon, color: widget.color, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.period.name,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _Colors.textPrimary,
                    ),
                  ),
                  Text(
                    widget.period.description,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: _Colors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.period.formattedTime,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 14,
              color: widget.color.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _InauspiciousTimeline extends StatelessWidget {
  final InauspiciousPeriods periods;
  final DateTime birthDateTime;

  const _InauspiciousTimeline({
    required this.periods,
    required this.birthDateTime,
  });

  @override
  Widget build(BuildContext context) {
    const startHour = 6;
    const endHour = 18;
    const totalMinutes = (endHour - startHour) * 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 12,
              color: _Colors.textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              'Day Timeline (6 AM - 6 PM)',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: _Colors.textTertiary,
              ),
            ),
            const Spacer(),
            Container(
              width: 12,
              height: 2,
              color: _Colors.violet,
            ),
            const SizedBox(width: 4),
            Text(
              'Birth',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 8,
                color: _Colors.violet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return SizedBox(
              height: 28,
              child: Stack(
                children: [
                  Container(
                    height: 10,
                    margin: const EdgeInsets.only(top: 9),
                    decoration: BoxDecoration(
                      color: _Colors.surface,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  _TimelineSegment(
                    period: periods.rahukala,
                    startHour: startHour,
                    totalMinutes: totalMinutes,
                    color: _Colors.coral,
                    maxWidth: width,
                  ),
                  _TimelineSegment(
                    period: periods.yamaghanda,
                    startHour: startHour,
                    totalMinutes: totalMinutes,
                    color: _Colors.amber,
                    maxWidth: width,
                  ),
                  _TimelineSegment(
                    period: periods.gulika,
                    startHour: startHour,
                    totalMinutes: totalMinutes,
                    color: _Colors.violet,
                    maxWidth: width,
                  ),
                  _BirthTimeMarker(
                    birthTime: birthDateTime,
                    startHour: startHour,
                    totalMinutes: totalMinutes,
                    maxWidth: width,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('6AM', style: GoogleFonts.jetBrainsMono(fontSize: 8, color: _Colors.textTertiary)),
            Text('9AM', style: GoogleFonts.jetBrainsMono(fontSize: 8, color: _Colors.textTertiary)),
            Text('12PM', style: GoogleFonts.jetBrainsMono(fontSize: 8, color: _Colors.textTertiary)),
            Text('3PM', style: GoogleFonts.jetBrainsMono(fontSize: 8, color: _Colors.textTertiary)),
            Text('6PM', style: GoogleFonts.jetBrainsMono(fontSize: 8, color: _Colors.textTertiary)),
          ],
        ),
      ],
    );
  }
}

class _TimelineSegment extends StatelessWidget {
  final TimePeriod period;
  final int startHour;
  final int totalMinutes;
  final Color color;
  final double maxWidth;

  const _TimelineSegment({
    required this.period,
    required this.startHour,
    required this.totalMinutes,
    required this.color,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final periodStartMinutes = (period.startTime.hour - startHour) * 60 + period.startTime.minute;
    final periodEndMinutes = (period.endTime.hour - startHour) * 60 + period.endTime.minute;

    final startFraction = (periodStartMinutes / totalMinutes).clamp(0.0, 1.0);
    final endFraction = (periodEndMinutes / totalMinutes).clamp(0.0, 1.0);
    final widthFraction = endFraction - startFraction;

    if (widthFraction <= 0) return const SizedBox();

    return Positioned(
      left: startFraction * maxWidth,
      top: 9,
      child: Container(
        width: widthFraction * maxWidth,
        height: 10,
        decoration: BoxDecoration(
          color: color.withOpacity(0.7),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}

class _BirthTimeMarker extends StatelessWidget {
  final DateTime birthTime;
  final int startHour;
  final int totalMinutes;
  final double maxWidth;

  const _BirthTimeMarker({
    required this.birthTime,
    required this.startHour,
    required this.totalMinutes,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final birthMinutes = (birthTime.hour - startHour) * 60 + birthTime.minute;
    final fraction = (birthMinutes / totalMinutes).clamp(0.0, 1.0);

    return Positioned(
      left: fraction * (maxWidth - 4),
      top: 0,
      child: Container(
        width: 3,
        height: 28,
        decoration: BoxDecoration(
          color: _Colors.violet,
          borderRadius: BorderRadius.circular(1.5),
          boxShadow: [
            BoxShadow(
              color: _Colors.violet.withOpacity(0.4),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VARSHPHAL CARD - Elegant Minimal Design
// ═══════════════════════════════════════════════════════════════════════════
class _VarshphalCard extends StatefulWidget {
  final VarshphalData varshphal;

  const _VarshphalCard({required this.varshphal});

  @override
  State<_VarshphalCard> createState() => _VarshphalCardState();
}

class _VarshphalCardState extends State<_VarshphalCard> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _showInsightSheet(context, _getVarshphalInsight(widget.varshphal));
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  Color _getYearLordColor(String lord) {
    const colors = {
      'Sun': Color(0xFFD4AF37),
      'Moon': Color(0xFF6EE7B7),
      'Mars': Color(0xFFF87171),
      'Mercury': Color(0xFF34D399),
      'Jupiter': Color(0xFFFBBF24),
      'Venus': Color(0xFFF472B6),
      'Saturn': Color(0xFF9CA3AF),
    };
    return colors[lord] ?? _Colors.textTertiary;
  }

  String _getYearLordSymbol(String lord) {
    const symbols = {
      'Sun': '☉',
      'Moon': '☽',
      'Mars': '♂',
      'Mercury': '☿',
      'Jupiter': '♃',
      'Venus': '♀',
      'Saturn': '♄',
    };
    return symbols[lord] ?? '•';
  }

  String _getSignSymbol(String sign) {
    const symbols = {
      'Aries': '♈', 'Taurus': '♉', 'Gemini': '♊', 'Cancer': '♋',
      'Leo': '♌', 'Virgo': '♍', 'Libra': '♎', 'Scorpio': '♏',
      'Sagittarius': '♐', 'Capricorn': '♑', 'Aquarius': '♒', 'Pisces': '♓',
    };
    return symbols[sign] ?? '•';
  }

  @override
  Widget build(BuildContext context) {
    final yearLordColor = _getYearLordColor(widget.varshphal.yearLord);
    
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isPressed 
              ? const Color(0xFF1A1820)
              : const Color(0xFF141218),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Age indicator - minimal circle
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1C24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.varshphal.age}',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: _Colors.textPrimary,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'years',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B6779),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Title and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        'Solar Return ${widget.varshphal.year}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _Colors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 12,
                            color: const Color(0xFF5A5666),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            DateFormat('d MMM yyyy').format(widget.varshphal.solarReturnDate),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF8A8698),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Info icon
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: _isPressed ? 1.0 : 0.4,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: const Color(0xFF6B6779),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Divider
            Container(
              height: 1,
              color: const Color(0xFF1E1C26),
            ),

            const SizedBox(height: 14),

            // Info tiles row
            Row(
              children: [
                // Muntha Sign
                Expanded(
                  child: _MinimalInfoTile(
                    symbol: _getSignSymbol(widget.varshphal.munthaSign),
                    label: 'Muntha',
                    value: widget.varshphal.munthaSign,
                    symbolColor: _Colors.violet,
                  ),
                ),
                const SizedBox(width: 12),
                // Year Lord
                Expanded(
                  child: _MinimalInfoTile(
                    symbol: _getYearLordSymbol(widget.varshphal.yearLord),
                    label: 'Year Lord',
                    value: widget.varshphal.yearLord,
                    symbolColor: yearLordColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MinimalInfoTile extends StatelessWidget {
  final String symbol;
  final String label;
  final String value;
  final Color symbolColor;

  const _MinimalInfoTile({
    required this.symbol,
    required this.label,
    required this.value,
    required this.symbolColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A181F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            symbol,
            style: TextStyle(
              fontSize: 16,
              color: symbolColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B6779),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _Colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
