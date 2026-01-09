import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/models/kundali_data_model.dart';
import '../../../models/astro_alert.dart';
import '../../../services/astro_alert_service.dart';
import 'astro_alert_card.dart';
import 'alert_detail_bottom_sheet.dart';

/// Design tokens for the alerts section
class _SectionTokens {
  _SectionTokens._();

  // Colors
  static const Color bgSurface = Color(0xFF16141F);
  static const Color borderColor = Color(0xFF2A2438);
  static const Color textPrimary = Color(0xFFF5F4F8);
  static const Color textSecondary = Color(0xFFA09CAC);
  static const Color textMuted = Color(0xFF6E6A7A);
  static const Color accentGold = Color(0xFFD4AF37);
}

/// Premium collapsible section for astrological alerts/influences
class AstroAlertsSection extends StatefulWidget {
  final KundaliData kundaliData;
  final bool initiallyExpanded;

  const AstroAlertsSection({
    super.key,
    required this.kundaliData,
    this.initiallyExpanded = true,
  });

  @override
  State<AstroAlertsSection> createState() => _AstroAlertsSectionState();
}

class _AstroAlertsSectionState extends State<AstroAlertsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;

  bool _isExpanded = true;
  List<AstroAlert> _alerts = [];
  bool _alertsGenerated = false;

  static const int _maxVisibleAlerts = 3;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _initAnimations();
    _generateAlerts();
  }

  void _initAnimations() {
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5, // 180 degrees
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _expandController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );
  }

  void _generateAlerts() {
    // Generate alerts from Kundali data
    _alerts = AstroAlertService.generateAlerts(widget.kundaliData);
    _alertsGenerated = true;
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(AstroAlertsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Regenerate alerts if Kundali data changes
    if (oldWidget.kundaliData.id != widget.kundaliData.id) {
      _generateAlerts();
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  void _showAlertDetails(AstroAlert alert) {
    AlertDetailBottomSheet.show(context, alert);
  }

  void _showAllAlerts() {
    AllAlertsBottomSheet.show(
      context,
      _alerts,
      (alert) => _showAlertDetails(alert),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Don't render if no alerts or still loading
    if (!_alertsGenerated || _alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _SectionTokens.bgSurface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _SectionTokens.borderColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (always visible)
            _buildHeader(),

            // Expandable content
            SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1.0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final alertCount = _alerts.length;

    return GestureDetector(
      onTap: _toggleExpanded,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _SectionTokens.accentGold.withOpacity(0.2),
                    _SectionTokens.accentGold.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _SectionTokens.accentGold.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: _SectionTokens.accentGold,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Important Astrological Influences',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _SectionTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$alertCount active ${alertCount == 1 ? 'influence' : 'influences'}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _SectionTokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Expand/Collapse indicator
            RotationTransition(
              turns: _rotateAnimation,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _SectionTokens.borderColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: _SectionTokens.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final visibleAlerts = _alerts.take(_maxVisibleAlerts).toList();
    final hasMore = _alerts.length > _maxVisibleAlerts;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _SectionTokens.borderColor,
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Alert cards
          ...visibleAlerts.asMap().entries.map((entry) {
            final index = entry.key;
            final alert = entry.value;
            return AstroAlertCard(
              alert: alert,
              index: index,
              onViewDetails: () => _showAlertDetails(alert),
              animate: true,
            );
          }),

          // "View all" button if more alerts exist
          if (hasMore) _buildViewAllButton(),
        ],
      ),
    );
  }

  Widget _buildViewAllButton() {
    final remaining = _alerts.length - _maxVisibleAlerts;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showAllAlerts();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: _SectionTokens.accentGold.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _SectionTokens.accentGold.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'View all influences',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _SectionTokens.accentGold,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _SectionTokens.accentGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '+$remaining more',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _SectionTokens.accentGold,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_rounded,
              size: 14,
              color: _SectionTokens.accentGold,
            ),
          ],
        ),
      ),
    );
  }
}

