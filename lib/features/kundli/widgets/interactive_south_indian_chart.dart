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
    final planetCount = planets.length;
    
    // Base font sizes - larger for better readability
    final baseFontSize = cellSize * 0.15;
    final signFontSize = cellSize * 0.12;
    final houseNumSize = cellSize * 0.10;
    
    // Planet font size - stays readable for 1-3 planets, scales down for more
    double planetFontSize;
    if (planetCount <= 3) {
      // Normal readable size for 1-3 planets
      planetFontSize = cellSize * 0.14;
    } else if (planetCount <= 5) {
      // Slightly smaller for 4-5 planets
      planetFontSize = cellSize * 0.12;
    } else {
      // Smallest for 6+ planets (rare case)
      planetFontSize = cellSize * 0.10;
    }
    
    return Padding(
      padding: EdgeInsets.all(cellSize * 0.06),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Planets (if any) - PRIMARY
          if (hasPlanets) ...[
            Flexible(
              child: _buildPlanetsDisplay(
                planets: planets,
                fontSize: planetFontSize,
                isActive: isActive,
                cellSize: cellSize,
              ),
            ),
            SizedBox(height: cellSize * 0.02),
          ],
          
          // Sign abbreviation
          Text(
            sign.length > 3 ? sign.substring(0, 3) : sign,
            style: GoogleFonts.dmSans(
              fontSize: hasPlanets ? signFontSize : baseFontSize,
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
              fontSize: houseNumSize,
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

  /// Builds the planets display with proper sizing
  /// - 1-3 planets: Full readable size with normal line height
  /// - 4+ planets: Slightly reduced line height, scales down to fit
  Widget _buildPlanetsDisplay({
    required List<String> planets,
    required double fontSize,
    required bool isActive,
    required double cellSize,
  }) {
    final planetCount = planets.length;
    
    // Adjust line height based on planet count - keeping decent spacing
    double lineHeight;
    double spacing;
    double runSpacing;
    
    if (planetCount <= 3) {
      lineHeight = 1.3;   // Normal comfortable line height
      spacing = 4;
      runSpacing = 2;
    } else if (planetCount <= 5) {
      lineHeight = 1.15;  // Slightly tighter but still readable
      spacing = 3;
      runSpacing = 1;
    } else {
      lineHeight = 1.05;  // Compact but still has decent spacing
      spacing = 3;
      runSpacing = 0;
    }
    
    // Build planet abbreviations with adjusted line height
    final planetWidgets = planets.map((p) {
      final abbr = p.length > 2 ? p.substring(0, 2) : p;
      return Text(
        abbr,
        style: GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: lineHeight,
          color: isActive ? Colors.white : const Color(0xFF60A5FA),
        ),
      );
    }).toList();
    
    // For 1-3 planets, use normal Wrap without scaling
    if (planetCount <= 3) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: spacing,
        runSpacing: runSpacing,
        children: planetWidgets,
      );
    }
    
    // For 4+ planets, use FittedBox to ensure it fits within bounds
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: cellSize * 0.85,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: spacing,
          runSpacing: runSpacing,
          children: planetWidgets,
        ),
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

/// Premium compact modal for showing house details
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
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.black.withOpacity(0.75 * curvedAnimation.value),
              ),
            ),
            Center(
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - curvedAnimation.value)),
                child: Opacity(
                  opacity: curvedAnimation.value,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      constraints: const BoxConstraints(maxWidth: 380, maxHeight: 520),
                      decoration: BoxDecoration(
                        color: _bgPrimary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _borderColor, width: 1),
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
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accentColor, accentColor.withOpacity(0.7)],
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
    final symbol = planetName.length > 2 ? planetName.substring(0, 2) : planetName;

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
              decoration: const BoxDecoration(
                color: _textMuted,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              position.nakshatra,
              style: GoogleFonts.inter(fontSize: 10, color: _textMuted),
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

  String _getPlanetImagePath(String planet) {
    return 'assets/images/planets/${planet.toLowerCase()}.png';
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

