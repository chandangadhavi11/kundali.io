import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../../shared/constants.dart' show getPlanetColor;
import 'dasha_shared_widgets.dart';

// ═══════════════════════════════════════════════════════════════════════════
// NAVIGATION SECTIONS
// ═══════════════════════════════════════════════════════════════════════════
const _sections = [
  DashaNavSection(id: 'current', label: 'Current', color: DashaColors.emerald),
  DashaNavSection(id: 'yoginis', label: 'Yoginis', color: DashaColors.yogini),
  DashaNavSection(id: 'timeline', label: 'Timeline', color: DashaColors.rose),
];

/// Yogini Dasha View - Premium 36-year cycle with 8 divine Yoginis
class YoginiDashaView extends StatefulWidget {
  final KundaliData kundaliData;

  const YoginiDashaView({super.key, required this.kundaliData});

  @override
  State<YoginiDashaView> createState() => _YoginiDashaViewState();
}

class _YoginiDashaViewState extends State<YoginiDashaView> {
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
    final yogini = widget.kundaliData.yoginiDashaInfo;

    if (yogini == null) {
      return _buildNoDataView();
    }

    final now = DateTime.now();
    final dynamicRemainingYears = _calculateDynamicRemainingYears(yogini, now);
    final currentIndex = yogini.sequence.indexWhere((p) => p.yogini == yogini.currentYogini);
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
              _YoginiHeroCard(
                yogini: yogini,
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
                      title: 'Active Yogini Periods',
                      accentColor: DashaColors.emerald,
                      icon: Icons.timeline_rounded,
                    ),
                    const SizedBox(height: DashaDesignTokens.space12),
                    DashaAnimatedCardWrapper(
                      delay: 50,
                      child: _CurrentPeriodsCard(
                        yogini: yogini,
                        dynamicRemainingYears: dynamicRemainingYears,
                        now: now,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DashaDesignTokens.space24),

              // Yogini Wheel Visualization
              DashaAnimatedSectionWrapper(
                key: _animatedKeys['yoginis'],
                sectionKey: _sectionKeys['yoginis']!,
                accentColor: DashaColors.yogini,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashaAnimatedSectionHeader(
                      title: 'The 8 Divine Yoginis',
                      accentColor: DashaColors.yogini,
                      icon: Icons.donut_large_rounded,
                    ),
                    const SizedBox(height: DashaDesignTokens.space12),
                    DashaAnimatedCardWrapper(
                      delay: 50,
                      child: _YoginiWheelCard(currentYogini: yogini.currentYogini),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DashaDesignTokens.space24),

              // Life Timeline
              DashaAnimatedSectionWrapper(
                key: _animatedKeys['timeline'],
                sectionKey: _sectionKeys['timeline']!,
                accentColor: DashaColors.rose,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashaAnimatedSectionHeader(
                      title: 'Yogini Timeline',
                      accentColor: DashaColors.rose,
                      icon: Icons.view_timeline_rounded,
                    ),
                    const SizedBox(height: DashaDesignTokens.space12),
                    DashaAnimatedCardWrapper(
                      delay: 50,
                      child: _YoginiTimelineBar(currentYogini: yogini.currentYogini),
                    ),
                    const SizedBox(height: DashaDesignTokens.space16),
                    ..._buildYoginiSequence(yogini, now),
                  ],
                ),
              ),

              const SizedBox(height: DashaDesignTokens.space16),

              const DashaInfoFooter(
                text: 'Yogini Dasha is a 36-year cycle based on 8 divine Yoginis representing cosmic feminine energies.',
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
                color: DashaColors.yogini.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.hourglass_empty_rounded,
                size: 40,
                color: DashaColors.yogini.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Yogini Dasha Unavailable',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DashaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to calculate Yogini Dasha for this chart.',
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

  double _calculateDynamicRemainingYears(YoginiDashaInfo yogini, DateTime now) {
    if (yogini.yoginiEndDate != null) {
      final daysRemaining = yogini.yoginiEndDate!.difference(now).inDays;
      if (daysRemaining > 0) {
        return daysRemaining / 365.25;
      }
      return 0;
    }
    return yogini.remainingYears;
  }

  List<Widget> _buildYoginiSequence(YoginiDashaInfo yogini, DateTime now) {
    final widgets = <Widget>[];

    if (yogini.yoginiSequence != null && yogini.yoginiSequence!.isNotEmpty) {
      for (var i = 0; i < yogini.yoginiSequence!.length && i < 8; i++) {
        final periodDetail = yogini.yoginiSequence![i];
        final isCurrent = periodDetail.yogini == yogini.currentYogini;
        final isPast = periodDetail.endDate.isBefore(now);

        widgets.add(DashaAnimatedCardWrapper(
          delay: 100 + (i * 30),
          child: _YoginiPeriodItem(
            periodDetail: periodDetail,
            index: i,
            isCurrent: isCurrent,
            isPast: isPast,
          ),
        ));
      }
    } else {
      DateTime currentStart = yogini.startDate;

      for (var i = 0; i < yogini.sequence.length; i++) {
        final period = yogini.sequence[i];
        final endDate = currentStart.add(Duration(days: (period.years * 365.25).round()));
        final isCurrent = period.yogini == yogini.currentYogini;
        final isPast = endDate.isBefore(now);

        widgets.add(DashaAnimatedCardWrapper(
          delay: 100 + (i * 30),
          child: _YoginiPeriodItemFallback(
            period: period,
            index: i,
            isCurrent: isCurrent,
            isPast: isPast,
            startDate: currentStart,
            endDate: endDate,
          ),
        ));

        currentStart = endDate;
      }
    }

    return widgets;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// YOGINI COLOR HELPER
// ═══════════════════════════════════════════════════════════════════════════
Color _getYoginiColor(Yogini yogini) {
  const colors = {
    Yogini.mangala: DashaColors.emerald,
    Yogini.pingala: DashaColors.gold,
    Yogini.dhanya: DashaColors.amber,
    Yogini.bhramari: DashaColors.coral,
    Yogini.bhadrika: DashaColors.teal,
    Yogini.ulka: Color(0xFF9CA3AF),
    Yogini.siddha: DashaColors.rose,
    Yogini.sankata: DashaColors.purple,
  };
  return colors[yogini] ?? DashaColors.yogini;
}

// ═══════════════════════════════════════════════════════════════════════════
// HERO CARD - Refined Premium Design
// ═══════════════════════════════════════════════════════════════════════════
class _YoginiHeroCard extends StatefulWidget {
  final YoginiDashaInfo yogini;
  final double dynamicRemainingYears;
  final DateTime now;
  final int completedPeriods;

  const _YoginiHeroCard({
    required this.yogini,
    required this.dynamicRemainingYears,
    required this.now,
    required this.completedPeriods,
  });

  @override
  State<_YoginiHeroCard> createState() => _YoginiHeroCardState();
}

class _YoginiHeroCardState extends State<_YoginiHeroCard>
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
    
    final totalYears = widget.yogini.currentYogini.years;
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
    final totalYears = widget.yogini.currentYogini.years;
    final elapsedYears = totalYears - widget.dynamicRemainingYears;
    final progressPercent = (elapsedYears / totalYears).clamp(0.0, 1.0);
    final yoginiColor = _getYoginiColor(widget.yogini.currentYogini);
    final planetColor = getPlanetColor(widget.yogini.currentYogini.planet);

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
          // Header with yogini symbol and title
          _buildHeader(yoginiColor, planetColor),
          
          const SizedBox(height: 18),
          
          // Progress Section
          _buildProgressSection(progressPercent, yoginiColor, totalYears),
        ],
      ),
    );
  }

  Widget _buildHeader(Color yoginiColor, Color planetColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Yogini symbol container
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: yoginiColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: yoginiColor.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              widget.yogini.currentYogini.symbol,
              style: TextStyle(
                fontSize: 22,
                color: yoginiColor,
              ),
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
                      'ACTIVE',
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
                '${widget.yogini.currentYogini.displayName} Dasha',
                style: GoogleFonts.instrumentSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              // Nature and ruling planet
              Row(
                children: [
                  Text(
                    widget.yogini.currentYogini.nature,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8B8798),
                    ),
                  ),
                  Container(
                    width: 3,
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A4858),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: planetColor.withOpacity(0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        getPlanetImagePath(widget.yogini.currentYogini.planet),
                        width: 14,
                        height: 14,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.yogini.currentYogini.planet,
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
                'Journey Progress',
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
              return _RefinedYoginiProgressBar(
                progress: _progressAnim.value,
                color: color,
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // Stats row
          Row(
            children: [
              _YoginiStatChip(
                icon: Icons.hourglass_top_rounded,
                value: formatDuration(widget.dynamicRemainingYears),
                label: 'Remaining',
                iconColor: color,
              ),
              _buildDivider(),
              _YoginiStatChip(
                icon: Icons.schedule_rounded,
                value: '$totalYears yrs',
                label: 'Duration',
                iconColor: const Color(0xFF7C7889),
              ),
              _buildDivider(),
              _YoginiStatChip(
                icon: Icons.check_circle_rounded,
                value: '${widget.completedPeriods}/8',
                label: 'Cycles',
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
}

// Refined Progress Bar for Yogini - Premium elegant thin design
class _RefinedYoginiProgressBar extends StatelessWidget {
  final double progress;
  final Color color;

  const _RefinedYoginiProgressBar({
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

// Stat Chip for Yogini
class _YoginiStatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _YoginiStatChip({
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

// ═══════════════════════════════════════════════════════════════════════════
// CURRENT PERIODS CARD
// ═══════════════════════════════════════════════════════════════════════════
class _CurrentPeriodsCard extends StatelessWidget {
  final YoginiDashaInfo yogini;
  final double dynamicRemainingYears;
  final DateTime now;

  const _CurrentPeriodsCard({
    required this.yogini,
    required this.dynamicRemainingYears,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CompactYoginiCard(
            label: 'Mahadasha',
            yogini: yogini.currentYogini,
            remainingYears: dynamicRemainingYears,
            progress: _calculateProgress(),
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 10),
        if (yogini.currentAntardasha != null)
          Expanded(
            child: _CompactYoginiCard(
              label: 'Antardasha',
              yogini: yogini.currentAntardasha!,
              remainingYears: yogini.antardashaRemainingYears ?? 0,
              progress: 0.5,
              isPrimary: false,
            ),
          ),
      ],
    );
  }

  double _calculateProgress() {
    final totalYears = yogini.currentYogini.years.toDouble();
    final elapsedYears = totalYears - dynamicRemainingYears;
    return (elapsedYears / totalYears).clamp(0.0, 1.0);
  }
}

class _CompactYoginiCard extends StatelessWidget {
  final String label;
  final Yogini yogini;
  final double remainingYears;
  final double progress;
  final bool isPrimary;

  const _CompactYoginiCard({
    required this.label,
    required this.yogini,
    required this.remainingYears,
    required this.progress,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getYoginiColor(yogini);

    return DashaPremiumCard(
      accentColor: color,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    yogini.symbol,
                    style: TextStyle(fontSize: 14, color: color),
                  ),
                ),
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
                      yogini.displayName,
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
            '${formatDuration(remainingYears)} left',
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
// YOGINI WHEEL CARD
// ═══════════════════════════════════════════════════════════════════════════
class _YoginiWheelCard extends StatelessWidget {
  final Yogini currentYogini;

  const _YoginiWheelCard({required this.currentYogini});

  @override
  Widget build(BuildContext context) {
    return DashaPremiumCard(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: Yogini.values.map((yogini) {
          final isCurrent = yogini == currentYogini;
          final color = _getYoginiColor(yogini);

          return Container(
            width: (MediaQuery.of(context).size.width - 80) / 4,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isCurrent
                  ? color.withOpacity(0.15)
                  : DashaColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrent
                    ? color.withOpacity(0.4)
                    : DashaColors.border.withOpacity(0.3),
                width: isCurrent ? 1.5 : 0.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  yogini.symbol,
                  style: TextStyle(
                    fontSize: 20,
                    color: isCurrent ? color : color.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  yogini.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                    color: isCurrent
                        ? DashaColors.textPrimary
                        : DashaColors.textTertiary,
                  ),
                ),
                Text(
                  '${yogini.years}y',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: isCurrent ? color : DashaColors.textTertiary,
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: DashaColors.emerald.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'NOW',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        color: DashaColors.emerald,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// YOGINI TIMELINE BAR - Auto-scrolls to current yogini
// ═══════════════════════════════════════════════════════════════════════════
class _YoginiTimelineBar extends StatefulWidget {
  final Yogini currentYogini;

  const _YoginiTimelineBar({required this.currentYogini});

  @override
  State<_YoginiTimelineBar> createState() => _YoginiTimelineBarState();
}

class _YoginiTimelineBarState extends State<_YoginiTimelineBar> {
  late ScrollController _scrollController;
  final double _itemWidth = 54.0; // 38px image + 16px padding

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
    final currentIndex = Yogini.values.indexOf(widget.currentYogini);
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
    final currentIndex = Yogini.values.indexOf(widget.currentYogini);

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
          children: Yogini.values.asMap().entries.map((entry) {
            final yogini = entry.value;
            final isCurrent = yogini == widget.currentYogini;
            final isPast = entry.key < currentIndex;
            final color = _getYoginiColor(yogini);

            return Padding(
              padding: EdgeInsets.only(
                left: entry.key == 0 ? 0 : 8,
                right: entry.key == Yogini.values.length - 1 ? 0 : 8,
              ),
              child: _YoginiTimelineItem(
                yogini: yogini,
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

// Individual yogini item in timeline
class _YoginiTimelineItem extends StatelessWidget {
  final Yogini yogini;
  final Color color;
  final bool isCurrent;
  final bool isPast;

  const _YoginiTimelineItem({
    required this.yogini,
    required this.color,
    required this.isCurrent,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isPast && !isCurrent ? 0.5 : 1.0;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Yogini symbol container
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isCurrent 
                ? color.withOpacity(0.2)
                : color.withOpacity(isPast ? 0.08 : 0.12),
            borderRadius: BorderRadius.circular(10),
            border: isCurrent
                ? Border.all(color: color.withOpacity(0.6), width: 2)
                : Border.all(color: color.withOpacity(0.2), width: 1),
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
          child: Center(
            child: Text(
              yogini.symbol,
              style: TextStyle(
                fontSize: 16,
                color: color.withOpacity(opacity),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Yogini name
        Text(
          _getShortYoginiName(yogini),
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

  String _getShortYoginiName(Yogini yogini) {
    // Return short 3-letter abbreviations for compact display
    const names = {
      Yogini.mangala: 'MAN',
      Yogini.pingala: 'PIN',
      Yogini.dhanya: 'DHA',
      Yogini.bhramari: 'BHR',
      Yogini.bhadrika: 'BHA',
      Yogini.ulka: 'ULK',
      Yogini.siddha: 'SID',
      Yogini.sankata: 'SAN',
    };
    return names[yogini] ?? yogini.displayName.substring(0, 3).toUpperCase();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PERIOD ITEMS
// ═══════════════════════════════════════════════════════════════════════════
class _YoginiPeriodItem extends StatelessWidget {
  final YoginiPeriodDetail periodDetail;
  final int index;
  final bool isCurrent;
  final bool isPast;

  const _YoginiPeriodItem({
    required this.periodDetail,
    required this.index,
    required this.isCurrent,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final yoginiColor = _getYoginiColor(periodDetail.yogini);

    return GestureDetector(
      onTap: () => _showYoginiPeriodSheet(context, periodDetail),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrent
              ? yoginiColor.withOpacity(0.08)
              : DashaColors.surface,
          borderRadius: BorderRadius.circular(DashaDesignTokens.radiusMd),
          border: Border.all(
            color: isCurrent
                ? yoginiColor.withOpacity(0.3)
                : DashaColors.border.withOpacity(isPast ? 0.15 : 0.3),
            width: isCurrent ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: yoginiColor.withOpacity(isCurrent ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  periodDetail.yogini.symbol,
                  style: TextStyle(
                    fontSize: 18,
                    color: isPast ? yoginiColor.withOpacity(0.5) : yoginiColor,
                  ),
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
                        periodDetail.yogini.displayName,
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
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      PremiumPlanetImage(
                        planet: periodDetail.yogini.planet,
                        size: 12,
                        showShadow: false,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ruled by ${periodDetail.yogini.planet}',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: getPlanetColor(periodDetail.yogini.planet).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
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
                color: yoginiColor.withOpacity(isPast ? 0.05 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${periodDetail.durationYears.round()}y',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPast ? DashaColors.textTertiary : yoginiColor,
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

  void _showYoginiPeriodSheet(BuildContext context, YoginiPeriodDetail period) {
    showYoginiPeriodBottomSheet(context, period, []);
  }
}

class _YoginiPeriodItemFallback extends StatelessWidget {
  final YoginiPeriod period;
  final int index;
  final bool isCurrent;
  final bool isPast;
  final DateTime startDate;
  final DateTime endDate;

  const _YoginiPeriodItemFallback({
    required this.period,
    required this.index,
    required this.isCurrent,
    required this.isPast,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final yoginiColor = _getYoginiColor(period.yogini);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent
            ? yoginiColor.withOpacity(0.08)
            : DashaColors.surface,
        borderRadius: BorderRadius.circular(DashaDesignTokens.radiusMd),
        border: Border.all(
          color: isCurrent
              ? yoginiColor.withOpacity(0.3)
              : DashaColors.border.withOpacity(isPast ? 0.15 : 0.3),
          width: isCurrent ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: yoginiColor.withOpacity(isCurrent ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                period.yogini.symbol,
                style: TextStyle(
                  fontSize: 18,
                  color: isPast ? yoginiColor.withOpacity(0.5) : yoginiColor,
                ),
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
                      period.yogini.displayName,
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
              color: yoginiColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${period.years}y',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: yoginiColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════
void showYoginiPeriodBottomSheet(
  BuildContext context,
  YoginiPeriodDetail period,
  List<String> breadcrumbs,
) {
  final levelColors = {
    YoginiLevel.mahadasha: DashaColors.mahadasha,
    YoginiLevel.antardasha: DashaColors.antardasha,
    YoginiLevel.pratyantara: DashaColors.pratyantara,
    YoginiLevel.sookshma: DashaColors.sookshma,
    YoginiLevel.prana: DashaColors.prana,
  };

  final levelColor = levelColors[period.level] ?? DashaColors.yogini;
  final yoginiColor = _getYoginiColor(period.yogini);
  final newBreadcrumbs = [...breadcrumbs, period.yogini.displayName];
  final now = DateTime.now();
  final isCurrentPeriod = period.containsDate(now);

  final hasSubPeriods = period.subPeriods != null && period.subPeriods!.isNotEmpty;

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
          border: Border.all(color: yoginiColor.withOpacity(0.3), width: 1),
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
            Padding(
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
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: yoginiColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: yoginiColor.withOpacity(0.3), width: 1),
                        ),
                        child: Center(
                          child: Text(
                            period.yogini.symbol,
                            style: TextStyle(fontSize: 22, color: yoginiColor),
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
                              '${period.yogini.displayName} ${period.levelName}',
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start', style: GoogleFonts.inter(fontSize: 9, color: DashaColors.textTertiary)),
                              Text(formatDate(period.startDate), style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w500, color: DashaColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 28, color: DashaColors.border),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('End', style: GoogleFonts.inter(fontSize: 9, color: DashaColors.textTertiary)),
                                Text(formatDate(period.endDate), style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w500, color: DashaColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                        Container(width: 1, height: 28, color: DashaColors.border),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Duration', style: GoogleFonts.inter(fontSize: 9, color: DashaColors.textTertiary)),
                                Text(formatDuration(period.durationYears), style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w600, color: yoginiColor)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (hasSubPeriods) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Sub-Periods (${period.subPeriods!.length})',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DashaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: hasSubPeriods
                  ? ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: period.subPeriods!.length,
                      itemBuilder: (context, index) {
                        final subPeriod = period.subPeriods![index];
                        final isSubCurrent = subPeriod.containsDate(now);
                        final subColor = _getYoginiColor(subPeriod.yogini);

                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            final deeperPeriod = _ensureYoginiSubPeriods(subPeriod);
                            showYoginiPeriodBottomSheet(context, deeperPeriod, newBreadcrumbs);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSubCurrent
                                  ? subColor.withOpacity(0.1)
                                  : DashaColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSubCurrent
                                    ? subColor.withOpacity(0.3)
                                    : DashaColors.border.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: subColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      subPeriod.yogini.symbol,
                                      style: TextStyle(fontSize: 14, color: subColor),
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
                                            subPeriod.yogini.displayName,
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
                                  formatDuration(subPeriod.durationYears),
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: DashaColors.textTertiary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: DashaColors.textTertiary.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'No sub-periods available',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: DashaColors.textTertiary,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}

YoginiPeriodDetail _ensureYoginiSubPeriods(YoginiPeriodDetail period) {
  if (period.subPeriods != null && period.subPeriods!.isNotEmpty) {
    return period;
  }

  final nextLevel = _getNextYoginiLevel(period.level);
  if (nextLevel == null) return period;

  final subPeriods = KundaliCalculationService.calculateYoginiSubPeriodsOnDemand(
    parentPeriod: period,
    depth: 1,
  );

  return YoginiPeriodDetail(
    yogini: period.yogini,
    fullPath: period.fullPath,
    durationYears: period.durationYears,
    startDate: period.startDate,
    endDate: period.endDate,
    level: period.level,
    subPeriods: subPeriods,
  );
}

YoginiLevel? _getNextYoginiLevel(YoginiLevel current) {
  switch (current) {
    case YoginiLevel.mahadasha:
      return YoginiLevel.antardasha;
    case YoginiLevel.antardasha:
      return YoginiLevel.pratyantara;
    case YoginiLevel.pratyantara:
      return YoginiLevel.sookshma;
    case YoginiLevel.sookshma:
      return YoginiLevel.prana;
    case YoginiLevel.prana:
      return null;
  }
}
