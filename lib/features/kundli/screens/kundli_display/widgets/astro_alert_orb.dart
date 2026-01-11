import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/astro_alert.dart';
import '../../../services/astro_alert_service.dart';
import '../../../../../shared/models/kundali_data_model.dart';
import 'package:intl/intl.dart';
import 'package:kundali_app/l10n/generated/app_localizations.dart';

/// Controller to manage the expanded/collapsed state of alerts
class AstroAlertController extends ChangeNotifier {
  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  void expand() {
    _isExpanded = true;
    notifyListeners();
  }

  void collapse() {
    _isExpanded = false;
    notifyListeners();
  }

  void toggle() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }
}

// =============================================================================
// DESIGN TOKENS
// =============================================================================
class _Tokens {
  // Colors
  static const bgPrimary = Color(0xFF0D0B14);
  static const surface = Color(0xFF1A1625);
  static const border = Color(0xFF2A2438);
  static const borderSubtle = Color(0xFF231F2E);
  
  static const textPrimary = Color(0xFFF5F3FF);
  static const textSecondary = Color(0xFFB8B3C8);
  static const textMuted = Color(0xFF6B6478);
  
  static const accentGold = Color(0xFFD4AF37);
  static const accentGreen = Color(0xFF6EE7B7);
  
  // Spacing
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  
  // Animation
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

// =============================================================================
// ALERT ORB - Small button matching fullscreen button size
// =============================================================================
class AstroAlertOrb extends StatefulWidget {
  final KundaliData kundaliData;
  final AstroAlertController controller;
  /// Optional transit date for calculating transit-based alerts (Sade Sati, Dhaiya)
  /// If null, uses current date
  final DateTime? transitDate;

  const AstroAlertOrb({
    super.key,
    required this.kundaliData,
    required this.controller,
    this.transitDate,
  });

  @override
  State<AstroAlertOrb> createState() => _AstroAlertOrbState();
}

class _AstroAlertOrbState extends State<AstroAlertOrb>
    with SingleTickerProviderStateMixin {
  late List<AstroAlert> _alerts;
  bool _isPressed = false;
  AppLocalizations? _cachedL10n;

  @override
  void initState() {
    super.initState();
    _alerts = []; // Initialize empty, will be populated in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);
    // Regenerate alerts when locale changes
    if (_cachedL10n != l10n) {
      _cachedL10n = l10n;
      _updateAlerts(l10n);
    }
  }

  @override
  void didUpdateWidget(covariant AstroAlertOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Regenerate alerts if transit date changes
    if (oldWidget.transitDate != widget.transitDate ||
        oldWidget.kundaliData != widget.kundaliData) {
      _updateAlerts(_cachedL10n);
    }
  }

  void _updateAlerts(AppLocalizations? l10n) {
    _alerts = AstroAlertService.generateAlerts(
      widget.kundaliData,
      transitDate: widget.transitDate,
      l10n: l10n,
    );
  }

  void _onTap() {
    HapticFeedback.selectionClick();
    widget.controller.toggle();
  }

  void _onLongPress() {
    HapticFeedback.mediumImpact();
    widget.controller.collapse();
    _showFullAlertsSheet();
  }

  void _showFullAlertsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AlertsBottomSheet(alerts: _alerts),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    final primaryColor = _alerts.first.accentColor;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        final isExpanded = widget.controller.isExpanded;

        return GestureDetector(
          onTap: _onTap,
          onLongPress: _onLongPress,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.92 : 1.0,
            duration: _Tokens.fast,
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: _Tokens.normal,
              curve: Curves.easeOutCubic,
              // Match fullscreen button size (36x36 based on padding: 8 + icon: 16 + padding: 8 = ~36)
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isExpanded 
                    ? primaryColor.withOpacity(0.15)
                    : _Tokens.surface.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isExpanded 
                      ? primaryColor.withOpacity(0.4)
                      : _Tokens.border.withOpacity(0.4),
                  width: 0.5,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Icon
                  AnimatedSwitcher(
                    duration: _Tokens.fast,
                    child: isExpanded
                        ? Icon(
                            Icons.keyboard_arrow_up_rounded,
                            key: const ValueKey('up'),
                            size: 18,
                            color: primaryColor,
                          )
                        : Icon(
                            Icons.auto_awesome_rounded,
                            key: const ValueKey('star'),
                            size: 14,
                            color: _Tokens.textSecondary,
                          ),
                  ),
                  // Count badge
                  if (_alerts.length > 1 && !isExpanded)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${_alerts.length}',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: _Tokens.bgPrimary,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// EXPANDABLE SECTION - Clean, minimal alert cards
// =============================================================================
class AstroAlertExpandedSection extends StatefulWidget {
  final KundaliData kundaliData;
  final AstroAlertController controller;
  final Duration autoCollapseDuration;
  /// Optional transit date for calculating transit-based alerts (Sade Sati, Dhaiya)
  /// If null, uses current date
  final DateTime? transitDate;

  const AstroAlertExpandedSection({
    super.key,
    required this.kundaliData,
    required this.controller,
    this.autoCollapseDuration = const Duration(seconds: 6),
    this.transitDate,
  });

  @override
  State<AstroAlertExpandedSection> createState() => _AstroAlertExpandedSectionState();
}

class _AstroAlertExpandedSectionState extends State<AstroAlertExpandedSection>
    with SingleTickerProviderStateMixin {
  late List<AstroAlert> _alerts;
  late AnimationController _animController;
  late Animation<double> _expandAnimation;
  Timer? _autoCollapseTimer;
  bool _hasAutoExpandedOnce = false;
  AppLocalizations? _cachedL10n;

  @override
  void initState() {
    super.initState();
    _alerts = []; // Initialize empty, will be populated in didChangeDependencies

    _animController = AnimationController(
      vsync: this,
      duration: _Tokens.slow,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);
    final needsUpdate = _cachedL10n != l10n || _alerts.isEmpty;
    _cachedL10n = l10n;
    
    if (needsUpdate) {
      _updateAlerts(l10n);
      // Auto-expand on first load
      if (_alerts.isNotEmpty && !_hasAutoExpandedOnce) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.controller.expand();
            _hasAutoExpandedOnce = true;
            _startAutoCollapseTimer();
          }
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant AstroAlertExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Regenerate alerts if transit date changes
    if (oldWidget.transitDate != widget.transitDate ||
        oldWidget.kundaliData != widget.kundaliData) {
      setState(() {
        _updateAlerts(_cachedL10n);
      });
    }
  }

  void _updateAlerts(AppLocalizations? l10n) {
    _alerts = AstroAlertService.generateAlerts(
      widget.kundaliData,
      transitDate: widget.transitDate,
      l10n: l10n,
    );
  }

  void _onControllerChanged() {
    if (widget.controller.isExpanded) {
      _animController.forward();
      _startAutoCollapseTimer();
    } else {
      _animController.reverse();
      _autoCollapseTimer?.cancel();
    }
  }

  void _startAutoCollapseTimer() {
    _autoCollapseTimer?.cancel();
    _autoCollapseTimer = Timer(widget.autoCollapseDuration, () {
      if (mounted && widget.controller.isExpanded) {
        widget.controller.collapse();
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _animController.dispose();
    _autoCollapseTimer?.cancel();
    super.dispose();
  }

  void _showAlertDetail(AstroAlert alert) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AlertDetailSheet(alert: alert),
    );
  }

  void _showAllAlerts() {
    HapticFeedback.selectionClick();
    widget.controller.collapse();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AlertsBottomSheet(alerts: _alerts),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_alerts.isEmpty) return const SizedBox.shrink();

    final displayAlerts = _alerts.take(2).toList();

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: _expandAnimation.value,
            child: Opacity(
              opacity: _expandAnimation.value.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
      child: Column(
        children: [
          const SizedBox(height: _Tokens.sm),
          // Alert cards
          ...displayAlerts.asMap().entries.map((entry) {
            return _AlertCard(
              alert: entry.value,
              onTap: () => _showAlertDetail(entry.value),
              delay: entry.key * 60,
            );
          }),
          // View all button
          if (_alerts.length > 2)
            Padding(
              padding: const EdgeInsets.only(top: _Tokens.xs),
              child: _ViewAllButton(
                count: _alerts.length,
                onTap: _showAllAlerts,
              ),
            ),
          const SizedBox(height: _Tokens.sm),
        ],
      ),
    );
  }
}

// =============================================================================
// ALERT CARD - Minimal, clean design
// =============================================================================
class _AlertCard extends StatefulWidget {
  final AstroAlert alert;
  final VoidCallback onTap;
  final int delay;

  const _AlertCard({
    required this.alert,
    required this.onTap,
    this.delay = 0,
  });

  @override
  State<_AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<_AlertCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + widget.delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 8 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: _Tokens.fast,
          child: Container(
            margin: const EdgeInsets.only(bottom: _Tokens.sm),
            padding: const EdgeInsets.all(_Tokens.md),
            decoration: BoxDecoration(
              color: _Tokens.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _Tokens.borderSubtle,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Left accent + icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.alert.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      widget.alert.iconSymbol,
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.alert.accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: _Tokens.md),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.alert.title,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _Tokens.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.alert.subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _Tokens.textMuted,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: _Tokens.textMuted.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// VIEW ALL BUTTON
// =============================================================================
class _ViewAllButton extends StatefulWidget {
  final int count;
  final VoidCallback onTap;

  const _ViewAllButton({required this.count, required this.onTap});

  @override
  State<_ViewAllButton> createState() => _ViewAllButtonState();
}

class _ViewAllButtonState extends State<_ViewAllButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: _Tokens.fast,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: _Tokens.md,
            vertical: _Tokens.sm,
          ),
          decoration: BoxDecoration(
            color: _Tokens.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).alert_viewAll(widget.count),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _Tokens.textMuted,
                ),
              ),
              const SizedBox(width: _Tokens.xs),
              Icon(
                Icons.arrow_forward_rounded,
                size: 12,
                color: _Tokens.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// BOTTOM SHEET - Full alerts list
// =============================================================================
class _AlertsBottomSheet extends StatelessWidget {
  final List<AstroAlert> alerts;

  const _AlertsBottomSheet({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _Tokens.bgPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: _Tokens.md),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _Tokens.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(_Tokens.xl),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Astrological Influences',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _Tokens.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${alerts.length} active',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: _Tokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _Tokens.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: _Tokens.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    _Tokens.xl, 0, _Tokens.xl, _Tokens.xl,
                  ),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    return _BottomSheetAlertCard(
                      alert: alerts[index],
                      index: index,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BottomSheetAlertCard extends StatefulWidget {
  final AstroAlert alert;
  final int index;

  const _BottomSheetAlertCard({required this.alert, required this.index});

  @override
  State<_BottomSheetAlertCard> createState() => _BottomSheetAlertCardState();
}

class _BottomSheetAlertCardState extends State<_BottomSheetAlertCard> {
  bool _isPressed = false;

  void _showDetail() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AlertDetailSheet(alert: widget.alert),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 250 + (widget.index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: _showDetail,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: _Tokens.fast,
          child: Container(
            margin: const EdgeInsets.only(bottom: _Tokens.md),
            padding: const EdgeInsets.all(_Tokens.lg),
            decoration: BoxDecoration(
              color: _Tokens.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _Tokens.borderSubtle, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: widget.alert.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      widget.alert.iconSymbol,
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.alert.accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: _Tokens.md),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.alert.title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _Tokens.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.alert.subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _Tokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: _Tokens.sm),
                      Text(
                        widget.alert.themeSummary,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _Tokens.textMuted,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: _Tokens.sm),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: _Tokens.textMuted.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// DETAIL SHEET - Full alert information
// =============================================================================
class _AlertDetailSheet extends StatelessWidget {
  final AstroAlert alert;

  const _AlertDetailSheet({required this.alert});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _Tokens.bgPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: _Tokens.md),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _Tokens.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(_Tokens.xl),
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: alert.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              alert.iconSymbol,
                              style: TextStyle(
                                fontSize: 22,
                                color: alert.accentColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: _Tokens.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alert.title,
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: _Tokens.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                alert.subtitle,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: alert.accentColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _Tokens.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: _Tokens.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: _Tokens.xl),
                    // Date range
                    if (alert.startDate != null && alert.endDate != null)
                      _buildDateRange(),
                    // Overview
                    _buildSection(
                      title: 'Overview',
                      content: alert.themeSummary,
                    ),
                    // Understanding
                    _buildSection(
                      title: 'Understanding',
                      content: alert.detailedExplanation,
                    ),
                    // Effects
                    _buildListSection(
                      title: 'Key Influences',
                      items: alert.effects,
                      color: _Tokens.accentGreen,
                    ),
                    // Remedies
                    if (alert.remedies != null && alert.remedies!.isNotEmpty)
                      _buildListSection(
                        title: 'Supportive Practices',
                        items: alert.remedies!,
                        color: _Tokens.accentGold,
                      ),
                    const SizedBox(height: _Tokens.xl),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateRange() {
    final format = DateFormat('MMM d, yyyy');
    return Container(
      margin: const EdgeInsets.only(bottom: _Tokens.lg),
      padding: const EdgeInsets.all(_Tokens.lg),
      decoration: BoxDecoration(
        color: _Tokens.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 16,
            color: alert.accentColor,
          ),
          const SizedBox(width: _Tokens.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Period',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: _Tokens.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${format.format(alert.startDate!)} → ${format.format(alert.endDate!)}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _Tokens.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _Tokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _Tokens.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: _Tokens.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(_Tokens.lg),
            decoration: BoxDecoration(
              color: _Tokens.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              content,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _Tokens.textSecondary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _Tokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: _Tokens.sm),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: _Tokens.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: _Tokens.md),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _Tokens.textSecondary,
                      height: 1.4,
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
