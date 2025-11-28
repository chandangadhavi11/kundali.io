import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class ModernGreetingSection extends StatefulWidget {
  final String userName;
  final String? userSign;
  final bool isGuest;

  const ModernGreetingSection({
    super.key,
    required this.userName,
    this.userSign,
    this.isGuest = false,
  });

  @override
  State<ModernGreetingSection> createState() => _ModernGreetingSectionState();
}

class _ModernGreetingSectionState extends State<ModernGreetingSection>
    with TickerProviderStateMixin {
  late AnimationController _greetingController;
  late AnimationController _waveController;
  late AnimationController _timeController;
  late Animation<double> _greetingFade;
  late Animation<Offset> _greetingSlide;
  late Animation<double> _waveAnimation;
  late Animation<double> _timeScale;

  Timer? _timeUpdateTimer;
  String _currentTime = '';
  String _greeting = '';
  IconData _greetingIcon = Icons.wb_sunny_rounded;
  Color _greetingColor = const Color(0xFFFDAB3D);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _updateGreeting();
    _startTimeUpdates();
  }

  void _initAnimations() {
    // Greeting animations
    _greetingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _greetingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _greetingController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _greetingSlide = Tween<Offset>(
      begin: const Offset(-0.2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _greetingController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Wave emoji animation
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.elasticIn),
    );

    // Time animation
    _timeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _timeScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _timeController, curve: Curves.elasticOut),
    );

    // Start animations
    _greetingController.forward();
    _timeController.forward();

    // Animate wave after greeting appears
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _waveController.repeat(reverse: true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _waveController.stop();
          }
        });
      }
    });
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      _greeting = 'Good Morning';
      _greetingIcon = Icons.wb_sunny_rounded;
      _greetingColor = const Color(0xFFFDAB3D);
    } else if (hour < 17) {
      _greeting = 'Good Afternoon';
      _greetingIcon = Icons.light_mode_rounded;
      _greetingColor = const Color(0xFFFF8E53);
    } else if (hour < 21) {
      _greeting = 'Good Evening';
      _greetingIcon = Icons.wb_twilight_rounded;
      _greetingColor = const Color(0xFF6C5CE7);
    } else {
      _greeting = 'Good Night';
      _greetingIcon = Icons.nightlight_rounded;
      _greetingColor = const Color(0xFF2E3192);
    }
  }

  void _startTimeUpdates() {
    _updateTime();
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _currentTime = DateFormat('h:mm a').format(DateTime.now());
      });
    }
  }

  @override
  void dispose() {
    _greetingController.dispose();
    _waveController.dispose();
    _timeController.dispose();
    _timeUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting with time-based icon
          AnimatedBuilder(
            animation: _greetingController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _greetingFade,
                child: SlideTransition(
                  position: _greetingSlide,
                  child: Row(
                    children: [
                      // Time-based icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _greetingColor.withOpacity(0.2),
                              _greetingColor.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _greetingIcon,
                          color: _greetingColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Greeting text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _greetingColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  'Hi, ${widget.userName}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.grey[900],
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Animated wave emoji
                                AnimatedBuilder(
                                  animation: _waveAnimation,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _waveAnimation.value,
                                      alignment: Alignment.bottomCenter,
                                      child: const Text(
                                        '👋',
                                        style: TextStyle(fontSize: 28),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Live time display
                      AnimatedBuilder(
                        animation: _timeController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _timeScale.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isDarkMode
                                        ? Colors.grey[800]?.withOpacity(0.5)
                                        : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      isDarkMode
                                          ? Colors.grey[700]!.withOpacity(0.3)
                                          : Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _currentTime,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isDarkMode
                                              ? Colors.white
                                              : Colors.grey[900],
                                    ),
                                  ),
                                  Text(
                                    DateFormat('MMM dd').format(now),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Date and additional info
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1400),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 10 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Row(
                    children: [
                      // Full date
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.calendar_today_rounded,
                          title: DateFormat('EEEE').format(now),
                          subtitle: DateFormat('dd MMMM yyyy').format(now),
                          color: const Color(0xFF4ECDC4),
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // User zodiac sign (if available)
                      if (widget.userSign != null && !widget.isGuest)
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.stars_rounded,
                            title: 'Your Sign',
                            subtitle: widget.userSign!,
                            color: const Color(0xFF6C5CE7),
                            isDarkMode: isDarkMode,
                          ),
                        ),

                      // Guest mode indicator
                      if (widget.isGuest)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              // Navigate to login
                            },
                            child: _InfoCard(
                              icon: Icons.login_rounded,
                              title: 'Guest Mode',
                              subtitle: 'Sign in',
                              color: const Color(0xFFFF6B6B),
                              isDarkMode: isDarkMode,
                              hasAction: true,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDarkMode;
  final bool hasAction;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDarkMode,
    this.hasAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850]?.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDarkMode
                  ? Colors.grey[800]!.withOpacity(0.5)
                  : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
              ],
            ),
          ),
          if (hasAction)
            Icon(Icons.arrow_forward_rounded, size: 16, color: color),
        ],
      ),
    );
  }
}


