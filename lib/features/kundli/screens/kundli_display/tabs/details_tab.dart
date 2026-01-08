import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../widgets/moon_phase_widget.dart';
import '../shared/floating_nav_bar.dart';

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
  static const double space20 = 20;
  static const double space24 = 24;

  // Border radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;

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

  static TextStyle get bodySm => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: _Colors.textPrimary,
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

  // Animation curves
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Curve curveStandard = Curves.easeOutCubic;
}

class _Colors {
  _Colors._();

  // Surfaces
  static const Color bgSecondary = Color(0xFF100E17);
  static const Color surface = Color(0xFF16141F);
  static const Color surfaceElevated = Color(0xFF1C1A26);

  // Borders
  static const Color border = Color(0xFF2A2838);
  static const Color borderSubtle = Color(0xFF1E1C28);

  // Text
  static const Color textPrimary = Color(0xFFF5F4F8);
  static const Color textSecondary = Color(0xFFA09CAC);
  static const Color textTertiary = Color(0xFF6E6A7A);

  // Accent colors - muted and sophisticated
  static const Color gold = Color(0xFFCFAE54);
  static const Color violet = Color(0xFF9580FF);
  static const Color emerald = Color(0xFF4ADE80);
  static const Color rose = Color(0xFFF472B6);
  static const Color sky = Color(0xFF38BDF8);
  static const Color amber = Color(0xFFFBBF24);
  static const Color coral = Color(0xFFF87171);
  static const Color teal = Color(0xFF2DD4BF);
}

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
// PREMIUM INSIGHT BOTTOM SHEET
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
            // Handle bar with accent glow
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
                    // Header with icon and title
                    Row(
                      children: [
                        // Accent icon container
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
                          child:
                              insight.imagePath != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.asset(
                                      insight.imagePath!,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Icon(
                                            insight.icon,
                                            size: 28,
                                            color: insight.accentColor,
                                          ),
                                    ),
                                  )
                                  : Icon(
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

                    // Divider with gradient
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
// TAPPABLE INSIGHT WRAPPER - Makes any widget tappable for insights
// ═══════════════════════════════════════════════════════════════════════════
class _TappableInsight extends StatefulWidget {
  final Widget child;
  final InsightData insight;

  const _TappableInsight({required this.child, required this.insight});

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
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTap() {
    _showInsightSheet(context, widget.insight);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_DesignTokens.radiusLg),
                boxShadow:
                    _isPressed
                        ? [
                          BoxShadow(
                            color: widget.insight.accentColor.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: -4,
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
// INSIGHT DATA GENERATORS
// ═══════════════════════════════════════════════════════════════════════════
InsightData _getAscendantInsight(String sign, double degree) {
  return InsightData(
    title: 'Rising Sign',
    value: sign,
    description:
        'Your Ascendant (Lagna) is $sign at ${degree.toStringAsFixed(1)}°. The Ascendant represents the sign that was rising on the eastern horizon at the exact moment of your birth. It is considered the most important point in Vedic astrology.',
    significance:
        'The Ascendant shapes your physical appearance, personality, and how others perceive you. It acts as a lens through which all planetary energies are filtered in your chart.',
    keyPoints: [
      'Determines your body constitution and health tendencies',
      'Influences your natural approach to life and new situations',
      'Sets the foundation for all 12 houses in your birth chart',
      'Reveals your instinctive reactions and outer personality',
    ],
    accentColor: _getZodiacColor(sign),
    icon: Icons.wb_twilight_rounded,
    imagePath: _getZodiacImagePath(sign),
  );
}

InsightData _getMoonSignInsight(String sign) {
  return InsightData(
    title: 'Moon Sign',
    value: sign,
    description:
        'Your Moon is placed in $sign. In Vedic astrology, the Moon sign (Rashi) is considered more significant than the Sun sign as it represents your emotional nature and inner world.',
    significance:
        'The Moon governs your mind, emotions, and subconscious patterns. It reveals how you process feelings and what brings you emotional security.',
    keyPoints: [
      'Reflects your emotional responses and mental patterns',
      'Determines your Nakshatra (birth star) placement',
      'Influences your intuition and psychic sensitivity',
      'Shapes your relationship with mother and nurturing figures',
    ],
    accentColor: _getZodiacColor(sign),
    icon: Icons.nightlight_round,
    imagePath: _getZodiacImagePath(sign),
  );
}

InsightData _getSunSignInsight(String sign) {
  return InsightData(
    title: 'Sun Sign',
    value: sign,
    description:
        'Your Sun is placed in $sign. The Sun represents your soul essence, vitality, and core identity. It shows your life purpose and the qualities you are meant to develop.',
    significance:
        'The Sun indicates your father, authority figures, and your relationship with power. It reveals your ego, pride, and how you express your individuality.',
    keyPoints: [
      'Represents your soul\'s purpose and true self',
      'Governs vitality, health, and life force energy',
      'Indicates career potential and leadership abilities',
      'Influences relationship with father and authority',
    ],
    accentColor: _getZodiacColor(sign),
    icon: Icons.wb_sunny_rounded,
    imagePath: _getZodiacImagePath(sign),
  );
}

InsightData _getElementInsight(String element, String sign) {
  final descriptions = {
    'Fire':
        'Fire signs (Aries, Leo, Sagittarius) are dynamic, passionate, and action-oriented. They bring enthusiasm, courage, and creative inspiration.',
    'Earth':
        'Earth signs (Taurus, Virgo, Capricorn) are practical, grounded, and focused on material stability. They bring patience, reliability, and tangible results.',
    'Air':
        'Air signs (Gemini, Libra, Aquarius) are intellectual, communicative, and socially oriented. They bring ideas, connection, and mental agility.',
    'Water':
        'Water signs (Cancer, Scorpio, Pisces) are emotional, intuitive, and deeply feeling. They bring sensitivity, empathy, and spiritual depth.',
  };

  final traits = {
    'Fire': [
      'Courageous and bold',
      'Natural leaders',
      'Quick to act',
      'Inspiring to others',
    ],
    'Earth': [
      'Practical and reliable',
      'Patient builders',
      'Materially focused',
      'Strong endurance',
    ],
    'Air': [
      'Quick-minded',
      'Excellent communicators',
      'Socially adept',
      'Idea generators',
    ],
    'Water': [
      'Deeply intuitive',
      'Emotionally intelligent',
      'Nurturing nature',
      'Spiritually inclined',
    ],
  };

  return InsightData(
    title: 'Element',
    value: element,
    description:
        descriptions[element] ??
        'Your rising sign belongs to the $element element, shaping your fundamental approach to life.',
    significance:
        'Elements represent the basic building blocks of personality. Your $element nature influences how you perceive and interact with the world around you.',
    keyPoints:
        traits[element] ??
        [
          'Influences your temperament',
          'Shapes your reactions',
          'Affects compatibility',
        ],
    accentColor: _getElementColorFromImage(element),
    icon: _getElementIcon(element),
    imagePath: _getElementImagePath(element),
  );
}

IconData _getElementIcon(String element) {
  switch (element) {
    case 'Fire':
      return Icons.local_fire_department_rounded;
    case 'Earth':
      return Icons.landscape_rounded;
    case 'Air':
      return Icons.air_rounded;
    case 'Water':
      return Icons.water_drop_rounded;
    default:
      return Icons.category_rounded;
  }
}

InsightData _getLagnaLordInsight(String planet, String sign) {
  return InsightData(
    title: 'Lagna Lord',
    value: planet,
    description:
        '$planet is the ruler of your Ascendant sign $sign. As the chart ruler, its placement and condition significantly influence your entire life journey and personality expression.',
    significance:
        'The Lagna Lord acts as a guide for your soul\'s journey. Its house placement shows where you invest most of your energy, and its condition affects overall life success.',
    keyPoints: [
      'Most important planet for your chart interpretation',
      'Its strength indicates overall life vitality',
      'House placement shows primary life focus',
      'Aspects to it affect personality and health',
    ],
    accentColor: _getPlanetColor(planet),
    icon: Icons.star_rounded,
    imagePath: _getPlanetImagePath(planet),
  );
}

InsightData _getNakshatraLordInsight(String planet, String nakshatra) {
  return InsightData(
    title: 'Nakshatra Lord',
    value: planet,
    description:
        '$planet rules your birth Nakshatra $nakshatra. The Nakshatra lord operates at a subtle level, influencing your psychological patterns and karmic tendencies.',
    significance:
        'This planet governs the Vimshottari Dasha sequence of your life. Its condition and placement deeply affect your mental inclinations and spiritual path.',
    keyPoints: [
      'Determines your Mahadasha sequence',
      'Influences subconscious patterns',
      'Affects intuitive and psychic abilities',
      'Reveals karmic lessons from past lives',
    ],
    accentColor: _getPlanetColor(planet),
    icon: Icons.auto_awesome_rounded,
    imagePath: _getPlanetImagePath(planet),
  );
}

InsightData _getNakshatraInsight(String nakshatra, int pada, String gana) {
  return InsightData(
    title: 'Birth Star',
    value: '$nakshatra (Pada $pada)',
    description:
        'You were born under $nakshatra Nakshatra in Pada $pada. Nakshatras are the 27 lunar mansions that the Moon travels through, providing deep insights into your psychological nature.',
    significance:
        'Your Nakshatra reveals your innate talents, emotional patterns, and destiny path. The Pada (quarter) adds further specificity to these qualities.',
    keyPoints: [
      'Reveals deep personality traits and tendencies',
      'Indicates compatible Nakshatras for relationships',
      'Determines your Gana (temperament): $gana',
      'Provides insights into career and life path',
    ],
    accentColor: _Colors.rose,
    icon: Icons.auto_awesome,
  );
}

InsightData _getTithiInsight(String tithi, String paksha) {
  return InsightData(
    title: 'Tithi',
    value: tithi,
    description:
        'You were born on $tithi during $paksha Paksha. Tithi is the lunar day based on the angular relationship between Sun and Moon, one of the five elements of Panchang.',
    significance:
        'Each Tithi carries specific energies affecting your emotional nature and auspiciousness for different activities. It influences your relationship with lunar energy.',
    keyPoints: [
      'Indicates emotional temperament at birth',
      'Affects personality and decision-making style',
      '$paksha Paksha influences waxing/waning energy',
      'Used for determining auspicious timings',
    ],
    accentColor: _Colors.emerald,
    icon: Icons.brightness_2_rounded,
  );
}

InsightData _getYogaInsight(String yoga) {
  return InsightData(
    title: 'Yoga',
    value: yoga,
    description:
        'You were born under $yoga Yoga. This is calculated from the combined positions of Sun and Moon, representing the spiritual and psychological atmosphere of your birth moment.',
    significance:
        'Yoga influences your mental orientation and fortune. There are 27 Yogas, each bringing distinct qualities and tendencies to the native.',
    keyPoints: [
      'Affects mental and spiritual inclinations',
      'Influences overall fortune and luck',
      'Shapes approach to challenges',
      'Indicates periods of opportunity',
    ],
    accentColor: _Colors.emerald,
    icon: Icons.self_improvement_rounded,
  );
}

InsightData _getKaranaInsight(String karana) {
  return InsightData(
    title: 'Karana',
    value: karana,
    description:
        'Your birth Karana is $karana. Karana is half of a Tithi and there are 11 Karanas that repeat in a cycle. It influences dynamic action and productivity.',
    significance:
        'Karana affects your capacity for action and completing tasks. It particularly influences work ethic and the nature of your activities.',
    keyPoints: [
      'Governs action and productivity style',
      'Influences work and completion ability',
      'Affects day-to-day decision making',
      'Important for selecting activity timing',
    ],
    accentColor: _Colors.emerald,
    icon: Icons.bolt_rounded,
  );
}

InsightData _getVaraInsight(String vara, String deity) {
  return InsightData(
    title: 'Vara (Day)',
    value: vara,
    description:
        'You were born on $vara, ruled by $deity. The weekday of birth is significant in Vedic astrology, connecting you to specific planetary and deity energies.',
    significance:
        'Your birth day lord influences your character and brings blessings from its ruling deity. Each day carries unique qualities that shape personality.',
    keyPoints: [
      'Connects you to ${vara}\'s planetary ruler',
      '$deity is your birth day deity',
      'Influences natural talents and interests',
      'Auspicious for activities ruled by this day',
    ],
    accentColor: _Colors.emerald,
    icon: Icons.calendar_today_rounded,
  );
}

InsightData _getMahadashaInsight(String planet, double remaining) {
  return InsightData(
    title: 'Mahadasha',
    value: '$planet Mahadasha',
    description:
        'You are currently running the $planet Mahadasha with ${remaining.toStringAsFixed(1)} years remaining. Mahadasha is the major planetary period that colors all life experiences.',
    significance:
        'The Mahadasha planet becomes the primary influence during its period, activating its significations in your chart. Life themes shift with each new Mahadasha.',
    keyPoints: [
      'Primary influence for current life phase',
      'Activates houses ruled by $planet',
      'Check $planet\'s condition for period quality',
      'Sub-periods (Antardasha) provide refinement',
    ],
    accentColor: _getPlanetColor(planet),
    icon: Icons.hourglass_bottom_rounded,
    imagePath: _getPlanetImagePath(planet),
  );
}

InsightData _getGunaInsight(String gunaName, String value, Color color) {
  final descriptions = {
    'Varna':
        'Varna represents the spiritual temperament and indicates the type of work one is naturally suited for. Your Varna is $value.',
    'Vashya':
        'Vashya indicates mutual attraction and control in relationships. Your category is $value, which affects compatibility dynamics.',
    'Tara':
        'Tara (Birth Star) compatibility assesses the health of relationship. Your Tara is $value, influencing relationship harmony.',
    'Yoni':
        'Yoni represents sexual compatibility and physical attraction. Your Yoni is $value, indicating instinctual compatibility patterns.',
    'Graha Maitri':
        'Graha Maitri checks friendship between Moon sign lords. Your Moon lord is $value, affecting mental compatibility.',
    'Gana':
        'Gana indicates temperament and nature. Your Gana is $value, representing your fundamental character type.',
    'Bhakoot':
        'Bhakoot checks relative position of Moon signs. Your Moon is in $value, affecting emotional and health compatibility.',
    'Nadi':
        'Nadi indicates physiological compatibility and genetic factors. Your Nadi is $value, crucial for progeny and health.',
  };

  final significances = {
    'Varna':
        'Varna matching carries 1 point in Ashtakoot. It shows social and spiritual compatibility between partners.',
    'Vashya':
        'Vashya carries 2 points and indicates the power dynamics and mutual influence in relationships.',
    'Tara':
        'Tara carries 3 points and indicates health, longevity, and overall wellbeing of the relationship.',
    'Yoni':
        'Yoni carries 4 points and is crucial for physical and instinctual compatibility between partners.',
    'Graha Maitri':
        'Graha Maitri carries 5 points and determines mental wavelength and friendship compatibility.',
    'Gana':
        'Gana carries 6 points and indicates behavioral and temperamental harmony between partners.',
    'Bhakoot':
        'Bhakoot carries 7 points and affects emotional bonding, prosperity, and health after marriage.',
    'Nadi':
        'Nadi carries 8 points (highest) and is essential for genetic compatibility and healthy progeny.',
  };

  return InsightData(
    title: gunaName,
    value: value,
    description:
        descriptions[gunaName] ??
        'Your $gunaName factor is $value, used in Vedic compatibility matching.',
    significance:
        significances[gunaName] ??
        'This factor contributes to overall compatibility score in marriage matching.',
    keyPoints: [
      'Used in Ashtakoot (8-fold) matching system',
      'Helps assess relationship compatibility',
      'Based on Moon sign and Nakshatra',
      'Important for marriage compatibility',
    ],
    accentColor: color,
    icon: Icons.favorite_rounded,
  );
}

InsightData _getGemstoneInsight(
  String gemstone,
  String moonSign,
  String rulingPlanet,
) {
  return InsightData(
    title: 'Primary Gemstone',
    value: gemstone,
    description:
        '$gemstone is recommended as your primary gemstone based on your Moon sign $moonSign. Gemstones channel planetary energies and can strengthen benefic influences.',
    significance: rulingPlanet,
    keyPoints: [
      'Wear on ${_getLuckyDay(moonSign)} for best results',
      'Consult an astrologer before wearing',
      'Use natural, untreated stones',
      'Set in recommended metal for your sign',
    ],
    accentColor: _getGemstoneColor(gemstone),
    icon: Icons.diamond_rounded,
    imagePath: _getGemstoneImagePath(gemstone),
  );
}

InsightData _getLuckyNumbersInsight(String numbers, String moonSign) {
  return InsightData(
    title: 'Lucky Numbers',
    value: numbers,
    description:
        'Based on your Moon sign $moonSign, the numbers $numbers carry positive vibrations for you. Numerology connects numbers to planetary energies.',
    significance:
        'Lucky numbers can be used for important decisions, choosing dates, addresses, and other significant selections in life.',
    keyPoints: [
      'Derived from Moon sign planetary rulership',
      'Use for important dates and decisions',
      'Can influence address and phone numbers',
      'Combined with Nakshatra for precision',
    ],
    accentColor: _Colors.gold,
    icon: Icons.tag_rounded,
  );
}

InsightData _getLuckyDayInsight(String day, String moonSign) {
  return InsightData(
    title: 'Lucky Day',
    value: day,
    description:
        '$day is your most auspicious weekday based on your Moon sign $moonSign. This day is ruled by a planet that is harmonious with your chart.',
    significance:
        'Important activities, new beginnings, and significant decisions yield better results when initiated on your lucky day.',
    keyPoints: [
      'Best day for new ventures',
      'Wear your gemstone on this day',
      'Good for important meetings',
      'Enhanced intuition and luck',
    ],
    accentColor: _Colors.gold,
    icon: Icons.calendar_today_rounded,
  );
}

InsightData _getLuckyColorsInsight(String colors, String moonSign) {
  return InsightData(
    title: 'Lucky Colors',
    value: colors,
    description:
        'The colors $colors are harmonious with your Moon sign $moonSign. Colors carry vibrational frequencies that can enhance or diminish planetary energies.',
    significance:
        'Incorporating lucky colors in clothing, surroundings, and accessories can subtly enhance positive planetary influences.',
    keyPoints: [
      'Wear during important occasions',
      'Use in home and workspace decor',
      'Enhances positive planetary rays',
      'Can improve mood and confidence',
    ],
    accentColor: _Colors.gold,
    icon: Icons.palette_outlined,
  );
}

InsightData _getLuckyMetalInsight(String metal, String moonSign) {
  return InsightData(
    title: 'Lucky Metal',
    value: metal,
    description:
        '$metal is your recommended metal based on your Moon sign $moonSign. Metals conduct planetary energies and wearing them can strengthen beneficial influences.',
    significance:
        'The right metal amplifies gemstone effects and provides protection from negative planetary influences.',
    keyPoints: [
      'Use for setting gemstones',
      'Wear as jewelry for benefits',
      'Connects to ruling planet',
      'Traditional Vedic remedy',
    ],
    accentColor: _Colors.gold,
    icon: Icons.hexagon_outlined,
  );
}

InsightData _getPlanetaryStatusInsight(String status, List<String> planets) {
  final descriptions = {
    'Exalted':
        'Planets in exaltation are at their strongest and most beneficial. They deliver their best results and significations with full power.',
    'Debilitated':
        'Planets in debilitation are weakened and may struggle to deliver positive results. Remedies can help mitigate negative effects.',
    'Retrograde':
        'Retrograde planets appear to move backward and often bring karmic lessons. They work on internal and past-life matters.',
    'Combust':
        'Planets too close to the Sun become combust, their significations may be overshadowed or weakened by solar energy.',
  };

  final tips = {
    'Exalted': [
      'Leverage this strength in life',
      'Excellent for related activities',
      'Natural talent area',
      'Harness during its Dasha',
    ],
    'Debilitated': [
      'Practice related remedies',
      'Be patient with these areas',
      'Cancellation may apply',
      'Growth through challenges',
    ],
    'Retrograde': [
      'Review and reflect themes',
      'Past-life karmic work',
      'Internal development focus',
      'Delays may have purpose',
    ],
    'Combust': [
      'Strengthen through mantras',
      'May need more effort',
      'Sun period affects these',
      'Humility in these areas',
    ],
  };

  final planetStr = planets.isEmpty ? 'None' : planets.join(', ');

  return InsightData(
    title: '$status Planets',
    value: planetStr,
    description:
        descriptions[status] ??
        'Planets with special status require attention in chart interpretation.',
    significance:
        planets.isEmpty
            ? 'No planets in this condition in your chart.'
            : 'These planets (${planets.join(", ")}) are $status in your chart, affecting their significations.',
    keyPoints:
        tips[status] ??
        [
          'Check individual planet effects',
          'Consider house placement',
          'Review Dasha periods',
        ],
    accentColor:
        status == 'Exalted'
            ? _Colors.emerald
            : status == 'Debilitated'
            ? _Colors.coral
            : status == 'Retrograde'
            ? _Colors.amber
            : _Colors.rose,
    icon:
        status == 'Exalted'
            ? Icons.arrow_upward_rounded
            : status == 'Debilitated'
            ? Icons.arrow_downward_rounded
            : status == 'Retrograde'
            ? Icons.replay_rounded
            : Icons.local_fire_department_outlined,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// NAVIGATION SECTION DATA
// ═══════════════════════════════════════════════════════════════════════════
const _sections = [
  NavSection(id: 'profile', label: 'Profile', color: _Colors.violet),
  NavSection(id: 'star', label: 'Star', color: _Colors.rose),
  NavSection(id: 'panchang', label: 'Panchang', color: _Colors.emerald),
  NavSection(id: 'dasha', label: 'Dasha', color: _Colors.sky),
  NavSection(id: 'guna', label: 'Guna', color: _Colors.coral),
  NavSection(id: 'lucky', label: 'Lucky', color: _Colors.gold),
  NavSection(id: 'planets', label: 'Planets', color: _Colors.teal),
];

/// Details Tab - Shows comprehensive birth chart details
/// Premium, elegant UI with clear visual hierarchy
class DetailsTab extends StatefulWidget {
  final KundaliData kundaliData;

  const DetailsTab({super.key, required this.kundaliData});

  @override
  State<DetailsTab> createState() => _DetailsTabState();
}

class _DetailsTabState extends State<DetailsTab> {
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

    // Initialize keys for each section
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

    // alignment: 0.05 gives ~5% viewport margin from top for comfortable spacing
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
              // Profile Summary
              _AnimatedSectionWrapper(
                key: _animatedKeys['profile'],
                sectionKey: _sectionKeys['profile']!,
                accentColor: _Colors.violet,
                child: _AnimatedCardWrapper(
                  child: _ProfileCard(kundaliData: widget.kundaliData),
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // Core Elements + Nakshatra Section
              _AnimatedSectionWrapper(
                key: _animatedKeys['star'],
                sectionKey: _sectionKeys['star']!,
                accentColor: _Colors.rose,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: 'Core Elements',
                      accentColor: _Colors.rose,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: _CoreElementsGrid(kundaliData: widget.kundaliData),
                    ),
                    const SizedBox(height: _DesignTokens.space24),
                    _AnimatedSectionHeader(
                      title: 'Birth Star',
                      accentColor: _Colors.rose,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 100,
                      child: _NakshatraCard(kundaliData: widget.kundaliData),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // Panchang Section
              _AnimatedSectionWrapper(
                key: _animatedKeys['panchang'],
                sectionKey: _sectionKeys['panchang']!,
                accentColor: _Colors.emerald,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: 'Panchang',
                      accentColor: _Colors.emerald,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: _PanchangCard(kundaliData: widget.kundaliData),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // Dasha Section
              _AnimatedSectionWrapper(
                key: _animatedKeys['dasha'],
                sectionKey: _sectionKeys['dasha']!,
                accentColor: _Colors.sky,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: 'Current Period',
                      accentColor: _Colors.sky,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: _DashaCard(kundaliData: widget.kundaliData),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // Guna Factors
              _AnimatedSectionWrapper(
                key: _animatedKeys['guna'],
                sectionKey: _sectionKeys['guna']!,
                accentColor: _Colors.coral,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: 'Guna Factors',
                      accentColor: _Colors.coral,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: _GunaFactorsCard(kundaliData: widget.kundaliData),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // Lucky Elements
              _AnimatedSectionWrapper(
                key: _animatedKeys['lucky'],
                sectionKey: _sectionKeys['lucky']!,
                accentColor: _Colors.gold,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: 'Favorable Elements',
                      accentColor: _Colors.gold,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: _LuckyElementsCard(
                        kundaliData: widget.kundaliData,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // Planetary Status
              _AnimatedSectionWrapper(
                key: _animatedKeys['planets'],
                sectionKey: _sectionKeys['planets']!,
                accentColor: _Colors.teal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: 'Planetary Status',
                      accentColor: _Colors.teal,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: _PlanetaryStatusCard(
                        kundaliData: widget.kundaliData,
                      ),
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
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATED SECTION WRAPPER - Premium Highlight Effect
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
  // We'll use InheritedWidget pattern to pass animation trigger to children
  bool _isHighlighted = false;

  void triggerHighlight() {
    HapticFeedback.lightImpact();
    setState(() => _isHighlighted = true);
    // Reset after animation duration
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

// InheritedWidget to pass animation state to children
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
// ANIMATED SECTION HEADER - Elegant underline sweep + text pulse
// ═══════════════════════════════════════════════════════════════════════════
class _AnimatedSectionHeader extends StatefulWidget {
  final String title;
  final Color accentColor;

  const _AnimatedSectionHeader({
    required this.title,
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

    // Underline sweeps from left to right
    _underlineAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    );

    // Text pulses in accent color
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
              const SizedBox(height: 4),
              // Animated underline
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = math.min(constraints.maxWidth * 0.3, 40.0);
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
// ANIMATED CARD WRAPPER - Gentle scale pop + shadow lift
// ═══════════════════════════════════════════════════════════════════════════
class _AnimatedCardWrapper extends StatefulWidget {
  final Widget child;
  final int delay; // Stagger delay in milliseconds

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

    // Scale with a gentle pop (slight overshoot)
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

    // Shadow lift
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
      // Apply stagger delay
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
// PROFILE CARD - Redesigned with elegant interactions
// ═══════════════════════════════════════════════════════════════════════════
class _ProfileCard extends StatelessWidget {
  final KundaliData kundaliData;

  const _ProfileCard({required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header section with zodiac and birth info
          Padding(
            padding: const EdgeInsets.all(_DesignTokens.space16),
            child: Row(
              children: [
                // Interactive Zodiac Badge
                _InteractiveZodiacBadge(sign: kundaliData.ascendant.sign),
                const SizedBox(width: _DesignTokens.space16),

                // Birth Details - refined typography
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(kundaliData.birthDateTime),
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _Colors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: _DesignTokens.space8),
                      // Time and location row
                      _InfoRow(
                        icon: Icons.access_time_rounded,
                        text: _formatTime(kundaliData.birthDateTime),
                        isHighlighted: true,
                      ),
                      const SizedBox(height: _DesignTokens.space6),
                      _InfoRow(
                        icon: Icons.place_outlined,
                        text: kundaliData.birthPlace,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Subtle divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(
              horizontal: _DesignTokens.space16,
            ),
            color: _Colors.borderSubtle,
          ),

          // Three pillars - interactive cards
          Builder(
            builder:
                (context) => Padding(
                  padding: const EdgeInsets.all(_DesignTokens.space12),
                  child: Row(
                    children: [
                      _InteractivePillar(
                        label: 'Ascendant',
                        sign: kundaliData.ascendant.sign,
                        icon: Icons.wb_twilight_rounded,
                        onTap:
                            () => _showInsightSheet(
                              context,
                              _getAscendantInsight(
                                kundaliData.ascendant.sign,
                                kundaliData.ascendant.signDegree,
                              ),
                            ),
                      ),
                      const SizedBox(width: _DesignTokens.space8),
                      _InteractivePillar(
                        label: 'Moon',
                        sign: kundaliData.moonSign,
                        icon: Icons.nightlight_round,
                        onTap:
                            () => _showInsightSheet(
                              context,
                              _getMoonSignInsight(kundaliData.moonSign),
                            ),
                      ),
                      const SizedBox(width: _DesignTokens.space8),
                      _InteractivePillar(
                        label: 'Sun',
                        sign: kundaliData.sunSign,
                        icon: Icons.wb_sunny_rounded,
                        onTap:
                            () => _showInsightSheet(
                              context,
                              _getSunSignInsight(kundaliData.sunSign),
                            ),
                      ),
                    ],
                  ),
                ),
          ),

          // Disclaimer about Vedic vs Western astrology
          _VedicDisclaimer(
            vedicSign: kundaliData.sunSign,
            westernSign: _getWesternZodiac(kundaliData.birthDateTime),
          ),
        ],
      ),
    );
  }

  /// Get Western (Tropical) zodiac sign based on birth month/day
  String _getWesternZodiac(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21))
      return 'Scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21))
      return 'Sagittarius';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19))
      return 'Capricorn';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18))
      return 'Aquarius';
    return 'Pisces';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period';
  }
}

/// Compact info row with icon
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isHighlighted;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 13,
          color: isHighlighted ? _Colors.textSecondary : _Colors.textTertiary,
        ),
        const SizedBox(width: _DesignTokens.space6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isHighlighted ? FontWeight.w500 : FontWeight.w400,
              color:
                  isHighlighted ? _Colors.textSecondary : _Colors.textTertiary,
              letterSpacing: isHighlighted ? 0.5 : 0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Disclaimer showing Vedic vs Western zodiac difference
class _VedicDisclaimer extends StatelessWidget {
  final String vedicSign;
  final String westernSign;

  const _VedicDisclaimer({required this.vedicSign, required this.westernSign});

  @override
  Widget build(BuildContext context) {
    final westernColor = _getZodiacColor(westernSign);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        _DesignTokens.space12,
        0,
        _DesignTokens.space12,
        _DesignTokens.space12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: _DesignTokens.space12,
        vertical: _DesignTokens.space10,
      ),
      decoration: BoxDecoration(
        color: _Colors.bgSecondary.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: _Colors.textTertiary,
          ),
          const SizedBox(width: _DesignTokens.space8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: _Colors.textTertiary,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'Based on Vedic planetary positions. '),
                  const TextSpan(
                    text: 'Western astrology: ',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: westernSign,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: westernColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive zodiac badge with tap animation
class _InteractiveZodiacBadge extends StatefulWidget {
  final String sign;

  const _InteractiveZodiacBadge({required this.sign});

  @override
  State<_InteractiveZodiacBadge> createState() =>
      _InteractiveZodiacBadgeState();
}

class _InteractiveZodiacBadgeState extends State<_InteractiveZodiacBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.02,
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
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final zodiacColor = _getZodiacColor(widget.sign);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotateAnimation.value,
              child: child,
            ),
          );
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              // Ambient shadow - soft and diffused
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 16,
                spreadRadius: -4,
                offset: const Offset(0, 6),
              ),
              // Color accent glow
              BoxShadow(
                color: zodiacColor.withOpacity(_isPressed ? 0.35 : 0.15),
                blurRadius: _isPressed ? 20 : 12,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              _getZodiacImagePath(widget.sign),
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: _Colors.bgSecondary,
                  child: Center(
                    child: Text(
                      _getSignSymbol(widget.sign),
                      style: TextStyle(fontSize: 26, color: zodiacColor),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Interactive pillar with press state and elegant animation
class _InteractivePillar extends StatefulWidget {
  final String label;
  final String sign;
  final IconData icon;
  final VoidCallback? onTap;

  const _InteractivePillar({
    required this.label,
    required this.sign,
    required this.icon,
    this.onTap,
  });

  @override
  State<_InteractivePillar> createState() => _InteractivePillarState();
}

class _InteractivePillarState extends State<_InteractivePillar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
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
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final zodiacColor = _getZodiacColor(widget.sign);

    return Expanded(
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
              horizontal: _DesignTokens.space8,
              vertical: _DesignTokens.space10,
            ),
            decoration: BoxDecoration(
              color:
                  _isPressed
                      ? zodiacColor.withOpacity(0.08)
                      : _Colors.bgSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    _isPressed
                        ? zodiacColor.withOpacity(0.3)
                        : _Colors.borderSubtle,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Label with icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, size: 10, color: _Colors.textTertiary),
                    const SizedBox(width: 3),
                    Text(
                      widget.label,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: _Colors.textTertiary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: _DesignTokens.space8),
                // Zodiac image with premium shadow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      // Deep ambient shadow
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: -3,
                        offset: const Offset(0, 4),
                      ),
                      // Color accent glow
                      BoxShadow(
                        color: zodiacColor.withOpacity(_isPressed ? 0.25 : 0.1),
                        blurRadius: _isPressed ? 14 : 8,
                        spreadRadius: -2,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      _getZodiacImagePath(widget.sign),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          color: _Colors.bgSecondary,
                          child: Center(
                            child: Text(
                              _getSignSymbol(widget.sign),
                              style: TextStyle(
                                fontSize: 20,
                                color: zodiacColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: _DesignTokens.space6),
                // Sign name
                Text(
                  widget.sign,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: zodiacColor,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CORE ELEMENTS GRID
// ═══════════════════════════════════════════════════════════════════════════
class _CoreElementsGrid extends StatelessWidget {
  final KundaliData kundaliData;

  const _CoreElementsGrid({required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final ascendant = kundaliData.ascendant;
    final element = _getSignElement(ascendant.sign);
    final lagnaLord = _getLagnaLord(ascendant.sign);
    final zodiacColor = _getZodiacColor(ascendant.sign);
    final nakshatraLord = _getNakshatraLord(kundaliData.birthNakshatra);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: 'Rising Sign',
                value: ascendant.sign,
                sublabel: '${ascendant.signDegree.toStringAsFixed(1)}°',
                color: zodiacColor,
                showZodiacImage: true,
                onTap:
                    () => _showInsightSheet(
                      context,
                      _getAscendantInsight(
                        ascendant.sign,
                        ascendant.signDegree,
                      ),
                    ),
              ),
            ),
            const SizedBox(width: _DesignTokens.space8),
            Expanded(
              child: _MetricTile(
                label: 'Element',
                value: element,
                sublabel: _getElementDescription(element),
                color: _getElementColor(element),
                showElementImage: true,
                onTap:
                    () => _showInsightSheet(
                      context,
                      _getElementInsight(element, ascendant.sign),
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: _DesignTokens.space8),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: 'Lagna Lord',
                value: lagnaLord,
                sublabel: 'Chart ruler',
                color: _getPlanetColor(lagnaLord),
                showPlanetImage: true,
                onTap:
                    () => _showInsightSheet(
                      context,
                      _getLagnaLordInsight(lagnaLord, ascendant.sign),
                    ),
              ),
            ),
            const SizedBox(width: _DesignTokens.space8),
            Expanded(
              child: _MetricTile(
                label: 'Nakshatra Lord',
                value: nakshatraLord,
                sublabel: 'Star lord',
                color: _getPlanetColor(nakshatraLord),
                showPlanetImage: true,
                onTap:
                    () => _showInsightSheet(
                      context,
                      _getNakshatraLordInsight(
                        nakshatraLord,
                        kundaliData.birthNakshatra,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getElementDescription(String element) {
    switch (element) {
      case 'Fire':
        return 'Dynamic';
      case 'Earth':
        return 'Grounded';
      case 'Air':
        return 'Intellectual';
      case 'Water':
        return 'Intuitive';
      default:
        return '';
    }
  }

  Color _getElementColor(String element) {
    // Colors based on actual element image visual palette
    switch (element) {
      case 'Fire':
        return const Color(0xFFFF8C42); // Warm orange/golden flames
      case 'Earth':
        return const Color(0xFF4ADE80); // Vibrant green land
      case 'Air':
        return const Color(0xFFB794F6); // Soft lavender swirl
      case 'Water':
        return const Color(0xFF2D9CDB); // Deep ocean blue
      default:
        return _Colors.textSecondary;
    }
  }
}

class _MetricTile extends StatefulWidget {
  final String label;
  final String value;
  final String sublabel;
  final Color color;
  final bool showZodiacImage;
  final bool showPlanetImage;
  final bool showElementImage;
  final VoidCallback? onTap;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.sublabel,
    required this.color,
    this.showZodiacImage = false,
    this.showPlanetImage = false,
    this.showElementImage = false,
    this.onTap,
  });

  @override
  State<_MetricTile> createState() => _MetricTileState();
}

class _MetricTileState extends State<_MetricTile>
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
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        widget.showZodiacImage ||
        widget.showPlanetImage ||
        widget.showElementImage;

    String getImagePath() {
      if (widget.showPlanetImage) return _getPlanetImagePath(widget.value);
      if (widget.showElementImage) return _getElementImagePath(widget.value);
      return _getZodiacImagePath(widget.value);
    }

    String getFallbackSymbol() {
      if (widget.showPlanetImage) return _getPlanetSymbol(widget.value);
      if (widget.showElementImage) return _getElementSymbol(widget.value);
      return _getSignSymbol(widget.value);
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Stack(
          children: [
            _Card(
              padding: const EdgeInsets.all(_DesignTokens.space12),
              child: Row(
                children: [
                  if (hasImage) ...[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            spreadRadius: -3,
                            offset: const Offset(0, 3),
                          ),
                          BoxShadow(
                            color: widget.color.withOpacity(
                              _isPressed ? 0.2 : 0.08,
                            ),
                            blurRadius: _isPressed ? 14 : 10,
                            spreadRadius: -4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          getImagePath(),
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint(
                              'Image load error for ${getImagePath()}: $error',
                            );
                            return Container(
                              color: widget.color.withOpacity(0.1),
                              child: Center(
                                child: Text(
                                  getFallbackSymbol(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: widget.color,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: _DesignTokens.space10),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.label, style: _DesignTokens.labelXs),
                        const SizedBox(height: _DesignTokens.space4),
                        Text(
                          widget.value,
                          style: _DesignTokens.titleSm.copyWith(
                            color: widget.color,
                          ),
                        ),
                        const SizedBox(height: _DesignTokens.space2),
                        Text(widget.sublabel, style: _DesignTokens.labelXs),
                      ],
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
// NAKSHATRA CARD
// ═══════════════════════════════════════════════════════════════════════════
class _NakshatraCard extends StatefulWidget {
  final KundaliData kundaliData;

  const _NakshatraCard({required this.kundaliData});

  @override
  State<_NakshatraCard> createState() => _NakshatraCardState();
}

class _NakshatraCardState extends State<_NakshatraCard>
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
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    final nakshatra = widget.kundaliData.birthNakshatra;
    final pada = widget.kundaliData.birthNakshatraPada;
    final gana = _getNakshatraGana(nakshatra);
    _showInsightSheet(context, _getNakshatraInsight(nakshatra, pada, gana));
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final nakshatra = widget.kundaliData.birthNakshatra;
    final pada = widget.kundaliData.birthNakshatraPada;
    final moonPos = widget.kundaliData.planetPositions['Moon'];
    final gana = _getNakshatraGana(nakshatra);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Stack(
          children: [
            _Card(
              child: Column(
                children: [
                  // Main nakshatra info
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _Colors.rose.withOpacity(
                            _isPressed ? 0.2 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(
                            _DesignTokens.radiusMd,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _getNakshatraSymbol(nakshatra),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: _DesignTokens.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nakshatra, style: _DesignTokens.titleMd),
                            const SizedBox(height: _DesignTokens.space2),
                            Text(
                              'Pada $pada • ${moonPos?.signDegree.toStringAsFixed(1)}° in ${moonPos?.sign ?? ''}',
                              style: _DesignTokens.labelSm,
                            ),
                          ],
                        ),
                      ),
                      _StatusChip(label: gana, color: _getGanaColor(gana)),
                    ],
                  ),

                  const SizedBox(height: _DesignTokens.space16),

                  // Details grid
                  Container(
                    padding: const EdgeInsets.all(_DesignTokens.space12),
                    decoration: BoxDecoration(
                      color: _Colors.bgSecondary,
                      borderRadius: BorderRadius.circular(
                        _DesignTokens.radiusMd,
                      ),
                    ),
                    child: Row(
                      children: [
                        _InfoCell(
                          label: 'Lord',
                          value: _getNakshatraLord(nakshatra),
                          isPlanet: true,
                        ),
                        _InfoCell(
                          label: 'Deity',
                          value: _getNakshatraDeity(nakshatra),
                        ),
                        _InfoCell(
                          label: 'Yoni',
                          value: _getNakshatraYoni(nakshatra),
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
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _DesignTokens.space8,
        vertical: _DesignTokens.space4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(_DesignTokens.radiusSm),
      ),
      child: Text(
        label,
        style: _DesignTokens.labelXs.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  final bool isPlanet;

  const _InfoCell({
    required this.label,
    required this.value,
    this.isPlanet = false,
  });

  @override
  Widget build(BuildContext context) {
    final planetColor = isPlanet ? _getPlanetColor(value) : null;

    return Expanded(
      child: Column(
        children: [
          Text(label, style: _DesignTokens.labelXs),
          const SizedBox(height: _DesignTokens.space6),
          if (isPlanet) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: planetColor!.withOpacity(0.15),
                    blurRadius: 4,
                    spreadRadius: -1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  _getPlanetImagePath(value),
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: planetColor.withOpacity(0.1),
                      child: Center(
                        child: Text(
                          _getPlanetSymbol(value),
                          style: TextStyle(fontSize: 14, color: planetColor),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: _DesignTokens.space4),
            Text(
              value,
              style: _DesignTokens.labelXs.copyWith(
                color: planetColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ] else
            Text(
              value,
              style: _DesignTokens.bodySm,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PANCHANG CARD
// ═══════════════════════════════════════════════════════════════════════════
class _PanchangCard extends StatelessWidget {
  final KundaliData kundaliData;

  const _PanchangCard({required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final sunPos = kundaliData.planetPositions['Sun'];
    final moonPos = kundaliData.planetPositions['Moon'];

    final panchang = KundaliCalculationService.calculatePanchang(
      kundaliData.birthDateTime,
      sunPos?.longitude ?? 0,
      moonPos?.longitude ?? 0,
    );

    return _Card(
      child: Column(
        children: [
          // Tithi & Moon phase - tappable
          _TappablePanchangRow(
            child: Row(
              children: [
                MoonPhaseWidget(
                  tithiNumber: panchang.tithiNumber,
                  paksha: panchang.paksha,
                  size: 48,
                ),
                const SizedBox(width: _DesignTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(panchang.tithi, style: _DesignTokens.titleMd),
                      const SizedBox(height: _DesignTokens.space2),
                      Text(
                        '${panchang.paksha} Paksha',
                        style: _DesignTokens.labelSm,
                      ),
                    ],
                  ),
                ),
                _StatusChip(label: panchang.vara, color: _Colors.emerald),
              ],
            ),
            onTap:
                () => _showInsightSheet(
                  context,
                  _getTithiInsight(panchang.tithi, panchang.paksha),
                ),
          ),

          const SizedBox(height: _DesignTokens.space16),

          // Panchang details - each item tappable
          Container(
            padding: const EdgeInsets.all(_DesignTokens.space12),
            decoration: BoxDecoration(
              color: _Colors.bgSecondary,
              borderRadius: BorderRadius.circular(_DesignTokens.radiusMd),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _TappablePanchangItem(
                        label: 'Yoga',
                        value: panchang.yoga,
                        onTap:
                            () => _showInsightSheet(
                              context,
                              _getYogaInsight(panchang.yoga),
                            ),
                      ),
                    ),
                    Expanded(
                      child: _TappablePanchangItem(
                        label: 'Karana',
                        value: panchang.karana,
                        onTap:
                            () => _showInsightSheet(
                              context,
                              _getKaranaInsight(panchang.karana),
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: _DesignTokens.space12),
                Row(
                  children: [
                    Expanded(
                      child: _TappablePanchangItem(
                        label: 'Vara',
                        value: panchang.vara,
                        onTap:
                            () => _showInsightSheet(
                              context,
                              _getVaraInsight(
                                panchang.vara,
                                panchang.varaDeity,
                              ),
                            ),
                      ),
                    ),
                    _InfoCell(label: 'Nakshatra', value: panchang.nakshatra),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tappable row for Panchang header
class _TappablePanchangRow extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TappablePanchangRow({required this.child, required this.onTap});

  @override
  State<_TappablePanchangRow> createState() => _TappablePanchangRowState();
}

class _TappablePanchangRowState extends State<_TappablePanchangRow> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(_DesignTokens.space8),
        decoration: BoxDecoration(
          color:
              _isPressed
                  ? _Colors.emerald.withOpacity(0.08)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(_DesignTokens.radiusMd),
        ),
        child: widget.child,
      ),
    );
  }
}

/// Tappable item for Panchang details
class _TappablePanchangItem extends StatefulWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TappablePanchangItem({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  State<_TappablePanchangItem> createState() => _TappablePanchangItemState();
}

class _TappablePanchangItemState extends State<_TappablePanchangItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(
          horizontal: _DesignTokens.space8,
          vertical: _DesignTokens.space6,
        ),
        decoration: BoxDecoration(
          color:
              _isPressed
                  ? _Colors.emerald.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(_DesignTokens.radiusSm),
        ),
        child: Column(
          children: [
            Text(widget.label, style: _DesignTokens.labelXs),
            const SizedBox(height: _DesignTokens.space6),
            Text(
              widget.value,
              style: _DesignTokens.bodySm,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DASHA CARD
// ═══════════════════════════════════════════════════════════════════════════
class _DashaCard extends StatefulWidget {
  final KundaliData kundaliData;

  const _DashaCard({required this.kundaliData});

  @override
  State<_DashaCard> createState() => _DashaCardState();
}

class _DashaCardState extends State<_DashaCard>
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
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    final dasha = widget.kundaliData.dashaInfo;
    _showInsightSheet(
      context,
      _getMahadashaInsight(dasha.currentMahadasha, dasha.remainingYears),
    );
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final dasha = widget.kundaliData.dashaInfo;
    final planetColor = _getPlanetColor(dasha.currentMahadasha);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Stack(
          children: [
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Mahadasha
                  Row(
                    children: [
                      // Planet image with premium shadow
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              spreadRadius: -3,
                              offset: const Offset(0, 5),
                            ),
                            BoxShadow(
                              color: planetColor.withOpacity(
                                _isPressed ? 0.25 : 0.15,
                              ),
                              blurRadius: _isPressed ? 14 : 10,
                              spreadRadius: -2,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            _getPlanetImagePath(dasha.currentMahadasha),
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: planetColor.withOpacity(0.12),
                                child: Center(
                                  child: Text(
                                    _getPlanetSymbol(dasha.currentMahadasha),
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: planetColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: _DesignTokens.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${dasha.currentMahadasha} Mahadasha',
                              style: _DesignTokens.titleMd,
                            ),
                            const SizedBox(height: _DesignTokens.space4),
                            Row(
                              children: [
                                Icon(
                                  Icons.hourglass_bottom_rounded,
                                  size: 12,
                                  color: _Colors.textTertiary,
                                ),
                                const SizedBox(width: _DesignTokens.space4),
                                Text(
                                  '${dasha.remainingYears.toStringAsFixed(1)} years remaining',
                                  style: _DesignTokens.labelSm,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: _DesignTokens.space16),

                  // Dasha sequence
                  Text('UPCOMING', style: _DesignTokens.labelXs),
                  const SizedBox(height: _DesignTokens.space8),
                  SizedBox(
                    height: 88,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: math.min(5, dasha.sequence.length),
                      separatorBuilder:
                          (_, __) =>
                              const SizedBox(width: _DesignTokens.space8),
                      itemBuilder: (context, index) {
                        final period = dasha.sequence[index];
                        final isCurrent =
                            period.planet == dasha.currentMahadasha;
                        final color = _getPlanetColor(period.planet);
                        return _DashaPeriodChip(
                          planet: period.planet,
                          years: period.years,
                          color: color,
                          isActive: isCurrent,
                        );
                      },
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

class _DashaPeriodChip extends StatelessWidget {
  final String planet;
  final int years;
  final Color color;
  final bool isActive;

  const _DashaPeriodChip({
    required this.planet,
    required this.years,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: _DesignTokens.space8),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : _Colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color.withOpacity(0.25) : _Colors.borderSubtle,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Planet image with subtle shadow
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow:
                  isActive
                      ? [
                        BoxShadow(
                          color: color.withOpacity(0.2),
                          blurRadius: 6,
                          spreadRadius: -2,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                _getPlanetImagePath(planet),
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      _getPlanetSymbol(planet),
                      style: TextStyle(fontSize: 16, color: color),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: _DesignTokens.space4),
          // Planet name
          Text(
            _getShortPlanetName(planet),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: isActive ? color : _Colors.textSecondary,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: _DesignTokens.space2),
          // Duration
          Text(
            '${years}y',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive ? color : _Colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GUNA FACTORS CARD
// ═══════════════════════════════════════════════════════════════════════════
class _GunaFactorsCard extends StatelessWidget {
  final KundaliData kundaliData;

  const _GunaFactorsCard({required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final nakshatra = kundaliData.birthNakshatra;
    final moonSign = kundaliData.moonSign;
    final nakshatraIndex = KundaliCalculationService.nakshatras.indexOf(
      nakshatra,
    );
    final taraNumber = (nakshatraIndex % 9) + 1;

    return _Card(
      child: Column(
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(_DesignTokens.space10),
            decoration: BoxDecoration(
              color: _Colors.violet.withOpacity(0.08),
              borderRadius: BorderRadius.circular(_DesignTokens.radiusSm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: _Colors.violet,
                ),
                const SizedBox(width: _DesignTokens.space8),
                Expanded(
                  child: Text(
                    'Your Ashtakoot factors for compatibility matching',
                    style: _DesignTokens.labelSm.copyWith(
                      color: _Colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: _DesignTokens.space16),

          // Guna grid
          _GunaGrid(
            items: [
              _GunaData('Varna', _getVarna(moonSign), _Colors.amber),
              _GunaData('Vashya', _getVashya(moonSign), _Colors.sky),
              _GunaData('Tara', _getTaraName(taraNumber), _Colors.emerald),
              _GunaData('Yoni', _getNakshatraYoni(nakshatra), _Colors.violet),
              _GunaData(
                'Graha Maitri',
                _getLagnaLord(moonSign),
                _Colors.teal,
                isPlanet: true,
              ),
              _GunaData('Gana', _getNakshatraGana(nakshatra), _Colors.rose),
              _GunaData('Bhakoot', moonSign, _Colors.coral, isZodiacSign: true),
              _GunaData('Nadi', _getNadi(nakshatra), _Colors.gold),
            ],
          ),
        ],
      ),
    );
  }
}

class _GunaData {
  final String label;
  final String value;
  final Color color;
  final bool isZodiacSign;
  final bool isPlanet;

  _GunaData(
    this.label,
    this.value,
    this.color, {
    this.isZodiacSign = false,
    this.isPlanet = false,
  });
}

class _GunaGrid extends StatelessWidget {
  final List<_GunaData> items;

  const _GunaGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: _DesignTokens.space8,
        crossAxisSpacing: _DesignTokens.space8,
        childAspectRatio: 2.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _GunaCell(
          label: item.label,
          value: item.value,
          color: item.color,
          isZodiacSign: item.isZodiacSign,
          isPlanet: item.isPlanet,
        );
      },
    );
  }
}

class _GunaCell extends StatefulWidget {
  final String label;
  final String value;
  final Color color;
  final bool isZodiacSign;
  final bool isPlanet;

  const _GunaCell({
    required this.label,
    required this.value,
    required this.color,
    this.isZodiacSign = false,
    this.isPlanet = false,
  });

  @override
  State<_GunaCell> createState() => _GunaCellState();
}

class _GunaCellState extends State<_GunaCell> {
  bool _isPressed = false;

  void _showGunaInsight() {
    _showInsightSheet(
      context,
      _getGunaInsight(widget.label, widget.value, widget.color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayColor =
        widget.isZodiacSign
            ? _getZodiacColor(widget.value)
            : (widget.isPlanet ? _getPlanetColor(widget.value) : widget.color);
    final hasImage = widget.isZodiacSign || widget.isPlanet;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        _showGunaInsight();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(_DesignTokens.space10),
        decoration: BoxDecoration(
          color:
              _isPressed
                  ? displayColor.withOpacity(0.15)
                  : _Colors.surfaceElevated,
          borderRadius: BorderRadius.circular(_DesignTokens.radiusSm),
          border: Border.all(
            color:
                _isPressed ? displayColor.withOpacity(0.3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (hasImage) ...[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: displayColor.withOpacity(_isPressed ? 0.25 : 0.15),
                      blurRadius: _isPressed ? 6 : 4,
                      spreadRadius: -1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    widget.isPlanet
                        ? _getPlanetImagePath(widget.value)
                        : _getZodiacImagePath(widget.value),
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: displayColor.withOpacity(0.1),
                        child: Center(
                          child: Text(
                            widget.isPlanet
                                ? _getPlanetSymbol(widget.value)
                                : _getSignSymbol(widget.value),
                            style: TextStyle(fontSize: 14, color: displayColor),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  color: displayColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
            const SizedBox(width: _DesignTokens.space10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: _DesignTokens.labelXs,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: _DesignTokens.space2),
                  Text(
                    widget.value,
                    style: _DesignTokens.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.isZodiacSign ? displayColor : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
// LUCKY ELEMENTS CARD
// ═══════════════════════════════════════════════════════════════════════════
class _LuckyElementsCard extends StatelessWidget {
  final KundaliData kundaliData;

  const _LuckyElementsCard({required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final moonSign = kundaliData.moonSign;
    final gemstone = _getLuckyGemstone(moonSign);

    return _Card(
      child: Column(
        children: [
          // Featured gemstone
          _InteractiveGemstoneRow(gemstone: gemstone, moonSign: moonSign),

          const SizedBox(height: _DesignTokens.space16),

          // Lucky factors grid
          Row(
            children: [
              Expanded(
                child: _LuckyTile(
                  icon: Icons.tag_rounded,
                  label: 'Numbers',
                  value: _getLuckyNumbers(moonSign),
                  onTap:
                      () => _showInsightSheet(
                        context,
                        _getLuckyNumbersInsight(
                          _getLuckyNumbers(moonSign),
                          moonSign,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: _DesignTokens.space8),
              Expanded(
                child: _LuckyTile(
                  icon: Icons.calendar_today_rounded,
                  label: 'Day',
                  value: _getLuckyDay(moonSign),
                  onTap:
                      () => _showInsightSheet(
                        context,
                        _getLuckyDayInsight(_getLuckyDay(moonSign), moonSign),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: _DesignTokens.space8),
          Row(
            children: [
              Expanded(
                child: _LuckyTile(
                  icon: Icons.palette_outlined,
                  label: 'Colors',
                  value: _getLuckyColors(moonSign),
                  onTap:
                      () => _showInsightSheet(
                        context,
                        _getLuckyColorsInsight(
                          _getLuckyColors(moonSign),
                          moonSign,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: _DesignTokens.space8),
              Expanded(
                child: _LuckyTile(
                  icon: Icons.hexagon_outlined,
                  label: 'Metal',
                  value: _getLuckyMetal(moonSign),
                  onTap:
                      () => _showInsightSheet(
                        context,
                        _getLuckyMetalInsight(
                          _getLuckyMetal(moonSign),
                          moonSign,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InteractiveGemstoneRow extends StatefulWidget {
  final String gemstone;
  final String moonSign;

  const _InteractiveGemstoneRow({
    required this.gemstone,
    required this.moonSign,
  });

  @override
  State<_InteractiveGemstoneRow> createState() =>
      _InteractiveGemstoneRowState();
}

class _InteractiveGemstoneRowState extends State<_InteractiveGemstoneRow>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gemstoneColor = _getGemstoneColor(widget.gemstone);
    final gemstonePath = _getGemstoneImagePath(widget.gemstone);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        _showInsightSheet(
          context,
          _getGemstoneInsight(
            widget.gemstone,
            widget.moonSign,
            _getGemstoneRulingPlanet(widget.gemstone),
          ),
        );
      },
      child: AnimatedContainer(
        duration: _DesignTokens.durationFast,
        curve: _DesignTokens.curveStandard,
        padding: const EdgeInsets.all(_DesignTokens.space16),
        decoration: BoxDecoration(
          color:
              _isPressed
                  ? gemstoneColor.withOpacity(0.06)
                  : gemstoneColor.withOpacity(0.03),
          borderRadius: BorderRadius.circular(_DesignTokens.radiusLg),
          border: Border.all(
            color: gemstoneColor.withOpacity(_isPressed ? 0.18 : 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Premium gemstone image with subtle, elegant shadow
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                final glowIntensity = 0.08 + (_shimmerController.value * 0.04);
                return Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      // Soft ambient shadow - barely visible depth
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        spreadRadius: -4,
                        offset: const Offset(0, 4),
                      ),
                      // Subtle color aura - gentle breathing glow
                      BoxShadow(
                        color: gemstoneColor.withOpacity(glowIntensity),
                        blurRadius: 20 + (_shimmerController.value * 4),
                        spreadRadius: -6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      gemstonePath,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: gemstoneColor.withOpacity(0.1),
                          child: Center(
                            child: Text(
                              _getGemstoneEmoji(widget.moonSign),
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: _DesignTokens.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Primary Gemstone',
                    style: _DesignTokens.labelXs.copyWith(
                      color: _Colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: _DesignTokens.space4),
                  Text(
                    widget.gemstone,
                    style: _DesignTokens.titleMd.copyWith(
                      color: gemstoneColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: _DesignTokens.space2),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: gemstoneColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Wear on ${_getLuckyDay(widget.moonSign)}',
                        style: _DesignTokens.labelXs.copyWith(
                          color: gemstoneColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: _DesignTokens.space4),
                  Text(
                    _getGemstoneRulingPlanet(widget.gemstone),
                    style: _DesignTokens.labelXs.copyWith(
                      color: _Colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            // Subtle sparkle accent
            Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: gemstoneColor.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _LuckyTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _LuckyTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  State<_LuckyTile> createState() => _LuckyTileState();
}

class _LuckyTileState extends State<_LuckyTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:
          widget.onTap != null
              ? (_) => setState(() => _isPressed = true)
              : null,
      onTapUp:
          widget.onTap != null
              ? (_) {
                setState(() => _isPressed = false);
                HapticFeedback.lightImpact();
                widget.onTap?.call();
              }
              : null,
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(_DesignTokens.space12),
        decoration: BoxDecoration(
          color:
              _isPressed
                  ? _Colors.gold.withOpacity(0.1)
                  : _Colors.surfaceElevated,
          borderRadius: BorderRadius.circular(_DesignTokens.radiusSm),
          border: Border.all(
            color:
                _isPressed ? _Colors.gold.withOpacity(0.2) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.icon,
                  size: 14,
                  color: _isPressed ? _Colors.gold : _Colors.textTertiary,
                ),
                const SizedBox(width: _DesignTokens.space6),
                Text(widget.label, style: _DesignTokens.labelXs),
              ],
            ),
            const SizedBox(height: _DesignTokens.space6),
            Text(
              widget.value,
              style: _DesignTokens.bodySm.copyWith(
                color: _isPressed ? _Colors.gold : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PLANETARY STATUS CARD
// ═══════════════════════════════════════════════════════════════════════════
class _PlanetaryStatusCard extends StatelessWidget {
  final KundaliData kundaliData;

  const _PlanetaryStatusCard({required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final planets = kundaliData.planetPositions;

    final retrograde = <String>[];
    final exalted = <String>[];
    final debilitated = <String>[];
    final combust = <String>[];

    const exaltationSigns = {
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

    const debilitationSigns = {
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

    const combustionOrbs = {
      'Moon': 12.0,
      'Mars': 17.0,
      'Mercury': 14.0,
      'Jupiter': 11.0,
      'Venus': 10.0,
      'Saturn': 15.0,
    };

    final sunPos = planets['Sun'];

    planets.forEach((name, planet) {
      if (exaltationSigns[name] == planet.sign) {
        exalted.add(name);
      }
      if (debilitationSigns[name] == planet.sign) {
        debilitated.add(name);
      }
      if (planet.isRetrograde && name != 'Rahu' && name != 'Ketu') {
        retrograde.add(name);
      }
      if (sunPos != null && combustionOrbs.containsKey(name)) {
        final orb = combustionOrbs[name]!;
        final distance = _getAngularDistance(
          sunPos.longitude,
          planet.longitude,
        );
        if (distance <= orb) {
          combust.add(name);
        }
      }
    });

    return _Card(
      child: Column(
        children: [
          _StatusRowItem(
            icon: Icons.arrow_upward_rounded,
            label: 'Exalted',
            planets: exalted,
            color: _Colors.emerald,
          ),
          const SizedBox(height: _DesignTokens.space8),
          _StatusRowItem(
            icon: Icons.arrow_downward_rounded,
            label: 'Debilitated',
            planets: debilitated,
            color: _Colors.coral,
          ),
          const SizedBox(height: _DesignTokens.space8),
          _StatusRowItem(
            icon: Icons.replay_rounded,
            label: 'Retrograde',
            planets: retrograde,
            color: _Colors.amber,
          ),
          const SizedBox(height: _DesignTokens.space8),
          _StatusRowItem(
            icon: Icons.local_fire_department_outlined,
            label: 'Combust',
            planets: combust,
            color: _Colors.rose,
          ),
        ],
      ),
    );
  }

  double _getAngularDistance(double long1, double long2) {
    double diff = (long1 - long2).abs();
    if (diff > 180) diff = 360 - diff;
    return diff;
  }
}

class _StatusRowItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<String> planets;
  final Color color;

  const _StatusRowItem({
    required this.icon,
    required this.label,
    required this.planets,
    required this.color,
  });

  @override
  State<_StatusRowItem> createState() => _StatusRowItemState();
}

class _StatusRowItemState extends State<_StatusRowItem> {
  bool _isPressed = false;

  void _showStatusInsight() {
    _showInsightSheet(
      context,
      _getPlanetaryStatusInsight(widget.label, widget.planets),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.planets.isEmpty;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        _showStatusInsight();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(
          horizontal: _DesignTokens.space12,
          vertical: _DesignTokens.space12,
        ),
        decoration: BoxDecoration(
          color:
              isEmpty
                  ? (_isPressed
                      ? widget.color.withOpacity(0.05)
                      : _Colors.bgSecondary)
                  : widget.color.withOpacity(_isPressed ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(_DesignTokens.radiusSm),
          border: Border.all(
            color:
                _isPressed ? widget.color.withOpacity(0.3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 16,
              color: isEmpty ? _Colors.textTertiary : widget.color,
            ),
            const SizedBox(width: _DesignTokens.space10),
            Text(
              widget.label,
              style: _DesignTokens.labelSm.copyWith(
                color: isEmpty ? _Colors.textTertiary : _Colors.textSecondary,
              ),
            ),
            const Spacer(),
            if (isEmpty)
              Text(
                'None',
                style: _DesignTokens.labelSm.copyWith(
                  color: _Colors.textTertiary,
                ),
              )
            else
              Wrap(
                spacing: _DesignTokens.space8,
                children:
                    widget.planets.map((p) {
                      final pColor = _getPlanetColor(p);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: pColor.withOpacity(
                                    _isPressed ? 0.3 : 0.2,
                                  ),
                                  blurRadius: _isPressed ? 6 : 4,
                                  spreadRadius: -1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                _getPlanetImagePath(p),
                                width: 28,
                                height: 28,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: pColor.withOpacity(0.15),
                                    child: Center(
                                      child: Text(
                                        p.substring(0, 1),
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: pColor,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getShortPlanetName(p),
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                              color: pColor,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED CARD COMPONENT
// ═══════════════════════════════════════════════════════════════════════════
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const _Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(_DesignTokens.space16),
      decoration: BoxDecoration(
        color: _Colors.surface,
        borderRadius: BorderRadius.circular(_DesignTokens.radiusLg),
        border: Border.all(color: _Colors.borderSubtle, width: 1),
        boxShadow: _DesignTokens.shadowSm,
      ),
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════
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

String _getSignElement(String sign) {
  const elements = {
    'Aries': 'Fire',
    'Taurus': 'Earth',
    'Gemini': 'Air',
    'Cancer': 'Water',
    'Leo': 'Fire',
    'Virgo': 'Earth',
    'Libra': 'Air',
    'Scorpio': 'Water',
    'Sagittarius': 'Fire',
    'Capricorn': 'Earth',
    'Aquarius': 'Air',
    'Pisces': 'Water',
  };
  return elements[sign] ?? 'Unknown';
}

String _getLagnaLord(String sign) {
  const lords = {
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
  return lords[sign] ?? 'Unknown';
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

String _getNakshatraDeity(String nakshatra) {
  const deities = {
    'Ashwini': 'Ashwini Kumaras',
    'Bharani': 'Yama',
    'Krittika': 'Agni',
    'Rohini': 'Brahma',
    'Mrigashira': 'Soma',
    'Ardra': 'Rudra',
    'Punarvasu': 'Aditi',
    'Pushya': 'Brihaspati',
    'Ashlesha': 'Nagas',
    'Magha': 'Pitris',
    'Purva Phalguni': 'Bhaga',
    'Uttara Phalguni': 'Aryaman',
    'Hasta': 'Savitar',
    'Chitra': 'Vishwakarma',
    'Swati': 'Vayu',
    'Vishakha': 'Indra-Agni',
    'Anuradha': 'Mitra',
    'Jyeshtha': 'Indra',
    'Mula': 'Nirriti',
    'Purva Ashadha': 'Apas',
    'Uttara Ashadha': 'Vishvadevas',
    'Shravana': 'Vishnu',
    'Dhanishta': 'Vasus',
    'Shatabhisha': 'Varuna',
    'Purva Bhadrapada': 'Aja Ekapada',
    'Uttara Bhadrapada': 'Ahir Budhnya',
    'Revati': 'Pushan',
  };
  return deities[nakshatra] ?? 'Unknown';
}

String _getNakshatraGana(String nakshatra) {
  const ganas = {
    'Ashwini': 'Deva',
    'Bharani': 'Manushya',
    'Krittika': 'Rakshasa',
    'Rohini': 'Manushya',
    'Mrigashira': 'Deva',
    'Ardra': 'Manushya',
    'Punarvasu': 'Deva',
    'Pushya': 'Deva',
    'Ashlesha': 'Rakshasa',
    'Magha': 'Rakshasa',
    'Purva Phalguni': 'Manushya',
    'Uttara Phalguni': 'Manushya',
    'Hasta': 'Deva',
    'Chitra': 'Rakshasa',
    'Swati': 'Deva',
    'Vishakha': 'Rakshasa',
    'Anuradha': 'Deva',
    'Jyeshtha': 'Rakshasa',
    'Mula': 'Rakshasa',
    'Purva Ashadha': 'Manushya',
    'Uttara Ashadha': 'Manushya',
    'Shravana': 'Deva',
    'Dhanishta': 'Rakshasa',
    'Shatabhisha': 'Rakshasa',
    'Purva Bhadrapada': 'Manushya',
    'Uttara Bhadrapada': 'Manushya',
    'Revati': 'Deva',
  };
  return ganas[nakshatra] ?? 'Manushya';
}

Color _getGanaColor(String gana) {
  switch (gana) {
    case 'Deva':
      return _Colors.emerald;
    case 'Manushya':
      return _Colors.sky;
    case 'Rakshasa':
      return _Colors.coral;
    default:
      return _Colors.textSecondary;
  }
}

String _getNakshatraSymbol(String nakshatra) {
  const symbols = {
    'Ashwini': '🐴',
    'Bharani': '△',
    'Krittika': '🔥',
    'Rohini': '◎',
    'Mrigashira': '🦌',
    'Ardra': '◆',
    'Punarvasu': '◇',
    'Pushya': '❀',
    'Ashlesha': '🐍',
    'Magha': '♛',
    'Purva Phalguni': '◫',
    'Uttara Phalguni': '◫',
    'Hasta': '✋',
    'Chitra': '◈',
    'Swati': '◉',
    'Vishakha': '◎',
    'Anuradha': '❋',
    'Jyeshtha': '☂',
    'Mula': '✦',
    'Purva Ashadha': '◬',
    'Uttara Ashadha': '◬',
    'Shravana': '◯',
    'Dhanishta': '♪',
    'Shatabhisha': '○',
    'Purva Bhadrapada': '⚔',
    'Uttara Bhadrapada': '◇',
    'Revati': '🐟',
  };
  return symbols[nakshatra] ?? '⭐';
}

String _getNakshatraYoni(String nakshatra) {
  const yonis = {
    'Ashwini': 'Horse',
    'Bharani': 'Elephant',
    'Krittika': 'Goat',
    'Rohini': 'Serpent',
    'Mrigashira': 'Serpent',
    'Ardra': 'Dog',
    'Punarvasu': 'Cat',
    'Pushya': 'Goat',
    'Ashlesha': 'Cat',
    'Magha': 'Rat',
    'Purva Phalguni': 'Rat',
    'Uttara Phalguni': 'Cow',
    'Hasta': 'Buffalo',
    'Chitra': 'Tiger',
    'Swati': 'Buffalo',
    'Vishakha': 'Tiger',
    'Anuradha': 'Deer',
    'Jyeshtha': 'Deer',
    'Mula': 'Dog',
    'Purva Ashadha': 'Monkey',
    'Uttara Ashadha': 'Mongoose',
    'Shravana': 'Monkey',
    'Dhanishta': 'Lion',
    'Shatabhisha': 'Horse',
    'Purva Bhadrapada': 'Lion',
    'Uttara Bhadrapada': 'Cow',
    'Revati': 'Elephant',
  };
  return yonis[nakshatra] ?? 'Unknown';
}

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

/// Get shortened planet name for compact display
String _getShortPlanetName(String planet) {
  const shortNames = {
    'Sun': 'Sun',
    'Moon': 'Moon',
    'Mars': 'Mars',
    'Mercury': 'Merc',
    'Jupiter': 'Jup',
    'Venus': 'Venus',
    'Saturn': 'Sat',
    'Rahu': 'Rahu',
    'Ketu': 'Ketu',
    'Neptune': 'Nep',
    'Uranus': 'Ura',
    'Pluto': 'Pluto',
  };
  return shortNames[planet] ?? planet;
}

String _getVarna(String moonSign) {
  const varnas = {
    'Aries': 'Kshatriya',
    'Leo': 'Kshatriya',
    'Sagittarius': 'Kshatriya',
    'Taurus': 'Vaishya',
    'Virgo': 'Vaishya',
    'Capricorn': 'Vaishya',
    'Gemini': 'Shudra',
    'Libra': 'Shudra',
    'Aquarius': 'Shudra',
    'Cancer': 'Brahmin',
    'Scorpio': 'Brahmin',
    'Pisces': 'Brahmin',
  };
  return varnas[moonSign] ?? 'Unknown';
}

String _getVashya(String moonSign) {
  // Vashya (control/dominance) classification per standard Vedic astrology
  // - Chatushpad (Quadruped): Aries, Taurus, Sagittarius, Capricorn
  // - Vanchar (Wild Animal): Leo
  // - Nara/Dwipad (Human): Gemini, Virgo, Libra, Aquarius
  // - Jalachara (Aquatic): Cancer, Pisces
  // - Keeta (Insect/Reptile): Scorpio
  const vashyas = {
    'Aries': 'Chatushpad',
    'Taurus': 'Chatushpad',
    'Leo': 'Vanchar',
    'Sagittarius': 'Chatushpad',
    'Capricorn': 'Chatushpad',
    'Gemini': 'Nara',
    'Virgo': 'Nara',
    'Libra': 'Nara',
    'Aquarius': 'Nara',
    'Cancer': 'Jalachara',
    'Pisces': 'Jalachara',
    'Scorpio': 'Keeta',
  };
  return vashyas[moonSign] ?? 'Unknown';
}

String _getNadi(String nakshatra) {
  const nadis = {
    'Ashwini': 'Aadi',
    'Bharani': 'Madhya',
    'Krittika': 'Antya',
    'Rohini': 'Aadi',
    'Mrigashira': 'Madhya',
    'Ardra': 'Antya',
    'Punarvasu': 'Aadi',
    'Pushya': 'Madhya',
    'Ashlesha': 'Antya',
    'Magha': 'Aadi',
    'Purva Phalguni': 'Madhya',
    'Uttara Phalguni': 'Antya',
    'Hasta': 'Aadi',
    'Chitra': 'Madhya',
    'Swati': 'Antya',
    'Vishakha': 'Aadi',
    'Anuradha': 'Madhya',
    'Jyeshtha': 'Antya',
    'Mula': 'Aadi',
    'Purva Ashadha': 'Madhya',
    'Uttara Ashadha': 'Antya',
    'Shravana': 'Aadi',
    'Dhanishta': 'Madhya',
    'Shatabhisha': 'Antya',
    'Purva Bhadrapada': 'Aadi',
    'Uttara Bhadrapada': 'Madhya',
    'Revati': 'Antya',
  };
  return nadis[nakshatra] ?? 'Unknown';
}

String _getTaraName(int taraNumber) {
  const taraNames = {
    1: 'Janma',
    2: 'Sampat',
    3: 'Vipat',
    4: 'Kshema',
    5: 'Pratyak',
    6: 'Sadhana',
    7: 'Naidhana',
    8: 'Mitra',
    9: 'Parama Mitra',
  };
  return taraNames[taraNumber] ?? 'Janma';
}

String _getLuckyNumbers(String moonSign) {
  const numbers = {
    'Aries': '1, 8, 9',
    'Taurus': '2, 6, 7',
    'Gemini': '3, 5, 6',
    'Cancer': '2, 4, 7',
    'Leo': '1, 4, 5',
    'Virgo': '3, 5, 6',
    'Libra': '2, 6, 7',
    'Scorpio': '3, 9, 4',
    'Sagittarius': '3, 5, 8',
    'Capricorn': '4, 8, 6',
    'Aquarius': '4, 7, 8',
    'Pisces': '3, 7, 9',
  };
  return numbers[moonSign] ?? '1, 7, 9';
}

String _getLuckyDay(String moonSign) {
  const days = {
    'Aries': 'Tuesday',
    'Taurus': 'Friday',
    'Gemini': 'Wednesday',
    'Cancer': 'Monday',
    'Leo': 'Sunday',
    'Virgo': 'Wednesday',
    'Libra': 'Friday',
    'Scorpio': 'Tuesday',
    'Sagittarius': 'Thursday',
    'Capricorn': 'Saturday',
    'Aquarius': 'Saturday',
    'Pisces': 'Thursday',
  };
  return days[moonSign] ?? 'Sunday';
}

/// Returns the color for a gemstone based on its visual appearance
Color _getGemstoneColor(String gemstone) {
  const colors = {
    // Ruby - Deep crimson red with golden undertones
    'Ruby': Color(0xFFE31B23),
    // Pearl - Iridescent silvery with soft pink/blue
    'Pearl': Color(0xFFB8C5D6),
    // Emerald - Deep forest green with vibrant sparkle
    'Emerald': Color(0xFF00875A),
    // Diamond - Brilliant white with rainbow iridescence
    'Diamond': Color(0xFFE8E4F0),
    // Yellow Sapphire - Golden amber with warm radiance
    'Yellow Sapphire': Color(0xFFF5A623),
    // Blue Sapphire - Deep royal blue with cosmic glow
    'Blue Sapphire': Color(0xFF2D4FA0),
    // Red Coral - Fiery orange-red with molten texture
    'Red Coral': Color(0xFFD94E2A),
    // Hessonite (Gomed) - Warm honey brown/amber
    'Hessonite': Color(0xFFB87333),
    // Cat's Eye (Lehsunia) - Olive green/golden chatoyant
    'Cat\'s Eye': Color(0xFF8B9556),
  };
  return colors[gemstone] ?? const Color(0xFFFFD700);
}

/// Returns the asset path for a gemstone image
String _getGemstoneImagePath(String gemstone) {
  const paths = {
    'Ruby': 'assets/images/gemstones/ruby.png',
    'Pearl': 'assets/images/gemstones/pearl.png',
    'Emerald': 'assets/images/gemstones/emerald.png',
    'Diamond': 'assets/images/gemstones/diamond.png',
    'Yellow Sapphire': 'assets/images/gemstones/yellow_sapphire.png',
    'Blue Sapphire': 'assets/images/gemstones/blue_sapphire.png',
    'Red Coral': 'assets/images/gemstones/red_coral.png',
    'Hessonite': 'assets/images/gemstones/hessonite.png',
    'Cat\'s Eye': 'assets/images/gemstones/cats_eye.png',
  };
  return paths[gemstone] ?? 'assets/images/gemstones/pearl.png';
}

/// Returns the ruling planet for a gemstone
String _getGemstoneRulingPlanet(String gemstone) {
  const planets = {
    'Ruby': 'Ruled by Sun • Strengthens vitality',
    'Pearl': 'Ruled by Moon • Enhances emotions',
    'Emerald': 'Ruled by Mercury • Boosts intellect',
    'Diamond': 'Ruled by Venus • Attracts love',
    'Yellow Sapphire': 'Ruled by Jupiter • Brings wisdom',
    'Blue Sapphire': 'Ruled by Saturn • Grants discipline',
    'Red Coral': 'Ruled by Mars • Increases courage',
    'Hessonite': 'Ruled by Rahu • Removes obstacles',
    'Cat\'s Eye': 'Ruled by Ketu • Provides protection',
  };
  return planets[gemstone] ?? 'Ruled by celestial forces';
}

String _getLuckyColors(String moonSign) {
  const colors = {
    'Aries': 'Red, Orange',
    'Taurus': 'Green, Pink',
    'Gemini': 'Yellow, Green',
    'Cancer': 'White, Silver',
    'Leo': 'Gold, Orange',
    'Virgo': 'Green, Brown',
    'Libra': 'Blue, Pink',
    'Scorpio': 'Red, Maroon',
    'Sagittarius': 'Yellow, Purple',
    'Capricorn': 'Black, Brown',
    'Aquarius': 'Blue, Electric',
    'Pisces': 'Sea Green, Lavender',
  };
  return colors[moonSign] ?? 'White';
}

String _getLuckyMetal(String moonSign) {
  const metals = {
    'Aries': 'Iron',
    'Taurus': 'Copper',
    'Gemini': 'Brass',
    'Cancer': 'Silver',
    'Leo': 'Gold',
    'Virgo': 'Bronze',
    'Libra': 'Copper',
    'Scorpio': 'Iron',
    'Sagittarius': 'Tin',
    'Capricorn': 'Lead',
    'Aquarius': 'Lead',
    'Pisces': 'Tin',
  };
  return metals[moonSign] ?? 'Gold';
}

String _getLuckyGemstone(String moonSign) {
  const gems = {
    'Aries': 'Red Coral',
    'Taurus': 'Diamond',
    'Gemini': 'Emerald',
    'Cancer': 'Pearl',
    'Leo': 'Ruby',
    'Virgo': 'Emerald',
    'Libra': 'Diamond',
    'Scorpio': 'Red Coral',
    'Sagittarius': 'Yellow Sapphire',
    'Capricorn': 'Blue Sapphire',
    'Aquarius': 'Blue Sapphire',
    'Pisces': 'Yellow Sapphire',
  };
  return gems[moonSign] ?? 'Pearl';
}

String _getGemstoneEmoji(String moonSign) {
  const gems = {
    'Aries': '🔴',
    'Taurus': '💎',
    'Gemini': '💚',
    'Cancer': '🤍',
    'Leo': '❤️',
    'Virgo': '💚',
    'Libra': '💎',
    'Scorpio': '🔴',
    'Sagittarius': '💛',
    'Capricorn': '💙',
    'Aquarius': '💙',
    'Pisces': '💛',
  };
  return gems[moonSign] ?? '💎';
}

/// Get zodiac sign color based on the visual palette from images
Color _getZodiacColor(String sign) {
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
String _getZodiacImagePath(String sign) {
  return 'assets/images/zodiac/${sign.toLowerCase()}.png';
}

/// Get planet image path
String _getPlanetImagePath(String planet) {
  return 'assets/images/planets/${planet.toLowerCase()}.png';
}

/// Get element image path
String _getElementImagePath(String element) {
  return 'assets/images/elements/${element.toLowerCase()}.png';
}

/// Get element symbol fallback
String _getElementSymbol(String element) {
  const symbols = {'Fire': '🔥', 'Water': '💧', 'Earth': '🌍', 'Air': '💨'};
  return symbols[element] ?? '✦';
}

/// Get element color based on actual image visual palette
Color _getElementColorFromImage(String element) {
  const colors = {
    // Fire - Warm orange/golden flames with white-hot center
    'Fire': Color(0xFFFF8C42),
    // Water - Deep blue ocean sphere with turquoise waves
    'Water': Color(0xFF2D9CDB),
    // Earth - Vibrant globe with blue oceans and green/yellow land
    'Earth': Color(0xFF4ADE80),
    // Air - Soft lavender/white ethereal swirl
    'Air': Color(0xFFB794F6),
  };
  return colors[element] ?? const Color(0xFFA09CAC);
}
