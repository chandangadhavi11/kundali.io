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
  final Map<String, String>? planetAbbreviations;
  final Map<String, String>? signAbbreviations;

  const InteractiveKundliChart({
    super.key,
    required this.houses,
    required this.planetPositions,
    required this.ascendantSign,
    this.chartStyle = ChartStyle.northIndian,
    this.isDarkMode = true,
    this.planetAbbreviations,
    this.signAbbreviations,
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
                  planetAbbreviations: widget.planetAbbreviations,
                  signAbbreviations: widget.signAbbreviations,
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
  final Map<String, String>? planetAbbreviations;
  final Map<String, String>? signAbbreviations;

  _GlowingChartPainter({
    required this.houses,
    required this.ascendantSign,
    required this.isDarkMode,
    this.selectedHouse,
    this.pressedHouse,
    required this.glowIntensity,
    required this.housePaths,
    this.planetAbbreviations,
    this.signAbbreviations,
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
      final signSize = chartSize * 0.028; // Signs are smaller
      
      // Planet size based on count - stays readable for 1-3 planets
      final planetCount = house.planets.length;
      double planetSize;
      double lineHeight;
      if (planetCount <= 3) {
        // Normal readable size for 1-3 planets
        planetSize = chartSize * (isActive ? 0.042 : 0.038);
        lineHeight = 1.3;
      } else if (planetCount <= 5) {
        // Slightly smaller for 4-5 planets
        planetSize = chartSize * (isActive ? 0.036 : 0.032);
        lineHeight = 1.15;
      } else {
        // Smallest for 6+ planets (rare case)
        planetSize = chartSize * (isActive ? 0.030 : 0.026);
        lineHeight = 1.05;
      }

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
        // For many planets, split into multiple lines
        if (planetCount > 4) {
          // Split planets into two lines for better fit
          final midPoint = (planetCount / 2).ceil();
          final line1 = house.planets.sublist(0, midPoint).map(_getPlanetSymbol).join(' ');
          final line2 = house.planets.sublist(midPoint).map(_getPlanetSymbol).join(' ');
          
          // Draw first line
          textPainter.text = TextSpan(
            text: line1,
            style: TextStyle(
              fontSize: planetSize,
              fontWeight: FontWeight.w700,
              height: lineHeight,
              color: isActive ? Colors.white : const Color(0xFF60A5FA),
              letterSpacing: 0.8,
            ),
          );
          textPainter.layout();
          final lineSpacing = planetSize * lineHeight * 0.5;
          textPainter.paint(
            canvas,
            Offset(
              pos.dx - textPainter.width / 2,
              pos.dy - textPainter.height - lineSpacing * 0.3,
            ),
          );
          
          // Draw second line
          textPainter.text = TextSpan(
            text: line2,
            style: TextStyle(
              fontSize: planetSize,
              fontWeight: FontWeight.w700,
              height: lineHeight,
              color: isActive ? Colors.white : const Color(0xFF60A5FA),
              letterSpacing: 0.8,
            ),
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(
              pos.dx - textPainter.width / 2,
              pos.dy + lineSpacing * 0.3,
            ),
          );
        } else {
          // Single line for 1-4 planets
          final planetsText = house.planets.map(_getPlanetSymbol).join(' ');
          textPainter.text = TextSpan(
            text: planetsText,
            style: TextStyle(
              fontSize: planetSize,
              fontWeight: FontWeight.w700,
              height: lineHeight,
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
        }

        // 3. Draw zodiac sign BELOW planets (smaller, secondary)
        final signOffsetY = planetCount > 4 ? planetSize * 1.2 : planetSize * 0.7;
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
          Offset(pos.dx - textPainter.width / 2, pos.dy + signOffsetY),
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

  // Dynamic abbreviation - uses localized map or takes first 3 chars of sign name
  String _getSignAbbreviation(String sign) {
    if (sign.isEmpty) return '';
    if (signAbbreviations != null && signAbbreviations!.containsKey(sign)) {
      return signAbbreviations![sign]!;
    }
    return sign.length > 3 ? sign.substring(0, 3) : sign;
  }

  // Dynamic abbreviation - uses localized map or takes first 2 chars of planet name
  String _getPlanetSymbol(String planet) {
    if (planet.isEmpty) return '';
    if (planetAbbreviations != null && planetAbbreviations!.containsKey(planet)) {
      return planetAbbreviations![planet]!;
    }
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

  static const _bgPrimary = Color(0xFF0A0910);
  static const _surfaceColor = Color(0xFF141220);
  static const _borderColor = Color(0xFF1F1B2E);
  static const _accentPrimary = Color(0xFFD4AF37);
  static const _accentSecondary = Color(0xFF8B5CF6);
  static const _textPrimary = Color(0xFFF5F4F8);
  static const _textSecondary = Color(0xFFA8A4B8);
  static const _textMuted = Color(0xFF5A5568);

  @override
  Widget build(BuildContext context) {
    final isAscendant = house.sign == ascendantSign;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuint,
        );

        return Stack(
          children: [
            // Backdrop with blur effect
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.black.withOpacity(0.75 * curvedAnimation.value),
              ),
            ),
            // Modal content
            Center(
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - curvedAnimation.value)),
                child: Opacity(
                  opacity: curvedAnimation.value,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      constraints: const BoxConstraints(
                        maxWidth: 380,
                        maxHeight: 520,
                      ),
                      decoration: BoxDecoration(
                        color: _bgPrimary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _borderColor,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: _accentSecondary.withOpacity(0.05),
                            blurRadius: 60,
                            spreadRadius: -20,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHeader(context, isAscendant),
                              const SizedBox(height: 16),
                              _buildHouseInfo(),
                              if (house.planets.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                _buildPlanetsSection(),
                              ],
                              const SizedBox(height: 14),
                              _buildSignificanceSection(),
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
    final accentColor = isAscendant ? _accentPrimary : _accentSecondary;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Compact house icon
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor,
                accentColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '${houseIndex + 1}',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _bgPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'House ${houseIndex + 1}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (isAscendant) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: _accentPrimary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ASC',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: _accentPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                _getHouseTheme(houseIndex),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: _textMuted,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        // Minimal close button
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _borderColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.close_rounded, size: 14, color: _textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildHouseInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildCompactInfoTile(
            label: 'Sign',
            value: house.sign,
            valueColor: _accentPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildCompactInfoTile(
            label: 'Cusp',
            value: '${house.cuspDegree.toStringAsFixed(1)}°',
          ),
        ),
      ],
    );
  }

  Widget _buildCompactInfoTile({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: _textMuted,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: valueColor ?? _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            'PLANETS',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...house.planets.map((planet) => _buildPlanetRow(planet)),
      ],
    );
  }

  Widget _buildPlanetRow(String planetName) {
    final position = planetPositions[planetName];
    final color = _getPlanetColor(planetName);
    final symbol = _getPlanetSymbol(planetName);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          // Planet image with premium shadow
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                // Soft ambient shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  spreadRadius: -2,
                  offset: const Offset(0, 3),
                ),
                // Color accent glow
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: -3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                _getPlanetImagePath(planetName),
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to symbol if image fails
                  return Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        symbol,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Planet name
          Expanded(
            child: Text(
              planetName,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _textPrimary,
              ),
            ),
          ),
          // Position info - inline
          if (position != null) ...[
            Text(
              '${position.sign} ${position.signDegree.toStringAsFixed(1)}°',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _textSecondary,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: _textMuted,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              position.nakshatra,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: _textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSignificanceSection() {
    final significance = _getHouseSignificance(houseIndex);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _accentPrimary.withOpacity(0.06),
            _accentPrimary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _accentPrimary.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 14,
            color: _accentPrimary.withOpacity(0.7),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  significance['title']!,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _accentPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  significance['description']!,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    height: 1.4,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPlanetSymbol(String planet) {
    if (planet.isEmpty) return '';
    return planet.length > 2 ? planet.substring(0, 2) : planet;
  }

  String _getPlanetImagePath(String planet) {
    return 'assets/images/planets/${planet.toLowerCase()}.png';
  }

  Color _getPlanetColor(String planet) {
    const colors = {
      'Sun': Color(0xFFD4AF37),
      'Moon': Color(0xFF6EE7B7),
      'Mars': Color(0xFFF87171),
      'Mercury': Color(0xFF34D399),
      'Jupiter': Color(0xFFFBBF24),
      'Venus': Color(0xFFF472B6),
      'Saturn': Color(0xFF9CA3AF),
      'Uranus': Color(0xFF22D3EE),
      'Neptune': Color(0xFF818CF8),
      'Pluto': Color(0xFF94A3B8),
      'Rahu': Color(0xFFA78BFA),
      'Ketu': Color(0xFFC2410C),
    };
    return colors[planet] ?? const Color(0xFF9CA3AF);
  }

  String _getHouseTheme(int index) {
    const themes = [
      'Self & Identity',
      'Wealth & Values',
      'Communication',
      'Home & Roots',
      'Creativity & Romance',
      'Health & Service',
      'Partnerships',
      'Transformation',
      'Philosophy & Fortune',
      'Career & Status',
      'Aspirations & Gains',
      'Spirituality & Endings',
    ];
    return index < themes.length ? themes[index] : '';
  }

  Map<String, String> _getHouseSignificance(int index) {
    const significances = [
      {'title': 'Lagna Bhava', 'description': 'Physical body, personality, vitality, and overall life path.'},
      {'title': 'Dhana Bhava', 'description': 'Accumulated wealth, family, speech, and early childhood.'},
      {'title': 'Sahaja Bhava', 'description': 'Siblings, courage, short journeys, and communication skills.'},
      {'title': 'Sukha Bhava', 'description': 'Mother, home, emotional peace, and domestic happiness.'},
      {'title': 'Putra Bhava', 'description': 'Children, creativity, intelligence, and romance.'},
      {'title': 'Shatru Bhava', 'description': 'Enemies, health issues, debts, and daily work.'},
      {'title': 'Kalatra Bhava', 'description': 'Marriage, partnerships, and business relationships.'},
      {'title': 'Randhra Bhava', 'description': 'Longevity, inheritance, occult, and transformation.'},
      {'title': 'Dharma Bhava', 'description': 'Fortune, higher learning, spirituality, and father.'},
      {'title': 'Karma Bhava', 'description': 'Career, reputation, authority, and public image.'},
      {'title': 'Labha Bhava', 'description': 'Gains, income, elder siblings, and social networks.'},
      {'title': 'Vyaya Bhava', 'description': 'Losses, expenses, foreign lands, and liberation.'},
    ];
    return index < significances.length 
        ? significances[index] 
        : {'title': 'House ${index + 1}', 'description': ''};
  }
}
