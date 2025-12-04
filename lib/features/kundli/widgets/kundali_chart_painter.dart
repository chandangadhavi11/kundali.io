import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/services/kundali_calculation_service.dart';

/// Custom painter for North Indian style chart (Diamond style)
/// 
/// Structure:
/// - Outer square
/// - Inner diamond connecting midpoints of the square
/// - Diagonals from corner to corner
/// - 12 houses arranged clockwise starting from top center (House 1)
class NorthIndianChartPainter extends CustomPainter {
  final List<House> houses;
  final Map<String, PlanetPosition> planets;
  final String ascendantSign;
  final bool isDarkMode;
  final TextStyle? textStyle;

  NorthIndianChartPainter({
    required this.houses,
    required this.planets,
    required this.ascendantSign,
    required this.isDarkMode,
    this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final chartSize = math.min(size.width, size.height);
    final padding = chartSize * 0.05;
    final effectiveSize = chartSize - (padding * 2);
    
    // Define the four corners of the outer square
    final left = (size.width - effectiveSize) / 2;
    final top = (size.height - effectiveSize) / 2;
    final right = left + effectiveSize;
    final bottom = top + effectiveSize;
    final centerX = (left + right) / 2;
    final centerY = (top + bottom) / 2;
    
    // Midpoints of each edge
    final midTop = Offset(centerX, top);
    final midRight = Offset(right, centerY);
    final midBottom = Offset(centerX, bottom);
    final midLeft = Offset(left, centerY);
    
    // Corner points
    final topLeft = Offset(left, top);
    final topRight = Offset(right, top);
    final bottomRight = Offset(right, bottom);
    final bottomLeft = Offset(left, bottom);

    // Paints
    final strokePaint = Paint()
      ..color = isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF1A1625) : Colors.white
      ..style = PaintingStyle.fill;

    // Draw background
    final outerRect = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(outerRect, fillPaint);
    
    // Draw outer square
    canvas.drawRect(outerRect, strokePaint);
    
    // Draw diagonals (corner to corner)
    canvas.drawLine(topLeft, bottomRight, strokePaint);
    canvas.drawLine(topRight, bottomLeft, strokePaint);
    
    // Draw inner diamond (connecting midpoints)
    final diamondPath = Path()
      ..moveTo(midTop.dx, midTop.dy)
      ..lineTo(midRight.dx, midRight.dy)
      ..lineTo(midBottom.dx, midBottom.dy)
      ..lineTo(midLeft.dx, midLeft.dy)
      ..close();
    canvas.drawPath(diamondPath, strokePaint);

    // Calculate house centers for all 12 houses (clockwise from top center)
    // The chart creates 12 compartments with the above lines
    
    final houseSize = effectiveSize / 4;
    
    // House positions: center point for each compartment
    // House 1: Top center triangle (between midTop, diagonal intersection with top edge)
    // House 2: Top right corner triangle
    // House 3: Right upper triangle
    // House 4: Right center triangle
    // House 5: Right lower triangle  
    // House 6: Bottom right corner triangle
    // House 7: Bottom center triangle
    // House 8: Bottom left corner triangle
    // House 9: Left lower triangle
    // House 10: Left center triangle
    // House 11: Left upper triangle
    // House 12: Top left corner triangle

    final housePositions = <Offset>[
      // House 1 - Top center (main ascendant house)
      Offset(centerX, top + houseSize * 0.7),
      // House 2 - Top right corner
      Offset(right - houseSize * 0.6, top + houseSize * 0.6),
      // House 3 - Right upper
      Offset(right - houseSize * 0.7, centerY - houseSize * 0.55),
      // House 4 - Right center
      Offset(right - houseSize * 0.7, centerY),
      // House 5 - Right lower
      Offset(right - houseSize * 0.7, centerY + houseSize * 0.55),
      // House 6 - Bottom right corner
      Offset(right - houseSize * 0.6, bottom - houseSize * 0.6),
      // House 7 - Bottom center
      Offset(centerX, bottom - houseSize * 0.7),
      // House 8 - Bottom left corner
      Offset(left + houseSize * 0.6, bottom - houseSize * 0.6),
      // House 9 - Left lower
      Offset(left + houseSize * 0.7, centerY + houseSize * 0.55),
      // House 10 - Left center
      Offset(left + houseSize * 0.7, centerY),
      // House 11 - Left upper
      Offset(left + houseSize * 0.7, centerY - houseSize * 0.55),
      // House 12 - Top left corner
      Offset(left + houseSize * 0.6, top + houseSize * 0.6),
    ];

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    // Draw house content
    for (int i = 0; i < 12 && i < houses.length; i++) {
      final house = houses[i];
      final pos = housePositions[i];
      final isAscendant = house.sign == ascendantSign;
      
      // Determine vertical layout based on house type
      // Corner houses (2, 6, 8, 12) - smaller triangles
      // Center houses (1, 4, 7, 10) - main diamond triangles
      // Side houses (3, 5, 9, 11) - side triangles
      
      final isCornerHouse = [1, 5, 7, 11].contains(i); // 0-indexed: 2,6,8,12
      
      // Calculate font sizes based on chart size
      final houseNumSize = chartSize * 0.028;
      final signSize = chartSize * 0.038;
      final planetSize = chartSize * 0.032;
      
      // Vertical offset adjustments
      double numOffsetY = -signSize * 1.2;
      double planetOffsetY = signSize * 0.8;
      
      if (isCornerHouse) {
        numOffsetY = -signSize * 0.9;
        planetOffsetY = signSize * 0.6;
      }
      
      // Draw house number (small, subtle)
      textPainter.text = TextSpan(
        text: '${i + 1}',
        style: TextStyle(
          fontSize: houseNumSize,
          fontWeight: FontWeight.w600,
          color: isDarkMode 
            ? Colors.white.withOpacity(0.4) 
            : Colors.black.withOpacity(0.4),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy + numOffsetY - textPainter.height),
      );

      // Draw zodiac sign abbreviation
      textPainter.text = TextSpan(
        text: _getSignAbbreviation(house.sign),
        style: TextStyle(
          fontSize: signSize,
          fontWeight: isAscendant ? FontWeight.bold : FontWeight.w500,
          color: isAscendant 
            ? const Color(0xFFD4AF37) // Gold for ascendant
            : (isDarkMode ? Colors.white.withOpacity(0.85) : Colors.black87),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
      );

      // Draw planets in house
      if (house.planets.isNotEmpty) {
        final planetsText = house.planets.map(_getPlanetSymbol).join(' ');
        textPainter.text = TextSpan(
          text: planetsText,
          style: TextStyle(
            fontSize: planetSize,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF5B8DEF), // Blue for planets
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(pos.dx - textPainter.width / 2, pos.dy + planetOffsetY),
        );
      }
    }

    // Draw "Asc" indicator in center
    textPainter.text = TextSpan(
      text: 'Asc',
      style: TextStyle(
        fontSize: chartSize * 0.045,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFD4AF37),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2, centerY - textPainter.height / 2),
    );
  }

  String _getSignAbbreviation(String sign) {
    const abbreviations = {
      'Aries': 'Ari',
      'Taurus': 'Tau',
      'Gemini': 'Gem',
      'Cancer': 'Can',
      'Leo': 'Leo',
      'Virgo': 'Vir',
      'Libra': 'Lib',
      'Scorpio': 'Sco',
      'Sagittarius': 'Sag',
      'Capricorn': 'Cap',
      'Aquarius': 'Aqu',
      'Pisces': 'Pis',
    };
    return abbreviations[sign] ?? sign.substring(0, 3);
  }

  String _getPlanetSymbol(String planet) {
    const symbols = {
      'Sun': '☉',
      'Moon': '☽',
      'Mars': '♂',
      'Mercury': '☿',
      'Jupiter': '♃',
      'Venus': '♀',
      'Saturn': '♄',
      'Uranus': '♅',
      'Neptune': '♆',
      'Pluto': '♇',
      'Rahu': 'ॐ',
      'Ketu': '☋',
    };
    return symbols[planet] ?? planet.substring(0, 2);
  }

  @override
  bool shouldRepaint(covariant NorthIndianChartPainter oldDelegate) {
    return houses != oldDelegate.houses ||
           planets != oldDelegate.planets ||
           ascendantSign != oldDelegate.ascendantSign ||
           isDarkMode != oldDelegate.isDarkMode;
  }
}

/// Custom painter for South Indian style chart
class SouthIndianChartPainter extends CustomPainter {
  final List<House> houses;
  final Map<String, PlanetPosition> planets;
  final String ascendantSign;
  final bool isDarkMode;
  final TextStyle? textStyle;

  SouthIndianChartPainter({
    required this.houses,
    required this.planets,
    required this.ascendantSign,
    required this.isDarkMode,
    this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = isDarkMode ? Colors.white24 : Colors.black26
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final fillPaint =
        Paint()
          ..color = isDarkMode ? const Color(0xFF2A2A3E) : Colors.white
          ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

    // Draw outer square
    final rect = Rect.fromCenter(
      center: center,
      width: radius * 2,
      height: radius * 2,
    );
    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, paint);

    // Draw grid for South Indian chart (3x3 with center merged)
    final cellWidth = radius * 2 / 3;
    final cellHeight = radius * 2 / 3;

    // Draw vertical lines
    canvas.drawLine(
      Offset(rect.left + cellWidth, rect.top),
      Offset(rect.left + cellWidth, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left + cellWidth * 2, rect.top),
      Offset(rect.left + cellWidth * 2, rect.bottom),
      paint,
    );

    // Draw horizontal lines
    canvas.drawLine(
      Offset(rect.left, rect.top + cellHeight),
      Offset(rect.right, rect.top + cellHeight),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top + cellHeight * 2),
      Offset(rect.right, rect.top + cellHeight * 2),
      paint,
    );

    // South Indian chart house positions (fixed signs)
    final signPositions = {
      'Pisces': Offset(
        rect.left + cellWidth * 0.5,
        rect.top + cellHeight * 0.5,
      ),
      'Aries': Offset(rect.left + cellWidth * 1.5, rect.top + cellHeight * 0.5),
      'Taurus': Offset(
        rect.left + cellWidth * 2.5,
        rect.top + cellHeight * 0.5,
      ),
      'Gemini': Offset(
        rect.left + cellWidth * 2.5,
        rect.top + cellHeight * 1.5,
      ),
      'Cancer': Offset(
        rect.left + cellWidth * 2.5,
        rect.top + cellHeight * 2.5,
      ),
      'Leo': Offset(rect.left + cellWidth * 1.5, rect.top + cellHeight * 2.5),
      'Virgo': Offset(rect.left + cellWidth * 0.5, rect.top + cellHeight * 2.5),
      'Libra': Offset(rect.left + cellWidth * 0.5, rect.top + cellHeight * 1.5),
      'Scorpio': Offset(
        rect.left + cellWidth * 0.5,
        rect.top + cellHeight * 1.5,
      ),
      'Sagittarius': Offset(
        rect.left + cellWidth * 0.5,
        rect.top + cellHeight * 1.5,
      ),
      'Capricorn': Offset(
        rect.left + cellWidth * 1.5,
        rect.top + cellHeight * 1.5,
      ),
      'Aquarius': Offset(
        rect.left + cellWidth * 2.5,
        rect.top + cellHeight * 1.5,
      ),
    };

    // Draw signs and planets
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final house in houses) {
      final position = signPositions[house.sign] ?? center;

      // Draw sign
      textPainter.text = TextSpan(
        text: _getSignAbbreviation(house.sign),
        style: textStyle?.copyWith(
          fontSize: 12,
          color:
              house.sign == ascendantSign
                  ? Colors.orange
                  : (isDarkMode ? Colors.white : Colors.black87),
          fontWeight:
              house.sign == ascendantSign ? FontWeight.bold : FontWeight.normal,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          position.dx - textPainter.width / 2,
          position.dy - textPainter.height / 2 - 10,
        ),
      );

      // Draw house number
      textPainter.text = TextSpan(
        text: '${house.number}',
        style: textStyle?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white54 : Colors.black45,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          position.dx - textPainter.width / 2,
          position.dy - textPainter.height / 2 + 5,
        ),
      );

      // Draw planets
      if (house.planets.isNotEmpty) {
        final planetsText = house.planets.map(_getPlanetSymbol).join(' ');
        textPainter.text = TextSpan(
          text: planetsText,
          style: textStyle?.copyWith(
            fontSize: 11,
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(position.dx - textPainter.width / 2, position.dy + 10),
        );
      }
    }

    // Draw ascendant indicator
    if (ascendantSign.isNotEmpty) {
      final ascPosition = signPositions[ascendantSign] ?? center;
      final ascPaint =
          Paint()
            ..color = Colors.orange
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;

      // Draw a diagonal line in ascendant house
      canvas.drawLine(
        Offset(ascPosition.dx - 15, ascPosition.dy - 20),
        Offset(ascPosition.dx - 5, ascPosition.dy - 10),
        ascPaint,
      );
    }
  }

  String _getSignAbbreviation(String sign) {
    final abbreviations = {
      'Aries': 'Ari',
      'Taurus': 'Tau',
      'Gemini': 'Gem',
      'Cancer': 'Can',
      'Leo': 'Leo',
      'Virgo': 'Vir',
      'Libra': 'Lib',
      'Scorpio': 'Sco',
      'Sagittarius': 'Sag',
      'Capricorn': 'Cap',
      'Aquarius': 'Aqu',
      'Pisces': 'Pis',
    };
    return abbreviations[sign] ?? sign.substring(0, 3);
  }

  String _getPlanetSymbol(String planet) {
    final symbols = {
      'Sun': '☉',
      'Moon': '☽',
      'Mars': '♂',
      'Mercury': '☿',
      'Jupiter': '♃',
      'Venus': '♀',
      'Saturn': '♄',
      'Uranus': '♅',
      'Neptune': '♆',
      'Pluto': '♇',
      'Rahu': 'Ra',
      'Ketu': 'Ke',
    };
    return symbols[planet] ?? planet.substring(0, 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
