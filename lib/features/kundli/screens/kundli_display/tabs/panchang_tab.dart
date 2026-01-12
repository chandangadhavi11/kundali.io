import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import 'package:kundali_app/l10n/generated/app_localizations.dart';
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
                      AppLocalizations.of(context).panchang_whatThisMeans,
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
                                  AppLocalizations.of(context).panchang_significance,
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
                        AppLocalizations.of(context).panchang_keyPoints,
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
InsightData _getTithiInsight(PanchangData panchang, String tithiLord, AppLocalizations l10n) {
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
  
  final pakshaType = panchang.paksha == "Shukla" ? l10n.panchang_waxing : l10n.panchang_waning;

  return InsightData(
    title: l10n.panchang_tithi_title,
    value: panchang.tithi,
    description: '${l10n.panchang_tithi_desc} ${tithiDescriptions[panchang.tithiNumber] ?? ""}',
    significance: l10n.panchang_tithi_significance(panchang.tithi, panchang.tithiNumber, panchang.paksha, tithiLord),
    keyPoints: [
      l10n.panchang_tithi_point1(panchang.tithiNumber),
      l10n.panchang_tithi_point2(panchang.paksha, pakshaType),
      l10n.panchang_tithi_point3(tithiLord),
      l10n.panchang_tithi_point4,
      l10n.panchang_tithi_point5,
    ],
    accentColor: _Colors.emerald,
    icon: Icons.brightness_2_rounded,
  );
}

InsightData _getNakshatraInsight(PanchangData panchang, AppLocalizations l10n) {
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
    title: l10n.panchang_nakshatra_title,
    value: l10n.panchang_nakshatra_value(panchang.nakshatra, panchang.nakshatraPada),
    description: l10n.panchang_nakshatra_desc,
    significance: l10n.panchang_nakshatra_significance(panchang.nakshatra, panchang.nakshatraPada, lord),
    keyPoints: [
      l10n.panchang_nakshatra_point1(panchang.nakshatra),
      l10n.panchang_nakshatra_point2(panchang.nakshatraPada),
      l10n.panchang_nakshatra_point3(lord),
      l10n.panchang_nakshatra_point4,
      l10n.panchang_nakshatra_point5,
    ],
    accentColor: _Colors.amber,
    icon: Icons.star_rounded,
  );
}

InsightData _getYogaInsight(PanchangData panchang, String yogaType, AppLocalizations l10n) {
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

  final yogaColor = yogaType == l10n.panchang_yoga_auspicious ? _Colors.emerald : 
                    yogaType == l10n.panchang_yoga_inauspicious ? _Colors.coral : _Colors.sky;

  return InsightData(
    title: l10n.panchang_yoga_title,
    value: l10n.panchang_yoga_value(panchang.yoga, panchang.yogaNumber),
    description: '${l10n.panchang_yoga_desc} ${yogaDescriptions[panchang.yoga] ?? ""}',
    significance: l10n.panchang_yoga_significance(panchang.yoga, yogaType),
    keyPoints: [
      l10n.panchang_yoga_point1(panchang.yoga),
      l10n.panchang_yoga_point2(panchang.yogaNumber),
      l10n.panchang_yoga_point3(yogaType),
      l10n.panchang_yoga_point4,
      l10n.panchang_yoga_point5,
    ],
    accentColor: yogaColor,
    icon: Icons.link_rounded,
  );
}

InsightData _getKaranaInsight(PanchangData panchang, String karanaType, AppLocalizations l10n) {
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

  final isBhadra = karanaType == l10n.panchang_karana_bhadra;
  final karanaColor = isBhadra ? _Colors.coral : _Colors.violet;

  return InsightData(
    title: l10n.panchang_karana_title,
    value: panchang.karana,
    description: '${l10n.panchang_karana_desc} ${karanaDescriptions[panchang.karana] ?? ""}',
    significance: l10n.panchang_karana_significance(panchang.karana, karanaType),
    keyPoints: [
      l10n.panchang_karana_point1(panchang.karana),
      l10n.panchang_karana_point2(karanaType),
      l10n.panchang_karana_point3,
      l10n.panchang_karana_point4,
      l10n.panchang_karana_point5,
    ],
    accentColor: karanaColor,
    icon: Icons.hourglass_bottom_rounded,
  );
}

InsightData _getVaraInsight(PanchangData panchang, AppLocalizations l10n) {
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
  final lord = info['lord'] as String;

  return InsightData(
    title: l10n.panchang_vara_title,
    value: panchang.vara,
    description: '${l10n.panchang_vara_desc} ${info['nature']}',
    significance: l10n.panchang_vara_significance(panchang.vara, lord),
    keyPoints: [
      l10n.panchang_vara_point1(panchang.vara),
      l10n.panchang_vara_point2(lord),
      l10n.panchang_vara_point3(panchang.varaDeity),
      l10n.panchang_vara_point4,
      l10n.panchang_vara_point5,
    ],
    accentColor: info['color'] as Color,
    icon: Icons.calendar_today_rounded,
  );
}

InsightData _getMoonPhaseInsight(PanchangData panchang, double illumination, AppLocalizations l10n) {
  final phaseType = panchang.paksha == 'Shukla' ? l10n.panchang_waxing : l10n.panchang_waning;
  String phase;
  if (panchang.tithiNumber == 15) {
    phase = panchang.paksha == 'Shukla' ? l10n.panchang_phase_fullMoon : l10n.panchang_phase_newMoon;
  } else if (panchang.tithiNumber <= 3) {
    phase = panchang.paksha == 'Shukla' ? l10n.panchang_phase_waxingCrescent : l10n.panchang_phase_waningGibbous;
  } else if (panchang.tithiNumber <= 7) {
    phase = panchang.paksha == 'Shukla' ? l10n.panchang_phase_firstQuarter : l10n.panchang_phase_thirdQuarter;
  } else if (panchang.tithiNumber <= 11) {
    phase = panchang.paksha == 'Shukla' ? l10n.panchang_phase_waxingGibbous : l10n.panchang_phase_waningCrescent;
  } else {
    phase = panchang.paksha == 'Shukla' ? l10n.panchang_phase_nearlyFull : l10n.panchang_phase_nearlyNew;
  }

  final nature = panchang.paksha == "Shukla" 
      ? l10n.panchang_moonPhase_nature_shukla 
      : l10n.panchang_moonPhase_nature_krishna;

  return InsightData(
    title: l10n.panchang_moonPhase_title,
    value: phase,
    description: l10n.panchang_moonPhase_desc,
    significance: l10n.panchang_moonPhase_significance(panchang.paksha, illumination.toStringAsFixed(0), nature),
    keyPoints: [
      l10n.panchang_moonPhase_point1(phase),
      l10n.panchang_moonPhase_point2(panchang.paksha, phaseType),
      l10n.panchang_moonPhase_point3(illumination.toStringAsFixed(1)),
      l10n.panchang_moonPhase_point4(panchang.tithi, panchang.tithiNumber),
      l10n.panchang_moonPhase_point5,
    ],
    accentColor: _Colors.indigo,
    icon: Icons.nightlight_round,
  );
}

InsightData _getHoraInsight(String hora, DateTime birthTime, AppLocalizations l10n) {
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
    title: l10n.panchang_hora_title,
    value: l10n.panchang_hora_value(hora),
    description: '${l10n.panchang_hora_desc} ${info['nature']}',
    significance: l10n.panchang_hora_significance(hora),
    keyPoints: [
      l10n.panchang_hora_point1(hora),
      l10n.panchang_hora_point2(DateFormat('HH:mm').format(birthTime)),
      l10n.panchang_hora_point3,
      l10n.panchang_hora_point4,
      l10n.panchang_hora_point5,
    ],
    accentColor: info['color'] as Color,
    icon: Icons.access_time_rounded,
  );
}

InsightData _getInauspiciousPeriodInsight(TimePeriod period, Color color, AppLocalizations l10n) {
  String description;
  String point4;
  
  if (period.name == 'Rahu Kala') {
    description = l10n.panchang_inauspicious_rahuKala_desc;
    point4 = l10n.panchang_inauspicious_point4_rahu;
  } else if (period.name == 'Yamaghanda') {
    description = l10n.panchang_inauspicious_yamaghanda_desc;
    point4 = l10n.panchang_inauspicious_point4_yama;
  } else {
    description = l10n.panchang_inauspicious_gulika_desc;
    point4 = l10n.panchang_inauspicious_point4_gulika;
  }

  return InsightData(
    title: l10n.panchang_inauspicious_title,
    value: period.name,
    description: description,
    significance: l10n.panchang_inauspicious_significance(period.name, period.formattedTime),
    keyPoints: [
      l10n.panchang_inauspicious_point1(period.name),
      l10n.panchang_inauspicious_point2(period.formattedTime),
      l10n.panchang_inauspicious_point3,
      point4,
      l10n.panchang_inauspicious_point5,
    ],
    accentColor: color,
    icon: period.name == 'Rahu Kala' ? Icons.do_not_disturb_on_rounded :
          period.name == 'Yamaghanda' ? Icons.warning_rounded :
          Icons.brightness_3_rounded,
  );
}

InsightData _getVarshphalInsight(VarshphalData varshphal, AppLocalizations l10n) {
  return InsightData(
    title: l10n.panchang_varshphal_title,
    value: l10n.panchang_varshphal_value(varshphal.year),
    description: l10n.panchang_varshphal_desc,
    significance: l10n.panchang_varshphal_significance(varshphal.age, varshphal.munthaSign, varshphal.yearLord),
    keyPoints: [
      l10n.panchang_varshphal_point1(varshphal.year),
      l10n.panchang_varshphal_point2(varshphal.age),
      l10n.panchang_varshphal_point3(DateFormat('d MMM yyyy').format(varshphal.solarReturnDate)),
      l10n.panchang_varshphal_point4(varshphal.munthaSign),
      l10n.panchang_varshphal_point5(varshphal.yearLord),
    ],
    accentColor: _Colors.amber,
    icon: Icons.wb_sunny_rounded,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// NAVIGATION SECTION DATA
// ═══════════════════════════════════════════════════════════════════════════
List<NavSection> _getSections(AppLocalizations l10n) => [
  NavSection(id: 'moon', label: l10n.panchang_nav_moon, color: _Colors.indigo),
  NavSection(id: 'elements', label: l10n.panchang_nav_elements, color: _Colors.emerald),
  NavSection(id: 'hora', label: l10n.panchang_nav_hora, color: _Colors.sky),
  NavSection(id: 'periods', label: l10n.panchang_nav_periods, color: _Colors.coral),
  NavSection(id: 'varshphal', label: l10n.panchang_nav_varshphal, color: _Colors.amber),
];

const _sectionIds = ['moon', 'elements', 'hora', 'periods', 'varshphal'];

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

    for (final sectionId in _sectionIds) {
      _sectionKeys[sectionId] = GlobalKey();
      _animatedKeys[sectionId] = GlobalKey<_AnimatedSectionWrapperState>();
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

    for (int i = 0; i < _sectionIds.length; i++) {
      final key = _sectionKeys[_sectionIds[i]];
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
    final sectionId = _sectionIds[index];
    final key = _sectionKeys[sectionId];

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

    _animatedKeys[sectionId]?.currentState?.triggerHighlight();

    setState(() => _isScrolling = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sections = _getSections(l10n);
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
    final yogaType = _getYogaType(panchang.yogaNumber, l10n);
    final karanaType = _getKaranaType(panchang.karana, l10n);

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
                    l10n: l10n,
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
                      title: l10n.panchang_fiveLimbs,
                      subtitle: l10n.panchang_elementsAtBirth,
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
                        l10n: l10n,
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
                      title: l10n.panchang_horaWeekday,
                      subtitle: l10n.panchang_horaSubtitle,
                      accentColor: _Colors.sky,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: Row(
                        children: [
                          Expanded(
                            child: _HoraCard(
                              hora: hora,
                              birthTime: widget.kundaliData.birthDateTime,
                              l10n: l10n,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _WeekdayCard(panchang: panchang, l10n: l10n),
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
                      title: l10n.panchang_inauspiciousPeriods,
                      subtitle: l10n.panchang_onDay(DateFormat('EEEE').format(widget.kundaliData.birthDateTime)),
                      accentColor: _Colors.coral,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: _InauspiciousPeriodsCard(
                        periods: inauspiciousPeriods,
                        birthDateTime: widget.kundaliData.birthDateTime,
                        l10n: l10n,
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
                      title: l10n.panchang_varshphalYear(varshphal.year),
                      subtitle: l10n.panchang_solarReturnSubtitle,
                      accentColor: _Colors.amber,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: _VarshphalCard(varshphal: varshphal, l10n: l10n),
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
            sections: sections,
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

  String _getYogaType(int yogaNumber, AppLocalizations l10n) {
    // Inauspicious Yogas per traditional Vedic astrology:
    // 1-Vishkumbha, 6-Atiganda, 9-Shula, 10-Ganda, 13-Vyaghata,
    // 15-Vajra, 17-Vyatipata, 19-Parigha, 27-Vaidhriti
    const inauspiciousYogas = [1, 6, 9, 10, 13, 15, 17, 19, 27];

    // Auspicious Yogas per traditional Vedic astrology:
    // 2-Priti, 3-Ayushman, 4-Saubhagya, 5-Shobhana, 7-Sukarma, 8-Dhriti,
    // 11-Vriddhi, 12-Dhruva, 14-Harshana, 16-Siddhi, 18-Variyan, 20-Shiva,
    // 21-Siddha, 22-Sadhya, 23-Shubha, 24-Shukla, 25-Brahma, 26-Indra
    const auspiciousYogas = [2, 3, 4, 5, 7, 8, 11, 12, 14, 16, 18, 20, 21, 22, 23, 24, 25, 26];

    if (inauspiciousYogas.contains(yogaNumber)) return l10n.panchang_yoga_inauspicious;
    if (auspiciousYogas.contains(yogaNumber)) return l10n.panchang_yoga_auspicious;
    return l10n.panchang_yoga_neutral;
  }

  String _getKaranaType(String karana, AppLocalizations l10n) {
    const movableKaranas = ['Bava', 'Balava', 'Kaulava', 'Taitila', 'Gara', 'Vanija', 'Vishti'];
    const fixedKaranas = ['Shakuni', 'Chatushpada', 'Naga', 'Kimstughna'];

    if (movableKaranas.contains(karana)) {
      if (karana == 'Vishti') return l10n.panchang_karana_bhadra;
      return l10n.panchang_karana_chara;
    }
    if (fixedKaranas.contains(karana)) return l10n.panchang_karana_sthira;
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
  final AppLocalizations l10n;

  const _MoonPhaseHeroCard({
    required this.panchang,
    required this.moonPos,
    required this.sunPos,
    required this.birthDateTime,
    required this.l10n,
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
      _getMoonPhaseInsight(widget.panchang, illumination, widget.l10n),
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
    final l10n = widget.l10n;
    final moonLong = widget.moonPos?.longitude ?? 0;
    final sunLong = widget.sunPos?.longitude ?? 0;
    double elongation = moonLong - sunLong;
    if (elongation < 0) elongation += 360;

    final phaseDescription = _getPhaseDescription(
      widget.panchang.tithiNumber,
      widget.panchang.paksha,
      l10n,
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
                              l10n.panchang_percentLit(illumination.toStringAsFixed(0)),
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
                                l10n.panchang_paksha(widget.panchang.paksha.toUpperCase()),
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
                        label: l10n.panchang_moonSign,
                        value: _getLocalizedZodiacSign(widget.moonPos?.sign ?? '?', l10n),
                        color: _Colors.emerald,
                      ),
                      const SizedBox(width: 8),
                      _CompactMoonStat(
                        icon: Icons.straighten_rounded,
                        label: l10n.panchang_degree,
                        value:
                            '${(widget.moonPos?.signDegree ?? 0).toStringAsFixed(1)}°',
                        color: _Colors.sky,
                      ),
                      const SizedBox(width: 8),
                      _CompactMoonStat(
                        icon: Icons.compare_arrows_rounded,
                        label: l10n.panchang_elongation,
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

String _getPhaseDescription(int tithi, String paksha, AppLocalizations l10n) {
  if (paksha == 'Shukla') {
    if (tithi <= 3) return l10n.panchang_phase_waxingCrescent;
    if (tithi <= 7) return l10n.panchang_phase_firstQuarter;
    if (tithi <= 11) return l10n.panchang_phase_waxingGibbous;
    if (tithi <= 14) return l10n.panchang_phase_nearlyFull;
    return l10n.panchang_phase_fullMoon;
  } else {
    if (tithi <= 3) return l10n.panchang_phase_waningGibbous;
    if (tithi <= 7) return l10n.panchang_phase_thirdQuarter;
    if (tithi <= 11) return l10n.panchang_phase_waningCrescent;
    if (tithi <= 14) return l10n.panchang_phase_nearlyNew;
    return l10n.panchang_phase_newMoon;
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
  final AppLocalizations l10n;

  const _PanchangElementsGrid({
    required this.panchang,
    required this.tithiLord,
    required this.yogaType,
    required this.karanaType,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final yogaColor = _getYogaTypeColor(yogaType, l10n);
    final isBhadra = karanaType == l10n.panchang_karana_bhadra;
    final karanaColor = isBhadra ? _Colors.coral : _Colors.violet;

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
                  label: l10n.panchang_tithi,
                  value: panchang.tithi,
                  detail: _getLocalizedPlanetName(tithiLord, l10n),
                  detailPrefix: l10n.panchang_lord,
                  position: _TilePosition.topLeft,
                  insight: _getTithiInsight(panchang, tithiLord, l10n),
                ),
              ),
              Expanded(
                child: _ElegantPanchangTile(
                  symbol: '✦',
                  label: l10n.panchang_nakshatra,
                  value: panchang.nakshatra,
                  detail: l10n.panchang_pada(panchang.nakshatraPada),
                  position: _TilePosition.topRight,
                  insight: _getNakshatraInsight(panchang, l10n),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _ElegantPanchangTile(
                  symbol: '☯',
                  label: l10n.panchang_yoga,
                  value: panchang.yoga,
                  detail: yogaType,
                  badge: '${panchang.yogaNumber}/27',
                  badgeColor: yogaColor,
                  position: _TilePosition.bottomLeft,
                  insight: _getYogaInsight(panchang, yogaType, l10n),
                ),
              ),
              Expanded(
                child: _ElegantPanchangTile(
                  symbol: '⧗',
                  label: l10n.panchang_karana,
                  value: panchang.karana,
                  detail: karanaType,
                  badgeColor: karanaColor,
                  showWarning: isBhadra,
                  position: _TilePosition.bottomRight,
                  insight: _getKaranaInsight(panchang, karanaType, l10n),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getYogaTypeColor(String type, AppLocalizations l10n) {
    if (type == l10n.panchang_yoga_auspicious) {
      return _Colors.emerald;
    } else if (type == l10n.panchang_yoga_inauspicious) {
      return _Colors.coral;
    }
    return _Colors.sky;
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
  final AppLocalizations l10n;

  const _HoraCard({required this.hora, required this.birthTime, required this.l10n});

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
      _getHoraInsight(widget.hora, widget.birthTime, widget.l10n),
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

  String _getHoraDescription(String planet, AppLocalizations l10n) {
    final descriptions = {
      'Sun': l10n.panchang_hora_desc_sun,
      'Moon': l10n.panchang_hora_desc_moon,
      'Mars': l10n.panchang_hora_desc_mars,
      'Mercury': l10n.panchang_hora_desc_mercury,
      'Jupiter': l10n.panchang_hora_desc_jupiter,
      'Venus': l10n.panchang_hora_desc_venus,
      'Saturn': l10n.panchang_hora_desc_saturn,
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
                        widget.l10n.panchang_birthHora,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: _Colors.textTertiary,
                        ),
                      ),
                      Text(
                        widget.l10n.panchang_hora_value(_getLocalizedPlanetName(widget.hora, widget.l10n)),
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
              _getHoraDescription(widget.hora, widget.l10n),
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
  final AppLocalizations l10n;

  const _WeekdayCard({required this.panchang, required this.l10n});

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
    _showInsightSheet(context, _getVaraInsight(widget.panchang, widget.l10n));
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
                        widget.l10n.panchang_varaWeekday,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: _Colors.textTertiary,
                        ),
                      ),
                      Text(
                        _getLocalizedWeekday(widget.panchang.vara, widget.l10n),
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
                  '${widget.l10n.panchang_lord}: ',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: _Colors.textTertiary,
                  ),
                ),
                Text(
                  _getLocalizedPlanetName(varaLord, widget.l10n),
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
  final AppLocalizations l10n;

  const _InauspiciousPeriodsCard({
    required this.periods,
    required this.birthDateTime,
    required this.l10n,
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
            _BirthWarningBanner(period: currentPeriod, l10n: l10n),
            const SizedBox(height: 14),
          ],

          _InauspiciousPeriodRow(
            period: periods.rahukala,
            color: _Colors.coral,
            icon: Icons.do_not_disturb_on_rounded,
            l10n: l10n,
          ),
          const SizedBox(height: 8),
          _InauspiciousPeriodRow(
            period: periods.yamaghanda,
            color: _Colors.amber,
            icon: Icons.warning_rounded,
            l10n: l10n,
          ),
          const SizedBox(height: 8),
          _InauspiciousPeriodRow(
            period: periods.gulika,
            color: _Colors.violet,
            icon: Icons.brightness_3_rounded,
            l10n: l10n,
          ),

          const SizedBox(height: 14),

          _InauspiciousTimeline(
            periods: periods,
            birthDateTime: birthDateTime,
            l10n: l10n,
          ),
        ],
      ),
    );
  }
}

class _BirthWarningBanner extends StatelessWidget {
  final TimePeriod period;
  final AppLocalizations l10n;

  const _BirthWarningBanner({required this.period, required this.l10n});

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
                  l10n.panchang_birthDuring(_getLocalizedPeriodName(period.name, l10n)),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _Colors.coral,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getLocalizedPeriodDescription(period.name, l10n),
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
  final AppLocalizations l10n;

  const _InauspiciousPeriodRow({
    required this.period,
    required this.color,
    required this.icon,
    required this.l10n,
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
      _getInauspiciousPeriodInsight(widget.period, widget.color, widget.l10n),
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
                    _getLocalizedPeriodName(widget.period.name, widget.l10n),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _Colors.textPrimary,
                    ),
                  ),
                  Text(
                    _getLocalizedPeriodDescription(widget.period.name, widget.l10n),
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
  final AppLocalizations l10n;

  const _InauspiciousTimeline({
    required this.periods,
    required this.birthDateTime,
    required this.l10n,
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
              l10n.panchang_dayTimeline,
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
              l10n.panchang_birth,
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
            Text(l10n.panchang_time_6am, style: GoogleFonts.jetBrainsMono(fontSize: 8, color: _Colors.textTertiary)),
            Text(l10n.panchang_time_9am, style: GoogleFonts.jetBrainsMono(fontSize: 8, color: _Colors.textTertiary)),
            Text(l10n.panchang_time_12pm, style: GoogleFonts.jetBrainsMono(fontSize: 8, color: _Colors.textTertiary)),
            Text(l10n.panchang_time_3pm, style: GoogleFonts.jetBrainsMono(fontSize: 8, color: _Colors.textTertiary)),
            Text(l10n.panchang_time_6pm, style: GoogleFonts.jetBrainsMono(fontSize: 8, color: _Colors.textTertiary)),
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
  final AppLocalizations l10n;

  const _VarshphalCard({required this.varshphal, required this.l10n});

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
    _showInsightSheet(context, _getVarshphalInsight(widget.varshphal, widget.l10n));
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
                        widget.l10n.panchang_years,
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
                        widget.l10n.panchang_varshphal_value(widget.varshphal.year),
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
                    label: widget.l10n.panchang_muntha,
                    value: _getLocalizedZodiacSign(widget.varshphal.munthaSign, widget.l10n),
                    symbolColor: _Colors.violet,
                  ),
                ),
                const SizedBox(width: 12),
                // Year Lord
                Expanded(
                  child: _MinimalInfoTile(
                    symbol: _getYearLordSymbol(widget.varshphal.yearLord),
                    label: widget.l10n.panchang_yearLord,
                    value: _getLocalizedPlanetName(widget.varshphal.yearLord, widget.l10n),
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

// ═══════════════════════════════════════════════════════════════════════════
// LOCALIZATION HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════
String _getLocalizedZodiacSign(String sign, AppLocalizations l10n) {
  switch (sign) {
    case 'Aries': return l10n.zodiac_aries;
    case 'Taurus': return l10n.zodiac_taurus;
    case 'Gemini': return l10n.zodiac_gemini;
    case 'Cancer': return l10n.zodiac_cancer;
    case 'Leo': return l10n.zodiac_leo;
    case 'Virgo': return l10n.zodiac_virgo;
    case 'Libra': return l10n.zodiac_libra;
    case 'Scorpio': return l10n.zodiac_scorpio;
    case 'Sagittarius': return l10n.zodiac_sagittarius;
    case 'Capricorn': return l10n.zodiac_capricorn;
    case 'Aquarius': return l10n.zodiac_aquarius;
    case 'Pisces': return l10n.zodiac_pisces;
    default: return sign;
  }
}

String _getLocalizedPlanetName(String planet, AppLocalizations l10n) {
  switch (planet) {
    case 'Sun': return l10n.planet_sun;
    case 'Moon': return l10n.planet_moon;
    case 'Mars': return l10n.planet_mars;
    case 'Mercury': return l10n.planet_mercury;
    case 'Jupiter': return l10n.planet_jupiter;
    case 'Venus': return l10n.planet_venus;
    case 'Saturn': return l10n.planet_saturn;
    case 'Rahu': return l10n.planet_rahu;
    case 'Ketu': return l10n.planet_ketu;
    default: return planet;
  }
}

String _getLocalizedWeekday(String weekday, AppLocalizations l10n) {
  switch (weekday) {
    case 'Sunday': return l10n.weekday_sunday;
    case 'Monday': return l10n.weekday_monday;
    case 'Tuesday': return l10n.weekday_tuesday;
    case 'Wednesday': return l10n.weekday_wednesday;
    case 'Thursday': return l10n.weekday_thursday;
    case 'Friday': return l10n.weekday_friday;
    case 'Saturday': return l10n.weekday_saturday;
    default: return weekday;
  }
}

String _getLocalizedPeriodName(String periodName, AppLocalizations l10n) {
  switch (periodName) {
    case 'Rahukala': return l10n.panchang_period_rahukala;
    case 'Rahu Kala': return l10n.panchang_period_rahukala;
    case 'Yamaghanda': return l10n.panchang_period_yamaghanda;
    case 'Gulika': return l10n.panchang_period_gulika;
    default: return periodName;
  }
}

String _getLocalizedPeriodDescription(String periodName, AppLocalizations l10n) {
  switch (periodName) {
    case 'Rahukala': return l10n.panchang_period_rahukala_short;
    case 'Rahu Kala': return l10n.panchang_period_rahukala_short;
    case 'Yamaghanda': return l10n.panchang_period_yamaghanda_short;
    case 'Gulika': return l10n.panchang_period_gulika_short;
    default: return '';
  }
}
