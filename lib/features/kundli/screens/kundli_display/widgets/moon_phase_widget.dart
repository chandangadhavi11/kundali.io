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
            color: const Color(0xFFFBBF24).withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _MoonPhasePainter(tithiNumber: tithiNumber, paksha: paksha),
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
    final radius = size.width / 2 - 1;

    // Calculate phase (0.0 to 1.0 representing the lunar cycle)
    // Shukla Paksha: Tithi 1 = just after new moon, Tithi 15 = full moon
    // Krishna Paksha: Tithi 1 = just after full moon, Tithi 15 = new moon
    bool isWaxing = paksha == 'Shukla';

    // Phase: 0 = new moon, 0.5 = full moon, 1 = new moon again
    double phase;
    if (isWaxing) {
      // Shukla: tithi 1 → phase ~0, tithi 15 → phase 0.5 (full moon)
      phase = (tithiNumber - 1) / 30.0;
    } else {
      // Krishna: tithi 1 → phase ~0.5 (just past full), tithi 15 → phase ~1 (new moon)
      phase = 0.5 + (tithiNumber - 1) / 30.0;
    }

    // Draw dark moon background (the shadow side)
    final darkPaint =
        Paint()
          ..color = const Color(0xFF1A1425)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, darkPaint);

    // Draw subtle craters on dark side
    _drawCraters(canvas, center, radius, 0.3);

    // Draw the illuminated portion
    _drawIlluminatedMoon(canvas, center, radius, phase);

    // Add rim light
    final rimPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
    canvas.drawCircle(center, radius, rimPaint);
  }

  void _drawCraters(
    Canvas canvas,
    Offset center,
    double radius,
    double opacity,
  ) {
    final random = math.Random(42);
    final craterPaint =
        Paint()
          ..color = const Color(0xFF0D0A12).withOpacity(opacity)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final dist = random.nextDouble() * radius * 0.65;
      final r = radius * (0.08 + random.nextDouble() * 0.12);

      canvas.drawCircle(
        Offset(
          center.dx + math.cos(angle) * dist,
          center.dy + math.sin(angle) * dist,
        ),
        r,
        craterPaint,
      );
    }
  }

  void _drawIlluminatedMoon(
    Canvas canvas,
    Offset center,
    double radius,
    double phase,
  ) {
    // Illumination: 0 at new moon, 1 at full moon, 0 at new moon again
    // phase 0 or 1 = new moon (0% illumination)
    // phase 0.5 = full moon (100% illumination)
    final illumination = (1 - (2 * (phase - 0.5)).abs());

    if (illumination < 0.02) return; // New moon - nothing to draw

    // Determine which side is lit
    // phase < 0.5 = waxing (right side lit)
    // phase > 0.5 = waning (left side lit)
    final bool rightSideLit = phase < 0.5;

    // Moon gradient for 3D look
    final moonPaint =
        Paint()
          ..shader = RadialGradient(
            center: Alignment(rightSideLit ? 0.3 : -0.3, -0.25),
            radius: 0.9,
            colors: const [
              Color(0xFFFFFCF0), // Bright center
              Color(0xFFF5E8C8), // Moon yellow
              Color(0xFFE8D5A0), // Edge
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.save();

    // Clip to moon circle
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );

    // Full moon case
    if (illumination > 0.98) {
      canvas.drawCircle(center, radius, moonPaint);
      _drawCraters(canvas, center, radius, 0.15);
      canvas.restore();
      return;
    }

    // Create the illuminated shape using the terminator curve
    final path = Path();

    // The terminator is an ellipse. Its x-scale determines the phase appearance.
    // terminatorScale: -1 = crescent (shadow bulges into lit side)
    //                   0 = half moon (straight line terminator)
    //                  +1 = gibbous (lit side bulges into shadow)
    //
    // For waxing: illumination 0→0.5 = crescent→half, 0.5→1 = half→gibbous→full
    // For waning: same but mirrored

    final double terminatorScale;
    if (illumination <= 0.5) {
      // Crescent phase: terminator curves inward (negative scale)
      terminatorScale = -(1 - illumination * 2);
    } else {
      // Gibbous phase: terminator curves outward (positive scale)
      terminatorScale = (illumination - 0.5) * 2;
    }

    // Build the path
    if (rightSideLit) {
      // Right side lit (waxing)
      // Draw right semicircle (the lit outer edge)
      path.moveTo(center.dx, center.dy - radius);
      path.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi,
        false,
      );

      // Draw terminator curve back to top
      // This is an ellipse with width = radius * terminatorScale
      if (terminatorScale.abs() < 0.01) {
        // Half moon - straight line
        path.lineTo(center.dx, center.dy - radius);
      } else {
        path.arcTo(
          Rect.fromCenter(
            center: center,
            width: (radius * terminatorScale).abs() * 2,
            height: radius * 2,
          ),
          math.pi / 2,
          terminatorScale > 0 ? math.pi : -math.pi,
          false,
        );
      }
    } else {
      // Left side lit (waning)
      // Draw left semicircle (the lit outer edge)
      path.moveTo(center.dx, center.dy - radius);
      path.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        -math.pi,
        false,
      );

      // Draw terminator curve back to top
      if (terminatorScale.abs() < 0.01) {
        // Half moon - straight line
        path.lineTo(center.dx, center.dy - radius);
      } else {
        path.arcTo(
          Rect.fromCenter(
            center: center,
            width: (radius * terminatorScale).abs() * 2,
            height: radius * 2,
          ),
          math.pi / 2,
          terminatorScale > 0 ? -math.pi : math.pi,
          false,
        );
      }
    }

    path.close();
    canvas.drawPath(path, moonPaint);

    // Draw craters on lit portion
    canvas.clipPath(path);
    _drawCraters(canvas, center, radius, 0.12);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MoonPhasePainter oldDelegate) {
    return oldDelegate.tithiNumber != tithiNumber ||
        oldDelegate.paksha != paksha;
  }
}

