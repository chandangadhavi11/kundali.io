import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════════════
// NAVIGATION SECTION DATA MODEL
// ═══════════════════════════════════════════════════════════════════════════
/// Data class representing a navigation section in the floating nav bar
class NavSection {
  final String id;
  final String label;
  final Color color;

  const NavSection({
    required this.id,
    required this.label,
    required this.color,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// FLOATING NAVIGATION BAR - Premium Glass Design
// ═══════════════════════════════════════════════════════════════════════════
/// A premium floating navigation bar with glass morphism design
/// Supports horizontal scrolling with fade edges, active state animations,
/// and haptic feedback
class FloatingNavBar extends StatefulWidget {
  final List<NavSection> sections;
  final int activeIndex;
  final ValueChanged<int> onTap;
  
  /// Optional accent color for the outer glow shadow
  /// Defaults to violet (0xFF9580FF)
  final Color? glowColor;

  const FloatingNavBar({
    super.key,
    required this.sections,
    required this.activeIndex,
    required this.onTap,
    this.glowColor,
  });

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar> {
  late final ScrollController _scrollController;
  final List<GlobalKey> _itemKeys = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeKeys();
  }

  void _initializeKeys() {
    _itemKeys.clear();
    for (int i = 0; i < widget.sections.length; i++) {
      _itemKeys.add(GlobalKey());
    }
  }

  @override
  void didUpdateWidget(FloatingNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Re-initialize keys if sections changed
    if (oldWidget.sections.length != widget.sections.length) {
      _initializeKeys();
    }
    
    if (oldWidget.activeIndex != widget.activeIndex) {
      _scrollToActiveItem();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveItem() {
    if (widget.activeIndex >= 0 && widget.activeIndex < _itemKeys.length) {
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
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.glowColor ?? const Color(0xFF9580FF);
    
    return Container(
      height: 56,
      decoration: BoxDecoration(
        // Glass effect background
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1C1925).withOpacity(0.95),
            const Color(0xFF14121A).withOpacity(0.98),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        // Subtle gradient border
        border: Border.all(color: const Color(0xFF2E2A3A), width: 1),
        // Layered shadows for depth
        boxShadow: [
          // Outer glow
          BoxShadow(
            color: glowColor.withOpacity(0.08),
            blurRadius: 32,
            spreadRadius: -4,
            offset: const Offset(0, 4),
          ),
          // Main shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          // Soft ambient
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 64,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Inner highlight at top
            Positioned(
              top: 0,
              left: 20,
              right: 20,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            // Scrollable content with fade edges
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.06, 0.94, 1.0],
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: List.generate(widget.sections.length, (index) {
                    return _NavPill(
                      key: _itemKeys[index],
                      section: widget.sections[index],
                      isActive: index == widget.activeIndex,
                      onTap: () => widget.onTap(index),
                    );
                  }),
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
// NAV PILL - Individual Navigation Button
// ═══════════════════════════════════════════════════════════════════════════
class _NavPill extends StatefulWidget {
  final NavSection section;
  final bool isActive;
  final VoidCallback onTap;

  const _NavPill({
    super.key,
    required this.section,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavPill> createState() => _NavPillState();
}

class _NavPillState extends State<_NavPill> with TickerProviderStateMixin {
  late AnimationController _activeController;
  late AnimationController _pressController;
  late Animation<double> _activeAnimation;

  @override
  void initState() {
    super.initState();
    _activeController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
      value: widget.isActive ? 1.0 : 0.0,
    );
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _activeAnimation = CurvedAnimation(
      parent: _activeController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(_NavPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _activeController.forward();
      } else {
        _activeController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _activeController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _pressController.reverse();
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.section.color;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([_activeAnimation, _pressController]),
        builder: (context, _) {
          final activeValue = _activeAnimation.value;
          final pressScale = 1.0 - (_pressController.value * 0.06);

          // Interpolate colors smoothly
          final bgColor = Color.lerp(Colors.transparent, color, activeValue)!;
          final textColor = Color.lerp(
            const Color(0xFF8A8494),
            const Color(0xFF0D0B12),
            activeValue,
          )!;
          final dotColor = Color.lerp(
            Colors.transparent,
            const Color(0xFF0D0B12),
            activeValue,
          )!;

          // Interpolate sizes
          final horizontalPadding = 14.0 + (4.0 * activeValue);
          final dotWidth = 6.0 * activeValue;
          final dotMargin = 8.0 * activeValue;

          // Interpolate shadow
          final shadowOpacity = 0.4 * activeValue;
          final shadowBlur = 16.0 * activeValue;

          return Transform.scale(
            scale: pressScale,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: activeValue > 0.01
                    ? [
                        BoxShadow(
                          color: color.withOpacity(shadowOpacity),
                          blurRadius: shadowBlur,
                          spreadRadius: -2,
                          offset: Offset(0, 4 * activeValue),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Active indicator dot
                  if (activeValue > 0.01)
                    Container(
                      width: dotWidth,
                      height: 6,
                      margin: EdgeInsets.only(right: dotMargin),
                      decoration: BoxDecoration(
                        color: dotColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  // Label
                  Text(
                    widget.section.label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight:
                          activeValue > 0.5 ? FontWeight.w600 : FontWeight.w500,
                      color: textColor,
                      letterSpacing: 0.2 * activeValue,
                      height: 1.2,
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


