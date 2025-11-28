import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModernFeatureCard extends StatefulWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final Color primaryColor;
  final Color? secondaryColor;
  final VoidCallback onTap;
  final String? badge;
  final bool isNew;

  const ModernFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    this.secondaryColor,
    required this.onTap,
    this.badge,
    this.isNew = false,
  });

  @override
  State<ModernFeatureCard> createState() => _ModernFeatureCardState();
}

class _ModernFeatureCardState extends State<ModernFeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _elevationAnimation = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _controller.forward();
    // Subtle haptic feedback
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final secondaryColor =
        widget.secondaryColor ?? widget.primaryColor.withOpacity(0.1);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.primaryColor.withOpacity(0.1),
                  blurRadius: _elevationAnimation.value,
                  offset: Offset(0, _elevationAnimation.value / 2),
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
                borderRadius: BorderRadius.circular(20),
                splashColor: widget.primaryColor.withOpacity(0.1),
                highlightColor: widget.primaryColor.withOpacity(0.05),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isDarkMode
                              ? widget.primaryColor.withOpacity(0.2)
                              : widget.primaryColor.withOpacity(0.08),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Subtle gradient background
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                secondaryColor.withOpacity(0.03),
                                secondaryColor.withOpacity(0.08),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Icon Container with subtle animation
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color:
                                        _isPressed
                                            ? widget.primaryColor.withOpacity(
                                              0.15,
                                            )
                                            : secondaryColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: IconTheme(
                                      data: IconThemeData(
                                        color: widget.primaryColor,
                                        size: 26,
                                      ),
                                      child: widget.icon,
                                    ),
                                  ),
                                ),
                                // Badge or New indicator
                                if (widget.isNew || widget.badge != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          widget.isNew
                                              ? Colors.green.withOpacity(0.1)
                                              : widget.primaryColor.withOpacity(
                                                0.1,
                                              ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      widget.badge ?? 'NEW',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            widget.isNew
                                                ? Colors.green
                                                : widget.primaryColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Title
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDarkMode
                                        ? Colors.white
                                        : Colors.grey[900],
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Subtitle
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Arrow indicator
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: Matrix4.translationValues(
                            _isPressed ? 4 : 0,
                            0,
                            0,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: widget.primaryColor.withOpacity(0.5),
                          ),
                        ),
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


