import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../../shared/constants.dart';
import 'dasha_shared_widgets.dart' hide getPlanetImagePath;

// ═══════════════════════════════════════════════════════════════════════════
// NAVIGATION SECTIONS
// ═══════════════════════════════════════════════════════════════════════════
const _sections = [
  DashaNavSection(id: 'theme', label: 'Theme', color: DashaColors.phala),
  DashaNavSection(id: 'effects', label: 'Effects', color: DashaColors.amber),
  DashaNavSection(id: 'life', label: 'Life Areas', color: DashaColors.sky),
  DashaNavSection(id: 'remedies', label: 'Remedies', color: DashaColors.yogini),
];

/// Mahadasha Phala View - Premium interpretations and predictions
class MahadashaPhalaView extends StatefulWidget {
  final KundaliData kundaliData;

  const MahadashaPhalaView({super.key, required this.kundaliData});

  @override
  State<MahadashaPhalaView> createState() => _MahadashaPhalaViewState();
}

class _MahadashaPhalaViewState extends State<MahadashaPhalaView> {
  late final ScrollController _scrollController;
  final Map<String, GlobalKey> _sectionKeys = {};
  final Map<String, GlobalKey<DashaAnimatedSectionWrapperState>> _animatedKeys = {};
  int _activeIndex = 0;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    for (final section in _sections) {
      _sectionKeys[section.id] = GlobalKey();
      _animatedKeys[section.id] = GlobalKey<DashaAnimatedSectionWrapperState>();
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
    final dasha = widget.kundaliData.dashaInfo;
    final interpretation = MahadashaInterpretations.getInterpretation(dasha.currentMahadasha);

    if (interpretation == null) {
      return _buildNoDataView();
    }

    final now = DateTime.now();
    final dynamicRemainingYears = _calculateDynamicRemainingYears(dasha, now);
    final planetColor = getPlanetColor(dasha.currentMahadasha);

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              _PhalaHeroCard(
                dasha: dasha,
                interpretation: interpretation,
                dynamicRemainingYears: dynamicRemainingYears,
                now: now,
              ),

              const SizedBox(height: DashaDesignTokens.space24),

              // Theme Section
              DashaAnimatedSectionWrapper(
                key: _animatedKeys['theme'],
                sectionKey: _sectionKeys['theme']!,
                accentColor: DashaColors.phala,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashaAnimatedSectionHeader(
                      title: 'Overall Theme',
                      accentColor: DashaColors.phala,
                      icon: Icons.format_quote_rounded,
                    ),
                    const SizedBox(height: DashaDesignTokens.space12),
                    DashaAnimatedCardWrapper(
                      delay: 50,
                      child: _ThemeCard(
                        theme: interpretation.overallTheme,
                        planetColor: planetColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DashaDesignTokens.space24),

              // Key Effects Section
              DashaAnimatedSectionWrapper(
                key: _animatedKeys['effects'],
                sectionKey: _sectionKeys['effects']!,
                accentColor: DashaColors.amber,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashaAnimatedSectionHeader(
                      title: 'Key Effects',
                      accentColor: DashaColors.amber,
                      icon: Icons.auto_awesome_rounded,
                    ),
                    const SizedBox(height: DashaDesignTokens.space12),
                    DashaAnimatedCardWrapper(
                      delay: 50,
                      child: _KeyEffectsCard(effects: interpretation.keyEffects, color: planetColor),
                    ),
                    const SizedBox(height: DashaDesignTokens.space16),
                    // Current Antardasha
                    if (dasha.currentAntardasha != null)
                      DashaAnimatedCardWrapper(
                        delay: 100,
                        child: _AntardashaCard(
                          mahadasha: dasha.currentMahadasha,
                          antardasha: dasha.currentAntardasha!,
                          remainingYears: dasha.antardashaRemainingYears,
                        ),
                      ),
                    const SizedBox(height: DashaDesignTokens.space16),
                    // Strengths & Challenges
                    DashaAnimatedCardWrapper(
                      delay: 150,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _AspectCard(
                              title: 'Favorable',
                              items: interpretation.favorableAspects,
                              color: DashaColors.emerald,
                              icon: Icons.check_circle_outline_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _AspectCard(
                              title: 'Challenges',
                              items: interpretation.challenges,
                              color: DashaColors.coral,
                              icon: Icons.warning_amber_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DashaDesignTokens.space24),

              // Life Areas Section
              DashaAnimatedSectionWrapper(
                key: _animatedKeys['life'],
                sectionKey: _sectionKeys['life']!,
                accentColor: DashaColors.sky,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashaAnimatedSectionHeader(
                      title: 'Life Areas',
                      accentColor: DashaColors.sky,
                      icon: Icons.dashboard_rounded,
                    ),
                    const SizedBox(height: DashaDesignTokens.space12),
                    DashaAnimatedCardWrapper(
                      delay: 50,
                      child: _LifeAreasCard(lifeAreas: interpretation.lifeAreas),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DashaDesignTokens.space24),

              // Remedies Section
              DashaAnimatedSectionWrapper(
                key: _animatedKeys['remedies'],
                sectionKey: _sectionKeys['remedies']!,
                accentColor: DashaColors.yogini,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashaAnimatedSectionHeader(
                      title: 'Remedies & Recommendations',
                      accentColor: DashaColors.yogini,
                      icon: Icons.healing_rounded,
                    ),
                    const SizedBox(height: DashaDesignTokens.space12),
                    DashaAnimatedCardWrapper(
                      delay: 50,
                      child: _RemediesCard(
                        remedies: interpretation.remedies,
                        gemstone: interpretation.gemstone,
                        mantra: interpretation.mantra,
                        deity: interpretation.deity,
                        color: interpretation.color,
                        dayOfWeek: interpretation.dayOfWeek,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DashaDesignTokens.space16),

              const DashaInfoFooter(
                text: 'Mahadasha Phala provides general predictions. Consult an astrologer for personalized guidance.',
              ),
            ],
          ),
        ),

        // Floating Navigation
        Positioned(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          child: DashaFloatingNavBar(
            sections: _sections,
            activeIndex: _activeIndex,
            onTap: _scrollToSection,
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DashaColors.phala.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.hourglass_empty_rounded,
                size: 40,
                color: DashaColors.phala.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Interpretation Unavailable',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DashaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load Mahadasha interpretation.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: DashaColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  double _calculateDynamicRemainingYears(DashaInfo dasha, DateTime now) {
    if (dasha.mahadashaEndDate != null) {
      final daysRemaining = dasha.mahadashaEndDate!.difference(now).inDays;
      if (daysRemaining > 0) {
        return daysRemaining / 365.25;
      }
      return 0;
    }
    return dasha.remainingYears;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HERO CARD
// ═══════════════════════════════════════════════════════════════════════════
class _PhalaHeroCard extends StatefulWidget {
  final DashaInfo dasha;
  final MahadashaPhalaData interpretation;
  final double dynamicRemainingYears;
  final DateTime now;

  const _PhalaHeroCard({
    required this.dasha,
    required this.interpretation,
    required this.dynamicRemainingYears,
    required this.now,
  });

  @override
  State<_PhalaHeroCard> createState() => _PhalaHeroCardState();
}

class _PhalaHeroCardState extends State<_PhalaHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    
    Future.delayed(const Duration(milliseconds: 100), () {
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
    final planetColor = getPlanetColor(widget.dasha.currentMahadasha);

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
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
              // Header with planet and title
              _buildHeader(planetColor),
              
              const SizedBox(height: 16),
              
              // Info chips row
              _buildInfoChips(planetColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color planetColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Planet image
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: planetColor.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              getPlanetImagePath(widget.dasha.currentMahadasha),
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phala badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: DashaColors.phala.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'PHALA',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: DashaColors.phala,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.dasha.currentMahadasha} Mahadasha',
                style: GoogleFonts.instrumentSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              // Deity & Gemstone row
              Row(
                children: [
                  Icon(
                    Icons.temple_hindu_rounded,
                    size: 11,
                    color: const Color(0xFF7C7889),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.interpretation.deity,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8B8798),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.diamond_outlined,
                    size: 11,
                    color: planetColor.withOpacity(0.8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.interpretation.gemstone.split(' ').first,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: planetColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChips(Color planetColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A181F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2A2838),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          _PhalaInfoChip(
            icon: Icons.hourglass_top_rounded,
            value: formatDuration(widget.dynamicRemainingYears),
            label: 'Remaining',
            iconColor: planetColor,
          ),
          _buildDivider(),
          _PhalaInfoChip(
            icon: Icons.calendar_today_rounded,
            value: _getDayName(widget.interpretation.dayOfWeek),
            label: 'Day',
            iconColor: DashaColors.phala,
          ),
          _buildDivider(),
          _PhalaInfoChip(
            icon: Icons.palette_rounded,
            value: widget.interpretation.color.split(',').first.trim(),
            label: 'Color',
            iconColor: _getColorFromName(widget.interpretation.color),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: const Color(0xFF2A2838),
    );
  }

  Color _getColorFromName(String colorName) {
    final name = colorName.toLowerCase().split(',').first.trim();
    final colorMap = {
      'red': const Color(0xFFEF4444),
      'orange': const Color(0xFFF97316),
      'yellow': const Color(0xFFEAB308),
      'gold': const Color(0xFFD4AF37),
      'green': const Color(0xFF22C55E),
      'blue': const Color(0xFF3B82F6),
      'white': const Color(0xFFF5F5F5),
      'grey': const Color(0xFF9CA3AF),
      'gray': const Color(0xFF9CA3AF),
      'brown': const Color(0xFF92400E),
      'black': const Color(0xFF6B7280),
      'purple': const Color(0xFFA855F7),
      'pink': const Color(0xFFEC4899),
      'saffron': const Color(0xFFFF9933),
    };
    return colorMap[name] ?? DashaColors.phala;
  }

  String _getDayName(int dayOfWeek) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[dayOfWeek % 7];
  }
}

class _PhalaInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _PhalaInfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF7C7889),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// THEME CARD
// ═══════════════════════════════════════════════════════════════════════════
class _ThemeCard extends StatelessWidget {
  final String theme;
  final Color planetColor;

  const _ThemeCard({required this.theme, required this.planetColor});

  @override
  Widget build(BuildContext context) {
    return DashaPremiumCard(
      accentColor: planetColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: planetColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.format_quote_rounded,
              size: 18,
              color: planetColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              theme,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: DashaColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// KEY EFFECTS CARD
// ═══════════════════════════════════════════════════════════════════════════
class _KeyEffectsCard extends StatelessWidget {
  final List<String> effects;
  final Color color;

  const _KeyEffectsCard({required this.effects, required this.color});

  @override
  Widget build(BuildContext context) {
    return DashaPremiumCard(
      child: Column(
        children: effects.asMap().entries.map((entry) {
          final index = entry.key;
          final effect = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: index < effects.length - 1 ? 10 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    effect,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: DashaColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LIFE AREAS CARD
// ═══════════════════════════════════════════════════════════════════════════
class _LifeAreasCard extends StatelessWidget {
  final Map<String, String> lifeAreas;

  const _LifeAreasCard({required this.lifeAreas});

  static const _areaIcons = {
    'Career': Icons.work_outline_rounded,
    'Health': Icons.favorite_outline_rounded,
    'Relationships': Icons.people_outline_rounded,
    'Finance': Icons.account_balance_wallet_outlined,
    'Spirituality': Icons.self_improvement_rounded,
  };

  static const _areaColors = {
    'Career': DashaColors.sky,
    'Health': DashaColors.coral,
    'Relationships': DashaColors.rose,
    'Finance': DashaColors.emerald,
    'Spirituality': DashaColors.yogini,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: lifeAreas.entries.map((entry) {
        final area = entry.key;
        final description = entry.value;
        final icon = _areaIcons[area] ?? Icons.star_outline_rounded;
        final color = _areaColors[area] ?? DashaColors.violet;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: DashaColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: DashaColors.border.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              title: Text(
                area,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DashaColors.textPrimary,
                ),
              ),
              iconColor: DashaColors.textTertiary,
              collapsedIconColor: DashaColors.textTertiary,
              children: [
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: DashaColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ANTARDASHA CARD
// ═══════════════════════════════════════════════════════════════════════════
class _AntardashaCard extends StatelessWidget {
  final String mahadasha;
  final String antardasha;
  final double? remainingYears;

  const _AntardashaCard({
    required this.mahadasha,
    required this.antardasha,
    this.remainingYears,
  });

  @override
  Widget build(BuildContext context) {
    final antarColor = getPlanetColor(antardasha);
    final effect = MahadashaInterpretations.getAntardashaEffect(mahadasha, antardasha);
    final antarData = MahadashaInterpretations.getInterpretation(antardasha);

    return DashaPremiumCard(
      accentColor: antarColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PremiumPlanetImage(
                planet: antardasha,
                size: 40,
                isActive: true,
                showShadow: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$antardasha Antardasha',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DashaColors.textPrimary,
                      ),
                    ),
                    if (remainingYears != null)
                      Text(
                        '${formatDuration(remainingYears!)} remaining',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: antarColor,
                        ),
                      ),
                  ],
                ),
              ),
              const ActiveNowBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: DashaColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              effect,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: DashaColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          if (antarData != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _MiniInfo(
                  label: 'Gemstone',
                  value: antarData.gemstone.split(' ').first,
                  color: antarColor,
                ),
                const SizedBox(width: 8),
                _MiniInfo(
                  label: 'Day',
                  value: _getDayShort(antarData.dayOfWeek),
                  color: antarColor,
                ),
                const SizedBox(width: 8),
                _MiniInfo(
                  label: 'Deity',
                  value: antarData.deity.split('/').first.replaceAll('Lord ', '').replaceAll('Goddess ', ''),
                  color: antarColor,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getDayShort(int dayOfWeek) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[dayOfWeek % 7];
  }
}

class _MiniInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniInfo({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 8,
                color: DashaColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ASPECT CARD
// ═══════════════════════════════════════════════════════════════════════════
class _AspectCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  final IconData icon;

  const _AspectCard({
    required this.title,
    required this.items,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DashaPremiumCard(
      accentColor: color,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
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
          const SizedBox(height: 10),
          ...items.take(5).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: DashaColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// REMEDIES CARD
// ═══════════════════════════════════════════════════════════════════════════
class _RemediesCard extends StatelessWidget {
  final List<String> remedies;
  final String gemstone;
  final String mantra;
  final String deity;
  final String color;
  final int dayOfWeek;

  const _RemediesCard({
    required this.remedies,
    required this.gemstone,
    required this.mantra,
    required this.deity,
    required this.color,
    required this.dayOfWeek,
  });

  @override
  Widget build(BuildContext context) {
    return DashaPremiumCard(
      accentColor: DashaColors.yogini,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Info Row
          Row(
            children: [
              _RemedyInfo(
                icon: Icons.diamond_outlined,
                label: 'Gemstone',
                value: gemstone.split('(').first.trim(),
              ),
              const SizedBox(width: 8),
              _RemedyInfo(
                icon: Icons.person_outline_rounded,
                label: 'Deity',
                value: deity.split('/').first.trim(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Mantra
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: DashaColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.record_voice_over_outlined,
                      size: 12,
                      color: DashaColors.yogini,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Mantra',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: DashaColors.yogini,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  mantra,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 11,
                    color: DashaColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Remedies List
          Text(
            'Suggested Practices',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: DashaColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ...remedies.map((remedy) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 14,
                      color: DashaColors.yogini.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        remedy,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: DashaColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _RemedyInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RemedyInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: DashaColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: DashaColors.yogini),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: DashaColors.textTertiary,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: DashaColors.textPrimary,
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
