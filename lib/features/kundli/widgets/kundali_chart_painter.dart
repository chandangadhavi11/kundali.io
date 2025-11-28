import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/services/kundali_calculation_service.dart';

/// Custom painter for North Indian style chart
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

    // Draw diagonal lines for North Indian chart
    canvas.drawLine(rect.topLeft, rect.bottomRight, paint);
    canvas.drawLine(rect.topRight, rect.bottomLeft, paint);

    // Draw inner rhombus
    final innerSize = radius * 0.5;
    final innerPath =
        Path()
          ..moveTo(center.dx, center.dy - innerSize)
          ..lineTo(center.dx + innerSize, center.dy)
          ..lineTo(center.dx, center.dy + innerSize)
          ..lineTo(center.dx - innerSize, center.dy)
          ..close();
    canvas.drawPath(innerPath, paint);

    // House positions for North Indian chart
    final housePositions = [
      // House 1 (top triangle)
      Offset(center.dx, rect.top + radius * 0.25),
      // House 2 (top-right)
      Offset(rect.right - radius * 0.25, rect.top + radius * 0.25),
      // House 3 (right-top)
      Offset(rect.right - radius * 0.25, center.dy - radius * 0.25),
      // House 4 (right triangle)
      Offset(rect.right - radius * 0.25, center.dy),
      // House 5 (right-bottom)
      Offset(rect.right - radius * 0.25, center.dy + radius * 0.25),
      // House 6 (bottom-right)
      Offset(rect.right - radius * 0.25, rect.bottom - radius * 0.25),
      // House 7 (bottom triangle)
      Offset(center.dx, rect.bottom - radius * 0.25),
      // House 8 (bottom-left)
      Offset(rect.left + radius * 0.25, rect.bottom - radius * 0.25),
      // House 9 (left-bottom)
      Offset(rect.left + radius * 0.25, center.dy + radius * 0.25),
      // House 10 (left triangle)
      Offset(rect.left + radius * 0.25, center.dy),
      // House 11 (left-top)
      Offset(rect.left + radius * 0.25, center.dy - radius * 0.25),
      // House 12 (top-left)
      Offset(rect.left + radius * 0.25, rect.top + radius * 0.25),
    ];

    // Draw house numbers and planets
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < 12; i++) {
      final house = houses[i];
      final position = housePositions[i];

      // Draw house number
      textPainter.text = TextSpan(
        text: '${i + 1}',
        style: textStyle?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          position.dx - textPainter.width / 2,
          position.dy - textPainter.height - 5,
        ),
      );

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
          position.dy - textPainter.height / 2,
        ),
      );

      // Draw planets in house
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
          Offset(position.dx - textPainter.width / 2, position.dy + 5),
        );
      }
    }

    // Draw "Asc" indicator
    textPainter.text = TextSpan(
      text: 'Asc',
      style: textStyle?.copyWith(
        fontSize: 14,
        color: Colors.orange,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
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
      'Rahu': 'Ra',
      'Ketu': 'Ke',
    };
    return symbols[planet] ?? planet.substring(0, 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
      'Rahu': 'Ra',
      'Ketu': 'Ke',
    };
    return symbols[planet] ?? planet.substring(0, 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
