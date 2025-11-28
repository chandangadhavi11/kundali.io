import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../shared/models/panchang_model.dart';

class ModernPanchangCard extends StatefulWidget {
  final Panchang panchang;
  final VoidCallback onTap;

  const ModernPanchangCard({
    super.key,
    required this.panchang,
    required this.onTap,
  });

  @override
  State<ModernPanchangCard> createState() => _ModernPanchangCardState();
}

class _ModernPanchangCardState extends State<ModernPanchangCard>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _waveController;
  late AnimationController _glowController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _glowAnimation;

  bool _isPressed = false;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));

    _glowAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // Stop all animations before disposing
    _rotationController.stop();
    _waveController.stop();
    _glowController.stop();

    _rotationController.dispose();
    _waveController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    setState(() {
      _showDetails = !_showDetails;
    });
    if (!_showDetails) {
      Future.delayed(const Duration(milliseconds: 200), widget.onTap);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF6C5CE7);
    final secondaryColor = const Color(0xFFFDAB3D);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
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
                  color: primaryColor.withOpacity(0.15),
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
                  // Background
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),

                  // Animated celestial background
                  Positioned.fill(
                    child: CustomPaint(
                      painter: CelestialBackgroundPainter(
                        animation: _waveAnimation,
                        color: primaryColor,
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with sun/moon animation
                        Row(
                          children: [
                            // Animated celestial icon
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow effect
                                AnimatedBuilder(
                                  animation: _glowAnimation,
                                  builder: (context, child) {
                                    return Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: secondaryColor.withOpacity(
                                              0.3 * _glowAnimation.value,
                                            ),
                                            blurRadius: 20,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                // Rotating sun
                                AnimatedBuilder(
                                  animation: _rotationAnimation,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _rotationAnimation.value,
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              secondaryColor,
                                              secondaryColor.withOpacity(0.7),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.wb_sunny_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Today\'s Panchang',
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
                                  Text(
                                    _getCurrentDate(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // View details button
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: AnimatedRotation(
                                duration: const Duration(milliseconds: 300),
                                turns: _showDetails ? 0.5 : 0,
                                child: Icon(
                                  Icons.expand_more_rounded,
                                  size: 18,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Panchang elements with staggered animation
                        ..._buildPanchangElements(isDarkMode),

                        // Festivals if any
                        if (widget.panchang.festivals.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildFestivalSection(isDarkMode),
                        ],

                        // Expanded details
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child:
                              _showDetails
                                  ? _buildExpandedDetails(isDarkMode)
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

  List<Widget> _buildPanchangElements(bool isDarkMode) {
    final elements = [
      {
        'label': 'Tithi',
        'value': widget.panchang.tithi,
        'icon': Icons.nightlight_rounded,
      },
      {
        'label': 'Nakshatra',
        'value': widget.panchang.nakshatra,
        'icon': Icons.star_rounded,
      },
      {
        'label': 'Yoga',
        'value': widget.panchang.yoga,
        'icon': Icons.self_improvement_rounded,
      },
      {
        'label': 'Karana',
        'value': widget.panchang.karana,
        'icon': Icons.schedule_rounded,
      },
    ];

    return elements.asMap().entries.map((entry) {
      final index = entry.key;
      final element = entry.value;

      return TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 600 + (index * 100)),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(30 * (1 - value), 0),
            child: Opacity(
              opacity: value,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPanchangItem(
                  element['label'] as String,
                  element['value'] as String,
                  element['icon'] as IconData,
                  isDarkMode,
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildPanchangItem(
    String label,
    String value,
    IconData icon,
    bool isDarkMode,
  ) {
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF95E1D3),
      const Color(0xFFB983FF),
    ];
    final color = colors[label.hashCode % colors.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFestivalSection(bool isDarkMode) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFDAB3D).withOpacity(0.1),
                    const Color(0xFFFF6B6B).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFDAB3D).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.celebration_rounded,
                    color: Color(0xFFFDAB3D),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Festival',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                isDarkMode
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.panchang.festivals.join(', '),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFFDAB3D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _buildExpandedDetails(bool isDarkMode) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Auspicious times
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.1), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time_filled_rounded,
                    size: 16,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Auspicious Times',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Display timing information
              if (widget.panchang.auspiciousTimings.isNotEmpty)
                ...widget.panchang.auspiciousTimings.map((timing) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 14,
                          color: Colors.green[400],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            timing,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                })
              else
                Text(
                  'No specific timings available',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Inauspicious times
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.1), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.block_rounded, size: 16, color: Colors.red[400]),
                  const SizedBox(width: 8),
                  Text(
                    'Inauspicious Times',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[400],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Display inauspicious timing information
              if (widget.panchang.inauspiciousTimings.isNotEmpty)
                ...widget.panchang.inauspiciousTimings.map((timing) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          size: 14,
                          color: Colors.red[400],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            timing,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                })
              else
                Text(
                  'No specific timings to avoid',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

// Custom painter for celestial background
class CelestialBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  CelestialBackgroundPainter({required this.animation, required this.color})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color.withOpacity(0.03)
          ..style = PaintingStyle.fill;

    // Draw animated celestial patterns
    for (int i = 0; i < 3; i++) {
      final offset = Offset(
        size.width * (0.2 + i * 0.3),
        size.height * 0.3 + math.sin(animation.value + i) * 10,
      );
      canvas.drawCircle(offset, 30, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
