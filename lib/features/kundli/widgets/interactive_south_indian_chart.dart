import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/kundali_calculation_service.dart';

/// Interactive South Indian Kundli chart with tappable cells
/// 
/// South Indian Chart Structure:
/// - 4x4 grid with center 2x2 merged (12 outer cells)
/// - Signs are FIXED in position
/// - Houses ROTATE based on ascendant sign
/// - Sign order (clockwise from Aries): Ari→Tau→Gem→Can→Leo→Vir→Lib→Sco→Sag→Cap→Aqu→Pis
class InteractiveSouthIndianChart extends StatefulWidget {
  final List<House> houses;
  final Map<String, PlanetPosition> planetPositions;
  final String ascendantSign;
  final bool isDarkMode;

  const InteractiveSouthIndianChart({
    super.key,
    required this.houses,
    required this.planetPositions,
    required this.ascendantSign,
    this.isDarkMode = true,
  });

  @override
  State<InteractiveSouthIndianChart> createState() => _InteractiveSouthIndianChartState();
}

class _InteractiveSouthIndianChartState extends State<InteractiveSouthIndianChart>
    with SingleTickerProviderStateMixin {
  int? _selectedHouse;
  int? _pressedHouse;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Fixed sign positions in South Indian chart (clockwise from top-left)
  // Grid positions: [row, col] for each zodiac sign index (0=Aries to 11=Pisces)
  static const List<String> _signOrder = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  // Cell positions for each sign in 4x4 grid (row, col)
  // Going clockwise from Pisces at top-left
  static const Map<String, List<int>> _signCellPositions = {
    'Pisces': [0, 0],
    'Aries': [0, 1],
    'Taurus': [0, 2],
    'Gemini': [0, 3],
    'Cancer': [1, 3],
    'Leo': [2, 3],
    'Virgo': [3, 3],
    'Libra': [3, 2],
    'Scorpio': [3, 1],
    'Sagittarius': [3, 0],
    'Capricorn': [2, 0],
    'Aquarius': [1, 0],
  };

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.4, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  // Get house number for a given sign based on ascendant
  int _getHouseNumberForSign(String sign) {
    final ascIndex = _signOrder.indexOf(widget.ascendantSign);
    final signIndex = _signOrder.indexOf(sign);
    if (ascIndex == -1 || signIndex == -1) return 0;
    
    // House 1 is at ascendant sign, then proceed clockwise
    int houseNum = (signIndex - ascIndex) % 12;
    if (houseNum < 0) houseNum += 12;
    return houseNum + 1; // 1-indexed
  }

  // Get house data by house number
  House? _getHouseByNumber(int houseNumber) {
    if (houseNumber < 1 || houseNumber > 12) return null;
    return widget.houses.firstWhere(
      (h) => h.number == houseNumber,
      orElse: () => widget.houses[houseNumber - 1],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        
        return AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _SouthIndianGridPainter(
                  isDarkMode: widget.isDarkMode,
                ),
                child: _buildInteractiveGrid(size),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInteractiveGrid(double size) {
    final cellSize = size / 4;
    
    return Stack(
      children: [
        // Build 12 tappable cells for signs
        ..._signCellPositions.entries.map((entry) {
          final sign = entry.key;
          final pos = entry.value;
          final row = pos[0];
          final col = pos[1];
          final houseNum = _getHouseNumberForSign(sign);
          final house = _getHouseByNumber(houseNum);
          
          return Positioned(
            left: col * cellSize,
            top: row * cellSize,
            width: cellSize,
            height: cellSize,
            child: _buildCell(
              sign: sign,
              houseNumber: houseNum,
              house: house,
              cellSize: cellSize,
            ),
          );
        }),
        
        // Center area (2x2 merged cells) - not tappable
        Positioned(
          left: cellSize,
          top: cellSize,
          width: cellSize * 2,
          height: cellSize * 2,
          child: _buildCenterArea(cellSize * 2),
        ),
      ],
    );
  }

  Widget _buildCell({
    required String sign,
    required int houseNumber,
    required House? house,
    required double cellSize,
  }) {
    final isSelected = _selectedHouse == houseNumber;
    final isPressed = _pressedHouse == houseNumber;
    final isAscendant = sign == widget.ascendantSign;
    final isActive = isSelected || isPressed;
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressedHouse = houseNumber);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() {
          _pressedHouse = null;
          _selectedHouse = houseNumber;
        });
        if (house != null) {
          _showHouseDetails(context, house, houseNumber - 1);
        }
      },
      onTapCancel: () => setState(() => _pressedHouse = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFD4AF37).withOpacity(_glowAnimation.value * 0.15)
              : Colors.transparent,
          border: isActive
              ? Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.6),
                  width: 1.5,
                )
              : null,
        ),
        child: _buildCellContent(
          sign: sign,
          houseNumber: houseNumber,
          house: house,
          isAscendant: isAscendant,
          isActive: isActive,
          cellSize: cellSize,
        ),
      ),
    );
  }

  Widget _buildCellContent({
    required String sign,
    required int houseNumber,
    required House? house,
    required bool isAscendant,
    required bool isActive,
    required double cellSize,
  }) {
    final planets = house?.planets ?? [];
    final hasPlanets = planets.isNotEmpty;
    
    final fontSize = cellSize * 0.15;
    final smallFontSize = cellSize * 0.11;
    
    return Padding(
      padding: EdgeInsets.all(cellSize * 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Planets (if any) - PRIMARY
          if (hasPlanets) ...[
            Text(
              planets.map((p) => p.length > 2 ? p.substring(0, 2) : p).join(' '),
              style: GoogleFonts.dmSans(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : const Color(0xFF60A5FA),
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: cellSize * 0.02),
          ],
          
          // Sign abbreviation
          Text(
            sign.length > 3 ? sign.substring(0, 3) : sign,
            style: GoogleFonts.dmSans(
              fontSize: hasPlanets ? smallFontSize : fontSize,
              fontWeight: isAscendant ? FontWeight.w600 : FontWeight.w400,
              color: isActive
                  ? Colors.white.withOpacity(0.9)
                  : isAscendant
                      ? const Color(0xFFD4AF37)
                      : Colors.white.withOpacity(hasPlanets ? 0.5 : 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: cellSize * 0.02),
          
          // House number
          Text(
            '$houseNumber',
            style: GoogleFonts.dmMono(
              fontSize: smallFontSize * 0.9,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? const Color(0xFFD4AF37)
                  : Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterArea(double size) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1625),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
      ),
    );
  }

  void _showHouseDetails(BuildContext context, House house, int houseIndex) {
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
      ),
    );
  }
}

/// Painter for South Indian grid lines
class _SouthIndianGridPainter extends CustomPainter {
  final bool isDarkMode;

  _SouthIndianGridPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 4;
    
    final strokePaint = Paint()
      ..color = isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final bgPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF1A1625) : Colors.white
      ..style = PaintingStyle.fill;

    // Draw background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw outer border
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), strokePaint);

    // Draw vertical lines
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(cellSize * i, 0),
        Offset(cellSize * i, size.height),
        strokePaint,
      );
    }

    // Draw horizontal lines
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(0, cellSize * i),
        Offset(size.width, cellSize * i),
        strokePaint,
      );
    }

    // Draw center box border (2x2 area)
    final centerRect = Rect.fromLTWH(cellSize, cellSize, cellSize * 2, cellSize * 2);
    canvas.drawRect(centerRect, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SouthIndianGridPainter oldDelegate) {
    return isDarkMode != oldDelegate.isDarkMode;
  }
}

/// Modal for showing house details
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
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.black.withOpacity(0.6 * curvedAnimation.value),
              ),
            ),
            Center(
              child: Transform.scale(
                scale: 0.8 + (0.2 * curvedAnimation.value),
                child: Opacity(
                  opacity: curvedAnimation.value,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.88,
                      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 550),
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
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isAscendant ? _accentPrimary : _accentSecondary,
                (isAscendant ? _accentPrimary : _accentSecondary).withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _accentPrimary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _accentPrimary.withOpacity(0.3)),
                      ),
                      child: Text(
                        'ASC',
                        style: GoogleFonts.dmMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _accentPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'House ${houseIndex + 1}',
                style: GoogleFonts.dmSans(fontSize: 13, color: _textMuted),
              ),
            ],
          ),
        ),
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
          child: Text(label, style: GoogleFonts.dmSans(fontSize: 13, color: _textMuted)),
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
    final symbol = planetName.length > 2 ? planetName.substring(0, 2) : planetName;
    final color = _getPlanetColor(planetName);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.03)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
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
                  Text(
                    position.nakshatra,
                    style: GoogleFonts.dmSans(fontSize: 10, color: _textMuted.withOpacity(0.7)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPlanetColor(String planet) {
    final hash = planet.hashCode;
    final hue = (hash % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor();
  }
}

