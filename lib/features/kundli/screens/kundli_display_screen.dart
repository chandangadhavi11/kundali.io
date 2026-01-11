import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/kundali_data_model.dart';
import '../../../core/providers/kundli_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/kundali_calculation_service.dart';
import 'package:kundali_app/l10n/generated/app_localizations.dart';
import '../widgets/kundali_chart_painter.dart';
import '../widgets/interactive_kundli_chart.dart';
import '../widgets/interactive_south_indian_chart.dart';
// Extracted tab components
import 'kundli_display/tabs/planets_tab.dart';
import 'kundli_display/tabs/houses_tab.dart';
import 'kundli_display/tabs/yogas_tab.dart';
import 'kundli_display/tabs/strength_tab.dart';
import 'kundli_display/tabs/transit_tab.dart';
import 'kundli_display/tabs/panchang_tab.dart';
import 'kundli_display/tabs/dasha_tab.dart';
import 'kundli_display/tabs/details_tab.dart';
import 'kundli_display/widgets/astro_alert_orb.dart';

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
  bool _isRecalculating = false;

  /// Returns recalculated data when custom date/time is set, otherwise original
  KundaliData get _displayKundaliData =>
      _recalculatedKundaliData ?? _kundaliData!;

  // Tap states for microinteractions
  final Map<String, bool> _pressedStates = {};

  // Astro Alert controller for expand/collapse
  final AstroAlertController _alertController = AstroAlertController();

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
    _alertController.dispose();
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
                          // Using extracted tab components - use _displayKundaliData for date/time sync
                          DetailsTab(kundaliData: _displayKundaliData),
                          PlanetsTab(kundaliData: _displayKundaliData),
                          HousesTab(kundaliData: _displayKundaliData),
                          DashaTab(kundaliData: _displayKundaliData),
                          StrengthTab(kundaliData: _displayKundaliData),
                          TransitTab(kundaliData: _displayKundaliData),
                          PanchangTab(kundaliData: _displayKundaliData),
                          YogasTab(kundaliData: _displayKundaliData),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Loading overlay during recalculation
          if (_isRecalculating)
            Positioned.fill(
              child: Container(
                color: _bgPrimary.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: _accentPrimary,
                          strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Recalculating...',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: _textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
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
                        _displayKundaliData.name,
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
                    if (_displayKundaliData.isPrimary) ...[
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
                        _displayKundaliData.birthPlace,
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
                      ).format(_displayKundaliData.birthDateTime),
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
    final l10n = AppLocalizations.of(context);
    final tabs = [
      {'icon': Icons.grid_view_rounded, 'label': l10n.display_tab_chart},
      {'icon': Icons.person_outline_rounded, 'label': l10n.display_tab_details},
      {'icon': Icons.public_rounded, 'label': l10n.display_tab_planets},
      {'icon': Icons.home_work_outlined, 'label': l10n.display_tab_houses},
      {'icon': Icons.timeline_rounded, 'label': l10n.display_tab_dasha},
      {'icon': Icons.analytics_rounded, 'label': l10n.display_tab_strength},
      {'icon': Icons.sync_rounded, 'label': l10n.display_tab_transit},
      {
        'icon': Icons.calendar_today_rounded,
        'label': l10n.display_tab_panchang,
      },
      {'icon': Icons.auto_awesome_rounded, 'label': l10n.display_tab_yogas},
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
                    AppLocalizations.of(context).display_viewChartFor,
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
                          label: AppLocalizations.of(context).display_date,
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
                          label: AppLocalizations.of(context).display_time,
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
                            AppLocalizations.of(
                              context,
                            ).display_viewCurrentTimeChart,
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

  void _showChartTypesInfoSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: _bgSecondary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border.all(
                      color: _accentSecondary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle & Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: _borderColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        _accentSecondary.withOpacity(0.2),
                                        _accentSecondary.withOpacity(0.08),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 22,
                                    color: _accentSecondary,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Chart Types Guide',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: _textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Understanding Vedic astrology charts',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: _textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _surfaceColor.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: _textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      // Chart types list
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          children: [
                            _buildChartCategorySection(
                              title:
                                  AppLocalizations.of(
                                    context,
                                  ).chart_category_primary,
                              description:
                                  AppLocalizations.of(
                                    context,
                                  ).chart_category_primary_desc,
                              charts: [
                                _ChartTypeInfo(
                                  type: KundaliType.lagna,
                                  icon: Icons.north_east_rounded,
                                  color: const Color(0xFFA78BFA),
                                  meaning:
                                      'The foundation of Vedic astrology. Shows your overall life path, personality, physical body, and general tendencies based on the rising sign at birth.',
                                ),
                                _ChartTypeInfo(
                                  type: KundaliType.chandra,
                                  icon: Icons.nightlight_round,
                                  color: const Color(0xFF6EE7B7),
                                  meaning:
                                      'Moon chart reveals your emotional nature, mind, mental patterns, and psychological tendencies. Essential for understanding inner feelings and reactions.',
                                ),
                                _ChartTypeInfo(
                                  type: KundaliType.surya,
                                  icon: Icons.wb_sunny_rounded,
                                  color: _accentPrimary,
                                  meaning:
                                      'Sun chart shows your soul purpose, ego, vitality, father, authority figures, and career in government or leadership roles.',
                                ),
                                _ChartTypeInfo(
                                  type: KundaliType.bhavaChalit,
                                  icon: Icons.swap_horiz_rounded,
                                  color: const Color(0xFF60A5FA),
                                  meaning:
                                      'Uses exact house cusps to show where planets actually influence. More accurate for predicting which house matters each planet truly affects.',
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildChartCategorySection(
                              title:
                                  AppLocalizations.of(
                                    context,
                                  ).chart_category_divisional,
                              description:
                                  AppLocalizations.of(
                                    context,
                                  ).chart_category_divisional_desc,
                              charts: [
                                _ChartTypeInfo(
                                  type: KundaliType.navamsa,
                                  icon: Icons.favorite_rounded,
                                  color: const Color(0xFFF472B6),
                                  meaning:
                                      'D9 - The most important divisional chart. Reveals marriage quality, spouse nature, dharma (life purpose), and the strength of planets. Shows the soul\'s deeper journey.',
                                ),
                                _ChartTypeInfo(
                                  type: KundaliType.dasamsa,
                                  icon: Icons.work_rounded,
                                  color: const Color(0xFF60A5FA),
                                  meaning:
                                      'D10 - Career and profession chart. Shows professional success, status in society, recognition, and the type of work that brings fulfillment.',
                                ),
                                _ChartTypeInfo(
                                  type: KundaliType.saptamsa,
                                  icon: Icons.child_care_rounded,
                                  color: const Color(0xFFFBBF24),
                                  meaning:
                                      'D7 - Children and progeny chart. Indicates fertility, number of children, relationship with children, and creative output.',
                                ),
                                _ChartTypeInfo(
                                  type: KundaliType.dwadasamsa,
                                  icon: Icons.people_rounded,
                                  color: const Color(0xFF34D399),
                                  meaning:
                                      'D12 - Parents chart. Shows relationship with parents, ancestral karma, and family lineage influences.',
                                ),
                                _ChartTypeInfo(
                                  type: KundaliType.trimshamsa,
                                  icon: Icons.warning_amber_rounded,
                                  color: const Color(0xFFF87171),
                                  meaning:
                                      'D30 - Misfortunes chart. Reveals potential challenges, health issues, accidents, and areas requiring caution.',
                                ),
                                _ChartTypeInfo(
                                  type: KundaliType.hora,
                                  icon: Icons.attach_money_rounded,
                                  color: const Color(0xFFFFD700),
                                  meaning:
                                      'D2 - Wealth chart. Shows financial potential, earning capacity, and accumulation of material resources.',
                                ),
                                _ChartTypeInfo(
                                  type: KundaliType.drekkana,
                                  icon: Icons.fitness_center_rounded,
                                  color: const Color(0xFFFF6B6B),
                                  meaning:
                                      'D3 - Siblings and courage chart. Reveals relationship with siblings, personal courage, and communication abilities.',
                                ),
                                _ChartTypeInfo(
                                  type: KundaliType.chaturthamsa,
                                  icon: Icons.home_rounded,
                                  color: const Color(0xFF4ECDC4),
                                  meaning:
                                      'D4 - Property and fortune chart. Shows real estate luck, vehicles, fixed assets, and overall material fortune.',
                                ),
                                _ChartTypeInfo(
                                  type: KundaliType.shodasamsa,
                                  icon: Icons.directions_car_rounded,
                                  color: const Color(0xFF9B59B6),
                                  meaning:
                                      'D16 - Vehicles and comforts chart. Indicates conveyances, luxuries, and physical pleasures.',
                                ),
                                _ChartTypeInfo(
                                  type: KundaliType.vimsamsa,
                                  icon: Icons.self_improvement_rounded,
                                  color: const Color(0xFF00CED1),
                                  meaning:
                                      'D20 - Spiritual progress chart. Shows religious inclinations, meditation abilities, and spiritual evolution.',
                                ),
                                _ChartTypeInfo(
                                  type: KundaliType.chaturvimsamsa,
                                  icon: Icons.school_rounded,
                                  color: const Color(0xFFE91E63),
                                  meaning:
                                      'D24 - Education chart. Reveals academic abilities, learning capacity, and success in studies.',
                                ),
                                _ChartTypeInfo(
                                  type: KundaliType.bhamsa,
                                  icon: Icons.stars_rounded,
                                  color: const Color(0xFF8E44AD),
                                  meaning:
                                      'D27 - Strength chart (Nakshatramsa). Shows inherent strengths, weaknesses, and physical vitality.',
                                ),
                                _ChartTypeInfo(
                                  type: KundaliType.khavedamsa,
                                  icon: Icons.auto_awesome_rounded,
                                  color: const Color(0xFF27AE60),
                                  meaning:
                                      'D40 - Auspicious effects chart. Indicates overall luck and positive karmic influences.',
                                ),
                                _ChartTypeInfo(
                                  type: KundaliType.akshavedamsa,
                                  icon: Icons.balance_rounded,
                                  color: const Color(0xFF3498DB),
                                  meaning:
                                      'D45 - General indications chart. Provides additional confirmation for predictions.',
                                ),
                                _ChartTypeInfo(
                                  type: KundaliType.shashtiamsa,
                                  icon: Icons.history_rounded,
                                  color: const Color(0xFFE74C3C),
                                  meaning:
                                      'D60 - Past life karma chart. The most subtle chart showing deep karmic patterns from previous lives.',
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildChartCategorySection(
                              title:
                                  AppLocalizations.of(
                                    context,
                                  ).chart_category_special,
                              description:
                                  AppLocalizations.of(
                                    context,
                                  ).chart_category_special_desc,
                              charts: [
                                _ChartTypeInfo(
                                  type: KundaliType.sudarshan,
                                  icon: Icons.blur_circular_rounded,
                                  color: const Color(0xFFFF9800),
                                  meaning:
                                      'Triple chart view combining Lagna, Moon, and Sun charts. Provides a holistic view of all three perspectives together.',
                                ),
                                _ChartTypeInfo(
                                  type: KundaliType.ashtakavarga,
                                  icon: Icons.grid_4x4_rounded,
                                  color: const Color(0xFF795548),
                                  meaning:
                                      'Point-based strength analysis. Calculates bindus (points) for each planet to determine favorable transits and house strengths.',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Info tip at bottom
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _surfaceColor.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _accentPrimary.withOpacity(0.2),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline_rounded,
                                    size: 18,
                                    color: _accentPrimary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Tap on any chart type in the selector to switch views and explore different aspects of your Kundali.',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 11,
                                        color: _textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

  Widget _buildChartCategorySection({
    required String title,
    required String description,
    required List<_ChartTypeInfo> charts,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: _accentPrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            description,
            style: GoogleFonts.dmSans(fontSize: 11, color: _textMuted),
          ),
        ),
        const SizedBox(height: 12),
        ...charts.map((info) => _buildChartTypeInfoCard(info)),
      ],
    );
  }

  Widget _buildChartTypeInfoCard(_ChartTypeInfo info) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: info.color.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: info.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(info.icon, size: 20, color: info.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      info.type.displayName,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: info.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        info.type.shortName,
                        style: GoogleFonts.dmMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: info.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  info.meaning,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: _textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  // NOTE: Details tab moved to tabs/details_tab.dart
  // Removed: _buildDetailsTab, _buildAscendantDetails, _buildNakshatraDetails,
  //          _buildPanchangDetails, _buildCurrentDashaDetails, _buildCompatibilityDetails,
  //          _buildLuckyFactors, _buildPlanetaryStatus, _buildDetailCard, _buildDetailItem,
  //          _buildGunaItem, _buildStatusRow, and all related helper methods

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
  String _getChartTypeLabel(KundaliType type, AppLocalizations l10n) {
    switch (type) {
      case KundaliType.lagna:
        return l10n.chart_lagna;
      case KundaliType.chandra:
        return l10n.chart_moon;
      case KundaliType.surya:
        return l10n.chart_sun;
      case KundaliType.bhavaChalit:
        return l10n.chart_bhava;
      case KundaliType.hora:
        return l10n.chart_hora;
      case KundaliType.drekkana:
        return l10n.chart_drekkana;
      case KundaliType.chaturthamsa:
        return l10n.chart_chaturthamsa;
      case KundaliType.saptamsa:
        return l10n.chart_saptamsa;
      case KundaliType.navamsa:
        return l10n.chart_navamsa;
      case KundaliType.dasamsa:
        return l10n.chart_dasamsa;
      case KundaliType.dwadasamsa:
        return l10n.chart_dwadasamsa;
      case KundaliType.shodasamsa:
        return l10n.chart_shodasamsa;
      case KundaliType.vimsamsa:
        return l10n.chart_vimsamsa;
      case KundaliType.chaturvimsamsa:
        return l10n.chart_chaturvimsamsa;
      case KundaliType.bhamsa:
        return l10n.chart_bhamsa;
      case KundaliType.trimshamsa:
        return l10n.chart_trimshamsa;
      case KundaliType.khavedamsa:
        return l10n.chart_khavedamsa;
      case KundaliType.akshavedamsa:
        return l10n.chart_akshavedamsa;
      case KundaliType.shashtiamsa:
        return l10n.chart_shashtiamsa;
      case KundaliType.sudarshan:
        return l10n.chart_sudarshan;
      case KundaliType.ashtakavarga:
        return l10n.chart_ashtakavarga;
    }
  }

  // Get localized planet abbreviations map
  Map<String, String> _getPlanetAbbreviations(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return {
      'Sun': l10n.planet_sun_abbr,
      'Moon': l10n.planet_moon_abbr,
      'Mars': l10n.planet_mars_abbr,
      'Mercury': l10n.planet_mercury_abbr,
      'Jupiter': l10n.planet_jupiter_abbr,
      'Venus': l10n.planet_venus_abbr,
      'Saturn': l10n.planet_saturn_abbr,
      'Rahu': l10n.planet_rahu_abbr,
      'Ketu': l10n.planet_ketu_abbr,
      'Uranus': l10n.planet_uranus_abbr,
      'Neptune': l10n.planet_neptune_abbr,
      'Pluto': l10n.planet_pluto_abbr,
    };
  }

  // Get localized sign abbreviations map
  Map<String, String> _getSignAbbreviations(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return {
      'Aries': l10n.zodiac_aries_abbr,
      'Taurus': l10n.zodiac_taurus_abbr,
      'Gemini': l10n.zodiac_gemini_abbr,
      'Cancer': l10n.zodiac_cancer_abbr,
      'Leo': l10n.zodiac_leo_abbr,
      'Virgo': l10n.zodiac_virgo_abbr,
      'Libra': l10n.zodiac_libra_abbr,
      'Scorpio': l10n.zodiac_scorpio_abbr,
      'Sagittarius': l10n.zodiac_sagittarius_abbr,
      'Capricorn': l10n.zodiac_capricorn_abbr,
      'Aquarius': l10n.zodiac_aquarius_abbr,
      'Pisces': l10n.zodiac_pisces_abbr,
    };
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
                    AppLocalizations.of(context).display_northIndian,
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
                    AppLocalizations.of(context).display_southIndian,
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
    final houses = _currentHouses ?? _displayKundaliData.houses;
    final planets =
        _currentPlanetPositions ?? _displayKundaliData.planetPositions;
    final ascSign = _currentAscendantSign ?? _displayKundaliData.ascendant.sign;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor.withOpacity(0.4), width: 0.5),
      ),
      child: Column(
        children: [
          // Compact header with style selector, alert orb, and fullscreen button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Chart Style Selector (North/South) - compact
              _buildCompactChartStyleSelector(),
              // Right side: Alert Orb + Fullscreen button
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Astro Alert Orb - triggers expand/collapse of section below
                  AstroAlertOrb(
                    kundaliData: _displayKundaliData,
                    controller: _alertController,
                    transitDate: _customDateTime,
                  ),
                  const SizedBox(width: 8),
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
            ],
          ),
          const SizedBox(height: 12),
          // Expandable alerts section - animates in/out between header and chart
          AstroAlertExpandedSection(
            kundaliData: _displayKundaliData,
            controller: _alertController,
            transitDate: _customDateTime,
          ),
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
                        planetAbbreviations: _getPlanetAbbreviations(context),
                        signAbbreviations: _getSignAbbreviations(context),
                        useLetterSpacing:
                            Localizations.localeOf(context).languageCode ==
                            'en',
                      )
                      : _currentChartStyle == ChartStyle.southIndian
                      ? InteractiveSouthIndianChart(
                        key: ValueKey('south_${_currentChartType.name}'),
                        houses: houses,
                        planetPositions: planets,
                        ascendantSign: ascSign,
                        isDarkMode: true,
                        planetAbbreviations: _getPlanetAbbreviations(context),
                        signAbbreviations: _getSignAbbreviations(context),
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

  /// Check if a name looks like a date format (contains date patterns)
  bool _isDateBasedName(String name) {
    // Common date patterns: "9 Jan 2026", "Jan 9, 2026", "2026-01-09", etc.
    // Check for month names
    final monthPattern = RegExp(
      r'\b(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\b',
      caseSensitive: false,
    );
    // Check for year pattern (4 digits)
    final yearPattern = RegExp(r'\b(19|20)\d{2}\b');
    // Check for time pattern (h:mm or hh:mm with AM/PM)
    final timePattern = RegExp(r'\d{1,2}:\d{2}\s*(AM|PM|am|pm)?');

    // If name contains month name + year, or time pattern, it's likely date-based
    return (monthPattern.hasMatch(name) && yearPattern.hasMatch(name)) ||
        (timePattern.hasMatch(name) && yearPattern.hasMatch(name));
  }

  void _recalculateKundaliData() {
    if (_customDateTime == null) {
      _recalculatedKundaliData = null;
      _isRecalculating = false;
      return;
    }

    // Show loading state briefly
    _isRecalculating = true;

    // Determine the name: if original name is date-based, update to new date
    String displayName = _kundaliData!.name;
    if (_isDateBasedName(displayName)) {
      // Format the new date/time as the name
      displayName = DateFormat('d MMM yyyy, h:mm a').format(_customDateTime!);
    }

    // Recalculate Kundali with custom date/time
    _recalculatedKundaliData = KundaliData.fromBirthDetails(
      id: 'temp_${_customDateTime!.millisecondsSinceEpoch}',
      name: displayName,
      birthDateTime: _customDateTime!,
      birthPlace: _kundaliData!.birthPlace,
      latitude: _kundaliData!.latitude,
      longitude: _kundaliData!.longitude,
      timezone: _kundaliData!.timezone,
      gender: _kundaliData!.gender,
      chartStyle: _kundaliData!.chartStyle,
    );

    // Hide loading state after calculation
    _isRecalculating = false;
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
        // Section label with info CTA
        Row(
          children: [
            Icon(
              Icons.auto_awesome_mosaic_rounded,
              size: 13,
              color: _textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              AppLocalizations.of(context).display_selectChartType,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _textMuted,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showChartTypesInfoSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _accentSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _accentSecondary.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 12,
                      color: _accentSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context).display_learnMore,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _accentSecondary,
                      ),
                    ),
                  ],
                ),
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
                        _getChartTypeLabel(type, AppLocalizations.of(context)),
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
            kundaliData: _displayKundaliData,
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

  // NOTE: All tabs moved to kundli_display/tabs/ folder
  // NOTE: Details tab moved to tabs/details_tab.dart

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
            Text(
              AppLocalizations.of(context).display_shareComingSoon,
              style: GoogleFonts.dmSans(fontSize: 13),
            ),
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
    final l10n = AppLocalizations.of(context);
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
            _buildMenuItem(
              Icons.picture_as_pdf_outlined,
              l10n.display_menu_exportPdf,
              () {},
            ),
            _buildMenuItem(
              Icons.star_outline_rounded,
              l10n.display_menu_setAsPrimary,
              () {
                Navigator.pop(context);
                context.read<KundliProvider>().setPrimaryKundali(
                  _kundaliData!.id,
                );
                HapticFeedback.mediumImpact();
              },
            ),
            _buildMenuItem(
              Icons.copy_outlined,
              l10n.display_menu_duplicate,
              () {},
            ),
            _buildMenuItem(
              Icons.language_rounded,
              l10n.display_menu_language,
              () {
                Navigator.pop(context);
                _showLanguageSheet();
              },
            ),
            _buildMenuItem(
              Icons.delete_outline_rounded,
              l10n.display_menu_delete,
              () {},
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet() {
    HapticFeedback.lightImpact();
    final languageProvider = context.read<LanguageProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _LanguageSelectionSheet(
            currentLanguageCode: languageProvider.currentLanguageCode,
            onLanguageSelected: (languageCode) async {
              Navigator.pop(context);
              await languageProvider.changeLanguage(languageCode);
              HapticFeedback.mediumImpact();
              final languageName =
                  AppConstants.supportedLanguages[languageCode] ?? languageCode;
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(
                        context,
                      ).language_changed(languageName),
                    ),
                    backgroundColor: _accentPrimary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
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
                    _getTypeLabel(type, AppLocalizations.of(context)),
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
  String _getTypeLabel(KundaliType type, AppLocalizations l10n) {
    switch (type) {
      case KundaliType.lagna:
        return l10n.chart_lagna;
      case KundaliType.chandra:
        return l10n.chart_moon;
      case KundaliType.surya:
        return l10n.chart_sun;
      case KundaliType.bhavaChalit:
        return l10n.chart_bhava;
      case KundaliType.hora:
        return l10n.chart_hora;
      case KundaliType.drekkana:
        return l10n.chart_drekkana;
      case KundaliType.chaturthamsa:
        return l10n.chart_chaturthamsa;
      case KundaliType.saptamsa:
        return l10n.chart_saptamsa;
      case KundaliType.navamsa:
        return l10n.chart_navamsa;
      case KundaliType.dasamsa:
        return l10n.chart_dasamsa;
      case KundaliType.dwadasamsa:
        return l10n.chart_dwadasamsa;
      case KundaliType.shodasamsa:
        return l10n.chart_shodasamsa;
      case KundaliType.vimsamsa:
        return l10n.chart_vimsamsa;
      case KundaliType.chaturvimsamsa:
        return l10n.chart_chaturvimsamsa;
      case KundaliType.bhamsa:
        return l10n.chart_bhamsa;
      case KundaliType.trimshamsa:
        return l10n.chart_trimshamsa;
      case KundaliType.khavedamsa:
        return l10n.chart_khavedamsa;
      case KundaliType.akshavedamsa:
        return l10n.chart_akshavedamsa;
      case KundaliType.shashtiamsa:
        return l10n.chart_shashtiamsa;
      case KundaliType.sudarshan:
        return l10n.chart_sudarshan;
      case KundaliType.ashtakavarga:
        return l10n.chart_ashtakavarga;
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

  // Get localized planet abbreviations map
  Map<String, String> _getPlanetAbbreviations(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return {
      'Sun': l10n.planet_sun_abbr,
      'Moon': l10n.planet_moon_abbr,
      'Mars': l10n.planet_mars_abbr,
      'Mercury': l10n.planet_mercury_abbr,
      'Jupiter': l10n.planet_jupiter_abbr,
      'Venus': l10n.planet_venus_abbr,
      'Saturn': l10n.planet_saturn_abbr,
      'Rahu': l10n.planet_rahu_abbr,
      'Ketu': l10n.planet_ketu_abbr,
      'Uranus': l10n.planet_uranus_abbr,
      'Neptune': l10n.planet_neptune_abbr,
      'Pluto': l10n.planet_pluto_abbr,
    };
  }

  // Get localized sign abbreviations map
  Map<String, String> _getSignAbbreviations(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return {
      'Aries': l10n.zodiac_aries_abbr,
      'Taurus': l10n.zodiac_taurus_abbr,
      'Gemini': l10n.zodiac_gemini_abbr,
      'Cancer': l10n.zodiac_cancer_abbr,
      'Leo': l10n.zodiac_leo_abbr,
      'Virgo': l10n.zodiac_virgo_abbr,
      'Libra': l10n.zodiac_libra_abbr,
      'Scorpio': l10n.zodiac_scorpio_abbr,
      'Sagittarius': l10n.zodiac_sagittarius_abbr,
      'Capricorn': l10n.zodiac_capricorn_abbr,
      'Aquarius': l10n.zodiac_aquarius_abbr,
      'Pisces': l10n.zodiac_pisces_abbr,
    };
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
          planetAbbreviations: _getPlanetAbbreviations(context),
          signAbbreviations: _getSignAbbreviations(context),
          useLetterSpacing:
              Localizations.localeOf(context).languageCode == 'en',
        );
      case ChartStyle.southIndian:
        return InteractiveSouthIndianChart(
          key: ValueKey('south_${_currentType.name}'),
          houses: houses,
          planetPositions: planets,
          ascendantSign: ascSign,
          isDarkMode: true,
          planetAbbreviations: _getPlanetAbbreviations(context),
          signAbbreviations: _getSignAbbreviations(context),
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
                          AppLocalizations.of(context).common_confirm,
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
    final l10n = AppLocalizations.of(context);
    final timeString =
        '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')} ${_isAM ? l10n.display_am : l10n.display_pm}';

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
                          AppLocalizations.of(context).common_confirm,
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

/// Helper class for chart type information display
class _ChartTypeInfo {
  final KundaliType type;
  final IconData icon;
  final Color color;
  final String meaning;

  const _ChartTypeInfo({
    required this.type,
    required this.icon,
    required this.color,
    required this.meaning,
  });
}

/// Language selection bottom sheet
class _LanguageSelectionSheet extends StatefulWidget {
  final String currentLanguageCode;
  final void Function(String) onLanguageSelected;

  const _LanguageSelectionSheet({
    required this.currentLanguageCode,
    required this.onLanguageSelected,
  });

  @override
  State<_LanguageSelectionSheet> createState() =>
      _LanguageSelectionSheetState();
}

class _LanguageSelectionSheetState extends State<_LanguageSelectionSheet>
    with SingleTickerProviderStateMixin {
  // Color palette
  static const _bgSheet = Color(0xFF0F0D16);
  static const _surfaceColor = Color(0xFF181522);
  static const _borderColor = Color(0xFF252232);
  static const _accentPrimary = Color(0xFFD4AF37);
  static const _textPrimary = Color(0xFFF5F4F8);

  // Get languages dynamically from AppConstants
  List<Map<String, String>> get _languages {
    return AppConstants.supportedLanguages.entries
        .map((e) => {'code': e.key, 'native': e.value})
        .toList();
  }

  String? _pressedItem;
  late AnimationController _animController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _slideAnimation.value)),
          child: Opacity(opacity: _slideAnimation.value, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _bgSheet,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              // Handle
              Container(
                width: 32,
                height: 3,
                decoration: BoxDecoration(
                  color: _borderColor,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(height: 18),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _accentPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Icon(
                        Icons.translate_rounded,
                        size: 14,
                        color: _accentPrimary.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context).language_title,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Language grid
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < _languages.length; i += 2)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i < _languages.length - 2 ? 3 : 0,
                        ),
                        child: Row(
                          children: [
                            Expanded(child: _buildLanguageTile(_languages[i])),
                            const SizedBox(width: 3),
                            Expanded(
                              child:
                                  i + 1 < _languages.length
                                      ? _buildLanguageTile(_languages[i + 1])
                                      : const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile(Map<String, String> lang) {
    final code = lang['code']!;
    final native = lang['native']!;
    final isSelected = widget.currentLanguageCode == code;
    final isPressed = _pressedItem == code;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedItem = code),
      onTapUp: (_) => setState(() => _pressedItem = null),
      onTapCancel: () => setState(() => _pressedItem = null),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onLanguageSelected(code);
      },
      child: AnimatedScale(
        scale: isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? _accentPrimary.withOpacity(0.08)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  native,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? _accentPrimary : _textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _accentPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 10,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
