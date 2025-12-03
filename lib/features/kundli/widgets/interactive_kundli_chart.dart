import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/kundali_calculation_service.dart';
import '../../../shared/models/kundali_data_model.dart';

/// Interactive North Indian Kundli chart with tappable, glowing house compartments
class InteractiveKundliChart extends StatefulWidget {
  final List<House> houses;
  final Map<String, PlanetPosition> planetPositions;
  final String ascendantSign;
  final ChartStyle chartStyle;
  final bool isDarkMode;

  const InteractiveKundliChart({
    super.key,
    required this.houses,
    required this.planetPositions,
    required this.ascendantSign,
    this.chartStyle = ChartStyle.northIndian,
    this.isDarkMode = true,
  });

  @override
  State<InteractiveKundliChart> createState() => _InteractiveKundliChartState();
}

class _InteractiveKundliChartState extends State<InteractiveKundliChart>
    with SingleTickerProviderStateMixin {
  int? _selectedVisualPos; // Visual position for glow effect (0-11)
  int? _pressedVisualPos; // Visual position for press feedback

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Store house polygons for hit testing
  final Map<int, Path> _housePaths = {};
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000), // Slower, more soothing
      vsync: this,
    );
    // Very subtle pulsing - barely noticeable but elegant
    _glowAnimation = Tween<double>(begin: 0.4, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);

    // Debug: Log houses data received by chart
    debugPrint('NorthIndianChart: === CHART DATA ===');
    debugPrint('NorthIndianChart: Ascendant Sign: ${widget.ascendantSign}');
    for (final house in widget.houses) {
      if (house.planets.isNotEmpty) {
        debugPrint(
          'NorthIndianChart: House ${house.number} (${house.sign}): ${house.planets.join(", ")}',
        );
      }
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _buildHousePaths(Size size) {
    if (size == _lastSize && _housePaths.isNotEmpty) return;
    _lastSize = size;
    _housePaths.clear();

    final chartSize = math.min(size.width, size.height);
    final padding = chartSize * 0.02;
    final effectiveSize = chartSize - (padding * 2);

    final left = (size.width - effectiveSize) / 2;
    final top = (size.height - effectiveSize) / 2;
    final right = left + effectiveSize;
    final bottom = top + effectiveSize;
    final centerX = (left + right) / 2;
    final centerY = (top + bottom) / 2;
    final quarterW = effectiveSize / 4;
    final quarterH = effectiveSize / 4;

    // Corner points of outer square
    final TL = Offset(left, top);
    final TR = Offset(right, top);
    final BR = Offset(right, bottom);
    final BL = Offset(left, bottom);

    // Midpoints of outer square edges
    final MT = Offset(centerX, top);
    final MR = Offset(right, centerY);
    final MB = Offset(centerX, bottom);
    final ML = Offset(left, centerY);

    // Center point
    final C = Offset(centerX, centerY);

    // CRITICAL: Intersection points where diagonals cross diamond edges
    // These create the actual house boundaries in North Indian chart
    // P1: diagonal TL-BR crosses diamond edge ML-MT
    // P2: diagonal TR-BL crosses diamond edge MT-MR
    // P3: diagonal TL-BR crosses diamond edge MR-MB
    // P4: diagonal TR-BL crosses diamond edge MB-ML
    final P1 = Offset(centerX - quarterW, centerY - quarterH);
    final P2 = Offset(centerX + quarterW, centerY - quarterH);
    final P3 = Offset(centerX + quarterW, centerY + quarterH);
    final P4 = Offset(centerX - quarterW, centerY + quarterH);

    // ═══════════════════════════════════════════════════════════════
    // HOUSE PATHS - North Indian Kundli (Diamond Style)
    // Houses go ANTI-CLOCKWISE starting from House 1 at top center
    // ═══════════════════════════════════════════════════════════════

    // House 1 - TOP CENTER KITE (Lagna/Ascendant - always here!)
    _housePaths[0] =
        Path()
          ..moveTo(MT.dx, MT.dy)
          ..lineTo(P1.dx, P1.dy)
          ..lineTo(C.dx, C.dy)
          ..lineTo(P2.dx, P2.dy)
          ..close();

    // House 2 - TOP LEFT TRIANGLE (anti-clockwise from House 1)
    _housePaths[1] =
        Path()
          ..moveTo(TL.dx, TL.dy)
          ..lineTo(P1.dx, P1.dy)
          ..lineTo(MT.dx, MT.dy)
          ..close();

    // House 3 - LEFT UPPER TRIANGLE
    _housePaths[2] =
        Path()
          ..moveTo(ML.dx, ML.dy)
          ..lineTo(P1.dx, P1.dy)
          ..lineTo(TL.dx, TL.dy)
          ..close();

    // House 4 - LEFT CENTER KITE
    _housePaths[3] =
        Path()
          ..moveTo(ML.dx, ML.dy)
          ..lineTo(P4.dx, P4.dy)
          ..lineTo(C.dx, C.dy)
          ..lineTo(P1.dx, P1.dy)
          ..close();

    // House 5 - LEFT LOWER TRIANGLE
    _housePaths[4] =
        Path()
          ..moveTo(BL.dx, BL.dy)
          ..lineTo(P4.dx, P4.dy)
          ..lineTo(ML.dx, ML.dy)
          ..close();

    // House 6 - BOTTOM LEFT TRIANGLE
    _housePaths[5] =
        Path()
          ..moveTo(MB.dx, MB.dy)
          ..lineTo(P4.dx, P4.dy)
          ..lineTo(BL.dx, BL.dy)
          ..close();

    // House 7 - BOTTOM CENTER KITE
    _housePaths[6] =
        Path()
          ..moveTo(MB.dx, MB.dy)
          ..lineTo(P3.dx, P3.dy)
          ..lineTo(C.dx, C.dy)
          ..lineTo(P4.dx, P4.dy)
          ..close();

    // House 8 - BOTTOM RIGHT TRIANGLE
    _housePaths[7] =
        Path()
          ..moveTo(BR.dx, BR.dy)
          ..lineTo(P3.dx, P3.dy)
          ..lineTo(MB.dx, MB.dy)
          ..close();

    // House 9 - RIGHT LOWER TRIANGLE
    _housePaths[8] =
        Path()
          ..moveTo(MR.dx, MR.dy)
          ..lineTo(P3.dx, P3.dy)
          ..lineTo(BR.dx, BR.dy)
          ..close();

    // House 10 - RIGHT CENTER KITE
    _housePaths[9] =
        Path()
          ..moveTo(MR.dx, MR.dy)
          ..lineTo(P2.dx, P2.dy)
          ..lineTo(C.dx, C.dy)
          ..lineTo(P3.dx, P3.dy)
          ..close();

    // House 11 - RIGHT UPPER TRIANGLE
    _housePaths[10] =
        Path()
          ..moveTo(TR.dx, TR.dy)
          ..lineTo(MR.dx, MR.dy)
          ..lineTo(P2.dx, P2.dy)
          ..close();

    // House 12 - TOP RIGHT TRIANGLE
    _housePaths[11] =
        Path()
          ..moveTo(TL.dx, TL.dy)
          ..lineTo(P1.dx, P1.dy)
          ..lineTo(MT.dx, MT.dy)
          ..close();
  }

  // Returns visual position (0-11) at the tap point
  int? _getVisualPositionAtPoint(Offset position) {
    for (final entry in _housePaths.entries) {
      if (entry.value.contains(position)) {
        return entry.key;
      }
    }
    return null;
  }

  // Convert visual position to house array index
  // In North Indian chart, house positions are FIXED:
  // Visual position 0 = House 1 (index 0)
  // Visual position 1 = House 2 (index 1)
  // etc.
  int? _getHouseIndexAtVisualPosition(int visualPosition) {
    // Direct mapping: visual position = house array index
    if (visualPosition >= 0 && visualPosition < widget.houses.length) {
      return visualPosition;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        // Build paths for hit testing
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _buildHousePaths(size);
        });

        return GestureDetector(
          onTapDown: (details) {
            _buildHousePaths(size);
            final visualPos = _getVisualPositionAtPoint(details.localPosition);
            if (visualPos != null) {
              setState(() => _pressedVisualPos = visualPos);
              HapticFeedback.lightImpact();
            }
          },
          onTapUp: (details) {
            _buildHousePaths(size);
            final visualPos = _getVisualPositionAtPoint(details.localPosition);
            final houseIndex =
                visualPos != null
                    ? _getHouseIndexAtVisualPosition(visualPos)
                    : null;
            setState(() {
              _pressedVisualPos = null;
              _selectedVisualPos = visualPos;
            });
            if (houseIndex != null) {
              _showHouseDetails(context, houseIndex);
            }
          },
          onTapCancel: () => setState(() => _pressedVisualPos = null),
          onPanUpdate: (details) {
            _buildHousePaths(size);
            final visualPos = _getVisualPositionAtPoint(details.localPosition);
            if (visualPos != _selectedVisualPos) {
              setState(() => _selectedVisualPos = visualPos);
              if (visualPos != null) {
                HapticFeedback.selectionClick();
              }
            }
          },
          onPanEnd: (_) {
            if (_selectedVisualPos != null) {
              final houseIndex = _getHouseIndexAtVisualPosition(
                _selectedVisualPos!,
              );
              if (houseIndex != null) {
                _showHouseDetails(context, houseIndex);
              }
            }
            setState(() => _selectedVisualPos = null);
          },
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: _GlowingChartPainter(
                  houses: widget.houses,
                  ascendantSign: widget.ascendantSign,
                  isDarkMode: widget.isDarkMode,
                  selectedHouse: _selectedVisualPos, // Visual position for glow
                  pressedHouse: _pressedVisualPos, // Visual position for press
                  glowIntensity: _glowAnimation.value,
                  housePaths: _housePaths,
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showHouseDetails(BuildContext context, int houseIndex) {
    if (houseIndex >= widget.houses.length) return;

    final house = widget.houses[houseIndex];

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return _HouseDetailModal(
            house: house,
            houseIndex: houseIndex,
            planetPositions: widget.planetPositions,
            ascendantSign: widget.ascendantSign,
            animation: animation,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
    );
  }
}

/// Custom painter that draws glowing house compartments
class _GlowingChartPainter extends CustomPainter {
  final List<House> houses;
  final String ascendantSign;
  final bool isDarkMode;
  final int? selectedHouse;
  final int? pressedHouse;
  final double glowIntensity;
  final Map<int, Path> housePaths;

  _GlowingChartPainter({
    required this.houses,
    required this.ascendantSign,
    required this.isDarkMode,
    this.selectedHouse,
    this.pressedHouse,
    required this.glowIntensity,
    required this.housePaths,
  });

  // Colors
  static const _surfaceColor = Color(0xFF1A1625);
  static const _strokeColor = Color(0xFF3D3A4A);
  static const _accentPrimary = Color(0xFFD4AF37);
  static const _glowColor = Color(0xFFD4AF37);

  @override
  void paint(Canvas canvas, Size size) {
    final chartSize = math.min(size.width, size.height);
    final padding = chartSize * 0.02;
    final effectiveSize = chartSize - (padding * 2);

    final left = (size.width - effectiveSize) / 2;
    final top = (size.height - effectiveSize) / 2;
    final right = left + effectiveSize;
    final bottom = top + effectiveSize;
    final centerX = (left + right) / 2;
    final centerY = (top + bottom) / 2;

    // Key points
    final topLeft = Offset(left, top);
    final topRight = Offset(right, top);
    final bottomRight = Offset(right, bottom);
    final bottomLeft = Offset(left, bottom);
    final midTop = Offset(centerX, top);
    final midRight = Offset(right, centerY);
    final midBottom = Offset(centerX, bottom);
    final midLeft = Offset(left, centerY);
    final center = Offset(centerX, centerY);

    // Build local paths if not provided
    final paths =
        housePaths.isNotEmpty
            ? housePaths
            : _buildLocalPaths(
              topLeft,
              topRight,
              bottomRight,
              bottomLeft,
              midTop,
              midRight,
              midBottom,
              midLeft,
              center,
            );

    // Draw background
    final bgPaint = Paint()..color = _surfaceColor;
    final outerRect = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(outerRect, bgPaint);

    // Draw each house compartment - ONLY when selected/pressed
    for (int i = 0; i < 12; i++) {
      final path = paths[i];
      if (path == null) continue;

      final isSelected = selectedHouse == i;
      final isPressed = pressedHouse == i;

      // Draw house fill ONLY when actively selected or pressed
      if (isSelected || isPressed) {
        // Very subtle, soothing fill effect
        final glowPaint =
            Paint()
              ..color = _glowColor.withOpacity(
                isPressed ? 0.12 : glowIntensity * 0.08,
              )
              ..style = PaintingStyle.fill;
        canvas.drawPath(path, glowPaint);

        // Elegant, soft border glow - not harsh
        final borderPaint =
            Paint()
              ..color = _glowColor.withOpacity(isPressed ? 0.7 : 0.5)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5;
        canvas.drawPath(path, borderPaint);

        // Very subtle outer glow - barely visible
        final softGlowPaint =
            Paint()
              ..color = _glowColor.withOpacity(
                isPressed ? 0.15 : glowIntensity * 0.1,
              )
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawPath(path, softGlowPaint);
      }
      // No permanent fill for ascendant house - only text is highlighted
    }

    // Draw all structural lines
    final strokePaint =
        Paint()
          ..color = _strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;

    // Outer square
    canvas.drawRect(outerRect, strokePaint);

    // Diagonals
    canvas.drawLine(topLeft, bottomRight, strokePaint);
    canvas.drawLine(topRight, bottomLeft, strokePaint);

    // Inner diamond
    final diamondPath =
        Path()
          ..moveTo(midTop.dx, midTop.dy)
          ..lineTo(midRight.dx, midRight.dy)
          ..lineTo(midBottom.dx, midBottom.dy)
          ..lineTo(midLeft.dx, midLeft.dy)
          ..close();
    canvas.drawPath(diamondPath, strokePaint);

    // Draw elegant border for selected house (already drawn in loop above)
    // No additional harsh border needed - the subtle glow is sufficient

    // Draw house content (numbers, signs, planets)
    _drawHouseContent(canvas, size, paths);
  }

  Map<int, Path> _buildLocalPaths(
    Offset TL,
    Offset TR,
    Offset BR,
    Offset BL,
    Offset MT,
    Offset MR,
    Offset MB,
    Offset ML,
    Offset C,
  ) {
    final paths = <int, Path>{};

    // Calculate intersection points (P1, P2, P3, P4)
    // These are where diagonals cross the diamond edges
    final quarterW = (TR.dx - TL.dx) / 4;
    final quarterH = (BL.dy - TL.dy) / 4;
    final P1 = Offset(C.dx - quarterW, C.dy - quarterH);
    final P2 = Offset(C.dx + quarterW, C.dy - quarterH);
    final P3 = Offset(C.dx + quarterW, C.dy + quarterH);
    final P4 = Offset(C.dx - quarterW, C.dy + quarterH);

    // House 1 - TOP CENTER KITE
    paths[0] =
        Path()
          ..moveTo(MT.dx, MT.dy)
          ..lineTo(P1.dx, P1.dy)
          ..lineTo(C.dx, C.dy)
          ..lineTo(P2.dx, P2.dy)
          ..close();

    // House 2 - TOP RIGHT TRIANGLE (outer)
    paths[1] =
        Path()
          ..moveTo(MT.dx, MT.dy)
          ..lineTo(TR.dx, TR.dy)
          ..lineTo(P2.dx, P2.dy)
          ..close();

    // House 3 - RIGHT UPPER TRIANGLE (inner)
    paths[2] =
        Path()
          ..moveTo(TR.dx, TR.dy)
          ..lineTo(MR.dx, MR.dy)
          ..lineTo(P2.dx, P2.dy)
          ..close();

    // House 4 - RIGHT CENTER KITE
    paths[3] =
        Path()
          ..moveTo(MR.dx, MR.dy)
          ..lineTo(P2.dx, P2.dy)
          ..lineTo(C.dx, C.dy)
          ..lineTo(P3.dx, P3.dy)
          ..close();

    // House 5 - RIGHT LOWER TRIANGLE (inner)
    paths[4] =
        Path()
          ..moveTo(MR.dx, MR.dy)
          ..lineTo(P3.dx, P3.dy)
          ..lineTo(BR.dx, BR.dy)
          ..close();

    // House 6 - BOTTOM RIGHT TRIANGLE (outer)
    paths[5] =
        Path()
          ..moveTo(BR.dx, BR.dy)
          ..lineTo(P3.dx, P3.dy)
          ..lineTo(MB.dx, MB.dy)
          ..close();

    // House 7 - BOTTOM CENTER KITE
    paths[6] =
        Path()
          ..moveTo(MB.dx, MB.dy)
          ..lineTo(P3.dx, P3.dy)
          ..lineTo(C.dx, C.dy)
          ..lineTo(P4.dx, P4.dy)
          ..close();

    // House 8 - BOTTOM LEFT TRIANGLE (outer)
    paths[7] =
        Path()
          ..moveTo(MB.dx, MB.dy)
          ..lineTo(P4.dx, P4.dy)
          ..lineTo(BL.dx, BL.dy)
          ..close();

    // House 9 - LEFT LOWER TRIANGLE (inner)
    paths[8] =
        Path()
          ..moveTo(BL.dx, BL.dy)
          ..lineTo(P4.dx, P4.dy)
          ..lineTo(ML.dx, ML.dy)
          ..close();

    // House 10 - LEFT CENTER KITE
    paths[9] =
        Path()
          ..moveTo(ML.dx, ML.dy)
          ..lineTo(P4.dx, P4.dy)
          ..lineTo(C.dx, C.dy)
          ..lineTo(P1.dx, P1.dy)
          ..close();

    // House 11 - LEFT UPPER TRIANGLE (inner)
    paths[10] =
        Path()
          ..moveTo(ML.dx, ML.dy)
          ..lineTo(P1.dx, P1.dy)
          ..lineTo(TL.dx, TL.dy)
          ..close();

    // House 12 - TOP LEFT TRIANGLE (outer)
    paths[11] =
        Path()
          ..moveTo(TL.dx, TL.dy)
          ..lineTo(P1.dx, P1.dy)
          ..lineTo(MT.dx, MT.dy)
          ..close();

    return paths;
  }

  void _drawHouseContent(Canvas canvas, Size size, Map<int, Path> paths) {
    final chartSize = math.min(size.width, size.height);
    final padding = chartSize * 0.02;
    final effectiveSize = chartSize - (padding * 2);

    final left = (size.width - effectiveSize) / 2;
    final top = (size.height - effectiveSize) / 2;
    final right = left + effectiveSize;
    final bottom = top + effectiveSize;
    final centerX = (left + right) / 2;
    final centerY = (top + bottom) / 2;

    // Calculate key points for accurate text positioning
    final quarterW = effectiveSize / 4;
    final quarterH = effectiveSize / 4;

    // Intersection points
    final p1x = centerX - quarterW;
    final p1y = centerY - quarterH;
    final p2x = centerX + quarterW;
    final p2y = centerY - quarterH;
    final p3x = centerX + quarterW;
    final p3y = centerY + quarterH;
    final p4x = centerX - quarterW;
    final p4y = centerY + quarterH;

    // Text positions - ANTI-CLOCKWISE from top center (North Indian style)
    // House 1 at top, then 2, 3, 4... going anti-clockwise
    final houseTextPositions = <Offset>[
      // House 1 - TOP CENTER KITE (Lagna/Ascendant - always here!)
      Offset(centerX, (top + p1y + centerY + p2y) / 4 + quarterH * 0.15),
      // House 2 - TOP LEFT TRIANGLE (anti-clockwise from House 1)
      Offset(
        (left + p1x + centerX) / 3,
        (top + p1y + top) / 3 + quarterH * 0.1,
      ),
      // House 3 - LEFT UPPER TRIANGLE
      Offset(
        (left + p1x + left) / 3 + quarterW * 0.15,
        (centerY + p1y + top) / 3,
      ),
      // House 4 - LEFT CENTER KITE
      Offset((left + p4x + centerX + p1x) / 4 - quarterW * 0.1, centerY),
      // House 5 - LEFT LOWER TRIANGLE
      Offset(
        (left + p4x + left) / 3 + quarterW * 0.15,
        (bottom + p4y + centerY) / 3,
      ),
      // House 6 - BOTTOM LEFT TRIANGLE
      Offset(
        (centerX + p4x + left) / 3,
        (bottom + p4y + bottom) / 3 - quarterH * 0.1,
      ),
      // House 7 - BOTTOM CENTER KITE
      Offset(centerX, (bottom + p3y + centerY + p4y) / 4 - quarterH * 0.15),
      // House 8 - BOTTOM RIGHT TRIANGLE
      Offset(
        (right + p3x + centerX) / 3,
        (bottom + p3y + bottom) / 3 - quarterH * 0.1,
      ),
      // House 9 - RIGHT LOWER TRIANGLE
      Offset(
        (right + p3x + right) / 3 - quarterW * 0.15,
        (centerY + p3y + bottom) / 3,
      ),
      // House 10 - RIGHT CENTER KITE
      Offset((right + p2x + centerX + p3x) / 4 + quarterW * 0.1, centerY),
      // House 11 - RIGHT UPPER TRIANGLE
      Offset(
        (right + right + p2x) / 3 - quarterW * 0.15,
        (top + centerY + p2y) / 3,
      ),
      // House 12 - TOP RIGHT TRIANGLE
      Offset(
        (centerX + right + p2x) / 3,
        (top + top + p2y) / 3 + quarterH * 0.1,
      ),
    ];

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // NORTH INDIAN CHART: HOUSE POSITIONS ARE FIXED!
    // - Top-center diamond = ALWAYS House 1 (Lagna/Ascendant house)
    // - Houses go ANTI-CLOCKWISE: 1(top) → 2(top-left) → 3(left-upper) → ... → 12(top-right)
    // - The SIGN NUMBER inside each box changes based on Lagna
    // - houses[0] = House 1 → position 0, houses[1] = House 2 → position 1, etc.
    // - Only the sign numbers move with time/date, not the house positions!

    for (int i = 0; i < 12 && i < houses.length; i++) {
      final house = houses[i];

      // FIXED: House position = array index (House 1 at pos 0, House 2 at pos 1, etc.)
      final visualPosition = i;
      final signIndex = _getSignIndex(house.sign);

      final pos = houseTextPositions[visualPosition];
      final isAscendant =
          i == 0; // House 1 (index 0) is always the Ascendant house
      // Compare with house index for selection
      final isSelected = selectedHouse == i;
      final isPressed = pressedHouse == i;
      final isActive = isSelected || isPressed;

      // Sizes: Planets are PRIMARY (bigger), Signs are SECONDARY (smaller)
      final houseNumSize = chartSize * 0.022;
      final planetSize =
          chartSize * (isActive ? 0.042 : 0.038); // Planets are BIGGER
      final signSize = chartSize * 0.028; // Signs are smaller

      // Layout order (top to bottom): Sign Number → Planets → Sign Name

      // 1. Draw SIGN NUMBER (Aries=1, Taurus=2, ..., Pisces=12) - NOT house number!
      // This is the traditional North Indian convention
      final signNumber =
          signIndex + 1; // signIndex is 0-based, sign number is 1-based
      textPainter.text = TextSpan(
        text: '$signNumber',
        style: TextStyle(
          fontSize: houseNumSize,
          fontWeight: FontWeight.w500,
          color:
              isActive
                  ? _glowColor
                  : (isDarkMode
                      ? Colors.white.withOpacity(0.3)
                      : Colors.black26),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy - planetSize * 1.4),
      );

      // 2. Draw PLANETS (PRIMARY - bigger, prominent, in the middle)
      if (house.planets.isNotEmpty) {
        final planetsText = house.planets.map(_getPlanetSymbol).join(' ');
        textPainter.text = TextSpan(
          text: planetsText,
          style: TextStyle(
            fontSize: planetSize,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : const Color(0xFF60A5FA),
            letterSpacing: 1.2,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            pos.dx - textPainter.width / 2,
            pos.dy - textPainter.height / 2,
          ),
        );

        // 3. Draw zodiac sign BELOW planets (smaller, secondary)
        textPainter.text = TextSpan(
          text: _getSignAbbreviation(house.sign),
          style: TextStyle(
            fontSize: signSize,
            fontWeight: isAscendant ? FontWeight.w600 : FontWeight.w400,
            color:
                isActive
                    ? Colors.white.withOpacity(0.8)
                    : isAscendant
                    ? _accentPrimary
                    : (isDarkMode
                        ? Colors.white.withOpacity(0.5)
                        : Colors.black45),
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(pos.dx - textPainter.width / 2, pos.dy + planetSize * 0.7),
        );
      } else {
        // No planets - show sign with same size and color (consistent)
        textPainter.text = TextSpan(
          text: _getSignAbbreviation(house.sign),
          style: TextStyle(
            fontSize: signSize, // Same size as houses with planets
            fontWeight: isAscendant ? FontWeight.w600 : FontWeight.w400,
            color:
                isActive
                    ? Colors.white.withOpacity(0.8)
                    : isAscendant
                    ? _accentPrimary
                    : (isDarkMode
                        ? Colors.white.withOpacity(0.5)
                        : Colors.black45),
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            pos.dx - textPainter.width / 2,
            pos.dy - textPainter.height / 2,
          ),
        );
      }
    }
  }

  // Dynamic abbreviation - takes first 3 chars of sign name
  String _getSignAbbreviation(String sign) {
    if (sign.isEmpty) return '';
    return sign.length > 3 ? sign.substring(0, 3) : sign;
  }

  // Dynamic abbreviation - takes first 2 chars of planet name
  String _getPlanetSymbol(String planet) {
    if (planet.isEmpty) return '';
    return planet.length > 2 ? planet.substring(0, 2) : planet;
  }

  // Get zodiac sign index (Aries=0, Taurus=1, ..., Pisces=11)
  int _getSignIndex(String sign) {
    const signs = [
      'Aries',
      'Taurus',
      'Gemini',
      'Cancer',
      'Leo',
      'Virgo',
      'Libra',
      'Scorpio',
      'Sagittarius',
      'Capricorn',
      'Aquarius',
      'Pisces',
    ];
    final index = signs.indexWhere(
      (s) => s.toLowerCase() == sign.toLowerCase(),
    );
    return index >= 0 ? index : 0;
  }

  @override
  bool shouldRepaint(covariant _GlowingChartPainter oldDelegate) {
    return houses != oldDelegate.houses ||
        ascendantSign != oldDelegate.ascendantSign ||
        selectedHouse != oldDelegate.selectedHouse ||
        pressedHouse != oldDelegate.pressedHouse ||
        glowIntensity != oldDelegate.glowIntensity;
  }
}

/// Modal for showing house details with beautiful animation
class _HouseDetailModal extends StatelessWidget {
  final House house;
  final int houseIndex;
  final Map<String, PlanetPosition> planetPositions;
  final String ascendantSign;
  final Animation<double> animation;

  const _HouseDetailModal({
    required this.house,
    required this.houseIndex,
    required this.planetPositions,
    required this.ascendantSign,
    required this.animation,
  });

  static const _bgPrimary = Color(0xFF0D0B14);
  static const _surfaceColor = Color(0xFF1A1625);
  static const _borderColor = Color(0xFF2A2438);
  static const _accentPrimary = Color(0xFFD4AF37);
  static const _accentSecondary = Color(0xFF8B5CF6);
  static const _textPrimary = Color(0xFFF1F0F5);
  static const _textSecondary = Color(0xFFB8B5C3);
  static const _textMuted = Color(0xFF6B6478);

  @override
  Widget build(BuildContext context) {
    final isAscendant = house.sign == ascendantSign;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return Stack(
          children: [
            // Backdrop
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.black.withOpacity(0.6 * curvedAnimation.value),
              ),
            ),
            // Modal content - wrapped in Material to prevent text underlines
            Center(
              child: Transform.scale(
                scale: 0.8 + (0.2 * curvedAnimation.value),
                child: Opacity(
                  opacity: curvedAnimation.value,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.88,
                      constraints: const BoxConstraints(
                        maxWidth: 400,
                        maxHeight: 600,
                      ),
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_surfaceColor, _bgPrimary],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _accentPrimary.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _accentPrimary.withOpacity(0.15),
                            blurRadius: 40,
                            spreadRadius: -10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHeader(context, isAscendant),
                              const SizedBox(height: 24),
                              _buildHouseInfo(),
                              if (house.planets.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                _buildPlanetsSection(),
                              ],
                              const SizedBox(height: 20),
                              _buildSignificanceSection(),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isAscendant) {
    return Row(
      children: [
        // House icon with gradient - styled like a diamond
        Hero(
          tag: 'house_${houseIndex}_icon',
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isAscendant ? _accentPrimary : _accentSecondary,
                  (isAscendant ? _accentPrimary : _accentSecondary).withOpacity(
                    0.6,
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (isAscendant ? _accentPrimary : _accentSecondary)
                      .withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${houseIndex + 1}',
                style: GoogleFonts.dmMono(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _bgPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'House ${houseIndex + 1}',
                    style: GoogleFonts.dmSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                  ),
                  if (isAscendant) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _accentPrimary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _accentPrimary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'ASC',
                        style: GoogleFonts.dmMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _accentPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _getHouseName(houseIndex),
                style: GoogleFonts.dmSans(fontSize: 13, color: _textMuted),
              ),
            ],
          ),
        ),
        // Close button
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _borderColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close_rounded, size: 18, color: _textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildHouseInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _borderColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.auto_awesome_rounded,
            label: 'Zodiac Sign',
            value: house.sign,
            valueColor: _accentPrimary,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.straighten_rounded,
            label: 'Cusp Degree',
            value: '${house.cuspDegree.toStringAsFixed(2)}°',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.category_rounded,
            label: 'Element',
            value: _getSignElement(house.sign),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.swap_horiz_rounded,
            label: 'Modality',
            value: _getSignModality(house.sign),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: _textMuted),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.dmSans(fontSize: 13, color: _textMuted),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.public_rounded, size: 16, color: _accentSecondary),
            const SizedBox(width: 8),
            Text(
              'Planets in this House',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...house.planets.map((planet) => _buildPlanetCard(planet)),
      ],
    );
  }

  Widget _buildPlanetCard(String planetName) {
    final position = planetPositions[planetName];
    final symbol = _getPlanetSymbol(planetName);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getPlanetColor(planetName).withOpacity(0.1),
            _getPlanetColor(planetName).withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _getPlanetColor(planetName).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getPlanetColor(planetName).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(
                  fontSize: 20,
                  color: _getPlanetColor(planetName),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planetName,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                if (position != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${position.sign} ${position.signDegree.toStringAsFixed(1)}°',
                    style: GoogleFonts.dmMono(fontSize: 11, color: _textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    position.nakshatra,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: _textMuted.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignificanceSection() {
    final significance = _getHouseSignificance(houseIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.lightbulb_outline_rounded,
              size: 16,
              color: _accentPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              'House Significance',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _accentPrimary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _accentPrimary.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                significance['title']!,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _accentPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                significance['description']!,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  height: 1.5,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Dynamic - takes first 2 chars of planet name
  String _getPlanetSymbol(String planet) {
    if (planet.isEmpty) return '';
    return planet.length > 2 ? planet.substring(0, 2) : planet;
  }

  // Dynamic color generation based on planet name
  Color _getPlanetColor(String planet) {
    // Generate consistent color from planet name hash
    final hash = planet.hashCode;
    final hue = (hash % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor();
  }

  // Dynamic house name
  String _getHouseName(int index) {
    return 'House ${index + 1}';
  }

  // Dynamic - derived from sign name
  String _getSignElement(String sign) {
    return sign.isNotEmpty ? sign : '-';
  }

  // Dynamic - derived from sign name
  String _getSignModality(String sign) {
    return sign.isNotEmpty ? sign : '-';
  }

  // Dynamic house info
  Map<String, String> _getHouseSignificance(int index) {
    return {
      'title': 'House ${index + 1}',
      'description':
          'Information about house ${index + 1} and the sign ${house.sign} placed here.',
    };
  }
}
