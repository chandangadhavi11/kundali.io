import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import 'package:kundali_app/l10n/generated/app_localizations.dart';
import '../../shared/constants.dart';
import 'dasha_shared_widgets.dart' hide getPlanetImagePath;

// ═══════════════════════════════════════════════════════════════════════════
// NAVIGATION SECTIONS
// ═══════════════════════════════════════════════════════════════════════════
List<DashaNavSection> _getSections(AppLocalizations l10n) => [
  DashaNavSection(id: 'current', label: l10n.vimshottari_nav_current, color: DashaColors.emerald),
  DashaNavSection(id: 'birth', label: l10n.vimshottari_nav_birth, color: DashaColors.amber),
  DashaNavSection(id: 'timeline', label: l10n.vimshottari_nav_timeline, color: DashaColors.vimshottari),
];

// Static section IDs for initialization
const _sectionIds = ['current', 'birth', 'timeline'];

/// Vimshottari Dasha View - Premium 120-year Dasha with drill-down
class VimshottariDashaView extends StatefulWidget {
  final KundaliData kundaliData;

  const VimshottariDashaView({super.key, required this.kundaliData});

  @override
  State<VimshottariDashaView> createState() => _VimshottariDashaViewState();
}

class _VimshottariDashaViewState extends State<VimshottariDashaView> {
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

    for (final id in _sectionIds) {
      _sectionKeys[id] = GlobalKey();
      _animatedKeys[id] = GlobalKey<DashaAnimatedSectionWrapperState>();
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

  Future<void> _scrollToSection(int index, List<DashaNavSection> sections) async {
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
    final dasha = widget.kundaliData.dashaInfo;
    final now = DateTime.now();
    final dynamicRemainingYears = _calculateDynamicRemainingYears(dasha, now);
    final currentIndex = dasha.sequence.indexWhere((p) => p.planet == dasha.currentMahadasha);
    final completedPeriods = currentIndex >= 0 ? currentIndex : 0;

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
              _VimshottariHeroCard(
                dasha: dasha,
                dynamicRemainingYears: dynamicRemainingYears,
                now: now,
                completedPeriods: completedPeriods,
              ),

              const SizedBox(height: DashaDesignTokens.space24),

              // Current Periods Section
              DashaAnimatedSectionWrapper(
                key: _animatedKeys['current'],
                sectionKey: _sectionKeys['current']!,
                accentColor: DashaColors.emerald,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashaAnimatedSectionHeader(
                      title: l10n.vimshottari_activePeriods,
                      accentColor: DashaColors.emerald,
                      icon: Icons.timeline_rounded,
                    ),
                    const SizedBox(height: DashaDesignTokens.space12),
                    DashaAnimatedCardWrapper(
                      delay: 50,
                      child: _CurrentPeriodsCard(
                        dasha: dasha,
                        dynamicRemainingYears: dynamicRemainingYears,
                        now: now,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DashaDesignTokens.space24),

              // Birth Configuration
              if (dasha.balanceYearsAtBirth != null || dasha.birthNakshatraLord != null)
                DashaAnimatedSectionWrapper(
                  key: _animatedKeys['birth'],
                  sectionKey: _sectionKeys['birth']!,
                  accentColor: DashaColors.amber,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashaAnimatedSectionHeader(
                        title: l10n.vimshottari_birthConfiguration,
                        accentColor: DashaColors.amber,
                        icon: Icons.child_care_rounded,
                      ),
                      const SizedBox(height: DashaDesignTokens.space12),
                      DashaAnimatedCardWrapper(
                        delay: 50,
                        child: _BirthConfigCard(
                          dasha: dasha,
                          birthDateTime: widget.kundaliData.birthDateTime,
                        ),
                      ),
                    ],
                  ),
                ),

              if (dasha.balanceYearsAtBirth != null || dasha.birthNakshatraLord != null)
                const SizedBox(height: DashaDesignTokens.space24),

              // Life Timeline
              DashaAnimatedSectionWrapper(
                key: _animatedKeys['timeline'],
                sectionKey: _sectionKeys['timeline']!,
                accentColor: DashaColors.vimshottari,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashaAnimatedSectionHeader(
                      title: l10n.vimshottari_lifeTimeline,
                      accentColor: DashaColors.vimshottari,
                      icon: Icons.view_timeline_rounded,
                    ),
                    const SizedBox(height: DashaDesignTokens.space12),
                    DashaAnimatedCardWrapper(
                      delay: 50,
                      child: _TimelineProgressBar(
                        sequence: dasha.sequence,
                        currentPlanet: dasha.currentMahadasha,
                      ),
                    ),
                    const SizedBox(height: DashaDesignTokens.space16),
                    ..._buildDashaSequence(dasha, now),
                  ],
                ),
              ),

              const SizedBox(height: DashaDesignTokens.space16),

              DashaInfoFooter(
                text: l10n.vimshottari_infoFooter,
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
            sections: sections,
            activeIndex: _activeIndex,
            onTap: (index) => _scrollToSection(index, sections),
          ),
        ),
      ],
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

  List<Widget> _buildDashaSequence(DashaInfo dasha, DateTime now) {
    final widgets = <Widget>[];

    if (dasha.mahadashaSequence != null && dasha.mahadashaSequence!.isNotEmpty) {
      for (var i = 0; i < dasha.mahadashaSequence!.length; i++) {
        final periodDetail = dasha.mahadashaSequence![i];
        final isCurrent = periodDetail.planet == dasha.currentMahadasha;
        final isPast = periodDetail.endDate.isBefore(now);

        widgets.add(DashaAnimatedCardWrapper(
          delay: 100 + (i * 30),
          child: _DashaPeriodItem(
            periodDetail: periodDetail,
            index: i,
            isCurrent: isCurrent,
            isPast: isPast,
            dasha: dasha,
          ),
        ));
      }
    } else {
      DateTime currentStart = dasha.startDate;

      for (var i = 0; i < dasha.sequence.length; i++) {
        final period = dasha.sequence[i];
        final endDate = currentStart.add(Duration(days: (period.years * 365.25).round()));
        final isCurrent = period.planet == dasha.currentMahadasha;
        final isPast = endDate.isBefore(now);

        widgets.add(DashaAnimatedCardWrapper(
          delay: 100 + (i * 30),
          child: _DashaPeriodItemFallback(
            period: period,
            index: i,
            isCurrent: isCurrent,
            isPast: isPast,
            startDate: currentStart,
            endDate: endDate,
            dasha: dasha,
          ),
        ));

        currentStart = endDate;
      }
    }

    return widgets;
  }
}

int _getMahadashaDuration(String planet) {
  const durations = {
    'Ketu': 7,
    'Venus': 20,
    'Sun': 6,
    'Moon': 10,
    'Mars': 7,
    'Rahu': 18,
    'Jupiter': 16,
    'Saturn': 19,
    'Mercury': 17,
  };
  return durations[planet] ?? 10;
}

// ═══════════════════════════════════════════════════════════════════════════
// HERO CARD - Refined Premium Design
// ═══════════════════════════════════════════════════════════════════════════
class _VimshottariHeroCard extends StatefulWidget {
  final DashaInfo dasha;
  final double dynamicRemainingYears;
  final DateTime now;
  final int completedPeriods;

  const _VimshottariHeroCard({
    required this.dasha,
    required this.dynamicRemainingYears,
    required this.now,
    required this.completedPeriods,
  });

  @override
  State<_VimshottariHeroCard> createState() => _VimshottariHeroCardState();
}

class _VimshottariHeroCardState extends State<_VimshottariHeroCard>
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
    
    final totalYears = _getMahadashaDuration(widget.dasha.currentMahadasha);
    final elapsedYears = totalYears - widget.dynamicRemainingYears;
    final progressPercent = (elapsedYears / totalYears).clamp(0.0, 1.0);
    
    _progressAnim = Tween<double>(begin: 0, end: progressPercent).animate(
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
    final totalYears = _getMahadashaDuration(widget.dasha.currentMahadasha);
    final elapsedYears = totalYears - widget.dynamicRemainingYears;
    final progressPercent = (elapsedYears / totalYears).clamp(0.0, 1.0);
    final planetColor = getPlanetColor(widget.dasha.currentMahadasha);

    return Container(
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
          // Header with planet image and title
          _buildHeader(planetColor),
          
          const SizedBox(height: 18),
          
          // Progress Section
          _buildProgressSection(progressPercent, planetColor, totalYears),
          
          const SizedBox(height: 16),
          
          // Timeline dates
          if (widget.dasha.mahadashaStartDate != null && 
              widget.dasha.mahadashaEndDate != null)
            _buildTimeline(),
        ],
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
              // Active badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3A2A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4ADE80).withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      AppLocalizations.of(context).vimshottari_active,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4ADE80),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context).vimshottari_planetMahadasha(_getLocalizedPlanetName(widget.dasha.currentMahadasha, AppLocalizations.of(context))),
                style: GoogleFonts.instrumentSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getPlanetDescription(widget.dasha.currentMahadasha, AppLocalizations.of(context)),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8B8798),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(double progress, Color color, int totalYears) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A181F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2A2838),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Progress bar with label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).vimshottari_journeyProgress,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9490A0),
                ),
              ),
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (context, _) {
                  return Text(
                    '${(_progressAnim.value * 100).toStringAsFixed(1)}%',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Animated progress bar
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (context, _) {
              return _RefinedProgressBar(
                progress: _progressAnim.value,
                color: color,
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // Stats row
          Row(
            children: [
              _StatChip(
                icon: Icons.hourglass_top_rounded,
                value: formatDurationLocalized(widget.dynamicRemainingYears, AppLocalizations.of(context)),
                label: AppLocalizations.of(context).vimshottari_remaining,
                iconColor: color,
              ),
              _buildDivider(),
              _StatChip(
                icon: Icons.schedule_rounded,
                value: AppLocalizations.of(context).vimshottari_yearsAbbr(totalYears.toString()),
                label: AppLocalizations.of(context).vimshottari_duration,
                iconColor: const Color(0xFF7C7889),
              ),
              _buildDivider(),
              _StatChip(
                icon: Icons.check_circle_rounded,
                value: '${widget.completedPeriods}/9',
                label: AppLocalizations.of(context).vimshottari_cycles,
                iconColor: const Color(0xFF4ADE80),
              ),
            ],
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

  Widget _buildTimeline() {
    return Row(
      children: [
        Expanded(
          child: _TimelineItem(
            label: AppLocalizations.of(context).vimshottari_started,
            date: widget.dasha.mahadashaStartDate!,
            alignment: CrossAxisAlignment.start,
          ),
        ),
        // Timeline connector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            width: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4ADE80).withOpacity(0.5),
                        const Color(0xFF4ADE80).withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4ADE80).withOpacity(0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _TimelineItem(
            label: AppLocalizations.of(context).vimshottari_ends,
            date: widget.dasha.mahadashaEndDate!,
            alignment: CrossAxisAlignment.end,
          ),
        ),
      ],
    );
  }

  String _getPlanetDescription(String planet, AppLocalizations l10n) {
    switch (planet) {
      case 'Sun':
        return l10n.vimshottari_desc_sun;
      case 'Moon':
        return l10n.vimshottari_desc_moon;
      case 'Mars':
        return l10n.vimshottari_desc_mars;
      case 'Mercury':
        return l10n.vimshottari_desc_mercury;
      case 'Jupiter':
        return l10n.vimshottari_desc_jupiter;
      case 'Venus':
        return l10n.vimshottari_desc_venus;
      case 'Saturn':
        return l10n.vimshottari_desc_saturn;
      case 'Rahu':
        return l10n.vimshottari_desc_rahu;
      case 'Ketu':
        return l10n.vimshottari_desc_ketu;
      default:
        return l10n.vimshottari_desc_default;
    }
  }
}

// Refined Progress Bar Component - Premium elegant thin design
class _RefinedProgressBar extends StatelessWidget {
  final double progress;
  final Color color;

  const _RefinedProgressBar({
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Create lighter gradient colors from the base color
    final baseColor = color;
    final lightColor = Color.lerp(baseColor, Colors.white, 0.35)!;
    final paleColor = Color.lerp(baseColor, Colors.white, 0.55)!;
    final clampedProgress = progress.clamp(0.0, 1.0);
    
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: const Color(0xFF1A181F),
        borderRadius: BorderRadius.circular(1.5),
        border: Border.all(
          color: const Color(0xFF2A2838).withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth * clampedProgress;
          return Stack(
            children: [
              // Progress fill with elegant gradient
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuart,
                width: width,
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
              // Leading edge glow dot
              if (width > 4)
                Positioned(
                  left: width - 1.5,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.5),
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
          );
        },
      ),
    );
  }
}

// Stat Chip Component
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
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
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
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

// Timeline Item Component
class _TimelineItem extends StatelessWidget {
  final String label;
  final DateTime date;
  final CrossAxisAlignment alignment;

  const _TimelineItem({
    required this.label,
    required this.date,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6E6A7A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formatDate(date),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFB8B5C2),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CURRENT PERIODS CARD
// ═══════════════════════════════════════════════════════════════════════════
class _CurrentPeriodsCard extends StatelessWidget {
  final DashaInfo dasha;
  final double dynamicRemainingYears;
  final DateTime now;

  const _CurrentPeriodsCard({
    required this.dasha,
    required this.dynamicRemainingYears,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _CompactPeriodCard(
            label: l10n.dasha_mahadasha,
            planet: dasha.currentMahadasha,
            remainingYears: dynamicRemainingYears,
            progress: _calculateProgress(),
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 10),
        if (dasha.currentAntardasha != null || dasha.currentAntardashaDetail != null)
          Expanded(
            child: _CompactPeriodCard(
              label: l10n.dasha_antardasha,
              planet: dasha.currentAntardashaDetail?.planet ?? dasha.currentAntardasha ?? '',
              remainingYears: _getAntardashaRemaining(),
              progress: _getAntardashaProgress(),
              isPrimary: false,
            ),
          ),
      ],
    );
  }

  double _calculateProgress() {
    final totalYears = _getMahadashaDuration(dasha.currentMahadasha).toDouble();
    final elapsedYears = totalYears - dynamicRemainingYears;
    return (elapsedYears / totalYears).clamp(0.0, 1.0);
  }

  double _getAntardashaRemaining() {
    final detail = dasha.currentAntardashaDetail;
    if (detail != null) {
      final daysRemaining = detail.endDate.difference(now).inDays;
      return daysRemaining > 0 ? daysRemaining / 365.25 : 0;
    }
    return dasha.antardashaRemainingYears ?? 0;
  }

  double _getAntardashaProgress() {
    final detail = dasha.currentAntardashaDetail;
    if (detail != null) {
      final remaining = _getAntardashaRemaining();
      final elapsed = detail.durationYears - remaining;
      return (elapsed / detail.durationYears).clamp(0.0, 1.0);
    }
    return 0.5;
  }
}

class _CompactPeriodCard extends StatelessWidget {
  final String label;
  final String planet;
  final double remainingYears;
  final double progress;
  final bool isPrimary;

  const _CompactPeriodCard({
    required this.label,
    required this.planet,
    required this.remainingYears,
    required this.progress,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final color = getPlanetColor(planet);

    return DashaPremiumCard(
      accentColor: color,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PremiumPlanetImage(
                planet: planet,
                size: 28,
                showShadow: false,
              ),
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
                      _getLocalizedPlanetName(planet, AppLocalizations.of(context)),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: DashaColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: DashaColors.border.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(color.withOpacity(0.7)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context).vimshottari_left(formatDurationLocalized(remainingYears, AppLocalizations.of(context))),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: DashaColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BIRTH CONFIG CARD
// ═══════════════════════════════════════════════════════════════════════════
class _BirthConfigCard extends StatelessWidget {
  final DashaInfo dasha;
  final DateTime birthDateTime;

  const _BirthConfigCard({required this.dasha, required this.birthDateTime});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DashaPremiumCard(
      child: Row(
        children: [
          if (dasha.birthNakshatraLord != null) ...[
            Expanded(
              child: _ConfigItem(
                icon: Icons.stars_rounded,
                label: l10n.vimshottari_nakshatraLord,
                value: dasha.birthNakshatraLord!,
                color: getPlanetColor(dasha.birthNakshatraLord!),
              ),
            ),
          ],
          if (dasha.birthNakshatraLord != null && dasha.balanceYearsAtBirth != null)
            Container(
              width: 1,
              height: 36,
              color: DashaColors.border.withOpacity(0.3),
            ),
          if (dasha.balanceYearsAtBirth != null) ...[
            Expanded(
              child: _ConfigItem(
                icon: Icons.hourglass_top_rounded,
                label: l10n.vimshottari_balanceAtBirth,
                value: formatDurationLocalized(dasha.balanceYearsAtBirth!, AppLocalizations.of(context)),
                color: DashaColors.amber,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfigItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ConfigItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color.withOpacity(0.7)),
        const SizedBox(width: 8),
        Column(
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TIMELINE PROGRESS BAR - Auto-scrolls to current planet
// ═══════════════════════════════════════════════════════════════════════════
class _TimelineProgressBar extends StatefulWidget {
  final List<DashaPeriod> sequence;
  final String currentPlanet;

  const _TimelineProgressBar({
    required this.sequence,
    required this.currentPlanet,
  });

  @override
  State<_TimelineProgressBar> createState() => _TimelineProgressBarState();
}

class _TimelineProgressBarState extends State<_TimelineProgressBar> {
  late ScrollController _scrollController;
  final double _itemWidth = 50.0; // 38px image + 12px padding

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Scroll to current item after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentItem();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentItem() {
    final currentIndex = widget.sequence.indexWhere((p) => p.planet == widget.currentPlanet);
    if (currentIndex < 0) return;

    // Calculate scroll offset to center the current item
    final screenWidth = MediaQuery.of(context).size.width;
    final containerPadding = 16 * 2 + 10 * 2; // outer padding + inner padding
    final availableWidth = screenWidth - containerPadding;
    
    // Position to scroll to (center the item)
    final targetOffset = (currentIndex * _itemWidth) - (availableWidth / 2) + (_itemWidth / 2);
    final maxScroll = _scrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.sequence.indexWhere((p) => p.planet == widget.currentPlanet);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141218),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF262432),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: widget.sequence.asMap().entries.map((entry) {
            final period = entry.value;
            final isCurrent = period.planet == widget.currentPlanet;
            final isPast = entry.key < currentIndex;
            final color = getPlanetColor(period.planet);

            return Padding(
              padding: EdgeInsets.only(
                left: entry.key == 0 ? 0 : 6,
                right: entry.key == widget.sequence.length - 1 ? 0 : 6,
              ),
              child: _TimelinePlanetItem(
                planet: period.planet,
                years: period.years,
                color: color,
                isCurrent: isCurrent,
                isPast: isPast,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Individual planet item in timeline
class _TimelinePlanetItem extends StatelessWidget {
  final String planet;
  final int years;
  final Color color;
  final bool isCurrent;
  final bool isPast;

  const _TimelinePlanetItem({
    required this.planet,
    required this.years,
    required this.color,
    required this.isCurrent,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isPast && !isCurrent ? 0.4 : 1.0;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Planet image container
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: isCurrent
                ? Border.all(color: color.withOpacity(0.6), width: 2)
                : Border.all(color: const Color(0xFF2A2838), width: 1),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.asset(
              getPlanetImagePath(planet),
              width: 38,
              height: 38,
              fit: BoxFit.cover,
              opacity: AlwaysStoppedAnimation(opacity),
              errorBuilder: (_, __, ___) => Container(
                color: color.withOpacity(0.15),
                child: Center(
                  child: Text(
                    getPlanetSymbol(planet),
                    style: TextStyle(
                      fontSize: 14,
                      color: color.withOpacity(opacity),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Planet name
        Text(
          _getShortPlanetName(planet, AppLocalizations.of(context)),
          style: GoogleFonts.inter(
            fontSize: 8,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
            color: isCurrent 
                ? color 
                : (isPast 
                    ? const Color(0xFF5A5868) 
                    : const Color(0xFF8B8798)),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  String _getShortPlanetName(String planet, AppLocalizations l10n) {
    switch (planet) {
      case 'Sun': return l10n.planet_sun_abbr;
      case 'Moon': return l10n.planet_moon_abbr;
      case 'Mars': return l10n.planet_mars_abbr;
      case 'Mercury': return l10n.planet_mercury_abbr;
      case 'Jupiter': return l10n.planet_jupiter_abbr;
      case 'Venus': return l10n.planet_venus_abbr;
      case 'Saturn': return l10n.planet_saturn_abbr;
      case 'Rahu': return l10n.planet_rahu_abbr;
      case 'Ketu': return l10n.planet_ketu_abbr;
      default: return planet.substring(0, 3).toUpperCase();
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PERIOD ITEMS
// ═══════════════════════════════════════════════════════════════════════════
class _DashaPeriodItem extends StatelessWidget {
  final DashaPeriodDetail periodDetail;
  final int index;
  final bool isCurrent;
  final bool isPast;
  final DashaInfo dasha;

  const _DashaPeriodItem({
    required this.periodDetail,
    required this.index,
    required this.isCurrent,
    required this.isPast,
    required this.dasha,
  });

  @override
  Widget build(BuildContext context) {
    final planetColor = getPlanetColor(periodDetail.planet);

    return GestureDetector(
      onTap: () => _showPeriodSheet(context, periodDetail),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrent
              ? planetColor.withOpacity(0.08)
              : DashaColors.surface,
          borderRadius: BorderRadius.circular(DashaDesignTokens.radiusMd),
          border: Border.all(
            color: isCurrent
                ? planetColor.withOpacity(0.3)
                : DashaColors.border.withOpacity(isPast ? 0.15 : 0.3),
            width: isCurrent ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            PremiumPlanetImage(
              planet: periodDetail.planet,
              size: 40,
              isActive: isCurrent,
              opacity: isPast ? 0.5 : 1.0,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getLocalizedPlanetName(periodDetail.planet, AppLocalizations.of(context)),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                          color: isPast
                              ? DashaColors.textTertiary
                              : DashaColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isCurrent) const ActiveNowBadge(fontSize: 7),
                      if (isPast && !isCurrent)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: DashaColors.textTertiary.withOpacity(0.4),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatDateShort(periodDetail.startDate)} → ${formatDateShort(periodDetail.endDate)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: DashaColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: planetColor.withOpacity(isPast ? 0.05 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppLocalizations.of(context).dasha_year_suffix(periodDetail.durationYears.round()),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPast ? DashaColors.textTertiary : planetColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: DashaColors.textTertiary.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  void _showPeriodSheet(BuildContext context, DashaPeriodDetail period) {
    showVimshottariPeriodSheet(context, period, []);
  }
}

class _DashaPeriodItemFallback extends StatelessWidget {
  final DashaPeriod period;
  final int index;
  final bool isCurrent;
  final bool isPast;
  final DateTime startDate;
  final DateTime endDate;
  final DashaInfo dasha;

  const _DashaPeriodItemFallback({
    required this.period,
    required this.index,
    required this.isCurrent,
    required this.isPast,
    required this.startDate,
    required this.endDate,
    required this.dasha,
  });

  @override
  Widget build(BuildContext context) {
    final planetColor = getPlanetColor(period.planet);

    return GestureDetector(
      onTap: () => _showDetailsFallback(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrent
              ? planetColor.withOpacity(0.08)
              : DashaColors.surface,
          borderRadius: BorderRadius.circular(DashaDesignTokens.radiusMd),
          border: Border.all(
            color: isCurrent
                ? planetColor.withOpacity(0.3)
                : DashaColors.border.withOpacity(isPast ? 0.15 : 0.3),
            width: isCurrent ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            PremiumPlanetImage(
              planet: period.planet,
              size: 40,
              isActive: isCurrent,
              opacity: isPast ? 0.5 : 1.0,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getLocalizedPlanetName(period.planet, AppLocalizations.of(context)),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                          color: isPast
                              ? DashaColors.textTertiary
                              : DashaColors.textPrimary,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        const ActiveNowBadge(fontSize: 7),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatDateShort(startDate)} → ${formatDateShort(endDate)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: DashaColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: planetColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${period.years}y',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: planetColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: DashaColors.textTertiary.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsFallback(BuildContext context) {
    final subPeriods = KundaliCalculationService.calculateSubDashas(
      parentPath: period.planet,
      parentPlanet: period.planet,
      parentDuration: period.years.toDouble(),
      startDate: startDate,
      level: DashaLevel.antardasha,
      maxDepth: 1,
    );

    final periodDetail = DashaPeriodDetail(
      planet: period.planet,
      fullPath: period.planet,
      durationYears: period.years.toDouble(),
      startDate: startDate,
      endDate: endDate,
      level: DashaLevel.mahadasha,
      subPeriods: subPeriods,
    );

    showVimshottariPeriodSheet(context, periodDetail, []);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════
void showVimshottariPeriodSheet(
  BuildContext context,
  DashaPeriodDetail period,
  List<String> breadcrumbs,
) {
  final levelColors = {
    DashaLevel.mahadasha: DashaColors.mahadasha,
    DashaLevel.antardasha: DashaColors.antardasha,
    DashaLevel.pratyantara: DashaColors.pratyantara,
    DashaLevel.sookshma: DashaColors.sookshma,
    DashaLevel.prana: DashaColors.prana,
  };

  final levelColor = levelColors[period.level] ?? DashaColors.violet;
  final newBreadcrumbs = [...breadcrumbs, period.planet];
  final now = DateTime.now();
  final isCurrentPeriod = period.containsDate(now);

  final hasSubPeriods = period.subPeriods != null && period.subPeriods!.isNotEmpty;
  final nextLevel = _getNextDashaLevel(period.level);
  final canDrillDeeper = nextLevel != null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: DashaColors.bgSecondary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: levelColor.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DashaColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _VimshottariPeriodHeader(
              period: period,
              breadcrumbs: breadcrumbs,
              levelColor: levelColor,
              isCurrentPeriod: isCurrentPeriod,
            ),
            if (canDrillDeeper)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context).vimshottari_levelPeriods(_getLevelDisplayName(nextLevel, AppLocalizations.of(context))),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DashaColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (hasSubPeriods)
                      Text(
                        '(${period.subPeriods!.length})',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: DashaColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: hasSubPeriods
                  ? ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: period.subPeriods!.length,
                      itemBuilder: (context, index) {
                        final subPeriod = period.subPeriods![index];
                        final isSubCurrent = subPeriod.containsDate(now);
                        final subLevelColor = levelColors[subPeriod.level] ?? DashaColors.textTertiary;
                        final canDrillDeeperSub = _getNextDashaLevel(subPeriod.level) != null;

                        return _SubPeriodItem(
                          subPeriod: subPeriod,
                          isSubCurrent: isSubCurrent,
                          subLevelColor: subLevelColor,
                          canDrillDeeperSub: canDrillDeeperSub,
                          newBreadcrumbs: newBreadcrumbs,
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.hourglass_empty_rounded,
                            size: 48,
                            color: DashaColors.textTertiary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context).vimshottari_loadingSubPeriods,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: DashaColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}

DashaLevel? _getNextDashaLevel(DashaLevel current) {
  switch (current) {
    case DashaLevel.mahadasha:
      return DashaLevel.antardasha;
    case DashaLevel.antardasha:
      return DashaLevel.pratyantara;
    case DashaLevel.pratyantara:
      return DashaLevel.sookshma;
    case DashaLevel.sookshma:
      return DashaLevel.prana;
    case DashaLevel.prana:
      return null;
  }
}

String _getLevelDisplayName(DashaLevel? level, AppLocalizations l10n) {
  if (level == null) return '';
  switch (level) {
    case DashaLevel.mahadasha:
      return l10n.dasha_mahadasha;
    case DashaLevel.antardasha:
      return l10n.dasha_antardasha;
    case DashaLevel.pratyantara:
      return l10n.dasha_pratyantardasha;
    case DashaLevel.sookshma:
      return l10n.vimshottari_sookshma;
    case DashaLevel.prana:
      return l10n.vimshottari_prana;
  }
}

class _VimshottariPeriodHeader extends StatelessWidget {
  final DashaPeriodDetail period;
  final List<String> breadcrumbs;
  final Color levelColor;
  final bool isCurrentPeriod;

  const _VimshottariPeriodHeader({
    required this.period,
    required this.breadcrumbs,
    required this.levelColor,
    required this.isCurrentPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (breadcrumbs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 14,
                      color: DashaColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      breadcrumbs.join(' → '),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: DashaColors.textTertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                PremiumPlanetImage(
                  planet: period.planet,
                  size: 48,
                  isActive: isCurrentPeriod,
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: levelColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            period.levelName,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: levelColor,
                            ),
                          ),
                        ),
                        if (isCurrentPeriod) ...[
                          const SizedBox(width: 8),
                          const ActiveNowBadge(fontSize: 8),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${period.planet} ${period.levelName}',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: DashaColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DashaPremiumCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _DateColumn(label: AppLocalizations.of(context).vimshottari_start, date: period.startDate),
                Container(width: 1, height: 28, color: DashaColors.border),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _DateColumn(label: AppLocalizations.of(context).vimshottari_end, date: period.endDate),
                  ),
                ),
                Container(width: 1, height: 28, color: DashaColors.border),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).vimshottari_duration,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: DashaColors.textTertiary,
                          ),
                        ),
                        Text(
                          formatDurationLocalized(period.durationYears, AppLocalizations.of(context)),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: levelColor,
                          ),
                        ),
                      ],
                    ),
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

class _DateColumn extends StatelessWidget {
  final String label;
  final DateTime date;

  const _DateColumn({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
            formatDate(date),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: DashaColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubPeriodItem extends StatelessWidget {
  final DashaPeriodDetail subPeriod;
  final bool isSubCurrent;
  final Color subLevelColor;
  final bool canDrillDeeperSub;
  final List<String> newBreadcrumbs;

  const _SubPeriodItem({
    required this.subPeriod,
    required this.isSubCurrent,
    required this.subLevelColor,
    required this.canDrillDeeperSub,
    required this.newBreadcrumbs,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canDrillDeeperSub
          ? () {
              Navigator.pop(context);
              final deeperPeriod = _ensureSubPeriods(subPeriod);
              showVimshottariPeriodSheet(context, deeperPeriod, newBreadcrumbs);
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSubCurrent
              ? subLevelColor.withOpacity(0.1)
              : DashaColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSubCurrent
                ? subLevelColor.withOpacity(0.3)
                : DashaColors.border.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            PremiumPlanetImage(
              planet: subPeriod.planet,
              size: 32,
              isActive: isSubCurrent,
              showShadow: false,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        subPeriod.planet,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: isSubCurrent ? FontWeight.w600 : FontWeight.w500,
                          color: DashaColors.textPrimary,
                        ),
                      ),
                      if (isSubCurrent) ...[
                        const SizedBox(width: 8),
                        const ActiveNowBadge(fontSize: 7),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatDateShort(subPeriod.startDate)} - ${formatDateShort(subPeriod.endDate)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: DashaColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatDurationLocalized(subPeriod.durationYears, AppLocalizations.of(context)),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: DashaColors.textTertiary,
              ),
            ),
            if (canDrillDeeperSub) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: DashaColors.textTertiary.withOpacity(0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

DashaPeriodDetail _ensureSubPeriods(DashaPeriodDetail period) {
  if (period.subPeriods != null && period.subPeriods!.isNotEmpty) {
    return period;
  }

  final nextLevel = _getNextDashaLevel(period.level);
  if (nextLevel == null) return period;

  final subPeriods = KundaliCalculationService.calculateSubDashas(
    parentPath: period.fullPath,
    parentPlanet: period.planet,
    parentDuration: period.durationYears,
    startDate: period.startDate,
    level: nextLevel,
    maxDepth: 1,
  );

  return DashaPeriodDetail(
    planet: period.planet,
    fullPath: period.fullPath,
    durationYears: period.durationYears,
    startDate: period.startDate,
    endDate: period.endDate,
    level: period.level,
    subPeriods: subPeriods,
  );
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