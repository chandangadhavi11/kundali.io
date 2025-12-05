import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/kundali_data_model.dart';
import '../../../core/providers/kundli_provider.dart';
import '../../../core/services/kundali_calculation_service.dart';
import '../../../core/services/sweph_service.dart';
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

  // Tab scroll controller for centering selected tab
  final ScrollController _tabScrollController = ScrollController();
  final List<GlobalKey> _tabKeys = List.generate(9, (_) => GlobalKey());

  // Chart type scroll controller for centering selected chart type
  final ScrollController _chartTypeScrollController = ScrollController();
  final List<GlobalKey> _chartTypeKeys = List.generate(
    KundaliType.values.length,
    (_) => GlobalKey(),
  );

  KundaliData? _effectiveKundaliData;
  KundaliData? get _kundaliData => _effectiveKundaliData ?? widget.kundaliData;

  // Cached divisional chart data
  List<House>? _currentHouses;
  Map<String, PlanetPosition>? _currentPlanetPositions;
  String? _currentAscendantSign;

  // Custom date/time for chart viewing
  DateTime? _customDateTime;
  KundaliData? _recalculatedKundaliData;

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

  // Number of tabs - keep this consistent
  static const int _tabCount = 9;

  @override
  void initState() {
    super.initState();
    _effectiveKundaliData = widget.kundaliData;
    _currentChartStyle = _kundaliData?.chartStyle ?? ChartStyle.northIndian;
    _tabController = TabController(length: _tabCount, vsync: this);
    _tabController.addListener(_handleTabChange);
    _initializeAnimations();
  }

  void _handleTabChange() {
    if (!mounted) return;
    if (_tabController.indexIsChanging) return;
    setState(() {});
    // Also scroll to center the tab when changed via swipe
    _scrollToTab(_tabController.index);
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
  void didUpdateWidget(covariant KundliDisplayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ensure tab controller index is valid after widget update
    if (_tabController.index >= _tabCount) {
      _tabController.index = 0;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _tabScrollController.dispose();
    _chartTypeScrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Scroll to center the selected tab with smooth animation
  void _scrollToTab(int index) {
    if (!_tabScrollController.hasClients) return;
    if (index < 0 || index >= _tabKeys.length) return;

    // Get the key for the selected tab
    final key = _tabKeys[index];
    final tabContext = key.currentContext;
    if (tabContext == null) return;

    // Get the RenderBox of the tab
    final RenderBox? tabBox = tabContext.findRenderObject() as RenderBox?;
    if (tabBox == null) return;

    // Get screen width for centering calculation
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = tabBox.size.width;

    // Get the tab's global position
    final tabGlobalPosition = tabBox.localToGlobal(Offset.zero);

    // Calculate current scroll offset
    final currentScroll = _tabScrollController.offset;

    // The tab's position in the scrollable content
    final tabScrollPosition =
        tabGlobalPosition.dx - 16 + currentScroll; // 16 is padding

    // Calculate offset to center the tab (accounting for screen width)
    final targetOffset = tabScrollPosition - (screenWidth / 2) + (tabWidth / 2);

    // Clamp the target offset within valid bounds
    final maxScroll = _tabScrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    // Animate to the target position with a nice easing curve
    _tabScrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuart,
    );
  }

  // Scroll to center the selected chart type with smooth animation
  void _scrollToChartType(int index) {
    if (!_chartTypeScrollController.hasClients) return;
    if (index < 0 || index >= _chartTypeKeys.length) return;

    // Get the key for the selected chart type
    final key = _chartTypeKeys[index];
    final itemContext = key.currentContext;
    if (itemContext == null) return;

    // Get the RenderBox of the chart type item
    final RenderBox? itemBox = itemContext.findRenderObject() as RenderBox?;
    if (itemBox == null) return;

    // Get screen width for centering calculation
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = itemBox.size.width;

    // Get the item's global position
    final itemGlobalPosition = itemBox.localToGlobal(Offset.zero);

    // Calculate current scroll offset
    final currentScroll = _chartTypeScrollController.offset;

    // The item's position in the scrollable content
    final itemScrollPosition = itemGlobalPosition.dx + currentScroll;

    // Calculate offset to center the item (accounting for screen width)
    final targetOffset =
        itemScrollPosition - (screenWidth / 2) + (itemWidth / 2);

    // Clamp the target offset within valid bounds
    final maxScroll = _chartTypeScrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    // Animate to the target position with a nice easing curve
    _chartTypeScrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuart,
    );
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
                          _buildDetailsTab(),
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
      {'icon': Icons.person_outline_rounded, 'label': 'Details'},
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
        controller: _tabScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          // Safe index check to prevent assertion errors
          final currentIndex = _tabController.index.clamp(0, _tabCount - 1);
          final isSelected = currentIndex == index;

          return GestureDetector(
            key: _tabKeys[index],
            onTap: () {
              if (index >= 0 && index < _tabCount) {
                HapticFeedback.selectionClick();
                _tabController.animateTo(index);
                setState(() {});
                // Scroll to center the selected tab after a short delay
                // to allow the UI to update first
                Future.delayed(const Duration(milliseconds: 50), () {
                  _scrollToTab(index);
                });
              }
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
          const SizedBox(height: 12),
          _buildDateTimeNavigator(),
        ],
      ),
    );
  }

  Widget _buildDateTimeNavigator() {
    final displayDateTime = _customDateTime ?? _kundaliData!.birthDateTime;
    final isCustom = _customDateTime != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isCustom
                  ? _accentPrimary.withOpacity(0.25)
                  : _borderColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Previous day button
          GestureDetector(
            onTap: () => _adjustDateTime(days: -1),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _borderColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 16,
                color: _textMuted,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Date/Time display - tappable
          Expanded(
            child: GestureDetector(
              onTap: () => _showDateTimePicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: isCustom ? _accentPrimary : _textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('d MMM yyyy').format(displayDateTime),
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isCustom ? _accentPrimary : _textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 12,
                      color: _borderColor.withOpacity(0.5),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: isCustom ? _accentPrimary : _textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('h:mm a').format(displayDateTime),
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isCustom ? _accentPrimary : _textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Next day button
          GestureDetector(
            onTap: () => _adjustDateTime(days: 1),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _borderColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: _textMuted,
              ),
            ),
          ),
          // Reset button (only when custom)
          if (isCustom) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _customDateTime = null;
                  _recalculatedKundaliData = null;
                  _updateChartDataForMainScreen();
                });
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _accentPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.restore_rounded,
                  size: 16,
                  color: _accentPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDateTimePicker(BuildContext context) {
    final displayDateTime = _customDateTime ?? _kundaliData!.birthDateTime;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
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
                  Text(
                    'View Chart For',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPickerOption(
                          icon: Icons.calendar_today_rounded,
                          label: 'Date',
                          value: DateFormat(
                            'd MMM yyyy',
                          ).format(displayDateTime),
                          color: _accentSecondary,
                          onTap: () {
                            Navigator.pop(context);
                            _selectDate(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPickerOption(
                          icon: Icons.schedule_rounded,
                          label: 'Time',
                          value: DateFormat('h:mm a').format(displayDateTime),
                          color: const Color(0xFF6EE7B7),
                          onTap: () {
                            Navigator.pop(context);
                            _selectTime(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      setState(() {
                        _customDateTime = DateTime.now();
                        _recalculateKundaliData();
                        _updateChartDataForMainScreen();
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6EE7B7).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF6EE7B7).withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            size: 16,
                            color: const Color(0xFF6EE7B7),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'View Current Time Chart',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6EE7B7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surfaceColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor.withOpacity(0.4), width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.dmSans(fontSize: 10, color: _textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStats(),
          const SizedBox(height: 16),
          _buildBasicInfo(),
          const SizedBox(height: 16),
          _buildAscendantDetails(),
          const SizedBox(height: 16),
          _buildNakshatraDetails(),
          const SizedBox(height: 16),
          _buildPanchangDetails(),
          const SizedBox(height: 16),
          _buildCurrentDashaDetails(),
          const SizedBox(height: 16),
          _buildCompatibilityDetails(),
          const SizedBox(height: 16),
          _buildLuckyFactors(),
          const SizedBox(height: 16),
          _buildPlanetaryStatus(),
        ],
      ),
    );
  }

  Widget _buildAscendantDetails() {
    final ascendant = _kundaliData!.ascendant;
    final lagnaLord = _getLagnaLord(ascendant.sign);
    final ascNakshatra = _getNakshatraFromLongitude(ascendant.longitude);
    final nakshatraLord = _getNakshatraLord(ascNakshatra);

    return _buildDetailCard(
      title: 'Lagna (Ascendant)',
      icon: Icons.north_east_rounded,
      color: _accentSecondary,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Lagna Sign',
                  ascendant.sign,
                  Icons.blur_circular_rounded,
                  _accentSecondary,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Degree',
                  '${(ascendant.longitude % 30).toStringAsFixed(2)}°',
                  Icons.straighten_rounded,
                  const Color(0xFF60A5FA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Nakshatra',
                  ascNakshatra,
                  Icons.star_rounded,
                  const Color(0xFFFBBF24),
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Lagna Lord',
                  lagnaLord,
                  Icons.person_rounded,
                  const Color(0xFF6EE7B7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Nakshatra Lord',
                  nakshatraLord,
                  Icons.auto_awesome_rounded,
                  const Color(0xFFF472B6),
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Element',
                  _getSignElement(ascendant.sign),
                  _getElementIcon(ascendant.sign),
                  _getElementColor(ascendant.sign),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNakshatraDetails() {
    final moonPos = _kundaliData!.planetPositions['Moon']!;
    final nakshatra = _kundaliData!.birthNakshatra;
    final pada = _kundaliData!.birthNakshatraPada;
    final nakshatraLord = _getNakshatraLord(nakshatra);
    final deity = _getNakshatraDeity(nakshatra);
    final gana = _getNakshatraGana(nakshatra);
    final symbol = _getNakshatraSymbol(nakshatra);

    return _buildDetailCard(
      title: 'Nakshatra Details',
      icon: Icons.stars_rounded,
      color: const Color(0xFFF472B6),
      child: Column(
        children: [
          // Main nakshatra display
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF472B6).withOpacity(0.12),
                  const Color(0xFFA78BFA).withOpacity(0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF472B6).withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF472B6).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(symbol, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nakshatra,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pada $pada • ${moonPos.signDegree.toStringAsFixed(2)}° in ${moonPos.sign}',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _getGanaColor(gana).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    gana,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getGanaColor(gana),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Lord',
                  nakshatraLord,
                  Icons.person_outline_rounded,
                  const Color(0xFFA78BFA),
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Deity',
                  deity,
                  Icons.temple_hindu_rounded,
                  const Color(0xFFFBBF24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Gana',
                  gana,
                  Icons.group_rounded,
                  _getGanaColor(gana),
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Yoni',
                  _getNakshatraYoni(nakshatra),
                  Icons.pets_rounded,
                  const Color(0xFF67E8F9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPanchangDetails() {
    final sunPos = _kundaliData!.planetPositions['Sun'];
    final moonPos = _kundaliData!.planetPositions['Moon'];

    final panchang = KundaliCalculationService.calculatePanchang(
      _kundaliData!.birthDateTime,
      sunPos?.longitude ?? 0,
      moonPos?.longitude ?? 0,
    );

    return _buildDetailCard(
      title: 'Panchang at Birth',
      icon: Icons.calendar_month_rounded,
      color: const Color(0xFF6EE7B7),
      child: Column(
        children: [
          // Tithi and Paksha highlight
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6EE7B7).withOpacity(0.12),
                  const Color(0xFF22D3EE).withOpacity(0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6EE7B7).withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                // Realistic Moon Phase Widget
                _MoonPhaseWidget(
                  tithiNumber: panchang.tithiNumber,
                  paksha: panchang.paksha,
                  size: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${panchang.paksha} Paksha',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _textMuted,
                        ),
                      ),
                      Text(
                        panchang.tithi,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6EE7B7).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    panchang.vara,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6EE7B7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Yoga',
                  panchang.yoga,
                  Icons.link_rounded,
                  const Color(0xFF60A5FA),
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Karana',
                  panchang.karana,
                  Icons.hourglass_bottom_rounded,
                  const Color(0xFFA78BFA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Vara Deity',
                  panchang.varaDeity,
                  Icons.temple_hindu_rounded,
                  _accentPrimary,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Nakshatra',
                  panchang.nakshatra,
                  Icons.star_rounded,
                  const Color(0xFFF472B6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentDashaDetails() {
    final dasha = _kundaliData!.dashaInfo;
    final currentPlanetColor = _getPlanetColor(dasha.currentMahadasha);

    return _buildDetailCard(
      title: 'Current Dasha Period',
      icon: Icons.timeline_rounded,
      color: const Color(0xFF60A5FA),
      child: Column(
        children: [
          // Main Dasha display
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  currentPlanetColor.withOpacity(0.15),
                  currentPlanetColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: currentPlanetColor.withOpacity(0.25),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: currentPlanetColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _getPlanetSymbol(dasha.currentMahadasha),
                      style: TextStyle(fontSize: 22, color: currentPlanetColor),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mahadasha',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _textMuted,
                        ),
                      ),
                      Text(
                        '${dasha.currentMahadasha} Dasha',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.hourglass_bottom_rounded,
                            size: 10,
                            color: _textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${dasha.remainingYears.toStringAsFixed(1)} years remaining',
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
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Dasha sequence preview
          Text(
            'Upcoming Periods',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: _textMuted,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children:
                  dasha.sequence.take(5).map((period) {
                    final isCurrent = period.planet == dasha.currentMahadasha;
                    final color = _getPlanetColor(period.planet);
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isCurrent
                                ? color.withOpacity(0.15)
                                : _surfaceColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              isCurrent
                                  ? color.withOpacity(0.3)
                                  : _borderColor.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getPlanetSymbol(period.planet),
                            style: TextStyle(fontSize: 16, color: color),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            period.planet.substring(0, 3),
                            style: GoogleFonts.dmSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isCurrent ? color : _textMuted,
                            ),
                          ),
                          Text(
                            '${period.years}y',
                            style: GoogleFonts.dmMono(
                              fontSize: 8,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityDetails() {
    final nakshatra = _kundaliData!.birthNakshatra;
    final gana = _getNakshatraGana(nakshatra);
    final varna = _getVarna(_kundaliData!.moonSign);
    final nadi = _getNadi(nakshatra);
    final yoni = _getNakshatraYoni(nakshatra);

    return _buildDetailCard(
      title: 'Compatibility Factors (Guna)',
      icon: Icons.favorite_rounded,
      color: const Color(0xFFF472B6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildGunaItem(
                  'Varna',
                  varna,
                  '1/1',
                  const Color(0xFFFBBF24),
                ),
              ),
              Expanded(
                child: _buildGunaItem(
                  'Vashya',
                  _getVashya(_kundaliData!.moonSign),
                  '2/2',
                  const Color(0xFF60A5FA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildGunaItem(
                  'Tara',
                  _getTara(nakshatra),
                  '3/3',
                  const Color(0xFF6EE7B7),
                ),
              ),
              Expanded(
                child: _buildGunaItem(
                  'Yoni',
                  yoni,
                  '4/4',
                  const Color(0xFFA78BFA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildGunaItem(
                  'Graha Maitri',
                  _getGrahaMaitri(_kundaliData!.moonSign),
                  '5/5',
                  const Color(0xFF67E8F9),
                ),
              ),
              Expanded(
                child: _buildGunaItem('Gana', gana, '6/6', _getGanaColor(gana)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildGunaItem(
                  'Bhakoot',
                  _getBhakoot(_kundaliData!.moonSign),
                  '7/7',
                  const Color(0xFFFCA5A5),
                ),
              ),
              Expanded(
                child: _buildGunaItem(
                  'Nadi',
                  nadi,
                  '8/8',
                  const Color(0xFFD8B4FE),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGunaItem(String name, String value, String points, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15), width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.dmSans(fontSize: 9, color: _textMuted),
                ),
                Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              points,
              style: GoogleFonts.dmMono(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyFactors() {
    final moonSign = _kundaliData!.moonSign;

    return _buildDetailCard(
      title: 'Lucky Factors',
      icon: Icons.auto_awesome_rounded,
      color: _accentPrimary,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildLuckyItem(
                  'Lucky Numbers',
                  _getLuckyNumbers(moonSign),
                  Icons.tag_rounded,
                  _accentPrimary,
                ),
              ),
              Expanded(
                child: _buildLuckyItem(
                  'Lucky Day',
                  _getLuckyDay(moonSign),
                  Icons.calendar_today_rounded,
                  const Color(0xFF6EE7B7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildLuckyItem(
                  'Lucky Colors',
                  _getLuckyColors(moonSign),
                  Icons.palette_rounded,
                  const Color(0xFFF472B6),
                ),
              ),
              Expanded(
                child: _buildLuckyItem(
                  'Lucky Metal',
                  _getLuckyMetal(moonSign),
                  Icons.hardware_rounded,
                  const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Gemstone recommendation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _accentPrimary.withOpacity(0.12),
                  const Color(0xFFA78BFA).withOpacity(0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _accentPrimary.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _accentPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.diamond_rounded,
                    size: 20,
                    color: _accentPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Primary Gemstone',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: _textMuted,
                        ),
                      ),
                      Text(
                        _getLuckyGemstone(moonSign),
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _getGemstoneEmoji(moonSign),
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
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
              const SizedBox(width: 5),
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
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetaryStatus() {
    final planets = _kundaliData!.planetPositions;

    // Find special planetary states
    final retrograde = <String>[];
    final exalted = <String>[];
    final debilitated = <String>[];
    final combust = <String>[];

    final exaltationSigns = {
      'Sun': 'Aries',
      'Moon': 'Taurus',
      'Mars': 'Capricorn',
      'Mercury': 'Virgo',
      'Jupiter': 'Cancer',
      'Venus': 'Pisces',
      'Saturn': 'Libra',
      'Rahu': 'Taurus',
      'Ketu': 'Scorpio',
    };
    final debilitationSigns = {
      'Sun': 'Libra',
      'Moon': 'Scorpio',
      'Mars': 'Cancer',
      'Mercury': 'Pisces',
      'Jupiter': 'Capricorn',
      'Venus': 'Virgo',
      'Saturn': 'Aries',
      'Rahu': 'Scorpio',
      'Ketu': 'Taurus',
    };

    planets.forEach((name, planet) {
      if (exaltationSigns[name] == planet.sign) exalted.add(name);
      if (debilitationSigns[name] == planet.sign) debilitated.add(name);
      // Simulate retrograde and combust (would need actual calculation)
      if (name == 'Saturn' || name == 'Jupiter') retrograde.add(name);
    });

    return _buildDetailCard(
      title: 'Planetary Status',
      icon: Icons.public_rounded,
      color: const Color(0xFF22D3EE),
      child: Column(
        children: [
          _buildStatusRow(
            'Exalted',
            exalted.isEmpty ? ['None'] : exalted,
            const Color(0xFF4ADE80),
            Icons.arrow_upward_rounded,
          ),
          const SizedBox(height: 8),
          _buildStatusRow(
            'Debilitated',
            debilitated.isEmpty ? ['None'] : debilitated,
            const Color(0xFFF87171),
            Icons.arrow_downward_rounded,
          ),
          const SizedBox(height: 8),
          _buildStatusRow(
            'Retrograde',
            retrograde.isEmpty ? ['None'] : retrograde,
            const Color(0xFFFBBF24),
            Icons.replay_rounded,
          ),
          if (combust.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildStatusRow(
              'Combust',
              combust,
              const Color(0xFFFF6B6B),
              Icons.local_fire_department_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRow(
    String label,
    List<String> planets,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _textMuted,
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: 6,
            children:
                planets.map((p) {
                  final planetColor =
                      p == 'None' ? _textMuted : _getPlanetColor(p);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: planetColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      p == 'None' ? p : p.substring(0, math.min(3, p.length)),
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: planetColor,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, childWidget) {
        return Transform.translate(
          offset: Offset(0, 15 * (1 - value)),
          child: Opacity(opacity: value, child: childWidget),
        );
      },
      child: Container(
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
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 14, color: color),
                ),
                const SizedBox(width: 8),
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
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(fontSize: 9, color: _textMuted),
                ),
                Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for astrological data
  String _getLagnaLord(String sign) {
    const lords = {
      'Aries': 'Mars',
      'Taurus': 'Venus',
      'Gemini': 'Mercury',
      'Cancer': 'Moon',
      'Leo': 'Sun',
      'Virgo': 'Mercury',
      'Libra': 'Venus',
      'Scorpio': 'Mars',
      'Sagittarius': 'Jupiter',
      'Capricorn': 'Saturn',
      'Aquarius': 'Saturn',
      'Pisces': 'Jupiter',
    };
    return lords[sign] ?? 'Unknown';
  }

  String _getNakshatraFromLongitude(double longitude) {
    final index = (longitude / 13.333333).floor() % 27;
    return KundaliCalculationService.nakshatras[index];
  }

  String _getNakshatraLord(String nakshatra) {
    const lords = {
      'Ashwini': 'Ketu',
      'Bharani': 'Venus',
      'Krittika': 'Sun',
      'Rohini': 'Moon',
      'Mrigashira': 'Mars',
      'Ardra': 'Rahu',
      'Punarvasu': 'Jupiter',
      'Pushya': 'Saturn',
      'Ashlesha': 'Mercury',
      'Magha': 'Ketu',
      'Purva Phalguni': 'Venus',
      'Uttara Phalguni': 'Sun',
      'Hasta': 'Moon',
      'Chitra': 'Mars',
      'Swati': 'Rahu',
      'Vishakha': 'Jupiter',
      'Anuradha': 'Saturn',
      'Jyeshtha': 'Mercury',
      'Mula': 'Ketu',
      'Purva Ashadha': 'Venus',
      'Uttara Ashadha': 'Sun',
      'Shravana': 'Moon',
      'Dhanishta': 'Mars',
      'Shatabhisha': 'Rahu',
      'Purva Bhadrapada': 'Jupiter',
      'Uttara Bhadrapada': 'Saturn',
      'Revati': 'Mercury',
    };
    return lords[nakshatra] ?? 'Unknown';
  }

  String _getNakshatraDeity(String nakshatra) {
    const deities = {
      'Ashwini': 'Ashwini Kumaras',
      'Bharani': 'Yama',
      'Krittika': 'Agni',
      'Rohini': 'Brahma',
      'Mrigashira': 'Soma',
      'Ardra': 'Rudra',
      'Punarvasu': 'Aditi',
      'Pushya': 'Brihaspati',
      'Ashlesha': 'Nagas',
      'Magha': 'Pitris',
      'Purva Phalguni': 'Bhaga',
      'Uttara Phalguni': 'Aryaman',
      'Hasta': 'Savitar',
      'Chitra': 'Vishwakarma',
      'Swati': 'Vayu',
      'Vishakha': 'Indra-Agni',
      'Anuradha': 'Mitra',
      'Jyeshtha': 'Indra',
      'Mula': 'Nirriti',
      'Purva Ashadha': 'Apas',
      'Uttara Ashadha': 'Vishvadevas',
      'Shravana': 'Vishnu',
      'Dhanishta': 'Vasus',
      'Shatabhisha': 'Varuna',
      'Purva Bhadrapada': 'Aja Ekapada',
      'Uttara Bhadrapada': 'Ahir Budhnya',
      'Revati': 'Pushan',
    };
    return deities[nakshatra] ?? 'Unknown';
  }

  String _getNakshatraGana(String nakshatra) {
    const ganas = {
      'Ashwini': 'Deva',
      'Bharani': 'Manushya',
      'Krittika': 'Rakshasa',
      'Rohini': 'Manushya',
      'Mrigashira': 'Deva',
      'Ardra': 'Manushya',
      'Punarvasu': 'Deva',
      'Pushya': 'Deva',
      'Ashlesha': 'Rakshasa',
      'Magha': 'Rakshasa',
      'Purva Phalguni': 'Manushya',
      'Uttara Phalguni': 'Manushya',
      'Hasta': 'Deva',
      'Chitra': 'Rakshasa',
      'Swati': 'Deva',
      'Vishakha': 'Rakshasa',
      'Anuradha': 'Deva',
      'Jyeshtha': 'Rakshasa',
      'Mula': 'Rakshasa',
      'Purva Ashadha': 'Manushya',
      'Uttara Ashadha': 'Manushya',
      'Shravana': 'Deva',
      'Dhanishta': 'Rakshasa',
      'Shatabhisha': 'Rakshasa',
      'Purva Bhadrapada': 'Manushya',
      'Uttara Bhadrapada': 'Manushya',
      'Revati': 'Deva',
    };
    return ganas[nakshatra] ?? 'Manushya';
  }

  String _getNakshatraSymbol(String nakshatra) {
    const symbols = {
      'Ashwini': '🐴',
      'Bharani': '🔺',
      'Krittika': '🔥',
      'Rohini': '🛞',
      'Mrigashira': '🦌',
      'Ardra': '💎',
      'Punarvasu': '🏹',
      'Pushya': '🌸',
      'Ashlesha': '🐍',
      'Magha': '👑',
      'Purva Phalguni': '🛏️',
      'Uttara Phalguni': '🛏️',
      'Hasta': '✋',
      'Chitra': '💠',
      'Swati': '🌱',
      'Vishakha': '🎯',
      'Anuradha': '🪷',
      'Jyeshtha': '☂️',
      'Mula': '🦁',
      'Purva Ashadha': '🐘',
      'Uttara Ashadha': '🐘',
      'Shravana': '👂',
      'Dhanishta': '🎵',
      'Shatabhisha': '⭕',
      'Purva Bhadrapada': '⚔️',
      'Uttara Bhadrapada': '🐍',
      'Revati': '🐟',
    };
    return symbols[nakshatra] ?? '⭐';
  }

  String _getNakshatraYoni(String nakshatra) {
    const yonis = {
      'Ashwini': 'Horse',
      'Bharani': 'Elephant',
      'Krittika': 'Goat',
      'Rohini': 'Serpent',
      'Mrigashira': 'Serpent',
      'Ardra': 'Dog',
      'Punarvasu': 'Cat',
      'Pushya': 'Goat',
      'Ashlesha': 'Cat',
      'Magha': 'Rat',
      'Purva Phalguni': 'Rat',
      'Uttara Phalguni': 'Cow',
      'Hasta': 'Buffalo',
      'Chitra': 'Tiger',
      'Swati': 'Buffalo',
      'Vishakha': 'Tiger',
      'Anuradha': 'Deer',
      'Jyeshtha': 'Deer',
      'Mula': 'Dog',
      'Purva Ashadha': 'Monkey',
      'Uttara Ashadha': 'Mongoose',
      'Shravana': 'Monkey',
      'Dhanishta': 'Lion',
      'Shatabhisha': 'Horse',
      'Purva Bhadrapada': 'Lion',
      'Uttara Bhadrapada': 'Cow',
      'Revati': 'Elephant',
    };
    return yonis[nakshatra] ?? 'Unknown';
  }

  Color _getGanaColor(String gana) {
    switch (gana) {
      case 'Deva':
        return const Color(0xFF6EE7B7);
      case 'Manushya':
        return const Color(0xFF60A5FA);
      case 'Rakshasa':
        return const Color(0xFFF87171);
      default:
        return _textMuted;
    }
  }

  String _getSignElement(String sign) {
    const elements = {
      'Aries': 'Fire',
      'Taurus': 'Earth',
      'Gemini': 'Air',
      'Cancer': 'Water',
      'Leo': 'Fire',
      'Virgo': 'Earth',
      'Libra': 'Air',
      'Scorpio': 'Water',
      'Sagittarius': 'Fire',
      'Capricorn': 'Earth',
      'Aquarius': 'Air',
      'Pisces': 'Water',
    };
    return elements[sign] ?? 'Unknown';
  }

  IconData _getElementIcon(String sign) {
    final element = _getSignElement(sign);
    switch (element) {
      case 'Fire':
        return Icons.local_fire_department_rounded;
      case 'Earth':
        return Icons.landscape_rounded;
      case 'Air':
        return Icons.air_rounded;
      case 'Water':
        return Icons.water_drop_rounded;
      default:
        return Icons.circle;
    }
  }

  Color _getElementColor(String sign) {
    final element = _getSignElement(sign);
    switch (element) {
      case 'Fire':
        return const Color(0xFFF87171);
      case 'Earth':
        return const Color(0xFF6EE7B7);
      case 'Air':
        return const Color(0xFF60A5FA);
      case 'Water':
        return const Color(0xFF67E8F9);
      default:
        return _textMuted;
    }
  }

  String _getVarna(String moonSign) {
    const varnas = {
      'Aries': 'Kshatriya',
      'Leo': 'Kshatriya',
      'Sagittarius': 'Kshatriya',
      'Taurus': 'Vaishya',
      'Virgo': 'Vaishya',
      'Capricorn': 'Vaishya',
      'Gemini': 'Shudra',
      'Libra': 'Shudra',
      'Aquarius': 'Shudra',
      'Cancer': 'Brahmin',
      'Scorpio': 'Brahmin',
      'Pisces': 'Brahmin',
    };
    return varnas[moonSign] ?? 'Unknown';
  }

  String _getVashya(String moonSign) {
    const vashyas = {
      'Aries': 'Chatushpad',
      'Taurus': 'Chatushpad',
      'Leo': 'Chatushpad',
      'Sagittarius': 'Chatushpad',
      'Capricorn': 'Chatushpad',
      'Gemini': 'Nara',
      'Virgo': 'Nara',
      'Libra': 'Nara',
      'Aquarius': 'Nara',
      'Cancer': 'Jalachara',
      'Pisces': 'Jalachara',
      'Scorpio': 'Keeta',
    };
    return vashyas[moonSign] ?? 'Unknown';
  }

  String _getTara(String nakshatra) {
    // Simplified - would need actual calculation based on birth nakshatra
    return 'Janma';
  }

  String _getGrahaMaitri(String moonSign) {
    return _getLagnaLord(moonSign);
  }

  String _getBhakoot(String moonSign) {
    return moonSign;
  }

  String _getNadi(String nakshatra) {
    const nadis = {
      'Ashwini': 'Aadi',
      'Bharani': 'Madhya',
      'Krittika': 'Antya',
      'Rohini': 'Aadi',
      'Mrigashira': 'Madhya',
      'Ardra': 'Antya',
      'Punarvasu': 'Aadi',
      'Pushya': 'Madhya',
      'Ashlesha': 'Antya',
      'Magha': 'Aadi',
      'Purva Phalguni': 'Madhya',
      'Uttara Phalguni': 'Antya',
      'Hasta': 'Aadi',
      'Chitra': 'Madhya',
      'Swati': 'Antya',
      'Vishakha': 'Aadi',
      'Anuradha': 'Madhya',
      'Jyeshtha': 'Antya',
      'Mula': 'Aadi',
      'Purva Ashadha': 'Madhya',
      'Uttara Ashadha': 'Antya',
      'Shravana': 'Aadi',
      'Dhanishta': 'Madhya',
      'Shatabhisha': 'Antya',
      'Purva Bhadrapada': 'Aadi',
      'Uttara Bhadrapada': 'Madhya',
      'Revati': 'Antya',
    };
    return nadis[nakshatra] ?? 'Unknown';
  }

  String _getLuckyNumbers(String moonSign) {
    const numbers = {
      'Aries': '1, 8, 9',
      'Taurus': '2, 6, 7',
      'Gemini': '3, 5, 6',
      'Cancer': '2, 4, 7',
      'Leo': '1, 4, 5',
      'Virgo': '3, 5, 6',
      'Libra': '2, 6, 7',
      'Scorpio': '3, 9, 4',
      'Sagittarius': '3, 5, 8',
      'Capricorn': '4, 8, 6',
      'Aquarius': '4, 7, 8',
      'Pisces': '3, 7, 9',
    };
    return numbers[moonSign] ?? '1, 7, 9';
  }

  String _getLuckyDay(String moonSign) {
    const days = {
      'Aries': 'Tuesday',
      'Taurus': 'Friday',
      'Gemini': 'Wednesday',
      'Cancer': 'Monday',
      'Leo': 'Sunday',
      'Virgo': 'Wednesday',
      'Libra': 'Friday',
      'Scorpio': 'Tuesday',
      'Sagittarius': 'Thursday',
      'Capricorn': 'Saturday',
      'Aquarius': 'Saturday',
      'Pisces': 'Thursday',
    };
    return days[moonSign] ?? 'Sunday';
  }

  String _getLuckyColors(String moonSign) {
    const colors = {
      'Aries': 'Red, Orange',
      'Taurus': 'Green, Pink',
      'Gemini': 'Yellow, Green',
      'Cancer': 'White, Silver',
      'Leo': 'Gold, Orange',
      'Virgo': 'Green, Brown',
      'Libra': 'Blue, Pink',
      'Scorpio': 'Red, Maroon',
      'Sagittarius': 'Yellow, Purple',
      'Capricorn': 'Black, Brown',
      'Aquarius': 'Blue, Electric',
      'Pisces': 'Sea Green, Lavender',
    };
    return colors[moonSign] ?? 'White';
  }

  String _getLuckyMetal(String moonSign) {
    const metals = {
      'Aries': 'Iron',
      'Taurus': 'Copper',
      'Gemini': 'Brass',
      'Cancer': 'Silver',
      'Leo': 'Gold',
      'Virgo': 'Bronze',
      'Libra': 'Copper',
      'Scorpio': 'Iron',
      'Sagittarius': 'Tin',
      'Capricorn': 'Lead',
      'Aquarius': 'Lead',
      'Pisces': 'Tin',
    };
    return metals[moonSign] ?? 'Gold';
  }

  String _getLuckyGemstone(String moonSign) {
    const gems = {
      'Aries': 'Red Coral',
      'Taurus': 'Diamond',
      'Gemini': 'Emerald',
      'Cancer': 'Pearl',
      'Leo': 'Ruby',
      'Virgo': 'Emerald',
      'Libra': 'Diamond',
      'Scorpio': 'Red Coral',
      'Sagittarius': 'Yellow Sapphire',
      'Capricorn': 'Blue Sapphire',
      'Aquarius': 'Blue Sapphire',
      'Pisces': 'Yellow Sapphire',
    };
    return gems[moonSign] ?? 'Pearl';
  }

  String _getGemstoneEmoji(String moonSign) {
    const gems = {
      'Aries': '🔴',
      'Taurus': '💎',
      'Gemini': '💚',
      'Cancer': '🤍',
      'Leo': '❤️',
      'Virgo': '💚',
      'Libra': '💎',
      'Scorpio': '🔴',
      'Sagittarius': '💛',
      'Capricorn': '💙',
      'Aquarius': '💙',
      'Pisces': '💛',
    };
    return gems[moonSign] ?? '💎';
  }

  void _updateChartDataForMainScreen() {
    if (_kundaliData == null) return;

    // Use recalculated data if available (when custom date/time is set)
    final data = _recalculatedKundaliData ?? _kundaliData!;

    switch (_currentChartType) {
      // Primary Charts
      case KundaliType.lagna:
        _currentHouses = data.houses;
        _currentPlanetPositions = data.planetPositions;
        _currentAscendantSign = data.ascendant.sign;
        break;
      case KundaliType.chandra:
        _currentHouses = KundaliCalculationService.calculateChandraChart(
          data.planetPositions,
        );
        _currentPlanetPositions = data.planetPositions;
        _currentAscendantSign = data.moonSign;
        break;
      case KundaliType.surya:
        _currentHouses = KundaliCalculationService.calculateSuryaChart(
          data.planetPositions,
        );
        _currentPlanetPositions = data.planetPositions;
        _currentAscendantSign = data.sunSign;
        break;
      case KundaliType.bhavaChalit:
        _currentHouses = KundaliCalculationService.calculateBhavaChaliChart(
          data.planetPositions,
          data.ascendant.longitude,
        );
        _currentPlanetPositions = data.planetPositions;
        _currentAscendantSign = data.ascendant.sign;
        break;

      // Divisional Charts
      case KundaliType.hora:
        final horaPositions = KundaliCalculationService.calculateHoraChart(
          data.planetPositions,
        );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          horaPositions,
          data.ascendant.longitude,
          2,
        );
        _currentPlanetPositions = horaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.drekkana:
        final drekkanaPositions =
            KundaliCalculationService.calculateDrekkanaChart(
              data.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          drekkanaPositions,
          data.ascendant.longitude,
          3,
        );
        _currentPlanetPositions = drekkanaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.chaturthamsa:
        final chaturthamsaPositions =
            KundaliCalculationService.calculateChaturthamsaChart(
              data.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          chaturthamsaPositions,
          data.ascendant.longitude,
          4,
        );
        _currentPlanetPositions = chaturthamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.saptamsa:
        final saptamsaPositions =
            KundaliCalculationService.calculateSaptamsaChart(
              data.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          saptamsaPositions,
          data.ascendant.longitude,
          7,
        );
        _currentPlanetPositions = saptamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.navamsa:
        final navamsaPositions =
            data.navamsaChart ??
            KundaliCalculationService.calculateNavamsaChart(
              data.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          navamsaPositions,
          data.ascendant.longitude,
          9,
        );
        _currentPlanetPositions = navamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.dasamsa:
        final dasamsaPositions =
            KundaliCalculationService.calculateDasamsaChart(
              data.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          dasamsaPositions,
          data.ascendant.longitude,
          10,
        );
        _currentPlanetPositions = dasamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.dwadasamsa:
        final dwadasamsaPositions =
            KundaliCalculationService.calculateDwadasamsaChart(
              data.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          dwadasamsaPositions,
          data.ascendant.longitude,
          12,
        );
        _currentPlanetPositions = dwadasamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.shodasamsa:
        final shodasamsaPositions =
            KundaliCalculationService.calculateShodasamsaChart(
              data.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          shodasamsaPositions,
          data.ascendant.longitude,
          16,
        );
        _currentPlanetPositions = shodasamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.vimsamsa:
        final vimsamsaPositions =
            KundaliCalculationService.calculateVimsamsaChart(
              data.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          vimsamsaPositions,
          data.ascendant.longitude,
          20,
        );
        _currentPlanetPositions = vimsamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.chaturvimsamsa:
        final chaturvimsamsaPositions =
            KundaliCalculationService.calculateChaturvimsamsaChart(
              data.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          chaturvimsamsaPositions,
          data.ascendant.longitude,
          24,
        );
        _currentPlanetPositions = chaturvimsamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.bhamsa:
        final bhamsaPositions = KundaliCalculationService.calculateBhamsaChart(
          data.planetPositions,
        );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          bhamsaPositions,
          data.ascendant.longitude,
          27,
        );
        _currentPlanetPositions = bhamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.trimshamsa:
        final trimshamsaPositions =
            KundaliCalculationService.calculateTrimshamsaChart(
              data.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          trimshamsaPositions,
          data.ascendant.longitude,
          30,
        );
        _currentPlanetPositions = trimshamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.khavedamsa:
        final khavedamsaPositions =
            KundaliCalculationService.calculateKhavedamsaChart(
              data.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          khavedamsaPositions,
          data.ascendant.longitude,
          40,
        );
        _currentPlanetPositions = khavedamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.akshavedamsa:
        final akshavedamsaPositions =
            KundaliCalculationService.calculateAkshavedamsaChart(
              data.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          akshavedamsaPositions,
          data.ascendant.longitude,
          45,
        );
        _currentPlanetPositions = akshavedamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;
      case KundaliType.shashtiamsa:
        final shashtiamsaPositions =
            KundaliCalculationService.calculateShashtiamsaChart(
              data.planetPositions,
            );
        _currentHouses = KundaliCalculationService.getHousesForDivisionalChart(
          shashtiamsaPositions,
          data.ascendant.longitude,
          60,
        );
        _currentPlanetPositions = shashtiamsaPositions;
        _currentAscendantSign = _currentHouses!.first.sign;
        break;

      // Special Charts - use Lagna as base
      case KundaliType.sudarshan:
      case KundaliType.ashtakavarga:
        _currentHouses = data.houses;
        _currentPlanetPositions = data.planetPositions;
        _currentAscendantSign = data.ascendant.sign;
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
          // Data mode indicator - shows if using real Swiss Ephemeris or sample data
          _buildDataModeIndicator(),
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

  void _adjustDateTime({int days = 0, int hours = 0}) {
    final current = _customDateTime ?? _kundaliData!.birthDateTime;
    setState(() {
      _customDateTime = current.add(Duration(days: days, hours: hours));
      _recalculateKundaliData();
      _updateChartDataForMainScreen();
    });
  }

  void _recalculateKundaliData() {
    if (_customDateTime == null) {
      _recalculatedKundaliData = null;
      return;
    }

    // Recalculate Kundali with custom date/time
    _recalculatedKundaliData = KundaliData.fromBirthDetails(
      id: 'temp_${_customDateTime!.millisecondsSinceEpoch}',
      name: _kundaliData!.name,
      birthDateTime: _customDateTime!,
      birthPlace: _kundaliData!.birthPlace,
      latitude: _kundaliData!.latitude,
      longitude: _kundaliData!.longitude,
      timezone: _kundaliData!.timezone,
      gender: _kundaliData!.gender,
      chartStyle: _kundaliData!.chartStyle,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final displayDateTime = _customDateTime ?? _kundaliData!.birthDateTime;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => _CustomDatePicker(
            initialDate: displayDateTime,
            onDateSelected: (picked) {
              HapticFeedback.selectionClick();
              setState(() {
                _customDateTime = DateTime(
                  picked.year,
                  picked.month,
                  picked.day,
                  displayDateTime.hour,
                  displayDateTime.minute,
                  displayDateTime.second,
                );
                _recalculateKundaliData();
                _updateChartDataForMainScreen();
              });
            },
          ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final displayDateTime = _customDateTime ?? _kundaliData!.birthDateTime;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => _CustomTimePicker(
            initialTime: displayDateTime,
            onTimeSelected: (picked) {
              HapticFeedback.selectionClick();
              setState(() {
                _customDateTime = DateTime(
                  displayDateTime.year,
                  displayDateTime.month,
                  displayDateTime.day,
                  picked.hour,
                  picked.minute,
                );
                _recalculateKundaliData();
                _updateChartDataForMainScreen();
              });
            },
          ),
    );
  }

  /// Build the data mode indicator showing if using real Swiss Ephemeris or sample data
  Widget _buildDataModeIndicator() {
    final isUsingRealData = SwephService.nativeLibraryAvailable;
    final indicatorColor = isUsingRealData ? Colors.green : Colors.orange;
    final icon =
        isUsingRealData
            ? Icons.precision_manufacturing_rounded
            : Icons.data_object_rounded;
    final text =
        isUsingRealData
            ? '🔬 Swiss Ephemeris (Accurate)'
            : '📊 Sample Data (Demo)';

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: indicatorColor.withOpacity(0.4), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: indicatorColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.dmMono(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: indicatorColor,
              letterSpacing: 0.3,
            ),
          ),
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
            controller: _chartTypeScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: KundaliType.values.length,
            itemBuilder: (context, index) {
              final type = KundaliType.values[index];
              final isSelected = _currentChartType == type;
              final typeColor = _getChartTypeColor(type);

              return GestureDetector(
                key: _chartTypeKeys[index],
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _currentChartType = type);
                  // Scroll to center the selected chart type
                  Future.delayed(const Duration(milliseconds: 50), () {
                    _scrollToChartType(index);
                  });
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
              child: Row(
                children: [
                  Text(
                    'Dasha Sequence',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• Tap to explore',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: _accentSecondary.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
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
              child: GestureDetector(
                onTap: () => _showDashaDetails(period.planet, dasha),
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
                          color: _getPlanetColor(
                            period.planet,
                          ).withOpacity(0.12),
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
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: _textMuted.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Show detailed Dasha information with drill-down capability
  void _showDashaDetails(String mahadashaPlanet, DashaInfo dasha) {
    final mahadashaDetail = dasha.mahadashaSequence?.firstWhere(
      (m) => m.planet == mahadashaPlanet,
      orElse: () => dasha.mahadashaSequence!.first,
    );

    if (mahadashaDetail == null) {
      // Fallback if detailed sequence not available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Detailed dasha data not available for $mahadashaPlanet',
          ),
          backgroundColor: _accentSecondary,
        ),
      );
      return;
    }

    _showDashaPeriodSheet(mahadashaDetail, []);
  }

  /// Show bottom sheet for a Dasha period with its sub-periods
  void _showDashaPeriodSheet(
    DashaPeriodDetail period,
    List<String> breadcrumbs,
  ) {
    final levelColors = {
      DashaLevel.mahadasha: const Color(0xFFE8B931),
      DashaLevel.antardasha: const Color(0xFFA78BFA),
      DashaLevel.pratyantara: const Color(0xFF6EE7B7),
      DashaLevel.sookshma: const Color(0xFF60A5FA),
      DashaLevel.prana: const Color(0xFFF472B6),
    };

    final levelColor = levelColors[period.level] ?? _accentSecondary;
    final newBreadcrumbs = [...breadcrumbs, period.planet];
    final now = DateTime.now();
    final isCurrentPeriod = period.containsDate(now);

    // Check if we need to calculate deeper sub-periods
    final hasSubPeriods =
        period.subPeriods != null && period.subPeriods!.isNotEmpty;
    final nextLevel = _getNextLevel(period.level);
    final canDrillDeeper = nextLevel != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.92,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: _bgSecondary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border.all(
                      color: levelColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Breadcrumbs
                            if (breadcrumbs.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Icon(
                                        Icons.arrow_back_ios_rounded,
                                        size: 14,
                                        color: _textMuted,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        breadcrumbs.join(' → '),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 11,
                                          color: _textMuted,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Period info
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: levelColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: levelColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getPlanetSymbol(period.planet),
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: levelColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: levelColor.withOpacity(
                                                0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              period.levelName,
                                              style: GoogleFonts.dmSans(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: levelColor,
                                              ),
                                            ),
                                          ),
                                          if (isCurrentPeriod) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF6EE7B7,
                                                ).withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'ACTIVE',
                                                style: GoogleFonts.dmMono(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(
                                                    0xFF6EE7B7,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${period.planet} ${period.levelName}',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: _textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Period dates and duration
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _surfaceColor.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _borderColor.withOpacity(0.4),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Start',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 9,
                                            color: _textMuted,
                                          ),
                                        ),
                                        Text(
                                          _needsTimeDisplay(period.level)
                                              ? _formatDateWithTime(
                                                period.startDate,
                                              )
                                              : _formatDate(period.startDate),
                                          style: GoogleFonts.dmMono(
                                            fontSize:
                                                _needsTimeDisplay(period.level)
                                                    ? 10
                                                    : 11,
                                            fontWeight: FontWeight.w500,
                                            color: _textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 28,
                                    color: _borderColor,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'End',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 9,
                                              color: _textMuted,
                                            ),
                                          ),
                                          Text(
                                            _needsTimeDisplay(period.level)
                                                ? _formatDateWithTime(
                                                  period.endDate,
                                                )
                                                : _formatDate(period.endDate),
                                            style: GoogleFonts.dmMono(
                                              fontSize:
                                                  _needsTimeDisplay(
                                                        period.level,
                                                      )
                                                      ? 10
                                                      : 11,
                                              fontWeight: FontWeight.w500,
                                              color: _textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 28,
                                    color: _borderColor,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Duration',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 9,
                                              color: _textMuted,
                                            ),
                                          ),
                                          Text(
                                            _formatDuration(
                                              period.durationYears,
                                            ),
                                            style: GoogleFonts.dmMono(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: levelColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Sub-periods list
                      if (canDrillDeeper)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Text(
                                '${_getLevelDisplayName(nextLevel)} Periods',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (hasSubPeriods)
                                Text(
                                  '(${period.subPeriods!.length})',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    color: _textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Sub-periods list
                      Expanded(
                        child:
                            hasSubPeriods
                                ? ListView.builder(
                                  controller: scrollController,
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    24,
                                  ),
                                  itemCount: period.subPeriods!.length,
                                  itemBuilder: (context, index) {
                                    final subPeriod = period.subPeriods![index];
                                    final isSubCurrent = subPeriod.containsDate(
                                      now,
                                    );
                                    final subLevelColor =
                                        levelColors[subPeriod.level] ??
                                        _textMuted;
                                    final canDrillDeeperSub =
                                        _getNextLevel(subPeriod.level) != null;

                                    return GestureDetector(
                                      onTap:
                                          canDrillDeeperSub
                                              ? () {
                                                Navigator.pop(context);
                                                // Calculate deeper levels on demand
                                                final deeperPeriod =
                                                    _ensureSubPeriods(
                                                      subPeriod,
                                                    );
                                                _showDashaPeriodSheet(
                                                  deeperPeriod,
                                                  newBreadcrumbs,
                                                );
                                              }
                                              : null,
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isSubCurrent
                                                  ? subLevelColor.withOpacity(
                                                    0.1,
                                                  )
                                                  : _surfaceColor.withOpacity(
                                                    0.4,
                                                  ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color:
                                                isSubCurrent
                                                    ? subLevelColor.withOpacity(
                                                      0.3,
                                                    )
                                                    : _borderColor.withOpacity(
                                                      0.3,
                                                    ),
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: _getPlanetColor(
                                                  subPeriod.planet,
                                                ).withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _getPlanetSymbol(
                                                    subPeriod.planet,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: _getPlanetColor(
                                                      subPeriod.planet,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        subPeriod.planet,
                                                        style: GoogleFonts.dmSans(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              isSubCurrent
                                                                  ? FontWeight
                                                                      .w600
                                                                  : FontWeight
                                                                      .w500,
                                                          color: _textPrimary,
                                                        ),
                                                      ),
                                                      if (isSubCurrent) ...[
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 5,
                                                                vertical: 2,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: const Color(
                                                              0xFF6EE7B7,
                                                            ).withOpacity(0.2),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  4,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            'NOW',
                                                            style: GoogleFonts.dmMono(
                                                              fontSize: 7,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color:
                                                                  const Color(
                                                                    0xFF6EE7B7,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    _needsTimeDisplay(
                                                          subPeriod.level,
                                                        )
                                                        ? '${_formatDateShortWithTime(subPeriod.startDate)} - ${_formatDateShortWithTime(subPeriod.endDate)}'
                                                        : '${_formatDateShort(subPeriod.startDate)} - ${_formatDateShort(subPeriod.endDate)}',
                                                    style: GoogleFonts.dmMono(
                                                      fontSize:
                                                          _needsTimeDisplay(
                                                                subPeriod.level,
                                                              )
                                                              ? 8
                                                              : 9,
                                                      color: _textMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              _formatDuration(
                                                subPeriod.durationYears,
                                              ),
                                              style: GoogleFonts.dmMono(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: _textMuted,
                                              ),
                                            ),
                                            if (canDrillDeeperSub) ...[
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.chevron_right_rounded,
                                                size: 16,
                                                color: _textMuted.withOpacity(
                                                  0.5,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                                : Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.hourglass_empty_rounded,
                                          size: 48,
                                          color: _textMuted.withOpacity(0.3),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Sub-periods calculating...',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 13,
                                            color: _textMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Please wait or try again',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 11,
                                            color: _textMuted.withOpacity(0.6),
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
          ),
    );
  }

  /// Get the next dasha level (for drilling deeper)
  DashaLevel? _getNextLevel(DashaLevel current) {
    switch (current) {
      case DashaLevel.mahadasha:
        return DashaLevel.antardasha;
      case DashaLevel.antardasha:
        return DashaLevel.pratyantara;
      case DashaLevel.pratyantara:
        return DashaLevel.sookshma;
      case DashaLevel.sookshma:
        return DashaLevel.prana;
      case DashaLevel.prana:
        return null; // Deepest level
    }
  }

  /// Get display name for a dasha level
  String _getLevelDisplayName(DashaLevel level) {
    switch (level) {
      case DashaLevel.mahadasha:
        return 'Mahadasha';
      case DashaLevel.antardasha:
        return 'Antardasha';
      case DashaLevel.pratyantara:
        return 'Pratyantara';
      case DashaLevel.sookshma:
        return 'Sookshma';
      case DashaLevel.prana:
        return 'Prana';
    }
  }

  /// Ensure sub-periods are calculated for deeper drill-down
  DashaPeriodDetail _ensureSubPeriods(DashaPeriodDetail period) {
    if (period.subPeriods != null && period.subPeriods!.isNotEmpty) {
      return period;
    }

    // Calculate sub-periods on demand
    final nextLevel = _getNextLevel(period.level);
    if (nextLevel == null) return period;

    final subPeriods = KundaliCalculationService.calculateSubDashas(
      parentPath: period.fullPath,
      parentPlanet: period.planet,
      parentDuration: period.durationYears,
      startDate: period.startDate,
      level: nextLevel,
      maxDepth: 1, // Only calculate one level deep at a time
    );

    return DashaPeriodDetail(
      planet: period.planet,
      fullPath: period.fullPath,
      durationYears: period.durationYears,
      startDate: period.startDate,
      endDate: period.endDate,
      level: period.level,
      subPeriods: subPeriods,
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Format date with time for shorter periods
  String _formatDateWithTime(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute';
  }

  /// Format date in short form
  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year.toString().substring(2)}';
  }

  /// Format date in short form with time for Sookshma/Prana levels
  String _formatDateShortWithTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month} $hour:$minute';
  }

  /// Format duration based on length - shows hours/minutes for short periods
  String _formatDuration(double durationYears) {
    final totalDays = durationYears * 365.25;

    if (totalDays >= 365) {
      final years = totalDays ~/ 365.25;
      final remainingDays = totalDays - (years * 365.25);
      final months = remainingDays ~/ 30.44;
      final days = (remainingDays - (months * 30.44)).round();
      return '$years y, $months m, $days d';
    } else if (totalDays >= 30) {
      final months = totalDays ~/ 30.44;
      final days = (totalDays - (months * 30.44)).round();
      return '$months m, $days d';
    } else if (totalDays >= 1) {
      final days = totalDays.floor();
      final hours = ((totalDays - days) * 24).round();
      if (hours > 0) {
        return '$days d, $hours h';
      }
      return '$days days';
    } else {
      // Less than a day - show hours and minutes
      final totalHours = totalDays * 24;
      if (totalHours >= 1) {
        final hours = totalHours.floor();
        final minutes = ((totalHours - hours) * 60).round();
        if (minutes > 0) {
          return '$hours h, $minutes m';
        }
        return '$hours hours';
      } else {
        // Less than an hour - show minutes
        final minutes = (totalHours * 60).round();
        if (minutes > 0) {
          return '$minutes min';
        }
        return '< 1 min';
      }
    }
  }

  /// Check if the dasha level needs time display (Sookshma and Prana)
  bool _needsTimeDisplay(DashaLevel level) {
    return level == DashaLevel.sookshma || level == DashaLevel.prana;
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
    // Calculate REAL current planetary positions using Swiss Ephemeris
    final currentPositions = _getCurrentTransitPositions();
    final transits = KundaliCalculationService.calculateTransits(
      _kundaliData!.planetPositions,
      currentPositions,
      _kundaliData!.moonSign,
    );

    // Format current date for display
    final now = DateTime.now();
    final dateStr =
        '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

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
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 12, color: _textMuted),
              const SizedBox(width: 4),
              Text(
                'As of $dateStr',
                style: GoogleFonts.dmSans(fontSize: 10, color: _textMuted),
              ),
              const Spacer(),
              Text(
                'Moon sign: ${_kundaliData!.moonSign}',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: _accentSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Current planetary positions summary
          _buildCurrentPositionsSummary(currentPositions),
          const SizedBox(height: 16),

          // Transit effects
          _buildSectionHeader(
            'Transit Effects',
            'Impact on your chart',
            Icons.trending_up_rounded,
            const Color(0xFF6EE7B7),
          ),
          const SizedBox(height: 12),
          ...transits.entries.map((entry) => _buildTransitCard(entry.value)),
        ],
      ),
    );
  }

  /// Calculate REAL current planetary positions using Swiss Ephemeris
  /// This replaces the old simulated positions with actual astronomical calculations
  Map<String, PlanetPosition> _getCurrentTransitPositions() {
    try {
      // Use current date/time with the same location as birth chart
      // (Location doesn't significantly affect planetary longitudes, mainly affects houses/ascendant)
      final now = DateTime.now();

      // Calculate using the same Swiss Ephemeris service used for birth chart
      final result = KundaliCalculationService.calculateAll(
        birthDateTime: now,
        latitude: _kundaliData!.latitude,
        longitude: _kundaliData!.longitude,
        timezone: _kundaliData!.timezone,
      );

      return result.planetPositions;
    } catch (e) {
      // Fallback to birth positions if calculation fails (shouldn't happen)
      debugPrint('Transit calculation error: $e');
      return _kundaliData!.planetPositions;
    }
  }

  /// Build a summary card showing current planetary positions
  Widget _buildCurrentPositionsSummary(Map<String, PlanetPosition> positions) {
    final vedicPlanets = [
      'Sun',
      'Moon',
      'Mars',
      'Mercury',
      'Jupiter',
      'Venus',
      'Saturn',
      'Rahu',
      'Ketu',
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF22D3EE).withOpacity(0.08),
            const Color(0xFF6EE7B7).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF22D3EE).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.public_rounded,
                size: 14,
                color: const Color(0xFF22D3EE),
              ),
              const SizedBox(width: 6),
              Text(
                'Current Sky Positions',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6EE7B7).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'LIVE',
                  style: GoogleFonts.dmMono(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6EE7B7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                vedicPlanets.map((planet) {
                  final pos = positions[planet];
                  if (pos == null) return const SizedBox();

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _surfaceColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getPlanetColor(planet).withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getPlanetSymbol(planet),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getPlanetColor(planet),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pos.sign,
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _textPrimary,
                              ),
                            ),
                            Text(
                              '${pos.signDegree.toStringAsFixed(1)}°${pos.isRetrograde ? ' ℞' : ''}',
                              style: GoogleFonts.dmMono(
                                fontSize: 8,
                                color:
                                    pos.isRetrograde
                                        ? const Color(0xFFF87171)
                                        : _textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
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

    // Calculate inauspicious periods for birth date
    final inauspiciousPeriods =
        KundaliCalculationService.calculateInauspiciousPeriods(
          _kundaliData!.birthDateTime,
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

          // Inauspicious Periods
          _buildSectionHeader(
            'Inauspicious Periods',
            'Rahukala, Yamaghanda & Gulika at birth',
            Icons.warning_amber_rounded,
            const Color(0xFFF87171),
          ),
          const SizedBox(height: 12),
          _buildInauspiciousPeriodsCard(inauspiciousPeriods),

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

  Widget _buildInauspiciousPeriodsCard(InauspiciousPeriods periods) {
    // Check if birth time falls in any inauspicious period
    final birthTime = _kundaliData!.birthDateTime;
    final currentPeriod = periods.getCurrentPeriod(birthTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF87171).withOpacity(0.08),
            const Color(0xFFFBBF24).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF87171).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Birth time warning if applicable
          if (currentPeriod != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF87171).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFF87171).withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFF87171),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Birth during ${currentPeriod.name}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFF87171),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentPeriod.description,
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Rahukala
          _buildInauspiciousPeriodRow(
            periods.rahukala,
            const Color(0xFFF87171),
            Icons.do_not_disturb_on_rounded,
          ),
          const SizedBox(height: 10),

          // Yamaghanda
          _buildInauspiciousPeriodRow(
            periods.yamaghanda,
            const Color(0xFFFBBF24),
            Icons.warning_rounded,
          ),
          const SizedBox(height: 10),

          // Gulika
          _buildInauspiciousPeriodRow(
            periods.gulika,
            const Color(0xFFA78BFA),
            Icons.brightness_3_rounded,
          ),

          const SizedBox(height: 12),

          // Visual timeline
          _buildInauspiciousTimeline(periods),
        ],
      ),
    );
  }

  Widget _buildInauspiciousPeriodRow(
    TimePeriod period,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  period.description,
                  style: GoogleFonts.dmSans(fontSize: 9, color: _textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              period.formattedTime,
              style: GoogleFonts.dmMono(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInauspiciousTimeline(InauspiciousPeriods periods) {
    // Visual timeline showing 6 AM to 6 PM
    final startHour = 6;
    final endHour = 18;
    final totalMinutes = (endHour - startHour) * 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule_rounded, size: 12, color: _textMuted),
            const SizedBox(width: 6),
            Text(
              'Day Timeline (6 AM - 6 PM)',
              style: GoogleFonts.dmSans(fontSize: 10, color: _textMuted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 24,
          child: Stack(
            children: [
              // Background bar
              Container(
                height: 8,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Rahukala period
              _buildTimelineSegment(
                periods.rahukala,
                startHour,
                totalMinutes,
                const Color(0xFFF87171),
              ),
              // Yamaghanda period
              _buildTimelineSegment(
                periods.yamaghanda,
                startHour,
                totalMinutes,
                const Color(0xFFFBBF24),
              ),
              // Gulika period
              _buildTimelineSegment(
                periods.gulika,
                startHour,
                totalMinutes,
                const Color(0xFFA78BFA),
              ),
              // Birth time marker
              _buildBirthTimeMarker(startHour, totalMinutes),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Hour markers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '6 AM',
              style: GoogleFonts.dmMono(fontSize: 8, color: _textMuted),
            ),
            Text(
              '9 AM',
              style: GoogleFonts.dmMono(fontSize: 8, color: _textMuted),
            ),
            Text(
              '12 PM',
              style: GoogleFonts.dmMono(fontSize: 8, color: _textMuted),
            ),
            Text(
              '3 PM',
              style: GoogleFonts.dmMono(fontSize: 8, color: _textMuted),
            ),
            Text(
              '6 PM',
              style: GoogleFonts.dmMono(fontSize: 8, color: _textMuted),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineSegment(
    TimePeriod period,
    int startHour,
    int totalMinutes,
    Color color,
  ) {
    final periodStartMinutes =
        (period.startTime.hour - startHour) * 60 + period.startTime.minute;
    final periodEndMinutes =
        (period.endTime.hour - startHour) * 60 + period.endTime.minute;

    // Calculate position and width
    final startFraction = (periodStartMinutes / totalMinutes).clamp(0.0, 1.0);
    final endFraction = (periodEndMinutes / totalMinutes).clamp(0.0, 1.0);
    final width = endFraction - startFraction;

    if (width <= 0) return const SizedBox();

    return Positioned(
      left:
          startFraction *
          (MediaQuery.of(context).size.width - 64), // Account for padding
      top: 8,
      child: Container(
        width: width * (MediaQuery.of(context).size.width - 64),
        height: 8,
        decoration: BoxDecoration(
          color: color.withOpacity(0.7),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildBirthTimeMarker(int startHour, int totalMinutes) {
    final birthTime = _kundaliData!.birthDateTime;
    final birthMinutes = (birthTime.hour - startHour) * 60 + birthTime.minute;
    final fraction = (birthMinutes / totalMinutes).clamp(0.0, 1.0);

    return Positioned(
      left: fraction * (MediaQuery.of(context).size.width - 68),
      top: 0,
      child: Column(
        children: [
          Container(
            width: 2,
            height: 24,
            decoration: BoxDecoration(
              color: _accentPrimary,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
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
          // Summary Card
          _buildYogaSummaryCard(),
          const SizedBox(height: 16),

          if (_kundaliData!.yogas.isNotEmpty) ...[
            _buildYogaSectionHeader(
              'Auspicious Yogas',
              '${_kundaliData!.yogas.length} present',
              const Color(0xFF6EE7B7),
              Icons.auto_awesome_rounded,
            ),
            const SizedBox(height: 10),
            ..._kundaliData!.yogas.asMap().entries.map((entry) {
              final index = entry.key;
              final yogaName = entry.value;
              return _buildYogaDetailCard(yogaName, index, false);
            }),
            const SizedBox(height: 20),
          ],

          if (_kundaliData!.doshas.isNotEmpty) ...[
            _buildYogaSectionHeader(
              'Doshas Present',
              '${_kundaliData!.doshas.length} present',
              const Color(0xFFF87171),
              Icons.warning_amber_rounded,
            ),
            const SizedBox(height: 10),
            ..._kundaliData!.doshas.asMap().entries.map((entry) {
              final index = entry.key;
              final doshaName = entry.value;
              return _buildYogaDetailCard(doshaName, index, true);
            }),
            const SizedBox(height: 20),
          ],

          _buildInsightsSection(),
        ],
      ),
    );
  }

  Widget _buildYogaSummaryCard() {
    final yogaCount = _kundaliData!.yogas.length;
    final doshaCount = _kundaliData!.doshas.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _accentSecondary.withOpacity(0.12),
            _accentPrimary.withOpacity(0.06),
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
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6EE7B7).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF6EE7B7),
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$yogaCount',
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6EE7B7),
                  ),
                ),
                Text(
                  'Yogas',
                  style: GoogleFonts.dmSans(fontSize: 10, color: _textMuted),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 60, color: _borderColor),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF87171).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFF87171),
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$doshaCount',
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF87171),
                  ),
                ),
                Text(
                  'Doshas',
                  style: GoogleFonts.dmSans(fontSize: 10, color: _textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYogaSectionHeader(
    String title,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYogaDetailCard(String yogaName, int index, bool isDosha) {
    final color = isDosha ? const Color(0xFFF87171) : const Color(0xFF6EE7B7);
    final yogaInfo = _getYogaInfo(yogaName, isDosha);

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
      child: GestureDetector(
        onTap: () => _showYogaDetailsSheet(yogaName, isDosha),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.15), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isDosha
                          ? Icons.warning_amber_rounded
                          : Icons.auto_awesome_rounded,
                      color: color,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          yogaName,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          yogaInfo['type'] ??
                              (isDosha ? 'Dosha' : 'Benefic Yoga'),
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: _textMuted.withOpacity(0.5),
                    size: 18,
                  ),
                ],
              ),
              if (yogaInfo['description'] != null) ...[
                const SizedBox(height: 10),
                Text(
                  yogaInfo['description']!,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: _textMuted,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Map<String, String> _getYogaInfo(String yogaName, bool isDosha) {
    // Map yoga names to their type and brief description
    final yogaInfoMap = {
      // Pancha Mahapurusha Yogas
      'Hamsa Yoga': {
        'type': 'Pancha Mahapurusha',
        'description':
            'Jupiter in Kendra in own/exalted sign. Bestows wisdom and spiritual growth.',
      },
      'Malavya Yoga': {
        'type': 'Pancha Mahapurusha',
        'description':
            'Venus in Kendra in own/exalted sign. Grants beauty, wealth, and luxury.',
      },
      'Bhadra Yoga': {
        'type': 'Pancha Mahapurusha',
        'description':
            'Mercury in Kendra in own sign. Gives intelligence and communication skills.',
      },
      'Ruchaka Yoga': {
        'type': 'Pancha Mahapurusha',
        'description':
            'Mars in Kendra in own/exalted sign. Bestows courage and leadership.',
      },
      'Sasa Yoga': {
        'type': 'Pancha Mahapurusha',
        'description':
            'Saturn in Kendra in own/exalted sign. Grants authority and discipline.',
      },

      // Raja Yogas
      'Gajakesari Yoga': {
        'type': 'Raja Yoga',
        'description':
            'Jupiter in Kendra from Moon. Brings fame, wisdom, and prosperity.',
      },
      'Budhaditya Yoga': {
        'type': 'Raja Yoga',
        'description':
            'Sun-Mercury conjunction. Grants sharp intellect and communication skills.',
      },
      'Chandra-Mangal Yoga': {
        'type': 'Dhana Yoga',
        'description':
            'Moon-Mars conjunction. Creates wealth through courage and determination.',
      },
      'Lakshmi Yoga': {
        'type': 'Dhana Yoga',
        'description':
            'Strong Venus in Kendra. Brings abundant wealth and luxury.',
      },
      'Viparita Raja Yoga': {
        'type': 'Raja Yoga',
        'description':
            'Dusthana lords in dusthana. Success through unconventional means.',
      },

      // Lunar Yogas
      'Sunafa Yoga': {
        'type': 'Lunar Yoga',
        'description': 'Planet in 2nd from Moon. Brings self-earned wealth.',
      },
      'Anafa Yoga': {
        'type': 'Lunar Yoga',
        'description':
            'Planet in 12th from Moon. Grants good personality and fame.',
      },
      'Durudhura Yoga': {
        'type': 'Lunar Yoga',
        'description':
            'Planets in both 2nd and 12th from Moon. Blessed with comforts.',
      },

      // Other Yogas
      'Dhana Yoga': {
        'type': 'Dhana Yoga',
        'description':
            '2nd and 11th house connection. Indicates wealth accumulation.',
      },
      'Amala Yoga': {
        'type': 'Benefic Yoga',
        'description':
            'Benefic planet in 10th house. Pure and charitable nature.',
      },
      'Saraswati Yoga': {
        'type': 'Benefic Yoga',
        'description':
            'Jupiter, Venus, Mercury well placed. Learning and wisdom.',
      },
      'Bhagya Yoga': {
        'type': 'Benefic Yoga',
        'description': 'Benefic in 9th house. Good fortune and luck.',
      },

      // Doshas
      'Manglik Dosha': {
        'type': 'Dosha',
        'description':
            'Mars in 1, 4, 7, 8, or 12. May affect marriage compatibility.',
      },
      'Kaal Sarp Dosha': {
        'type': 'Dosha',
        'description':
            'All planets between Rahu-Ketu axis. Karmic challenges and delays.',
      },
      'Pitra Dosha': {
        'type': 'Dosha',
        'description': 'Sun afflicted by Rahu/Ketu. Ancestral karma issues.',
      },
      'Surya Grahan Dosha': {
        'type': 'Grahan Dosha',
        'description': 'Sun with Rahu/Ketu. May affect career and father.',
      },
      'Chandra Grahan Dosha': {
        'type': 'Grahan Dosha',
        'description': 'Moon with Rahu/Ketu. May affect mental peace.',
      },
      'Shrapit Dosha': {
        'type': 'Dosha',
        'description': 'Saturn-Rahu conjunction. Past life karmic debt.',
      },
      'Guru Chandal Yoga': {
        'type': 'Dosha',
        'description':
            'Jupiter-Rahu conjunction. May affect wisdom and ethics.',
      },
      'Kemdrum Dosha': {
        'type': 'Dosha',
        'description': 'No planets 2nd/12th from Moon. Emotional challenges.',
      },
      'Angarak Dosha': {
        'type': 'Dosha',
        'description': 'Mars-Rahu conjunction. Anger and conflict issues.',
      },
    };

    return yogaInfoMap[yogaName] ??
        {
          'type': isDosha ? 'Dosha' : 'Benefic Yoga',
          'description':
              isDosha
                  ? 'This dosha may create certain challenges. Tap for details and remedies.'
                  : 'This yoga brings positive influences to your chart. Tap for details.',
        };
  }

  void _showYogaDetailsSheet(String yogaName, bool isDosha) {
    final color = isDosha ? const Color(0xFFF87171) : const Color(0xFF6EE7B7);
    final yogaDetails = _getFullYogaDetails(yogaName, isDosha);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.4,
            maxChildSize: 0.85,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: _bgSecondary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border.all(color: color.withOpacity(0.3), width: 1),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                isDosha
                                    ? Icons.warning_amber_rounded
                                    : Icons.auto_awesome_rounded,
                                color: color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    yogaName,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: _textPrimary,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      yogaDetails['type']!,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Content
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          children: [
                            // Description
                            _buildYogaDetailSection(
                              'What is ${yogaName}?',
                              yogaDetails['description']!,
                              Icons.info_outline_rounded,
                              _accentSecondary,
                            ),
                            const SizedBox(height: 16),
                            // Effects
                            _buildYogaDetailSection(
                              isDosha ? 'Potential Effects' : 'Benefits',
                              yogaDetails['effects']!,
                              isDosha
                                  ? Icons.warning_amber_outlined
                                  : Icons.star_outline_rounded,
                              isDosha
                                  ? const Color(0xFFFBBF24)
                                  : const Color(0xFF6EE7B7),
                            ),
                            const SizedBox(height: 16),
                            // Remedies (for doshas) or Enhancement (for yogas)
                            _buildYogaDetailSection(
                              isDosha ? 'Remedies' : 'How to Strengthen',
                              yogaDetails['remedies']!,
                              Icons.healing_rounded,
                              const Color(0xFF60A5FA),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildYogaDetailSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor.withOpacity(0.4), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: _textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _getFullYogaDetails(String yogaName, bool isDosha) {
    // Full details for each yoga/dosha
    final detailsMap = {
      // Pancha Mahapurusha Yogas
      'Hamsa Yoga': {
        'type': 'Pancha Mahapurusha Yoga',
        'description':
            'Hamsa Yoga is formed when Jupiter is placed in a Kendra house (1st, 4th, 7th, or 10th) in its own sign (Sagittarius or Pisces) or its exaltation sign (Cancer). This is one of the five great person yogas in Vedic astrology.',
        'effects':
            'The native is blessed with divine qualities, profound wisdom, and spiritual inclination. They gain respect from learned people, achieve good fortune, and lead a virtuous life. They often have a handsome appearance and enjoy longevity.',
        'remedies':
            'To strengthen this yoga: Worship Lord Vishnu regularly, study and teach sacred scriptures, perform charitable acts especially on Thursdays, wear yellow clothes and donate yellow items like turmeric, bananas, or gold.',
      },
      'Malavya Yoga': {
        'type': 'Pancha Mahapurusha Yoga',
        'description':
            'Malavya Yoga forms when Venus occupies a Kendra house (1st, 4th, 7th, or 10th) in its own sign (Taurus or Libra) or exaltation sign (Pisces). Named after the Malavya people known for their refined culture.',
        'effects':
            'Bestows physical beauty, artistic talents, luxurious lifestyle, happy marriage, and material wealth. The native has a magnetic personality, refined taste, and enjoys sensual pleasures while maintaining dignity.',
        'remedies':
            'To enhance: Worship Goddess Lakshmi, appreciate and support arts, maintain beauty and cleanliness, donate white items on Fridays, wear white or pastel colors, and practice gratitude for life\'s pleasures.',
      },
      'Bhadra Yoga': {
        'type': 'Pancha Mahapurusha Yoga',
        'description':
            'Bhadra Yoga occurs when Mercury is placed in a Kendra house (1st, 4th, 7th, or 10th) in its own sign (Gemini or Virgo). The word "Bhadra" means auspicious or blessed.',
        'effects':
            'Grants exceptional intelligence, eloquence, success in business and communication. The native excels in education, writing, trading, and analytical work. They are respected for their knowledge and wit.',
        'remedies':
            'To strengthen: Worship Lord Vishnu, pursue continuous learning and teaching, donate green items on Wednesdays, engage in writing or public speaking, keep an emerald or wear green clothes.',
      },
      'Ruchaka Yoga': {
        'type': 'Pancha Mahapurusha Yoga',
        'description':
            'Ruchaka Yoga is formed when Mars occupies a Kendra house (1st, 4th, 7th, or 10th) in its own sign (Aries or Scorpio) or exaltation (Capricorn). Named after the Ruchaka warrior clan.',
        'effects':
            'Bestows courage, valor, strong physique, and leadership abilities. Success in military, sports, or competitive fields. The native is fearless, commands respect, and achieves through bold decisive action.',
        'remedies':
            'To enhance: Worship Lord Hanuman, practice physical discipline and martial arts, donate red items on Tuesdays, engage in competitive sports, channel aggression constructively through exercise.',
      },
      'Sasa Yoga': {
        'type': 'Pancha Mahapurusha Yoga',
        'description':
            'Sasa Yoga forms when Saturn is in a Kendra house (1st, 4th, 7th, or 10th) in its own sign (Capricorn or Aquarius) or exaltation (Libra). It represents mastery over limitations.',
        'effects':
            'Grants authority, command over subordinates, success in politics or administration. Wealth comes through hard work and perseverance. The native rises to high positions through patience and discipline.',
        'remedies':
            'To strengthen: Worship Lord Shani, serve elderly and disabled people, donate black items on Saturdays, practice patience and discipline, engage in social service, avoid shortcuts.',
      },

      // Raja Yogas
      'Gajakesari Yoga': {
        'type': 'Raja Yoga',
        'description':
            'One of the most auspicious yogas, formed when Jupiter is in a Kendra (1st, 4th, 7th, or 10th house) from the Moon. The name means "elephant-lion" symbolizing royal power and dignity.',
        'effects':
            'The native gains wisdom, intelligence, excellent reputation, wealth, and leadership qualities. They are respected in society, achieve success through righteous conduct, and enjoy a position of influence.',
        'remedies':
            'To enhance: Worship Lord Ganesha and Jupiter, chant Guru mantras on Thursdays, donate yellow items, support educational institutions, practice generosity and ethical living.',
      },
      'Budhaditya Yoga': {
        'type': 'Raja Yoga',
        'description':
            'Formed when the Sun and Mercury are conjunct in the same sign. "Budha" (Mercury) + "Aditya" (Sun) creates intellectual brilliance illuminated by soul\'s light.',
        'effects':
            'Grants sharp intellect, excellent communication skills, success in education, fame through intellectual pursuits. The native excels in writing, speaking, analysis, and administrative work.',
        'remedies':
            'To strengthen: Worship Lord Vishnu, recite Gayatri Mantra at sunrise, donate green items on Wednesday, pursue learning and teaching, maintain ethical standards in communication.',
      },

      // Doshas
      'Manglik Dosha': {
        'type': 'Major Dosha',
        'description':
            'Also called Mangal Dosha or Kuja Dosha, formed when Mars is placed in the 1st, 4th, 7th, 8th, or 12th house from the Ascendant. Affects about 40% of people.',
        'effects':
            'May cause delays in marriage, conflicts with spouse, or challenges in married life. The strong energy of Mars needs proper channeling. Effects vary based on Mars\' sign and aspects.',
        'remedies':
            'Perform Mangal Shanti Puja, chant Hanuman Chalisa daily, fast on Tuesdays, marry another Manglik (cancels effect), perform Kumbh Vivah ritual, donate red lentils and red clothes on Tuesday.',
      },
      'Kaal Sarp Dosha': {
        'type': 'Major Dosha',
        'description':
            'Occurs when all seven planets are hemmed between Rahu and Ketu. There are 12 types based on Rahu\'s house position. Represents karmic patterns from past lives.',
        'effects':
            'May bring sudden ups and downs, struggles, delays in success, and unexpected events. The native\'s life follows unusual patterns. Effects depend on which planets are closest to nodes.',
        'remedies':
            'Visit Trimbakeshwar or Kalahasti temple for Kaal Sarp Puja, chant Maha Mrityunjaya Mantra 108 times daily, donate to snake conservation, feed birds daily, wear Gomed after consultation.',
      },
      'Pitra Dosha': {
        'type': 'Ancestral Dosha',
        'description':
            'Formed when Sun is afflicted by Rahu or Ketu, or when the 9th house (father, ancestors) is severely afflicted. Indicates unresolved ancestral karma.',
        'effects':
            'May affect father, career, fortune, and overall progress until remedied. The native may face obstacles that seem to have no logical cause. Family patterns may repeat.',
        'remedies':
            'Perform Pitra Tarpan on every Amavasya (new moon), do Shradh rituals annually, feed crows and dogs, donate to elderly care homes, visit Gaya for Pind Daan if possible.',
      },
      'Guru Chandal Yoga': {
        'type': 'Dosha',
        'description':
            'Forms when Jupiter (Guru) is conjunct with Rahu (Chandal means outcaste). Jupiter\'s wisdom is clouded by Rahu\'s illusions and unconventional influences.',
        'effects':
            'May affect wisdom, spirituality, and traditional values. The native may have unconventional or unorthodox beliefs, face challenges with teachers or gurus, or experience confusion in moral matters.',
        'remedies':
            'Worship Lord Vishnu regularly, show respect to teachers and elders, study traditional scriptures, perform Jupiter and Rahu remedies on respective days, maintain ethical conduct.',
      },
      'Kemdrum Dosha': {
        'type': 'Lunar Dosha',
        'description':
            'Occurs when the Moon has no planets in its 2nd or 12th house (excluding Sun, Rahu, and Ketu). The Moon lacks support from neighboring planets.',
        'effects':
            'May cause emotional instability, feelings of loneliness or lack of support, and mental disturbances. The native may struggle with poverty or feel emotionally unsupported despite material success.',
        'remedies':
            'Strengthen Moon by wearing pearl or moonstone (after consultation), chant Chandra mantra on Mondays, fast on Monday, wear white clothes, serve mother and elderly women.',
      },
      'Shrapit Dosha': {
        'type': 'Karmic Dosha',
        'description':
            'Forms when Saturn and Rahu are conjunct in any house. "Shrapit" means cursed, indicating heavy karmic debt from past lives that must be resolved.',
        'effects':
            'Causes delays and obstacles that require patience to overcome. The native may face repeated setbacks in specific life areas depending on the house of conjunction.',
        'remedies':
            'Perform Shrapit Dosha Nivaran Puja, serve disabled and elderly people, chant Saturn and Rahu mantras, donate black items on Saturday, practice extreme patience and karma yoga.',
      },
    };

    // Default details for yogas/doshas not in the map
    if (!detailsMap.containsKey(yogaName)) {
      return {
        'type': isDosha ? 'Dosha' : 'Benefic Yoga',
        'description':
            isDosha
                ? 'This is a challenging planetary combination that may create certain obstacles in life. Its effects depend on the overall strength of the horoscope and other supportive factors.'
                : 'This is an auspicious planetary combination that brings positive influences to your chart. Its full benefits manifest based on the overall horoscope strength.',
        'effects':
            isDosha
                ? 'The specific effects depend on the houses and signs involved. Generally, doshas indicate areas where extra attention and remedial measures can help smooth the life path.'
                : 'This yoga enhances success, prosperity, and positive outcomes in the areas of life it influences. The stronger the participating planets, the more pronounced the benefits.',
        'remedies':
            isDosha
                ? 'General remedies include: regular prayer and meditation, charitable activities, respecting elders, maintaining ethical conduct, and wearing gemstones after proper consultation with an astrologer.'
                : 'To maximize benefits: honor the planets forming this yoga through their respective mantras and charitable acts, live according to dharma, and utilize the talents this yoga provides for good purposes.',
      };
    }

    return detailsMap[yogaName]!;
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
      'Uranus': Color(0xFF22D3EE), // Cyan/Electric blue
      'Neptune': Color(0xFF818CF8), // Indigo/Deep blue
      'Pluto': Color(0xFF94A3B8), // Slate/Dark gray
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
      'Uranus': '♅',
      'Neptune': '♆',
      'Pluto': '♇',
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

  // Chart type scroll controller for centering
  final ScrollController _chartTypeScrollController = ScrollController();
  final List<GlobalKey> _chartTypeKeys = List.generate(
    KundaliType.values.length,
    (_) => GlobalKey(),
  );

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
    _chartTypeScrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // Scroll to center the selected chart type with smooth animation
  void _scrollToChartType(int index) {
    if (!_chartTypeScrollController.hasClients) return;
    if (index < 0 || index >= _chartTypeKeys.length) return;

    final key = _chartTypeKeys[index];
    final itemContext = key.currentContext;
    if (itemContext == null) return;

    final RenderBox? itemBox = itemContext.findRenderObject() as RenderBox?;
    if (itemBox == null) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = itemBox.size.width;
    final itemGlobalPosition = itemBox.localToGlobal(Offset.zero);
    final currentScroll = _chartTypeScrollController.offset;
    final itemScrollPosition = itemGlobalPosition.dx + currentScroll;
    final targetOffset =
        itemScrollPosition - (screenWidth / 2) + (itemWidth / 2);
    final maxScroll = _chartTypeScrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    _chartTypeScrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuart,
    );
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
        controller: _chartTypeScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: KundaliType.values.length,
        itemBuilder: (context, index) {
          final type = KundaliType.values[index];
          final isSelected = _currentType == type;
          final accentColor = _getTypeColor(type);

          return GestureDetector(
            key: _chartTypeKeys[index],
            onTap: () {
              _changeType(type);
              // Scroll to center the selected chart type
              Future.delayed(const Duration(milliseconds: 50), () {
                _scrollToChartType(index);
              });
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

// Custom Date Picker Widget
class _CustomDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const _CustomDatePicker({
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<_CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<_CustomDatePicker> {
  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  static const _bgPrimary = Color(0xFF0D0B14);
  static const _bgSecondary = Color(0xFF131020);
  static const _surfaceColor = Color(0xFF1A1625);
  static const _borderColor = Color(0xFF2A2438);
  static const _accentPrimary = Color(0xFFD4AF37);
  static const _accentSecondary = Color(0xFFA78BFA);
  static const _textPrimary = Color(0xFFF8F7FC);
  static const _textMuted = Color(0xFF6B6478);

  final List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDate.day;
    _selectedMonth = widget.initialDate.month;
    _selectedYear = widget.initialDate.year;
    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonth - 1,
    );
    _yearController = FixedExtentScrollController(
      initialItem: _selectedYear - 1900,
    );
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  int _getDaysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDay = now.day;
      _selectedMonth = now.month;
      _selectedYear = now.year;
    });
    _dayController.animateToItem(
      _selectedDay - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    _monthController.animateToItem(
      _selectedMonth - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    _yearController.animateToItem(
      _selectedYear - 1900,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _getDaysInMonth(_selectedMonth, _selectedYear);
    final selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);

    return Container(
      height: MediaQuery.of(context).size.height * 0.52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_bgSecondary, _bgPrimary],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Header with prominent date display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Selected date prominent display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _accentPrimary.withOpacity(0.12),
                        _accentSecondary.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _accentPrimary.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('EEEE').format(selectedDate),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _accentSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d MMMM yyyy').format(selectedDate),
                        style: GoogleFonts.dmSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Quick actions row
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _goToToday,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6EE7B7).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF6EE7B7).withOpacity(0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.today_rounded,
                                size: 14,
                                color: const Color(0xFF6EE7B7),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Today',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6EE7B7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _borderColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _textMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                        widget.onDateSelected(selectedDate);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _accentPrimary,
                              _accentPrimary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: _accentPrimary.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Confirm',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Picker labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'DAY',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      'MONTH',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      'YEAR',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Date Pickers
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: _surfaceColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borderColor.withOpacity(0.3)),
              ),
              child: Stack(
                children: [
                  // Selection highlight
                  Center(
                    child: Container(
                      height: 48,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _accentPrimary.withOpacity(0.12),
                            _accentPrimary.withOpacity(0.06),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _accentPrimary.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlays for fade effect
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _surfaceColor.withOpacity(0.9),
                            _surfaceColor.withOpacity(0.0),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            _surfaceColor.withOpacity(0.9),
                            _surfaceColor.withOpacity(0.0),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // Day picker
                      Expanded(
                        flex: 2,
                        child: ListWheelScrollView.useDelegate(
                          controller: _dayController,
                          itemExtent: 48,
                          diameterRatio: 1.2,
                          perspective: 0.002,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedDay = index + 1);
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: daysInMonth,
                            builder: (context, index) {
                              final isSelected = index + 1 == _selectedDay;
                              return Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 150),
                                  style: GoogleFonts.dmMono(
                                    fontSize: isSelected ? 22 : 16,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                    color:
                                        isSelected
                                            ? _accentPrimary
                                            : _textMuted.withOpacity(0.6),
                                  ),
                                  child: Text('${index + 1}'.padLeft(2, '0')),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Month picker
                      Expanded(
                        flex: 3,
                        child: ListWheelScrollView.useDelegate(
                          controller: _monthController,
                          itemExtent: 48,
                          diameterRatio: 1.2,
                          perspective: 0.002,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedMonth = index + 1;
                              final maxDays = _getDaysInMonth(
                                _selectedMonth,
                                _selectedYear,
                              );
                              if (_selectedDay > maxDays) {
                                _selectedDay = maxDays;
                                _dayController.jumpToItem(_selectedDay - 1);
                              }
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 12,
                            builder: (context, index) {
                              final isSelected = index + 1 == _selectedMonth;
                              return Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 150),
                                  style: GoogleFonts.dmSans(
                                    fontSize: isSelected ? 18 : 14,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                    color:
                                        isSelected
                                            ? _accentPrimary
                                            : _textMuted.withOpacity(0.6),
                                  ),
                                  child: Text(_months[index]),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Year picker
                      Expanded(
                        flex: 3,
                        child: ListWheelScrollView.useDelegate(
                          controller: _yearController,
                          itemExtent: 48,
                          diameterRatio: 1.2,
                          perspective: 0.002,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedYear = 1900 + index;
                              final maxDays = _getDaysInMonth(
                                _selectedMonth,
                                _selectedYear,
                              );
                              if (_selectedDay > maxDays) {
                                _selectedDay = maxDays;
                                _dayController.jumpToItem(_selectedDay - 1);
                              }
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 201,
                            builder: (context, index) {
                              final year = 1900 + index;
                              final isSelected = year == _selectedYear;
                              return Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 150),
                                  style: GoogleFonts.dmMono(
                                    fontSize: isSelected ? 20 : 15,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                    color:
                                        isSelected
                                            ? _accentPrimary
                                            : _textMuted.withOpacity(0.6),
                                  ),
                                  child: Text('$year'),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Custom Time Picker Widget
class _CustomTimePicker extends StatefulWidget {
  final DateTime initialTime;
  final Function(DateTime) onTimeSelected;

  const _CustomTimePicker({
    required this.initialTime,
    required this.onTimeSelected,
  });

  @override
  State<_CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<_CustomTimePicker> {
  late int _selectedHour;
  late int _selectedMinute;
  late bool _isAM;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  static const _bgPrimary = Color(0xFF0D0B14);
  static const _bgSecondary = Color(0xFF131020);
  static const _surfaceColor = Color(0xFF1A1625);
  static const _borderColor = Color(0xFF2A2438);
  static const _accentPrimary = Color(0xFFD4AF37);
  static const _accentSecondary = Color(0xFFA78BFA);
  static const _textPrimary = Color(0xFFF8F7FC);
  static const _textMuted = Color(0xFF6B6478);

  @override
  void initState() {
    super.initState();
    final hour24 = widget.initialTime.hour;
    _isAM = hour24 < 12;
    _selectedHour = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    _selectedMinute = widget.initialTime.minute;
    _hourController = FixedExtentScrollController(
      initialItem: _selectedHour - 1,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  int _get24Hour() {
    if (_isAM) {
      return _selectedHour == 12 ? 0 : _selectedHour;
    } else {
      return _selectedHour == 12 ? 12 : _selectedHour + 12;
    }
  }

  void _setCurrentTime() {
    final now = DateTime.now();
    final hour24 = now.hour;
    setState(() {
      _isAM = hour24 < 12;
      _selectedHour = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
      _selectedMinute = now.minute;
    });
    _hourController.animateToItem(
      _selectedHour - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    _minuteController.animateToItem(
      _selectedMinute,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final timeString =
        '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')} ${_isAM ? 'AM' : 'PM'}';

    return Container(
      height: MediaQuery.of(context).size.height * 0.48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_bgSecondary, _bgPrimary],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Header with prominent time display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Selected time prominent display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _accentPrimary.withOpacity(0.12),
                        _accentSecondary.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _accentPrimary.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 20,
                        color: _accentSecondary,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        timeString,
                        style: GoogleFonts.dmMono(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Quick actions row
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _setCurrentTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6EE7B7).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF6EE7B7).withOpacity(0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time_filled_rounded,
                                size: 14,
                                color: const Color(0xFF6EE7B7),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Now',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6EE7B7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _borderColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _textMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                        widget.onTimeSelected(
                          DateTime(
                            widget.initialTime.year,
                            widget.initialTime.month,
                            widget.initialTime.day,
                            _get24Hour(),
                            _selectedMinute,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _accentPrimary,
                              _accentPrimary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: _accentPrimary.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Confirm',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Time Picker
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Hour & Minute Pickers
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _surfaceColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _borderColor.withOpacity(0.3),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Selection highlight
                          Center(
                            child: Container(
                              height: 54,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _accentPrimary.withOpacity(0.12),
                                    _accentPrimary.withOpacity(0.06),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _accentPrimary.withOpacity(0.25),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                          // Gradient fades
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    _surfaceColor.withOpacity(0.9),
                                    _surfaceColor.withOpacity(0.0),
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    _surfaceColor.withOpacity(0.9),
                                    _surfaceColor.withOpacity(0.0),
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              // Hour picker
                              Expanded(
                                child: ListWheelScrollView.useDelegate(
                                  controller: _hourController,
                                  itemExtent: 54,
                                  diameterRatio: 1.2,
                                  perspective: 0.002,
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) {
                                    HapticFeedback.selectionClick();
                                    setState(() => _selectedHour = index + 1);
                                  },
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    childCount: 12,
                                    builder: (context, index) {
                                      final hour = index + 1;
                                      final isSelected = hour == _selectedHour;
                                      return Center(
                                        child: AnimatedDefaultTextStyle(
                                          duration: const Duration(
                                            milliseconds: 150,
                                          ),
                                          style: GoogleFonts.dmMono(
                                            fontSize: isSelected ? 32 : 22,
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w400,
                                            color:
                                                isSelected
                                                    ? _accentPrimary
                                                    : _textMuted.withOpacity(
                                                      0.5,
                                                    ),
                                          ),
                                          child: Text(
                                            hour.toString().padLeft(2, '0'),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Colon separator
                              Text(
                                ':',
                                style: GoogleFonts.dmMono(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: _accentPrimary,
                                ),
                              ),
                              // Minute picker
                              Expanded(
                                child: ListWheelScrollView.useDelegate(
                                  controller: _minuteController,
                                  itemExtent: 54,
                                  diameterRatio: 1.2,
                                  perspective: 0.002,
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) {
                                    HapticFeedback.selectionClick();
                                    setState(() => _selectedMinute = index);
                                  },
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    childCount: 60,
                                    builder: (context, index) {
                                      final isSelected =
                                          index == _selectedMinute;
                                      return Center(
                                        child: AnimatedDefaultTextStyle(
                                          duration: const Duration(
                                            milliseconds: 150,
                                          ),
                                          style: GoogleFonts.dmMono(
                                            fontSize: isSelected ? 32 : 22,
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w400,
                                            color:
                                                isSelected
                                                    ? _accentPrimary
                                                    : _textMuted.withOpacity(
                                                      0.5,
                                                    ),
                                          ),
                                          child: Text(
                                            index.toString().padLeft(2, '0'),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // AM/PM Selector
                  Container(
                    width: 72,
                    decoration: BoxDecoration(
                      color: _surfaceColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _borderColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _isAM = true);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 56,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient:
                                  _isAM
                                      ? LinearGradient(
                                        colors: [
                                          _accentPrimary.withOpacity(0.2),
                                          _accentPrimary.withOpacity(0.1),
                                        ],
                                      )
                                      : null,
                              color: _isAM ? null : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    _isAM
                                        ? _accentPrimary.withOpacity(0.4)
                                        : Colors.transparent,
                                width: 1,
                              ),
                              boxShadow:
                                  _isAM
                                      ? [
                                        BoxShadow(
                                          color: _accentPrimary.withOpacity(
                                            0.15,
                                          ),
                                          blurRadius: 8,
                                        ),
                                      ]
                                      : null,
                            ),
                            child: Center(
                              child: Text(
                                'AM',
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight:
                                      _isAM ? FontWeight.w700 : FontWeight.w500,
                                  color:
                                      _isAM
                                          ? _accentPrimary
                                          : _textMuted.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _isAM = false);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 56,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient:
                                  !_isAM
                                      ? LinearGradient(
                                        colors: [
                                          _accentPrimary.withOpacity(0.2),
                                          _accentPrimary.withOpacity(0.1),
                                        ],
                                      )
                                      : null,
                              color: !_isAM ? null : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    !_isAM
                                        ? _accentPrimary.withOpacity(0.4)
                                        : Colors.transparent,
                                width: 1,
                              ),
                              boxShadow:
                                  !_isAM
                                      ? [
                                        BoxShadow(
                                          color: _accentPrimary.withOpacity(
                                            0.15,
                                          ),
                                          blurRadius: 8,
                                        ),
                                      ]
                                      : null,
                            ),
                            child: Center(
                              child: Text(
                                'PM',
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight:
                                      !_isAM
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                  color:
                                      !_isAM
                                          ? _accentPrimary
                                          : _textMuted.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// A widget that displays a realistic moon phase based on tithi
class _MoonPhaseWidget extends StatelessWidget {
  final int tithiNumber; // 1-15
  final String paksha; // 'Shukla' or 'Krishna'
  final double size;

  const _MoonPhaseWidget({
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
