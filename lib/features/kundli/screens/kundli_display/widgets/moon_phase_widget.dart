import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A widget that displays a realistic moon phase based on tithi
class MoonPhaseWidget extends StatelessWidget {
  final int tithiNumber; // 1-15
  final String paksha; // 'Shukla' or 'Krishna'
  final double size;

  const MoonPhaseWidget({
    super.key,
    required this.tithiNumber,
    required this.paksha,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFBBF24).withOpacity(0.25),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: CustomPaint(
          size: Size(size, size),
          painter: _MoonPhasePainter(tithiNumber: tithiNumber, paksha: paksha),
        ),
      ),
    );
  }
}

/// Custom painter for realistic moon phase visualization
class _MoonPhasePainter extends CustomPainter {
  final int tithiNumber;
  final String paksha;

  _MoonPhasePainter({required this.tithiNumber, required this.paksha});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Determine if waxing (Shukla) or waning (Krishna)
    final bool isWaxing = paksha.toLowerCase() == 'shukla';

    // Calculate illumination fraction (0 to 1)
    // Tithi 1 = just started, Tithi 15 = end of paksha
    // Shukla: 1 = thin crescent, 15 = full moon
    // Krishna: 1 = almost full, 15 = new moon
    double illumination;
    if (isWaxing) {
      // Waxing: tithi 1 ≈ 0%, tithi 15 = 100%
      illumination = tithiNumber / 15.0;
    } else {
      // Waning: tithi 1 ≈ 100%, tithi 15 ≈ 0%
      illumination = 1.0 - (tithiNumber / 15.0);
    }

    // Clamp illumination
    illumination = illumination.clamp(0.0, 1.0);

    // Draw the dark moon base (shadow)
    _drawDarkMoon(canvas, center, radius);

    // Draw the illuminated portion
    if (illumination > 0.02) {
      _drawIlluminatedPortion(canvas, center, radius, illumination, isWaxing);
    }

    // Add subtle rim highlight
    final rimPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, radius - 0.4, rimPaint);
  }

  void _drawDarkMoon(Canvas canvas, Offset center, double radius) {
    // Dark moon surface
    final darkGradient = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 1.2,
        colors: const [
          Color(0xFF2A2438), // Slightly lighter center
          Color(0xFF1A1425), // Dark purple-gray
          Color(0xFF0F0B14), // Very dark edge
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, darkGradient);

    // Draw subtle craters on dark surface
    _drawCraters(canvas, center, radius, 0.25, isDark: true);
  }

  void _drawIlluminatedPortion(
    Canvas canvas,
    Offset center,
    double radius,
    double illumination,
    bool isWaxing,
  ) {
    // Full moon - just fill the whole circle
    if (illumination >= 0.98) {
      _drawFullMoon(canvas, center, radius);
      return;
    }

    // Create clipping path for the illuminated portion
    final clipPath = _createMoonPhasePath(center, radius, illumination, isWaxing);

    canvas.save();
    canvas.clipPath(clipPath);

    // Draw the lit moon surface
    _drawFullMoon(canvas, center, radius);

    canvas.restore();
  }

  void _drawFullMoon(Canvas canvas, Offset center, double radius) {
    // Lit moon gradient - warm moonlight color
    final moonGradient = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.3),
        radius: 1.0,
        colors: const [
          Color(0xFFFFFEF8), // Bright white-yellow center
          Color(0xFFF8F0D8), // Warm cream
          Color(0xFFE8DCC0), // Slightly darker edge
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, moonGradient);

    // Draw craters on lit surface
    _drawCraters(canvas, center, radius, 0.12, isDark: false);
  }

  Path _createMoonPhasePath(
    Offset center,
    double radius,
    double illumination,
    bool isWaxing,
  ) {
    final path = Path();

    // For waxing moon: right side is lit first
    // For waning moon: left side remains lit

    // The terminator position: 0 = no light, 0.5 = half moon, 1 = full moon
    // We use an ellipse whose width varies with illumination

    if (isWaxing) {
      // Waxing: light comes from the right
      // Draw right semicircle (always lit edge)
      path.moveTo(center.dx, center.dy - radius);
      path.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start at top
        math.pi, // Sweep clockwise to bottom
        false,
      );

      // Draw terminator curve from bottom to top
      if (illumination <= 0.5) {
        // Crescent phase: terminator curves INTO the lit area (concave from lit side)
        // Scale goes from 1 (new moon) to 0 (half moon)
        final terminatorWidth = radius * (1.0 - illumination * 2);
        path.arcTo(
          Rect.fromCenter(
            center: center,
            width: terminatorWidth * 2,
            height: radius * 2,
          ),
          math.pi / 2, // Start at bottom
          math.pi, // Curve through left side back to top
          false,
        );
      } else {
        // Gibbous phase: terminator curves AWAY from lit area (convex from lit side)
        // Scale goes from 0 (half moon) to 1 (full moon)
        final terminatorWidth = radius * ((illumination - 0.5) * 2);
        path.arcTo(
          Rect.fromCenter(
            center: center,
            width: terminatorWidth * 2,
            height: radius * 2,
          ),
          math.pi / 2, // Start at bottom
          -math.pi, // Curve through right side back to top (opposite direction)
          false,
        );
      }
    } else {
      // Waning: light remains on the left
      // Draw left semicircle (always lit edge)
      path.moveTo(center.dx, center.dy - radius);
      path.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start at top
        -math.pi, // Sweep counter-clockwise to bottom
        false,
      );

      // Draw terminator curve from bottom to top
      if (illumination <= 0.5) {
        // Crescent phase
        final terminatorWidth = radius * (1.0 - illumination * 2);
        path.arcTo(
          Rect.fromCenter(
            center: center,
            width: terminatorWidth * 2,
            height: radius * 2,
          ),
          math.pi / 2, // Start at bottom
          -math.pi, // Curve through right side back to top
          false,
        );
      } else {
        // Gibbous phase
        final terminatorWidth = radius * ((illumination - 0.5) * 2);
        path.arcTo(
          Rect.fromCenter(
            center: center,
            width: terminatorWidth * 2,
            height: radius * 2,
          ),
          math.pi / 2, // Start at bottom
          math.pi, // Curve through left side back to top
          false,
        );
      }
    }

    path.close();
    return path;
  }

  void _drawCraters(
    Canvas canvas,
    Offset center,
    double radius,
    double opacity, {
    required bool isDark,
  }) {
    final craterColor = isDark
        ? const Color(0xFF0A0710).withOpacity(opacity)
        : const Color(0xFFD0C4A8).withOpacity(opacity);

    final craterPaint = Paint()
      ..color = craterColor
      ..style = PaintingStyle.fill;

    // Predefined crater positions for natural look
    final craters = [
      {'angle': 0.3, 'dist': 0.4, 'size': 0.12},
      {'angle': 1.8, 'dist': 0.55, 'size': 0.08},
      {'angle': 2.5, 'dist': 0.3, 'size': 0.15},
      {'angle': 4.2, 'dist': 0.6, 'size': 0.1},
      {'angle': 5.5, 'dist': 0.35, 'size': 0.09},
    ];

    for (final crater in craters) {
      final angle = crater['angle']!;
      final dist = crater['dist']! * radius;
      final craterRadius = crater['size']! * radius;

      canvas.drawCircle(
        Offset(
          center.dx + math.cos(angle) * dist,
          center.dy + math.sin(angle) * dist,
        ),
        craterRadius,
        craterPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MoonPhasePainter oldDelegate) {
    return oldDelegate.tithiNumber != tithiNumber ||
        oldDelegate.paksha != paksha;
  }
}
