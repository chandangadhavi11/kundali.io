import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
  static const Color bgSecondary = Color(0xFF1A1825);

  // Borders
  static const Color border = Color(0xFF2A2838);

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
  static const Color gold = Color(0xFFD4AF37);
  static const Color rose = Color(0xFFF472B6);
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
InsightData _getYogaOverviewInsight(
  int yogaCount,
  int doshaCount,
  int strongYogas,
  int severeDoshas,
  String ascendant,
  AppLocalizations l10n,
) {
  final balance = yogaCount - severeDoshas;
  final balanceStatus = _getLocalizedBalanceStatus(balance, yogaCount, doshaCount, l10n);

  final color =
      balance >= 3
          ? _Colors.emerald
          : balance >= 0
          ? _Colors.sky
          : balance >= -2
          ? _Colors.amber
          : _Colors.coral;

  final localizedAscendant = _getLocalizedZodiacSign(ascendant, l10n);

  return InsightData(
    title: l10n.yogas_overview_insight_title,
    value: balanceStatus,
    description: l10n.yogas_overview_insight_desc,
    significance: l10n.yogas_overview_insight_significance(
      yogaCount,
      doshaCount,
      strongYogas,
      severeDoshas,
      localizedAscendant,
      balanceStatus,
    ),
    keyPoints: [
      l10n.yogas_overview_insight_keypoint1(yogaCount, strongYogas),
      l10n.yogas_overview_insight_keypoint2(doshaCount, severeDoshas),
      l10n.yogas_overview_insight_keypoint3(localizedAscendant),
      l10n.yogas_overview_insight_keypoint4(balanceStatus),
      l10n.yogas_overview_insight_keypoint5,
      l10n.yogas_overview_insight_keypoint6,
    ],
    accentColor: color,
    icon: Icons.balance_rounded,
  );
}

String _getLocalizedBalanceStatus(int balance, int yogas, int doshas, AppLocalizations l10n) {
  if (yogas > 0 && doshas == 0) return l10n.yogas_balance_excellent;
  if (balance >= 3) return l10n.yogas_balance_veryFavorable;
  if (balance >= 1) return l10n.yogas_balance_favorable;
  if (balance >= -1) return l10n.yogas_balance_mixed;
  return l10n.yogas_balance_challenging;
}

InsightData _getYogaTypeInsight(String type, bool isYoga, AppLocalizations l10n) {
  final (String desc, String significance, Color color) = _getYogaTypeInfo(type, isYoga, l10n);
  final localizedType = isYoga ? _getLocalizedYogaType(type, l10n) : _getLocalizedStrength(type, l10n);

  return InsightData(
    title: isYoga ? l10n.yogas_type_yoga : l10n.yogas_doshaRemedy,
    value: localizedType,
    description: desc,
    significance: significance,
    keyPoints:
        isYoga
            ? [
              l10n.yogas_typeInsight_yoga_type(localizedType),
              l10n.yogas_typeInsight_yoga_nature,
              l10n.yogas_typeInsight_yoga_activation,
              l10n.yogas_typeInsight_yoga_strength,
            ]
            : [
              l10n.yogas_typeInsight_dosha_severity(localizedType),
              l10n.yogas_typeInsight_dosha_impact,
              l10n.yogas_typeInsight_dosha_remedies,
              l10n.yogas_typeInsight_dosha_consult,
            ],
    accentColor: color,
    icon: isYoga ? Icons.auto_awesome_rounded : Icons.warning_amber_rounded,
  );
}

(String, String, Color) _getYogaTypeInfo(String type, bool isYoga, AppLocalizations l10n) {
  switch (type) {
    case 'Raja Yoga':
    case 'Raja':
      return (l10n.yogas_typeInsight_rajaYoga_desc, l10n.yogas_typeInsight_rajaYoga_significance, _Colors.gold);
    case 'Dhana Yoga':
    case 'Dhana':
      return (l10n.yogas_typeInsight_dhanaYoga_desc, l10n.yogas_typeInsight_dhanaYoga_significance, _Colors.emerald);
    case 'Pancha Mahapurusha':
    case 'Mahapurusha':
      return (l10n.yogas_typeInsight_mahapurusha_desc, l10n.yogas_typeInsight_mahapurusha_significance, _Colors.violet);
    case 'Lunar Yoga':
    case 'Lunar':
      return (l10n.yogas_typeInsight_lunarYoga_desc, l10n.yogas_typeInsight_lunarYoga_significance, _Colors.sky);
    case 'High':
    case 'Severe':
      return (l10n.yogas_typeInsight_severeDosha_desc, l10n.yogas_typeInsight_severeDosha_significance, _Colors.coral);
    case 'Moderate':
      return (l10n.yogas_typeInsight_moderateDosha_desc, l10n.yogas_typeInsight_moderateDosha_significance, _Colors.amber);
    case 'Low':
    case 'Mild':
      return (l10n.yogas_typeInsight_mildDosha_desc, l10n.yogas_typeInsight_mildDosha_significance, _Colors.sky);
    default:
      if (isYoga) {
        return (l10n.yogas_typeInsight_defaultYoga_desc, l10n.yogas_typeInsight_defaultYoga_significance, _Colors.gold);
      } else {
        return (l10n.yogas_typeInsight_defaultDosha_desc, l10n.yogas_typeInsight_defaultDosha_significance, _Colors.coral);
      }
  }
}

InsightData _getStrengthInsight(String strength, int count, String label, AppLocalizations l10n) {
  final localizedLabel = _getLocalizedStrength(label, l10n);
  final (String desc, Color color) = _getStrengthInfo(label, l10n);

  return InsightData(
    title: l10n.yogas_strengthInsight_title(count, localizedLabel),
    value: l10n.yogas_strengthInsight_value(count, localizedLabel),
    description: desc,
    significance: l10n.yogas_strengthInsight_significance(count, localizedLabel),
    keyPoints: [
      l10n.yogas_strengthInsight_count(count),
      l10n.yogas_strengthInsight_level(localizedLabel),
      if (label == 'Strong') l10n.yogas_strengthInsight_strong_keypoint,
      if (label == 'Moderate') l10n.yogas_strengthInsight_moderate_keypoint,
      if (label == 'Severe') l10n.yogas_strengthInsight_severe_keypoint,
    ],
    accentColor: color,
    icon:
        label == 'Severe'
            ? Icons.warning_rounded
            : label == 'Strong'
            ? Icons.keyboard_double_arrow_up_rounded
            : Icons.remove_rounded,
  );
}

(String, Color) _getStrengthInfo(String label, AppLocalizations l10n) {
  switch (label) {
    case 'Strong':
      return (l10n.yogas_strengthInsight_strong_desc, _Colors.emerald);
    case 'Moderate':
      return (l10n.yogas_strengthInsight_moderate_desc, _Colors.amber);
    case 'Severe':
      return (l10n.yogas_strengthInsight_severe_desc, _Colors.coral);
    default:
      return (l10n.yogas_strengthInsight_default_desc, _Colors.sky);
  }
}

InsightData _getInsightCardInsight(
  String title,
  String description,
  Color color,
  AppLocalizations l10n,
) {
  final (String desc, String significance, List<String> keyPoints) = _getInsightCardInfo(title, description, l10n);
  final localizedTitle = _getLocalizedInsightTitle(title, l10n);

  return InsightData(
    title: l10n.yogas_astrologicalInsight,
    value: localizedTitle,
    description: desc,
    significance: significance,
    keyPoints: keyPoints,
    accentColor: color,
    icon:
        title == 'Understanding'
            ? Icons.lightbulb_outline_rounded
            : title == 'Activation'
            ? Icons.schedule_rounded
            : title == 'Strength'
            ? Icons.fitness_center_rounded
            : Icons.healing_outlined,
  );
}

String _getLocalizedInsightTitle(String title, AppLocalizations l10n) {
  switch (title) {
    case 'Understanding': return l10n.yogas_insight_understanding;
    case 'Activation': return l10n.yogas_insight_activation;
    case 'Strength': return l10n.yogas_insight_strength;
    case 'Remedies': return l10n.yogas_insight_remedies;
    default: return title;
  }
}

(String, String, List<String>) _getInsightCardInfo(String title, String description, AppLocalizations l10n) {
  switch (title) {
    case 'Understanding':
      return (
        l10n.yogas_insightCard_understanding_desc,
        l10n.yogas_insightCard_understanding_significance,
        [
          l10n.yogas_insightCard_understanding_kp1,
          l10n.yogas_insightCard_understanding_kp2,
          l10n.yogas_insightCard_understanding_kp3,
          l10n.yogas_insightCard_understanding_kp4,
        ],
      );
    case 'Activation':
      return (
        l10n.yogas_insightCard_activation_desc,
        l10n.yogas_insightCard_activation_significance,
        [
          l10n.yogas_insightCard_activation_kp1,
          l10n.yogas_insightCard_activation_kp2,
          l10n.yogas_insightCard_activation_kp3,
          l10n.yogas_insightCard_activation_kp4,
        ],
      );
    case 'Strength':
      return (
        l10n.yogas_insightCard_strength_desc,
        l10n.yogas_insightCard_strength_significance,
        [
          l10n.yogas_insightCard_strength_kp1,
          l10n.yogas_insightCard_strength_kp2,
          l10n.yogas_insightCard_strength_kp3,
          l10n.yogas_insightCard_strength_kp4,
        ],
      );
    case 'Remedies':
      return (
        l10n.yogas_insightCard_remedies_desc,
        l10n.yogas_insightCard_remedies_significance,
        [
          l10n.yogas_insightCard_remedies_kp1,
          l10n.yogas_insightCard_remedies_kp2,
          l10n.yogas_insightCard_remedies_kp3,
          l10n.yogas_insightCard_remedies_kp4,
        ],
      );
    default:
      return (
        description,
        l10n.yogas_insightCard_default_significance,
        [l10n.yogas_insightCard_default_kp],
      );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NAVIGATION SECTION DATA
// ═══════════════════════════════════════════════════════════════════════════
List<NavSection> _getSections(AppLocalizations l10n) => [
  NavSection(id: 'overview', label: l10n.yogas_nav_overview, color: _Colors.emerald),
  NavSection(id: 'yogas', label: l10n.yogas_nav_yogas, color: _Colors.gold),
  NavSection(id: 'doshas', label: l10n.yogas_nav_doshas, color: _Colors.coral),
  NavSection(id: 'insights', label: l10n.yogas_nav_insights, color: _Colors.violet),
];

/// Yogas & Doshas Tab - Shows all yogas and doshas with details
/// Premium, elegant UI with clear visual hierarchy
class YogasTab extends StatefulWidget {
  final KundaliData kundaliData;

  const YogasTab({super.key, required this.kundaliData});

  @override
  State<YogasTab> createState() => _YogasTabState();
}

class _YogasTabState extends State<YogasTab> {
  late final ScrollController _scrollController;
  final Map<String, GlobalKey> _sectionKeys = {};
  final Map<String, GlobalKey<_AnimatedSectionWrapperState>> _animatedKeys = {};
  int _activeIndex = 0;
  bool _isScrolling = false;
  
  // Static section IDs for initialization
  static const _sectionIds = ['overview', 'yogas', 'doshas', 'insights'];

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

  Future<void> _scrollToSection(int index, List<NavSection> sections) async {
    final section = sections[index];
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
    final l10n = AppLocalizations.of(context);
    final sections = _getSections(l10n);
    final analyzedYogas = _analyzeYogas(widget.kundaliData);
    final analyzedDoshas = _analyzeDoshas(widget.kundaliData);

    final strongYogas =
        analyzedYogas.where((y) => y['strength'] == 'Strong').length;
    final partialYogas = analyzedYogas.length - strongYogas;
    final severeDoshas =
        analyzedDoshas.where((d) => d['severity'] == 'High').length;

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
                accentColor: _Colors.emerald,
                child: _AnimatedCardWrapper(
                  child: _YogaHeroCard(
                    yogaCount: analyzedYogas.length,
                    doshaCount: analyzedDoshas.length,
                    strongYogas: strongYogas,
                    partialYogas: partialYogas,
                    severeDoshas: severeDoshas,
                    ascendant: widget.kundaliData.ascendant.sign,
                  ),
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // ═══════════════════════════════════════════════════════════════
              // YOGAS SECTION
              // ═══════════════════════════════════════════════════════════════
              _AnimatedSectionWrapper(
                key: _animatedKeys['yogas'],
                sectionKey: _sectionKeys['yogas']!,
                accentColor: _Colors.gold,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: l10n.yogas_auspiciousYogas,
                      subtitle: l10n.yogas_beneficialCombinations(analyzedYogas.length.toString()),
                      accentColor: _Colors.gold,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    if (analyzedYogas.isNotEmpty) ...[
                      _AnimatedCardWrapper(
                        delay: 50,
                        child: _YogaTypeLegend(isYoga: true),
                      ),
                      const SizedBox(height: _DesignTokens.space12),
                      ...analyzedYogas.asMap().entries.map(
                        (entry) => _AnimatedCardWrapper(
                          delay: 100 + (entry.key * 50),
                          child: _PremiumYogaCard(
                            yogaData: entry.value,
                            index: entry.key,
                            isDosha: false,
                            planetPositions: widget.kundaliData.planetPositions,
                          ),
                        ),
                      ),
                    ] else ...[
                      _AnimatedCardWrapper(
                        delay: 50,
                        child: _EmptyStateCard(
                          title: l10n.yogas_noYogasDetected,
                          message: l10n.yogas_noYogasMessage,
                          icon: Icons.auto_awesome_outlined,
                          color: _Colors.gold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // ═══════════════════════════════════════════════════════════════
              // DOSHAS SECTION
              // ═══════════════════════════════════════════════════════════════
              _AnimatedSectionWrapper(
                key: _animatedKeys['doshas'],
                sectionKey: _sectionKeys['doshas']!,
                accentColor: _Colors.coral,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: l10n.yogas_doshasPresent,
                      subtitle: l10n.yogas_detected(analyzedDoshas.length.toString()),
                      accentColor: _Colors.coral,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    if (analyzedDoshas.isNotEmpty) ...[
                      _AnimatedCardWrapper(
                        delay: 50,
                        child: _YogaTypeLegend(isYoga: false),
                      ),
                      const SizedBox(height: _DesignTokens.space12),
                      ...analyzedDoshas.asMap().entries.map(
                        (entry) => _AnimatedCardWrapper(
                          delay: 100 + (entry.key * 50),
                          child: _PremiumYogaCard(
                            yogaData: entry.value,
                            index: entry.key,
                            isDosha: true,
                            planetPositions: widget.kundaliData.planetPositions,
                          ),
                        ),
                      ),
                    ] else ...[
                      _AnimatedCardWrapper(
                        delay: 50,
                        child: _EmptyStateCard(
                          title: l10n.yogas_noDoshasFound,
                          message: l10n.yogas_noDoshasMessage,
                          icon: Icons.check_circle_outline_rounded,
                          color: _Colors.emerald,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // ═══════════════════════════════════════════════════════════════
              // INSIGHTS SECTION
              // ═══════════════════════════════════════════════════════════════
              _AnimatedSectionWrapper(
                key: _animatedKeys['insights'],
                sectionKey: _sectionKeys['insights']!,
                accentColor: _Colors.violet,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: l10n.yogas_astrologicalInsights,
                      subtitle: l10n.yogas_understandingYourChart,
                      accentColor: _Colors.violet,
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    _AnimatedCardWrapper(
                      delay: 50,
                      child: _InsightsGrid(
                        hasKaalSarp: widget.kundaliData.doshas.contains(
                          'Kaal Sarp Dosha',
                        ),
                        hasManglik: widget.kundaliData.doshas.contains(
                          'Manglik Dosha',
                        ),
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
            sections: sections,
            activeIndex: _activeIndex,
            onTap: (index) => _scrollToSection(index, sections),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _analyzeYogas(KundaliData data) {
    final results = <Map<String, dynamic>>[];
    final positions = data.planetPositions;
    final houses = data.houses;
    final ascSign = data.ascendant.sign;

    for (final yogaName in data.yogas) {
      final analysis = _analyzeSpecificYoga(
        yogaName,
        positions,
        houses,
        ascSign,
      );
      results.add(analysis);
    }

    return results;
  }

  List<Map<String, dynamic>> _analyzeDoshas(KundaliData data) {
    final results = <Map<String, dynamic>>[];
    final positions = data.planetPositions;
    final houses = data.houses;
    final ascSign = data.ascendant.sign;

    for (final doshaName in data.doshas) {
      final analysis = _analyzeSpecificDosha(
        doshaName,
        positions,
        houses,
        ascSign,
      );
      results.add(analysis);
    }

    return results;
  }

  Map<String, dynamic> _analyzeSpecificYoga(
    String yogaName,
    Map<String, PlanetPosition> positions,
    List<House> houses,
    String ascSign,
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

    Map<String, dynamic> result = {
      'name': yogaName,
      'planets': <String>[],
      'houses': <int>[],
      'strength': 'Moderate',
      'formationRule': '',
    };

    switch (yogaName) {
      case 'Gajakesari Yoga':
        final jupiter = positions['Jupiter'];
        final moon = positions['Moon'];
        if (jupiter != null && moon != null) {
          final jupHouse = _getHouseFromSign(jupiter.sign, ascSign, signs);
          final moonHouse = _getHouseFromSign(moon.sign, ascSign, signs);
          // Calculate Jupiter's house from Moon (not from Ascendant)
          final jupIndex = signs.indexOf(jupiter.sign);
          final moonIndex = signs.indexOf(moon.sign);
          final jupHouseFromMoon = ((jupIndex - moonIndex + 12) % 12) + 1;
          result['planets'] = ['Jupiter', 'Moon'];
          result['houses'] = [jupHouse, moonHouse];
          result['formationRule'] = 'Jupiter in H$jupHouseFromMoon from Moon';
          // Strength based on Kendra from Moon, not from Ascendant
          result['strength'] =
              _isInKendra(jupHouseFromMoon) ? 'Strong' : 'Moderate';
        }
        break;

      case 'Hamsa Yoga':
        final jupiter = positions['Jupiter'];
        if (jupiter != null) {
          final jupHouse = _getHouseFromSign(jupiter.sign, ascSign, signs);
          result['planets'] = ['Jupiter'];
          result['houses'] = [jupHouse];
          result['formationRule'] = 'Jupiter in H$jupHouse (${jupiter.sign})';
          result['strength'] =
              (jupiter.sign == 'Sagittarius' ||
                      jupiter.sign == 'Pisces' ||
                      jupiter.sign == 'Cancer')
                  ? 'Strong'
                  : 'Moderate';
        }
        break;

      case 'Malavya Yoga':
        final venus = positions['Venus'];
        if (venus != null) {
          final venHouse = _getHouseFromSign(venus.sign, ascSign, signs);
          result['planets'] = ['Venus'];
          result['houses'] = [venHouse];
          result['formationRule'] = 'Venus in H$venHouse (${venus.sign})';
          result['strength'] =
              (venus.sign == 'Taurus' ||
                      venus.sign == 'Libra' ||
                      venus.sign == 'Pisces')
                  ? 'Strong'
                  : 'Moderate';
        }
        break;

      case 'Bhadra Yoga':
        final mercury = positions['Mercury'];
        if (mercury != null) {
          final merHouse = _getHouseFromSign(mercury.sign, ascSign, signs);
          result['planets'] = ['Mercury'];
          result['houses'] = [merHouse];
          result['formationRule'] = 'Mercury in H$merHouse (${mercury.sign})';
          result['strength'] =
              (mercury.sign == 'Gemini' || mercury.sign == 'Virgo')
                  ? 'Strong'
                  : 'Moderate';
        }
        break;

      case 'Ruchaka Yoga':
        final mars = positions['Mars'];
        if (mars != null) {
          final marsHouse = _getHouseFromSign(mars.sign, ascSign, signs);
          result['planets'] = ['Mars'];
          result['houses'] = [marsHouse];
          result['formationRule'] = 'Mars in H$marsHouse (${mars.sign})';
          result['strength'] =
              (mars.sign == 'Aries' ||
                      mars.sign == 'Scorpio' ||
                      mars.sign == 'Capricorn')
                  ? 'Strong'
                  : 'Moderate';
        }
        break;

      case 'Sasa Yoga':
        final saturn = positions['Saturn'];
        if (saturn != null) {
          final satHouse = _getHouseFromSign(saturn.sign, ascSign, signs);
          result['planets'] = ['Saturn'];
          result['houses'] = [satHouse];
          result['formationRule'] = 'Saturn in H$satHouse (${saturn.sign})';
          result['strength'] =
              (saturn.sign == 'Capricorn' ||
                      saturn.sign == 'Aquarius' ||
                      saturn.sign == 'Libra')
                  ? 'Strong'
                  : 'Moderate';
        }
        break;

      case 'Budhaditya Yoga':
        final sun = positions['Sun'];
        final mercury = positions['Mercury'];
        if (sun != null && mercury != null && sun.sign == mercury.sign) {
          final sunHouse = _getHouseFromSign(sun.sign, ascSign, signs);
          result['planets'] = ['Sun', 'Mercury'];
          result['houses'] = [sunHouse];
          result['formationRule'] = 'Sun-Mercury conjunction in H$sunHouse';
          final separation = (sun.signDegree - mercury.signDegree).abs();
          result['strength'] = separation > 14 ? 'Strong' : 'Moderate';
        }
        break;

      case 'Chandra-Mangal Yoga':
        final moon = positions['Moon'];
        final mars = positions['Mars'];
        if (moon != null && mars != null && moon.sign == mars.sign) {
          final moonHouse = _getHouseFromSign(moon.sign, ascSign, signs);
          result['planets'] = ['Moon', 'Mars'];
          result['houses'] = [moonHouse];
          result['formationRule'] = 'Moon-Mars conjunction in H$moonHouse';
          result['strength'] = 'Strong';
        }
        break;

      default:
        result['formationRule'] = 'Planetary combination forming $yogaName';
    }

    return result;
  }

  Map<String, dynamic> _analyzeSpecificDosha(
    String doshaName,
    Map<String, PlanetPosition> positions,
    List<House> houses,
    String ascSign,
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

    Map<String, dynamic> result = {
      'name': doshaName,
      'planets': <String>[],
      'houses': <int>[],
      'severity': 'Moderate',
      'formationRule': '',
    };

    switch (doshaName) {
      case 'Manglik Dosha':
        final mars = positions['Mars'];
        if (mars != null) {
          final marsHouse = _getHouseFromSign(mars.sign, ascSign, signs);
          result['planets'] = ['Mars'];
          result['houses'] = [marsHouse];
          result['formationRule'] = 'Mars in H$marsHouse from Lagna';
          if (marsHouse == 7 || marsHouse == 8) {
            result['severity'] = 'High';
          } else if (mars.sign == 'Aries' ||
              mars.sign == 'Scorpio' ||
              mars.sign == 'Capricorn') {
            result['severity'] = 'Low';
          }
        }
        break;

      case 'Kaal Sarp Dosha':
        final rahu = positions['Rahu'];
        final ketu = positions['Ketu'];
        if (rahu != null && ketu != null) {
          final rahuHouse = _getHouseFromSign(rahu.sign, ascSign, signs);
          final ketuHouse = _getHouseFromSign(ketu.sign, ascSign, signs);
          result['planets'] = ['Rahu', 'Ketu'];
          result['houses'] = [rahuHouse, ketuHouse];
          result['formationRule'] = 'All planets between Rahu-Ketu axis';
          result['severity'] = 'High';
        }
        break;

      case 'Pitra Dosha':
        final sun = positions['Sun'];
        if (sun != null) {
          final sunHouse = _getHouseFromSign(sun.sign, ascSign, signs);
          result['planets'] = ['Sun'];
          result['houses'] = [sunHouse];
          result['formationRule'] = 'Sun afflicted in H$sunHouse';
          result['severity'] = 'Moderate';
        }
        break;

      case 'Guru Chandal Yoga':
        final jupiter = positions['Jupiter'];
        final rahu = positions['Rahu'];
        if (jupiter != null && rahu != null && jupiter.sign == rahu.sign) {
          final jupHouse = _getHouseFromSign(jupiter.sign, ascSign, signs);
          result['planets'] = ['Jupiter', 'Rahu'];
          result['houses'] = [jupHouse];
          result['formationRule'] = 'Jupiter-Rahu conjunction in H$jupHouse';
          result['severity'] = 'Moderate';
        }
        break;

      case 'Angarak Dosha':
        final mars = positions['Mars'];
        final rahu = positions['Rahu'];
        if (mars != null && rahu != null && mars.sign == rahu.sign) {
          final marsHouse = _getHouseFromSign(mars.sign, ascSign, signs);
          result['planets'] = ['Mars', 'Rahu'];
          result['houses'] = [marsHouse];
          result['formationRule'] = 'Mars-Rahu conjunction in H$marsHouse';
          result['severity'] = 'High';
        }
        break;

      default:
        result['formationRule'] = 'Planetary affliction causing $doshaName';
    }

    return result;
  }

  int _getHouseFromSign(String planetSign, String ascSign, List<String> signs) {
    final ascIndex = signs.indexOf(ascSign);
    final planetIndex = signs.indexOf(planetSign);
    return ((planetIndex - ascIndex + 12) % 12) + 1;
  }

  bool _isInKendra(int house) {
    return [1, 4, 7, 10].contains(house);
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
// YOGA HERO CARD - Interactive
// ═══════════════════════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════
// YOGA HERO CARD - Minimal Elegant Design
// ═══════════════════════════════════════════════════════════════════════════
class _YogaHeroCard extends StatefulWidget {
  final int yogaCount;
  final int doshaCount;
  final int strongYogas;
  final int partialYogas;
  final int severeDoshas;
  final String ascendant;

  const _YogaHeroCard({
    required this.yogaCount,
    required this.doshaCount,
    required this.strongYogas,
    required this.partialYogas,
    required this.severeDoshas,
    required this.ascendant,
  });

  @override
  State<_YogaHeroCard> createState() => _YogaHeroCardState();
}

class _YogaHeroCardState extends State<_YogaHeroCard> {
  bool _isPressed = false;

  Color _getBalanceColor(int balance) {
    if (balance >= 3) return _Colors.emerald;
    if (balance >= 0) return _Colors.sky;
    if (balance >= -2) return _Colors.amber;
    return _Colors.coral;
  }

  String _getBalanceStatus(int balance, int yogas, int doshas, AppLocalizations l10n) {
    if (yogas > 0 && doshas == 0) return l10n.yogas_balance_excellent;
    if (balance >= 3) return l10n.yogas_balance_veryGood;
    if (balance >= 1) return l10n.yogas_balance_good;
    if (balance >= -1) return l10n.yogas_balance_mixed;
    if (balance >= -3) return l10n.yogas_balance_challenging;
    return l10n.yogas_balance_needsAttention;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final balance = widget.yogaCount - widget.severeDoshas;
    final balanceStatus = _getBalanceStatus(
      balance,
      widget.yogaCount,
      widget.doshaCount,
      l10n,
    );
    final balanceColor = _getBalanceColor(balance);
    final ascendantColor = _getZodiacColor(widget.ascendant);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        final l10n = AppLocalizations.of(context);
        _showInsightSheet(
          context,
          _getYogaOverviewInsight(
            widget.yogaCount,
            widget.doshaCount,
            widget.strongYogas,
            widget.severeDoshas,
            widget.ascendant,
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
            // Header row - Balance indicator + Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Minimal balance indicator
                _MinimalYogaBalanceIndicator(
                  yogaCount: widget.yogaCount,
                  doshaCount: widget.doshaCount,
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
                            l10n.yogas_overview_title,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6A6778),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Yogas/Doshas inline stats
                      Row(
                        children: [
                          _MinimalYogaStat(
                            value: widget.yogaCount,
                            label: l10n.yogas_yogas,
                            color: _Colors.gold,
                            isPositive: true,
                          ),
                          const SizedBox(width: 16),
                          _MinimalYogaStat(
                            value: widget.doshaCount,
                            label: l10n.yogas_doshas,
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

            // Bottom row - Ascendant + Strength stats
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0D14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Strength stats inline
                  _MinimalStrengthStat(
                    value: widget.strongYogas,
                    label: l10n.yogas_strong,
                    color: _Colors.emerald,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 1,
                    height: 14,
                    color: const Color(0xFF2A2838),
                  ),
                  _MinimalStrengthStat(
                    value: widget.partialYogas,
                    label: l10n.yogas_moderate,
                    color: _Colors.amber,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 1,
                    height: 14,
                    color: const Color(0xFF2A2838),
                  ),
                  _MinimalStrengthStat(
                    value: widget.severeDoshas,
                    label: l10n.yogas_severe,
                    color: _Colors.coral,
                  ),
                  const Spacer(),
                  // Lagna with zodiac image
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: ascendantColor.withOpacity(0.2),
                          blurRadius: 4,
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                        _getZodiacImagePath(widget.ascendant),
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              color: ascendantColor.withOpacity(0.15),
                              child: Center(
                                child: Text(
                                  _getSignSymbol(widget.ascendant),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: ascendantColor,
                                  ),
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getLocalizedZodiacSign(widget.ascendant, l10n),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ascendantColor,
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

// Minimal Balance Indicator - Simple visual for yoga/dosha ratio
class _MinimalYogaBalanceIndicator extends StatelessWidget {
  final int yogaCount;
  final int doshaCount;
  final Color color;

  const _MinimalYogaBalanceIndicator({
    required this.yogaCount,
    required this.doshaCount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final balance = yogaCount - doshaCount;
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
          Text(
            '✦',
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
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

// Minimal Yoga Stat - Inline yoga/dosha count
class _MinimalYogaStat extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  final bool isPositive;

  const _MinimalYogaStat({
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

// Minimal Strength Stat - For strong/moderate/severe counts
class _MinimalStrengthStat extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _MinimalStrengthStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
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
            fontSize: 9,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF7C7889),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// YOGA TYPE LEGEND - Minimal Design
// ═══════════════════════════════════════════════════════════════════════════
class _YogaTypeLegend extends StatelessWidget {
  final bool isYoga;

  const _YogaTypeLegend({required this.isYoga});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items =
        isYoga
            ? [
              (l10n.yogas_type_raja, _Colors.gold),
              (l10n.yogas_type_dhana, _Colors.emerald),
              (l10n.yogas_type_mahapurusha, _Colors.violet),
              (l10n.yogas_type_lunar, _Colors.sky),
            ]
            : [
              (l10n.yogas_severe, _Colors.coral),
              (l10n.yogas_moderate, _Colors.amber),
              (l10n.yogas_mild, _Colors.sky),
            ];

    return Row(
      children:
          items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _MinimalLegendItem(
                    label: item.$1,
                    color: item.$2,
                    isYoga: isYoga,
                  ),
                ),
              )
              .toList(),
    );
  }
}

class _MinimalLegendItem extends StatefulWidget {
  final String label;
  final Color color;
  final bool isYoga;

  const _MinimalLegendItem({
    required this.label,
    required this.color,
    required this.isYoga,
  });

  @override
  State<_MinimalLegendItem> createState() => _MinimalLegendItemState();
}

class _MinimalLegendItemState extends State<_MinimalLegendItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        _showInsightSheet(
          context,
          _getYogaTypeInsight(widget.label, widget.isYoga, l10n),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(_isPressed ? 1.0 : 0.7),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: _isPressed ? widget.color : const Color(0xFF7A7686),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EMPTY STATE CARD - Interactive
// ═══════════════════════════════════════════════════════════════════════════
class _EmptyStateCard extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  const _EmptyStateCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  State<_EmptyStateCard> createState() => _EmptyStateCardState();
}

class _EmptyStateCardState extends State<_EmptyStateCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isNoYogas = widget.title.contains(l10n.yogas_noYogasDetected) || widget.title.contains('No Yogas');

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        _showInsightSheet(
          context,
          InsightData(
            title: isNoYogas ? l10n.yogas_noSpecialYogas : l10n.yogas_doshaFreeChart,
            value: widget.title,
            description: isNoYogas ? l10n.yogas_emptyState_noYogas_desc : l10n.yogas_emptyState_noDoshas_desc,
            significance: widget.message,
            keyPoints:
                isNoYogas
                    ? [
                      l10n.yogas_emptyState_noYogas_kp1,
                      l10n.yogas_emptyState_noYogas_kp2,
                      l10n.yogas_emptyState_noYogas_kp3,
                      l10n.yogas_emptyState_noYogas_kp4,
                      l10n.yogas_emptyState_noYogas_kp5,
                    ]
                    : [
                      l10n.yogas_emptyState_noDoshas_kp1,
                      l10n.yogas_emptyState_noDoshas_kp2,
                      l10n.yogas_emptyState_noDoshas_kp3,
                      l10n.yogas_emptyState_noDoshas_kp4,
                      l10n.yogas_emptyState_noDoshas_kp5,
                    ],
            accentColor: widget.color,
            icon: widget.icon,
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _Colors.surface.withOpacity(_isPressed ? 0.6 : 0.4),
          borderRadius: BorderRadius.circular(_DesignTokens.radiusLg),
          border: Border.all(
            color: widget.color.withOpacity(_isPressed ? 0.4 : 0.2),
            width: _isPressed ? 1 : 0.5,
          ),
          boxShadow:
              _isPressed
                  ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.1),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ]
                  : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(_isPressed ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(12),
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
              child: Center(
                child: Icon(widget.icon, size: 24, color: widget.color),
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
                        widget.title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _Colors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 100),
                        opacity: _isPressed ? 1.0 : 0.4,
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: widget.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.message,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _Colors.textSecondary,
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
// PREMIUM YOGA CARD - Elegant Minimal Design
// ═══════════════════════════════════════════════════════════════════════════
class _PremiumYogaCard extends StatefulWidget {
  final Map<String, dynamic> yogaData;
  final int index;
  final bool isDosha;
  final Map<String, PlanetPosition> planetPositions;

  const _PremiumYogaCard({
    required this.yogaData,
    required this.index,
    required this.isDosha,
    required this.planetPositions,
  });

  @override
  State<_PremiumYogaCard> createState() => _PremiumYogaCardState();
}

class _PremiumYogaCardState extends State<_PremiumYogaCard> {
  bool _isPressed = false;

  Color _getStrengthColor(String strength) {
    switch (strength) {
      case 'Strong':
        return _Colors.emerald;
      case 'High':
        return _Colors.coral;
      case 'Moderate':
        return _Colors.amber;
      case 'Low':
        return _Colors.sky;
      default:
        return _Colors.amber;
    }
  }

  String _getStrengthSymbol(String strength) {
    switch (strength) {
      case 'Strong':
        return '↑↑';
      case 'High':
        return '!!';
      case 'Moderate':
        return '—';
      case 'Low':
        return '↓';
      default:
        return '—';
    }
  }

  Color _getTypeColor(String type) {
    if (type.contains('Raja')) return _Colors.gold;
    if (type.contains('Dhana')) return _Colors.emerald;
    if (type.contains('Pancha') || type.contains('Mahapurusha'))
      return _Colors.violet;
    if (type.contains('Lunar')) return _Colors.sky;
    if (type.contains('Dosha') || type.contains('Grahan')) return _Colors.coral;
    return _Colors.textTertiary;
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _showYogaDetails(
      context,
      widget.yogaData['name'] as String,
      widget.isDosha,
      widget.yogaData,
    );
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final yogaName = widget.yogaData['name'] as String;
    final planets = widget.yogaData['planets'] as List<String>? ?? [];
    final strength =
        widget.yogaData['strength'] as String? ??
        widget.yogaData['severity'] as String? ??
        'Moderate';
    final formationRule = widget.yogaData['formationRule'] as String? ?? '';
    final yogaInfo = _getYogaInfo(yogaName, widget.isDosha);
    
    final yogaTypeEnglish = yogaInfo['type'] ?? (widget.isDosha ? 'Dosha' : 'Yoga');
    final localizedType = _getLocalizedYogaType(yogaTypeEnglish, l10n);
    final localizedStrength = _getLocalizedStrength(strength, l10n);

    final strengthColor = _getStrengthColor(strength);
    final typeColor = _getTypeColor(yogaInfo['type'] ?? '');

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFF1A1820) : const Color(0xFF141218),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Yoga name and type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        yogaName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _Colors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        localizedType,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: typeColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Strength indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: strengthColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getStrengthSymbol(strength),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: strengthColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        localizedStrength,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: strengthColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Planets involved
            if (planets.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  ...planets.take(3).map((planet) {
                    final pos = widget.planetPositions[planet];
                    final planetColor = _getPlanetColor(planet);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getPlanetSymbol(planet),
                            style: TextStyle(fontSize: 12, color: planetColor),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            pos != null
                                ? _getLocalizedZodiacAbbr(pos.sign, l10n)
                                : planet.substring(0, 3),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF9590A0),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (planets.length > 3)
                    Text(
                      '+${planets.length - 3}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF6B6779),
                      ),
                    ),
                ],
              ),
            ],

            // Formation rule
            if (formationRule.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formationRule,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B6779),
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 100),
                    opacity: _isPressed ? 1.0 : 0.4,
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: const Color(0xFF6B6779),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showYogaDetails(
    BuildContext context,
    String yogaName,
    bool isDosha,
    Map<String, dynamic> yogaData,
  ) {
    final l10n = AppLocalizations.of(context);
    final color = isDosha ? _Colors.coral : _Colors.gold;
    final details = _getFullYogaDetails(yogaName, isDosha, l10n);
    final planets = yogaData['planets'] as List<String>? ?? [];
    final formationRule = yogaData['formationRule'] as String? ?? '';
    final strength =
        yogaData['strength'] as String? ??
        yogaData['severity'] as String? ??
        l10n.yogas_moderate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: _Colors.bgSecondary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border.all(color: color.withOpacity(0.3), width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _Colors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    color.withOpacity(0.2),
                                    color.withOpacity(0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: color.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  isDosha
                                      ? Icons.warning_amber_rounded
                                      : Icons.auto_awesome_rounded,
                                  color: color,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    yogaName,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: _Colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          details['type']!,
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStrengthColor(
                                            strength,
                                          ).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          strength,
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: _getStrengthColor(strength),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          children: [
                            if (planets.isNotEmpty || formationRule.isNotEmpty)
                              _DetailSection(
                                title: l10n.yogas_formation,
                                icon: Icons.architecture_rounded,
                                color: _Colors.violet,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (planets.isNotEmpty) ...[
                                      Text(
                                        l10n.yogas_planetsInvolved,
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: _Colors.textTertiary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children:
                                            planets.map((planet) {
                                              final pos =
                                                  widget
                                                      .planetPositions[planet];
                                              final planetColor =
                                                  _getPlanetColor(planet);

                                              return Container(
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: planetColor
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: planetColor
                                                        .withOpacity(0.2),
                                                    width: 0.5,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      _getPlanetSymbol(planet),
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: planetColor,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          planet,
                                                          style: GoogleFonts.inter(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                _Colors
                                                                    .textPrimary,
                                                          ),
                                                        ),
                                                        if (pos != null)
                                                          Text(
                                                            '${pos.sign} ${pos.signDegree.toStringAsFixed(1)}°',
                                                            style: GoogleFonts.jetBrainsMono(
                                                              fontSize: 9,
                                                              color:
                                                                  _Colors
                                                                      .textTertiary,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    if (formationRule.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: _Colors.surface.withOpacity(
                                            0.4,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.rule_rounded,
                                              size: 14,
                                              color: _Colors.textTertiary,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                formationRule,
                                                style:
                                                    GoogleFonts.jetBrainsMono(
                                                      fontSize: 10,
                                                      color:
                                                          _Colors.textSecondary,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 16),

                            _DetailSection(
                              title: l10n.yogas_whatIs(yogaName),
                              icon: Icons.info_outline_rounded,
                              color: _Colors.sky,
                              child: Text(
                                details['description']!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: _Colors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            _DetailSection(
                              title: isDosha ? l10n.yogas_potentialEffects : l10n.yogas_benefits,
                              icon:
                                  isDosha
                                      ? Icons.warning_amber_outlined
                                      : Icons.star_outline_rounded,
                              color: isDosha ? _Colors.amber : _Colors.emerald,
                              child: Text(
                                details['effects']!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: _Colors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            _DetailSection(
                              title: isDosha ? l10n.yogas_remedies : l10n.yogas_howToStrengthen,
                              icon: Icons.healing_rounded,
                              color: _Colors.sky,
                              child: Text(
                                details['remedies']!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: _Colors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _DetailSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _Colors.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INSIGHTS GRID - Interactive
// ═══════════════════════════════════════════════════════════════════════════
class _InsightsGrid extends StatelessWidget {
  final bool hasKaalSarp;
  final bool hasManglik;

  const _InsightsGrid({this.hasKaalSarp = false, this.hasManglik = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InteractiveInsightCard(
                title: l10n.yogas_insight_understanding,
                description: l10n.yogas_insight_understanding_desc,
                icon: Icons.lightbulb_outline_rounded,
                color: _Colors.violet,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InteractiveInsightCard(
                title: l10n.yogas_insight_activation,
                description: l10n.yogas_insight_activation_desc,
                icon: Icons.schedule_rounded,
                color: _Colors.emerald,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _InteractiveInsightCard(
                title: l10n.yogas_insight_strength,
                description: l10n.yogas_insight_strength_desc,
                icon: Icons.fitness_center_rounded,
                color: _Colors.amber,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InteractiveInsightCard(
                title: l10n.yogas_insight_remedies,
                description: l10n.yogas_insight_remedies_desc,
                icon: Icons.healing_outlined,
                color: _Colors.sky,
              ),
            ),
          ],
        ),
        if (hasKaalSarp || hasManglik) ...[
          const SizedBox(height: 16),
          if (hasKaalSarp)
            _InteractiveRemedyCard(
              title: l10n.yogas_kaalSarpRemedy,
              description: l10n.yogas_kaalSarpRemedy_desc,
              icon: Icons.auto_fix_high_rounded,
              color: _Colors.coral,
              doshaType: 'Kaal Sarp Dosha',
            ),
          if (hasManglik) ...[
            const SizedBox(height: 10),
            _InteractiveRemedyCard(
              title: l10n.yogas_manglikRemedy,
              description: l10n.yogas_manglikRemedy_desc,
              icon: Icons.auto_fix_high_rounded,
              color: _Colors.coral,
              doshaType: 'Manglik Dosha',
            ),
          ],
        ],
      ],
    );
  }
}

class _InteractiveInsightCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _InteractiveInsightCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  State<_InteractiveInsightCard> createState() =>
      _InteractiveInsightCardState();
}

class _InteractiveInsightCardState extends State<_InteractiveInsightCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        _showInsightSheet(
          context,
          _getInsightCardInsight(
            widget.title,
            widget.description,
            widget.color,
            l10n,
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _Colors.surface.withOpacity(_isPressed ? 0.6 : 0.4),
          borderRadius: BorderRadius.circular(_DesignTokens.radiusMd),
          border: Border.all(
            color: widget.color.withOpacity(_isPressed ? 0.35 : 0.15),
            width: _isPressed ? 1 : 0.5,
          ),
          boxShadow:
              _isPressed
                  ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.12),
                      blurRadius: 10,
                      spreadRadius: -2,
                    ),
                  ]
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(_isPressed ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow:
                        _isPressed
                            ? [
                              BoxShadow(
                                color: widget.color.withOpacity(0.2),
                                blurRadius: 6,
                                spreadRadius: -2,
                              ),
                            ]
                            : null,
                  ),
                  child: Icon(widget.icon, size: 14, color: widget.color),
                ),
                const Spacer(),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: _isPressed ? 1.0 : 0.3,
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 12,
                    color: widget.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.title,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _Colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.description,
              style: GoogleFonts.inter(
                fontSize: 9,
                color: _Colors.textTertiary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveRemedyCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String doshaType;

  const _InteractiveRemedyCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.doshaType,
  });

  @override
  State<_InteractiveRemedyCard> createState() => _InteractiveRemedyCardState();
}

class _InteractiveRemedyCardState extends State<_InteractiveRemedyCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isKaalSarp = widget.doshaType == 'Kaal Sarp Dosha';
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        _showInsightSheet(
          context,
          InsightData(
            title: l10n.yogas_doshaRemedy,
            value: widget.doshaType,
            description: isKaalSarp ? l10n.yogas_kaalSarpDosha_desc : l10n.yogas_manglikDosha_desc,
            significance: widget.description,
            keyPoints:
                isKaalSarp
                    ? [
                      l10n.yogas_kaalSarp_kp1,
                      l10n.yogas_kaalSarp_kp2,
                      l10n.yogas_kaalSarp_kp3,
                      l10n.yogas_kaalSarp_kp4,
                      l10n.yogas_kaalSarp_kp5,
                    ]
                    : [
                      l10n.yogas_manglik_kp1,
                      l10n.yogas_manglik_kp2,
                      l10n.yogas_manglik_kp3,
                      l10n.yogas_manglik_kp4,
                      l10n.yogas_manglik_kp5,
                    ],
            accentColor: widget.color,
            icon: widget.icon,
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.color.withOpacity(_isPressed ? 0.18 : 0.1),
              widget.color.withOpacity(_isPressed ? 0.08 : 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(_DesignTokens.radiusMd),
          border: Border.all(
            color: widget.color.withOpacity(_isPressed ? 0.4 : 0.2),
            width: _isPressed ? 1 : 0.5,
          ),
          boxShadow:
              _isPressed
                  ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.15),
                      blurRadius: 12,
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
                color: widget.color.withOpacity(_isPressed ? 0.25 : 0.15),
                borderRadius: BorderRadius.circular(10),
                boxShadow:
                    _isPressed
                        ? [
                          BoxShadow(
                            color: widget.color.withOpacity(0.25),
                            blurRadius: 8,
                            spreadRadius: -2,
                          ),
                        ]
                        : null,
              ),
              child: Icon(widget.icon, size: 18, color: widget.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: widget.color,
                        ),
                      ),
                      const Spacer(),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 100),
                        opacity: _isPressed ? 1.0 : 0.4,
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: 12,
                          color: widget.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.description,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: _Colors.textSecondary,
                      height: 1.3,
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

Map<String, String> _getYogaInfo(String yogaName, bool isDosha) {
  // Returns English type keys that will be localized later
  final yogaInfoMap = {
    'Hamsa Yoga': {'type': 'Pancha Mahapurusha'},
    'Malavya Yoga': {'type': 'Pancha Mahapurusha'},
    'Bhadra Yoga': {'type': 'Pancha Mahapurusha'},
    'Ruchaka Yoga': {'type': 'Pancha Mahapurusha'},
    'Sasa Yoga': {'type': 'Pancha Mahapurusha'},
    'Gajakesari Yoga': {'type': 'Raja Yoga'},
    'Budhaditya Yoga': {'type': 'Raja Yoga'},
    'Chandra-Mangal Yoga': {'type': 'Dhana Yoga'},
    'Lakshmi Yoga': {'type': 'Dhana Yoga'},
    'Dhana Yoga': {'type': 'Dhana Yoga'},
    'Sunafa Yoga': {'type': 'Lunar Yoga'},
    'Anafa Yoga': {'type': 'Lunar Yoga'},
    'Durudhura Yoga': {'type': 'Benefic Yoga'},
    'Manglik Dosha': {'type': 'Major Dosha'},
    'Kaal Sarp Dosha': {'type': 'Major Dosha'},
    'Pitra Dosha': {'type': 'Ancestral'},
    'Guru Chandal Yoga': {'type': 'Conjunction Dosha'},
    'Angarak Dosha': {'type': 'Major Dosha'},
  };

  return yogaInfoMap[yogaName] ?? {'type': isDosha ? 'Dosha' : 'Benefic Yoga'};
}

String _getLocalizedYogaType(String englishType, AppLocalizations l10n) {
  switch (englishType) {
    case 'Raja Yoga': return l10n.yogas_type_rajaYoga;
    case 'Dhana Yoga': return l10n.yogas_type_dhanaYoga;
    case 'Lunar Yoga': return l10n.yogas_type_lunarYoga;
    case 'Pancha Mahapurusha': return l10n.yogas_type_panchaMahapurusha;
    case 'Benefic Yoga': return l10n.yogas_type_beneficYoga;
    case 'Major Dosha': return l10n.yogas_type_majorDosha;
    case 'Ancestral': return l10n.yogas_type_ancestral;
    case 'Conjunction Dosha': return l10n.yogas_type_conjunctionDosha;
    case 'Dosha': return l10n.yogas_type_dosha;
    case 'Yoga': return l10n.yogas_type_yoga;
    default: return englishType;
  }
}

String _getLocalizedStrength(String englishStrength, AppLocalizations l10n) {
  switch (englishStrength) {
    case 'Strong': return l10n.yogas_strength_strong;
    case 'Moderate': return l10n.yogas_strength_moderate;
    case 'High': return l10n.yogas_strength_high;
    case 'Low': return l10n.yogas_strength_low;
    default: return englishStrength;
  }
}

String _getLocalizedZodiacAbbr(String sign, AppLocalizations l10n) {
  switch (sign) {
    case 'Aries': return l10n.zodiac_aries.length > 3 ? l10n.zodiac_aries.substring(0, 3) : l10n.zodiac_aries;
    case 'Taurus': return l10n.zodiac_taurus.length > 3 ? l10n.zodiac_taurus.substring(0, 3) : l10n.zodiac_taurus;
    case 'Gemini': return l10n.zodiac_gemini.length > 3 ? l10n.zodiac_gemini.substring(0, 3) : l10n.zodiac_gemini;
    case 'Cancer': return l10n.zodiac_cancer.length > 3 ? l10n.zodiac_cancer.substring(0, 3) : l10n.zodiac_cancer;
    case 'Leo': return l10n.zodiac_leo.length > 3 ? l10n.zodiac_leo.substring(0, 3) : l10n.zodiac_leo;
    case 'Virgo': return l10n.zodiac_virgo.length > 3 ? l10n.zodiac_virgo.substring(0, 3) : l10n.zodiac_virgo;
    case 'Libra': return l10n.zodiac_libra.length > 3 ? l10n.zodiac_libra.substring(0, 3) : l10n.zodiac_libra;
    case 'Scorpio': return l10n.zodiac_scorpio.length > 3 ? l10n.zodiac_scorpio.substring(0, 3) : l10n.zodiac_scorpio;
    case 'Sagittarius': return l10n.zodiac_sagittarius.length > 3 ? l10n.zodiac_sagittarius.substring(0, 3) : l10n.zodiac_sagittarius;
    case 'Capricorn': return l10n.zodiac_capricorn.length > 3 ? l10n.zodiac_capricorn.substring(0, 3) : l10n.zodiac_capricorn;
    case 'Aquarius': return l10n.zodiac_aquarius.length > 3 ? l10n.zodiac_aquarius.substring(0, 3) : l10n.zodiac_aquarius;
    case 'Pisces': return l10n.zodiac_pisces.length > 3 ? l10n.zodiac_pisces.substring(0, 3) : l10n.zodiac_pisces;
    default: return sign.length > 3 ? sign.substring(0, 3) : sign;
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

Map<String, String> _getFullYogaDetails(String yogaName, bool isDosha, AppLocalizations l10n) {
  // Note: These yoga-specific descriptions are kept in English as they are technical astrological terms
  // that may not translate well. The structure labels are localized.
  final detailsMap = {
    'Hamsa Yoga': {
      'type': 'Pancha Mahapurusha Yoga',
      'description':
          'Hamsa Yoga forms when Jupiter is in Kendra in own/exalted sign. One of the five great person yogas.',
      'effects':
          'Blessed with wisdom, spiritual inclination, respect from learned people, and virtuous life.',
      'remedies':
          'Worship Lord Vishnu, study scriptures, donate yellow items on Thursdays.',
    },
    'Gajakesari Yoga': {
      'type': 'Raja Yoga',
      'description':
          'One of the most auspicious yogas, formed when Jupiter is in a Kendra from the Moon.',
      'effects':
          'Grants wisdom, intelligence, excellent reputation, wealth, and leadership.',
      'remedies':
          'Worship Lord Ganesha and Jupiter, chant Guru mantras on Thursdays.',
    },
    'Manglik Dosha': {
      'type': 'Major Dosha',
      'description':
          'Formed when Mars is in 1st, 4th, 7th, 8th, or 12th house from Ascendant.',
      'effects': 'May cause delays in marriage or challenges in married life.',
      'remedies':
          'Perform Mangal Shanti Puja, chant Hanuman Chalisa, fast on Tuesdays.',
    },
    'Kaal Sarp Dosha': {
      'type': 'Major Dosha',
      'description': 'All planets hemmed between Rahu and Ketu axis.',
      'effects':
          'May bring sudden ups and downs, struggles, delays in success.',
      'remedies':
          'Visit Trimbakeshwar for Kaal Sarp Puja, chant Maha Mrityunjaya Mantra.',
    },
  };

  return detailsMap[yogaName] ??
      {
        'type': isDosha ? l10n.yogas_type_dosha : l10n.yogas_type_yoga,
        'description':
            isDosha
                ? 'This dosha indicates certain karmic patterns creating challenges.'
                : 'This yoga indicates beneficial combinations enhancing life areas.',
        'effects':
            isDosha
                ? 'Effects vary based on planet strength and placement.'
                : 'Benefits manifest according to overall chart strength.',
        'remedies':
            isDosha
                ? 'Consult an astrologer for personalized remedies.'
                : 'Strengthen involved planets through mantras and gemstones.',
      };
}
