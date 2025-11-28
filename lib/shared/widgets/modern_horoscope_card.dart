import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/models/horoscope_model.dart';

class ModernHoroscopeCard extends StatefulWidget {
  final String sign;
  final Horoscope horoscope;
  final VoidCallback onTap;

  const ModernHoroscopeCard({
    super.key,
    required this.sign,
    required this.horoscope,
    required this.onTap,
  });

  @override
  State<ModernHoroscopeCard> createState() => _ModernHoroscopeCardState();
}

class _ModernHoroscopeCardState extends State<ModernHoroscopeCard>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;

  bool _isExpanded = false;
  bool _isPressed = false;

  // Zodiac colors with modern palette
  static const Map<String, Color> zodiacColors = {
    'Aries': Color(0xFFFF6B6B),
    'Taurus': Color(0xFF4ECDC4),
    'Gemini': Color(0xFFFFD93D),
    'Cancer': Color(0xFF95E1D3),
    'Leo': Color(0xFFFFA502),
    'Virgo': Color(0xFFA8E6CF),
    'Libra': Color(0xFFFF8B94),
    'Scorpio': Color(0xFF8B5CF6),
    'Sagittarius': Color(0xFFB983FF),
    'Capricorn': Color(0xFF6C5B7B),
    'Aquarius': Color(0xFF3498DB),
    'Pisces': Color(0xFF74B9FF),
  };

  @override
  void initState() {
    super.initState();

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Animation is used via _expandController directly

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // Stop all animations before disposing
    _expandController.stop();
    _shimmerController.stop();
    _pulseController.stop();

    _expandController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });

    // Delay navigation if expanding
    if (!_isExpanded) {
      Future.delayed(const Duration(milliseconds: 200), widget.onTap);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final zodiacColor = zodiacColors[widget.sign] ?? const Color(0xFFFF6B6B);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: zodiacColor.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Background with gradient
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),

                  // Animated shimmer effect
                  AnimatedBuilder(
                    animation: _shimmerAnimation,
                    builder: (context, child) {
                      return Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.transparent,
                                zodiacColor.withOpacity(0.03),
                                zodiacColor.withOpacity(0.05),
                                zodiacColor.withOpacity(0.03),
                                Colors.transparent,
                              ],
                              stops:
                                  [
                                    0.0,
                                    _shimmerAnimation.value - 0.3,
                                    _shimmerAnimation.value,
                                    _shimmerAnimation.value + 0.3,
                                    1.0,
                                  ].map((e) => e.clamp(0.0, 1.0)).toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            // Animated icon container
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          zodiacColor.withOpacity(0.15),
                                          zodiacColor.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome_rounded,
                                      color: zodiacColor,
                                      size: 24,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Daily Horoscope',
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
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        _getZodiacIcon(widget.sign),
                                        size: 14,
                                        color: zodiacColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.sign,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: zodiacColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Animated arrow
                            AnimatedRotation(
                              duration: const Duration(milliseconds: 300),
                              turns: _isExpanded ? 0.25 : 0,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: zodiacColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: zodiacColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Main content
                        AnimatedCrossFade(
                          firstChild: Text(
                            widget.horoscope.general,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          secondChild: Text(
                            widget.horoscope.general,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                          crossFadeState:
                              _isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                        ),

                        const SizedBox(height: 16),

                        // Lucky elements with animations
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildAnimatedChip(
                              icon: Icons.favorite_rounded,
                              label: widget.horoscope.mood,
                              color: const Color(0xFFFF6B94),
                              delay: 0,
                            ),
                            _buildAnimatedChip(
                              icon: Icons.palette_rounded,
                              label: widget.horoscope.luckyColor,
                              color: const Color(0xFF4ECDC4),
                              delay: 100,
                            ),
                            _buildAnimatedChip(
                              icon: Icons.looks_one_rounded,
                              label: widget.horoscope.luckyNumber.toString(),
                              color: const Color(0xFF95E1D3),
                              delay: 200,
                            ),
                          ],
                        ),

                        // Expanded content
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child:
                              _isExpanded
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 16),
                                      _buildExpandedSection(
                                        'Love & Relationships',
                                        widget.horoscope.love,
                                        Icons.favorite_rounded,
                                        const Color(0xFFFF6B94),
                                        isDarkMode,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildExpandedSection(
                                        'Career & Finance',
                                        widget.horoscope.career,
                                        Icons.trending_up_rounded,
                                        const Color(0xFF4ECDC4),
                                        isDarkMode,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildExpandedSection(
                                        'Health & Wellness',
                                        widget.horoscope.health,
                                        Icons.favorite_border_rounded,
                                        const Color(0xFF95E1D3),
                                        isDarkMode,
                                      ),
                                    ],
                                  )
                                  : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedChip({
    required IconData icon,
    required String label,
    required Color color,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.2), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w500,
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

  Widget _buildExpandedSection(
    String title,
    String content,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getZodiacIcon(String sign) {
    // Return appropriate icons for each zodiac sign
    switch (sign.toLowerCase()) {
      case 'aries':
        return Icons.whatshot_rounded;
      case 'taurus':
        return Icons.terrain_rounded;
      case 'gemini':
        return Icons.people_rounded;
      case 'cancer':
        return Icons.home_rounded;
      case 'leo':
        return Icons.sunny;
      case 'virgo':
        return Icons.eco_rounded;
      case 'libra':
        return Icons.balance_rounded;
      case 'scorpio':
        return Icons.water_drop_rounded;
      case 'sagittarius':
        return Icons.explore_rounded;
      case 'capricorn':
        return Icons.landscape_rounded;
      case 'aquarius':
        return Icons.air_rounded;
      case 'pisces':
        return Icons.waves_rounded;
      default:
        return Icons.stars_rounded;
    }
  }
}
