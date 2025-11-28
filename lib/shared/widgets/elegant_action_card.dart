import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ElegantActionCard extends StatefulWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isPremium;

  const ElegantActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
    this.isPremium = false,
  });

  @override
  State<ElegantActionCard> createState() => _ElegantActionCardState();
}

class _ElegantActionCardState extends State<ElegantActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isHovered = true);
    _hoverController.forward();
    HapticFeedback.selectionClick();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _hoverAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 - (_hoverAnimation.value * 0.03),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.accentColor.withOpacity(
                    0.15 * (1 - _hoverAnimation.value),
                  ),
                  blurRadius: 20,
                  offset: Offset(0, 10 * (1 - _hoverAnimation.value)),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(24),
                splashColor: widget.accentColor.withOpacity(0.08),
                highlightColor: widget.accentColor.withOpacity(0.04),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                    border: Border.all(
                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Animated Icon Container
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.accentColor.withOpacity(
                                    _isHovered ? 0.2 : 0.1,
                                  ),
                                  widget.accentColor.withOpacity(
                                    _isHovered ? 0.15 : 0.05,
                                  ),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: IconTheme(
                                data: IconThemeData(
                                  color: widget.accentColor,
                                  size: 28,
                                ),
                                child: widget.icon,
                              ),
                            ),
                          ),
                          // Premium Badge
                          if (widget.isPremium)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amber[400]!,
                                    Colors.orange[400]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'PRO',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      // Bottom Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDarkMode ? Colors.white : Colors.grey[900],
                              letterSpacing: -0.3,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.subtitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        isDarkMode
                                            ? Colors.grey[500]
                                            : Colors.grey[600],
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                transform: Matrix4.translationValues(
                                  _isHovered ? 5 : 0,
                                  0,
                                  0,
                                ),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: widget.accentColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: widget.accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


