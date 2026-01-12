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
  DashaNavSection(id: 'current', label: l10n.charDasha_nav_current, color: DashaColors.emerald),
  DashaNavSection(id: 'karakas', label: l10n.charDasha_nav_karakas, color: DashaColors.char),
  DashaNavSection(id: 'timeline', label: l10n.charDasha_nav_timeline, color: DashaColors.sky),
];

// Static section IDs for initialization
const _sectionIds = ['current', 'karakas', 'timeline'];

/// Char Dasha View - Premium Jaimini sign-based Dasha system
class CharDashaView extends StatefulWidget {
  final KundaliData kundaliData;

  const CharDashaView({super.key, required this.kundaliData});

  @override
  State<CharDashaView> createState() => _CharDashaViewState();
}

class _CharDashaViewState extends State<CharDashaView> {
  late final ScrollController _scrollController;
  final Map<String, GlobalKey> _sectionKeys = {};
  final Map<String, GlobalKey<DashaAnimatedSectionWrapperState>> _animatedKeys =
      {};
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
    final charDasha = widget.kundaliData.charDashaInfo;

    if (charDasha == null) {
      return _buildNoDataView(l10n);
    }

    final now = DateTime.now();
    final dynamicRemainingYears = _calculateDynamicRemainingYears(
      charDasha,
      now,
    );
    final currentIndex = charDasha.sequence.indexWhere(
      (p) => p.sign == charDasha.currentSign,
    );
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
              _CharHeroCard(
                charDasha: charDasha,
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
                      title: l10n.charDasha_activeRasiDasha,
                      accentColor: DashaColors.emerald,
                      icon: Icons.timeline_rounded,
                    ),
                    const SizedBox(height: DashaDesignTokens.space12),
                    DashaAnimatedCardWrapper(
                      delay: 50,
                      child: _CurrentPeriodsCard(
                        charDasha: charDasha,
                        dynamicRemainingYears: dynamicRemainingYears,
                        now: now,
                      ),
                    ),
                    const SizedBox(height: DashaDesignTokens.space12),
                    DashaAnimatedCardWrapper(
                      delay: 100,
                      child: _DirectionCard(
                        startingSign: charDasha.startingSign,
                        isClockwise: charDasha.isClockwise,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DashaDesignTokens.space24),

              // Jaimini Karakas Section
              DashaAnimatedSectionWrapper(
                key: _animatedKeys['karakas'],
                sectionKey: _sectionKeys['karakas']!,
                accentColor: DashaColors.char,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashaAnimatedSectionHeader(
                      title: l10n.charDasha_jaiminiKarakas,
                      accentColor: DashaColors.char,
                      icon: Icons.star_rounded,
                    ),
                    const SizedBox(height: DashaDesignTokens.space12),
                    DashaAnimatedCardWrapper(
                      delay: 50,
                      child: _KarakasCard(karakas: charDasha.karakas),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DashaDesignTokens.space24),

              // Life Timeline
              DashaAnimatedSectionWrapper(
                key: _animatedKeys['timeline'],
                sectionKey: _sectionKeys['timeline']!,
                accentColor: DashaColors.sky,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashaAnimatedSectionHeader(
                      title: l10n.charDasha_rasiDashaTimeline,
                      accentColor: DashaColors.sky,
                      icon: Icons.view_timeline_rounded,
                    ),
                    const SizedBox(height: DashaDesignTokens.space12),
                    DashaAnimatedCardWrapper(
                      delay: 50,
                      child: _CharTimelineBar(
                        sequence: charDasha.sequence,
                        currentSign: charDasha.currentSign,
                      ),
                    ),
                    const SizedBox(height: DashaDesignTokens.space16),
                    ..._buildCharSequence(charDasha, now),
                  ],
                ),
              ),

              const SizedBox(height: DashaDesignTokens.space16),

              DashaInfoFooter(
                text: l10n.charDasha_infoFooter,
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

  Widget _buildNoDataView(AppLocalizations l10n) {
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
                color: DashaColors.char.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.hourglass_empty_rounded,
                size: 40,
                color: DashaColors.char.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.charDasha_unavailable,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DashaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.charDasha_unableToCalculate,
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

  double _calculateDynamicRemainingYears(
    CharDashaInfo charDasha,
    DateTime now,
  ) {
    if (charDasha.signEndDate != null) {
      final daysRemaining = charDasha.signEndDate!.difference(now).inDays;
      if (daysRemaining > 0) {
        return daysRemaining / 365.25;
      }
      return 0;
    }
    return charDasha.remainingYears;
  }

  List<Widget> _buildCharSequence(CharDashaInfo charDasha, DateTime now) {
    final widgets = <Widget>[];

    if (charDasha.charSequence != null && charDasha.charSequence!.isNotEmpty) {
      for (var i = 0; i < charDasha.charSequence!.length; i++) {
        final periodDetail = charDasha.charSequence![i];
        final isCurrent = periodDetail.sign == charDasha.currentSign;
        final isPast = periodDetail.endDate.isBefore(now);

        widgets.add(
          DashaAnimatedCardWrapper(
            delay: 100 + (i * 30),
            child: _CharPeriodItem(
              periodDetail: periodDetail,
              index: i,
              isCurrent: isCurrent,
              isPast: isPast,
              isClockwise: charDasha.isClockwise,
            ),
          ),
        );
      }
    } else {
      DateTime currentStart = charDasha.startDate;

      for (var i = 0; i < charDasha.sequence.length; i++) {
        final period = charDasha.sequence[i];
        final endDate = currentStart.add(
          Duration(days: (period.years * 365.25).round()),
        );
        final isCurrent = period.sign == charDasha.currentSign;
        final isPast = endDate.isBefore(now);

        widgets.add(
          DashaAnimatedCardWrapper(
            delay: 100 + (i * 30),
            child: _CharPeriodItemFallback(
              period: period,
              index: i,
              isCurrent: isCurrent,
              isPast: isPast,
              startDate: currentStart,
              endDate: endDate,
            ),
          ),
        );

        currentStart = endDate;
      }
    }

    return widgets;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HERO CARD
// ═══════════════════════════════════════════════════════════════════════════
class _CharHeroCard extends StatefulWidget {
  final CharDashaInfo charDasha;
  final double dynamicRemainingYears;
  final DateTime now;
  final int completedPeriods;

  const _CharHeroCard({
    required this.charDasha,
    required this.dynamicRemainingYears,
    required this.now,
    required this.completedPeriods,
  });

  @override
  State<_CharHeroCard> createState() => _CharHeroCardState();
}

class _CharHeroCardState extends State<_CharHeroCard>
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

    final currentPeriod = widget.charDasha.sequence.firstWhere(
      (p) => p.sign == widget.charDasha.currentSign,
      orElse: () => CharaPeriod(widget.charDasha.currentSign, 9),
    );
    final totalYears = currentPeriod.years;
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
    final currentPeriod = widget.charDasha.sequence.firstWhere(
      (p) => p.sign == widget.charDasha.currentSign,
      orElse: () => CharaPeriod(widget.charDasha.currentSign, 9),
    );
    final totalYears = currentPeriod.years;
    final signColor = getSignColor(widget.charDasha.currentSign);
    final lordPlanet = _getSignLord(widget.charDasha.currentSign);
    final lordColor = getPlanetColor(lordPlanet);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141218),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF262432), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with zodiac image and title
          _buildHeader(signColor, lordColor, lordPlanet),

          const SizedBox(height: 18),

          // Progress Section
          _buildProgressSection(signColor, totalYears),
        ],
      ),
    );
  }

  Widget _buildHeader(Color signColor, Color lordColor, String lordPlanet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Zodiac sign image
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: signColor.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              getZodiacImagePath(widget.charDasha.currentSign),
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: signColor.withOpacity(0.15),
                  child: Center(
                    child: Text(
                      getSignSymbol(widget.charDasha.currentSign),
                      style: TextStyle(fontSize: 24, color: signColor),
                    ),
                  ),
                );
              },
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
                      AppLocalizations.of(context).charDasha_active,
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
                AppLocalizations.of(context).charDasha_signRasiDasha(widget.charDasha.currentSign),
                style: GoogleFonts.instrumentSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              // Description and Lord
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _getSignDescription(widget.charDasha.currentSign, AppLocalizations.of(context)),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8B8798),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 3,
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
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
                          color: lordColor.withOpacity(0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        getPlanetImagePath(lordPlanet),
                        width: 14,
                        height: 14,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    lordPlanet,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: lordColor,
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

  Widget _buildProgressSection(Color color, int totalYears) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A181F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2838), width: 0.5),
      ),
      child: Column(
        children: [
          // Progress bar with label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).charDasha_journeyProgress,
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
              return _RefinedCharProgressBar(
                progress: _progressAnim.value,
                color: color,
              );
            },
          ),

          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              _CharStatChip(
                icon: Icons.hourglass_top_rounded,
                value: formatDurationLocalized(widget.dynamicRemainingYears, AppLocalizations.of(context)),
                label: AppLocalizations.of(context).charDasha_remaining,
                iconColor: color,
              ),
              _buildDivider(),
              _CharStatChip(
                icon: Icons.schedule_rounded,
                value: AppLocalizations.of(context).charDasha_yearsAbbr(totalYears.toString()),
                label: AppLocalizations.of(context).charDasha_duration,
                iconColor: const Color(0xFF7C7889),
              ),
              _buildDivider(),
              _CharStatChip(
                icon: Icons.check_circle_rounded,
                value: '${widget.completedPeriods}/12',
                label: AppLocalizations.of(context).charDasha_cycles,
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

  String _getSignDescription(String sign, AppLocalizations l10n) {
    switch (sign) {
      case 'Aries':
        return l10n.charDasha_signDesc_aries;
      case 'Taurus':
        return l10n.charDasha_signDesc_taurus;
      case 'Gemini':
        return l10n.charDasha_signDesc_gemini;
      case 'Cancer':
        return l10n.charDasha_signDesc_cancer;
      case 'Leo':
        return l10n.charDasha_signDesc_leo;
      case 'Virgo':
        return l10n.charDasha_signDesc_virgo;
      case 'Libra':
        return l10n.charDasha_signDesc_libra;
      case 'Scorpio':
        return l10n.charDasha_signDesc_scorpio;
      case 'Sagittarius':
        return l10n.charDasha_signDesc_sagittarius;
      case 'Capricorn':
        return l10n.charDasha_signDesc_capricorn;
      case 'Aquarius':
        return l10n.charDasha_signDesc_aquarius;
      case 'Pisces':
        return l10n.charDasha_signDesc_pisces;
      default:
        return l10n.charDasha_signDesc_default;
    }
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
}

// Refined Progress Bar for Char Dasha - Premium elegant thin design
class _RefinedCharProgressBar extends StatelessWidget {
  final double progress;
  final Color color;

  const _RefinedCharProgressBar({required this.progress, required this.color});

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

// Stat Chip for Char Dasha
class _CharStatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _CharStatChip({
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
  final CharDashaInfo charDasha;
  final double dynamicRemainingYears;
  final DateTime now;

  const _CurrentPeriodsCard({
    required this.charDasha,
    required this.dynamicRemainingYears,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _CompactSignCard(
            label: l10n.charDasha_rasiDasha,
            sign: charDasha.currentSign,
            remainingYears: dynamicRemainingYears,
            progress: _calculateProgress(),
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 10),
        if (charDasha.currentAntardasha != null)
          Expanded(
            child: _CompactSignCard(
              label: l10n.charDasha_antardasha,
              sign: charDasha.currentAntardasha!,
              remainingYears: charDasha.antardashaRemainingYears ?? 0,
              progress: 0.5,
              isPrimary: false,
            ),
          ),
      ],
    );
  }

  double _calculateProgress() {
    final currentPeriod = charDasha.sequence.firstWhere(
      (p) => p.sign == charDasha.currentSign,
      orElse: () => CharaPeriod(charDasha.currentSign, 9),
    );
    final totalYears = currentPeriod.years.toDouble();
    final elapsedYears = totalYears - dynamicRemainingYears;
    return (elapsedYears / totalYears).clamp(0.0, 1.0);
  }
}

class _CompactSignCard extends StatelessWidget {
  final String label;
  final String sign;
  final double remainingYears;
  final double progress;
  final bool isPrimary;

  const _CompactSignCard({
    required this.label,
    required this.sign,
    required this.remainingYears,
    required this.progress,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final color = getSignColor(sign);

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
                    getSignSymbol(sign),
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
                      sign,
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
            AppLocalizations.of(context).charDasha_left(formatDurationLocalized(remainingYears, AppLocalizations.of(context))),
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
// DIRECTION CARD
// ═══════════════════════════════════════════════════════════════════════════
class _DirectionCard extends StatelessWidget {
  final String startingSign;
  final bool isClockwise;

  const _DirectionCard({required this.startingSign, required this.isClockwise});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DashaPremiumCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DashaColors.char.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                isClockwise
                    ? Icons.rotate_right_rounded
                    : Icons.rotate_left_rounded,
                size: 22,
                color: DashaColors.char,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.charDasha_dashaDirection,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: DashaColors.textTertiary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      isClockwise ? l10n.charDasha_clockwise : l10n.charDasha_antiClockwise,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DashaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: getSignColor(startingSign).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l10n.charDasha_fromSign(startingSign),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: getSignColor(startingSign),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: getSignColor(startingSign).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                getSignSymbol(startingSign),
                style: TextStyle(
                  fontSize: 16,
                  color: getSignColor(startingSign),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// KARAKAS CARD
// ═══════════════════════════════════════════════════════════════════════════
class _KarakasCard extends StatelessWidget {
  final JaiminiKarakas karakas;

  const _KarakasCard({required this.karakas});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DashaPremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary Karakas row
          Row(
            children: [
              Expanded(
                child: _KarakaItem(
                  shortName: l10n.charDasha_karaka_ak,
                  fullName: l10n.charDasha_karaka_atmakaraka,
                  planet: karakas.atmakaraka,
                  degree: karakas.atmakarakaDegree,
                  isHighlight: true,
                ),
              ),
              Expanded(
                child: _KarakaItem(
                  shortName: l10n.charDasha_karaka_amk,
                  fullName: l10n.charDasha_karaka_amatyakaraka,
                  planet: karakas.amatyakaraka,
                  degree: karakas.amatyakarakaDegree,
                ),
              ),
              Expanded(
                child: _KarakaItem(
                  shortName: l10n.charDasha_karaka_bk,
                  fullName: l10n.charDasha_karaka_bhratrikaraka,
                  planet: karakas.bhratrikaraka,
                  degree: karakas.bhratrikarakaDegree,
                ),
              ),
              Expanded(
                child: _KarakaItem(
                  shortName: l10n.charDasha_karaka_mk,
                  fullName: l10n.charDasha_karaka_matrikaraka,
                  planet: karakas.matrikaraka,
                  degree: karakas.matrikarakaDegree,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Secondary Karakas row
          Row(
            children: [
              Expanded(
                child: _KarakaItem(
                  shortName: l10n.charDasha_karaka_pik,
                  fullName: l10n.charDasha_karaka_pitrikaraka,
                  planet: karakas.pitrikaraka,
                  degree: karakas.pitrikarakaDegree,
                ),
              ),
              Expanded(
                child: _KarakaItem(
                  shortName: l10n.charDasha_karaka_puk,
                  fullName: l10n.charDasha_karaka_putrakaraka,
                  planet: karakas.putrakaraka,
                  degree: karakas.putrakarakaDegree,
                ),
              ),
              Expanded(
                child: _KarakaItem(
                  shortName: l10n.charDasha_karaka_gk,
                  fullName: l10n.charDasha_karaka_gnatikaraka,
                  planet: karakas.gnatikaraka,
                  degree: karakas.gnatrikarakaDegree,
                ),
              ),
              Expanded(
                child: _KarakaItem(
                  shortName: l10n.charDasha_karaka_dk,
                  fullName: l10n.charDasha_karaka_darakaraka,
                  planet: karakas.darakaraka,
                  degree: karakas.darakarakaDegree,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Karakamsa
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: DashaColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: DashaColors.border.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: DashaColors.char.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      getSignSymbol(karakas.karakamsa),
                      style: TextStyle(fontSize: 14, color: DashaColors.char),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.charDasha_karakamsa,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: DashaColors.textTertiary,
                      ),
                    ),
                    Text(
                      l10n.charDasha_karakamsa_desc(karakas.karakamsa),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DashaColors.textPrimary,
                      ),
                    ),
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

class _KarakaItem extends StatelessWidget {
  final String shortName;
  final String fullName;
  final String planet;
  final double degree;
  final bool isHighlight;

  const _KarakaItem({
    required this.shortName,
    required this.fullName,
    required this.planet,
    required this.degree,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final planetColor = getPlanetColor(planet);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color:
            isHighlight
                ? planetColor.withOpacity(0.1)
                : DashaColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              isHighlight
                  ? planetColor.withOpacity(0.3)
                  : DashaColors.border.withOpacity(0.3),
          width: isHighlight ? 1 : 0.5,
        ),
      ),
      child: Column(
        children: [
          PremiumPlanetImage(
            planet: planet,
            size: 28,
            isActive: isHighlight,
            showShadow: true,
          ),
          const SizedBox(height: 4),
          Text(
            shortName,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isHighlight ? planetColor : DashaColors.textSecondary,
            ),
          ),
          Text(
            planet,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: DashaColors.textTertiary,
            ),
          ),
          Text(
            '${degree.toStringAsFixed(1)}°',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8,
              color: DashaColors.textTertiary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CHAR TIMELINE BAR - Auto-scrolls to current period
// ═══════════════════════════════════════════════════════════════════════════
class _CharTimelineBar extends StatefulWidget {
  final List<CharaPeriod> sequence;
  final String currentSign;

  const _CharTimelineBar({required this.sequence, required this.currentSign});

  @override
  State<_CharTimelineBar> createState() => _CharTimelineBarState();
}

class _CharTimelineBarState extends State<_CharTimelineBar> {
  late ScrollController _scrollController;
  final double _itemWidth = 48.0; // 36px image + 12px padding

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
    final currentIndex = widget.sequence.indexWhere(
      (p) => p.sign == widget.currentSign,
    );
    if (currentIndex < 0) return;

    // Calculate scroll offset to center the current item
    final screenWidth = MediaQuery.of(context).size.width;
    final containerPadding = 16 * 2 + 10 * 2; // outer padding + inner padding
    final availableWidth = screenWidth - containerPadding;

    // Position to scroll to (center the item)
    final targetOffset =
        (currentIndex * _itemWidth) - (availableWidth / 2) + (_itemWidth / 2);
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
    final currentIndex = widget.sequence.indexWhere(
      (p) => p.sign == widget.currentSign,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141218),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF262432), width: 1),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children:
              widget.sequence.asMap().entries.map((entry) {
                final period = entry.value;
                final isCurrent = period.sign == widget.currentSign;
                final isPast = entry.key < currentIndex;
                final color = getSignColor(period.sign);

                return Padding(
                  padding: EdgeInsets.only(
                    left: entry.key == 0 ? 0 : 6,
                    right: entry.key == widget.sequence.length - 1 ? 0 : 6,
                  ),
                  child: _CharTimelineItem(
                    sign: period.sign,
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

// Individual sign item in timeline
class _CharTimelineItem extends StatelessWidget {
  final String sign;
  final int years;
  final Color color;
  final bool isCurrent;
  final bool isPast;

  const _CharTimelineItem({
    required this.sign,
    required this.years,
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
        // Zodiac sign image container
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border:
                isCurrent
                    ? Border.all(color: color.withOpacity(0.6), width: 2)
                    : Border.all(color: const Color(0xFF2A2838), width: 1),
            boxShadow:
                isCurrent
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
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              getZodiacImagePath(sign),
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              opacity: AlwaysStoppedAnimation(opacity),
              errorBuilder:
                  (_, __, ___) => Container(
                    color: color.withOpacity(0.15),
                    child: Center(
                      child: Text(
                        getSignSymbol(sign),
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
        const SizedBox(height: 5),
        // Sign name
        Text(
          _getShortSignName(sign),
          style: GoogleFonts.inter(
            fontSize: 7,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
            color:
                isCurrent
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

  String _getShortSignName(String sign) {
    // Return short 3-letter abbreviations for compact display
    const names = {
      'Aries': 'ARI',
      'Taurus': 'TAU',
      'Gemini': 'GEM',
      'Cancer': 'CAN',
      'Leo': 'LEO',
      'Virgo': 'VIR',
      'Libra': 'LIB',
      'Scorpio': 'SCO',
      'Sagittarius': 'SAG',
      'Capricorn': 'CAP',
      'Aquarius': 'AQU',
      'Pisces': 'PIS',
    };
    return names[sign] ?? sign.substring(0, 3).toUpperCase();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PERIOD ITEMS - Premium Minimal Design
// ═══════════════════════════════════════════════════════════════════════════
class _CharPeriodItem extends StatefulWidget {
  final CharaPeriodDetail periodDetail;
  final int index;
  final bool isCurrent;
  final bool isPast;
  final bool isClockwise;

  const _CharPeriodItem({
    required this.periodDetail,
    required this.index,
    required this.isCurrent,
    required this.isPast,
    required this.isClockwise,
  });

  @override
  State<_CharPeriodItem> createState() => _CharPeriodItemState();
}

class _CharPeriodItemState extends State<_CharPeriodItem> {
  bool _isPressed = false;

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

  @override
  Widget build(BuildContext context) {
    final signColor = getSignColor(widget.periodDetail.sign);
    final lordPlanet =
        widget.periodDetail.signLord ?? _getSignLord(widget.periodDetail.sign);
    final lordColor = getPlanetColor(lordPlanet);
    final opacity = widget.isPast && !widget.isCurrent ? 0.6 : 1.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        showCharPeriodBottomSheet(
          context,
          widget.periodDetail,
          [],
          widget.isClockwise,
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:
              _isPressed
                  ? const Color(0xFF1A1820)
                  : widget.isCurrent
                  ? const Color(0xFF161420)
                  : const Color(0xFF141218),
          borderRadius: BorderRadius.circular(14),
          border:
              widget.isCurrent
                  ? Border.all(color: signColor.withOpacity(0.25), width: 1)
                  : null,
        ),
        child: Row(
          children: [
            // Zodiac sign image
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: signColor.withOpacity(
                      widget.isCurrent ? 0.25 : 0.15,
                    ),
                    blurRadius: widget.isCurrent ? 12 : 8,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  getZodiacImagePath(widget.periodDetail.sign),
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  opacity: AlwaysStoppedAnimation(opacity),
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: signColor.withOpacity(0.15),
                        child: Center(
                          child: Text(
                            getSignSymbol(widget.periodDetail.sign),
                            style: TextStyle(
                              fontSize: 20,
                              color: signColor.withOpacity(opacity),
                            ),
                          ),
                        ),
                      ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sign name with status
                  Row(
                    children: [
                      Text(
                        widget.periodDetail.sign,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight:
                              widget.isCurrent
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                          color:
                              widget.isPast
                                  ? const Color(0xFF7A7786)
                                  : Colors.white,
                        ),
                      ),
                      if (widget.isPast && !widget.isCurrent) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: const Color(0xFF4ADE80).withOpacity(0.5),
                        ),
                      ],
                      if (widget.isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3A2A),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4ADE80),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context).charDasha_now,
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF4ADE80),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Lord with planet image
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: lordColor.withOpacity(0.25),
                              blurRadius: 4,
                              spreadRadius: -1,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(
                            getPlanetImagePath(lordPlanet),
                            width: 14,
                            height: 14,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  color: lordColor.withOpacity(0.2),
                                  child: Center(
                                    child: Text(
                                      getPlanetSymbol(lordPlanet),
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: lordColor,
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        lordPlanet,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: lordColor.withOpacity(
                            widget.isPast ? 0.6 : 0.9,
                          ),
                        ),
                      ),
                      Container(
                        width: 3,
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A4858),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        '${formatDateShort(widget.periodDetail.startDate)} → ${formatDateShort(widget.periodDetail.endDate)}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: const Color(0xFF6A6778),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Duration badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color:
                    widget.isCurrent
                        ? signColor.withOpacity(0.12)
                        : const Color(0xFF1A1820),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppLocalizations.of(context).dasha_year_suffix(widget.periodDetail.durationYears.round()),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color:
                      widget.isPast
                          ? const Color(0xFF6A6778)
                          : widget.isCurrent
                          ? signColor
                          : const Color(0xFF9A97A6),
                ),
              ),
            ),

            const SizedBox(width: 6),

            // Arrow
            AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: _isPressed ? 1.0 : 0.4,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: const Color(0xFF6A6778),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharPeriodItemFallback extends StatefulWidget {
  final CharaPeriod period;
  final int index;
  final bool isCurrent;
  final bool isPast;
  final DateTime startDate;
  final DateTime endDate;

  const _CharPeriodItemFallback({
    required this.period,
    required this.index,
    required this.isCurrent,
    required this.isPast,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<_CharPeriodItemFallback> createState() =>
      _CharPeriodItemFallbackState();
}

class _CharPeriodItemFallbackState extends State<_CharPeriodItemFallback> {
  bool _isPressed = false;

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

  @override
  Widget build(BuildContext context) {
    final signColor = getSignColor(widget.period.sign);
    final lordPlanet = _getSignLord(widget.period.sign);
    final lordColor = getPlanetColor(lordPlanet);
    final opacity = widget.isPast && !widget.isCurrent ? 0.6 : 1.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:
              _isPressed
                  ? const Color(0xFF1A1820)
                  : widget.isCurrent
                  ? const Color(0xFF161420)
                  : const Color(0xFF141218),
          borderRadius: BorderRadius.circular(14),
          border:
              widget.isCurrent
                  ? Border.all(color: signColor.withOpacity(0.25), width: 1)
                  : null,
        ),
        child: Row(
          children: [
            // Zodiac sign image
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: signColor.withOpacity(
                      widget.isCurrent ? 0.25 : 0.15,
                    ),
                    blurRadius: widget.isCurrent ? 12 : 8,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  getZodiacImagePath(widget.period.sign),
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  opacity: AlwaysStoppedAnimation(opacity),
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: signColor.withOpacity(0.15),
                        child: Center(
                          child: Text(
                            getSignSymbol(widget.period.sign),
                            style: TextStyle(
                              fontSize: 20,
                              color: signColor.withOpacity(opacity),
                            ),
                          ),
                        ),
                      ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sign name with status
                  Row(
                    children: [
                      Text(
                        widget.period.sign,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight:
                              widget.isCurrent
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                          color:
                              widget.isPast
                                  ? const Color(0xFF7A7786)
                                  : Colors.white,
                        ),
                      ),
                      if (widget.isPast && !widget.isCurrent) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: const Color(0xFF4ADE80).withOpacity(0.5),
                        ),
                      ],
                      if (widget.isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3A2A),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4ADE80),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context).charDasha_now,
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF4ADE80),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Lord with planet image
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: lordColor.withOpacity(0.25),
                              blurRadius: 4,
                              spreadRadius: -1,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(
                            getPlanetImagePath(lordPlanet),
                            width: 14,
                            height: 14,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  color: lordColor.withOpacity(0.2),
                                  child: Center(
                                    child: Text(
                                      getPlanetSymbol(lordPlanet),
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: lordColor,
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        lordPlanet,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: lordColor.withOpacity(
                            widget.isPast ? 0.6 : 0.9,
                          ),
                        ),
                      ),
                      Container(
                        width: 3,
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A4858),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        '${formatDateShort(widget.startDate)} → ${formatDateShort(widget.endDate)}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: const Color(0xFF6A6778),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Duration badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color:
                    widget.isCurrent
                        ? signColor.withOpacity(0.12)
                        : const Color(0xFF1A1820),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${widget.period.years}y',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color:
                      widget.isPast
                          ? const Color(0xFF6A6778)
                          : widget.isCurrent
                          ? signColor
                          : const Color(0xFF9A97A6),
                ),
              ),
            ),

            const SizedBox(width: 6),

            // Arrow
            AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: _isPressed ? 1.0 : 0.4,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 18,
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
// BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════
void showCharPeriodBottomSheet(
  BuildContext context,
  CharaPeriodDetail period,
  List<String> breadcrumbs,
  bool isClockwise,
) {
  final levelColors = {
    CharLevel.mahadasha: DashaColors.mahadasha,
    CharLevel.antardasha: DashaColors.antardasha,
    CharLevel.pratyantara: DashaColors.pratyantara,
    CharLevel.sookshma: DashaColors.sookshma,
    CharLevel.prana: DashaColors.prana,
  };

  final levelColor = levelColors[period.level] ?? DashaColors.char;
  final signColor = getSignColor(period.sign);
  final newBreadcrumbs = [...breadcrumbs, period.sign];
  final now = DateTime.now();
  final isCurrentPeriod = period.containsDate(now);

  final hasSubPeriods =
      period.subPeriods != null && period.subPeriods!.isNotEmpty;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder:
              (context, scrollController) => Container(
                decoration: BoxDecoration(
                  color: DashaColors.bgSecondary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  border: Border.all(
                    color: signColor.withOpacity(0.3),
                    width: 1,
                  ),
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
                                  color: signColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: signColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    getSignSymbol(period.sign),
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: signColor,
                                    ),
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
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: levelColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
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
                                      '${period.sign} ${period.levelName}',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context).charDasha_start,
                                        style: GoogleFonts.inter(
                                          fontSize: 9,
                                          color: DashaColors.textTertiary,
                                        ),
                                      ),
                                      Text(
                                        formatDate(period.startDate),
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: DashaColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 28,
                                  color: DashaColors.border,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context).charDasha_end,
                                          style: GoogleFonts.inter(
                                            fontSize: 9,
                                            color: DashaColors.textTertiary,
                                          ),
                                        ),
                                        Text(
                                          formatDate(period.endDate),
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: DashaColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 28,
                                  color: DashaColors.border,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context).charDasha_duration,
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
                                            color: signColor,
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
                    ),
                    if (hasSubPeriods) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context).charDasha_subPeriods(period.subPeriods!.length.toString()),
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
                      child:
                          hasSubPeriods
                              ? ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  24,
                                ),
                                itemCount: period.subPeriods!.length,
                                itemBuilder: (context, index) {
                                  final subPeriod = period.subPeriods![index];
                                  final isSubCurrent = subPeriod.containsDate(
                                    now,
                                  );
                                  final subColor = getSignColor(subPeriod.sign);

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      final deeperPeriod =
                                          _ensureCharSubPeriods(
                                            subPeriod,
                                            isClockwise,
                                          );
                                      showCharPeriodBottomSheet(
                                        context,
                                        deeperPeriod,
                                        newBreadcrumbs,
                                        isClockwise,
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSubCurrent
                                                ? subColor.withOpacity(0.1)
                                                : DashaColors.surface,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color:
                                              isSubCurrent
                                                  ? subColor.withOpacity(0.3)
                                                  : DashaColors.border
                                                      .withOpacity(0.3),
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Text(
                                                getSignSymbol(subPeriod.sign),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: subColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      subPeriod.sign,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            isSubCurrent
                                                                ? FontWeight
                                                                    .w600
                                                                : FontWeight
                                                                    .w500,
                                                        color:
                                                            DashaColors
                                                                .textPrimary,
                                                      ),
                                                    ),
                                                    if (isSubCurrent) ...[
                                                      const SizedBox(width: 8),
                                                      const ActiveNowBadge(
                                                        fontSize: 7,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${formatDateShort(subPeriod.startDate)} - ${formatDateShort(subPeriod.endDate)}',
                                                  style:
                                                      GoogleFonts.jetBrainsMono(
                                                        fontSize: 9,
                                                        color:
                                                            DashaColors
                                                                .textTertiary,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            formatDurationLocalized(
                                              subPeriod.durationYears, AppLocalizations.of(context)),
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
                                            color: DashaColors.textTertiary
                                                .withOpacity(0.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                              : Center(
                                  child: Text(
                                    AppLocalizations.of(context).charDasha_noSubPeriods,
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

CharaPeriodDetail _ensureCharSubPeriods(
  CharaPeriodDetail period,
  bool isClockwise,
) {
  if (period.subPeriods != null && period.subPeriods!.isNotEmpty) {
    return period;
  }

  final nextLevel = _getNextCharLevel(period.level);
  if (nextLevel == null) return period;

  final subPeriods = KundaliCalculationService.calculateCharSubPeriodsOnDemand(
    parentPeriod: period,
    isClockwise: isClockwise,
    depth: 1,
  );

  return CharaPeriodDetail(
    sign: period.sign,
    fullPath: period.fullPath,
    durationYears: period.durationYears,
    startDate: period.startDate,
    endDate: period.endDate,
    level: period.level,
    subPeriods: subPeriods,
    signLord: period.signLord,
  );
}

CharLevel? _getNextCharLevel(CharLevel current) {
  switch (current) {
    case CharLevel.mahadasha:
      return CharLevel.antardasha;
    case CharLevel.antardasha:
      return CharLevel.pratyantara;
    case CharLevel.pratyantara:
      return CharLevel.sookshma;
    case CharLevel.sookshma:
      return CharLevel.prana;
    case CharLevel.prana:
      return null;
  }
}
