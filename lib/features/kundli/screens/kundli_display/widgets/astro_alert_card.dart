import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/astro_alert.dart';

/// Premium design tokens for alert cards
class _AlertCardTokens {
  _AlertCardTokens._();

  // Colors
  static const Color bgSurface = Color(0xFF1A1625);
  static const Color textPrimary = Color(0xFFF5F4F8);
  static const Color textSecondary = Color(0xFFA09CAC);
  static const Color textMuted = Color(0xFF6E6A7A);

  // Dimensions
  static const double borderRadius = 16.0;
  static const double accentBarWidth = 4.0;
  static const double iconSize = 40.0;
  static const double padding = 16.0;

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
}

/// Premium alert card widget with glassmorphism and animations
class AstroAlertCard extends StatefulWidget {
  final AstroAlert alert;
  final VoidCallback onViewDetails;
  final int index;
  final bool animate;

  const AstroAlertCard({
    super.key,
    required this.alert,
    required this.onViewDetails,
    this.index = 0,
    this.animate = true,
  });

  @override
  State<AstroAlertCard> createState() => _AstroAlertCardState();
}

class _AstroAlertCardState extends State<AstroAlertCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 80)),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animate) {
      // Delay based on index for staggered effect
      Future.delayed(Duration(milliseconds: widget.index * 80), () {
        if (mounted) {
          _animationController.forward();
        }
      });
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onViewDetails();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: _buildCard(),
        ),
      ),
    );
  }

  Widget _buildCard() {
    final alert = widget.alert;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _AlertCardTokens.bgSurface,
        borderRadius: BorderRadius.circular(_AlertCardTokens.borderRadius),
        border: Border.all(
          color: alert.accentColor.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: _AlertCardTokens.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_AlertCardTokens.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
          child: Stack(
            children: [
              // Accent bar on the left
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: _AlertCardTokens.accentBarWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        alert.accentColor,
                        alert.accentColor.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(_AlertCardTokens.borderRadius),
                      bottomLeft: Radius.circular(_AlertCardTokens.borderRadius),
                    ),
                  ),
                ),
              ),

              // Subtle glow effect
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        alert.accentColor.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.only(
                  left: _AlertCardTokens.accentBarWidth + _AlertCardTokens.padding,
                  right: _AlertCardTokens.padding,
                  top: _AlertCardTokens.padding,
                  bottom: _AlertCardTokens.padding,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    _buildIcon(),
                    const SizedBox(width: 14),

                    // Content
                    Expanded(child: _buildContent()),

                    // Arrow indicator
                    _buildArrowIndicator(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final alert = widget.alert;

    return Container(
      width: _AlertCardTokens.iconSize,
      height: _AlertCardTokens.iconSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            alert.accentColor.withOpacity(0.2),
            alert.accentColor.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert.accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: alert.planetName != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.asset(
                'assets/images/planets/${alert.planetName!.toLowerCase()}.png',
                width: _AlertCardTokens.iconSize,
                height: _AlertCardTokens.iconSize,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildSymbolIcon(),
              ),
            )
          : _buildSymbolIcon(),
    );
  }

  Widget _buildSymbolIcon() {
    final alert = widget.alert;
    
    return Center(
      child: Text(
        alert.iconSymbol,
        style: TextStyle(
          fontSize: 22,
          color: alert.accentColor,
        ),
      ),
    );
  }

  Widget _buildContent() {
    final alert = widget.alert;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title row with type badge
        Row(
          children: [
            Expanded(
              child: Text(
                alert.title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _AlertCardTokens.textPrimary,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (alert.type == AlertType.positive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AstroAlertColors.positive.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '✦ Yoga',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AstroAlertColors.positive,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 4),

        // Subtitle
        Text(
          alert.subtitle,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: alert.accentColor.withOpacity(0.9),
          ),
        ),

        const SizedBox(height: 6),

        // Time range (if available)
        if (alert.dateRangeString != null) ...[
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 12,
                color: _AlertCardTokens.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                alert.dateRangeString!,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: _AlertCardTokens.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],

        // Theme summary
        Text(
          alert.themeSummary,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: _AlertCardTokens.textSecondary,
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 10),

        // CTA Button
        _buildViewDetailsButton(),
      ],
    );
  }

  Widget _buildViewDetailsButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.alert.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.alert.accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'View details',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: widget.alert.accentColor,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_forward_rounded,
            size: 12,
            color: widget.alert.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildArrowIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: _AlertCardTokens.textMuted,
      ),
    );
  }
}

/// Compact version of the alert card for "View all" bottom sheet
class AstroAlertCardCompact extends StatelessWidget {
  final AstroAlert alert;
  final VoidCallback onTap;

  const AstroAlertCardCompact({
    super.key,
    required this.alert,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _AlertCardTokens.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: alert.accentColor.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Accent dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: alert.accentColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),

            // Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: alert.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  alert.iconSymbol,
                  style: TextStyle(
                    fontSize: 16,
                    color: alert.accentColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _AlertCardTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _AlertCardTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: _AlertCardTokens.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

