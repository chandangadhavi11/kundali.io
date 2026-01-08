import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/constants.dart' show getPlanetColor, getPlanetSymbol, getSignColor, getSignSymbol, getZodiacImagePath;
export '../../shared/constants.dart' show getSignColor, getSignSymbol, getZodiacImagePath;

// ═══════════════════════════════════════════════════════════════════════════
// PREMIUM DESIGN SYSTEM TOKENS
// ═══════════════════════════════════════════════════════════════════════════
class DashaDesignTokens {
  DashaDesignTokens._();

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
  static const double radiusXl = 20;
  static const double radiusPill = 28;

  // Typography
  static TextStyle get labelXs => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: DashaColors.textTertiary,
      );

  static TextStyle get labelSm => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: DashaColors.textSecondary,
      );

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: DashaColors.textPrimary,
      );

  static TextStyle get titleSm => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: DashaColors.textPrimary,
      );

  static TextStyle get titleMd => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: DashaColors.textPrimary,
      );

  static TextStyle get mono => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: DashaColors.textSecondary,
      );

  // Shadows
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  // Animation
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Curve curveStandard = Curves.easeOutCubic;
}

// ═══════════════════════════════════════════════════════════════════════════
// PREMIUM COLOR PALETTE
// ═══════════════════════════════════════════════════════════════════════════
class DashaColors {
  DashaColors._();

  // Surfaces
  static const Color bgPrimary = Color(0xFF0D0B14);
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

  // Accent colors - sophisticated and muted
  static const Color gold = Color(0xFFD4AF37);
  static const Color violet = Color(0xFF9580FF);
  static const Color emerald = Color(0xFF4ADE80);
  static const Color rose = Color(0xFFF472B6);
  static const Color sky = Color(0xFF38BDF8);
  static const Color amber = Color(0xFFFBBF24);
  static const Color coral = Color(0xFFF87171);
  static const Color teal = Color(0xFF2DD4BF);
  static const Color purple = Color(0xFFA78BFA);
  static const Color indigo = Color(0xFF818CF8);

  // Dasha-specific colors
  static const Color vimshottari = Color(0xFFD4AF37);
  static const Color yogini = Color(0xFFA78BFA);
  static const Color char = Color(0xFF4ADE80);
  static const Color phala = Color(0xFFFF9500);

  // Level colors
  static const Color mahadasha = Color(0xFFE8B931);
  static const Color antardasha = Color(0xFFA78BFA);
  static const Color pratyantara = Color(0xFF4ADE80);
  static const Color sookshma = Color(0xFF38BDF8);
  static const Color prana = Color(0xFFF472B6);
}

// ═══════════════════════════════════════════════════════════════════════════
// NAVIGATION SECTION DATA
// ═══════════════════════════════════════════════════════════════════════════
class DashaNavSection {
  final String id;
  final String label;
  final Color color;

  const DashaNavSection({
    required this.id,
    required this.label,
    required this.color,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATED SECTION WRAPPER - Premium Highlight Effect
// ═══════════════════════════════════════════════════════════════════════════
class DashaAnimatedSectionWrapper extends StatefulWidget {
  final GlobalKey sectionKey;
  final Color accentColor;
  final Widget child;

  const DashaAnimatedSectionWrapper({
    super.key,
    required this.sectionKey,
    required this.accentColor,
    required this.child,
  });

  @override
  State<DashaAnimatedSectionWrapper> createState() =>
      DashaAnimatedSectionWrapperState();
}

class DashaAnimatedSectionWrapperState
    extends State<DashaAnimatedSectionWrapper> {
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
    return DashaSectionAnimationProvider(
      isHighlighted: _isHighlighted,
      accentColor: widget.accentColor,
      child: Container(key: widget.sectionKey, child: widget.child),
    );
  }
}

// InheritedWidget to pass animation state to children
class DashaSectionAnimationProvider extends InheritedWidget {
  final bool isHighlighted;
  final Color accentColor;

  const DashaSectionAnimationProvider({
    super.key,
    required this.isHighlighted,
    required this.accentColor,
    required super.child,
  });

  static DashaSectionAnimationProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DashaSectionAnimationProvider>();
  }

  @override
  bool updateShouldNotify(DashaSectionAnimationProvider oldWidget) {
    return isHighlighted != oldWidget.isHighlighted;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATED SECTION HEADER - Elegant underline sweep + text pulse
// ═══════════════════════════════════════════════════════════════════════════
class DashaAnimatedSectionHeader extends StatefulWidget {
  final String title;
  final Color accentColor;
  final IconData? icon;

  const DashaAnimatedSectionHeader({
    super.key,
    required this.title,
    required this.accentColor,
    this.icon,
  });

  @override
  State<DashaAnimatedSectionHeader> createState() =>
      _DashaAnimatedSectionHeaderState();
}

class _DashaAnimatedSectionHeaderState extends State<DashaAnimatedSectionHeader>
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
    final provider = DashaSectionAnimationProvider.of(context);
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
          DashaColors.textTertiary,
          widget.accentColor,
          textPulse * 0.8,
        )!;

        return Padding(
          padding: const EdgeInsets.only(left: DashaDesignTokens.space4),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 14,
                    color: widget.accentColor,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Column(
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth =
                          math.min(constraints.maxWidth * 0.3, 40.0);
                      return Container(
                        height: 2,
                        width: maxWidth * underlineWidth,
                        decoration: BoxDecoration(
                          color:
                              widget.accentColor.withOpacity(0.6 + textPulse * 0.4),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      );
                    },
                  ),
                ],
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
class DashaAnimatedCardWrapper extends StatefulWidget {
  final Widget child;
  final int delay;

  const DashaAnimatedCardWrapper({super.key, required this.child, this.delay = 0});

  @override
  State<DashaAnimatedCardWrapper> createState() =>
      _DashaAnimatedCardWrapperState();
}

class _DashaAnimatedCardWrapperState extends State<DashaAnimatedCardWrapper>
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
            Tween(begin: 1.0, end: 1.025).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.025, end: 1.0)
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
    final provider = DashaSectionAnimationProvider.of(context);
    if (provider?.isHighlighted == true) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _controller.forward(from: 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = DashaSectionAnimationProvider.of(context);
    final accentColor = provider?.accentColor ?? DashaColors.violet;

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
                    borderRadius:
                        BorderRadius.circular(DashaDesignTokens.radiusLg),
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
// FLOATING NAVIGATION BAR - Premium Glass Design
// ═══════════════════════════════════════════════════════════════════════════
class DashaFloatingNavBar extends StatefulWidget {
  final List<DashaNavSection> sections;
  final int activeIndex;
  final ValueChanged<int> onTap;

  const DashaFloatingNavBar({
    super.key,
    required this.sections,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  State<DashaFloatingNavBar> createState() => _DashaFloatingNavBarState();
}

class _DashaFloatingNavBarState extends State<DashaFloatingNavBar> {
  late final ScrollController _scrollController;
  final List<GlobalKey> _itemKeys = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    for (int i = 0; i < widget.sections.length; i++) {
      _itemKeys.add(GlobalKey());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DashaFloatingNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndex != widget.activeIndex) {
      _scrollToActiveItem();
    }
  }

  void _scrollToActiveItem() {
    if (widget.activeIndex >= _itemKeys.length) return;
    final key = _itemKeys[widget.activeIndex];
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: DashaColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: DashaColors.borderSubtle, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            spreadRadius: -4,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: widget.sections.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final section = widget.sections[index];
            final isActive = index == widget.activeIndex;
            return _DashaNavPill(
              key: _itemKeys[index],
              label: section.label,
              color: section.color,
              isActive: isActive,
              onTap: () => widget.onTap(index),
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NAV PILL - Premium animated pill button
// ═══════════════════════════════════════════════════════════════════════════
class _DashaNavPill extends StatefulWidget {
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _DashaNavPill({
    super.key,
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_DashaNavPill> createState() => _DashaNavPillState();
}

class _DashaNavPillState extends State<_DashaNavPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
      value: widget.isActive ? 1.0 : 0.0,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_DashaNavPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final activeValue = _animationController.value;

        final bgColor = Color.lerp(
          Colors.transparent,
          widget.color.withOpacity(0.15),
          activeValue,
        )!;

        final textColor = Color.lerp(
          DashaColors.textTertiary,
          widget.color,
          activeValue,
        )!;

        final borderColor = Color.lerp(
          Colors.transparent,
          widget.color.withOpacity(0.3),
          activeValue,
        )!;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14 + (activeValue * 4),
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: activeValue > 0.5
                  ? [
                      BoxShadow(
                        color: widget.color.withOpacity(0.2 * activeValue),
                        blurRadius: 8,
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Active indicator dot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: activeValue > 0.5 ? 6 : 0,
                  height: 6,
                  margin: EdgeInsets.only(right: activeValue > 0.5 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight:
                        activeValue > 0.5 ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
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
// PREMIUM CARD CONTAINER
// ═══════════════════════════════════════════════════════════════════════════
class DashaPremiumCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final EdgeInsetsGeometry? padding;
  final bool elevated;

  const DashaPremiumCard({
    super.key,
    required this.child,
    this.accentColor,
    this.padding,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(DashaDesignTokens.space16),
      decoration: BoxDecoration(
        color: elevated ? DashaColors.surfaceElevated : DashaColors.surface,
        borderRadius: BorderRadius.circular(DashaDesignTokens.radiusLg),
        border: Border.all(
          color: accentColor?.withOpacity(0.15) ?? DashaColors.border,
          width: 0.5,
        ),
        boxShadow: elevated ? DashaDesignTokens.shadowMd : null,
      ),
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS (Updated for premium design)
// ═══════════════════════════════════════════════════════════════════════════

/// Shared Section Header Widget for all Dasha views
class DashaSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const DashaSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DashaColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: DashaColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Date Badge Widget for showing start/end dates
class DashaDateBadge extends StatelessWidget {
  final String label;
  final DateTime date;
  final IconData icon;

  const DashaDateBadge({
    super.key,
    required this.label,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: DashaColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: DashaColors.borderSubtle,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: DashaColors.textTertiary),
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
                formatDate(date),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: DashaColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Info Footer Widget for Dasha explanations
class DashaInfoFooter extends StatelessWidget {
  final String text;

  const DashaInfoFooter({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashaColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: DashaColors.borderSubtle,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 14,
            color: DashaColors.textTertiary.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 9,
                color: DashaColors.textTertiary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Active Badge Widget showing "NOW" indicator
class ActiveNowBadge extends StatelessWidget {
  final double fontSize;

  const ActiveNowBadge({super.key, this.fontSize = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: DashaColors.emerald.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: DashaColors.emerald,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'NOW',
            style: GoogleFonts.jetBrainsMono(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: DashaColors.emerald,
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress Bar Widget
class DashaProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final double height;

  const DashaProgressBar({
    super.key,
    required this.progress,
    required this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: DashaColors.border.withOpacity(0.3),
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
        FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Hero Stat Item Widget
class DashaHeroStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const DashaHeroStatItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: DashaColors.textPrimary,
            ),
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
    );
  }
}

/// Dasha Type Colors (Legacy compatibility)
class DashaTypeColors {
  DashaTypeColors._();

  static const vimshottariPrimary = DashaColors.vimshottari;
  static const vimshottariSecondary = Color(0xFFE8C547);

  static const phalaPrimary = DashaColors.phala;
  static const phalaSecondary = Color(0xFFFFB84D);

  static const yoginiPrimary = DashaColors.yogini;
  static const yoginiSecondary = Color(0xFFC4B5FD);

  static const charPrimary = DashaColors.char;
  static const charSecondary = Color(0xFF34D399);

  static const mahadasha = DashaColors.mahadasha;
  static const antardasha = DashaColors.antardasha;
  static const pratyantara = DashaColors.pratyantara;
  static const sookshma = DashaColors.sookshma;
  static const prana = DashaColors.prana;
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

/// Format date as "d MMM yyyy"
String formatDate(DateTime date) {
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
    'Dec'
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// Format date as "d/M/yy"
String formatDateShort(DateTime date) {
  return '${date.day}/${date.month}/${date.year.toString().substring(2)}';
}

/// Format date with time
String formatDateWithTime(DateTime date) {
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
    'Dec'
  ];
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute';
}

/// Format date short with time
String formatDateShortWithTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day}/${date.month} $hour:$minute';
}

/// Format duration in years, months, days
String formatDuration(double durationYears) {
  final totalDays = durationYears * 365.25;

  if (totalDays >= 365) {
    final years = totalDays ~/ 365.25;
    final remainingDays = totalDays - (years * 365.25);
    final months = remainingDays ~/ 30.44;
    final days = (remainingDays - (months * 30.44)).round();
    return '$years y, $months m, $days d';
  } else if (totalDays >= 30) {
    final months = totalDays ~/ 30.44;
    final days = (totalDays - (months * 30.44)).round();
    return '$months m, $days d';
  } else if (totalDays >= 1) {
    final days = totalDays.floor();
    final hours = ((totalDays - days) * 24).round();
    if (hours > 0) return '$days d, $hours h';
    return '$days days';
  } else {
    final totalHours = totalDays * 24;
    if (totalHours >= 1) {
      final hours = totalHours.floor();
      final minutes = ((totalHours - hours) * 60).round();
      if (minutes > 0) return '$hours h, $minutes m';
      return '$hours hours';
    } else {
      final minutes = (totalHours * 60).round();
      if (minutes > 0) return '$minutes min';
      return '< 1 min';
    }
  }
}

/// Get planet image path
String getPlanetImagePath(String planet) {
  return 'assets/images/planets/${planet.toLowerCase()}.png';
}

// ═══════════════════════════════════════════════════════════════════════════
// PREMIUM PLANET IMAGE WIDGET - With shadows matching details_tab.dart style
// ═══════════════════════════════════════════════════════════════════════════
class PremiumPlanetImage extends StatelessWidget {
  final String planet;
  final double size;
  final bool isActive;
  final bool showShadow;
  final double opacity;

  const PremiumPlanetImage({
    super.key,
    required this.planet,
    this.size = 48,
    this.isActive = false,
    this.showShadow = true,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final color = getPlanetColor(planet);
    
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.28),
          boxShadow: showShadow ? [
            // Deep ambient shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: -3,
              offset: const Offset(0, 5),
            ),
            // Color accent glow
            BoxShadow(
              color: color.withOpacity(isActive ? 0.25 : 0.15),
              blurRadius: isActive ? 14 : 10,
              spreadRadius: -2,
              offset: const Offset(0, 3),
            ),
          ] : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.28),
          child: Image.asset(
            getPlanetImagePath(planet),
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(size * 0.28),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    getPlanetSymbol(planet),
                    style: TextStyle(
                      fontSize: size * 0.45,
                      color: color,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PREMIUM CARD - Matching details_tab.dart card style
// ═══════════════════════════════════════════════════════════════════════════
class DashaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const DashaCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(DashaDesignTokens.space16),
      decoration: BoxDecoration(
        color: DashaColors.surface,
        borderRadius: BorderRadius.circular(DashaDesignTokens.radiusLg),
        border: Border.all(color: DashaColors.borderSubtle, width: 1),
        boxShadow: DashaDesignTokens.shadowSm,
      ),
      child: child,
    );
  }
}
