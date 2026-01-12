import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart'
    show House;
import 'package:kundali_app/l10n/generated/app_localizations.dart';
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

  // Animation
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

  // Accent colors
  static const Color violet = Color(0xFF9580FF);
  static const Color emerald = Color(0xFF4ADE80);
  static const Color sky = Color(0xFF38BDF8);
  static const Color amber = Color(0xFFFBBF24);
  static const Color coral = Color(0xFFF87171);
  static const Color lavender = Color(0xFFA78BFA);
  static const Color rose = Color(0xFFF472B6);
  static const Color teal = Color(0xFF2DD4BF);
}

// ═══════════════════════════════════════════════════════════════════════════
// INSIGHT DATA MODEL
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
                          child: insight.imagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    insight.imagePath!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
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
// NAVIGATION SECTION DATA
// ═══════════════════════════════════════════════════════════════════════════
List<NavSection> _getSections(AppLocalizations l10n) => [
  NavSection(id: 'overview', label: l10n.houses_nav_overview, color: _Colors.violet),
  NavSection(id: 'kendra', label: l10n.houses_nav_kendra, color: _Colors.emerald),
  NavSection(id: 'trikona', label: l10n.houses_nav_trikona, color: _Colors.amber),
  NavSection(id: 'dusthana', label: l10n.houses_nav_dusthana, color: _Colors.coral),
  NavSection(id: 'upachaya', label: l10n.houses_nav_upachaya, color: _Colors.sky),
  NavSection(id: 'maraka', label: l10n.houses_nav_maraka, color: _Colors.lavender),
];

// Section IDs for key management
const _sectionIds = ['overview', 'kendra', 'trikona', 'dusthana', 'upachaya', 'maraka'];

// ═══════════════════════════════════════════════════════════════════════════
// HOUSES TAB - Main Widget
// ═══════════════════════════════════════════════════════════════════════════
class HousesTab extends StatefulWidget {
  final KundaliData kundaliData;

  const HousesTab({super.key, required this.kundaliData});

  @override
  State<HousesTab> createState() => _HousesTabState();
}

class _HousesTabState extends State<HousesTab> {
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

  Map<String, int> _calculateHouseStats() {
    int occupiedHouses = 0;
    int totalPlanets = 0;

    for (final house in widget.kundaliData.houses) {
      if (house.planets.isNotEmpty) {
        occupiedHouses++;
        totalPlanets += house.planets.length;
      }
    }

    return {
      'occupied': occupiedHouses,
      'empty': 12 - occupiedHouses,
      'planets': totalPlanets,
    };
  }

  List<House> _getHousesByNumbers(List<int> numbers) {
    return widget.kundaliData.houses
        .where((h) => numbers.contains(h.number))
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final houseStats = _calculateHouseStats();
    final sections = _getSections(l10n);

    return Stack(
      children: [
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
                child: _AnimatedCardWrapper(
                  child: _OverviewCard(
                    ascendant: widget.kundaliData.ascendant.sign,
                    stats: houseStats,
                    l10n: l10n,
                  ),
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // Kendra Houses (1, 4, 7, 10)
              _AnimatedSectionWrapper(
                key: _animatedKeys['kendra'],
                sectionKey: _sectionKeys['kendra']!,
                accentColor: _Colors.emerald,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: l10n.houses_kendra_title,
                      subtitle: l10n.houses_kendra_subtitle,
                      accentColor: _Colors.emerald,
                      onTap: () => _showInsightSheet(
                        context,
                        _getHouseTypeInsight('Kendra', l10n),
                      ),
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    ..._getHousesByNumbers([1, 4, 7, 10])
                        .asMap()
                        .entries
                        .map((entry) {
                      return _AnimatedCardWrapper(
                        delay: entry.key * 50,
                        child: _HouseCard(
                          house: entry.value,
                          kundaliData: widget.kundaliData,
                          accentColor: _Colors.emerald,
                          l10n: l10n,
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // Trikona Houses (5, 9)
              _AnimatedSectionWrapper(
                key: _animatedKeys['trikona'],
                sectionKey: _sectionKeys['trikona']!,
                accentColor: _Colors.amber,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: l10n.houses_trikona_title,
                      subtitle: l10n.houses_trikona_subtitle,
                      accentColor: _Colors.amber,
                      onTap: () => _showInsightSheet(
                        context,
                        _getHouseTypeInsight('Trikona', l10n),
                      ),
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    ..._getHousesByNumbers([5, 9])
                        .asMap()
                        .entries
                        .map((entry) {
                      return _AnimatedCardWrapper(
                        delay: entry.key * 50,
                        child: _HouseCard(
                          house: entry.value,
                          kundaliData: widget.kundaliData,
                          accentColor: _Colors.amber,
                          l10n: l10n,
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // Dusthana Houses (6, 8, 12)
              _AnimatedSectionWrapper(
                key: _animatedKeys['dusthana'],
                sectionKey: _sectionKeys['dusthana']!,
                accentColor: _Colors.coral,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: l10n.houses_dusthana_title,
                      subtitle: l10n.houses_dusthana_subtitle,
                      accentColor: _Colors.coral,
                      onTap: () => _showInsightSheet(
                        context,
                        _getHouseTypeInsight('Dusthana', l10n),
                      ),
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    ..._getHousesByNumbers([6, 8, 12])
                        .asMap()
                        .entries
                        .map((entry) {
                      return _AnimatedCardWrapper(
                        delay: entry.key * 50,
                        child: _HouseCard(
                          house: entry.value,
                          kundaliData: widget.kundaliData,
                          accentColor: _Colors.coral,
                          l10n: l10n,
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // Upachaya Houses (3, 11)
              _AnimatedSectionWrapper(
                key: _animatedKeys['upachaya'],
                sectionKey: _sectionKeys['upachaya']!,
                accentColor: _Colors.sky,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: l10n.houses_upachaya_title,
                      subtitle: l10n.houses_upachaya_subtitle,
                      accentColor: _Colors.sky,
                      onTap: () => _showInsightSheet(
                        context,
                        _getHouseTypeInsight('Upachaya', l10n),
                      ),
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    ..._getHousesByNumbers([3, 11])
                        .asMap()
                        .entries
                        .map((entry) {
                      return _AnimatedCardWrapper(
                        delay: entry.key * 50,
                        child: _HouseCard(
                          house: entry.value,
                          kundaliData: widget.kundaliData,
                          accentColor: _Colors.sky,
                          l10n: l10n,
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: _DesignTokens.space24),

              // Maraka Houses (2, 7)
              _AnimatedSectionWrapper(
                key: _animatedKeys['maraka'],
                sectionKey: _sectionKeys['maraka']!,
                accentColor: _Colors.lavender,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedSectionHeader(
                      title: l10n.houses_maraka_title,
                      subtitle: l10n.houses_maraka_subtitle,
                      accentColor: _Colors.lavender,
                      onTap: () => _showInsightSheet(
                        context,
                        _getHouseTypeInsight('Maraka', l10n),
                      ),
                    ),
                    const SizedBox(height: _DesignTokens.space12),
                    ..._getHousesByNumbers([2, 7])
                        .asMap()
                        .entries
                        .map((entry) {
                      return _AnimatedCardWrapper(
                        delay: entry.key * 50,
                        child: _HouseCard(
                          house: entry.value,
                          kundaliData: widget.kundaliData,
                          accentColor: _Colors.lavender,
                          l10n: l10n,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Floating navigation
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
  final VoidCallback? onTap;

  const _AnimatedSectionHeader({
    required this.title,
    this.subtitle,
    required this.accentColor,
    this.onTap,
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
        tween:
            Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
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
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
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
                            const SizedBox(width: _DesignTokens.space8),
                            Text(
                              widget.subtitle!,
                              style: _DesignTokens.labelXs.copyWith(
                                color: _Colors.textTertiary.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final maxWidth =
                              math.min(constraints.maxWidth * 0.3, 40.0);
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
                if (widget.onTap != null)
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: widget.accentColor.withOpacity(0.5),
                  ),
              ],
            ),
          );
        },
      ),
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
        tween:
            Tween(begin: 1.0, end: 1.02).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.02, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 65,
      ),
    ]).animate(_controller);

    _shadowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween:
            Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
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
// CARD COMPONENT
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
// OVERVIEW CARD
// ═══════════════════════════════════════════════════════════════════════════
class _OverviewCard extends StatelessWidget {
  final String ascendant;
  final Map<String, int> stats;
  final AppLocalizations l10n;

  const _OverviewCard({required this.ascendant, required this.stats, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final zodiacColor = _getZodiacColor(ascendant);

    return _Card(
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              // Zodiac image
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_DesignTokens.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: zodiacColor.withOpacity(0.25),
                      blurRadius: 12,
                      spreadRadius: -2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_DesignTokens.radiusMd),
                  child: Image.asset(
                    _getZodiacImagePath(ascendant),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: zodiacColor.withOpacity(0.12),
                        child: Center(
                          child: Text(
                            _getSignSymbol(ascendant),
                            style: TextStyle(fontSize: 28, color: zodiacColor),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: _DesignTokens.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _Colors.violet.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l10n.houses_bhavas,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: _Colors.violet,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: _DesignTokens.space6),
                    Text(l10n.houses_lagna(ascendant), style: _DesignTokens.titleMd),
                    const SizedBox(height: _DesignTokens.space2),
                    Text(
                      l10n.houses_startingFrom(ascendant),
                      style: _DesignTokens.labelXs,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: _DesignTokens.space16),

          // Stats row
          Container(
            padding: const EdgeInsets.all(_DesignTokens.space12),
            decoration: BoxDecoration(
              color: _Colors.bgSecondary,
              borderRadius: BorderRadius.circular(_DesignTokens.radiusMd),
            ),
            child: Row(
              children: [
                _StatItem(
                  value: '${stats['occupied']}',
                  label: l10n.houses_occupied,
                  color: _Colors.emerald,
                ),
                _StatDivider(),
                _StatItem(
                  value: '${stats['empty']}',
                  label: l10n.houses_empty,
                  color: _Colors.textTertiary,
                ),
                _StatDivider(),
                _StatItem(
                  value: '${stats['planets']}',
                  label: l10n.houses_planetsCount,
                  color: _Colors.amber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: _DesignTokens.titleMd.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: _DesignTokens.space2),
          Text(label, style: _DesignTokens.labelXs),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: _Colors.border);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HOUSE CARD - Redesigned to match details_tab style
// ═══════════════════════════════════════════════════════════════════════════
class _HouseCard extends StatefulWidget {
  final House house;
  final KundaliData kundaliData;
  final Color accentColor;
  final AppLocalizations l10n;

  const _HouseCard({
    required this.house,
    required this.kundaliData,
    required this.accentColor,
    required this.l10n,
  });

  @override
  State<_HouseCard> createState() => _HouseCardState();
}

class _HouseCardState extends State<_HouseCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    _showInsightSheet(context, _getHouseInsight(widget.house, widget.l10n));
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  int _findPlanetHouse(String planet) {
    for (final h in widget.kundaliData.houses) {
      if (h.planets.contains(planet)) return h.number;
    }
    final planetPos = widget.kundaliData.planetPositions[planet];
    if (planetPos != null) {
      for (final h in widget.kundaliData.houses) {
        if (h.sign == planetPos.sign) return h.number;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final houseLord = _getSignLord(widget.house.sign);
    final lordPlacement = _findPlanetHouse(houseLord);
    final hasPlanets = widget.house.planets.isNotEmpty;
    final isFirstHouse = widget.house.number == 1;
    final zodiacColor = _getZodiacColor(widget.house.sign);

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
        child: Container(
          margin: const EdgeInsets.only(bottom: _DesignTokens.space10),
          child: _Card(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Main content
                Padding(
                  padding: const EdgeInsets.all(_DesignTokens.space16),
                  child: Row(
                    children: [
                      // Zodiac image
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(_DesignTokens.radiusMd),
                          boxShadow: [
                            BoxShadow(
                              color: zodiacColor.withOpacity(
                                _isPressed ? 0.25 : 0.12,
                              ),
                              blurRadius: _isPressed ? 14 : 10,
                              spreadRadius: -4,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(_DesignTokens.radiusMd),
                          child: Image.asset(
                            _getZodiacImagePath(widget.house.sign),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: zodiacColor.withOpacity(0.12),
                                child: Center(
                                  child: Text(
                                    _getSignSymbol(widget.house.sign),
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: zodiacColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: _DesignTokens.space12),
                      // House info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.l10n.houses_houseNumber(widget.house.number),
                                  style: _DesignTokens.titleSm.copyWith(
                                    color: widget.accentColor,
                                  ),
                                ),
                                const SizedBox(width: _DesignTokens.space6),
                                if (isFirstHouse)
                                  _StatusChip(
                                    label: widget.l10n.houses_lagnaChip,
                                    color: _Colors.violet,
                                  ),
                              ],
                            ),
                            const SizedBox(height: _DesignTokens.space4),
                            Text(
                              widget.l10n.houses_houseBhava(_getHouseName(widget.house.number, widget.l10n), _getLocalizedSign(widget.house.sign, widget.l10n)),
                              style: _DesignTokens.labelSm,
                            ),
                            const SizedBox(height: _DesignTokens.space2),
                            Text(
                              '${widget.house.cuspDegree.toStringAsFixed(1)}°',
                              style: _DesignTokens.mono.copyWith(
                                fontSize: 10,
                                color: _Colors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Lord info
                      _LordBadge(
                        lord: houseLord,
                        placement: lordPlacement,
                      ),
                    ],
                  ),
                ),

                // Details row
                Container(
                  padding: const EdgeInsets.all(_DesignTokens.space12),
                  decoration: const BoxDecoration(
                    color: _Colors.bgSecondary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(_DesignTokens.radiusLg - 1),
                      bottomRight: Radius.circular(_DesignTokens.radiusLg - 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Significations
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 12,
                            color: _Colors.textTertiary,
                          ),
                          const SizedBox(width: _DesignTokens.space6),
                          Expanded(
                            child: Text(
                              _getHouseSignifications(widget.house.number, widget.l10n),
                              style: _DesignTokens.labelXs.copyWith(
                                color: _Colors.textTertiary.withOpacity(0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // Planets
                      if (hasPlanets) ...[
                        const SizedBox(height: _DesignTokens.space10),
                        Wrap(
                          spacing: _DesignTokens.space6,
                          runSpacing: _DesignTokens.space6,
                          children: widget.house.planets.map((planet) {
                            final pos =
                                widget.kundaliData.planetPositions[planet];
                            return _PlanetChip(
                              planet: planet,
                              degree: pos?.signDegree,
                              isRetrograde: pos?.isRetrograde ?? false,
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
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
// SUPPORTING WIDGETS
// ═══════════════════════════════════════════════════════════════════════════
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _DesignTokens.space6,
        vertical: _DesignTokens.space2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(_DesignTokens.radiusSm),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _LordBadge extends StatelessWidget {
  final String lord;
  final int placement;

  const _LordBadge({required this.lord, required this.placement});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lordColor = _getPlanetColor(lord);

    return Container(
      padding: const EdgeInsets.all(_DesignTokens.space8),
      decoration: BoxDecoration(
        color: lordColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(_DesignTokens.radiusSm),
        border: Border.all(
          color: lordColor.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: lordColor.withOpacity(0.25),
                  blurRadius: 4,
                  spreadRadius: -1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                _getPlanetImagePath(lord),
                width: 24,
                height: 24,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: lordColor.withOpacity(0.15),
                    child: Center(
                      child: Text(
                        _getPlanetSymbol(lord),
                        style: TextStyle(fontSize: 12, color: lordColor),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: _DesignTokens.space8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getLocalizedPlanetName(lord, l10n),
                style: _DesignTokens.labelSm.copyWith(
                  color: lordColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (placement > 0)
                Text(
                  l10n.houses_inHouse(placement),
                  style: _DesignTokens.mono.copyWith(
                    fontSize: 9,
                    color: _Colors.textTertiary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanetChip extends StatelessWidget {
  final String planet;
  final double? degree;
  final bool isRetrograde;

  const _PlanetChip({
    required this.planet,
    this.degree,
    this.isRetrograde = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _getPlanetColor(planet);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _DesignTokens.space8,
        vertical: _DesignTokens.space6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(_DesignTokens.radiusSm),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 4,
                  spreadRadius: -1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                _getPlanetImagePath(planet),
                width: 20,
                height: 20,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: color.withOpacity(0.15),
                    child: Center(
                      child: Text(
                        _getPlanetSymbol(planet),
                        style: TextStyle(fontSize: 10, color: color),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: _DesignTokens.space6),
          Text(
            _getLocalizedPlanetName(planet, l10n),
            style: _DesignTokens.labelSm.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isRetrograde) ...[
            const SizedBox(width: _DesignTokens.space4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: _Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'R',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: _Colors.amber,
                ),
              ),
            ),
          ],
          if (degree != null) ...[
            const SizedBox(width: _DesignTokens.space6),
            Text(
              '${degree!.toStringAsFixed(1)}°',
              style: _DesignTokens.mono.copyWith(
                fontSize: 9,
                color: _Colors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INSIGHT GENERATORS
// ═══════════════════════════════════════════════════════════════════════════
InsightData _getHouseInsight(House house, AppLocalizations l10n) {
  final houseName = _getHouseName(house.number, l10n);
  final significations = _getHouseSignifications(house.number, l10n);
  final zodiacColor = _getZodiacColor(house.sign);

  String _getDescription(int number) {
    switch (number) {
      case 1: return l10n.houses_1_desc;
      case 2: return l10n.houses_2_desc;
      case 3: return l10n.houses_3_desc;
      case 4: return l10n.houses_4_desc;
      case 5: return l10n.houses_5_desc;
      case 6: return l10n.houses_6_desc;
      case 7: return l10n.houses_7_desc;
      case 8: return l10n.houses_8_desc;
      case 9: return l10n.houses_9_desc;
      case 10: return l10n.houses_10_desc;
      case 11: return l10n.houses_11_desc;
      case 12: return l10n.houses_12_desc;
      default: return '';
    }
  }

  final localizedSign = _getLocalizedSign(house.sign, l10n);
  final localizedLord = _getLocalizedPlanetName(_getSignLord(house.sign), l10n);
  
  return InsightData(
    title: l10n.houses_houseNumber(house.number),
    value: l10n.houses_bhava_label(houseName),
    description: _getDescription(house.number),
    significance: l10n.houses_withSign(localizedSign, localizedLord),
    keyPoints: [
      l10n.houses_sign_key(localizedSign, _getSignSymbol(house.sign)),
      l10n.houses_lord_key(localizedLord),
      l10n.houses_cusp_key(house.cuspDegree.toStringAsFixed(2)),
      l10n.houses_karaka_key(_getHouseKaraka(house.number)),
      l10n.houses_significations_key(significations),
    ],
    accentColor: zodiacColor,
    icon: _getHouseIcon(house.number),
    imagePath: _getZodiacImagePath(house.sign),
  );
}

InsightData _getHouseTypeInsight(String houseType, AppLocalizations l10n) {
  switch (houseType) {
    case 'Kendra':
      return InsightData(
        title: l10n.houses_houseCategory,
        value: l10n.houses_kendra_value,
        description: l10n.houses_kendra_desc,
        significance: l10n.houses_kendra_significance,
        keyPoints: [
          l10n.houses_kendra_point1,
          l10n.houses_kendra_point2,
          l10n.houses_kendra_point3,
          l10n.houses_kendra_point4,
          l10n.houses_kendra_point5,
        ],
        accentColor: _Colors.emerald,
        icon: Icons.grid_4x4_rounded,
      );
    case 'Trikona':
      return InsightData(
        title: l10n.houses_houseCategory,
        value: l10n.houses_trikona_value,
        description: l10n.houses_trikona_desc,
        significance: l10n.houses_trikona_significance,
        keyPoints: [
          l10n.houses_trikona_point1,
          l10n.houses_trikona_point2,
          l10n.houses_trikona_point3,
          l10n.houses_trikona_point4,
          l10n.houses_trikona_point5,
        ],
        accentColor: _Colors.amber,
        icon: Icons.change_history_rounded,
      );
    case 'Dusthana':
      return InsightData(
        title: l10n.houses_houseCategory,
        value: l10n.houses_dusthana_value,
        description: l10n.houses_dusthana_desc,
        significance: l10n.houses_dusthana_significance,
        keyPoints: [
          l10n.houses_dusthana_point1,
          l10n.houses_dusthana_point2,
          l10n.houses_dusthana_point3,
          l10n.houses_dusthana_point4,
          l10n.houses_dusthana_point5,
        ],
        accentColor: _Colors.coral,
        icon: Icons.warning_amber_rounded,
      );
    case 'Upachaya':
      return InsightData(
        title: l10n.houses_houseCategory,
        value: l10n.houses_upachaya_value,
        description: l10n.houses_upachaya_desc,
        significance: l10n.houses_upachaya_significance,
        keyPoints: [
          l10n.houses_upachaya_point1,
          l10n.houses_upachaya_point2,
          l10n.houses_upachaya_point3,
          l10n.houses_upachaya_point4,
          l10n.houses_upachaya_point5,
        ],
        accentColor: _Colors.sky,
        icon: Icons.trending_up_rounded,
      );
    case 'Maraka':
      return InsightData(
        title: l10n.houses_houseCategory,
        value: l10n.houses_maraka_value,
        description: l10n.houses_maraka_desc,
        significance: l10n.houses_maraka_significance,
        keyPoints: [
          l10n.houses_maraka_point1,
          l10n.houses_maraka_point2,
          l10n.houses_maraka_point3,
          l10n.houses_maraka_point4,
          l10n.houses_maraka_point5,
        ],
        accentColor: _Colors.lavender,
        icon: Icons.hourglass_bottom_rounded,
      );
    default:
      return InsightData(
        title: l10n.houses_houseCategory,
        value: houseType,
        description: '',
        significance: '',
        keyPoints: [],
        accentColor: _Colors.violet,
        icon: Icons.home_rounded,
      );
  }
}

IconData _getHouseIcon(int houseNumber) {
  const icons = {
    1: Icons.person_rounded,
    2: Icons.account_balance_wallet_rounded,
    3: Icons.campaign_rounded,
    4: Icons.home_rounded,
    5: Icons.palette_rounded,
    6: Icons.health_and_safety_rounded,
    7: Icons.favorite_rounded,
    8: Icons.transform_rounded,
    9: Icons.school_rounded,
    10: Icons.work_rounded,
    11: Icons.groups_rounded,
    12: Icons.self_improvement_rounded,
  };
  return icons[houseNumber] ?? Icons.grid_view_rounded;
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

String _getSignLord(String sign) {
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

String _getHouseKaraka(int houseNumber) {
  const karakas = {
    1: 'Sun',
    2: 'Jupiter',
    3: 'Mars',
    4: 'Moon',
    5: 'Jupiter',
    6: 'Mars',
    7: 'Venus',
    8: 'Saturn',
    9: 'Jupiter',
    10: 'Sun',
    11: 'Jupiter',
    12: 'Saturn',
  };
  return karakas[houseNumber] ?? 'Unknown';
}

String _getHouseName(int n, AppLocalizations l10n) {
  final names = [
    l10n.houses_bhava_lagna,
    l10n.houses_bhava_dhana,
    l10n.houses_bhava_sahaja,
    l10n.houses_bhava_sukha,
    l10n.houses_bhava_putra,
    l10n.houses_bhava_ari,
    l10n.houses_bhava_yuvati,
    l10n.houses_bhava_mrityu,
    l10n.houses_bhava_dharma,
    l10n.houses_bhava_karma,
    l10n.houses_bhava_labha,
    l10n.houses_bhava_vyaya,
  ];
  return names[(n - 1) % 12];
}

String _getHouseSignifications(int n, AppLocalizations l10n) {
  switch (n) {
    case 1:
      return l10n.house_1_meaning;
    case 2:
      return l10n.house_2_meaning;
    case 3:
      return l10n.house_3_meaning;
    case 4:
      return l10n.house_4_meaning;
    case 5:
      return l10n.house_5_meaning;
    case 6:
      return l10n.house_6_meaning;
    case 7:
      return l10n.house_7_meaning;
    case 8:
      return l10n.house_8_meaning;
    case 9:
      return l10n.house_9_meaning;
    case 10:
      return l10n.house_10_meaning;
    case 11:
      return l10n.house_11_meaning;
    case 12:
      return l10n.house_12_meaning;
    default:
      return '';
  }
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

Color _getPlanetColor(String planet) {
  const colors = {
    'Sun': Color(0xFFCFAE54),
    'Moon': Color(0xFF6EE7B7),
    'Mars': Color(0xFFF87171),
    'Mercury': Color(0xFF4ADE80),
    'Jupiter': Color(0xFFFBBF24),
    'Venus': Color(0xFFF472B6),
    'Saturn': Color(0xFF9CA3AF),
    'Rahu': Color(0xFF9580FF),
    'Ketu': Color(0xFFD97706),
  };
  return colors[planet] ?? _Colors.textSecondary;
}

String _getZodiacImagePath(String sign) {
  return 'assets/images/zodiac/${sign.toLowerCase()}.png';
}

String _getPlanetImagePath(String planet) {
  return 'assets/images/planets/${planet.toLowerCase()}.png';
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
    case 'Uranus': return l10n.planet_uranus;
    case 'Neptune': return l10n.planet_neptune;
    case 'Pluto': return l10n.planet_pluto;
    default: return planet;
  }
}

String _getLocalizedSign(String sign, AppLocalizations l10n) {
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

Color _getZodiacColor(String sign) {
  const colors = {
    'Aries': Color(0xFFF87171),
    'Taurus': Color(0xFF4ADE80),
    'Gemini': Color(0xFFFBBF24),
    'Cancer': Color(0xFF6EE7B7),
    'Leo': Color(0xFFCFAE54),
    'Virgo': Color(0xFF4ADE80),
    'Libra': Color(0xFFF472B6),
    'Scorpio': Color(0xFFF87171),
    'Sagittarius': Color(0xFF9580FF),
    'Capricorn': Color(0xFF9CA3AF),
    'Aquarius': Color(0xFF38BDF8),
    'Pisces': Color(0xFF2DD4BF),
  };
  return colors[sign] ?? _Colors.violet;
}
