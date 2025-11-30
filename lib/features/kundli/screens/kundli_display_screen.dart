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
    _tabController = TabController(length: 8, vsync: this);
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
                          _buildStrengthTab(),
                          _buildTransitTab(),
                          _buildPanchangTab(),
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
      {'icon': Icons.analytics_rounded, 'label': 'Strength'},
      {'icon': Icons.sync_rounded, 'label': 'Transit'},
      {'icon': Icons.calendar_today_rounded, 'label': 'Panchang'},
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
          _buildChartCard(),
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
      // Primary Charts
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
      case KundaliType.bhavaChalit:
        _currentHouses = KundaliCalculationService.calculateBhavaChaliChart(
          _kundaliData!.planetPositions,
          _kundaliData!.ascendant.longitude,
        );
        _currentPlanetPositions = _kundaliData!.planetPositions;
        _currentAscendantSign = _kundaliData!.ascendant.sign;
        break;

      // Divisional Charts
      case KundaliType.hora:
        final horaPositions = KundaliCalculationService.calculateHoraChart(
          _kundaliData!.planetPositions,
        );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          horaPositions,
          _kundaliData!.ascendant.longitude,
          2,
        );
        _currentPlanetPositions = horaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.drekkana:
        final drekkanaPositions =
            KundaliCalculationService.calculateDrekkanaChart(
              _kundaliData!.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          drekkanaPositions,
          _kundaliData!.ascendant.longitude,
          3,
        );
        _currentPlanetPositions = drekkanaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.chaturthamsa:
        final chaturthamsaPositions =
            KundaliCalculationService.calculateChaturthamsaChart(
              _kundaliData!.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          chaturthamsaPositions,
          _kundaliData!.ascendant.longitude,
          4,
        );
        _currentPlanetPositions = chaturthamsaPositions;
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
      case KundaliType.shodasamsa:
        final shodasamsaPositions =
            KundaliCalculationService.calculateShodasamsaChart(
              _kundaliData!.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          shodasamsaPositions,
          _kundaliData!.ascendant.longitude,
          16,
        );
        _currentPlanetPositions = shodasamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.vimsamsa:
        final vimsamsaPositions =
            KundaliCalculationService.calculateVimsamsaChart(
              _kundaliData!.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          vimsamsaPositions,
          _kundaliData!.ascendant.longitude,
          20,
        );
        _currentPlanetPositions = vimsamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.chaturvimsamsa:
        final chaturvimsamsaPositions =
            KundaliCalculationService.calculateChaturvimsamsaChart(
              _kundaliData!.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          chaturvimsamsaPositions,
          _kundaliData!.ascendant.longitude,
          24,
        );
        _currentPlanetPositions = chaturvimsamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.bhamsa:
        final bhamsaPositions = KundaliCalculationService.calculateBhamsaChart(
          _kundaliData!.planetPositions,
        );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          bhamsaPositions,
          _kundaliData!.ascendant.longitude,
          27,
        );
        _currentPlanetPositions = bhamsaPositions;
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
      case KundaliType.khavedamsa:
        final khavedamsaPositions =
            KundaliCalculationService.calculateKhavedamsaChart(
              _kundaliData!.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          khavedamsaPositions,
          _kundaliData!.ascendant.longitude,
          40,
        );
        _currentPlanetPositions = khavedamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.akshavedamsa:
        final akshavedamsaPositions =
            KundaliCalculationService.calculateAkshavedamsaChart(
              _kundaliData!.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          akshavedamsaPositions,
          _kundaliData!.ascendant.longitude,
          45,
        );
        _currentPlanetPositions = akshavedamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.shashtiamsa:
        final shashtiamsaPositions =
            KundaliCalculationService.calculateShashtiamsaChart(
              _kundaliData!.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          shashtiamsaPositions,
          _kundaliData!.ascendant.longitude,
          60,
        );
        _currentPlanetPositions = shashtiamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;

      // Special Charts - use Lagna as base
      case KundaliType.sudarshan:
      case KundaliType.ashtakavarga:
        _currentHouses = _kundaliData!.houses;
        _currentPlanetPositions = _kundaliData!.planetPositions;
        _currentAscendantSign = _kundaliData!.ascendant.sign;
        break;
    }
  }

  IconData _getChartTypeIcon(KundaliType type) {
    switch (type) {
      // Primary Charts
      case KundaliType.lagna:
        return Icons.north_east_rounded;
      case KundaliType.chandra:
        return Icons.nightlight_round;
      case KundaliType.surya:
        return Icons.wb_sunny_rounded;
      case KundaliType.bhavaChalit:
        return Icons.swap_horiz_rounded;
      // Divisional Charts
      case KundaliType.hora:
        return Icons.attach_money_rounded;
      case KundaliType.drekkana:
        return Icons.people_outline_rounded;
      case KundaliType.chaturthamsa:
        return Icons.home_rounded;
      case KundaliType.saptamsa:
        return Icons.child_care_rounded;
      case KundaliType.navamsa:
        return Icons.favorite_rounded;
      case KundaliType.dasamsa:
        return Icons.work_rounded;
      case KundaliType.dwadasamsa:
        return Icons.family_restroom_rounded;
      case KundaliType.shodasamsa:
        return Icons.directions_car_rounded;
      case KundaliType.vimsamsa:
        return Icons.self_improvement_rounded;
      case KundaliType.chaturvimsamsa:
        return Icons.school_rounded;
      case KundaliType.bhamsa:
        return Icons.stars_rounded;
      case KundaliType.trimshamsa:
        return Icons.warning_amber_rounded;
      case KundaliType.khavedamsa:
        return Icons.auto_awesome_rounded;
      case KundaliType.akshavedamsa:
        return Icons.insights_rounded;
      case KundaliType.shashtiamsa:
        return Icons.history_rounded;
      // Special Charts
      case KundaliType.sudarshan:
        return Icons.blur_circular_rounded;
      case KundaliType.ashtakavarga:
        return Icons.grid_on_rounded;
    }
  }

  Color _getChartTypeColor(KundaliType type) {
    switch (type) {
      // Primary Charts
      case KundaliType.lagna:
        return _accentSecondary;
      case KundaliType.chandra:
        return const Color(0xFF6EE7B7);
      case KundaliType.surya:
        return _accentPrimary;
      case KundaliType.bhavaChalit:
        return const Color(0xFF818CF8);
      // Divisional Charts - color coded by category
      case KundaliType.hora:
        return const Color(0xFFFCD34D);
      case KundaliType.drekkana:
        return const Color(0xFF93C5FD);
      case KundaliType.chaturthamsa:
        return const Color(0xFFFCA5A5);
      case KundaliType.saptamsa:
        return const Color(0xFFFBBF24);
      case KundaliType.navamsa:
        return const Color(0xFFF472B6);
      case KundaliType.dasamsa:
        return const Color(0xFF60A5FA);
      case KundaliType.dwadasamsa:
        return const Color(0xFF34D399);
      case KundaliType.shodasamsa:
        return const Color(0xFF67E8F9);
      case KundaliType.vimsamsa:
        return const Color(0xFFC4B5FD);
      case KundaliType.chaturvimsamsa:
        return const Color(0xFF86EFAC);
      case KundaliType.bhamsa:
        return const Color(0xFFFDE68A);
      case KundaliType.trimshamsa:
        return const Color(0xFFF87171);
      case KundaliType.khavedamsa:
        return const Color(0xFF7DD3FC);
      case KundaliType.akshavedamsa:
        return const Color(0xFFFDA4AF);
      case KundaliType.shashtiamsa:
        return const Color(0xFFD8B4FE);
      // Special Charts
      case KundaliType.sudarshan:
        return const Color(0xFF22D3EE);
      case KundaliType.ashtakavarga:
        return const Color(0xFF4ADE80);
    }
  }

  // User-friendly simple names for the horizontal selector
  String _getChartTypeLabel(KundaliType type) {
    switch (type) {
      case KundaliType.lagna:
        return 'Lagna';
      case KundaliType.chandra:
        return 'Moon';
      case KundaliType.surya:
        return 'Sun';
      case KundaliType.bhavaChalit:
        return 'Bhava';
      case KundaliType.hora:
        return 'Hora';
      case KundaliType.drekkana:
        return 'Drekkana';
      case KundaliType.chaturthamsa:
        return 'Chaturthamsa';
      case KundaliType.saptamsa:
        return 'Saptamsa';
      case KundaliType.navamsa:
        return 'Navamsa';
      case KundaliType.dasamsa:
        return 'Dasamsa';
      case KundaliType.dwadasamsa:
        return 'Dwadasamsa';
      case KundaliType.shodasamsa:
        return 'Shodasamsa';
      case KundaliType.vimsamsa:
        return 'Vimsamsa';
      case KundaliType.chaturvimsamsa:
        return 'Chaturvimsamsa';
      case KundaliType.bhamsa:
        return 'Bhamsa';
      case KundaliType.trimshamsa:
        return 'Trimshamsa';
      case KundaliType.khavedamsa:
        return 'Khavedamsa';
      case KundaliType.akshavedamsa:
        return 'Akshavedamsa';
      case KundaliType.shashtiamsa:
        return 'Shashtiamsa';
      case KundaliType.sudarshan:
        return 'Sudarshan';
      case KundaliType.ashtakavarga:
        return 'Ashtakavarga';
    }
  }

  Widget _buildCompactChartStyleSelector() {
    final isNorth = _currentChartStyle == ChartStyle.northIndian;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // North Indian
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _currentChartStyle = ChartStyle.northIndian);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    isNorth
                        ? _accentPrimary.withOpacity(0.15)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color:
                      isNorth
                          ? _accentPrimary.withOpacity(0.3)
                          : Colors.transparent,
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.diamond_outlined,
                    size: 12,
                    color: isNorth ? _accentPrimary : _textMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'North',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: isNorth ? FontWeight.w600 : FontWeight.w400,
                      color: isNorth ? _accentPrimary : _textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // South Indian
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _currentChartStyle = ChartStyle.southIndian);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    !isNorth
                        ? _accentPrimary.withOpacity(0.15)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color:
                      !isNorth
                          ? _accentPrimary.withOpacity(0.3)
                          : Colors.transparent,
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.grid_4x4_rounded,
                    size: 12,
                    color: !isNorth ? _accentPrimary : _textMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'South',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: !isNorth ? FontWeight.w600 : FontWeight.w400,
                      color: !isNorth ? _accentPrimary : _textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
          // Compact header with style selector and fullscreen button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Chart Style Selector (North/South) - compact
              _buildCompactChartStyleSelector(),
              // Fullscreen button - icon only
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _openFullscreenChart();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _accentPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _accentPrimary.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    Icons.fullscreen_rounded,
                    size: 16,
                    color: _accentPrimary,
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
          const SizedBox(height: 16),
          // Chart Type Selector (Lagna, Chandra, Navamsa, etc.)
          _buildInlineChartTypeSelector(),
        ],
      ),
    );
  }

  Widget _buildInlineChartTypeSelector() {
    final accentColor = _getChartTypeColor(_currentChartType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current selection header with details
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withOpacity(0.12),
                accentColor.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withOpacity(0.2), width: 0.5),
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getChartTypeIcon(_currentChartType),
                  size: 20,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 12),
              // Chart info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentChartType.displayName,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _currentChartType.subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: _textMuted,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Short name badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _currentChartType.shortName,
                  style: GoogleFonts.dmMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Section label
        Row(
          children: [
            Icon(
              Icons.auto_awesome_mosaic_rounded,
              size: 13,
              color: _textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              'Select Chart Type',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Horizontally scrollable chart types - same as fullscreen
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: KundaliType.values.length,
            itemBuilder: (context, index) {
              final type = KundaliType.values[index];
              final isSelected = _currentChartType == type;
              final typeColor = _getChartTypeColor(type);

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _currentChartType = type);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    right: index < KundaliType.values.length - 1 ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? typeColor.withOpacity(0.15)
                            : _surfaceColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          isSelected
                              ? typeColor.withOpacity(0.4)
                              : _borderColor.withOpacity(0.3),
                      width: isSelected ? 1 : 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getChartTypeIcon(type),
                        size: 14,
                        color: isSelected ? typeColor : _textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getChartTypeLabel(type),
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? typeColor : _textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
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

  // ============ STRENGTH TAB (Shadbala, Vimshopaka, Ashtakavarga) ============

  Widget _buildStrengthTab() {
    final shadbala = KundaliCalculationService.calculateShadbala(
      _kundaliData!.planetPositions,
      _kundaliData!.ascendant.longitude,
      _kundaliData!.birthDateTime,
    );
    final vimshopaka = KundaliCalculationService.calculateVimshopakaBala(
      _kundaliData!.planetPositions,
    );
    final ashtakavarga = KundaliCalculationService.calculateAshtakavarga(
      _kundaliData!.planetPositions,
    );
    final sav = KundaliCalculationService.calculateSarvashtakavarga(
      ashtakavarga,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shadbala Section
          _buildSectionHeader(
            'Shadbala',
            'Six-fold planetary strength',
            Icons.fitness_center_rounded,
            const Color(0xFFA78BFA),
          ),
          const SizedBox(height: 10),
          ...shadbala.entries.map((entry) => _buildShadbalaCard(entry.value)),

          const SizedBox(height: 24),

          // Vimshopaka Bala Section
          _buildSectionHeader(
            'Vimshopaka Bala',
            'Divisional chart strength',
            Icons.layers_rounded,
            const Color(0xFF60A5FA),
          ),
          const SizedBox(height: 10),
          ...vimshopaka.entries.map(
            (entry) => _buildVimshopakCard(entry.value),
          ),

          const SizedBox(height: 24),

          // Ashtakavarga Section
          _buildSectionHeader(
            'Ashtakavarga',
            'Point-based strength analysis',
            Icons.grid_on_rounded,
            const Color(0xFF4ADE80),
          ),
          const SizedBox(height: 10),
          _buildAshtakavargaGrid(ashtakavarga, sav),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(fontSize: 10, color: _textMuted),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShadbalaCard(ShadbalaData data) {
    final percentage = data.percentageOfRequired.clamp(0.0, 150.0);
    final color =
        data.isStrong ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor.withOpacity(0.4), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getPlanetColor(data.planet).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _getPlanetSymbol(data.planet),
                    style: TextStyle(
                      fontSize: 14,
                      color: _getPlanetColor(data.planet),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.planet,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            data.isStrong ? 'Strong' : 'Weak',
                            style: GoogleFonts.dmSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 150,
                        backgroundColor: _borderColor.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data.totalBala.toStringAsFixed(1)} / ${data.requiredBala.toStringAsFixed(0)} (${percentage.toStringAsFixed(0)}%)',
                      style: GoogleFonts.dmMono(fontSize: 9, color: _textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Bala breakdown
          Row(
            children: [
              _buildBalaChip('Sthana', data.sthanaBala),
              _buildBalaChip('Dig', data.digBala),
              _buildBalaChip('Kala', data.kalaBala),
              _buildBalaChip('Chesta', data.chestaBala),
              _buildBalaChip('Naisarg', data.naisargikaBala),
              _buildBalaChip('Drik', data.drikBala),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalaChip(String label, double value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: _borderColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(fontSize: 7, color: _textMuted),
            ),
            Text(
              value.toStringAsFixed(0),
              style: GoogleFonts.dmMono(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVimshopakCard(VimshopakaBalaData data) {
    final color =
        data.strength == 'Strong'
            ? const Color(0xFF4ADE80)
            : data.strength == 'Medium'
            ? const Color(0xFFFBBF24)
            : const Color(0xFFF87171);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor.withOpacity(0.4), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getPlanetColor(data.planet).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _getPlanetSymbol(data.planet),
                style: TextStyle(
                  fontSize: 14,
                  color: _getPlanetColor(data.planet),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data.planet,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        data.strength,
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.totalPoints.toStringAsFixed(1)} / ${data.maxPoints.toStringAsFixed(0)} points (${data.percentage.toStringAsFixed(0)}%)',
                  style: GoogleFonts.dmMono(fontSize: 9, color: _textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAshtakavargaGrid(
    Map<String, List<int>> ashtakavarga,
    List<int> sav,
  ) {
    final signs = [
      'Ari',
      'Tau',
      'Gem',
      'Can',
      'Leo',
      'Vir',
      'Lib',
      'Sco',
      'Sag',
      'Cap',
      'Aqu',
      'Pis',
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor.withOpacity(0.4), width: 0.5),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with signs
            Row(
              children: [
                Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Planet',
                    style: GoogleFonts.dmSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: _textMuted,
                    ),
                  ),
                ),
                ...signs.map(
                  (sign) => Container(
                    width: 32,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    alignment: Alignment.center,
                    child: Text(
                      sign,
                      style: GoogleFonts.dmMono(
                        fontSize: 7,
                        fontWeight: FontWeight.w600,
                        color: _accentPrimary,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 36,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  alignment: Alignment.center,
                  child: Text(
                    'Total',
                    style: GoogleFonts.dmSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: _textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 8, color: _borderColor),
            // Planet rows
            ...ashtakavarga.entries.map((entry) {
              final total = entry.value.reduce((a, b) => a + b);
              return Row(
                children: [
                  Container(
                    width: 50,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      entry.key.substring(0, 3),
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: _getPlanetColor(entry.key),
                      ),
                    ),
                  ),
                  ...entry.value.map(
                    (points) => Container(
                      width: 32,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            points >= 4
                                ? const Color(0xFF4ADE80).withOpacity(0.15)
                                : points <= 2
                                ? const Color(0xFFF87171).withOpacity(0.15)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$points',
                        style: GoogleFonts.dmMono(
                          fontSize: 9,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    alignment: Alignment.center,
                    child: Text(
                      '$total',
                      style: GoogleFonts.dmMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: _accentSecondary,
                      ),
                    ),
                  ),
                ],
              );
            }),
            const Divider(height: 8, color: _borderColor),
            // SAV row
            Row(
              children: [
                Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'SAV',
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _accentPrimary,
                    ),
                  ),
                ),
                ...sav.map(
                  (points) => Container(
                    width: 32,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          points >= 28
                              ? const Color(0xFF4ADE80).withOpacity(0.2)
                              : points <= 22
                              ? const Color(0xFFF87171).withOpacity(0.2)
                              : _accentPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$points',
                      style: GoogleFonts.dmMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 36,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  alignment: Alignment.center,
                  child: Text(
                    '${sav.reduce((a, b) => a + b)}',
                    style: GoogleFonts.dmMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _accentPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============ TRANSIT TAB ============

  Widget _buildTransitTab() {
    // For demo, we'll use current positions (in real app, would get from ephemeris)
    // Here we simulate current transits
    final currentPositions = _getSimulatedCurrentPositions();
    final transits = KundaliCalculationService.calculateTransits(
      _kundaliData!.planetPositions,
      currentPositions,
      _kundaliData!.moonSign,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Current Transits (Gochar)',
            'Planetary movements from Moon',
            Icons.sync_rounded,
            const Color(0xFF22D3EE),
          ),
          const SizedBox(height: 4),
          Text(
            'Effects calculated from your Moon sign: ${_kundaliData!.moonSign}',
            style: GoogleFonts.dmSans(fontSize: 10, color: _textMuted),
          ),
          const SizedBox(height: 14),
          ...transits.entries.map((entry) => _buildTransitCard(entry.value)),
        ],
      ),
    );
  }

  Map<String, PlanetPosition> _getSimulatedCurrentPositions() {
    // Simulate current planetary positions (in real app, calculate from current date)
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;

    Map<String, PlanetPosition> positions = {};
    final planetSpeeds = {
      'Sun': 1.0,
      'Moon': 13.0,
      'Mars': 0.5,
      'Mercury': 1.2,
      'Jupiter': 0.08,
      'Venus': 1.0,
      'Saturn': 0.03,
      'Rahu': -0.05,
      'Ketu': -0.05,
    };

    for (var planet in planetSpeeds.keys) {
      double longitude =
          (dayOfYear * planetSpeeds[planet]! * 0.5 + planet.hashCode) % 360;
      int signIndex = (longitude / 30).floor();
      positions[planet] = PlanetPosition(
        planet: planet,
        longitude: longitude,
        sign: KundaliCalculationService.zodiacSigns[signIndex],
        signDegree: longitude % 30,
        nakshatra:
            KundaliCalculationService.nakshatras[(longitude / 13.333).floor() %
                27],
        house: 1,
      );
    }
    return positions;
  }

  Widget _buildTransitCard(TransitData transit) {
    final color =
        transit.isFavorable ? const Color(0xFF4ADE80) : const Color(0xFFF87171);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              transit.isFavorable
                  ? color.withOpacity(0.3)
                  : _borderColor.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getPlanetColor(transit.planet).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    _getPlanetSymbol(transit.planet),
                    style: TextStyle(
                      fontSize: 16,
                      color: _getPlanetColor(transit.planet),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          transit.planet,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              transit.isFavorable
                                  ? Icons.thumb_up_rounded
                                  : Icons.thumb_down_rounded,
                              size: 12,
                              color: color,
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                transit.isFavorable
                                    ? 'Favorable'
                                    : 'Challenging',
                                style: GoogleFonts.dmSans(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildTransitChip(
                          '${transit.currentSign} ${transit.currentDegree.toStringAsFixed(1)}°',
                          _textSecondary,
                        ),
                        const SizedBox(width: 6),
                        _buildTransitChip(
                          'House ${transit.transitHouse}',
                          _accentSecondary,
                        ),
                        if (transit.aspectToNatal != 'None') ...[
                          const SizedBox(width: 6),
                          _buildTransitChip(
                            transit.aspectToNatal,
                            _accentPrimary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (transit.effects.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _borderColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 12,
                    color: _textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      transit.effects,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: _textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransitChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmMono(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  // ============ PANCHANG TAB ============

  Widget _buildPanchangTab() {
    final sunPos = _kundaliData!.planetPositions['Sun'];
    final moonPos = _kundaliData!.planetPositions['Moon'];

    final panchang = KundaliCalculationService.calculatePanchang(
      _kundaliData!.birthDateTime,
      sunPos?.longitude ?? 0,
      moonPos?.longitude ?? 0,
    );

    final varshphal = KundaliCalculationService.calculateVarshphal(
      _kundaliData!.birthDateTime,
      sunPos?.longitude ?? 0,
      DateTime.now().year,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Birth Panchang
          _buildSectionHeader(
            'Birth Panchang',
            'Lunar calendar details at birth',
            Icons.calendar_today_rounded,
            const Color(0xFFF472B6),
          ),
          const SizedBox(height: 12),
          _buildPanchangCard(panchang),

          const SizedBox(height: 24),

          // Varshphal
          _buildSectionHeader(
            'Varshphal ${varshphal.year}',
            'Annual horoscope (Solar Return)',
            Icons.cake_rounded,
            const Color(0xFFFBBF24),
          ),
          const SizedBox(height: 12),
          _buildVarshphalCard(varshphal),
        ],
      ),
    );
  }

  Widget _buildPanchangCard(PanchangData panchang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF472B6).withOpacity(0.1),
            const Color(0xFFA78BFA).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF472B6).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Main Panchang elements
          Row(
            children: [
              Expanded(
                child: _buildPanchangElement(
                  'Tithi',
                  '${panchang.paksha} ${panchang.tithi}',
                  Icons.brightness_2_rounded,
                  const Color(0xFF6EE7B7),
                ),
              ),
              Expanded(
                child: _buildPanchangElement(
                  'Nakshatra',
                  '${panchang.nakshatra} (Pada ${panchang.nakshatraPada})',
                  Icons.star_rounded,
                  const Color(0xFFFBBF24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPanchangElement(
                  'Yoga',
                  panchang.yoga,
                  Icons.link_rounded,
                  const Color(0xFF60A5FA),
                ),
              ),
              Expanded(
                child: _buildPanchangElement(
                  'Karana',
                  panchang.karana,
                  Icons.auto_awesome_rounded,
                  const Color(0xFFA78BFA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPanchangElement(
                  'Vara',
                  panchang.vara,
                  Icons.calendar_view_day_rounded,
                  const Color(0xFF22D3EE),
                ),
              ),
              Expanded(
                child: _buildPanchangElement(
                  'Ruling Deity',
                  panchang.varaDeity,
                  Icons.person_rounded,
                  _accentPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPanchangElement(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.dmSans(fontSize: 9, color: _textMuted),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVarshphalCard(VarshphalData varshphal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFBBF24).withOpacity(0.12),
            const Color(0xFFF97316).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFBBF24).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _textPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${varshphal.age}',
                      style: GoogleFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _accentPrimary,
                      ),
                    ),
                    Text(
                      'years',
                      style: GoogleFonts.dmSans(fontSize: 9, color: _textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solar Return ${varshphal.year}',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${DateFormat('d MMM yyyy').format(varshphal.solarReturnDate)}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _surfaceColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.place_rounded,
                            size: 12,
                            color: _accentSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Muntha Sign',
                            style: GoogleFonts.dmSans(
                              fontSize: 9,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        varshphal.munthaSign,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _surfaceColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 12,
                            color: _accentPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Year Lord',
                            style: GoogleFonts.dmSans(
                              fontSize: 9,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        varshphal.yearLord,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
    final division = _currentType.division;

    // Handle divisional charts with division number
    if (division != null && division > 1) {
      final divisionalPositions =
          KundaliCalculationService.calculateDivisionalChart(
            widget.kundaliData.planetPositions,
            division,
          );
      _houses = KundaliCalculationService.getHousesForDivisionalChart(
        divisionalPositions,
        widget.kundaliData.ascendant.longitude,
        division,
      );
      _planets = divisionalPositions;
      _ascendantSign = _houses!.first.sign;
      return;
    }

    // Handle primary and special charts
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
      case KundaliType.bhavaChalit:
        _houses = KundaliCalculationService.calculateBhavaChaliChart(
          widget.kundaliData.planetPositions,
          widget.kundaliData.ascendant.longitude,
        );
        _planets = widget.kundaliData.planetPositions;
        _ascendantSign = widget.kundaliData.ascendant.sign;
        break;
      case KundaliType.sudarshan:
      case KundaliType.ashtakavarga:
        _houses = widget.kundaliData.houses;
        _planets = widget.kundaliData.planetPositions;
        _ascendantSign = widget.kundaliData.ascendant.sign;
        break;
      default:
        _houses = widget.kundaliData.houses;
        _planets = widget.kundaliData.planetPositions;
        _ascendantSign = widget.kundaliData.ascendant.sign;
    }
  }

  IconData _getTypeIcon(KundaliType type) {
    switch (type) {
      // Primary Charts
      case KundaliType.lagna:
        return Icons.north_east_rounded;
      case KundaliType.chandra:
        return Icons.nightlight_round;
      case KundaliType.surya:
        return Icons.wb_sunny_rounded;
      case KundaliType.bhavaChalit:
        return Icons.swap_horiz_rounded;
      // Divisional Charts
      case KundaliType.hora:
        return Icons.attach_money_rounded;
      case KundaliType.drekkana:
        return Icons.people_outline_rounded;
      case KundaliType.chaturthamsa:
        return Icons.home_rounded;
      case KundaliType.saptamsa:
        return Icons.child_care_rounded;
      case KundaliType.navamsa:
        return Icons.favorite_rounded;
      case KundaliType.dasamsa:
        return Icons.work_rounded;
      case KundaliType.dwadasamsa:
        return Icons.family_restroom_rounded;
      case KundaliType.shodasamsa:
        return Icons.directions_car_rounded;
      case KundaliType.vimsamsa:
        return Icons.self_improvement_rounded;
      case KundaliType.chaturvimsamsa:
        return Icons.school_rounded;
      case KundaliType.bhamsa:
        return Icons.stars_rounded;
      case KundaliType.trimshamsa:
        return Icons.warning_amber_rounded;
      case KundaliType.khavedamsa:
        return Icons.auto_awesome_rounded;
      case KundaliType.akshavedamsa:
        return Icons.insights_rounded;
      case KundaliType.shashtiamsa:
        return Icons.history_rounded;
      // Special Charts
      case KundaliType.sudarshan:
        return Icons.blur_circular_rounded;
      case KundaliType.ashtakavarga:
        return Icons.grid_on_rounded;
    }
  }

  Color _getTypeColor(KundaliType type) {
    switch (type) {
      // Primary Charts
      case KundaliType.lagna:
        return _accentSecondary;
      case KundaliType.chandra:
        return const Color(0xFF6EE7B7);
      case KundaliType.surya:
        return _accentPrimary;
      case KundaliType.bhavaChalit:
        return const Color(0xFF818CF8);
      // Divisional Charts
      case KundaliType.hora:
        return const Color(0xFFFCD34D);
      case KundaliType.drekkana:
        return const Color(0xFF93C5FD);
      case KundaliType.chaturthamsa:
        return const Color(0xFFFCA5A5);
      case KundaliType.saptamsa:
        return const Color(0xFFFBBF24);
      case KundaliType.navamsa:
        return const Color(0xFFF472B6);
      case KundaliType.dasamsa:
        return const Color(0xFF60A5FA);
      case KundaliType.dwadasamsa:
        return const Color(0xFF34D399);
      case KundaliType.shodasamsa:
        return const Color(0xFF67E8F9);
      case KundaliType.vimsamsa:
        return const Color(0xFFC4B5FD);
      case KundaliType.chaturvimsamsa:
        return const Color(0xFF86EFAC);
      case KundaliType.bhamsa:
        return const Color(0xFFFDE68A);
      case KundaliType.trimshamsa:
        return const Color(0xFFF87171);
      case KundaliType.khavedamsa:
        return const Color(0xFF7DD3FC);
      case KundaliType.akshavedamsa:
        return const Color(0xFFFDA4AF);
      case KundaliType.shashtiamsa:
        return const Color(0xFFD8B4FE);
      // Special Charts
      case KundaliType.sudarshan:
        return const Color(0xFF22D3EE);
      case KundaliType.ashtakavarga:
        return const Color(0xFF4ADE80);
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
                    _getTypeLabel(type),
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
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

  // User-friendly simple names for the horizontal selector
  String _getTypeLabel(KundaliType type) {
    switch (type) {
      case KundaliType.lagna:
        return 'Lagna';
      case KundaliType.chandra:
        return 'Moon';
      case KundaliType.surya:
        return 'Sun';
      case KundaliType.bhavaChalit:
        return 'Bhava';
      case KundaliType.hora:
        return 'Hora';
      case KundaliType.drekkana:
        return 'Drekkana';
      case KundaliType.chaturthamsa:
        return 'Chaturthamsa';
      case KundaliType.saptamsa:
        return 'Saptamsa';
      case KundaliType.navamsa:
        return 'Navamsa';
      case KundaliType.dasamsa:
        return 'Dasamsa';
      case KundaliType.dwadasamsa:
        return 'Dwadasamsa';
      case KundaliType.shodasamsa:
        return 'Shodasamsa';
      case KundaliType.vimsamsa:
        return 'Vimsamsa';
      case KundaliType.chaturvimsamsa:
        return 'Chaturvimsamsa';
      case KundaliType.bhamsa:
        return 'Bhamsa';
      case KundaliType.trimshamsa:
        return 'Trimshamsa';
      case KundaliType.khavedamsa:
        return 'Khavedamsa';
      case KundaliType.akshavedamsa:
        return 'Akshavedamsa';
      case KundaliType.shashtiamsa:
        return 'Shashtiamsa';
      case KundaliType.sudarshan:
        return 'Sudarshan';
      case KundaliType.ashtakavarga:
        return 'Ashtakavarga';
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
    final isNorth = _currentStyle == ChartStyle.northIndian;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _surfaceColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor.withOpacity(0.3), width: 0.5),
        ),
        child: Row(
          children: [
            // North Indian
            Expanded(
              child: GestureDetector(
                onTap: () => _changeStyle(ChartStyle.northIndian),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        isNorth
                            ? _accentPrimary.withOpacity(0.15)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isNorth
                              ? _accentPrimary.withOpacity(0.3)
                              : Colors.transparent,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.diamond_outlined,
                        size: 14,
                        color: isNorth ? _accentPrimary : _textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'North Indian',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight:
                              isNorth ? FontWeight.w600 : FontWeight.w400,
                          color: isNorth ? _accentPrimary : _textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // South Indian
            Expanded(
              child: GestureDetector(
                onTap: () => _changeStyle(ChartStyle.southIndian),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        !isNorth
                            ? _accentPrimary.withOpacity(0.15)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          !isNorth
                              ? _accentPrimary.withOpacity(0.3)
                              : Colors.transparent,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.grid_4x4_rounded,
                        size: 14,
                        color: !isNorth ? _accentPrimary : _textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'South Indian',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight:
                              !isNorth ? FontWeight.w600 : FontWeight.w400,
                          color: !isNorth ? _accentPrimary : _textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
