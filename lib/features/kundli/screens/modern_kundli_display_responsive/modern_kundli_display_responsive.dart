import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import '../../../../shared/models/kundali_data_model.dart';
import '../../../../core/constants/app_colors.dart';

// Responsive Modern Kundli Display with Visualizations
// Full implementation with circular charts, adaptive cards, and gestures

// Breakpoints
class KundliDisplayBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double ultraWide = 1800;
}

// Screen sizes
enum ScreenSize { mobile, tablet, desktop, ultraWide }

// Layout modes
enum DisplayLayout {
  single, // Mobile - single column
  split, // Tablet - chart + info
  grid, // Desktop - multi-grid
  dashboard, // Ultra-wide - full dashboard
}

// View modes
enum ViewMode { chart, details, analysis, predictions, export }

// Chart interaction state
class ChartInteractionState {
  final double scale;
  final Offset offset;
  final double rotation;
  final bool isInteracting;
  final Offset? touchPoint;

  ChartInteractionState({
    this.scale = 1.0,
    this.offset = Offset.zero,
    this.rotation = 0.0,
    this.isInteracting = false,
    this.touchPoint,
  });

  ChartInteractionState copyWith({
    double? scale,
    Offset? offset,
    double? rotation,
    bool? isInteracting,
    Offset? touchPoint,
  }) {
    return ChartInteractionState(
      scale: scale ?? this.scale,
      offset: offset ?? this.offset,
      rotation: rotation ?? this.rotation,
      isInteracting: isInteracting ?? this.isInteracting,
      touchPoint: touchPoint ?? this.touchPoint,
    );
  }
}

class ModernKundliDisplayResponsive extends StatefulWidget {
  final KundaliData kundaliData;

  const ModernKundliDisplayResponsive({super.key, required this.kundaliData});

  @override
  State<ModernKundliDisplayResponsive> createState() =>
      _ModernKundliDisplayResponsiveState();
}

class _ModernKundliDisplayResponsiveState
    extends State<ModernKundliDisplayResponsive>
    with TickerProviderStateMixin {
  // Controllers
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // Animation controllers
  late AnimationController _chartAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _tooltipAnimationController;
  late AnimationController _fullscreenAnimationController;
  late AnimationController _rotationAnimationController;

  // Animations
  late Animation<double> _chartScaleAnimation;
  late Animation<double> _chartRotationAnimation;
  late List<Animation<double>> _cardFadeAnimations;
  late Animation<double> _tooltipAnimation;
  late Animation<double> _fullscreenAnimation;

  // State
  // ignore: unused_field
  ViewMode _currentView = ViewMode.chart;
  ChartStyle _chartStyle = ChartStyle.northIndian;
  DisplayLayout _currentLayout = DisplayLayout.single;
  ChartInteractionState _interactionState = ChartInteractionState();
  bool _isFullscreen = false;
  bool _showTooltip = false;
  String _tooltipText = '';
  Offset _tooltipPosition = Offset.zero;
  final int _selectedPlanetIndex = -1;
  final int _selectedHouseIndex = -1;

  // Gesture detection
  double _baseScale = 1.0;
  Offset _baseFocalPoint = Offset.zero;
  // ignore: unused_field
  final double _currentRotation = 0.0;
  Timer? _tooltipTimer;

  // Export options
  bool _showExportOptions = false;

  // Responsive values
  ScreenSize _currentScreenSize = ScreenSize.mobile;
  double _chartSize = 300;
  int _gridColumns = 1;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
    _chartStyle = widget.kundaliData.chartStyle;
  }

  void _initControllers() {
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _currentView = ViewMode.chart;
            break;
          case 1:
            _currentView = ViewMode.details;
            break;
          case 2:
            _currentView = ViewMode.analysis;
            break;
          case 3:
            _currentView = ViewMode.predictions;
            break;
          case 4:
            _currentView = ViewMode.export;
            break;
        }
      });
    });
  }

  void _initAnimations() {
    // Chart animation
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _chartScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _chartAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _chartRotationAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _chartAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Card animations
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _cardFadeAnimations = List.generate(10, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardAnimationController,
          curve: Interval(
            index * 0.08,
            0.5 + index * 0.08,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    // Tooltip animation
    _tooltipAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _tooltipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _tooltipAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Fullscreen animation
    _fullscreenAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fullscreenAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fullscreenAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Rotation animation
    _rotationAnimationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    // Start animations
    _chartAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _cardAnimationController.forward();
      }
    });
  }

  // Get screen size
  ScreenSize _getScreenSize(double width) {
    if (width < KundliDisplayBreakpoints.mobile) return ScreenSize.mobile;
    if (width < KundliDisplayBreakpoints.tablet) return ScreenSize.tablet;
    if (width < KundliDisplayBreakpoints.desktop) return ScreenSize.desktop;
    return ScreenSize.ultraWide;
  }

  // Get display layout
  DisplayLayout _getDisplayLayout(ScreenSize screenSize, bool isLandscape) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return DisplayLayout.single;
      case ScreenSize.tablet:
        return isLandscape ? DisplayLayout.split : DisplayLayout.single;
      case ScreenSize.desktop:
        return DisplayLayout.grid;
      case ScreenSize.ultraWide:
        return DisplayLayout.dashboard;
    }
  }

  // Get chart size
  double _getChartSize(double width, ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return width * 0.85;
      case ScreenSize.tablet:
        return math.min(width * 0.5, 400);
      case ScreenSize.desktop:
        return math.min(width * 0.4, 500);
      case ScreenSize.ultraWide:
        return math.min(width * 0.35, 600);
    }
  }

  // Get grid columns
  int _getGridColumns(ScreenSize screenSize, DisplayLayout layout) {
    switch (layout) {
      case DisplayLayout.single:
        return 1;
      case DisplayLayout.split:
        return 2;
      case DisplayLayout.grid:
        return 3;
      case DisplayLayout.dashboard:
        return 4;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _chartAnimationController.dispose();
    _cardAnimationController.dispose();
    _tooltipAnimationController.dispose();
    _fullscreenAnimationController.dispose();
    _rotationAnimationController.dispose();
    _tooltipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final screenSize = _getScreenSize(screenWidth);
        final isLandscape = screenWidth > screenHeight;
        final layout = _getDisplayLayout(screenSize, isLandscape);

        // Update responsive values
        if (_currentScreenSize != screenSize) {
          _currentScreenSize = screenSize;
          _chartSize = _getChartSize(screenWidth, screenSize);
          _gridColumns = _getGridColumns(screenSize, layout);
        }

        if (_currentLayout != layout) {
          _currentLayout = layout;
        }

        // Fullscreen mode
        if (_isFullscreen) {
          return _buildFullscreenView(context, screenSize);
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: _buildResponsiveLayout(
            context,
            screenSize,
            layout,
            screenWidth,
            screenHeight,
          ),
        );
      },
    );
  }

  // Build responsive layout
  Widget _buildResponsiveLayout(
    BuildContext context,
    ScreenSize screenSize,
    DisplayLayout layout,
    double screenWidth,
    double screenHeight,
  ) {
    switch (layout) {
      case DisplayLayout.single:
        return _buildSingleLayout(context, screenSize);
      case DisplayLayout.split:
        return _buildSplitLayout(context, screenSize, screenWidth);
      case DisplayLayout.grid:
        return _buildGridLayout(context, screenSize, screenWidth);
      case DisplayLayout.dashboard:
        return _buildDashboardLayout(context, screenSize, screenWidth);
    }
  }

  // Single column layout for mobile
  Widget _buildSingleLayout(BuildContext context, ScreenSize screenSize) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App bar
        _buildSliverAppBar(context, screenSize),

        // Chart section
        SliverToBoxAdapter(child: _buildChartSection(context, screenSize)),

        // Info cards
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: _buildInfoCardsSliver(context, screenSize),
        ),

        // Export options
        if (_showExportOptions)
          SliverToBoxAdapter(child: _buildExportSection(context, screenSize)),
      ],
    );
  }

  // Split layout for tablet
  Widget _buildSplitLayout(
    BuildContext context,
    ScreenSize screenSize,
    double screenWidth,
  ) {
    return Row(
      children: [
        // Chart panel
        SizedBox(
          width: screenWidth * 0.5,
          child: Column(
            children: [
              _buildCompactHeader(context, screenSize),
              Expanded(child: _buildChartSection(context, screenSize)),
            ],
          ),
        ),

        // Info panel
        Expanded(
          child: Column(
            children: [
              _buildTabBar(context, screenSize),
              Expanded(child: _buildTabContent(context, screenSize)),
            ],
          ),
        ),
      ],
    );
  }

  // Grid layout for desktop
  Widget _buildGridLayout(
    BuildContext context,
    ScreenSize screenSize,
    double screenWidth,
  ) {
    return Column(
      children: [
        // Header
        _buildDesktopHeader(context, screenSize),

        // Main content
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chart section
              Container(
                width: screenWidth * 0.4,
                padding: const EdgeInsets.all(20),
                child: _buildChartSection(context, screenSize),
              ),

              // Info grid
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildInfoGrid(context, screenSize),
                ),
              ),
            ],
          ),
        ),

        // Bottom actions
        _buildBottomActions(context, screenSize),
      ],
    );
  }

  // Dashboard layout for ultra-wide
  Widget _buildDashboardLayout(
    BuildContext context,
    ScreenSize screenSize,
    double screenWidth,
  ) {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              right: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: _buildSidebar(context, screenSize),
        ),

        // Main content area
        Expanded(
          child: Column(
            children: [
              _buildDashboardHeader(context, screenSize),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Chart and primary info row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Chart
                          Container(
                            width: _chartSize,
                            height: _chartSize,
                            margin: const EdgeInsets.only(right: 24),
                            child: _buildChartSection(context, screenSize),
                          ),

                          // Primary info
                          Expanded(
                            child: _buildPrimaryInfoColumn(context, screenSize),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Secondary info grid
                      _buildInfoGrid(context, screenSize),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Right panel
        Container(
          width: 320,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.5),
            border: Border(
              left: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: _buildRightPanel(context, screenSize),
        ),
      ],
    );
  }

  // Build sliver app bar
  Widget _buildSliverAppBar(BuildContext context, ScreenSize screenSize) {
    final isCompact = screenSize == ScreenSize.mobile;

    return SliverAppBar(
      expandedHeight: isCompact ? 180 : 220,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.kundaliData.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isCompact ? 16 : 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated background pattern
              AnimatedBuilder(
                animation: _rotationAnimationController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: ConstellationPainter(
                      rotation:
                          _rotationAnimationController.value * 2 * math.pi,
                      color: AppColors.primary.withOpacity(0.05),
                    ),
                  );
                },
              ),

              // Birth info
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(isCompact ? 16 : 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_buildBirthInfoRow(context, screenSize)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: _buildAppBarActions(context, screenSize),
    );
  }

  // Build compact header
  Widget _buildCompactHeader(BuildContext context, ScreenSize screenSize) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.person, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.kundaliData.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatBirthDateTime(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: _toggleFullscreen,
            tooltip: 'Fullscreen',
          ),
        ],
      ),
    );
  }

  // Build desktop header
  Widget _buildDesktopHeader(BuildContext context, ScreenSize screenSize) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                widget.kundaliData.name[0].toUpperCase(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.kundaliData.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_formatBirthDateTime()} • ${widget.kundaliData.birthPlace}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderActions(context, screenSize),
        ],
      ),
    );
  }

  // Build chart section
  Widget _buildChartSection(BuildContext context, ScreenSize screenSize) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Chart container
        AnimatedBuilder(
          animation: _chartScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _chartScaleAnimation.value,
              child: Transform.rotate(
                angle: _chartRotationAnimation.value,
                child: Container(
                  width: _chartSize,
                  height: _chartSize,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildInteractiveChart(context, screenSize),
                  ),
                ),
              ),
            );
          },
        ),

        // Chart controls
        if (screenSize != ScreenSize.mobile)
          Positioned(
            top: 16,
            right: 16,
            child: _buildChartControls(context, screenSize),
          ),

        // Tooltip
        if (_showTooltip)
          Positioned(
            left: _tooltipPosition.dx,
            top: _tooltipPosition.dy,
            child: _buildTooltip(context, screenSize),
          ),
      ],
    );
  }

  // Build interactive chart
  Widget _buildInteractiveChart(BuildContext context, ScreenSize screenSize) {
    final isTouch =
        screenSize == ScreenSize.mobile || screenSize == ScreenSize.tablet;

    return GestureDetector(
      // Touch gestures for mobile/tablet
      onScaleStart: isTouch ? _onScaleStart : null,
      onScaleUpdate: isTouch ? _onScaleUpdate : null,
      onScaleEnd: isTouch ? _onScaleEnd : null,
      onTapDown: (details) => _onTapDown(details, context),
      onLongPressStart: (details) => _onLongPress(details, context),
      // Mouse gestures for desktop
      child: MouseRegion(
        onHover: !isTouch ? (event) => _onMouseHover(event, context) : null,
        onExit: !isTouch ? (_) => _hideTooltip() : null,
        child: Listener(
          onPointerSignal: !isTouch ? _onPointerSignal : null,
          child: Transform(
            transform:
                Matrix4.identity()
                  ..translate(
                    _interactionState.offset.dx,
                    _interactionState.offset.dy,
                  )
                  ..scale(_interactionState.scale)
                  ..rotateZ(_interactionState.rotation),
            alignment: Alignment.center,
            child: CustomPaint(
              size: Size(_chartSize, _chartSize),
              painter: ResponsiveKundliChartPainter(
                kundaliData: widget.kundaliData,
                chartStyle: _chartStyle,
                isDarkMode: Theme.of(context).brightness == Brightness.dark,
                scale: _interactionState.scale,
                selectedPlanetIndex: _selectedPlanetIndex,
                selectedHouseIndex: _selectedHouseIndex,
                touchPoint: _interactionState.touchPoint,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build chart controls
  Widget _buildChartControls(BuildContext context, ScreenSize screenSize) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.zoom_in, size: 20),
            onPressed: _zoomIn,
            tooltip: 'Zoom In',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out, size: 20),
            onPressed: _zoomOut,
            tooltip: 'Zoom Out',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _resetView,
            tooltip: 'Reset View',
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen, size: 20),
            onPressed: _toggleFullscreen,
            tooltip: 'Fullscreen',
          ),
        ],
      ),
    );
  }

  // Build tooltip
  Widget _buildTooltip(BuildContext context, ScreenSize screenSize) {
    return AnimatedBuilder(
      animation: _tooltipAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _tooltipAnimation.value,
          child: Transform.scale(
            scale: _tooltipAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                _tooltipText,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }

  // Build info cards sliver
  SliverGrid _buildInfoCardsSliver(
    BuildContext context,
    ScreenSize screenSize,
  ) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridColumns,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: screenSize == ScreenSize.mobile ? 1.5 : 1.3,
      ),
      delegate: SliverChildListDelegate([
        _buildInfoCard(
          context,
          'Ascendant',
          widget.kundaliData.ascendant.sign,
          Icons.arrow_upward,
          Colors.blue,
          0,
        ),
        _buildInfoCard(
          context,
          'Moon Sign',
          widget.kundaliData.moonSign,
          Icons.nightlight,
          Colors.purple,
          1,
        ),
        _buildInfoCard(
          context,
          'Sun Sign',
          widget.kundaliData.sunSign,
          Icons.wb_sunny,
          Colors.orange,
          2,
        ),
        _buildInfoCard(
          context,
          'Nakshatra',
          widget.kundaliData.birthNakshatra,
          Icons.star,
          Colors.indigo,
          3,
        ),
      ]),
    );
  }

  // Build info grid
  Widget _buildInfoGrid(BuildContext context, ScreenSize screenSize) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: _gridColumns,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildInfoCard(
          context,
          'Ascendant',
          widget.kundaliData.ascendant.sign,
          Icons.arrow_upward,
          Colors.blue,
          0,
        ),
        _buildInfoCard(
          context,
          'Moon Sign',
          widget.kundaliData.moonSign,
          Icons.nightlight,
          Colors.purple,
          1,
        ),
        _buildInfoCard(
          context,
          'Sun Sign',
          widget.kundaliData.sunSign,
          Icons.wb_sunny,
          Colors.orange,
          2,
        ),
        _buildInfoCard(
          context,
          'Nakshatra',
          widget.kundaliData.birthNakshatra,
          Icons.star,
          Colors.indigo,
          3,
        ),
        _buildPlanetCard(context, 'Mars', 4),
        _buildPlanetCard(context, 'Mercury', 5),
        _buildPlanetCard(context, 'Jupiter', 6),
        _buildPlanetCard(context, 'Venus', 7),
        _buildPlanetCard(context, 'Saturn', 8),
        _buildSpecialCard(context, 'Yogas', widget.kundaliData.yogas.length, 9),
      ],
    );
  }

  // Build info card
  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    int index,
  ) {
    return AnimatedBuilder(
      animation:
          index < _cardFadeAnimations.length
              ? _cardFadeAnimations[index]
              : _cardFadeAnimations.last,
      builder: (context, child) {
        final animation =
            index < _cardFadeAnimations.length
                ? _cardFadeAnimations[index]
                : _cardFadeAnimations.last;

        return FadeTransition(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Build planet card
  Widget _buildPlanetCard(BuildContext context, String planet, int index) {
    final position = widget.kundaliData.planetPositions[planet];
    if (position == null) {
      return const SizedBox.shrink();
    }

    return _buildInfoCard(
      context,
      planet,
      '${position.sign}\n${position.longitude.toStringAsFixed(2)}°',
      Icons.public,
      _getPlanetColor(planet),
      index,
    );
  }

  // Build special card
  Widget _buildSpecialCard(
    BuildContext context,
    String title,
    int count,
    int index,
  ) {
    return _buildInfoCard(
      context,
      title,
      count.toString(),
      Icons.auto_awesome,
      Colors.amber,
      index,
    );
  }

  // Build export section
  Widget _buildExportSection(BuildContext context, ScreenSize screenSize) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Options',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildExportOption(
                context,
                'PDF',
                Icons.picture_as_pdf,
                Colors.red,
              ),
              _buildExportOption(context, 'Image', Icons.image, Colors.blue),
              _buildExportOption(context, 'Print', Icons.print, Colors.green),
              _buildExportOption(context, 'Share', Icons.share, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  // Build export option
  Widget _buildExportOption(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () => _handleExport(label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // Build fullscreen view
  Widget _buildFullscreenView(BuildContext context, ScreenSize screenSize) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fullscreen chart
          Center(
            child: AnimatedBuilder(
              animation: _fullscreenAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fullscreenAnimation.value,
                  child: _buildInteractiveChart(context, screenSize),
                );
              },
            ),
          ),

          // Exit button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: _toggleFullscreen,
            ),
          ),

          // Info overlay
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFullscreenInfo(
                    'Ascendant',
                    widget.kundaliData.ascendant.sign,
                  ),
                  _buildFullscreenInfo('Moon', widget.kundaliData.moonSign),
                  _buildFullscreenInfo('Sun', widget.kundaliData.sunSign),
                  _buildFullscreenInfo(
                    'Nakshatra',
                    widget.kundaliData.birthNakshatra,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build fullscreen info
  Widget _buildFullscreenInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Helper UI builders
  Widget _buildBirthInfoRow(BuildContext context, ScreenSize screenSize) {
    final isCompact = screenSize == ScreenSize.mobile;

    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: isCompact ? 14 : 16,
          color: Colors.white70,
        ),
        const SizedBox(width: 8),
        Text(
          _formatBirthDateTime(),
          style: TextStyle(
            fontSize: isCompact ? 12 : 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.location_on,
          size: isCompact ? 14 : 16,
          color: Colors.white70,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.kundaliData.birthPlace,
            style: TextStyle(
              fontSize: isCompact ? 12 : 14,
              color: Colors.white70,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions(
    BuildContext context,
    ScreenSize screenSize,
  ) {
    if (screenSize == ScreenSize.mobile) {
      return [
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'share', child: Text('Share')),
                const PopupMenuItem(value: 'export', child: Text('Export')),
                const PopupMenuItem(
                  value: 'fullscreen',
                  child: Text('Fullscreen'),
                ),
              ],
        ),
      ];
    }

    return [
      IconButton(
        icon: const Icon(Icons.share),
        onPressed: () => _handleMenuAction('share'),
        tooltip: 'Share',
      ),
      IconButton(
        icon: const Icon(Icons.download),
        onPressed: () => _handleMenuAction('export'),
        tooltip: 'Export',
      ),
      IconButton(
        icon: const Icon(Icons.fullscreen),
        onPressed: _toggleFullscreen,
        tooltip: 'Fullscreen',
      ),
    ];
  }

  Widget _buildTabBar(BuildContext context, ScreenSize screenSize) {
    return TabBar(
      controller: _tabController,
      isScrollable: screenSize == ScreenSize.mobile,
      tabs: const [
        Tab(text: 'Chart'),
        Tab(text: 'Details'),
        Tab(text: 'Analysis'),
        Tab(text: 'Predictions'),
        Tab(text: 'Export'),
      ],
    );
  }

  Widget _buildTabContent(BuildContext context, ScreenSize screenSize) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildChartTab(context, screenSize),
        _buildDetailsTab(context, screenSize),
        _buildAnalysisTab(context, screenSize),
        _buildPredictionsTab(context, screenSize),
        _buildExportTab(context, screenSize),
      ],
    );
  }

  // Placeholder tab content
  Widget _buildChartTab(BuildContext context, ScreenSize screenSize) {
    return const Center(child: Text('Chart View'));
  }

  Widget _buildDetailsTab(BuildContext context, ScreenSize screenSize) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildInfoGrid(context, screenSize),
    );
  }

  Widget _buildAnalysisTab(BuildContext context, ScreenSize screenSize) {
    return const Center(child: Text('Analysis'));
  }

  Widget _buildPredictionsTab(BuildContext context, ScreenSize screenSize) {
    return const Center(child: Text('Predictions'));
  }

  Widget _buildExportTab(BuildContext context, ScreenSize screenSize) {
    return _buildExportSection(context, screenSize);
  }

  // Stub methods for additional UI
  Widget _buildDashboardHeader(BuildContext context, ScreenSize screenSize) {
    return _buildDesktopHeader(context, screenSize);
  }

  Widget _buildSidebar(BuildContext context, ScreenSize screenSize) {
    return Column(
      children: [
        _buildCompactHeader(context, screenSize),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSidebarItem(Icons.dashboard, 'Chart', true),
              _buildSidebarItem(Icons.info, 'Details', false),
              _buildSidebarItem(Icons.analytics, 'Analysis', false),
              _buildSidebarItem(Icons.auto_awesome, 'Predictions', false),
              _buildSidebarItem(Icons.download, 'Export', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? AppColors.primary : null),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.primary : null,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildPrimaryInfoColumn(BuildContext context, ScreenSize screenSize) {
    return Column(
      children: [
        _buildInfoCard(
          context,
          'Ascendant',
          widget.kundaliData.ascendant.sign,
          Icons.arrow_upward,
          Colors.blue,
          0,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          context,
          'Moon Sign',
          widget.kundaliData.moonSign,
          Icons.nightlight,
          Colors.purple,
          1,
        ),
      ],
    );
  }

  Widget _buildRightPanel(BuildContext context, ScreenSize screenSize) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildQuickAction('Generate Report', Icons.description),
              _buildQuickAction('Match Making', Icons.favorite),
              _buildQuickAction('Remedies', Icons.healing),
              _buildQuickAction('Ask Astrologer', Icons.support_agent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(String label, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, ScreenSize screenSize) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(context, 'Share', Icons.share),
          _buildActionButton(context, 'Export', Icons.download),
          _buildActionButton(context, 'Print', Icons.print),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon) {
    return TextButton.icon(
      onPressed: () => _handleMenuAction(label.toLowerCase()),
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _buildHeaderActions(BuildContext context, ScreenSize screenSize) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _handleMenuAction('share'),
        ),
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => _handleMenuAction('export'),
        ),
        IconButton(
          icon: const Icon(Icons.fullscreen),
          onPressed: _toggleFullscreen,
        ),
      ],
    );
  }

  // Gesture handlers
  void _onScaleStart(ScaleStartDetails details) {
    _baseScale = _interactionState.scale;
    _baseFocalPoint = details.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _interactionState = _interactionState.copyWith(
        scale: (_baseScale * details.scale).clamp(0.5, 3.0),
        offset: details.focalPoint - _baseFocalPoint,
      );
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    setState(() {
      _interactionState = _interactionState.copyWith(isInteracting: false);
    });
  }

  void _onTapDown(TapDownDetails details, BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);

    setState(() {
      _interactionState = _interactionState.copyWith(touchPoint: localPosition);
    });

    // Check if tapped on planet or house
    _checkPlanetHit(localPosition);
  }

  void _onLongPress(LongPressStartDetails details, BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);

    _showTooltipAt(localPosition, 'Long press detected');
  }

  void _onMouseHover(PointerHoverEvent event, BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(event.position);

    _checkPlanetHit(localPosition);
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      setState(() {
        final delta = event.scrollDelta.dy > 0 ? -0.1 : 0.1;
        _interactionState = _interactionState.copyWith(
          scale: (_interactionState.scale + delta).clamp(0.5, 3.0),
        );
      });
    }
  }

  void _checkPlanetHit(Offset position) {
    // Simplified hit detection
    // In production, calculate actual planet positions
    _showTooltipAt(position, 'Planet info');
  }

  void _showTooltipAt(Offset position, String text) {
    setState(() {
      _tooltipText = text;
      _tooltipPosition = position;
      _showTooltip = true;
    });

    _tooltipAnimationController.forward();

    // Auto-hide after delay
    _tooltipTimer?.cancel();
    _tooltipTimer = Timer(const Duration(seconds: 2), _hideTooltip);
  }

  void _hideTooltip() {
    _tooltipAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showTooltip = false;
        });
      }
    });
  }

  // Actions
  void _zoomIn() {
    setState(() {
      _interactionState = _interactionState.copyWith(
        scale: (_interactionState.scale + 0.2).clamp(0.5, 3.0),
      );
    });
  }

  void _zoomOut() {
    setState(() {
      _interactionState = _interactionState.copyWith(
        scale: (_interactionState.scale - 0.2).clamp(0.5, 3.0),
      );
    });
  }

  void _resetView() {
    setState(() {
      _interactionState = ChartInteractionState();
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      _fullscreenAnimationController.forward();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      _fullscreenAnimationController.reverse();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        _shareKundali();
        break;
      case 'export':
        setState(() {
          _showExportOptions = !_showExportOptions;
        });
        break;
      case 'fullscreen':
        _toggleFullscreen();
        break;
    }
  }

  void _handleExport(String type) {
    // Implement export logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting as $type...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareKundali() {
    // Implement share logic
    HapticFeedback.lightImpact();
  }

  // Helper methods
  String _formatBirthDateTime() {
    return DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(widget.kundaliData.birthDateTime);
  }

  Color _getPlanetColor(String planet) {
    final colors = {
      'Sun': Colors.orange,
      'Moon': Colors.blue,
      'Mars': Colors.red,
      'Mercury': Colors.green,
      'Jupiter': Colors.amber,
      'Venus': Colors.pink,
      'Saturn': Colors.grey,
      'Rahu': Colors.deepPurple,
      'Ketu': Colors.brown,
    };
    return colors[planet] ?? Colors.grey;
  }
}

// Responsive Kundli Chart Painter
class ResponsiveKundliChartPainter extends CustomPainter {
  final KundaliData kundaliData;
  final ChartStyle chartStyle;
  final bool isDarkMode;
  final double scale;
  final int selectedPlanetIndex;
  final int selectedHouseIndex;
  final Offset? touchPoint;

  ResponsiveKundliChartPainter({
    required this.kundaliData,
    required this.chartStyle,
    required this.isDarkMode,
    this.scale = 1.0,
    this.selectedPlanetIndex = -1,
    this.selectedHouseIndex = -1,
    this.touchPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0 * scale
          ..color = isDarkMode ? Colors.white : Colors.black;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.85;

    // Draw based on chart style
    switch (chartStyle) {
      case ChartStyle.northIndian:
        _drawNorthIndianChart(canvas, size, center, radius, paint);
        break;
      case ChartStyle.southIndian:
        _drawSouthIndianChart(canvas, size, center, radius, paint);
        break;
      case ChartStyle.western:
        _drawWesternChart(canvas, size, center, radius, paint);
        break;
    }

    // Draw planets
    _drawPlanets(canvas, size, center, radius);

    // Draw touch indicator
    if (touchPoint != null) {
      _drawTouchIndicator(canvas, touchPoint!);
    }
  }

  void _drawNorthIndianChart(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
    Paint paint,
  ) {
    // Draw square with diagonals
    final rect = Rect.fromCenter(
      center: center,
      width: radius * 2,
      height: radius * 2,
    );
    canvas.drawRect(rect, paint);

    // Draw diagonals
    canvas.drawLine(rect.topLeft, rect.bottomRight, paint);
    canvas.drawLine(rect.topRight, rect.bottomLeft, paint);

    // Draw inner lines
    canvas.drawLine(
      Offset(rect.left, rect.top + rect.height / 2),
      Offset(rect.right, rect.top + rect.height / 2),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left + rect.width / 2, rect.top),
      Offset(rect.left + rect.width / 2, rect.bottom),
      paint,
    );
  }

  void _drawSouthIndianChart(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
    Paint paint,
  ) {
    // Draw grid
    final rect = Rect.fromCenter(
      center: center,
      width: radius * 2,
      height: radius * 2,
    );
    canvas.drawRect(rect, paint);

    final cellSize = radius * 2 / 3;
    for (int i = 1; i < 3; i++) {
      // Vertical lines
      canvas.drawLine(
        Offset(rect.left + cellSize * i, rect.top),
        Offset(rect.left + cellSize * i, rect.bottom),
        paint,
      );
      // Horizontal lines
      canvas.drawLine(
        Offset(rect.left, rect.top + cellSize * i),
        Offset(rect.right, rect.top + cellSize * i),
        paint,
      );
    }
  }

  void _drawWesternChart(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
    Paint paint,
  ) {
    // Draw circle
    canvas.drawCircle(center, radius, paint);

    // Draw 12 divisions
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), paint);
    }

    // Draw inner circle
    canvas.drawCircle(center, radius * 0.4, paint);
  }

  void _drawPlanets(Canvas canvas, Size size, Offset center, double radius) {
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    // Draw planet symbols
    kundaliData.planetPositions.forEach((planet, position) {
      // Calculate position based on house
      final angle = (position.house * 30 - 90) * math.pi / 180;
      final x = center.dx + (radius * 0.7) * math.cos(angle);
      final y = center.dy + (radius * 0.7) * math.sin(angle);

      textPainter.text = TextSpan(
        text: _getPlanetSymbol(planet),
        style: TextStyle(
          color: _getPlanetColor(planet),
          fontSize: 16 * scale,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    });
  }

  void _drawTouchIndicator(Canvas canvas, Offset position) {
    final paint =
        Paint()
          ..color = Colors.blue.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 20, paint);
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

  Color _getPlanetColor(String planet) {
    final colors = {
      'Sun': Colors.orange,
      'Moon': Colors.blue,
      'Mars': Colors.red,
      'Mercury': Colors.green,
      'Jupiter': Colors.amber,
      'Venus': Colors.pink,
      'Saturn': Colors.grey,
      'Rahu': Colors.deepPurple,
      'Ketu': Colors.brown,
    };
    return colors[planet] ?? Colors.grey;
  }

  @override
  bool shouldRepaint(ResponsiveKundliChartPainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.selectedPlanetIndex != selectedPlanetIndex ||
        oldDelegate.selectedHouseIndex != selectedHouseIndex ||
        oldDelegate.touchPoint != touchPoint ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}

// Constellation background painter
class ConstellationPainter extends CustomPainter {
  final double rotation;
  final Color color;

  ConstellationPainter({required this.rotation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    // Save canvas state
    canvas.save();

    // Rotate canvas
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);
    canvas.translate(-size.width / 2, -size.height / 2);

    // Draw constellation pattern
    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 12; i++) {
      final x = (size.width / 12) * i + 20;
      final y = 50 + (random % 30);

      // Draw star
      canvas.drawCircle(
        Offset(x.toDouble(), y.toDouble()),
        3,
        paint..style = PaintingStyle.fill,
      );

      // Draw connections
      if (i > 0) {
        final prevX = (size.width / 12) * (i - 1) + 20;
        final prevY = 50 + ((random - i) % 30);
        canvas.drawLine(
          Offset(prevX.toDouble(), prevY.toDouble()),
          Offset(x.toDouble(), y.toDouble()),
          paint..style = PaintingStyle.stroke,
        );
      }
    }

    // Restore canvas state
    canvas.restore();
  }

  @override
  bool shouldRepaint(ConstellationPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.color != color;
  }
}
