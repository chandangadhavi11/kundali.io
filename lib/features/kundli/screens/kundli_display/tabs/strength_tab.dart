import 'dart:math' as math;
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
// DESIGN SYSTEM TOKENS
// ═══════════════════════════════════════════════════════════════════════════
class _DesignTokens {
  _DesignTokens._();

  // Spacing scale
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;

  // Border radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
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
  static const Color rose = Color(0xFFF472B6);
  static const Color sky = Color(0xFF38BDF8);
  static const Color amber = Color(0xFFFBBF24);
  static const Color coral = Color(0xFFF87171);
  static const Color teal = Color(0xFF2DD4BF);
  static const Color indigo = Color(0xFF6366F1);
  static const Color gold = Color(0xFFCFAE54);
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
                                    (1.0 - (index * 0.08)).clamp(0.3, 1.0),
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
InsightData _getChartStrengthInsight(
  double avgStrength,
  int strongCount,
  int weakCount,
  int totalPlanets,
) {
  final strengthLevel =
      avgStrength >= 100
          ? 'Excellent'
          : avgStrength >= 75
          ? 'Good'
          : avgStrength >= 50
          ? 'Average'
          : 'Needs Support';

  final strengthColor =
      avgStrength >= 100
          ? _Colors.emerald
          : avgStrength >= 75
          ? _Colors.sky
          : avgStrength >= 50
          ? _Colors.amber
          : _Colors.coral;

  return InsightData(
    title: 'Chart Strength',
    value: '$strengthLevel (${avgStrength.toStringAsFixed(0)}%)',
    description:
        'Your overall chart strength is measured by averaging the Shadbala (six-fold strength) of all planets. This indicates how well the planets are positioned to deliver their results in your life.',
    significance:
        'With $strongCount strong planets and $weakCount weak planets out of $totalPlanets, your chart shows ${avgStrength >= 75 ? "good overall planetary strength" : "areas that may benefit from remedial measures"}.',
    keyPoints: [
      'Average Strength: ${avgStrength.toStringAsFixed(1)}%',
      'Strong Planets: $strongCount (≥100% of required)',
      'Weak Planets: $weakCount (<100% of required)',
      'Strength Level: $strengthLevel',
      avgStrength >= 100
          ? 'Excellent! Most planets can deliver strong results'
          : avgStrength >= 75
          ? 'Good strength with minor areas to improve'
          : 'Consider remedies for weak planets',
    ],
    accentColor: strengthColor,
    icon: Icons.insights_rounded,
  );
}

InsightData _getShadbalaInsight(ShadbalaData data, int rank, int total) {
  final planetColor = _getPlanetColor(data.planet);
  final isStrong = data.isStrong;

  return InsightData(
    title: 'Shadbala',
    value: '${data.planet} - ${data.percentageOfRequired.toStringAsFixed(0)}%',
    description:
        'Shadbala (षड्बल) means "six-fold strength" - the comprehensive Vedic system to calculate planetary power. A planet needs 100% of its required strength to give good results.',
    significance:
        '${data.planet} ranks #$rank out of $total planets with ${data.totalBala.toStringAsFixed(1)} Rupas (${data.percentageOfRequired.toStringAsFixed(0)}% of the ${data.requiredBala.toStringAsFixed(0)} required). ${isStrong ? "This planet is strong and well-positioned to deliver positive results." : "This planet may need strengthening through remedies."}',
    keyPoints: [
      'Total Shadbala: ${data.totalBala.toStringAsFixed(1)} Rupas',
      'Required: ${data.requiredBala.toStringAsFixed(0)} Rupas',
      'Percentage: ${data.percentageOfRequired.toStringAsFixed(1)}%',
      'Rank: #$rank of $total planets',
      'Status: ${isStrong ? "Strong ✓" : "Needs Support ⚠"}',
      'Sthana Bala: ${data.sthanaBala.toStringAsFixed(1)} (Position)',
      'Dig Bala: ${data.digBala.toStringAsFixed(1)} (Direction)',
      'Kala Bala: ${data.kalaBala.toStringAsFixed(1)} (Time)',
      'Chesta Bala: ${data.chestaBala.toStringAsFixed(1)} (Motion)',
      'Naisargika Bala: ${data.naisargikaBala.toStringAsFixed(1)} (Natural)',
      'Drik Bala: ${data.drikBala.toStringAsFixed(1)} (Aspect)',
    ],
    accentColor: planetColor,
    icon: Icons.stacked_bar_chart_rounded,
  );
}

InsightData _getVimshopakaBalaInsight(VimshopakaBalaData data) {
  final planetColor = _getPlanetColor(data.planet);
  final score = data.totalPoints;
  final maxScore = data.maxPoints;

  return InsightData(
    title: 'Vimshopaka Bala',
    value: '${data.planet} - ${data.percentage.toStringAsFixed(0)}%',
    description:
        'Vimshopaka Bala (20-point strength) evaluates planetary strength across 16 divisional charts (Shodasavarga). Each planet is scored out of ${maxScore.toStringAsFixed(0)} points based on its dignity (exalted, own sign, friendly, etc.) in each divisional chart.',
    significance:
        '${data.planet} scores ${score.toStringAsFixed(1)}/${maxScore.toStringAsFixed(0)} (${data.percentage.toStringAsFixed(0)}%), classified as "${data.strength}". ${data.strength == "Strong"
            ? "This planet has excellent dignity across divisional charts."
            : data.strength == "Medium"
            ? "This planet has moderate dignity."
            : "This planet may need strengthening."}',
    keyPoints: [
      'Vimshopaka Score: ${score.toStringAsFixed(2)}/${maxScore.toStringAsFixed(0)}',
      'Percentage: ${data.percentage.toStringAsFixed(1)}%',
      'Strength Category: ${data.strength}',
      'Strong: 75-100%',
      'Medium: 50-75%',
      'Weak: 0-50%',
      'Based on dignity in 16 divisional charts',
    ],
    accentColor: planetColor,
    icon: Icons.grid_view_rounded,
  );
}

InsightData _getAshtakavargaInsight(String sign, int points, String type) {
  final isStrong = points >= (type == 'SAV' ? 28 : 4);
  final color =
      isStrong
          ? _Colors.emerald
          : points >= (type == 'SAV' ? 25 : 3)
          ? _Colors.amber
          : _Colors.coral;

  return InsightData(
    title: type == 'SAV' ? 'Sarvashtakavarga' : 'Ashtakavarga',
    value: '$sign - $points points',
    description:
        type == 'SAV'
            ? 'Sarvashtakavarga (SAV) is the combined Ashtakavarga points of all 7 planets for each sign. It shows the overall strength of each sign for transits and results. Maximum possible is 56 points (8 points × 7 planets).'
            : 'Ashtakavarga shows benefic points (0-8) each planet contributes to each sign. Points ≥4 are auspicious. This helps predict transit effects - planets transiting signs with higher points give better results.',
    significance:
        type == 'SAV'
            ? '$sign has $points SAV points. ${points >= 28 ? "This sign is strong and transits through it generally give positive results." : "Transits through this sign may need more attention."}'
            : '$sign has $points bindus. ${points >= 4 ? "Transits of this planet through $sign are generally favorable." : "Extra care needed during transits through this sign."}',
    keyPoints: [
      'Sign: $sign',
      'Points: $points${type == 'SAV' ? '/56' : '/8'}',
      type == 'SAV'
          ? 'Type: Sarvashtakavarga (Combined)'
          : 'Type: Bhinna Ashtakavarga (Individual)',
      type == 'SAV' ? 'Strong: ≥28 points' : 'Auspicious: ≥4 points',
      'Used for transit predictions',
    ],
    accentColor: color,
    icon: Icons.apps_rounded,
  );
}

InsightData _getLagnaLordStrengthInsight(
  String lagnaLord,
  String ascendantSign,
  ShadbalaData? strength,
) {
  final planetColor = _getPlanetColor(lagnaLord);

  return InsightData(
    title: 'Lagna Lord Strength',
    value:
        '$lagnaLord (${strength?.percentageOfRequired.toStringAsFixed(0) ?? "N/A"}%)',
    description:
        'The Lagna Lord (Ascendant Lord) is the most important planet in your chart. It rules your Ascendant sign and represents your overall life path, personality, and vitality. Its strength directly impacts your ability to achieve success.',
    significance:
        '$lagnaLord rules $ascendantSign (your Ascendant). ${strength != null ? (strength.isStrong ? "Your Lagna Lord is strong, indicating good vitality and ability to overcome obstacles." : "Your Lagna Lord needs strengthening for better life results.") : ""}',
    keyPoints: [
      'Lagna Lord: $lagnaLord',
      'Rules: $ascendantSign Ascendant',
      if (strength != null) ...[
        'Shadbala: ${strength.totalBala.toStringAsFixed(1)} Rupas',
        'Required: ${strength.requiredBala.toStringAsFixed(0)} Rupas',
        'Strength: ${strength.percentageOfRequired.toStringAsFixed(1)}%',
        'Status: ${strength.isStrong ? "Strong ✓" : "Needs Support"}',
      ],
      'The Lagna Lord\'s condition affects overall life success',
    ],
    accentColor: planetColor,
    icon: Icons.home_rounded,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// NAVIGATION SECTION DATA
// ═══════════════════════════════════════════════════════════════════════════
const _sections = [
  NavSection(id: 'overview', label: 'Overview', color: _Colors.violet),
  NavSection(id: 'shadbala', label: 'Shadbala', color: _Colors.rose),
  NavSection(id: 'vimshopaka', label: 'Vimshopaka', color: _Colors.sky),
  NavSection(id: 'ashtakavarga', label: 'Ashtaka', color: _Colors.emerald),
];

/// Strength Tab - Shows Shadbala, Vimshopaka, and Ashtakavarga
/// Premium, elegant UI with clear visual hierarchy
class StrengthTab extends StatefulWidget {
  final KundaliData kundaliData;

  const StrengthTab({super.key, required this.kundaliData});

  @override
  State<StrengthTab> createState() => _StrengthTabState();
}

class _StrengthTabState extends State<StrengthTab> {
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
    // Calculate all strength data
    final shadbala = KundaliCalculationService.calculateShadbala(
      widget.kundaliData.planetPositions,
      widget.kundaliData.ascendant.longitude,
      widget.kundaliData.birthDateTime,
    );

    final vimshopaka = KundaliCalculationService.calculateVimshopakaBala(
      widget.kundaliData.planetPositions,
    );

    final lagnaSignIndex = KundaliCalculationService.zodiacSigns.indexOf(
      widget.kundaliData.ascendant.sign,
    );
    final ashtakavarga = KundaliCalculationService.calculateAshtakavarga(
      widget.kundaliData.planetPositions,
      lagnaSignIndex,
    );

    final sav = KundaliCalculationService.calculateSarvashtakavarga(
      ashtakavarga,
    );

    final strengthRanking = _calculateStrengthRanking(shadbala);
    final strongestPlanet =
        strengthRanking.isNotEmpty ? strengthRanking.first : null;
    final weakestPlanet =
        strengthRanking.isNotEmpty ? strengthRanking.last : null;

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
              // OVERVIEW SECTION
              // ═══════════════════════════════════════════════════════════════
              _AnimatedSectionWrapper(
                key: _animatedKeys['overview'],
                sectionKey: _sectionKeys['overview']!,
                accentColor: _Colors.violet,
                child: _AnimatedCardWrapper(
                  child: _StrengthHeroCard(
                    shadbala: shadbala,
                    strongestPlanet: strongestPlanet,
                    weakestPlanet: weakestPlanet,
                    ascendantSign: widget.kundaliData.ascendant.sign,
                  ),
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // ═══════════════════════════════════════════════════════════════
              // SHADBALA SECTION
              // ═══════════════════════════════════════════════════════════════
              _AnimatedSectionWrapper(
                key: _animatedKeys['shadbala'],
                sectionKey: _sectionKeys['shadbala']!,
                accentColor: _Colors.rose,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: 'Shadbala (षड्बल)',
                      subtitle: 'Six-fold planetary strength',
                      accentColor: _Colors.rose,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(delay: 50, child: _ShadbalaLegend()),
                    const SizedBox(height: _DesignTokens.space12),
                    ...shadbala.entries.toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final planetEntry = entry.value;
                      return _AnimatedCardWrapper(
                        delay: 100 + (index * 50),
                        child: _PremiumShadbalaCard(
                          data: planetEntry.value,
                          rank: strengthRanking.indexOf(planetEntry.key) + 1,
                          totalPlanets: strengthRanking.length,
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // ═══════════════════════════════════════════════════════════════
              // VIMSHOPAKA BALA SECTION
              // ═══════════════════════════════════════════════════════════════
              _AnimatedSectionWrapper(
                key: _animatedKeys['vimshopaka'],
                sectionKey: _sectionKeys['vimshopaka']!,
                accentColor: _Colors.sky,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: 'Vimshopaka Bala',
                      subtitle: 'Divisional chart strength (20-point scale)',
                      accentColor: _Colors.sky,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: _VimshopakaSummary(vimshopaka: vimshopaka),
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 100,
                      child: _VimshopakaBarsCard(vimshopaka: vimshopaka),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // ═══════════════════════════════════════════════════════════════
              // ASHTAKAVARGA SECTION
              // ═══════════════════════════════════════════════════════════════
              _AnimatedSectionWrapper(
                key: _animatedKeys['ashtakavarga'],
                sectionKey: _sectionKeys['ashtakavarga']!,
                accentColor: _Colors.emerald,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: 'Ashtakavarga (अष्टकवर्ग)',
                      subtitle: 'Transit strength by sign',
                      accentColor: _Colors.emerald,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: _AshtakavargaSummaryCard(
                        ashtakavarga: ashtakavarga,
                        sav: sav,
                      ),
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 100,
                      child: _AshtakavargaHeatmap(
                        ashtakavarga: ashtakavarga,
                        sav: sav,
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

  List<String> _calculateStrengthRanking(Map<String, ShadbalaData> shadbala) {
    final entries = shadbala.entries.toList();
    entries.sort(
      (a, b) =>
          b.value.percentageOfRequired.compareTo(a.value.percentageOfRequired),
    );
    return entries.map((e) => e.key).toList();
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
// STRENGTH HERO CARD - Interactive
// ═══════════════════════════════════════════════════════════════════════════
class _StrengthHeroCard extends StatefulWidget {
  final Map<String, ShadbalaData> shadbala;
  final String? strongestPlanet;
  final String? weakestPlanet;
  final String ascendantSign;

  const _StrengthHeroCard({
    required this.shadbala,
    required this.strongestPlanet,
    required this.weakestPlanet,
    required this.ascendantSign,
  });

  @override
  State<_StrengthHeroCard> createState() => _StrengthHeroCardState();
}

class _StrengthHeroCardState extends State<_StrengthHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  // ignore: unused_field - used for setState to trigger rebuild
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
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStrengthColor(double percentage) {
    if (percentage >= 100) return _Colors.emerald;
    if (percentage >= 75) return _Colors.sky;
    if (percentage >= 50) return _Colors.amber;
    return _Colors.coral;
  }

  String _getStrengthLevel(double percentage) {
    if (percentage >= 100) return 'Excellent';
    if (percentage >= 75) return 'Good';
    if (percentage >= 50) return 'Average';
    return 'Needs Support';
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
    return lords[sign] ?? 'Sun';
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.selectionClick();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    final totalPercentage = widget.shadbala.values
        .map((d) => d.percentageOfRequired)
        .fold<double>(0.0, (a, b) => a + b);
    final avgStrength =
        widget.shadbala.isNotEmpty
            ? totalPercentage / widget.shadbala.length
            : 0.0;
    final strongCount = widget.shadbala.values.where((d) => d.isStrong).length;
    final weakCount = widget.shadbala.values.length - strongCount;
    _showInsightSheet(
      context,
      _getChartStrengthInsight(
        avgStrength,
        strongCount,
        weakCount,
        widget.shadbala.length,
      ),
    );
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final totalPercentage = widget.shadbala.values
        .map((d) => d.percentageOfRequired)
        .fold<double>(0.0, (a, b) => a + b);
    final avgStrength =
        widget.shadbala.isNotEmpty
            ? totalPercentage / widget.shadbala.length
            : 0.0;
    final strongCount = widget.shadbala.values.where((d) => d.isStrong).length;
    final weakCount = widget.shadbala.values.length - strongCount;
    final lagnaLord = _getLagnaLord(widget.ascendantSign);
    final lagnaLordStrength = widget.shadbala[lagnaLord];
    final strengthLevel = _getStrengthLevel(avgStrength);
    final strengthColor = _getStrengthColor(avgStrength);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF141218),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF262432), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with gauge and title
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Compact strength gauge
                  _CompactStrengthGauge(
                    percentage: avgStrength,
                    color: strengthColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Level badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: strengthColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            strengthLevel.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: strengthColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Chart Strength',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Strong/Weak count
                        Row(
                          children: [
                            _MiniStatBadge(
                              icon: Icons.trending_up_rounded,
                              value: '$strongCount',
                              label: 'Strong',
                              color: _Colors.emerald,
                            ),
                            const SizedBox(width: 12),
                            _MiniStatBadge(
                              icon: Icons.trending_down_rounded,
                              value: '$weakCount',
                              label: 'Weak',
                              color: _Colors.amber,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Info icon
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: const Color(0xFF6E6A7A),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Strongest and Weakest planets row
              Row(
                children: [
                  if (widget.strongestPlanet != null)
                    Expanded(
                      child: _CompactPlanetCard(
                        label: 'Strongest',
                        planet: widget.strongestPlanet!,
                        percentage:
                            widget
                                .shadbala[widget.strongestPlanet]
                                ?.percentageOfRequired ??
                            0,
                        isPositive: true,
                        onTap: () {
                          if (widget.shadbala[widget.strongestPlanet] != null) {
                            HapticFeedback.selectionClick();
                            _showInsightSheet(
                              context,
                              _getShadbalaInsight(
                                widget.shadbala[widget.strongestPlanet]!,
                                1,
                                widget.shadbala.length,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  const SizedBox(width: 10),
                  if (widget.weakestPlanet != null)
                    Expanded(
                      child: _CompactPlanetCard(
                        label: 'Weakest',
                        planet: widget.weakestPlanet!,
                        percentage:
                            widget
                                .shadbala[widget.weakestPlanet]
                                ?.percentageOfRequired ??
                            0,
                        isPositive: false,
                        onTap: () {
                          if (widget.shadbala[widget.weakestPlanet] != null) {
                            HapticFeedback.selectionClick();
                            _showInsightSheet(
                              context,
                              _getShadbalaInsight(
                                widget.shadbala[widget.weakestPlanet]!,
                                widget.shadbala.length,
                                widget.shadbala.length,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),

              // Lagna Lord
              if (lagnaLordStrength != null) ...[
                const SizedBox(height: 12),
                _CompactLagnaLordRow(
                  lagnaLord: lagnaLord,
                  ascendantSign: widget.ascendantSign,
                  strength: lagnaLordStrength,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// COMPACT STRENGTH GAUGE - Refined circular gauge
// ═══════════════════════════════════════════════════════════════════════════
class _CompactStrengthGauge extends StatefulWidget {
  final double percentage;
  final Color color;

  const _CompactStrengthGauge({required this.percentage, required this.color});

  @override
  State<_CompactStrengthGauge> createState() => _CompactStrengthGaugeState();
}

class _CompactStrengthGaugeState extends State<_CompactStrengthGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressAnim = Tween<double>(
      begin: 0,
      end: widget.percentage / 100,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: AnimatedBuilder(
        animation: _progressAnim,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withOpacity(0.15),
                    width: 4,
                  ),
                ),
              ),
              // Progress arc
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: _progressAnim.value.clamp(0.0, 1.0),
                  strokeWidth: 4,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Center text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(_progressAnim.value * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: widget.color,
                    ),
                  ),
                  Text(
                    'AVG',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7C7889),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MINI STAT BADGE - Compact strong/weak indicator
// ═══════════════════════════════════════════════════════════════════════════
class _MiniStatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MiniStatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF8B8798),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// COMPACT PLANET CARD - Strongest/Weakest planet display with premium images
// ═══════════════════════════════════════════════════════════════════════════
class _CompactPlanetCard extends StatefulWidget {
  final String label;
  final String planet;
  final double percentage;
  final bool isPositive;
  final VoidCallback onTap;

  const _CompactPlanetCard({
    required this.label,
    required this.planet,
    required this.percentage,
    required this.isPositive,
    required this.onTap,
  });

  @override
  State<_CompactPlanetCard> createState() => _CompactPlanetCardState();
}

class _CompactPlanetCardState extends State<_CompactPlanetCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isPositive ? _Colors.emerald : _Colors.amber;
    final planetColor = _getPlanetColor(widget.planet);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isPressed ? color.withOpacity(0.08) : const Color(0xFF1A181F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                _isPressed ? color.withOpacity(0.3) : const Color(0xFF2A2838),
            width: _isPressed ? 1 : 0.5,
          ),
          boxShadow:
              _isPressed
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ]
                  : null,
        ),
        child: Row(
          children: [
            // Planet image with premium shadow
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  // Deep ambient shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: -2,
                    offset: const Offset(0, 3),
                  ),
                  // Color accent glow
                  BoxShadow(
                    color: planetColor.withOpacity(_isPressed ? 0.25 : 0.12),
                    blurRadius: _isPressed ? 12 : 8,
                    spreadRadius: -2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  _getPlanetImagePath(widget.planet),
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: planetColor.withOpacity(0.12),
                      child: Center(
                        child: Text(
                          _getPlanetSymbol(widget.planet),
                          style: TextStyle(fontSize: 16, color: planetColor),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF7C7889),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.planet,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _isPressed ? color : Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Percentage badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${widget.percentage.toStringAsFixed(0)}%',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
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
// COMPACT LAGNA LORD ROW - With premium planet and zodiac images
// ═══════════════════════════════════════════════════════════════════════════
class _CompactLagnaLordRow extends StatefulWidget {
  final String lagnaLord;
  final String ascendantSign;
  final ShadbalaData strength;

  const _CompactLagnaLordRow({
    required this.lagnaLord,
    required this.ascendantSign,
    required this.strength,
  });

  @override
  State<_CompactLagnaLordRow> createState() => _CompactLagnaLordRowState();
}

class _CompactLagnaLordRowState extends State<_CompactLagnaLordRow> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.strength.isStrong ? _Colors.emerald : _Colors.amber;
    final planetColor = _getPlanetColor(widget.lagnaLord);
    final zodiacColor = _getZodiacColor(widget.ascendantSign);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        _showInsightSheet(
          context,
          _getLagnaLordStrengthInsight(
            widget.lagnaLord,
            widget.ascendantSign,
            widget.strength,
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:
              _isPressed
                  ? _Colors.violet.withOpacity(0.08)
                  : const Color(0xFF1A181F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                _isPressed
                    ? _Colors.violet.withOpacity(0.3)
                    : const Color(0xFF2A2838),
            width: _isPressed ? 1 : 0.5,
          ),
          boxShadow:
              _isPressed
                  ? [
                    BoxShadow(
                      color: _Colors.violet.withOpacity(0.12),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ]
                  : null,
        ),
        child: Row(
          children: [
            // Planet image with premium shadow
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: -2,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: planetColor.withOpacity(_isPressed ? 0.25 : 0.12),
                    blurRadius: _isPressed ? 12 : 8,
                    spreadRadius: -2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  _getPlanetImagePath(widget.lagnaLord),
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: planetColor.withOpacity(0.12),
                      child: Center(
                        child: Text(
                          _getPlanetSymbol(widget.lagnaLord),
                          style: TextStyle(fontSize: 16, color: planetColor),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Lagna Lord',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF7C7889),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 12,
                        color: _Colors.violet.withOpacity(0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        widget.lagnaLord,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isPressed ? _Colors.violet : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: zodiacColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.ascendantSign,
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: zodiacColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.strength.isStrong
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 10,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.strength.percentageOfRequired.toStringAsFixed(0)}%',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
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

class _InteractiveStatChip extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final String description;

  const _InteractiveStatChip({
    required this.icon,
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
            title: '${widget.label} Planets',
            value: widget.value,
            description: widget.description,
            significance:
                'You have ${widget.value} ${widget.label.toLowerCase()} planets in your chart.',
            keyPoints: [
              'Count: ${widget.value} planets',
              'Status: ${widget.label}',
              widget.description,
            ],
            accentColor: widget.color,
            icon: widget.icon,
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(_isPressed ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                _isPressed ? widget.color.withOpacity(0.4) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 14, color: widget.color),
            const SizedBox(width: 4),
            Text(
              widget.value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: widget.color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: _Colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractivePlanetHighlight extends StatefulWidget {
  final String label;
  final String planet;
  final double percentage;
  final bool isPositive;
  final ShadbalaData? shadbalaData;
  final int rank;
  final int total;

  const _InteractivePlanetHighlight({
    required this.label,
    required this.planet,
    required this.percentage,
    required this.isPositive,
    required this.shadbalaData,
    required this.rank,
    required this.total,
  });

  @override
  State<_InteractivePlanetHighlight> createState() =>
      _InteractivePlanetHighlightState();
}

class _InteractivePlanetHighlightState
    extends State<_InteractivePlanetHighlight> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isPositive ? _Colors.emerald : _Colors.amber;
    final planetColor = _getPlanetColor(widget.planet);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        if (widget.shadbalaData != null) {
          _showInsightSheet(
            context,
            _getShadbalaInsight(
              widget.shadbalaData!,
              widget.rank,
              widget.total,
            ),
          );
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isPressed ? color.withOpacity(0.12) : const Color(0xFF1A181F),
          borderRadius: BorderRadius.circular(_DesignTokens.radiusMd),
          border: Border.all(
            color:
                _isPressed ? color.withOpacity(0.35) : const Color(0xFF2A2838),
            width: _isPressed ? 1.5 : 0.5,
          ),
          boxShadow:
              _isPressed
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ]
                  : null,
        ),
        child: Row(
          children: [
            // Planet image with premium shadow
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    spreadRadius: -2,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: planetColor.withOpacity(_isPressed ? 0.25 : 0.12),
                    blurRadius: _isPressed ? 10 : 6,
                    spreadRadius: -2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  _getPlanetImagePath(widget.planet),
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: planetColor.withOpacity(0.12),
                      child: Center(
                        child: Text(
                          _getPlanetSymbol(widget.planet),
                          style: TextStyle(fontSize: 16, color: planetColor),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.label,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: _Colors.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 100),
                        opacity: _isPressed ? 1.0 : 0.5,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 12,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.planet,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isPressed ? planetColor : _Colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isPositive
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 10,
                    color: color,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${widget.percentage.toStringAsFixed(0)}%',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
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

class _InteractiveLagnaLordCard extends StatefulWidget {
  final String lagnaLord;
  final String ascendantSign;
  final ShadbalaData strength;

  const _InteractiveLagnaLordCard({
    required this.lagnaLord,
    required this.ascendantSign,
    required this.strength,
  });

  @override
  State<_InteractiveLagnaLordCard> createState() =>
      _InteractiveLagnaLordCardState();
}

class _InteractiveLagnaLordCardState extends State<_InteractiveLagnaLordCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final planetColor = _getPlanetColor(widget.lagnaLord);
    final zodiacColor = _getZodiacColor(widget.ascendantSign);
    final strengthColor =
        widget.strength.isStrong ? _Colors.emerald : _Colors.amber;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        _showInsightSheet(
          context,
          _getLagnaLordStrengthInsight(
            widget.lagnaLord,
            widget.ascendantSign,
            widget.strength,
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              _isPressed
                  ? _Colors.violet.withOpacity(0.08)
                  : const Color(0xFF1A181F),
          borderRadius: BorderRadius.circular(_DesignTokens.radiusMd),
          border: Border.all(
            color:
                _isPressed
                    ? _Colors.violet.withOpacity(0.35)
                    : const Color(0xFF2A2838),
            width: _isPressed ? 1.5 : 0.5,
          ),
          boxShadow:
              _isPressed
                  ? [
                    BoxShadow(
                      color: _Colors.violet.withOpacity(0.12),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ]
                  : null,
        ),
        child: Row(
          children: [
            // Planet image with premium shadow
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    spreadRadius: -2,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: planetColor.withOpacity(_isPressed ? 0.25 : 0.12),
                    blurRadius: _isPressed ? 10 : 6,
                    spreadRadius: -2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  _getPlanetImagePath(widget.lagnaLord),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: planetColor.withOpacity(0.12),
                      child: Center(
                        child: Text(
                          _getPlanetSymbol(widget.lagnaLord),
                          style: TextStyle(fontSize: 18, color: planetColor),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Lagna Lord',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: _Colors.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 100),
                        opacity: _isPressed ? 1.0 : 0.5,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 14,
                          color: _Colors.violet,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        widget.lagnaLord,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isPressed ? _Colors.violet : planetColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: zodiacColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.ascendantSign,
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: zodiacColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: strengthColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: strengthColor.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.strength.isStrong
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 10,
                    color: strengthColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.strength.percentageOfRequired.toStringAsFixed(0)}%',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: strengthColor,
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

class _StrengthGauge extends StatefulWidget {
  final double percentage;
  final Color color;

  const _StrengthGauge({required this.percentage, required this.color});

  @override
  State<_StrengthGauge> createState() => _StrengthGaugeState();
}

class _StrengthGaugeState extends State<_StrengthGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.color.withOpacity(0.25 * _pulseAnimation.value),
                widget.color.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: widget.color.withOpacity(
                0.3 + 0.1 * _pulseAnimation.value,
              ),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.15 * _pulseAnimation.value),
                blurRadius: 16,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.percentage.toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: widget.color,
                  ),
                ),
                Text(
                  'AVG',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: _Colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHADBALA COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════
class _ShadbalaLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141218),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF262432), width: 1),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: const [
            _CompactLegendChip(
              label: 'Sthana',
              hint: 'Position',
              color: _Colors.violet,
            ),
            SizedBox(width: 6),
            _CompactLegendChip(
              label: 'Dig',
              hint: 'Direction',
              color: _Colors.sky,
            ),
            SizedBox(width: 6),
            _CompactLegendChip(
              label: 'Kala',
              hint: 'Time',
              color: _Colors.emerald,
            ),
            SizedBox(width: 6),
            _CompactLegendChip(
              label: 'Chesta',
              hint: 'Motion',
              color: _Colors.amber,
            ),
            SizedBox(width: 6),
            _CompactLegendChip(
              label: 'Naisarg',
              hint: 'Natural',
              color: _Colors.rose,
            ),
            SizedBox(width: 6),
            _CompactLegendChip(
              label: 'Drik',
              hint: 'Aspect',
              color: _Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactLegendChip extends StatelessWidget {
  final String label;
  final String hint;
  final Color color;

  const _CompactLegendChip({
    required this.label,
    required this.hint,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            hint,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF7C7889),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumShadbalaCard extends StatefulWidget {
  final ShadbalaData data;
  final int rank;
  final int totalPlanets;

  const _PremiumShadbalaCard({
    required this.data,
    required this.rank,
    required this.totalPlanets,
  });

  @override
  State<_PremiumShadbalaCard> createState() => _PremiumShadbalaCardState();
}

class _PremiumShadbalaCardState extends State<_PremiumShadbalaCard>
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
      _getShadbalaInsight(widget.data, widget.rank, widget.totalPlanets),
    );
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = widget.data.percentageOfRequired.clamp(0.0, 150.0);
    final isStrong = widget.data.isStrong;
    final strengthColor = isStrong ? _Colors.emerald : _Colors.amber;
    final planetColor = _getPlanetColor(widget.data.planet);
    final isTopRank = widget.rank == 1;
    final isBottomRank = widget.rank == widget.totalPlanets;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color:
                _isPressed
                    ? planetColor.withOpacity(0.04)
                    : const Color(0xFF141218),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  _isPressed
                      ? planetColor.withOpacity(0.35)
                      : isTopRank
                      ? _Colors.emerald.withOpacity(0.3)
                      : isBottomRank
                      ? _Colors.coral.withOpacity(0.2)
                      : const Color(0xFF262432),
              width: _isPressed ? 1.5 : 1,
            ),
            boxShadow:
                _isPressed
                    ? [
                      BoxShadow(
                        color: planetColor.withOpacity(0.15),
                        blurRadius: 16,
                        spreadRadius: -4,
                      ),
                    ]
                    : null,
          ),
          child: Column(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Planet image with rank badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
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
                                color: planetColor.withOpacity(
                                  _isPressed ? 0.3 : 0.15,
                                ),
                                blurRadius: _isPressed ? 16 : 10,
                                spreadRadius: -2,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              _getPlanetImagePath(widget.data.planet),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: planetColor.withOpacity(0.12),
                                  child: Center(
                                    child: Text(
                                      _getPlanetSymbol(widget.data.planet),
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: planetColor,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          right: -5,
                          top: -5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isTopRank
                                      ? _Colors.emerald
                                      : isBottomRank
                                      ? _Colors.coral
                                      : const Color(0xFF3A3848),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '#${widget.rank}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Planet info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Planet name row
                          Row(
                            children: [
                              Text(
                                widget.data.planet,
                                style: GoogleFonts.instrumentSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _isPressed ? planetColor : Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (isTopRank) ...[
                                const SizedBox(width: 6),
                                const Text(
                                  '👑',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Rupas info with subtle chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A181F),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${widget.data.totalBala.toStringAsFixed(1)} / ${widget.data.requiredBala.toStringAsFixed(0)} Rupas',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF8B8798),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status badge + info icon
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 100),
                          opacity: _isPressed ? 1.0 : 0.5,
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: planetColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: strengthColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: strengthColor.withOpacity(0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isStrong
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                size: 10,
                                color: strengthColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isStrong ? 'Strong' : 'Weak',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: strengthColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Progress bar section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _MinimalProgressBar(
                  percentage: percentage,
                  color: strengthColor,
                ),
              ),

              const SizedBox(height: 12),

              // Bala Components
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A181F),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF2A2838),
                    width: 0.5,
                  ),
                ),
                child: _MinimalBalaRow(data: widget.data),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Premium Progress Bar - Elegant thin design with gradient
class _MinimalProgressBar extends StatefulWidget {
  final double percentage;
  final Color color;

  const _MinimalProgressBar({required this.percentage, required this.color});

  @override
  State<_MinimalProgressBar> createState() => _MinimalProgressBarState();
}

class _MinimalProgressBarState extends State<_MinimalProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Normalize to 0-1 range (assuming max 150%)
    _progressAnim = Tween<double>(
      begin: 0,
      end: widget.percentage / 150,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutQuart),
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create lighter gradient colors from the base color
    final baseColor = widget.color;
    final lightColor = Color.lerp(baseColor, Colors.white, 0.35)!;
    final paleColor = Color.lerp(baseColor, Colors.white, 0.55)!;

    return AnimatedBuilder(
      animation: _progressAnim,
      builder: (context, child) {
        final progress = _progressAnim.value.clamp(0.0, 1.0);

        return Row(
          children: [
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  // Subtle dark track with inner shadow effect
                  color: const Color(0xFF1A181F),
                  borderRadius: BorderRadius.circular(1.5),
                  border: Border.all(
                    color: const Color(0xFF2A2838).withOpacity(0.5),
                    width: 0.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Progress fill with elegant gradient
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1.5),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              paleColor.withOpacity(0.6),
                              lightColor.withOpacity(0.8),
                              baseColor.withOpacity(0.9),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                          boxShadow: [
                            // Soft glow effect
                            BoxShadow(
                              color: baseColor.withOpacity(0.25),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Subtle highlight line at top
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(1.5),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.white.withOpacity(0.0),
                                      Colors.white.withOpacity(0.25),
                                      Colors.white.withOpacity(0.15),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Leading edge accent dot
                    if (progress > 0.02)
                      Positioned(
                        left:
                            (progress *
                                (MediaQuery.of(context).size.width - 80)) -
                            1.5,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 3,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.6),
                            boxShadow: [
                              BoxShadow(
                                color: baseColor.withOpacity(0.4),
                                blurRadius: 3,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Percentage text with gradient effect
            ShaderMask(
              shaderCallback:
                  (bounds) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [lightColor, baseColor],
                  ).createShader(bounds),
              child: Text(
                '${widget.percentage.toStringAsFixed(0)}%',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Minimal Bala Row - Clean component display
class _MinimalBalaRow extends StatelessWidget {
  final ShadbalaData data;

  const _MinimalBalaRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final balas = [
      ('Sthana', data.sthanaBala, _Colors.violet),
      ('Dig', data.digBala, _Colors.sky),
      ('Kala', data.kalaBala, _Colors.emerald),
      ('Chesta', data.chestaBala, _Colors.amber),
      ('Naisarg', data.naisargikaBala, _Colors.rose),
      ('Drik', data.drikBala, _Colors.teal),
    ];

    final maxValue = balas.map((b) => b.$2).reduce((a, b) => a > b ? a : b);
    final minValue = balas.map((b) => b.$2).reduce((a, b) => a < b ? a : b);

    return Row(
      children:
          balas.map((bala) {
            final isMax = bala.$2 == maxValue;
            final isMin = bala.$2 == minValue;

            return Expanded(
              child: _MinimalBalaCell(
                name: bala.$1,
                value: bala.$2,
                color: bala.$3,
                isMax: isMax,
                isMin: isMin,
              ),
            );
          }).toList(),
    );
  }
}

// Minimal Bala Cell - Clean value display
class _MinimalBalaCell extends StatelessWidget {
  final String name;
  final double value;
  final Color color;
  final bool isMax;
  final bool isMin;

  const _MinimalBalaCell({
    required this.name,
    required this.value,
    required this.color,
    required this.isMax,
    required this.isMin,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor =
        isMax
            ? _Colors.emerald
            : isMin
            ? _Colors.coral
            : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color:
            isMax
                ? _Colors.emerald.withOpacity(0.1)
                : isMin
                ? _Colors.coral.withOpacity(0.08)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border:
            isMax || isMin
                ? Border.all(
                  color:
                      isMax
                          ? _Colors.emerald.withOpacity(0.25)
                          : _Colors.coral.withOpacity(0.2),
                  width: 0.5,
                )
                : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color dot
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 4),
          // Value
          Text(
            value.toStringAsFixed(0),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: displayColor,
            ),
          ),
          // Label
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 7,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF7C7889),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VIMSHOPAKA COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════
class _VimshopakaSummary extends StatefulWidget {
  final Map<String, VimshopakaBalaData> vimshopaka;

  const _VimshopakaSummary({required this.vimshopaka});

  @override
  State<_VimshopakaSummary> createState() => _VimshopakaSummaryState();
}

class _VimshopakaSummaryState extends State<_VimshopakaSummary> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final strongCount =
        widget.vimshopaka.values.where((d) => d.strength == 'Strong').length;
    final mediumCount =
        widget.vimshopaka.values.where((d) => d.strength == 'Medium').length;
    final weakCount =
        widget.vimshopaka.values.where((d) => d.strength == 'Weak').length;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        _showInsightSheet(
          context,
          InsightData(
            title: 'Vimshopaka Bala',
            value: 'Summary',
            description:
                'Vimshopaka Bala (20-point strength) evaluates how well planets are placed across all 16 divisional charts (Shodasavarga). Each planet receives dignity points based on its placement in each divisional chart.',
            significance:
                'Of ${widget.vimshopaka.length} planets: $strongCount are Strong (75-100%), $mediumCount are Medium (50-75%), and $weakCount are Weak (<50%).',
            keyPoints: [
              'Strong Planets: $strongCount (15-20 points)',
              'Medium Planets: $mediumCount (10-15 points)',
              'Weak Planets: $weakCount (0-10 points)',
              'Based on 16 divisional charts (D1 to D60)',
              'Max score: 20 points per planet',
              'Strong Vimshopaka = Good dignity across all charts',
            ],
            accentColor: _Colors.sky,
            icon: Icons.grid_view_rounded,
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _Colors.sky.withOpacity(_isPressed ? 0.12 : 0.06),
          borderRadius: BorderRadius.circular(_DesignTokens.radiusMd),
          border: Border.all(
            color: _Colors.sky.withOpacity(_isPressed ? 0.3 : 0.15),
            width: _isPressed ? 1 : 0.5,
          ),
          boxShadow:
              _isPressed
                  ? [
                    BoxShadow(
                      color: _Colors.sky.withOpacity(0.15),
                      blurRadius: 10,
                      spreadRadius: -2,
                    ),
                  ]
                  : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _Colors.sky.withOpacity(_isPressed ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: _Colors.sky,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tap for detailed explanation',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: _Colors.sky.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Strength from 16 divisional charts',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: _Colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            _InteractiveMiniCount(
              count: strongCount,
              label: 'Strong',
              color: _Colors.emerald,
            ),
            const SizedBox(width: 6),
            _InteractiveMiniCount(
              count: mediumCount,
              label: 'Med',
              color: _Colors.amber,
            ),
            const SizedBox(width: 6),
            _InteractiveMiniCount(
              count: weakCount,
              label: 'Weak',
              color: _Colors.coral,
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveMiniCount extends StatefulWidget {
  final int count;
  final String label;
  final Color color;

  const _InteractiveMiniCount({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  State<_InteractiveMiniCount> createState() => _InteractiveMiniCountState();
}

class _InteractiveMiniCountState extends State<_InteractiveMiniCount> {
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
            title: 'Vimshopaka Strength',
            value: '${widget.count} ${widget.label}',
            description:
                widget.label == 'Strong'
                    ? 'Planets with 15-20 Vimshopaka points (75-100%). These planets have excellent dignity across divisional charts and give strong results.'
                    : widget.label == 'Med'
                    ? 'Planets with 10-15 Vimshopaka points (50-75%). These planets have moderate dignity and give balanced results.'
                    : 'Planets with 0-10 Vimshopaka points (<50%). These planets may need strengthening through remedies.',
            significance:
                'You have ${widget.count} ${widget.label.toLowerCase()} planet(s) based on Vimshopaka Bala scoring.',
            keyPoints: [
              'Count: ${widget.count} planets',
              'Category: ${widget.label}',
              widget.label == 'Strong'
                  ? 'Score Range: 15-20 points (75-100%)'
                  : widget.label == 'Med'
                  ? 'Score Range: 10-15 points (50-75%)'
                  : 'Score Range: 0-10 points (0-50%)',
            ],
            accentColor: widget.color,
            icon: Icons.grid_view_rounded,
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(_isPressed ? 0.2 : 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                _isPressed ? widget.color.withOpacity(0.4) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.count}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: widget.color,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              widget.label,
              style: GoogleFonts.inter(fontSize: 8, color: widget.color),
            ),
          ],
        ),
      ),
    );
  }
}

class _VimshopakaBarsCard extends StatelessWidget {
  final Map<String, VimshopakaBalaData> vimshopaka;

  const _VimshopakaBarsCard({required this.vimshopaka});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _Colors.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(_DesignTokens.radiusLg),
        border: Border.all(color: _Colors.border.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        children:
            vimshopaka.entries.map((entry) {
              final data = entry.value;
              return _InteractiveVimshopakaPlanetRow(data: data);
            }).toList(),
      ),
    );
  }
}

class _InteractiveVimshopakaPlanetRow extends StatefulWidget {
  final VimshopakaBalaData data;

  const _InteractiveVimshopakaPlanetRow({required this.data});

  @override
  State<_InteractiveVimshopakaPlanetRow> createState() =>
      _InteractiveVimshopakaPlanetRowState();
}

class _InteractiveVimshopakaPlanetRowState
    extends State<_InteractiveVimshopakaPlanetRow> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final color =
        data.strength == 'Strong'
            ? _Colors.emerald
            : data.strength == 'Medium'
            ? _Colors.amber
            : _Colors.coral;
    final planetColor = _getPlanetColor(data.planet);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        _showInsightSheet(context, _getVimshopakaBalaInsight(data));
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color:
              _isPressed
                  ? planetColor.withOpacity(0.08)
                  : const Color(0xFF1A181F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                _isPressed
                    ? planetColor.withOpacity(0.35)
                    : const Color(0xFF2A2838),
            width: _isPressed ? 1.5 : 0.5,
          ),
          boxShadow:
              _isPressed
                  ? [
                    BoxShadow(
                      color: planetColor.withOpacity(0.12),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ]
                  : null,
        ),
        child: Row(
          children: [
            // Planet image with premium shadow
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    spreadRadius: -2,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: planetColor.withOpacity(_isPressed ? 0.25 : 0.1),
                    blurRadius: _isPressed ? 10 : 6,
                    spreadRadius: -2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  _getPlanetImagePath(data.planet),
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: planetColor.withOpacity(0.12),
                      child: Center(
                        child: Text(
                          _getPlanetSymbol(data.planet),
                          style: TextStyle(fontSize: 16, color: planetColor),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Planet name
            SizedBox(
              width: 40,
              child: Text(
                data.planet.length > 4
                    ? data.planet.substring(0, 4)
                    : data.planet,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _isPressed ? planetColor : _Colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Progress bar
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2838),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: (data.percentage / 100).clamp(0.0, 1.0),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.7), color],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Percentage with status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${data.percentage.toStringAsFixed(0)}%',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: _isPressed ? 1.0 : 0.4,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: planetColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ASHTAKAVARGA COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════
class _AshtakavargaSummaryCard extends StatefulWidget {
  final Map<String, List<int>> ashtakavarga;
  final List<int> sav;

  const _AshtakavargaSummaryCard({
    required this.ashtakavarga,
    required this.sav,
  });

  @override
  State<_AshtakavargaSummaryCard> createState() =>
      _AshtakavargaSummaryCardState();
}

class _AshtakavargaSummaryCardState extends State<_AshtakavargaSummaryCard> {
  bool _isPressed = false;

  static const _signs = [
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

  static const _signSymbols = [
    '♈',
    '♉',
    '♊',
    '♋',
    '♌',
    '♍',
    '♎',
    '♏',
    '♐',
    '♑',
    '♒',
    '♓',
  ];

  @override
  Widget build(BuildContext context) {
    int maxSav = 0, minSav = 56, maxIndex = 0, minIndex = 0;
    for (int i = 0; i < widget.sav.length; i++) {
      if (widget.sav[i] > maxSav) {
        maxSav = widget.sav[i];
        maxIndex = i;
      }
      if (widget.sav[i] < minSav) {
        minSav = widget.sav[i];
        minIndex = i;
      }
    }

    final totalSav = widget.sav.fold<int>(0, (a, b) => a + b);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        _showInsightSheet(
          context,
          InsightData(
            title: 'Ashtakavarga',
            value: 'Transit Strength System',
            description:
                'Ashtakavarga is a unique Vedic system to evaluate sign strength for transit predictions. Each of the 7 planets contributes 0-8 benefic points (bindus) to each sign. The Sarvashtakavarga (SAV) is the combined score of all planets for each sign.',
            significance:
                'Your strongest sign for transits is ${_signs[maxIndex]} ($maxSav points) and weakest is ${_signs[minIndex]} ($minSav points). Total SAV across all signs is $totalSav.',
            keyPoints: [
              'Strongest Sign: ${_signs[maxIndex]} ($maxSav pts)',
              'Weakest Sign: ${_signs[minIndex]} ($minSav pts)',
              'Total SAV: $totalSav points',
              'Individual BAV: 0-8 points per planet-sign',
              'SAV: 0-56 points per sign (combined)',
              'Good BAV: ≥4 points',
              'Strong SAV: ≥28 points',
            ],
            accentColor: _Colors.emerald,
            icon: Icons.apps_rounded,
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _Colors.emerald.withOpacity(_isPressed ? 0.12 : 0.06),
          borderRadius: BorderRadius.circular(_DesignTokens.radiusMd),
          border: Border.all(
            color: _Colors.emerald.withOpacity(_isPressed ? 0.3 : 0.15),
            width: _isPressed ? 1 : 0.5,
          ),
          boxShadow:
              _isPressed
                  ? [
                    BoxShadow(
                      color: _Colors.emerald.withOpacity(0.15),
                      blurRadius: 10,
                      spreadRadius: -2,
                    ),
                  ]
                  : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: _Colors.emerald.withOpacity(_isPressed ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 12,
                    color: _Colors.emerald,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tap for detailed explanation',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          color: _Colors.emerald.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        'Points 0-8 per sign · ≥4 Auspicious · SAV ≥28 Strong',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: _Colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InteractiveSavHighlight(
                    label: 'Strongest',
                    sign: _signs[maxIndex],
                    signSymbol: _signSymbols[maxIndex],
                    points: maxSav,
                    icon: Icons.arrow_upward_rounded,
                    color: _Colors.emerald,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InteractiveSavHighlight(
                    label: 'Weakest',
                    sign: _signs[minIndex],
                    signSymbol: _signSymbols[minIndex],
                    points: minSav,
                    icon: Icons.arrow_downward_rounded,
                    color: _Colors.coral,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: _InteractiveTotalSav(totalSav: totalSav)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveSavHighlight extends StatefulWidget {
  final String label;
  final String sign;
  final String signSymbol;
  final int points;
  final IconData icon;
  final Color color;

  const _InteractiveSavHighlight({
    required this.label,
    required this.sign,
    required this.signSymbol,
    required this.points,
    required this.icon,
    required this.color,
  });

  @override
  State<_InteractiveSavHighlight> createState() =>
      _InteractiveSavHighlightState();
}

class _InteractiveSavHighlightState extends State<_InteractiveSavHighlight> {
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
          _getAshtakavargaInsight(
            '${widget.signSymbol} ${widget.sign}',
            widget.points,
            'SAV',
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(_isPressed ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                _isPressed ? widget.color.withOpacity(0.3) : Colors.transparent,
            width: 1,
          ),
          boxShadow:
              _isPressed
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 12, color: widget.color),
                const SizedBox(width: 4),
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: _Colors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.signSymbol,
                  style: TextStyle(fontSize: 12, color: widget.color),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    widget.sign,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _Colors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              '${widget.points} pts',
              style: GoogleFonts.jetBrainsMono(
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

class _InteractiveTotalSav extends StatefulWidget {
  final int totalSav;

  const _InteractiveTotalSav({required this.totalSav});

  @override
  State<_InteractiveTotalSav> createState() => _InteractiveTotalSavState();
}

class _InteractiveTotalSavState extends State<_InteractiveTotalSav> {
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
            title: 'Total Sarvashtakavarga',
            value: '${widget.totalSav} Points',
            description:
                'The Total SAV is the sum of all Sarvashtakavarga points across all 12 signs. Maximum possible is 337 points. A higher total indicates overall stronger chart for transits.',
            significance:
                'Your total SAV of ${widget.totalSav} points ${widget.totalSav >= 300
                    ? "is excellent, indicating a strong overall chart"
                    : widget.totalSav >= 250
                    ? "is good, showing balanced strength"
                    : "suggests focusing on beneficial transit periods"}.',
            keyPoints: [
              'Total SAV: ${widget.totalSav} points',
              'Maximum possible: 337 points',
              'Calculation: Sum of all 12 sign SAV values',
              'Higher = Better overall transit strength',
            ],
            accentColor: _Colors.violet,
            icon: Icons.functions_rounded,
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _Colors.violet.withOpacity(_isPressed ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                _isPressed
                    ? _Colors.violet.withOpacity(0.3)
                    : Colors.transparent,
            width: 1,
          ),
          boxShadow:
              _isPressed
                  ? [
                    BoxShadow(
                      color: _Colors.violet.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                  ]
                  : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.functions_rounded, size: 12, color: _Colors.violet),
                const SizedBox(width: 4),
                Text(
                  'Total SAV',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: _Colors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.totalSav}',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _Colors.violet,
              ),
            ),
            Text(
              'points',
              style: GoogleFonts.inter(
                fontSize: 8,
                color: _Colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AshtakavargaHeatmap extends StatelessWidget {
  final Map<String, List<int>> ashtakavarga;
  final List<int> sav;

  const _AshtakavargaHeatmap({required this.ashtakavarga, required this.sav});

  static const _signNames = [
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

  static const _signs = [
    '♈',
    '♉',
    '♊',
    '♋',
    '♌',
    '♍',
    '♎',
    '♏',
    '♐',
    '♑',
    '♒',
    '♓',
  ];

  Color _getHeatmapColor(int value) {
    if (value >= 6) return _Colors.emerald;
    if (value >= 4) return _Colors.emerald.withOpacity(0.4);
    if (value >= 3) return _Colors.amber.withOpacity(0.3);
    if (value >= 2) return _Colors.coral.withOpacity(0.2);
    return _Colors.coral.withOpacity(0.1);
  }

  Color _getSavColor(int value) {
    if (value >= 30) return _Colors.emerald;
    if (value >= 28) return _Colors.emerald.withOpacity(0.6);
    if (value >= 25) return _Colors.amber.withOpacity(0.4);
    if (value >= 22) return _Colors.coral.withOpacity(0.3);
    return _Colors.coral.withOpacity(0.15);
  }

  @override
  Widget build(BuildContext context) {
    final planets = ashtakavarga.keys.toList();

    return Container(
      decoration: BoxDecoration(
        color: _Colors.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(_DesignTokens.radiusLg),
        border: Border.all(color: _Colors.border.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        children: [
          // Header row with signs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _Colors.surface.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_DesignTokens.radiusLg),
                topRight: Radius.circular(_DesignTokens.radiusLg),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 40),
                ..._signs.map(
                  (s) => Expanded(
                    child: Center(
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _Colors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Data rows
          ...planets.map((planet) {
            final values = ashtakavarga[planet]!;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _Colors.border.withOpacity(0.15),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      planet.length > 3 ? planet.substring(0, 3) : planet,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getPlanetColor(planet),
                      ),
                    ),
                  ),
                  ...values.asMap().entries.map((entry) {
                    final index = entry.key;
                    final v = entry.value;
                    return Expanded(
                      child: _InteractiveAshtakavargaCell(
                        value: v,
                        signName: _signNames[index],
                        signSymbol: _signs[index],
                        planetName: planet,
                        color: _getHeatmapColor(v),
                        type: 'BAV',
                      ),
                    );
                  }),
                ],
              ),
            );
          }),

          // SAV row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _Colors.violet.withOpacity(0.06),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(_DesignTokens.radiusLg),
                bottomRight: Radius.circular(_DesignTokens.radiusLg),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    'SAV',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _Colors.violet,
                    ),
                  ),
                ),
                ...sav.asMap().entries.map((entry) {
                  final index = entry.key;
                  final v = entry.value;
                  return Expanded(
                    child: _InteractiveSavCell(
                      value: v,
                      signName: _signNames[index],
                      signSymbol: _signs[index],
                      color: _getSavColor(v),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveAshtakavargaCell extends StatefulWidget {
  final int value;
  final String signName;
  final String signSymbol;
  final String planetName;
  final Color color;
  final String type;

  const _InteractiveAshtakavargaCell({
    required this.value,
    required this.signName,
    required this.signSymbol,
    required this.planetName,
    required this.color,
    required this.type,
  });

  @override
  State<_InteractiveAshtakavargaCell> createState() =>
      _InteractiveAshtakavargaCellState();
}

class _InteractiveAshtakavargaCellState
    extends State<_InteractiveAshtakavargaCell> {
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
          _getAshtakavargaInsight(
            '${widget.signSymbol} ${widget.signName}',
            widget.value,
            'BAV',
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: _isPressed ? 24 : 20,
          height: _isPressed ? 24 : 20,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(_isPressed ? 6 : 4),
            boxShadow:
                _isPressed
                    ? [
                      BoxShadow(
                        color: widget.color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ]
                    : null,
          ),
          child: Center(
            child: Text(
              '${widget.value}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: _isPressed ? 10 : 9,
                fontWeight: FontWeight.w600,
                color: widget.value >= 4 ? Colors.white : _Colors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InteractiveSavCell extends StatefulWidget {
  final int value;
  final String signName;
  final String signSymbol;
  final Color color;

  const _InteractiveSavCell({
    required this.value,
    required this.signName,
    required this.signSymbol,
    required this.color,
  });

  @override
  State<_InteractiveSavCell> createState() => _InteractiveSavCellState();
}

class _InteractiveSavCellState extends State<_InteractiveSavCell> {
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
          _getAshtakavargaInsight(
            '${widget.signSymbol} ${widget.signName}',
            widget.value,
            'SAV',
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: _isPressed ? 26 : 22,
          height: _isPressed ? 26 : 22,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(_isPressed ? 6 : 4),
            boxShadow:
                _isPressed
                    ? [
                      BoxShadow(
                        color: widget.color.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ]
                    : null,
          ),
          child: Center(
            child: Text(
              '${widget.value}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: _isPressed ? 10 : 9,
                fontWeight: FontWeight.w700,
                color: widget.value >= 28 ? Colors.white : _Colors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

/// Planet colors based on actual image visual palette (matching details_tab.dart)
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

/// Get planet image path for premium visuals
String _getPlanetImagePath(String planet) {
  return 'assets/images/planets/${planet.toLowerCase()}.png';
}

/// Get zodiac sign color based on the visual palette from images
Color _getZodiacColor(String sign) {
  const colors = {
    'Aries': Color(0xFFD4A84B),
    'Taurus': Color(0xFF4ECDC4),
    'Gemini': Color(0xFFE85A6B),
    'Cancer': Color(0xFFB794F6),
    'Leo': Color(0xFFE07B4C),
    'Virgo': Color(0xFFF5A6C4),
    'Libra': Color(0xFF6BCB77),
    'Scorpio': Color(0xFFD9652B),
    'Sagittarius': Color(0xFFE040FB),
    'Capricorn': Color(0xFFB8956B),
    'Aquarius': Color(0xFF40E0D0),
    'Pisces': Color(0xFF64B5F6),
  };
  return colors[sign] ?? const Color(0xFFA09CAC);
}
