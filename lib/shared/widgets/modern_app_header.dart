import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class ModernAppHeader extends StatefulWidget {
  final String appName;
  final VoidCallback? onNotificationTap;
  final int notificationCount;

  const ModernAppHeader({
    super.key,
    required this.appName,
    this.onNotificationTap,
    this.notificationCount = 0,
  });

  @override
  State<ModernAppHeader> createState() => _ModernAppHeaderState();
}

class _ModernAppHeaderState extends State<ModernAppHeader>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _sparkleController;
  late Animation<double> _logoRotation;
  late Animation<double> _logoPulse;
  late List<Animation<double>> _sparkleAnimations;

  @override
  void initState() {
    super.initState();

    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _logoRotation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _logoPulse = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Sparkle animations
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _sparkleAnimations = List.generate(
      3,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _sparkleController,
          curve: Interval(
            index * 0.2,
            math.min(0.4 + index * 0.2, 1.0),
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Stop all animations before disposing
    _logoController.stop();
    _sparkleController.stop();

    _logoController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Animated Logo
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _logoRotation.value,
                  child: Transform.scale(
                    scale: _logoPulse.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Sparkles
                        ...List.generate(3, (index) {
                          return AnimatedBuilder(
                            animation: _sparkleAnimations[index],
                            builder: (context, child) {
                              final angle = (index * 120) * math.pi / 180;
                              final distance =
                                  25.0 * _sparkleAnimations[index].value;
                              return Transform.translate(
                                offset: Offset(
                                  math.cos(angle) * distance,
                                  math.sin(angle) * distance,
                                ),
                                child: Opacity(
                                  opacity: 1 - _sparkleAnimations[index].value,
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDAB3D),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFFDAB3D,
                                          ).withOpacity(0.5),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),

                        // Logo container
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B6B).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 14),

          // App Name with animation
          Expanded(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(20 * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: Text(
                      widget.appName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.grey[900],
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Notification Button
          if (widget.onNotificationTap != null)
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: _NotificationButton(
                    onTap: widget.onNotificationTap!,
                    count: widget.notificationCount,
                    isDarkMode: isDarkMode,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatefulWidget {
  final VoidCallback onTap;
  final int count;
  final bool isDarkMode;

  const _NotificationButton({
    required this.onTap,
    required this.count,
    required this.isDarkMode,
  });

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _bellController;
  late Animation<double> _bellAnimation;

  @override
  void initState() {
    super.initState();
    _bellController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bellAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _bellController, curve: Curves.elasticIn),
    );

    // Animate bell when there are new notifications
    if (widget.count > 0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _bellController.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void didUpdateWidget(_NotificationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count > oldWidget.count && widget.count > 0) {
      _bellController.repeat(reverse: true);
    } else if (widget.count == 0) {
      _bellController.stop();
    }
  }

  @override
  void dispose() {
    // Stop animation before disposing
    _bellController.stop();
    _bellController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color:
              widget.isDarkMode
                  ? Colors.grey[800]?.withOpacity(0.5)
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                widget.isDarkMode
                    ? Colors.grey[700]!.withOpacity(0.3)
                    : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _bellAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle:
                      _bellAnimation.value *
                      math.sin(_bellController.value * math.pi * 4),
                  child: Icon(
                    Icons.notifications_rounded,
                    color:
                        widget.isDarkMode ? Colors.grey[400] : Colors.grey[700],
                    size: 22,
                  ),
                );
              },
            ),

            // Notification badge
            if (widget.count > 0)
              Positioned(
                top: 8,
                right: 8,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                widget.isDarkMode
                                    ? Colors.grey[900]!
                                    : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.count > 9 ? '9+' : widget.count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
