import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/astro_alert.dart';

/// Premium design tokens for alert detail sheet
class _SheetTokens {
  _SheetTokens._();

  // Colors
  static const Color bgSurface = Color(0xFF16141F);
  static const Color bgElevated = Color(0xFF1C1A26);
  static const Color borderColor = Color(0xFF2A2438);
  static const Color textPrimary = Color(0xFFF5F4F8);
  static const Color textSecondary = Color(0xFFA09CAC);
  static const Color textMuted = Color(0xFF6E6A7A);
}

/// Premium bottom sheet for displaying alert details
class AlertDetailBottomSheet extends StatefulWidget {
  final AstroAlert alert;

  const AlertDetailBottomSheet({
    super.key,
    required this.alert,
  });

  /// Show the bottom sheet
  static Future<void> show(BuildContext context, AstroAlert alert) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => AlertDetailBottomSheet(alert: alert),
    );
  }

  @override
  State<AlertDetailBottomSheet> createState() => _AlertDetailBottomSheetState();
}

class _AlertDetailBottomSheetState extends State<AlertDetailBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

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
    final alert = widget.alert;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.85,
        ),
        decoration: BoxDecoration(
          color: _SheetTokens.bgSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(
              color: alert.accentColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: alert.accentColor.withOpacity(0.15),
              blurRadius: 40,
              spreadRadius: -10,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar with accent glow
            _buildHandleBar(),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon and title
                    _buildHeader(),
                    const SizedBox(height: 20),

                    // Time range card (if applicable)
                    if (alert.dateRangeString != null) ...[
                      _buildTimeRangeCard(),
                      const SizedBox(height: 20),
                    ],

                    // Theme summary highlight
                    _buildThemeSummary(),
                    const SizedBox(height: 24),

                    // Formation logic
                    _buildSection(
                      title: 'How It Forms',
                      icon: Icons.auto_awesome_outlined,
                      content: alert.formationLogic,
                    ),
                    const SizedBox(height: 20),

                    // Detailed explanation
                    _buildSection(
                      title: 'Understanding This Influence',
                      icon: Icons.lightbulb_outline_rounded,
                      content: alert.detailedExplanation.trim(),
                    ),
                    const SizedBox(height: 20),

                    // Effects
                    _buildEffectsSection(),

                    // Remedies (if available)
                    if (alert.remedies != null && alert.remedies!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildRemediesSection(),
                    ],

                    const SizedBox(height: 24),

                    // Close button
                    _buildCloseButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 16),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: widget.alert.accentColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    final alert = widget.alert;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon container
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                alert.accentColor.withOpacity(0.2),
                alert.accentColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: alert.accentColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: alert.planetName != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/planets/${alert.planetName!.toLowerCase()}.png',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        alert.iconSymbol,
                        style: TextStyle(
                          fontSize: 30,
                          color: alert.accentColor,
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    alert.iconSymbol,
                    style: TextStyle(
                      fontSize: 30,
                      color: alert.accentColor,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 16),

        // Title and subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: _getTypeBadgeColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getTypeBadgeText(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getTypeBadgeColor(),
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              // Title
              Text(
                alert.title,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _SheetTokens.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle
              Text(
                alert.subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: alert.accentColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getTypeBadgeColor() {
    switch (widget.alert.type) {
      case AlertType.warning:
        return const Color(0xFFF87171);
      case AlertType.neutral:
        return const Color(0xFFA09CAC);
      case AlertType.positive:
        return AstroAlertColors.positive;
    }
  }

  String _getTypeBadgeText() {
    switch (widget.alert.type) {
      case AlertType.warning:
        return 'IMPORTANT TRANSIT';
      case AlertType.neutral:
        return 'CHART FEATURE';
      case AlertType.positive:
        return 'AUSPICIOUS YOGA';
    }
  }

  Widget _buildTimeRangeCard() {
    final alert = widget.alert;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            alert.accentColor.withOpacity(0.1),
            alert.accentColor.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: alert.accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: alert.accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.date_range_rounded,
              color: alert.accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Period',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _SheetTokens.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.dateRangeString!,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _SheetTokens.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSummary() {
    final alert = widget.alert;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _SheetTokens.bgElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _SheetTokens.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: Text(
              '✦',
              style: TextStyle(
                fontSize: 16,
                color: alert.accentColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              alert.themeSummary,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _SheetTokens.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: widget.alert.accentColor,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _SheetTokens.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: _SheetTokens.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildEffectsSection() {
    final alert = widget.alert;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.insights_rounded,
              size: 18,
              color: alert.accentColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Key Effects & Themes',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _SheetTokens.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...alert.effects.asMap().entries.map((entry) {
          final index = entry.key;
          final effect = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: alert.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: alert.accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    effect,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _SheetTokens.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRemediesSection() {
    final alert = widget.alert;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AstroAlertColors.positive.withOpacity(0.08),
            AstroAlertColors.positive.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AstroAlertColors.positive.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.spa_outlined,
                size: 18,
                color: AstroAlertColors.positive,
              ),
              const SizedBox(width: 8),
              Text(
                'Suggested Remedies',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _SheetTokens.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...alert.remedies!.map((remedy) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: TextStyle(
                      fontSize: 14,
                      color: AstroAlertColors.positive,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      remedy,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _SheetTokens.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: _SheetTokens.bgElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _SheetTokens.borderColor,
              width: 1,
            ),
          ),
        ),
        child: Text(
          'Close',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _SheetTokens.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet to show all alerts when more than 3 exist
class AllAlertsBottomSheet extends StatelessWidget {
  final List<AstroAlert> alerts;
  final Function(AstroAlert) onAlertTap;

  const AllAlertsBottomSheet({
    super.key,
    required this.alerts,
    required this.onAlertTap,
  });

  /// Show the bottom sheet
  static Future<void> show(
    BuildContext context,
    List<AstroAlert> alerts,
    Function(AstroAlert) onAlertTap,
  ) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => AllAlertsBottomSheet(
        alerts: alerts,
        onAlertTap: onAlertTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.7,
      ),
      decoration: const BoxDecoration(
        color: _SheetTokens.bgSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _SheetTokens.textMuted.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'All Astrological Influences',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _SheetTokens.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AstroAlertColors.positive.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${alerts.length}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AstroAlertColors.positive,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Alert list
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 20),
              shrinkWrap: true,
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _buildAlertItem(context, alert);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(BuildContext context, AstroAlert alert) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
        onAlertTap(alert);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _SheetTokens.bgElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: alert.accentColor.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Accent indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: alert.accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),

            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: alert.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  alert.iconSymbol,
                  style: TextStyle(
                    fontSize: 20,
                    color: alert.accentColor,
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
                  Text(
                    alert.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _SheetTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: alert.accentColor.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: _SheetTokens.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

