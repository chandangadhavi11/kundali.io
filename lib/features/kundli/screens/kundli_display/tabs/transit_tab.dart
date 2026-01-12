import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import 'package:kundali_app/l10n/generated/app_localizations.dart';
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
  static const double space12 = 12;
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
  static const Color surface = Color(0xFF16141F);

  // Borders
  static const Color border = Color(0xFF2A2838);

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
  static const Color cyan = Color(0xFF22D3EE);
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
                      AppLocalizations.of(context).insight_whatThisMeans,
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
                                  AppLocalizations.of(context).insight_significance,
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
                        AppLocalizations.of(context).insight_keyPoints,
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
InsightData _getTransitOverviewInsight(
  int favorableCount,
  int challengingCount,
  String moonSign,
  AppLocalizations l10n,
) {
  final balance = favorableCount - challengingCount;
  final localizedMoonSign = _getLocalizedZodiacSign(moonSign, l10n);
  final balanceStatus =
      balance >= 3
          ? l10n.transit_veryFavorable
          : balance >= 1
          ? l10n.transit_favorable
          : balance >= -1
          ? l10n.transit_balance_mixed
          : l10n.transit_challenging;
  final color =
      balance >= 3
          ? _Colors.emerald
          : balance >= 0
          ? _Colors.sky
          : balance >= -2
          ? _Colors.amber
          : _Colors.coral;

  return InsightData(
    title: l10n.transit_insight_overview_title,
    value: balanceStatus,
    description: l10n.transit_insight_overview_desc,
    significance: l10n.transit_insight_overview_significance(
      favorableCount.toString(),
      challengingCount.toString(),
      localizedMoonSign,
    ),
    keyPoints: [
      l10n.transit_insight_overview_keypoint1(favorableCount.toString()),
      l10n.transit_insight_overview_keypoint2(challengingCount.toString()),
      l10n.transit_insight_overview_keypoint3(balanceStatus),
      l10n.transit_insight_overview_keypoint4(localizedMoonSign),
      l10n.transit_insight_overview_keypoint5,
      l10n.transit_insight_overview_keypoint6,
    ],
    accentColor: color,
    icon: Icons.sync_alt_rounded,
  );
}

InsightData _getGocharInsight(String moonSign, AppLocalizations l10n) {
  final localizedMoonSign = _getLocalizedZodiacSign(moonSign, l10n);
  return InsightData(
    title: l10n.transit_insight_gochar_title,
    value: l10n.transit_insight_gochar_value,
    description: l10n.transit_insight_gochar_desc,
    significance: l10n.transit_insight_gochar_significance(localizedMoonSign),
    keyPoints: [
      l10n.transit_insight_gochar_keypoint1(localizedMoonSign),
      l10n.transit_insight_gochar_keypoint2,
      l10n.transit_insight_gochar_keypoint3,
      l10n.transit_insight_gochar_keypoint4,
      l10n.transit_insight_gochar_keypoint5,
      l10n.transit_insight_gochar_keypoint6,
    ],
    accentColor: _Colors.rose,
    icon: Icons.radar_rounded,
  );
}

InsightData _getTransitPlanetInsight(TransitData transit, AppLocalizations l10n) {
  final planetColor = _getPlanetColor(transit.planet);
  final isSlow = ['Saturn', 'Jupiter', 'Rahu', 'Ketu'].contains(transit.planet);
  final localizedPlanet = _getLocalizedPlanetName(transit.planet, l10n);
  final localizedSign = _getLocalizedZodiacSign(transit.currentSign, l10n);
  final ordinalSuffix = _getOrdinalSuffix(transit.transitHouse);

  return InsightData(
    title: l10n.transit_insight_planet_title,
    value: l10n.transit_insight_planet_value(localizedPlanet, transit.transitHouse.toString()),
    description:
        '$localizedPlanet ${l10n.transit_is} currently transiting $localizedSign at ${transit.currentDegree.toStringAsFixed(1)}°, which is the ${transit.transitHouse}$ordinalSuffix house from your Moon sign. ${transit.isFavorable ? l10n.transit_insight_favorable_position : l10n.transit_insight_attention_position}',
    significance:
        transit.effects.isNotEmpty
            ? transit.effects
            : '$localizedPlanet in the ${transit.transitHouse}$ordinalSuffix house ${transit.isFavorable ? l10n.transit_insight_supports_growth : l10n.transit_insight_requires_patience}.',
    keyPoints: [
      '${l10n.transit_planet_label}: $localizedPlanet',
      '${l10n.transit_sign_label}: $localizedSign',
      '${l10n.transit_degree_label}: ${transit.currentDegree.toStringAsFixed(1)}°',
      l10n.transit_houseFromMoon(transit.transitHouse.toString()),
      '${l10n.transit_status_label}: ${transit.isFavorable ? "${l10n.transit_favorable} ✓" : "${l10n.transit_challenging} ⚠"}',
      if (transit.aspectToNatal != 'None')
        '${l10n.transit_aspectToNatal}: ${transit.aspectToNatal}',
      if (isSlow)
        '${l10n.transit_major}: $localizedPlanet ${l10n.transit_movesSlow}, ${l10n.transit_effectsLast} ${transit.planet == "Saturn"
            ? "~2.5 ${l10n.transit_years}"
            : transit.planet == "Jupiter"
            ? "~1 ${l10n.transit_year}"
            : "~1.5 ${l10n.transit_years}"} ${l10n.transit_perSign}',
    ],
    accentColor: planetColor,
    icon: Icons.explore_rounded,
  );
}

InsightData _getGocharHouseInsight(
  int house,
  List<String> planets,
  bool isFavorable,
  bool isMoonHouse,
  AppLocalizations l10n,
) {
  String _getHouseSignifications(int h) {
    switch (h) {
      case 1: return l10n.transit_house_1_significations;
      case 2: return l10n.transit_house_2_significations;
      case 3: return l10n.transit_house_3_significations;
      case 4: return l10n.transit_house_4_significations;
      case 5: return l10n.transit_house_5_significations;
      case 6: return l10n.transit_house_6_significations;
      case 7: return l10n.transit_house_7_significations;
      case 8: return l10n.transit_house_8_significations;
      case 9: return l10n.transit_house_9_significations;
      case 10: return l10n.transit_house_10_significations;
      case 11: return l10n.transit_house_11_significations;
      case 12: return l10n.transit_house_12_significations;
      default: return '';
    }
  }

  final significations = _getHouseSignifications(house);
  final localizedPlanets = planets.map((p) => _getLocalizedPlanetName(p, l10n)).toList();
  
  final color =
      isMoonHouse
          ? _Colors.violet
          : isFavorable
          ? _Colors.emerald
          : _Colors.amber;

  final description = isMoonHouse
      ? l10n.transit_insight_house_desc_moonHouse(house.toString(), significations)
      : isFavorable
      ? l10n.transit_insight_house_desc_favorable(house.toString(), significations)
      : l10n.transit_insight_house_desc_challenging(house.toString(), significations);

  final significance = planets.isEmpty
      ? l10n.transit_insight_house_significance_empty
      : l10n.transit_insight_house_significance_planets(
          localizedPlanets.join(", "),
          planets.length == 1 ? l10n.transit_is : l10n.transit_are,
          isFavorable ? l10n.transit_supporting : l10n.transit_influencing,
          significations.split(",").first,
        );

  return InsightData(
    title: l10n.transit_insight_house_title,
    value: isMoonHouse
        ? l10n.transit_insight_house_value_moon(house.toString())
        : l10n.transit_insight_house_value(house.toString()),
    description: description,
    significance: significance,
    keyPoints: [
      l10n.transit_insight_house_keypoint1(house.toString()),
      l10n.transit_insight_house_keypoint2(significations),
      if (isMoonHouse) l10n.transit_insight_house_keypoint3,
      isFavorable
          ? l10n.transit_insight_house_keypoint4_favorable
          : l10n.transit_insight_house_keypoint4_challenging,
      l10n.transit_insight_house_keypoint5(
          localizedPlanets.isEmpty ? l10n.transit_none : localizedPlanets.join(", ")),
    ],
    accentColor: color,
    icon: Icons.home_work_rounded,
  );
}

InsightData _getSadeSatiInsight(Map<String, dynamic> info, AppLocalizations l10n) {
  final phase = info['phaseNumber'] ?? 0;
  
  String _getPhaseName(int p) {
    switch (p) {
      case 1: return l10n.transit_phase_rising;
      case 2: return l10n.transit_phase_peak;
      case 3: return l10n.transit_phase_setting;
      default: return '';
    }
  }
  
  final phaseName = _getPhaseName(phase);
  final localizedSaturnSign = info['saturnSign'] != null 
      ? _getLocalizedZodiacSign(info['saturnSign'], l10n) 
      : '';
  final localizedMoonSign = info['moonSign'] != null 
      ? _getLocalizedZodiacSign(info['moonSign'], l10n) 
      : '';

  return InsightData(
    title: l10n.transit_insight_sadesati_title,
    value: phase > 0 ? l10n.transit_insight_sadesati_value_active(phaseName) : l10n.transit_insight_sadesati_value_inactive,
    description: l10n.transit_insight_sadesati_desc,
    significance: phase > 0
        ? l10n.transit_insight_sadesati_significance_active(
            info['description'] ?? '',
            localizedSaturnSign,
            (info['saturnDegree'] as double?)?.toStringAsFixed(1) ?? '',
          )
        : l10n.transit_insight_sadesati_significance_inactive(localizedMoonSign),
    keyPoints: [
      l10n.transit_insight_sadesati_keypoint1,
      l10n.transit_insight_sadesati_keypoint2,
      l10n.transit_insight_sadesati_keypoint3,
      l10n.transit_insight_sadesati_keypoint4,
      if (phase > 0) l10n.transit_insight_sadesati_keypoint5(phaseName),
      if (phase > 0) l10n.transit_insight_sadesati_keypoint6(localizedSaturnSign),
      l10n.transit_insight_sadesati_keypoint7,
    ],
    accentColor: _Colors.coral,
    icon: Icons.hourglass_bottom_rounded,
  );
}

InsightData _getCurrentSkyInsight(AppLocalizations l10n) {
  return InsightData(
    title: l10n.transit_currentSky_title,
    value: l10n.transit_currentSky_value,
    description: l10n.transit_currentSky_desc,
    significance: l10n.transit_currentSky_significance,
    keyPoints: [
      l10n.transit_currentSky_keypoint1,
      l10n.transit_currentSky_keypoint2,
      l10n.transit_currentSky_keypoint3,
      l10n.transit_currentSky_keypoint4,
      l10n.transit_currentSky_keypoint5,
      l10n.transit_currentSky_keypoint6,
      l10n.transit_currentSky_keypoint7,
    ],
    accentColor: _Colors.violet,
    icon: Icons.nights_stay_rounded,
  );
}

String _getOrdinalSuffix(int number) {
  if (number >= 11 && number <= 13) return 'th';
  switch (number % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NAVIGATION SECTION DATA
// ═══════════════════════════════════════════════════════════════════════════
const _sectionIds = ['overview', 'sky', 'gochar', 'effects', 'sadesati'];
const _sectionColors = [_Colors.cyan, _Colors.violet, _Colors.rose, _Colors.emerald, _Colors.coral];

List<NavSection> _getSections(AppLocalizations l10n) => [
  NavSection(id: 'overview', label: l10n.transit_nav_overview, color: _Colors.cyan),
  NavSection(id: 'sky', label: l10n.transit_nav_sky, color: _Colors.violet),
  NavSection(id: 'gochar', label: l10n.transit_nav_gochar, color: _Colors.rose),
  NavSection(id: 'effects', label: l10n.transit_nav_effects, color: _Colors.emerald),
  NavSection(id: 'sadesati', label: l10n.transit_nav_sadesati, color: _Colors.coral),
];

/// Transit Tab - Shows current planetary transits (Gochar)
/// Premium, elegant UI with clear visual hierarchy
class TransitTab extends StatefulWidget {
  final KundaliData kundaliData;

  const TransitTab({super.key, required this.kundaliData});

  @override
  State<TransitTab> createState() => _TransitTabState();
}

class _TransitTabState extends State<TransitTab> {
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

    for (final id in _sectionIds) {
      _sectionKeys[id] = GlobalKey();
      _animatedKeys[id] = GlobalKey<_AnimatedSectionWrapperState>();
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
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    // Get real-time planetary positions
    final currentPositions = _getCurrentTransitPositions();

    // Calculate transit effects from Moon sign
    final transits = KundaliCalculationService.calculateTransits(
      widget.kundaliData.planetPositions,
      currentPositions,
      widget.kundaliData.moonSign,
    );

    // Calculate Sade Sati status
    final sadeSatiInfo = _calculateSadeSati(
      currentPositions,
      widget.kundaliData.moonSign,
    );

    // Calculate transit house from Moon
    final transitHouses = _calculateTransitHousesFromMoon(
      currentPositions,
      widget.kundaliData.moonSign,
    );

    // Count favorable vs unfavorable transits
    final favorableCount = transits.values.where((t) => t.isFavorable).length;
    final challengingCount = transits.values.length - favorableCount;

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
                accentColor: _Colors.cyan,
                child: _AnimatedCardWrapper(
                  child: _TransitHeroCard(
                    now: now,
                    moonSign: widget.kundaliData.moonSign,
                    favorableCount: favorableCount,
                    challengingCount: challengingCount,
                    sadeSatiInfo: sadeSatiInfo,
                  ),
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // ═══════════════════════════════════════════════════════════════
              // CURRENT SKY POSITIONS
              // ═══════════════════════════════════════════════════════════════
              _AnimatedSectionWrapper(
                key: _animatedKeys['sky'],
                sectionKey: _sectionKeys['sky']!,
                accentColor: _Colors.violet,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: l10n.transit_currentSky_title,
                      subtitle: l10n.transit_currentSky_subtitle,
                      accentColor: _Colors.violet,
                      trailing: _LiveIndicator(),
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: _CurrentPositionsCard(
                        positions: currentPositions,
                        natalPositions: widget.kundaliData.planetPositions,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // ═══════════════════════════════════════════════════════════════
              // GOCHAR GRID
              // ═══════════════════════════════════════════════════════════════
              _AnimatedSectionWrapper(
                key: _animatedKeys['gochar'],
                sectionKey: _sectionKeys['gochar']!,
                accentColor: _Colors.rose,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: l10n.transit_gochar_title,
                      subtitle: l10n.transit_gochar_subtitle(widget.kundaliData.moonSign),
                      accentColor: _Colors.rose,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: _GocharLegend(
                        moonSign: widget.kundaliData.moonSign,
                      ),
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 100,
                      child: _GocharGrid(
                        transitHouses: transitHouses,
                        moonSign: widget.kundaliData.moonSign,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // ═══════════════════════════════════════════════════════════════
              // TRANSIT EFFECTS
              // ═══════════════════════════════════════════════════════════════
              _AnimatedSectionWrapper(
                key: _animatedKeys['effects'],
                sectionKey: _sectionKeys['effects']!,
                accentColor: _Colors.emerald,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: l10n.transit_effects_title,
                      subtitle: l10n.transit_effects_subtitle,
                      accentColor: _Colors.emerald,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    ...transits.entries.toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final transitEntry = entry.value;
                      return _AnimatedCardWrapper(
                        delay: 50 + (index * 30),
                        child: _PremiumTransitCard(
                          transit: transitEntry.value,
                          natalPosition:
                              widget.kundaliData.planetPositions[transitEntry
                                  .key],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // ═══════════════════════════════════════════════════════════════
              // SADE SATI (if active)
              // ═══════════════════════════════════════════════════════════════
              _AnimatedSectionWrapper(
                key: _animatedKeys['sadesati'],
                sectionKey: _sectionKeys['sadesati']!,
                accentColor: _Colors.coral,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (sadeSatiInfo['isActive'] == true) ...[
                      const SizedBox(height: _DesignTokens.space24),
                      _AnimatedSectionHeader(
                        title: l10n.transit_sadesati_title,
                        subtitle: l10n.transit_sadesati_subtitle,
                        accentColor: _Colors.coral,
                      ),
                      const SizedBox(height: _DesignTokens.space12),
                      _AnimatedCardWrapper(
                        delay: 50,
                        child: _SadeSatiCard(sadeSatiInfo: sadeSatiInfo),
                      ),
                    ] else ...[
                      const SizedBox(height: _DesignTokens.space24),
                      _AnimatedCardWrapper(
                        child: _SadeSatiInactiveCard(
                          moonSign: widget.kundaliData.moonSign,
                        ),
                      ),
                    ],
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
            sections: _getSections(l10n),
            activeIndex: _activeIndex,
            onTap: _scrollToSection,
          ),
        ),
      ],
    );
  }

  Map<String, PlanetPosition> _getCurrentTransitPositions() {
    try {
      final now = DateTime.now();
      final result = KundaliCalculationService.calculateAll(
        birthDateTime: now,
        latitude: widget.kundaliData.latitude,
        longitude: widget.kundaliData.longitude,
        timezone: widget.kundaliData.timezone,
      );
      return result.planetPositions;
    } catch (e) {
      debugPrint('Transit calculation error: $e');
      return widget.kundaliData.planetPositions;
    }
  }

  Map<String, dynamic> _calculateSadeSati(
    Map<String, PlanetPosition> currentPositions,
    String moonSign,
  ) {
    final saturnPos = currentPositions['Saturn'];
    if (saturnPos == null) {
      return {'isActive': false};
    }

    final signs = [
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
    final moonIndex = signs.indexOf(moonSign);
    final saturnIndex = signs.indexOf(saturnPos.sign);

    if (moonIndex == -1 || saturnIndex == -1) {
      return {'isActive': false};
    }

    int relativePos = (saturnIndex - moonIndex + 12) % 12;

    String phase = '';
    bool isActive = false;
    String description = '';
    int phaseNumber = 0;

    if (relativePos == 11) {
      isActive = true;
      phase = 'Rising (1st Phase)';
      phaseNumber = 1;
      description =
          'Saturn transiting 12th from Moon. Beginning of 7.5 year cycle. Increased expenses, travel, and mental stress possible.';
    } else if (relativePos == 0) {
      isActive = true;
      phase = 'Peak (2nd Phase)';
      phaseNumber = 2;
      description =
          'Saturn transiting over Moon sign. Most intense period. Health, emotions, and relationships may face challenges.';
    } else if (relativePos == 1) {
      isActive = true;
      phase = 'Setting (3rd Phase)';
      phaseNumber = 3;
      description =
          'Saturn transiting 2nd from Moon. Final phase. Financial matters, family, and speech may be affected.';
    }

    return {
      'isActive': isActive,
      'phase': phase,
      'phaseNumber': phaseNumber,
      'description': description,
      'saturnSign': saturnPos.sign,
      'saturnDegree': saturnPos.signDegree,
      'moonSign': moonSign,
    };
  }

  Map<String, int> _calculateTransitHousesFromMoon(
    Map<String, PlanetPosition> positions,
    String moonSign,
  ) {
    final signs = [
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
    final moonIndex = signs.indexOf(moonSign);

    final transitHouses = <String, int>{};

    for (final entry in positions.entries) {
      final planetSign = entry.value.sign;
      final planetIndex = signs.indexOf(planetSign);
      if (planetIndex != -1 && moonIndex != -1) {
        final house = ((planetIndex - moonIndex + 12) % 12) + 1;
        transitHouses[entry.key] = house;
      }
    }

    return transitHouses;
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
  final Widget? trailing;

  const _AnimatedSectionHeader({
    required this.title,
    this.subtitle,
    required this.accentColor,
    this.trailing,
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
          child: Row(
            children: [
              Expanded(
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
                        final maxWidth = math.min(
                          constraints.maxWidth * 0.3,
                          40.0,
                        );
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
              ),
              if (widget.trailing != null) widget.trailing!,
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
// LIVE INDICATOR
// ═══════════════════════════════════════════════════════════════════════════
class _LiveIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _Colors.emerald.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _Colors.emerald.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: _Colors.emerald,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            l10n.transit_live,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: _Colors.emerald,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TRANSIT HERO CARD - Minimal Elegant Design
// ═══════════════════════════════════════════════════════════════════════════
class _TransitHeroCard extends StatefulWidget {
  final DateTime now;
  final String moonSign;
  final int favorableCount;
  final int challengingCount;
  final Map<String, dynamic> sadeSatiInfo;

  const _TransitHeroCard({
    required this.now,
    required this.moonSign,
    required this.favorableCount,
    required this.challengingCount,
    required this.sadeSatiInfo,
  });

  @override
  State<_TransitHeroCard> createState() => _TransitHeroCardState();
}

class _TransitHeroCardState extends State<_TransitHeroCard> {
  bool _isPressed = false;

  Color _getBalanceColor(int balance) {
    if (balance >= 3) return _Colors.emerald;
    if (balance >= 0) return _Colors.sky;
    if (balance >= -2) return _Colors.amber;
    return _Colors.coral;
  }

  String _getBalanceStatus(int balance, AppLocalizations l10n) {
    if (balance >= 3) return l10n.transit_balance_excellent;
    if (balance >= 1) return l10n.transit_balance_good;
    if (balance >= -1) return l10n.transit_balance_mixed;
    if (balance >= -3) return l10n.transit_balance_tough;
    return l10n.transit_balance_difficult;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateStr = DateFormat('dd MMM yyyy').format(widget.now);
    final timeStr = DateFormat('HH:mm').format(widget.now);
    final overallBalance = widget.favorableCount - widget.challengingCount;
    final balanceStatus = _getBalanceStatus(overallBalance, l10n);
    final balanceColor = _getBalanceColor(overallBalance);
    final moonSignColor = _getZodiacColor(widget.moonSign);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        final l10n = AppLocalizations.of(context);
        _showInsightSheet(
          context,
          _getTransitOverviewInsight(
            widget.favorableCount,
            widget.challengingCount,
            widget.moonSign,
            l10n,
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFF1A1820) : const Color(0xFF141218),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with balance score and title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Minimal balance indicator
                _MinimalBalanceIndicator(
                  balance: overallBalance,
                  color: balanceColor,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status + Title row
                      Row(
                        children: [
                          Text(
                            balanceStatus,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: balanceColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: balanceColor.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            l10n.transit_overview,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6A6778),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Favorable/Challenging inline stats
                      Row(
                        children: [
                          _MinimalTransitStat(
                            value: widget.favorableCount,
                            label: l10n.transit_favorable,
                            color: _Colors.emerald,
                            isPositive: true,
                          ),
                          const SizedBox(width: 16),
                          _MinimalTransitStat(
                            value: widget.challengingCount,
                            label: l10n.transit_challenging,
                            color: _Colors.coral,
                            isPositive: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Subtle info icon
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: _isPressed ? 1.0 : 0.4,
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Color(0xFF6A6778),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Date/Time & Moon Sign row - Cleaner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0D14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Date & Time combined
                  Text(
                    '$dateStr  ·  $timeStr',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7C7889),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  // Moon Sign with zodiac image
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: moonSignColor.withOpacity(0.2),
                          blurRadius: 4,
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                        _getZodiacImagePath(widget.moonSign),
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              color: moonSignColor.withOpacity(0.15),
                              child: Center(
                                child: Text(
                                  _getSignSymbol(widget.moonSign),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: moonSignColor,
                                  ),
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getLocalizedZodiacSign(widget.moonSign, l10n),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: moonSignColor,
                    ),
                  ),
                ],
              ),
            ),

            // Sade Sati warning - Minimal
            if (widget.sadeSatiInfo['isActive'] == true) ...[
              const SizedBox(height: 10),
              _MinimalSadeSatiBanner(sadeSatiInfo: widget.sadeSatiInfo),
            ],
          ],
        ),
      ),
    );
  }
}

// Minimal Balance Indicator - Replaces circular gauge
class _MinimalBalanceIndicator extends StatelessWidget {
  final int balance;
  final Color color;

  const _MinimalBalanceIndicator({required this.balance, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            balance >= 0
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            size: 14,
            color: color.withOpacity(0.7),
          ),
          const SizedBox(height: 2),
          Text(
            balance >= 0 ? '+$balance' : '$balance',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Minimal Transit Stat - Inline favorable/challenging count
class _MinimalTransitStat extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  final bool isPositive;

  const _MinimalTransitStat({
    required this.value,
    required this.label,
    required this.color,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$value',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6A6778),
          ),
        ),
      ],
    );
  }
}

// Minimal Sade Sati Banner
class _MinimalSadeSatiBanner extends StatefulWidget {
  final Map<String, dynamic> sadeSatiInfo;

  const _MinimalSadeSatiBanner({required this.sadeSatiInfo});

  @override
  State<_MinimalSadeSatiBanner> createState() => _MinimalSadeSatiBannerState();
}

class _MinimalSadeSatiBannerState extends State<_MinimalSadeSatiBanner> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phase = widget.sadeSatiInfo['phaseNumber'] ?? 2;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        final l10n = AppLocalizations.of(context);
        _showInsightSheet(context, _getSadeSatiInsight(widget.sadeSatiInfo, l10n));
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color:
              _isPressed
                  ? _Colors.coral.withOpacity(0.12)
                  : _Colors.coral.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Subtle warning icon
            Icon(
              Icons.error_outline_rounded,
              size: 14,
              color: _Colors.coral.withOpacity(_isPressed ? 1.0 : 0.7),
            ),
            const SizedBox(width: 10),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.transit_sadesati_active,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _Colors.coral,
                    ),
                  ),
                  Text(
                    '${widget.sadeSatiInfo['phase']}',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: const Color(0xFF6A6778),
                    ),
                  ),
                ],
              ),
            ),
            // Phase indicators
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final isActive = index < phase;
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? _Colors.coral
                            : _Colors.coral.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 14,
              color: _Colors.coral.withOpacity(_isPressed ? 1.0 : 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveSadeSatiBanner extends StatefulWidget {
  final Map<String, dynamic> sadeSatiInfo;

  const _InteractiveSadeSatiBanner({required this.sadeSatiInfo});

  @override
  State<_InteractiveSadeSatiBanner> createState() =>
      _InteractiveSadeSatiBannerState();
}

class _InteractiveSadeSatiBannerState
    extends State<_InteractiveSadeSatiBanner> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        final l10n = AppLocalizations.of(context);
        _showInsightSheet(context, _getSadeSatiInsight(widget.sadeSatiInfo, l10n));
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _Colors.coral.withOpacity(_isPressed ? 0.2 : 0.12),
              _Colors.coral.withOpacity(_isPressed ? 0.1 : 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(_DesignTokens.radiusMd),
          border: Border.all(
            color: _Colors.coral.withOpacity(_isPressed ? 0.4 : 0.25),
            width: _isPressed ? 1 : 0.5,
          ),
          boxShadow:
              _isPressed
                  ? [
                    BoxShadow(
                      color: _Colors.coral.withOpacity(0.15),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _Colors.coral.withOpacity(_isPressed ? 0.25 : 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: _Colors.coral,
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
                        'Sade Sati Active',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _Colors.coral,
                        ),
                      ),
                      const Spacer(),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: _isPressed ? 1.0 : 0.5,
                        child: Text(
                          'Tap for details',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            color: _Colors.coral,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${widget.sadeSatiInfo['phase']}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: _Colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            _SadeSatiPhaseIndicator(
              phase: widget.sadeSatiInfo['phaseNumber'] ?? 0,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// COMPACT BALANCE GAUGE - Refined circular gauge
// ═══════════════════════════════════════════════════════════════════════════
class _CompactBalanceGauge extends StatefulWidget {
  final int balance;
  final Color color;

  const _CompactBalanceGauge({required this.balance, required this.color});

  @override
  State<_CompactBalanceGauge> createState() => _CompactBalanceGaugeState();
}

class _CompactBalanceGaugeState extends State<_CompactBalanceGauge>
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

    // Normalize balance to 0-1 range (balance ranges from -12 to +12)
    final normalizedValue = ((widget.balance + 12) / 24).clamp(0.0, 1.0);

    _progressAnim = Tween<double>(begin: 0, end: normalizedValue).animate(
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
                  value: _progressAnim.value,
                  strokeWidth: 4,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.balance >= 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 14,
                    color: widget.color,
                  ),
                  Text(
                    widget.balance >= 0
                        ? '+${widget.balance}'
                        : '${widget.balance}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: widget.color,
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
// TRANSIT STAT BADGE - Compact favorable/challenging indicator
// ═══════════════════════════════════════════════════════════════════════════
class _TransitStatBadge extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  const _TransitStatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            '$value',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveBalanceGauge extends StatefulWidget {
  final int balance;
  final int favorable;
  final int challenging;

  const _InteractiveBalanceGauge({
    required this.balance,
    required this.favorable,
    required this.challenging,
  });

  @override
  State<_InteractiveBalanceGauge> createState() =>
      _InteractiveBalanceGaugeState();
}

class _InteractiveBalanceGaugeState extends State<_InteractiveBalanceGauge>
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
    final color = widget.balance >= 0 ? _Colors.emerald : _Colors.coral;

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
                color.withOpacity(0.25 * _pulseAnimation.value),
                color.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: color.withOpacity(0.4 + 0.1 * _pulseAnimation.value),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15 * _pulseAnimation.value),
                blurRadius: 16,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.balance >= 0
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: 24,
                color: color,
              ),
              Text(
                widget.balance >= 0
                    ? '+${widget.balance}'
                    : '${widget.balance}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InteractiveStatBadge extends StatefulWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  const _InteractiveStatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  State<_InteractiveStatBadge> createState() => _InteractiveStatBadgeState();
}

class _InteractiveStatBadgeState extends State<_InteractiveStatBadge> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        final isFavorable = widget.label == l10n.transit_favorable || widget.label == 'Favorable';
        _showInsightSheet(
          context,
          InsightData(
            title: l10n.transit_insight_transitCount_title(widget.label),
            value: l10n.transit_insight_transitCount_value(widget.value.toString()),
            description: isFavorable
                ? l10n.transit_insight_transitCount_desc_favorable
                : l10n.transit_insight_transitCount_desc_challenging,
            significance: l10n.transit_insight_transitCount_significance(
              widget.value.toString(),
              widget.label.toLowerCase(),
            ),
            keyPoints: [
              l10n.transit_insight_transitCount_keypoint1(widget.value.toString()),
              l10n.transit_insight_transitCount_keypoint2(widget.label),
              isFavorable
                  ? l10n.transit_insight_transitCount_keypoint3_favorable
                  : l10n.transit_insight_transitCount_keypoint3_challenging,
              l10n.transit_insight_transitCount_keypoint4,
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
            const SizedBox(width: 6),
            Text(
              '${widget.value}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: widget.color,
              ),
            ),
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
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String? label;
  final Color color;
  final bool isHighlighted;

  const _InfoChip({
    required this.icon,
    required this.value,
    this.label,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null)
              Text(
                label!,
                style: GoogleFonts.inter(
                  fontSize: 8,
                  color: _Colors.textTertiary.withOpacity(0.7),
                ),
              ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: isHighlighted ? 12 : 11,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                color: isHighlighted ? color : _Colors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: _Colors.border.withOpacity(0.3),
    );
  }
}

class _SadeSatiPhaseIndicator extends StatelessWidget {
  final int phase;

  const _SadeSatiPhaseIndicator({required this.phase});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final isActive = i < phase;
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: isActive ? _Colors.coral : _Colors.coral.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CURRENT POSITIONS CARD - Interactive
// ═══════════════════════════════════════════════════════════════════════════
class _CurrentPositionsCard extends StatefulWidget {
  final Map<String, PlanetPosition> positions;
  final Map<String, PlanetPosition> natalPositions;

  const _CurrentPositionsCard({
    required this.positions,
    required this.natalPositions,
  });

  @override
  State<_CurrentPositionsCard> createState() => _CurrentPositionsCardState();
}

class _CurrentPositionsCardState extends State<_CurrentPositionsCard> {
  bool _headerPressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vedicPlanets = [
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _Colors.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(_DesignTokens.radiusLg),
        border: Border.all(color: _Colors.border.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        children: [
          // Header - Interactive
          GestureDetector(
            onTapDown: (_) => setState(() => _headerPressed = true),
            onTapUp: (_) {
              setState(() => _headerPressed = false);
              HapticFeedback.selectionClick();
              _showInsightSheet(context, _getCurrentSkyInsight(l10n));
            },
            onTapCancel: () => setState(() => _headerPressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color:
                    _headerPressed
                        ? _Colors.violet.withOpacity(0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    l10n.transit_planet_header,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _Colors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _headerPressed ? 1.0 : 0.5,
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 12,
                      color: _Colors.violet,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l10n.transit_current_header,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _Colors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 40),
                  Text(
                    l10n.transit_natal_header,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _Colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: _Colors.border.withOpacity(0.2), height: 1),
          const SizedBox(height: 8),
          // Planets - Interactive rows
          ...vedicPlanets.map((planet) {
            final pos = widget.positions[planet];
            final natalPos = widget.natalPositions[planet];
            if (pos == null) return const SizedBox();

            return _InteractiveSkyPlanetRow(
              planet: planet,
              currentPos: pos,
              natalPos: natalPos,
            );
          }),
        ],
      ),
    );
  }
}

class _InteractiveSkyPlanetRow extends StatefulWidget {
  final String planet;
  final PlanetPosition currentPos;
  final PlanetPosition? natalPos;

  const _InteractiveSkyPlanetRow({
    required this.planet,
    required this.currentPos,
    this.natalPos,
  });

  @override
  State<_InteractiveSkyPlanetRow> createState() =>
      _InteractiveSkyPlanetRowState();
}

class _InteractiveSkyPlanetRowState extends State<_InteractiveSkyPlanetRow> {
  bool _isPressed = false;

  String _getPlanetImagePath(String planet) {
    return 'assets/images/planets/${planet.toLowerCase()}.png';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final signChanged =
        widget.natalPos != null &&
        widget.natalPos!.sign != widget.currentPos.sign;
    final planetColor = _getPlanetColor(widget.planet);
    final isSlow = [
      'Saturn',
      'Jupiter',
      'Rahu',
      'Ketu',
    ].contains(widget.planet);
    final currentSignColor = _getZodiacColor(widget.currentPos.sign);
    final natalSignColor =
        widget.natalPos != null
            ? _getZodiacColor(widget.natalPos!.sign)
            : currentSignColor;
    final localizedPlanetName = _getLocalizedPlanetName(widget.planet, l10n);
    final localizedSignCurrent = _getLocalizedZodiacSign(widget.currentPos.sign, l10n);
    // ignore: unused_local_variable
    final localizedSignNatal = widget.natalPos != null ? _getLocalizedZodiacSign(widget.natalPos!.sign, l10n) : localizedSignCurrent;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        
        final retroText = widget.currentPos.isRetrograde ? l10n.transit_insight_currentPosition_retro : '';
        final natalInfo = widget.natalPos != null 
            ? l10n.transit_insight_currentPosition_natalInfo(
                localizedPlanetName,
                widget.natalPos!.signDegree.toStringAsFixed(1),
                localizedSignNatal,
              )
            : '';
        
        String significance;
        if (signChanged) {
          significance = l10n.transit_insight_currentPosition_significance_changed(localizedPlanetName);
        } else if (widget.currentPos.sign == widget.natalPos?.sign) {
          significance = l10n.transit_insight_currentPosition_significance_same(localizedPlanetName);
        } else {
          significance = l10n.transit_insight_currentPosition_significance_transiting(localizedPlanetName);
        }
        if (isSlow) {
          significance += l10n.transit_insight_currentPosition_significance_slow;
        }
        
        final transitDuration = widget.planet == "Saturn"
            ? "~2.5 ${l10n.transit_years}"
            : widget.planet == "Jupiter"
            ? "~1 ${l10n.transit_year}"
            : "~1.5 ${l10n.transit_years}";
        
        _showInsightSheet(
          context,
          InsightData(
            title: l10n.transit_insight_currentPosition_title,
            value: localizedPlanetName,
            description: l10n.transit_insight_currentPosition_desc(
              localizedPlanetName,
              widget.currentPos.signDegree.toStringAsFixed(1),
              localizedSignCurrent,
              retroText,
              natalInfo,
            ),
            significance: significance,
            keyPoints: [
              l10n.transit_insight_currentPosition_keypoint1(localizedPlanetName),
              l10n.transit_insight_currentPosition_keypoint2(localizedSignCurrent, widget.currentPos.signDegree.toStringAsFixed(1)),
              if (widget.natalPos != null)
                l10n.transit_insight_currentPosition_keypoint3(localizedSignNatal, widget.natalPos!.signDegree.toStringAsFixed(1)),
              if (widget.currentPos.isRetrograde) l10n.transit_insight_currentPosition_keypoint4,
              if (signChanged) l10n.transit_insight_currentPosition_keypoint5,
              if (isSlow)
                l10n.transit_insight_currentPosition_keypoint6(transitDuration),
            ],
            accentColor: planetColor,
            icon: Icons.public_rounded,
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFF1A1820) : const Color(0xFF0F0D14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Planet image
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: planetColor.withOpacity(_isPressed ? 0.3 : 0.15),
                    blurRadius: _isPressed ? 10 : 6,
                    spreadRadius: -2,
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
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: planetColor.withOpacity(0.12),
                        child: Center(
                          child: Text(
                            _getPlanetSymbol(widget.planet),
                            style: TextStyle(fontSize: 16, color: planetColor),
                          ),
                        ),
                      ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Planet name and Major badge
            SizedBox(
              width: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedPlanetName,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (isSlow)
                    Text(
                      l10n.transit_major,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: _Colors.sky,
                      ),
                    ),
                ],
              ),
            ),

            const Spacer(),

            // Current position with sign image
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: currentSignColor.withOpacity(0.15),
                        blurRadius: 4,
                        spreadRadius: -1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      _getZodiacImagePath(widget.currentPos.sign),
                      width: 18,
                      height: 18,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            color: currentSignColor.withOpacity(0.15),
                            child: Center(
                              child: Text(
                                _getSignSymbol(widget.currentPos.sign),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: currentSignColor,
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${widget.currentPos.signDegree.toStringAsFixed(1)}°',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                if (widget.currentPos.isRetrograde) ...[
                  const SizedBox(width: 4),
                  Text(
                    'R',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _Colors.coral,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(width: 16),

            // Natal position with sign image
            if (widget.natalPos != null) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: natalSignColor.withOpacity(0.1),
                          blurRadius: 3,
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        _getZodiacImagePath(widget.natalPos!.sign),
                        width: 16,
                        height: 16,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              color: natalSignColor.withOpacity(0.1),
                              child: Center(
                                child: Text(
                                  _getSignSymbol(widget.natalPos!.sign),
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: natalSignColor,
                                  ),
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.natalPos!.signDegree.toStringAsFixed(1)}°',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: const Color(0xFF6A6778),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(width: 6),

            // Chevron
            AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: _isPressed ? 1.0 : 0.3,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: const Color(0xFF6A6778),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GOCHAR COMPONENTS - Minimal Elegant Design
// ═══════════════════════════════════════════════════════════════════════════
class _GocharLegend extends StatefulWidget {
  final String moonSign;

  const _GocharLegend({required this.moonSign});

  @override
  State<_GocharLegend> createState() => _GocharLegendState();
}

class _GocharLegendState extends State<_GocharLegend> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final moonSignColor = _getZodiacColor(widget.moonSign);
    final localizedMoonSign = _getLocalizedZodiacSign(widget.moonSign, l10n);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        final l10n = AppLocalizations.of(context);
        _showInsightSheet(context, _getGocharInsight(widget.moonSign, l10n));
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFF1A1820) : const Color(0xFF141218),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Moon sign indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: moonSignColor.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: -1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  _getZodiacImagePath(widget.moonSign),
                  width: 22,
                  height: 22,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: moonSignColor.withOpacity(0.15),
                        child: Center(
                          child: Text(
                            '☽',
                            style: TextStyle(
                              fontSize: 12,
                              color: moonSignColor,
                            ),
                          ),
                        ),
                      ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Legend text
            Expanded(
              child: Text(
                l10n.transit_houses_from(localizedMoonSign),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9A97A6),
                ),
              ),
            ),

            // Legend items
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _Colors.emerald,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '3,6,10,11',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: const Color(0xFF6A6778),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _Colors.violet,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.transit_legend_moon,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: const Color(0xFF6A6778),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: _isPressed ? 1.0 : 0.3,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: const Color(0xFF6A6778),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GocharGrid extends StatelessWidget {
  final Map<String, int> transitHouses;
  final String moonSign;

  const _GocharGrid({required this.transitHouses, required this.moonSign});

  @override
  Widget build(BuildContext context) {
    final houseGroups = <int, List<String>>{};
    for (int i = 1; i <= 12; i++) {
      houseGroups[i] = [];
    }
    transitHouses.forEach((planet, house) {
      houseGroups[house]?.add(planet);
    });

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0B12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Row 1: Houses 1-6
          Row(
            children: List.generate(
              6,
              (i) => Expanded(
                child: _InteractiveGocharCell(
                  house: i + 1,
                  planets: houseGroups[i + 1] ?? [],
                  isFavorable: _isFavorableHouse(i + 1),
                  isMoonHouse: i == 0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Row 2: Houses 7-12
          Row(
            children: List.generate(
              6,
              (i) => Expanded(
                child: _InteractiveGocharCell(
                  house: i + 7,
                  planets: houseGroups[i + 7] ?? [],
                  isFavorable: _isFavorableHouse(i + 7),
                  isMoonHouse: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isFavorableHouse(int house) {
    return [3, 6, 10, 11].contains(house);
  }
}

class _InteractiveGocharCell extends StatefulWidget {
  final int house;
  final List<String> planets;
  final bool isFavorable;
  final bool isMoonHouse;

  const _InteractiveGocharCell({
    required this.house,
    required this.planets,
    required this.isFavorable,
    required this.isMoonHouse,
  });

  @override
  State<_InteractiveGocharCell> createState() => _InteractiveGocharCellState();
}

class _InteractiveGocharCellState extends State<_InteractiveGocharCell> {
  bool _isPressed = false;

  String _getPlanetImagePath(String planet) {
    return 'assets/images/planets/${planet.toLowerCase()}.png';
  }

  @override
  Widget build(BuildContext context) {
    final accentColor =
        widget.isMoonHouse
            ? _Colors.violet
            : widget.isFavorable
            ? _Colors.emerald
            : const Color(0xFF4A4758);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        final l10n = AppLocalizations.of(context);
        _showInsightSheet(
          context,
          _getGocharHouseInsight(
            widget.house,
            widget.planets,
            widget.isFavorable,
            widget.isMoonHouse,
            l10n,
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFF1E1C24) : const Color(0xFF141218),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                widget.isMoonHouse || widget.isFavorable
                    ? accentColor.withOpacity(_isPressed ? 0.4 : 0.2)
                    : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // House number with indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.house}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        widget.isMoonHouse || widget.isFavorable
                            ? accentColor
                            : const Color(0xFF6A6778),
                  ),
                ),
                if (widget.isMoonHouse || widget.isFavorable) ...[
                  const SizedBox(width: 3),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),

            // Planet images or empty indicator
            SizedBox(
              height: 28,
              child:
                  widget.planets.isEmpty
                      ? Center(
                        child: Container(
                          width: 16,
                          height: 1,
                          color: const Color(0xFF2A2838),
                        ),
                      )
                      : widget.planets.length <= 2
                      // Show images for 1-2 planets
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            widget.planets.map((planet) {
                              final planetColor = _getPlanetColor(planet);
                              return Container(
                                width: 22,
                                height: 22,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: planetColor.withOpacity(
                                        _isPressed ? 0.3 : 0.15,
                                      ),
                                      blurRadius: _isPressed ? 6 : 4,
                                      spreadRadius: -1,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.asset(
                                    _getPlanetImagePath(planet),
                                    width: 22,
                                    height: 22,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => Container(
                                          color: planetColor.withOpacity(0.12),
                                          child: Center(
                                            child: Text(
                                              _getPlanetSymbol(planet),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: planetColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                  ),
                                ),
                              );
                            }).toList(),
                      )
                      // Show count + first planet for 3+ planets
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: _getPlanetColor(
                                    widget.planets.first,
                                  ).withOpacity(0.15),
                                  blurRadius: 4,
                                  spreadRadius: -1,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.asset(
                                _getPlanetImagePath(widget.planets.first),
                                width: 20,
                                height: 20,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Container(
                                      color: _getPlanetColor(
                                        widget.planets.first,
                                      ).withOpacity(0.12),
                                      child: Center(
                                        child: Text(
                                          _getPlanetSymbol(
                                            widget.planets.first,
                                          ),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: _getPlanetColor(
                                              widget.planets.first,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${widget.planets.length - 1}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8A87A0),
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
// PREMIUM TRANSIT CARD - Minimal Elegant Design
// ═══════════════════════════════════════════════════════════════════════════
class _PremiumTransitCard extends StatefulWidget {
  final TransitData transit;
  final PlanetPosition? natalPosition;

  const _PremiumTransitCard({required this.transit, this.natalPosition});

  @override
  State<_PremiumTransitCard> createState() => _PremiumTransitCardState();
}

class _PremiumTransitCardState extends State<_PremiumTransitCard> {
  bool _isPressed = false;

  bool _isSlowPlanet(String planet) {
    return ['Saturn', 'Jupiter', 'Rahu', 'Ketu'].contains(planet);
  }

  String _getPlanetImagePath(String planet) {
    return 'assets/images/planets/${planet.toLowerCase()}.png';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFavorable = widget.transit.isFavorable;
    final statusColor = isFavorable ? _Colors.emerald : _Colors.coral;
    final planetColor = _getPlanetColor(widget.transit.planet);
    final isSlowPlanet = _isSlowPlanet(widget.transit.planet);
    final signColor = _getZodiacColor(widget.transit.currentSign);
    final localizedPlanetName = _getLocalizedPlanetName(widget.transit.planet, l10n);
    final localizedSignName = _getLocalizedZodiacSign(widget.transit.currentSign, l10n);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        _showInsightSheet(context, _getTransitPlanetInsight(widget.transit, l10n));
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFF1A1820) : const Color(0xFF141218),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main row: Planet image + info + status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Planet image
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: planetColor.withOpacity(
                          _isPressed ? 0.25 : 0.15,
                        ),
                        blurRadius: _isPressed ? 8 : 5,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      _getPlanetImagePath(widget.transit.planet),
                      width: 38,
                      height: 38,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            color: planetColor.withOpacity(0.12),
                            child: Center(
                              child: Text(
                                _getPlanetSymbol(widget.transit.planet),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: planetColor,
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Planet info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + status row
                      Row(
                        children: [
                          Text(
                            localizedPlanetName,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (isSlowPlanet) ...[
                            const SizedBox(width: 6),
                            Text(
                              '•',
                              style: TextStyle(
                                fontSize: 8,
                                color: _Colors.sky.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.transit_major,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: _Colors.sky.withOpacity(0.8),
                              ),
                            ),
                          ],
                          const Spacer(),
                          // Status indicator - minimal
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isFavorable ? l10n.transit_good : l10n.transit_alert,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Position info - inline
                      Row(
                        children: [
                          // Sign with small image
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: signColor.withOpacity(0.15),
                                  blurRadius: 3,
                                  spreadRadius: -1,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.asset(
                                _getZodiacImagePath(widget.transit.currentSign),
                                width: 16,
                                height: 16,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Container(
                                      color: signColor.withOpacity(0.15),
                                      child: Center(
                                        child: Text(
                                          _getSignSymbol(
                                            widget.transit.currentSign,
                                          ),
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: signColor,
                                          ),
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${localizedSignName.length > 3 ? localizedSignName.substring(0, 3) : localizedSignName} ${widget.transit.currentDegree.toStringAsFixed(1)}°',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF9A97A6),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A4758),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // House from Moon
                          Text(
                            '☽',
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  isFavorable
                                      ? statusColor.withOpacity(0.7)
                                      : const Color(0xFF7A7786),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'H${widget.transit.transitHouse}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color:
                                  isFavorable
                                      ? statusColor
                                      : const Color(0xFF9A97A6),
                            ),
                          ),
                          // Aspect (if present) - inline
                          if (widget.transit.aspectToNatal != 'None') ...[
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A4758),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Icon(
                              Icons.link_rounded,
                              size: 10,
                              color: _Colors.violet.withOpacity(0.6),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.transit.aspectToNatal,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF8A87A0),
                              ),
                            ),
                          ],
                          const Spacer(),
                          // Subtle arrow
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 100),
                            opacity: _isPressed ? 1.0 : 0.3,
                            child: Icon(
                              Icons.chevron_right_rounded,
                              size: 14,
                              color: const Color(0xFF6A6778),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Effects row (if present) - minimal
            if (widget.transit.effects.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0D14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡', style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.transit.effects,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: const Color(0xFF8A8798),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SADE SATI CARDS - Premium Design with Centered Saturn
// ═══════════════════════════════════════════════════════════════════════════
class _SadeSatiCard extends StatefulWidget {
  final Map<String, dynamic> sadeSatiInfo;

  const _SadeSatiCard({required this.sadeSatiInfo});

  @override
  State<_SadeSatiCard> createState() => _SadeSatiCardState();
}

class _SadeSatiCardState extends State<_SadeSatiCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getPhaseTitle(int phase, AppLocalizations l10n) {
    switch (phase) {
      case 1:
        return l10n.sadesati_rising_phase;
      case 2:
        return l10n.sadesati_peak_phase;
      case 3:
        return l10n.sadesati_setting_phase;
      default:
        return l10n.sadesati_active;
    }
  }

  String _getPhaseSubtitle(int phase, AppLocalizations l10n) {
    switch (phase) {
      case 1:
        return l10n.sadesati_12th_from_moon;
      case 2:
        return l10n.sadesati_over_moon;
      case 3:
        return l10n.sadesati_2nd_from_moon;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phase = widget.sadeSatiInfo['phaseNumber'] ?? 0;
    final saturnColor = const Color(0xFFE57373);
    final saturnSign = widget.sadeSatiInfo['saturnSign'] ?? '';
    final saturnSignColor = _getZodiacColor(saturnSign);
    final moonSign = widget.sadeSatiInfo['moonSign'] ?? '';
    final moonSignColor = _getZodiacColor(moonSign);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        final l10n = AppLocalizations.of(context);
        _showInsightSheet(context, _getSadeSatiInsight(widget.sadeSatiInfo, l10n));
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFF1A1820) : const Color(0xFF141218),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header row with status badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: saturnColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: saturnColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getPhaseTitle(phase, l10n),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: saturnColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: _isPressed ? 1.0 : 0.4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.sadesati_learn_more,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: const Color(0xFF6A6778),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: const Color(0xFF6A6778),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Central Saturn showcase with animated rings
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                final pulse = _pulseAnimation.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer warning ring
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: saturnColor.withOpacity(0.1 + pulse * 0.08),
                          width: 1,
                        ),
                      ),
                    ),
                    // Middle ring
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: saturnColor.withOpacity(0.15 + pulse * 0.1),
                          width: 1.5,
                        ),
                      ),
                    ),
                    // Saturn container with glow
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1E1C28),
                        boxShadow: [
                          BoxShadow(
                            color: saturnColor.withOpacity(0.2 + pulse * 0.15),
                            blurRadius: 24 + pulse * 12,
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/planets/saturn.png',
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Center(
                                child: Text(
                                  '♄',
                                  style: TextStyle(
                                    fontSize: 36,
                                    color: saturnColor,
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                    // Phase indicator badge
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: saturnColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: saturnColor.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$phase',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              l10n.sadesati_active,
              style: GoogleFonts.instrumentSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 4),

            // Phase subtitle
            Text(
              _getPhaseSubtitle(phase, l10n),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF7A7786),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Saturn & Moon sign info row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0D14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Saturn position
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: saturnSignColor.withOpacity(0.2),
                              blurRadius: 6,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            _getZodiacImagePath(saturnSign),
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  color: saturnSignColor.withOpacity(0.15),
                                  child: Center(
                                    child: Text(
                                      '♄',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: saturnSignColor,
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.sadesati_saturn,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: const Color(0xFF6A6778),
                        ),
                      ),
                      Text(
                        _getLocalizedZodiacSign(saturnSign, l10n),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: saturnSignColor,
                        ),
                      ),
                    ],
                  ),

                  // Divider with arrow
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: saturnColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${phase == 1
                              ? l10n.sadesati_phase_12th
                              : phase == 2
                              ? l10n.sadesati_phase_1st
                              : l10n.sadesati_phase_2nd}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            color: saturnColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Moon sign
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: moonSignColor.withOpacity(0.2),
                              blurRadius: 6,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            _getZodiacImagePath(moonSign),
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  color: moonSignColor.withOpacity(0.15),
                                  child: Center(
                                    child: Text(
                                      '☽',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: moonSignColor,
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.sadesati_moon,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: const Color(0xFF6A6778),
                        ),
                      ),
                      Text(
                        _getLocalizedZodiacSign(moonSign, l10n),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: moonSignColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Phase progress indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SadeSatiPhaseChip(
                  label: l10n.sadesati_phase_12th,
                  isActive: phase >= 1,
                  isCurrent: phase == 1,
                  color: saturnColor,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 20,
                  height: 2,
                  decoration: BoxDecoration(
                    color: phase >= 2 ? saturnColor : const Color(0xFF2A2838),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                _SadeSatiPhaseChip(
                  label: l10n.sadesati_phase_1st,
                  isActive: phase >= 2,
                  isCurrent: phase == 2,
                  color: saturnColor,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 20,
                  height: 2,
                  decoration: BoxDecoration(
                    color: phase >= 3 ? saturnColor : const Color(0xFF2A2838),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                _SadeSatiPhaseChip(
                  label: l10n.sadesati_phase_2nd,
                  isActive: phase >= 3,
                  isCurrent: phase == 3,
                  color: saturnColor,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: saturnColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⚠️', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.sadeSatiInfo['description'] ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF9A97A6),
                        height: 1.4,
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

class _SadeSatiInactiveCard extends StatefulWidget {
  final String moonSign;

  const _SadeSatiInactiveCard({required this.moonSign});

  @override
  State<_SadeSatiInactiveCard> createState() => _SadeSatiInactiveCardState();
}

class _SadeSatiInactiveCardState extends State<_SadeSatiInactiveCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
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
    final l10n = AppLocalizations.of(context);
    final saturnColor = const Color(0xFF5C7AEA);
    final moonSignColor = _getZodiacColor(widget.moonSign);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        _showInsightSheet(
          context,
          _getSadeSatiInsight({'isActive': false, 'moonSign': widget.moonSign}, l10n),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFF1A1820) : const Color(0xFF141218),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header row with status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _Colors.emerald.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _Colors.emerald,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.sadesati_clear_period,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _Colors.emerald,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: _isPressed ? 1.0 : 0.4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.sadesati_learn_more,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: const Color(0xFF6A6778),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: const Color(0xFF6A6778),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Central Saturn showcase
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                final pulse = _pulseAnimation.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring glow
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: saturnColor.withOpacity(0.08 + pulse * 0.06),
                          width: 1,
                        ),
                      ),
                    ),
                    // Middle ring
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: saturnColor.withOpacity(0.1 + pulse * 0.08),
                          width: 1,
                        ),
                      ),
                    ),
                    // Saturn container with glow
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1E1C28),
                        boxShadow: [
                          BoxShadow(
                            color: saturnColor.withOpacity(0.15 + pulse * 0.1),
                            blurRadius: 20 + pulse * 10,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/planets/saturn.png',
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Center(
                                child: Text(
                                  '♄',
                                  style: TextStyle(
                                    fontSize: 32,
                                    color: saturnColor,
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                    // Check mark overlay
                    Positioned(
                      right: 14,
                      bottom: 10,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _Colors.emerald,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _Colors.emerald.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              l10n.sadesati_not_active,
              style: GoogleFonts.instrumentSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 6),

            // Subtitle
            Text(
              l10n.sadesati_not_affecting,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF7A7786),
              ),
            ),

            const SizedBox(height: 16),

            // Info row with Moon sign
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0D14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Saturn position
                  Text(
                    '♄',
                    style: TextStyle(
                      fontSize: 12,
                      color: saturnColor.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.sadesati_saturn,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF8A8798),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 1,
                    height: 14,
                    color: const Color(0xFF2A2838),
                  ),
                  // Moon sign
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: moonSignColor.withOpacity(0.2),
                          blurRadius: 4,
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                        _getZodiacImagePath(widget.moonSign),
                        width: 18,
                        height: 18,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              color: moonSignColor.withOpacity(0.15),
                              child: Center(
                                child: Text(
                                  _getSignSymbol(widget.moonSign),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: moonSignColor,
                                  ),
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getLocalizedZodiacSign(widget.moonSign, l10n),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: moonSignColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${l10n.sadesati_janma_rashi})',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: const Color(0xFF6A6778),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Three phases indicator - all inactive
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SadeSatiPhaseChip(
                  label: l10n.sadesati_phase_12th,
                  isActive: false,
                  color: saturnColor,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 16,
                  height: 1,
                  color: const Color(0xFF2A2838),
                ),
                _SadeSatiPhaseChip(
                  label: l10n.sadesati_phase_1st,
                  isActive: false,
                  color: saturnColor,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 16,
                  height: 1,
                  color: const Color(0xFF2A2838),
                ),
                _SadeSatiPhaseChip(
                  label: l10n.sadesati_phase_2nd,
                  isActive: false,
                  color: saturnColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for Sade Sati phase indicator
class _SadeSatiPhaseChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCurrent;
  final Color color;

  const _SadeSatiPhaseChip({
    required this.label,
    required this.isActive,
    this.isCurrent = false,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isCurrent
                ? color.withOpacity(0.2)
                : isActive
                ? color.withOpacity(0.1)
                : const Color(0xFF1A1820),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isCurrent
                  ? color.withOpacity(0.5)
                  : isActive
                  ? color.withOpacity(0.25)
                  : const Color(0xFF2A2838),
          width: isCurrent ? 1.5 : 0.5,
        ),
        boxShadow:
            isCurrent
                ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ]
                : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
          color: isActive ? color : const Color(0xFF5A5768),
        ),
      ),
    );
  }
}

class _PhaseProgressBar extends StatelessWidget {
  final int currentPhase;

  const _PhaseProgressBar({required this.currentPhase});

  @override
  Widget build(BuildContext context) {
    final phases = [
      ('Rising', '12th from ☽'),
      ('Peak', 'Over ☽'),
      ('Setting', '2nd from ☽'),
    ];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _Colors.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i + 1 == currentPhase;
          final isPast = i + 1 < currentPhase;

          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color:
                          isPast || isActive
                              ? _Colors.coral
                              : _Colors.border.withOpacity(0.3),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? _Colors.coral.withOpacity(0.15)
                            : isPast
                            ? _Colors.coral.withOpacity(0.08)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border:
                        isActive
                            ? Border.all(
                              color: _Colors.coral.withOpacity(0.3),
                              width: 0.5,
                            )
                            : null,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color:
                              isActive || isPast
                                  ? _Colors.coral
                                  : _Colors.border.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color:
                                  isActive || isPast
                                      ? Colors.white
                                      : _Colors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phases[i].$1,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                          color:
                              isActive ? _Colors.coral : _Colors.textTertiary,
                        ),
                      ),
                      Text(
                        phases[i].$2,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 7,
                          color: _Colors.textTertiary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      color:
                          isPast
                              ? _Colors.coral
                              : _Colors.border.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════
Color _getPlanetColor(String planet) {
  const colors = {
    'Sun': Color(0xFFFF9F43),
    'Moon': Color(0xFFF5F5F5),
    'Mars': Color(0xFFEE5A5A),
    'Mercury': Color(0xFF26DE81),
    'Jupiter': Color(0xFFFFD93D),
    'Venus': Color(0xFFFF6B9D),
    'Saturn': Color(0xFF5C7AEA),
    'Rahu': Color(0xFF9C88FF),
    'Ketu': Color(0xFFA29BFE),
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

Color _getZodiacColor(String sign) {
  const colors = {
    'Aries': Color(0xFFEE5A5A),
    'Taurus': Color(0xFF4ADE80),
    'Gemini': Color(0xFFFFD93D),
    'Cancer': Color(0xFFF5F5F5),
    'Leo': Color(0xFFFF9F43),
    'Virgo': Color(0xFF26DE81),
    'Libra': Color(0xFFFF6B9D),
    'Scorpio': Color(0xFFEE5A5A),
    'Sagittarius': Color(0xFFFFD93D),
    'Capricorn': Color(0xFF5C7AEA),
    'Aquarius': Color(0xFF5C7AEA),
    'Pisces': Color(0xFF9C88FF),
  };
  return colors[sign] ?? const Color(0xFFA09CAC);
}

String _getZodiacImagePath(String sign) {
  return 'assets/images/zodiac/${sign.toLowerCase()}.png';
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

String _getLocalizedPlanetName(String planet, AppLocalizations l10n) {
  switch (planet.toLowerCase()) {
    case 'sun':
      return l10n.planet_sun;
    case 'moon':
      return l10n.planet_moon;
    case 'mars':
      return l10n.planet_mars;
    case 'mercury':
      return l10n.planet_mercury;
    case 'jupiter':
      return l10n.planet_jupiter;
    case 'venus':
      return l10n.planet_venus;
    case 'saturn':
      return l10n.planet_saturn;
    case 'rahu':
      return l10n.planet_rahu;
    case 'ketu':
      return l10n.planet_ketu;
    case 'uranus':
      return l10n.planet_uranus;
    case 'neptune':
      return l10n.planet_neptune;
    case 'pluto':
      return l10n.planet_pluto;
    default:
      return planet;
  }
}

String _getLocalizedZodiacSign(String sign, AppLocalizations l10n) {
  switch (sign.toLowerCase()) {
    case 'aries':
      return l10n.zodiac_aries;
    case 'taurus':
      return l10n.zodiac_taurus;
    case 'gemini':
      return l10n.zodiac_gemini;
    case 'cancer':
      return l10n.zodiac_cancer;
    case 'leo':
      return l10n.zodiac_leo;
    case 'virgo':
      return l10n.zodiac_virgo;
    case 'libra':
      return l10n.zodiac_libra;
    case 'scorpio':
      return l10n.zodiac_scorpio;
    case 'sagittarius':
      return l10n.zodiac_sagittarius;
    case 'capricorn':
      return l10n.zodiac_capricorn;
    case 'aquarius':
      return l10n.zodiac_aquarius;
    case 'pisces':
      return l10n.zodiac_pisces;
    default:
      return sign;
  }
}
