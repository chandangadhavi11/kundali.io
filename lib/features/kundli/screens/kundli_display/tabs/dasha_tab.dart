import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import 'dasha/vimshottari_dasha_view.dart';
import 'dasha/mahadasha_phala_view.dart';
import 'dasha/yogini_dasha_view.dart';
import 'dasha/char_dasha_view.dart';
import 'dasha/dasha_shared_widgets.dart';

// Design tokens and colors are imported from dasha_shared_widgets.dart
// (DashaDesignTokens and DashaColors)

// ═══════════════════════════════════════════════════════════════════════════
// INSIGHT DATA MODEL - For interactive explanations
// ═══════════════════════════════════════════════════════════════════════════
class DashaInsightData {
  final String title;
  final String value;
  final String description;
  final String significance;
  final List<String> keyPoints;
  final Color accentColor;
  final IconData icon;
  final String? imagePath;

  const DashaInsightData({
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
// INSIGHT GENERATORS
// ═══════════════════════════════════════════════════════════════════════════
DashaInsightData _getDashaTypeInsight(DashaType type) {
  switch (type) {
    case DashaType.vimshottari:
      return DashaInsightData(
        title: 'Dasha System',
        value: 'Vimshottari',
        description:
            'Vimshottari Dasha is the most widely used planetary period system in Vedic astrology. It\'s a 120-year cycle based on the Moon\'s Nakshatra (lunar mansion) at birth.',
        significance:
            'This system reveals the timing of life events by showing which planetary energies are active during specific periods of your life.',
        keyPoints: [
          'Based on Moon\'s birth Nakshatra',
          '120-year complete cycle',
          '9 planetary periods (Mahadasha)',
          'Each period has sub-periods (Antardasha)',
          'Most accurate for timing predictions',
        ],
        accentColor: DashaColors.vimshottari,
        icon: Icons.brightness_2_rounded,
      );
    case DashaType.mahadashaPhala:
      return DashaInsightData(
        title: 'Dasha System',
        value: 'Mahadasha Phala',
        description:
            'Mahadasha Phala focuses on the results and effects of major planetary periods. It provides detailed predictions for each Mahadasha based on planetary positions.',
        significance:
            'This analysis helps understand what specific results each Mahadasha will bring based on the planet\'s house placement and aspects.',
        keyPoints: [
          'Focuses on period results',
          'House-based predictions',
          'Considers planetary aspects',
          'Shows favorable/unfavorable periods',
          'Helps in life planning',
        ],
        accentColor: DashaColors.phala,
        icon: Icons.auto_awesome_rounded,
      );
    case DashaType.yogini:
      return DashaInsightData(
        title: 'Dasha System',
        value: 'Yogini',
        description:
            'Yogini Dasha is a unique 36-year cycle named after 8 Yoginis (divine feminine energies). It\'s particularly useful for timing events and is known for its accuracy.',
        significance:
            'This shorter cycle system is excellent for precise timing and is said to give results that are more immediately noticeable.',
        keyPoints: [
          '36-year complete cycle',
          '8 Yogini periods',
          'Named after divine feminine',
          'Excellent for timing events',
          'Complementary to Vimshottari',
        ],
        accentColor: DashaColors.yogini,
        icon: Icons.spa_rounded,
      );
    case DashaType.char:
      return DashaInsightData(
        title: 'Dasha System',
        value: 'Chara (Jaimini)',
        description:
            'Chara Dasha is from the Jaimini system of astrology. It uses zodiac signs rather than planets and is based on the Karakamsha (soul\'s desire).',
        significance:
            'This sign-based system provides a different perspective on life timing and is particularly useful for understanding soul-level desires and karmic patterns.',
        keyPoints: [
          'Jaimini astrology system',
          'Sign-based periods',
          'Based on Karakamsha',
          'Shows karmic patterns',
          'Complements planetary Dashas',
        ],
        accentColor: DashaColors.char,
        icon: Icons.donut_small_rounded,
      );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INSIGHT BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════
void _showInsightSheet(BuildContext context, DashaInsightData insight) {
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
  final DashaInsightData insight;

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
          color: DashaColors.surface,
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
                                  color: DashaColors.textPrimary,
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
                        color: DashaColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      insight.description,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: DashaColors.textPrimary,
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
                                    color: DashaColors.textPrimary,
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
                          color: DashaColors.textSecondary,
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
                                    color: DashaColors.textSecondary,
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
// DASHA TAB - Main Container with Premium Design
// ═══════════════════════════════════════════════════════════════════════════
class DashaTab extends StatefulWidget {
  final KundaliData kundaliData;

  const DashaTab({super.key, required this.kundaliData});

  @override
  State<DashaTab> createState() => _DashaTabState();
}

class _DashaTabState extends State<DashaTab> with TickerProviderStateMixin {
  DashaType _selectedType = DashaType.vimshottari;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _selectDashaType(DashaType type) {
    if (type == _selectedType) return;

    HapticFeedback.lightImpact();

    _fadeController.reverse();
    _slideController.reverse().then((_) {
      setState(() => _selectedType = type);
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Premium Dasha Type Selector
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _PremiumDashaSelector(
            selectedType: _selectedType,
            onSelect: _selectDashaType,
            onInfoTap:
                (type) =>
                    _showInsightSheet(context, _getDashaTypeInsight(type)),
          ),
        ),

        // Content with animation
        Expanded(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildCurrentView(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentView() {
    switch (_selectedType) {
      case DashaType.vimshottari:
        return VimshottariDashaView(kundaliData: widget.kundaliData);
      case DashaType.mahadashaPhala:
        return MahadashaPhalaView(kundaliData: widget.kundaliData);
      case DashaType.yogini:
        return YoginiDashaView(kundaliData: widget.kundaliData);
      case DashaType.char:
        return CharDashaView(kundaliData: widget.kundaliData);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PREMIUM DASHA TYPE SELECTOR
// ═══════════════════════════════════════════════════════════════════════════
class _PremiumDashaSelector extends StatefulWidget {
  final DashaType selectedType;
  final ValueChanged<DashaType> onSelect;
  final ValueChanged<DashaType> onInfoTap;

  const _PremiumDashaSelector({
    required this.selectedType,
    required this.onSelect,
    required this.onInfoTap,
  });

  @override
  State<_PremiumDashaSelector> createState() => _PremiumDashaSelectorState();
}

class _PremiumDashaSelectorState extends State<_PremiumDashaSelector> {
  late ScrollController _scrollController;
  final Map<DashaType, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    for (final type in DashaType.values) {
      _itemKeys[type] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_PremiumDashaSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedType != widget.selectedType) {
      _scrollToSelected();
    }
  }

  void _scrollToSelected() {
    final key = _itemKeys[widget.selectedType];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        alignment: 0.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      decoration: BoxDecoration(
        color: DashaColors.surface,
        borderRadius: BorderRadius.circular(DashaDesignTokens.radiusLg),
        border: Border.all(color: DashaColors.borderSubtle, width: 1),
        boxShadow: DashaDesignTokens.shadowSm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DashaDesignTokens.radiusLg),
        child: ShaderMask(
          shaderCallback:
              (bounds) => LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: const [0, 0.04, 0.96, 1],
              ).createShader(bounds),
          blendMode: BlendMode.dstIn,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children:
                  DashaType.values.map((type) {
                    final isSelected = type == widget.selectedType;
                    return Padding(
                      key: _itemKeys[type],
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _DashaTypeTab(
                        type: type,
                        isSelected: isSelected,
                        onTap: () => widget.onSelect(type),
                        onLongPress: () => widget.onInfoTap(type),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DASHA TYPE TAB
// ═══════════════════════════════════════════════════════════════════════════
class _DashaTypeTab extends StatefulWidget {
  final DashaType type;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _DashaTypeTab({
    required this.type,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_DashaTypeTab> createState() => _DashaTypeTabState();
}

class _DashaTypeTabState extends State<_DashaTypeTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
      value: widget.isSelected ? 1.0 : 0.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_DashaTypeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  Color get _typeColor {
    switch (widget.type) {
      case DashaType.vimshottari:
        return DashaColors.vimshottari;
      case DashaType.mahadashaPhala:
        return DashaColors.phala;
      case DashaType.yogini:
        return DashaColors.yogini;
      case DashaType.char:
        return DashaColors.char;
    }
  }

  IconData get _typeIcon {
    switch (widget.type) {
      case DashaType.vimshottari:
        return Icons.brightness_2_rounded;
      case DashaType.mahadashaPhala:
        return Icons.auto_awesome_rounded;
      case DashaType.yogini:
        return Icons.spa_rounded;
      case DashaType.char:
        return Icons.donut_small_rounded;
    }
  }

  String get _shortLabel {
    switch (widget.type) {
      case DashaType.vimshottari:
        return 'Vimshottari';
      case DashaType.mahadashaPhala:
        return 'Phala';
      case DashaType.yogini:
        return 'Yogini';
      case DashaType.char:
        return 'Char';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      onLongPress: () {
        HapticFeedback.mediumImpact();
        widget.onLongPress();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final activeValue = _controller.value;

          return AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutCubic,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12 + (activeValue * 4),
                vertical: 8,
              ),
              decoration: BoxDecoration(
                gradient:
                    activeValue > 0.1
                        ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _typeColor.withOpacity(0.2 * activeValue),
                            _typeColor.withOpacity(0.08 * activeValue),
                          ],
                        )
                        : null,
                color: activeValue <= 0.1 ? Colors.transparent : null,
                borderRadius: BorderRadius.circular(DashaDesignTokens.radiusMd),
                border:
                    activeValue > 0.1
                        ? Border.all(
                          color: _typeColor.withOpacity(0.3 * activeValue),
                          width: 1,
                        )
                        : null,
                boxShadow:
                    activeValue > 0.3
                        ? [
                          BoxShadow(
                            color: _typeColor.withOpacity(0.2 * activeValue),
                            blurRadius: 12 * activeValue,
                            spreadRadius: -2,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with subtle animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color:
                          widget.isSelected
                              ? _typeColor.withOpacity(0.15)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _typeIcon,
                      size: 14,
                      color: Color.lerp(
                        DashaColors.textTertiary,
                        _typeColor,
                        activeValue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Label
                  Text(
                    _shortLabel,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight:
                          widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: Color.lerp(
                        DashaColors.textSecondary,
                        _typeColor,
                        activeValue,
                      ),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
