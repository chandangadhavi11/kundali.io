import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/kundali_data_model.dart';
import '../../../core/providers/kundli_provider.dart';
import '../../../core/services/kundali_calculation_service.dart';
import '../widgets/kundali_chart_painter.dart';
import '../widgets/chart_style_selector.dart';
import '../widgets/interactive_kundli_chart.dart';
import '../widgets/interactive_south_indian_chart.dart';

class KundliDisplayScreen extends StatefulWidget {
  final KundaliData? kundaliData;

  const KundliDisplayScreen({super.key, this.kundaliData});

  @override
  State<KundliDisplayScreen> createState() => _KundliDisplayScreenState();
}

class _KundliDisplayScreenState extends State<KundliDisplayScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late ChartStyle _currentChartStyle;
  KundaliType _currentChartType = KundaliType.lagna;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  KundaliData? _effectiveKundaliData;
  KundaliData? get _kundaliData => _effectiveKundaliData ?? widget.kundaliData;

  // Cached divisional chart data
  List<House>? _currentHouses;
  Map<String, PlanetPosition>? _currentPlanetPositions;
  String? _currentAscendantSign;

  // Tap states for microinteractions
  final Map<String, bool> _pressedStates = {};

  // Color palette - Refined cosmic theme
  static const _bgPrimary = Color(0xFF0D0B14);
  static const _bgSecondary = Color(0xFF131020);
  static const _surfaceColor = Color(0xFF1A1625);
  static const _borderColor = Color(0xFF2A2438);
  static const _accentPrimary = Color(0xFFD4AF37);
  static const _accentSecondary = Color(0xFFA78BFA);
  static const _textPrimary = Color(0xFFF8F7FC);
  static const _textSecondary = Color(0xFF9B95A8);
  static const _textMuted = Color(0xFF6B6478);

  @override
  void initState() {
    super.initState();
    _effectiveKundaliData = widget.kundaliData;
    _currentChartStyle = _kundaliData?.chartStyle ?? ChartStyle.northIndian;
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);
    _initializeAnimations();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    setState(() {});
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_effectiveKundaliData == null) {
      final provider = context.read<KundliProvider>();
      if (provider.savedKundalis.isNotEmpty) {
        _effectiveKundaliData = provider.savedKundalis.first;
        _currentChartStyle = _kundaliData?.chartStyle ?? ChartStyle.northIndian;
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _setPressed(String key, bool value) {
    setState(() => _pressedStates[key] = value);
  }

  bool _isPressed(String key) => _pressedStates[key] ?? false;

  @override
  Widget build(BuildContext context) {
    if (_kundaliData == null) {
      return Scaffold(
        backgroundColor: _bgPrimary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: _accentPrimary,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading chart...',
                style: GoogleFonts.dmSans(fontSize: 13, color: _textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bgPrimary,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildChartTab(),
                          _buildPlanetsTab(),
                          _buildHousesTab(),
                          _buildDashaTab(),
                          _buildYogasTab(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF12101B), _bgPrimary, Color(0xFF0A080F)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _accentSecondary.withOpacity(0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 150,
          left: -60,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_accentPrimary.withOpacity(0.04), Colors.transparent],
              ),
            ),
          ),
        ),
        // Subtle noise texture
        Positioned.fill(
          child: Opacity(
            opacity: 0.012,
            child: CustomPaint(painter: _NoisePainter()),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back button
          _buildIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 14),
          // Name and details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _kundaliData!.name,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_kundaliData!.isPrimary) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _accentPrimary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 8,
                              color: _accentPrimary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Primary',
                              style: GoogleFonts.dmSans(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: _accentPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 10, color: _textMuted),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        _kundaliData!.birthPlace,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: _textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.schedule_outlined, size: 10, color: _textMuted),
                    const SizedBox(width: 2),
                    Text(
                      DateFormat(
                        'd MMM, h:mm a',
                      ).format(_kundaliData!.birthDateTime),
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action buttons
          _buildIconButton(icon: Icons.ios_share_rounded, onTap: _shareKundali),
          const SizedBox(width: 6),
          _buildIconButton(
            icon: Icons.more_horiz_rounded,
            onTap: () => _showOptionsMenu(context),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final key = 'icon_${icon.hashCode}';
    return GestureDetector(
      onTapDown: (_) => _setPressed(key, true),
      onTapUp: (_) => _setPressed(key, false),
      onTapCancel: () => _setPressed(key, false),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedScale(
        scale: _isPressed(key) ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _surfaceColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _borderColor.withOpacity(0.4),
              width: 0.5,
            ),
          ),
          child: Icon(icon, size: 15, color: _textSecondary),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      {'icon': Icons.grid_view_rounded, 'label': 'Chart'},
      {'icon': Icons.public_rounded, 'label': 'Planets'},
      {'icon': Icons.home_work_outlined, 'label': 'Houses'},
      {'icon': Icons.timeline_rounded, 'label': 'Dasha'},
      {'icon': Icons.auto_awesome_rounded, 'label': 'Yogas'},
    ];

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = _tabController.index == index;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _tabController.animateTo(index);
              setState(() {});
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.only(right: index < tabs.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _accentSecondary.withOpacity(0.18),
                            _accentSecondary.withOpacity(0.08),
                          ],
                        )
                        : null,
                color: isSelected ? null : _surfaceColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      isSelected
                          ? _accentSecondary.withOpacity(0.3)
                          : _borderColor.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab['icon'] as IconData,
                    size: 14,
                    color: isSelected ? _accentSecondary : _textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tab['label'] as String,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? _accentSecondary : _textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartTab() {
    // Update chart data when type changes
    _updateChartDataForMainScreen();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart Type Selector (horizontal scroll)
          _buildChartTypeHeader(),
          const SizedBox(height: 12),
          _buildChartCard(),
          const SizedBox(height: 14),
          _buildChartStyleSelector(),
          const SizedBox(height: 20),
          _buildQuickStats(),
          const SizedBox(height: 20),
          _buildBasicInfo(),
        ],
      ),
    );
  }

  void _updateChartDataForMainScreen() {
    if (_kundaliData == null) return;

    switch (_currentChartType) {
      case KundaliType.lagna:
        _currentHouses = _kundaliData!.houses;
        _currentPlanetPositions = _kundaliData!.planetPositions;
        _currentAscendantSign = _kundaliData!.ascendant.sign;
        break;
      case KundaliType.chandra:
        _currentHouses = KundaliCalculationService.calculateChandraChart(
          _kundaliData!.planetPositions,
        );
        _currentPlanetPositions = _kundaliData!.planetPositions;
        _currentAscendantSign = _kundaliData!.moonSign;
        break;
      case KundaliType.surya:
        _currentHouses = KundaliCalculationService.calculateSuryaChart(
          _kundaliData!.planetPositions,
        );
        _currentPlanetPositions = _kundaliData!.planetPositions;
        _currentAscendantSign = _kundaliData!.sunSign;
        break;
      case KundaliType.navamsa:
        final navamsaPositions =
            _kundaliData!.navamsaChart ??
            KundaliCalculationService.calculateNavamsaChart(
              _kundaliData!.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          navamsaPositions,
          _kundaliData!.ascendant.longitude,
          9,
        );
        _currentPlanetPositions = navamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.dasamsa:
        final dasamsaPositions =
            KundaliCalculationService.calculateDasamsaChart(
              _kundaliData!.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          dasamsaPositions,
          _kundaliData!.ascendant.longitude,
          10,
        );
        _currentPlanetPositions = dasamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.saptamsa:
        final saptamsaPositions =
            KundaliCalculationService.calculateSaptamsaChart(
              _kundaliData!.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          saptamsaPositions,
          _kundaliData!.ascendant.longitude,
          7,
        );
        _currentPlanetPositions = saptamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.dwadasamsa:
        final dwadasamsaPositions =
            KundaliCalculationService.calculateDwadasamsaChart(
              _kundaliData!.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          dwadasamsaPositions,
          _kundaliData!.ascendant.longitude,
          12,
        );
        _currentPlanetPositions = dwadasamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.trimshamsa:
        final trimshamsaPositions =
            KundaliCalculationService.calculateTrimshamsaChart(
              _kundaliData!.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          trimshamsaPositions,
          _kundaliData!.ascendant.longitude,
          30,
        );
        _currentPlanetPositions = trimshamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
    }
  }

  Widget _buildChartTypeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_mosaic_rounded,
                    size: 14,
                    color: _textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Chart Type',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _textMuted,
                    ),
                  ),
                ],
              ),
              // Current type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _accentPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _accentPrimary.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentChartType.shortName,
                      style: GoogleFonts.dmMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: _accentPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _currentChartType.displayName,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _accentPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Horizontal scrolling chart type cards
        SizedBox(
          height: 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: KundaliType.values.length,
            itemBuilder: (context, index) {
              final type = KundaliType.values[index];
              final isSelected = _currentChartType == type;

              return _buildChartTypeCard(type, isSelected, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChartTypeCard(KundaliType type, bool isSelected, int index) {
    final key = 'chart_type_${type.name}';
    final accentColor = _getChartTypeColor(type);

    return GestureDetector(
      onTapDown: (_) => _setPressed(key, true),
      onTapUp: (_) => _setPressed(key, false),
      onTapCancel: () => _setPressed(key, false),
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _currentChartType = type);
      },
      child: AnimatedScale(
        scale: _isPressed(key) ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 76,
          margin: EdgeInsets.only(
            right: index < KundaliType.values.length - 1 ? 10 : 0,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withOpacity(0.2),
                        accentColor.withOpacity(0.08),
                      ],
                    )
                    : null,
            color: isSelected ? null : _surfaceColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  isSelected
                      ? accentColor.withOpacity(0.4)
                      : _borderColor.withOpacity(0.3),
              width: isSelected ? 1 : 0.5,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: accentColor.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                    : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? accentColor.withOpacity(0.2)
                              : _borderColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      _getChartTypeIcon(type),
                      size: 16,
                      color: isSelected ? accentColor : _textMuted,
                    ),
                  ),
                  // Short name badge
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? accentColor
                                : _borderColor.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        type.shortName,
                        style: GoogleFonts.dmMono(
                          fontSize: 6,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? _bgPrimary : _textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Name
              Text(
                type.displayName,
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? _textPrimary : _textMuted,
                  letterSpacing: 0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getChartTypeIcon(KundaliType type) {
    switch (type) {
      case KundaliType.lagna:
        return Icons.north_east_rounded;
      case KundaliType.chandra:
        return Icons.nightlight_round;
      case KundaliType.surya:
        return Icons.wb_sunny_rounded;
      case KundaliType.navamsa:
        return Icons.favorite_rounded;
      case KundaliType.dasamsa:
        return Icons.work_rounded;
      case KundaliType.saptamsa:
        return Icons.child_care_rounded;
      case KundaliType.dwadasamsa:
        return Icons.people_rounded;
      case KundaliType.trimshamsa:
        return Icons.warning_amber_rounded;
    }
  }

  Color _getChartTypeColor(KundaliType type) {
    switch (type) {
      case KundaliType.lagna:
        return _accentSecondary;
      case KundaliType.chandra:
        return const Color(0xFF6EE7B7);
      case KundaliType.surya:
        return _accentPrimary;
      case KundaliType.navamsa:
        return const Color(0xFFF472B6);
      case KundaliType.dasamsa:
        return const Color(0xFF60A5FA);
      case KundaliType.saptamsa:
        return const Color(0xFFFBBF24);
      case KundaliType.dwadasamsa:
        return const Color(0xFF34D399);
      case KundaliType.trimshamsa:
        return const Color(0xFFF87171);
    }
  }

  Widget _buildChartStyleSelector() {
    return ChartStyleSelector(
      currentStyle: _currentChartStyle,
      onStyleChanged: (style) {
        setState(() => _currentChartStyle = style);
      },
    );
  }

  Widget _buildChartCard() {
    // Use calculated chart data or fallback to lagna
    final houses = _currentHouses ?? _kundaliData!.houses;
    final planets = _currentPlanetPositions ?? _kundaliData!.planetPositions;
    final ascSign = _currentAscendantSign ?? _kundaliData!.ascendant.sign;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor.withOpacity(0.4), width: 0.5),
      ),
      child: Column(
        children: [
          // Header with chart type info and fullscreen button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Chart type info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getChartTypeColor(
                        _currentChartType,
                      ).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getChartTypeIcon(_currentChartType),
                          size: 10,
                          color: _getChartTypeColor(_currentChartType),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _currentChartType.displayName,
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: _getChartTypeColor(_currentChartType),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.touch_app_rounded,
                    size: 11,
                    color: _textMuted.withOpacity(0.4),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Tap house',
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      color: _textMuted.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
              // Fullscreen button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _openFullscreenChart();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _accentPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _accentPrimary.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fullscreen_rounded,
                        size: 14,
                        color: _accentPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Fullscreen',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _accentPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child:
                  _currentChartStyle == ChartStyle.northIndian
                      ? InteractiveKundliChart(
                        key: ValueKey('north_${_currentChartType.name}'),
                        houses: houses,
                        planetPositions: planets,
                        ascendantSign: ascSign,
                        chartStyle: _currentChartStyle,
                        isDarkMode: true,
                      )
                      : _currentChartStyle == ChartStyle.southIndian
                      ? InteractiveSouthIndianChart(
                        key: ValueKey('south_${_currentChartType.name}'),
                        houses: houses,
                        planetPositions: planets,
                        ascendantSign: ascSign,
                        isDarkMode: true,
                      )
                      : CustomPaint(
                        key: ValueKey('western_${_currentChartType.name}'),
                        // Western style - placeholder
                        painter: SouthIndianChartPainter(
                          houses: houses,
                          planets: planets,
                          ascendantSign: ascSign,
                          isDarkMode: true,
                          textStyle: GoogleFonts.dmSans(color: _textPrimary),
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFullscreenChart() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullscreenChartView(
            kundaliData: _kundaliData!,
            initialChartStyle: _currentChartStyle,
            initialChartType: _currentChartType,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = [
      {
        'icon': Icons.north_east_rounded,
        'label': 'Ascendant',
        'value': _kundaliData!.ascendant.sign,
        'color': _accentSecondary,
      },
      {
        'icon': Icons.nightlight_round,
        'label': 'Moon',
        'value': _kundaliData!.moonSign,
        'color': const Color(0xFF6EE7B7),
      },
      {
        'icon': Icons.wb_sunny_rounded,
        'label': 'Sun',
        'value': _kundaliData!.sunSign,
        'color': _accentPrimary,
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'label': 'Nakshatra',
        'value': _kundaliData!.birthNakshatra,
        'color': const Color(0xFFF472B6),
      },
    ];

    return Row(
      children:
          stats.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;
            return Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400 + (index * 80)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 10 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (stat['color'] as Color).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (stat['color'] as Color).withOpacity(0.12),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        stat['icon'] as IconData,
                        size: 16,
                        color: stat['color'] as Color,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stat['value'] as String,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stat['label'] as String,
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildBasicInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor.withOpacity(0.4), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: _textMuted),
              const SizedBox(width: 6),
              Text(
                'Birth Details',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Date',
            DateFormat('EEEE, d MMMM yyyy').format(_kundaliData!.birthDateTime),
          ),
          _buildInfoRow(
            'Time',
            DateFormat('h:mm:ss a').format(_kundaliData!.birthDateTime),
          ),
          _buildInfoRow('Place', _kundaliData!.birthPlace),
          _buildInfoRow(
            'Coordinates',
            '${_kundaliData!.latitude.toStringAsFixed(3)}°N, ${_kundaliData!.longitude.toStringAsFixed(3)}°E',
          ),
          _buildInfoRow('Timezone', _kundaliData!.timezone, isLast: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.dmSans(fontSize: 11, color: _textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetsTab() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: _kundaliData!.planetPositions.length,
      itemBuilder: (_, index) {
        final planet = _kundaliData!.planetPositions.values.elementAt(index);
        final color = _getPlanetColor(planet.planet);

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 12 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _surfaceColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _borderColor.withOpacity(0.4),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _getPlanetSymbol(planet.planet),
                      style: TextStyle(fontSize: 16, color: color),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planet.planet,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildPlanetChip(
                            '${planet.sign} ${planet.signDegree.toStringAsFixed(1)}°',
                            _textSecondary,
                          ),
                          const SizedBox(width: 6),
                          _buildPlanetChip(
                            'H${planet.house}',
                            _accentSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              planet.nakshatra,
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: _textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanetChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmMono(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildHousesTab() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: _kundaliData!.houses.length,
      itemBuilder: (_, index) {
        final house = _kundaliData!.houses[index];

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 40)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 12 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _surfaceColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _borderColor.withOpacity(0.4),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _accentSecondary.withOpacity(0.25),
                        _accentSecondary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${house.number}',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _getHouseName(house.number),
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '• ${house.sign}',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                      if (house.planets.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 5,
                          runSpacing: 4,
                          children:
                              house.planets.map((p) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getPlanetColor(p).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    p,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: _getPlanetColor(p),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashaTab() {
    final dasha = _kundaliData!.dashaInfo;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      child: Column(
        children: [
          // Current Dasha Card
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.95 + (0.05 * value),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _accentSecondary.withOpacity(0.15),
                    _accentSecondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _accentSecondary.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _textPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _getPlanetSymbol(dasha.currentMahadasha),
                        style: TextStyle(
                          fontSize: 20,
                          color: _getPlanetColor(dasha.currentMahadasha),
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
                          'Current Mahadasha',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _accentSecondary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dasha.currentMahadasha,
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.hourglass_bottom_rounded,
                              size: 11,
                              color: _textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${dasha.remainingYears.toStringAsFixed(1)} years remaining',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                'Dasha Sequence',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...dasha.sequence.asMap().entries.map((entry) {
            final index = entry.key;
            final period = entry.value;
            final isCurrent = period.planet == dasha.currentMahadasha;

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 350 + (index * 50)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 10 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      isCurrent
                          ? _accentSecondary.withOpacity(0.1)
                          : _surfaceColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        isCurrent
                            ? _accentSecondary.withOpacity(0.3)
                            : _borderColor.withOpacity(0.4),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _getPlanetColor(period.planet).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                        child: Text(
                          _getPlanetSymbol(period.planet),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getPlanetColor(period.planet),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        period.planet,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight:
                              isCurrent ? FontWeight.w600 : FontWeight.w500,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${period.years} years',
                      style: GoogleFonts.dmMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildYogasTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_kundaliData!.yogas.isNotEmpty) ...[
            _buildYogaSection(
              'Yogas Present',
              _kundaliData!.yogas,
              const Color(0xFF6EE7B7),
              Icons.auto_awesome_rounded,
            ),
            const SizedBox(height: 20),
          ],
          if (_kundaliData!.doshas.isNotEmpty) ...[
            _buildYogaSection(
              'Doshas Present',
              _kundaliData!.doshas,
              const Color(0xFFF87171),
              Icons.warning_amber_rounded,
            ),
            const SizedBox(height: 20),
          ],
          _buildInsightsSection(),
        ],
      ),
    );
  }

  Widget _buildYogaSection(
    String title,
    List<String> items,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children:
              items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 60)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.9 + (0.1 * value),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color.withOpacity(0.15),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      item,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildInsightsSection() {
    final insights = [
      {
        'title': 'Personality',
        'desc':
            'Based on your ascendant ${_kundaliData!.ascendant.sign} and Moon sign ${_kundaliData!.moonSign}',
        'icon': Icons.person_outline_rounded,
        'color': _accentSecondary,
      },
      {
        'title': 'Career',
        'desc': 'Your 10th house indicates potential in leadership roles',
        'icon': Icons.work_outline_rounded,
        'color': const Color(0xFF60A5FA),
      },
      {
        'title': 'Relationships',
        'desc': 'Your 7th house suggests harmonious partnerships',
        'icon': Icons.favorite_outline_rounded,
        'color': const Color(0xFFF472B6),
      },
      {
        'title': 'Health',
        'desc': 'Monitor your 6th house ruler for optimal well-being',
        'icon': Icons.favorite_border_rounded,
        'color': const Color(0xFF6EE7B7),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Text(
            'Quick Insights',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...insights.asMap().entries.map((entry) {
          final index = entry.key;
          final insight = entry.value;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 350 + (index * 60)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 10 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: _buildInsightCard(insight),
          );
        }),
      ],
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight) {
    final key = 'insight_${insight['title']}';
    return GestureDetector(
      onTapDown: (_) => _setPressed(key, true),
      onTapUp: (_) => _setPressed(key, false),
      onTapCancel: () => _setPressed(key, false),
      onTap: () => HapticFeedback.lightImpact(),
      child: AnimatedScale(
        scale: _isPressed(key) ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _surfaceColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _borderColor.withOpacity(0.4),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: (insight['color'] as Color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  insight['icon'] as IconData,
                  size: 16,
                  color: insight['color'] as Color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight['title'] as String,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      insight['desc'] as String,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: _textMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: _textMuted.withOpacity(0.5),
              ),
            ],
          ),
        ),
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
      'Rahu': Color(0xFFA78BFA),
      'Ketu': Color(0xFFC2410C),
    };
    return colors[planet] ?? Colors.grey;
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
      'Rahu': '☊',
      'Ketu': '☋',
    };
    return symbols[planet] ?? planet.substring(0, 2);
  }

  String _getHouseName(int n) {
    const names = [
      'Self',
      'Wealth',
      'Siblings',
      'Home',
      'Children',
      'Health',
      'Partner',
      'Transform',
      'Fortune',
      'Career',
      'Gains',
      'Liberation',
    ];
    return names[(n - 1) % 12];
  }

  void _shareKundali() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.ios_share_rounded,
                color: Colors.white,
                size: 12,
              ),
            ),
            const SizedBox(width: 10),
            Text('Share coming soon', style: GoogleFonts.dmSans(fontSize: 13)),
          ],
        ),
        backgroundColor: const Color(0xFF3B82F6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildOptionsSheet(),
    );
  }

  Widget _buildOptionsSheet() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: _bgSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _buildMenuItem(Icons.picture_as_pdf_outlined, 'Export PDF', () {}),
            _buildMenuItem(Icons.star_outline_rounded, 'Set as Primary', () {
              Navigator.pop(context);
              context.read<KundliProvider>().setPrimaryKundali(
                _kundaliData!.id,
              );
              HapticFeedback.mediumImpact();
            }),
            _buildMenuItem(Icons.copy_outlined, 'Duplicate', () {}),
            _buildMenuItem(
              Icons.delete_outline_rounded,
              'Delete',
              () {},
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? const Color(0xFFF87171) : _textPrimary;
    final key = 'menu_$title';

    return GestureDetector(
      onTapDown: (_) => _setPressed(key, true),
      onTapUp: (_) => _setPressed(key, false),
      onTapCancel: () => _setPressed(key, false),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedScale(
        scale: _isPressed(key) ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color.withOpacity(0.8)),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Noise painter for texture
class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..color = Colors.white;

    for (var i = 0; i < 1500; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        0.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Fullscreen Chart View
class _FullscreenChartView extends StatefulWidget {
  final KundaliData kundaliData;
  final ChartStyle initialChartStyle;
  final KundaliType initialChartType;

  const _FullscreenChartView({
    required this.kundaliData,
    required this.initialChartStyle,
    required this.initialChartType,
  });

  @override
  State<_FullscreenChartView> createState() => _FullscreenChartViewState();
}

class _FullscreenChartViewState extends State<_FullscreenChartView>
    with SingleTickerProviderStateMixin {
  late ChartStyle _currentStyle;
  late KundaliType _currentType;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  // Zoom controls
  final TransformationController _transformController =
      TransformationController();
  double _currentZoom = 1.0;
  TapDownDetails? _doubleTapDetails;

  // Cached chart data
  List<House>? _houses;
  Map<String, PlanetPosition>? _planets;
  String? _ascendantSign;

  // Colors
  static const _bgPrimary = Color(0xFF0D0B14);
  static const _surfaceColor = Color(0xFF1A1625);
  static const _borderColor = Color(0xFF2D2640);
  static const _textPrimary = Color(0xFFF5F3FF);
  static const _textMuted = Color(0xFF9CA3AF);
  static const _accentPrimary = Color(0xFFD4AF37);
  static const _accentSecondary = Color(0xFFA78BFA);

  @override
  void initState() {
    super.initState();
    _currentStyle = widget.initialChartStyle;
    _currentType = widget.initialChartType;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();

    // Listen to zoom changes
    _transformController.addListener(_onZoomChanged);

    // Calculate initial chart data
    _updateChartData();
  }

  void _onZoomChanged() {
    final scale = _transformController.value.getMaxScaleOnAxis();
    if (scale != _currentZoom) {
      setState(() => _currentZoom = scale);
    }
  }

  @override
  void dispose() {
    _transformController.removeListener(_onZoomChanged);
    _transformController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    HapticFeedback.lightImpact();
    if (_currentZoom > 1.0) {
      // Reset to default
      _animateZoomTo(Matrix4.identity());
    } else {
      // Zoom in to 2.5x at tap position
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      final matrix =
          Matrix4.identity()
            ..translate(-position.dx * 1.5, -position.dy * 1.5)
            ..scale(2.5);
      _animateZoomTo(matrix);
    }
  }

  void _animateZoomTo(Matrix4 end) {
    final startMatrix = _transformController.value.clone();
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );

    controller.addListener(() {
      final t = animation.value;
      final newMatrix = Matrix4.identity();
      for (int i = 0; i < 16; i++) {
        newMatrix.storage[i] =
            startMatrix.storage[i] +
            (end.storage[i] - startMatrix.storage[i]) * t;
      }
      _transformController.value = newMatrix;
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _resetZoom() {
    HapticFeedback.lightImpact();
    _animateZoomTo(Matrix4.identity());
  }

  void _changeStyle(ChartStyle style) {
    if (_currentStyle != style) {
      HapticFeedback.selectionClick();
      setState(() => _currentStyle = style);
    }
  }

  void _changeType(KundaliType type) {
    if (_currentType != type) {
      HapticFeedback.selectionClick();
      setState(() {
        _currentType = type;
        _updateChartData();
        // Reset zoom when changing type
        _transformController.value = Matrix4.identity();
      });
    }
  }

  // Get chart data based on current chart type
  void _updateChartData() {
    switch (_currentType) {
      case KundaliType.lagna:
        _houses = widget.kundaliData.houses;
        _planets = widget.kundaliData.planetPositions;
        _ascendantSign = widget.kundaliData.ascendant.sign;
        break;
      case KundaliType.chandra:
        _houses = KundaliCalculationService.calculateChandraChart(
          widget.kundaliData.planetPositions,
        );
        _planets = widget.kundaliData.planetPositions;
        _ascendantSign = widget.kundaliData.moonSign;
        break;
      case KundaliType.surya:
        _houses = KundaliCalculationService.calculateSuryaChart(
          widget.kundaliData.planetPositions,
        );
        _planets = widget.kundaliData.planetPositions;
        _ascendantSign = widget.kundaliData.sunSign;
        break;
      case KundaliType.navamsa:
        final navamsaPositions =
            widget.kundaliData.navamsaChart ??
            KundaliCalculationService.calculateNavamsaChart(
              widget.kundaliData.planetPositions,
            );
        _houses = KundaliCalculationService.getHousesForDivisionalChart(
          navamsaPositions,
          widget.kundaliData.ascendant.longitude,
          9,
        );
        _planets = navamsaPositions;
        _ascendantSign = _houses!.first.sign;
        break;
      case KundaliType.dasamsa:
        final dasamsaPositions =
            KundaliCalculationService.calculateDasamsaChart(
              widget.kundaliData.planetPositions,
            );
        _houses = KundaliCalculationService.getHousesForDivisionalChart(
          dasamsaPositions,
          widget.kundaliData.ascendant.longitude,
          10,
        );
        _planets = dasamsaPositions;
        _ascendantSign = _houses!.first.sign;
        break;
      case KundaliType.saptamsa:
        final saptamsaPositions =
            KundaliCalculationService.calculateSaptamsaChart(
              widget.kundaliData.planetPositions,
            );
        _houses = KundaliCalculationService.getHousesForDivisionalChart(
          saptamsaPositions,
          widget.kundaliData.ascendant.longitude,
          7,
        );
        _planets = saptamsaPositions;
        _ascendantSign = _houses!.first.sign;
        break;
      case KundaliType.dwadasamsa:
        final dwadasamsaPositions =
            KundaliCalculationService.calculateDwadasamsaChart(
              widget.kundaliData.planetPositions,
            );
        _houses = KundaliCalculationService.getHousesForDivisionalChart(
          dwadasamsaPositions,
          widget.kundaliData.ascendant.longitude,
          12,
        );
        _planets = dwadasamsaPositions;
        _ascendantSign = _houses!.first.sign;
        break;
      case KundaliType.trimshamsa:
        final trimshamsaPositions =
            KundaliCalculationService.calculateTrimshamsaChart(
              widget.kundaliData.planetPositions,
            );
        _houses = KundaliCalculationService.getHousesForDivisionalChart(
          trimshamsaPositions,
          widget.kundaliData.ascendant.longitude,
          30,
        );
        _planets = trimshamsaPositions;
        _ascendantSign = _houses!.first.sign;
        break;
    }
  }

  IconData _getTypeIcon(KundaliType type) {
    switch (type) {
      case KundaliType.lagna:
        return Icons.north_east_rounded;
      case KundaliType.chandra:
        return Icons.nightlight_round;
      case KundaliType.surya:
        return Icons.wb_sunny_rounded;
      case KundaliType.navamsa:
        return Icons.favorite_rounded;
      case KundaliType.dasamsa:
        return Icons.work_rounded;
      case KundaliType.saptamsa:
        return Icons.child_care_rounded;
      case KundaliType.dwadasamsa:
        return Icons.people_rounded;
      case KundaliType.trimshamsa:
        return Icons.warning_amber_rounded;
    }
  }

  Color _getTypeColor(KundaliType type) {
    switch (type) {
      case KundaliType.lagna:
        return _accentSecondary;
      case KundaliType.chandra:
        return const Color(0xFF6EE7B7);
      case KundaliType.surya:
        return _accentPrimary;
      case KundaliType.navamsa:
        return const Color(0xFFF472B6);
      case KundaliType.dasamsa:
        return const Color(0xFF60A5FA);
      case KundaliType.saptamsa:
        return const Color(0xFFFBBF24);
      case KundaliType.dwadasamsa:
        return const Color(0xFF34D399);
      case KundaliType.trimshamsa:
        return const Color(0xFFF87171);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPrimary,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildChartArea(),
                  ),
                ),
                _buildStyleSelector(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final typeColor = _getTypeColor(_currentType);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Close button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _surfaceColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _borderColor.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(Icons.close_rounded, size: 20, color: _textMuted),
                ),
              ),
              // Title with type badge
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTypeIcon(_currentType),
                              size: 10,
                              color: typeColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _currentType.shortName,
                              style: GoogleFonts.dmMono(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: typeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _currentType.displayName,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_getStyleName(_currentStyle)} Style',
                    style: GoogleFonts.dmSans(fontSize: 11, color: _textMuted),
                  ),
                ],
              ),
              // Placeholder for symmetry
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 12),
          // Chart type selector
          _buildChartTypeRow(),
        ],
      ),
    );
  }

  Widget _buildChartTypeRow() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: KundaliType.values.length,
        itemBuilder: (context, index) {
          final type = KundaliType.values[index];
          final isSelected = _currentType == type;
          final accentColor = _getTypeColor(type);

          return GestureDetector(
            onTap: () => _changeType(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: index < KundaliType.values.length - 1 ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? accentColor.withOpacity(0.15)
                        : _surfaceColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      isSelected
                          ? accentColor.withOpacity(0.4)
                          : _borderColor.withOpacity(0.3),
                  width: isSelected ? 1 : 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getTypeIcon(type),
                    size: 14,
                    color: isSelected ? accentColor : _textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    type.shortName,
                    style: GoogleFonts.dmMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? accentColor : _textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getStyleName(ChartStyle style) {
    switch (style) {
      case ChartStyle.northIndian:
        return 'North Indian';
      case ChartStyle.southIndian:
        return 'South Indian';
      case ChartStyle.western:
        return 'Western';
    }
  }

  Widget _buildChartArea() {
    return Stack(
      children: [
        // Main chart with zoom
        Container(
          decoration: BoxDecoration(
            color: _surfaceColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _borderColor.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: GestureDetector(
              onDoubleTapDown: _handleDoubleTapDown,
              onDoubleTap: _handleDoubleTap,
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: 1.0,
                maxScale: 4.0,
                boundaryMargin: const EdgeInsets.all(80),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: _buildChart(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Zoom indicator & controls
        Positioned(top: 12, right: 12, child: _buildZoomControls()),
        // Zoom hint (shows when not zoomed)
        if (_currentZoom <= 1.0)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _currentZoom <= 1.0 ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _bgPrimary.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _borderColor.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pinch_rounded,
                        size: 14,
                        color: _textMuted.withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pinch or double-tap to zoom',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: _textMuted.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildZoomControls() {
    final zoomPercent = (_currentZoom * 100).round();
    final isZoomed = _currentZoom > 1.05;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: isZoomed ? 8 : 10, vertical: 6),
      decoration: BoxDecoration(
        color:
            isZoomed
                ? _accentPrimary.withOpacity(0.15)
                : _bgPrimary.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              isZoomed
                  ? _accentPrimary.withOpacity(0.3)
                  : _borderColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.zoom_in_rounded,
            size: 14,
            color: isZoomed ? _accentPrimary : _textMuted,
          ),
          const SizedBox(width: 4),
          Text(
            '$zoomPercent%',
            style: GoogleFonts.dmMono(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isZoomed ? _accentPrimary : _textMuted,
            ),
          ),
          if (isZoomed) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _resetZoom,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: _accentPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.fit_screen_rounded,
                  size: 14,
                  color: _accentPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChart() {
    final houses = _houses ?? widget.kundaliData.houses;
    final planets = _planets ?? widget.kundaliData.planetPositions;
    final ascSign = _ascendantSign ?? widget.kundaliData.ascendant.sign;

    switch (_currentStyle) {
      case ChartStyle.northIndian:
        return InteractiveKundliChart(
          key: ValueKey('north_${_currentType.name}'),
          houses: houses,
          planetPositions: planets,
          ascendantSign: ascSign,
          chartStyle: _currentStyle,
          isDarkMode: true,
        );
      case ChartStyle.southIndian:
        return InteractiveSouthIndianChart(
          key: ValueKey('south_${_currentType.name}'),
          houses: houses,
          planetPositions: planets,
          ascendantSign: ascSign,
          isDarkMode: true,
        );
      case ChartStyle.western:
        return CustomPaint(
          key: ValueKey('western_${_currentType.name}'),
          painter: SouthIndianChartPainter(
            houses: houses,
            planets: planets,
            ascendantSign: ascSign,
            isDarkMode: true,
            textStyle: GoogleFonts.dmSans(color: _textPrimary),
          ),
        );
    }
  }

  Widget _buildStyleSelector() {
    final styles = [
      {
        'style': ChartStyle.northIndian,
        'icon': Icons.diamond_outlined,
        'label': 'North Indian',
      },
      {
        'style': ChartStyle.southIndian,
        'icon': Icons.grid_4x4_rounded,
        'label': 'South Indian',
      },
      {
        'style': ChartStyle.western,
        'icon': Icons.circle_outlined,
        'label': 'Western',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _surfaceColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor.withOpacity(0.3), width: 0.5),
        ),
        child: Row(
          children:
              styles.map((item) {
                final style = item['style'] as ChartStyle;
                final isSelected = _currentStyle == style;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _changeStyle(style),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? _accentPrimary.withOpacity(0.15)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              isSelected
                                  ? _accentPrimary.withOpacity(0.3)
                                  : Colors.transparent,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 16,
                            color: isSelected ? _accentPrimary : _textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item['label'] as String,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                              color: isSelected ? _accentPrimary : _textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
