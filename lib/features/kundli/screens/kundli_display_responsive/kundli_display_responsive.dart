import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import '../../../../shared/models/kundali_data_model.dart';
import '../../../../core/constants/app_colors.dart';

// Responsive Kundli Display Screen with Chart Visualization
// Full implementation with SVG charts, zoom controls, and responsive layouts

// Breakpoints
class KundliDisplayBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1800;
}

// Screen sizes
enum ScreenSize { mobile, tablet, desktop, largeDesktop }

// Layout modes
enum ChartLayout {
  tabbed, // Mobile - tabs for different views
  splitView, // Tablet - chart + details side by side
  multiPanel, // Desktop - multiple panels
  dashboard, // Large desktop - full dashboard
}

// View modes
enum ViewMode { chart, details, planets, aspects, dasha, predictions }

class ResponsiveKundliDisplay extends StatefulWidget {
  final KundaliData kundaliData;

  const ResponsiveKundliDisplay({super.key, required this.kundaliData});

  @override
  State<ResponsiveKundliDisplay> createState() =>
      _ResponsiveKundliDisplayState();
}

class _ResponsiveKundliDisplayState extends State<ResponsiveKundliDisplay>
    with TickerProviderStateMixin {
  // Controllers
  late TabController _tabController;
  late TransformationController _transformationController;
  late AnimationController _chartAnimationController;
  late AnimationController _detailsAnimationController;

  // Animations
  late Animation<double> _chartScaleAnimation;
  late Animation<double> _chartRotationAnimation;
  // ignore: unused_field
  late List<Animation<double>> _detailsFadeAnimations;

  // State
  // ignore: unused_field
  final ViewMode _currentView = ViewMode.chart;
  ChartStyle _currentChartStyle = ChartStyle.northIndian;
  double _zoomLevel = 1.0;
  bool _showGridLines = true;
  bool _showHouseNumbers = true;
  bool _showPlanetDegrees = true;
  ChartLayout _currentLayout = ChartLayout.tabbed;

  // Print mode
  bool _isPrintMode = false;

  // Gesture detection
  double _baseScale = 1.0;
  double _currentScale = 1.0;
  // ignore: unused_field
  Offset _focalPoint = Offset.zero;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
    _currentChartStyle = widget.kundaliData.chartStyle;
  }

  void _initControllers() {
    _tabController = TabController(length: 6, vsync: this);
    _transformationController = TransformationController();

    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _detailsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  void _initAnimations() {
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

    _detailsFadeAnimations = List.generate(10, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _detailsAnimationController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    // Start animations
    _chartAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _detailsAnimationController.forward();
      }
    });
  }

  // Get screen size
  ScreenSize _getScreenSize(double width) {
    if (width < KundliDisplayBreakpoints.mobile) return ScreenSize.mobile;
    if (width < KundliDisplayBreakpoints.tablet) return ScreenSize.tablet;
    if (width < KundliDisplayBreakpoints.desktop) return ScreenSize.desktop;
    return ScreenSize.largeDesktop;
  }

  // Get chart layout
  ChartLayout _getChartLayout(double width, double height) {
    final screenSize = _getScreenSize(width);
    final isLandscape = width > height;

    switch (screenSize) {
      case ScreenSize.mobile:
        return ChartLayout.tabbed;
      case ScreenSize.tablet:
        return isLandscape ? ChartLayout.splitView : ChartLayout.tabbed;
      case ScreenSize.desktop:
        return ChartLayout.multiPanel;
      case ScreenSize.largeDesktop:
        return ChartLayout.dashboard;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _transformationController.dispose();
    _chartAnimationController.dispose();
    _detailsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final screenSize = _getScreenSize(screenWidth);
        final chartLayout = _getChartLayout(screenWidth, screenHeight);

        // Update layout state
        if (_currentLayout != chartLayout) {
          _currentLayout = chartLayout;
        }

        // Print mode override
        if (_isPrintMode) {
          return _buildPrintLayout(context, screenSize);
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: _buildResponsiveLayout(
            context,
            screenSize,
            chartLayout,
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
    ChartLayout layout,
    double screenWidth,
    double screenHeight,
  ) {
    switch (layout) {
      case ChartLayout.tabbed:
        return _buildTabbedLayout(context, screenSize);
      case ChartLayout.splitView:
        return _buildSplitViewLayout(context, screenSize, screenWidth);
      case ChartLayout.multiPanel:
        return _buildMultiPanelLayout(context, screenSize, screenWidth);
      case ChartLayout.dashboard:
        return _buildDashboardLayout(context, screenSize, screenWidth);
    }
  }

  // Tabbed layout for mobile
  Widget _buildTabbedLayout(BuildContext context, ScreenSize screenSize) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          _buildHeader(context, screenSize),

          // Tab bar
          _buildTabBar(context, screenSize),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChartView(context, screenSize),
                _buildDetailsView(context, screenSize),
                _buildPlanetsTable(context, screenSize),
                _buildAspectsView(context, screenSize),
                _buildDashaView(context, screenSize),
                _buildPredictionsView(context, screenSize),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Split view layout for tablet
  Widget _buildSplitViewLayout(
    BuildContext context,
    ScreenSize screenSize,
    double screenWidth,
  ) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          _buildHeader(context, screenSize),

          // Content
          Expanded(
            child: Row(
              children: [
                // Chart panel
                SizedBox(
                  width: screenWidth * 0.5,
                  child: _buildChartView(context, screenSize),
                ),

                // Details panel with tabs
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTabBar(context),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildDetailsView(context, screenSize),
                            _buildPlanetsTable(context, screenSize),
                            _buildAspectsView(context, screenSize),
                            _buildDashaView(context, screenSize),
                            _buildPredictionsView(context, screenSize),
                            const SizedBox(), // Empty for chart tab
                          ],
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
    );
  }

  // Multi-panel layout for desktop
  Widget _buildMultiPanelLayout(
    BuildContext context,
    ScreenSize screenSize,
    double screenWidth,
  ) {
    return SafeArea(
      child: Column(
        children: [
          // Header with controls
          _buildDesktopHeader(context, screenSize),

          // Main content
          Expanded(
            child: Row(
              children: [
                // Left panel - Chart
                Container(
                  width: screenWidth * 0.4,
                  padding: const EdgeInsets.all(16),
                  child: _buildChartView(context, screenSize),
                ),

                // Middle panel - Details
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Expanded(child: _buildDetailsView(context, screenSize)),
                        const Divider(),
                        SizedBox(
                          height: 200,
                          child: _buildPlanetsTable(context, screenSize),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right panel - Additional info
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      left: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: _buildSidePanel(context, screenSize),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dashboard layout for large desktop
  Widget _buildDashboardLayout(
    BuildContext context,
    ScreenSize screenSize,
    double screenWidth,
  ) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          _buildDesktopHeader(context, screenSize),

          // Dashboard grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Top row - Chart and birth info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chart
                      Container(
                        width: 500,
                        height: 500,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: _buildChartView(context, screenSize),
                      ),
                      const SizedBox(width: 24),

                      // Birth details
                      Expanded(
                        child: Column(
                          children: [
                            _buildBirthInfoCard(context, screenSize),
                            const SizedBox(height: 16),
                            _buildPlanetaryStrengthCard(context, screenSize),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Bottom row - Tables and predictions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Planets table
                      Expanded(child: _buildPlanetsCard(context, screenSize)),
                      const SizedBox(width: 16),

                      // Aspects
                      Expanded(child: _buildAspectsCard(context, screenSize)),
                      const SizedBox(width: 16),

                      // Dasha
                      Expanded(child: _buildDashaCard(context, screenSize)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build header
  Widget _buildHeader(BuildContext context, ScreenSize screenSize) {
    final isCompact = screenSize == ScreenSize.mobile;

    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          if (!isCompact)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.kundaliData.name,
                  style: TextStyle(
                    fontSize: isCompact ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatBirthDateTime(),
                  style: TextStyle(
                    fontSize: isCompact ? 12 : 14,
                    color: Colors.grey[600],
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
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.kundaliData.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_formatBirthDateTime()} • ${widget.kundaliData.birthPlace}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const Spacer(),
          _buildChartControls(context),
          const SizedBox(width: 16),
          _buildHeaderActions(context, screenSize),
        ],
      ),
    );
  }

  // Build header actions
  Widget _buildHeaderActions(BuildContext context, ScreenSize screenSize) {
    final isCompact = screenSize == ScreenSize.mobile;

    return Row(
      children: [
        if (!isCompact) ...[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareChart,
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportChart,
            tooltip: 'Export',
          ),
        ],
        IconButton(
          icon: const Icon(Icons.print),
          onPressed: () => _togglePrintMode(context),
          tooltip: 'Print',
        ),
        if (isCompact)
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'share', child: Text('Share')),
                  const PopupMenuItem(value: 'export', child: Text('Export')),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Text('Settings'),
                  ),
                ],
          ),
      ],
    );
  }

  // Build chart controls
  Widget _buildChartControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom controls
          IconButton(
            icon: const Icon(Icons.zoom_out, size: 20),
            onPressed: _zoomOut,
            tooltip: 'Zoom Out',
          ),
          Text(
            '${(_zoomLevel * 100).toInt()}%',
            style: const TextStyle(fontSize: 12),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in, size: 20),
            onPressed: _zoomIn,
            tooltip: 'Zoom In',
          ),
          const VerticalDivider(width: 16),

          // Chart style selector
          DropdownButton<ChartStyle>(
            value: _currentChartStyle,
            underline: const SizedBox(),
            isDense: true,
            items:
                ChartStyle.values.map((style) {
                  return DropdownMenuItem(
                    value: style,
                    child: Text(
                      style.displayName,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
            onChanged: (style) {
              if (style != null) {
                setState(() {
                  _currentChartStyle = style;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // Build tab bar
  Widget _buildTabBar(BuildContext context, ScreenSize screenSize) {
    final isCompact = screenSize == ScreenSize.mobile;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: isCompact,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(text: 'Chart', icon: Icon(Icons.dashboard, size: 20)),
          Tab(text: 'Details', icon: Icon(Icons.info_outline, size: 20)),
          Tab(text: 'Planets', icon: Icon(Icons.public, size: 20)),
          Tab(text: 'Aspects', icon: Icon(Icons.compare_arrows, size: 20)),
          Tab(text: 'Dasha', icon: Icon(Icons.timeline, size: 20)),
          Tab(text: 'Predictions', icon: Icon(Icons.auto_awesome, size: 20)),
        ],
      ),
    );
  }

  // Build compact tab bar
  Widget _buildCompactTabBar(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(text: 'Details'),
          Tab(text: 'Planets'),
          Tab(text: 'Aspects'),
          Tab(text: 'Dasha'),
          Tab(text: 'Predictions'),
          Tab(text: 'Chart'), // Hidden in split view
        ],
      ),
    );
  }

  // Build chart view
  Widget _buildChartView(BuildContext context, ScreenSize screenSize) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isCompact = screenSize == ScreenSize.mobile;

    return AnimatedBuilder(
      animation: _chartScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _chartScaleAnimation.value,
          child: Transform.rotate(
            angle: _chartRotationAnimation.value,
            child: Container(
              padding: EdgeInsets.all(isCompact ? 8 : 16),
              child: GestureDetector(
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onScaleEnd: _onScaleEnd,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: KundliChartPainter(
                      kundaliData: widget.kundaliData,
                      chartStyle: _currentChartStyle,
                      isDarkMode: isDarkMode,
                      showGridLines: _showGridLines,
                      showHouseNumbers: _showHouseNumbers,
                      showPlanetDegrees: _showPlanetDegrees,
                      zoomLevel: _zoomLevel,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Build details view
  Widget _buildDetailsView(BuildContext context, ScreenSize screenSize) {
    final isCompact = screenSize == ScreenSize.mobile;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isCompact ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailSection('Birth Information', [
            _buildDetailRow('Name', widget.kundaliData.name),
            _buildDetailRow(
              'Date',
              _formatDate(widget.kundaliData.birthDateTime),
            ),
            _buildDetailRow(
              'Time',
              _formatTime(widget.kundaliData.birthDateTime),
            ),
            _buildDetailRow('Place', widget.kundaliData.birthPlace),
            _buildDetailRow('Latitude', '${widget.kundaliData.latitude}°'),
            _buildDetailRow('Longitude', '${widget.kundaliData.longitude}°'),
          ]),
          const SizedBox(height: 20),
          _buildDetailSection('Panchang Details', [
            _buildDetailRow('Tithi', 'Shukla Paksha Panchami'),
            _buildDetailRow('Nakshatra', 'Rohini'),
            _buildDetailRow('Yoga', 'Shobhana'),
            _buildDetailRow('Karana', 'Bava'),
            _buildDetailRow('Rashi', 'Vrishabha'),
            _buildDetailRow('Lagna', 'Mithuna'),
          ]),
        ],
      ),
    );
  }

  // Build planets table
  Widget _buildPlanetsTable(BuildContext context, ScreenSize screenSize) {
    final isCompact = screenSize == ScreenSize.mobile;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isCompact ? 8 : 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: isCompact ? 20 : 40,
          columns: const [
            DataColumn(label: Text('Planet')),
            DataColumn(label: Text('Sign')),
            DataColumn(label: Text('Degree')),
            DataColumn(label: Text('House')),
            DataColumn(label: Text('Nakshatra')),
          ],
          rows: _buildPlanetRows(),
        ),
      ),
    );
  }

  // Build planet rows
  List<DataRow> _buildPlanetRows() {
    final planets = [
      ['Sun', 'Aries', '15°30\'', '10th', 'Bharani'],
      ['Moon', 'Taurus', '22°45\'', '11th', 'Rohini'],
      ['Mars', 'Gemini', '8°15\'', '12th', 'Mrigashira'],
      ['Mercury', 'Pisces', '28°10\'', '9th', 'Revati'],
      ['Jupiter', 'Sagittarius', '12°20\'', '6th', 'Moola'],
      ['Venus', 'Aquarius', '5°55\'', '8th', 'Dhanishta'],
      ['Saturn', 'Capricorn', '18°40\'', '7th', 'Shravana'],
      ['Rahu', 'Cancer', '10°30\'', '1st', 'Pushya'],
      ['Ketu', 'Capricorn', '10°30\'', '7th', 'Shravana'],
    ];

    return planets.map((planet) {
      return DataRow(
        cells: planet.map((value) => DataCell(Text(value))).toList(),
      );
    }).toList();
  }

  // Build aspects view
  Widget _buildAspectsView(BuildContext context, ScreenSize screenSize) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Planetary Aspects',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildAspectGrid(),
        ],
      ),
    );
  }

  // Build aspect grid
  Widget _buildAspectGrid() {
    final planets = [
      'Sun',
      'Moon',
      'Mars',
      'Mercury',
      'Jupiter',
      'Venus',
      'Saturn',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Table(
        border: TableBorder.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        children: [
          // Header row
          TableRow(
            children: [
              const SizedBox(height: 40),
              ...planets.map(
                (planet) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      planet.substring(0, 3),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Data rows
          ...planets.map((planet1) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    planet1,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...planets.map((planet2) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _getAspectSymbol(planet1, planet2),
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  // Build dasha view
  Widget _buildDashaView(BuildContext context, ScreenSize screenSize) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vimshottari Dasha',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDashaTimeline(),
        ],
      ),
    );
  }

  // Build dasha timeline
  Widget _buildDashaTimeline() {
    final dashas = [
      {'planet': 'Sun', 'start': '2020', 'end': '2026', 'years': 6},
      {'planet': 'Moon', 'start': '2026', 'end': '2036', 'years': 10},
      {'planet': 'Mars', 'start': '2036', 'end': '2043', 'years': 7},
    ];

    return Column(
      children:
          dashas.map((dasha) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        dasha['planet'].toString().substring(0, 1),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
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
                          '${dasha['planet']} Mahadasha',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${dasha['start']} - ${dasha['end']} (${dasha['years']} years)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  // Build predictions view
  Widget _buildPredictionsView(BuildContext context, ScreenSize screenSize) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPredictionCard(
            'Career',
            'Strong placement of Sun in 10th house indicates leadership roles and success in government or administrative positions.',
            Icons.work_outline,
            Colors.blue,
          ),
          _buildPredictionCard(
            'Relationships',
            'Venus in 7th house brings harmony in partnerships. Favorable period for marriage after 2025.',
            Icons.favorite_outline,
            Colors.pink,
          ),
          _buildPredictionCard(
            'Health',
            'Mars in 6th house provides good immunity. Regular exercise will enhance vitality.',
            Icons.health_and_safety_outlined,
            Colors.green,
          ),
          _buildPredictionCard(
            'Finance',
            'Jupiter aspects on 2nd house promise good financial growth. Investments in property are favorable.',
            Icons.account_balance_wallet_outlined,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  // Build prediction card
  Widget _buildPredictionCard(
    String title,
    String prediction,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  prediction,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build side panel
  Widget _buildSidePanel(BuildContext context, ScreenSize screenSize) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildQuickAction('Generate Report', Icons.description, () {}),
          _buildQuickAction('Match Making', Icons.favorite, () {}),
          _buildQuickAction('Remedies', Icons.healing, () {}),
          _buildQuickAction('Ask Astrologer', Icons.support_agent, () {}),
          const Divider(height: 32),
          const Text(
            'Chart Settings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Grid Lines', style: TextStyle(fontSize: 14)),
            value: _showGridLines,
            onChanged: (value) {
              setState(() {
                _showGridLines = value;
              });
            },
            dense: true,
          ),
          SwitchListTile(
            title: const Text('House Numbers', style: TextStyle(fontSize: 14)),
            value: _showHouseNumbers,
            onChanged: (value) {
              setState(() {
                _showHouseNumbers = value;
              });
            },
            dense: true,
          ),
          SwitchListTile(
            title: const Text('Planet Degrees', style: TextStyle(fontSize: 14)),
            value: _showPlanetDegrees,
            onChanged: (value) {
              setState(() {
                _showPlanetDegrees = value;
              });
            },
            dense: true,
          ),
        ],
      ),
    );
  }

  // Build quick action
  Widget _buildQuickAction(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      dense: true,
    );
  }

  // Build detail section
  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  // Build detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // Build cards for dashboard
  Widget _buildBirthInfoCard(BuildContext context, ScreenSize screenSize) {
    return Container(
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
            'Birth Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Name', widget.kundaliData.name),
          _buildDetailRow(
            'Date',
            _formatDate(widget.kundaliData.birthDateTime),
          ),
          _buildDetailRow(
            'Time',
            _formatTime(widget.kundaliData.birthDateTime),
          ),
          _buildDetailRow('Place', widget.kundaliData.birthPlace),
        ],
      ),
    );
  }

  Widget _buildPlanetaryStrengthCard(
    BuildContext context,
    ScreenSize screenSize,
  ) {
    return Container(
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
            'Planetary Strength',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStrengthBar('Sun', 0.8, Colors.orange),
          _buildStrengthBar('Moon', 0.6, Colors.blue),
          _buildStrengthBar('Mars', 0.9, Colors.red),
          _buildStrengthBar('Mercury', 0.7, Colors.green),
          _buildStrengthBar('Jupiter', 0.85, Colors.amber),
        ],
      ),
    );
  }

  Widget _buildStrengthBar(String planet, double strength, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(planet), Text('${(strength * 100).toInt()}%')],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: strength,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetsCard(BuildContext context, ScreenSize screenSize) {
    return Container(
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
            'Planetary Positions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 300, child: _buildPlanetsTable(context, screenSize)),
        ],
      ),
    );
  }

  Widget _buildAspectsCard(BuildContext context, ScreenSize screenSize) {
    return Container(
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
            'Planetary Aspects',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 300, child: _buildAspectGrid()),
        ],
      ),
    );
  }

  Widget _buildDashaCard(BuildContext context, ScreenSize screenSize) {
    return Container(
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
            'Current Dasha',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDashaTimeline(),
        ],
      ),
    );
  }

  // Build print layout
  Widget _buildPrintLayout(BuildContext context, ScreenSize screenSize) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          // Header
          Text(
            'Kundali Chart',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          // Birth details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: Column(
              children: [
                Text(
                  'Name: ${widget.kundaliData.name}',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Date: ${_formatDate(widget.kundaliData.birthDateTime)}',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Time: ${_formatTime(widget.kundaliData.birthDateTime)}',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Place: ${widget.kundaliData.birthPlace}',
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Chart
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: CustomPaint(
                size: Size.infinite,
                painter: KundliChartPainter(
                  kundaliData: widget.kundaliData,
                  chartStyle: _currentChartStyle,
                  isDarkMode: false,
                  showGridLines: true,
                  showHouseNumbers: true,
                  showPlanetDegrees: true,
                  zoomLevel: 1.0,
                ),
              ),
            ),
          ),

          // Footer
          const SizedBox(height: 20),
          Text(
            'Generated on ${_formatDate(DateTime.now())}',
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Widget _getAspectSymbol(String planet1, String planet2) {
    if (planet1 == planet2) {
      return Container(width: 20, height: 20, color: Colors.grey[300]);
    }
    // Simplified aspect logic
    final aspects = {
      'SunMoon': '☌',
      'SunMars': '□',
      'MoonMars': '△',
      'MercuryJupiter': '⚹',
      'VenusSaturn': '☍',
    };
    final key = planet1 + planet2;
    final reverseKey = planet2 + planet1;
    return Text(
      aspects[key] ?? aspects[reverseKey] ?? '',
      style: const TextStyle(fontSize: 16),
    );
  }

  String _formatBirthDateTime() {
    final date = widget.kundaliData.birthDateTime;
    return '${_formatDate(date)} at ${_formatTime(date)}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  // Gesture handlers
  void _onScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
    _focalPoint = details.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _currentScale = (_baseScale * details.scale).clamp(0.5, 3.0);
      _zoomLevel = _currentScale;
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    // Optional: Add animation to snap to certain zoom levels
  }

  // Actions
  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 0.1).clamp(0.5, 3.0);
      _currentScale = _zoomLevel;
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 0.1).clamp(0.5, 3.0);
      _currentScale = _zoomLevel;
    });
  }

  void _shareChart() {
    // Implement share functionality
    HapticFeedback.lightImpact();
  }

  void _exportChart() {
    // Implement export functionality
    HapticFeedback.lightImpact();
  }

  void _togglePrintMode(BuildContext context) {
    setState(() {
      _isPrintMode = !_isPrintMode;
    });
    if (_isPrintMode) {
      // Trigger print dialog
      Future.delayed(const Duration(milliseconds: 500), () {
        // window.print() equivalent in Flutter
      });
    }
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'share':
        _shareChart();
        break;
      case 'export':
        _exportChart();
        break;
      case 'settings':
        // Show settings dialog
        break;
    }
  }
}

// Custom chart painter
class KundliChartPainter extends CustomPainter {
  final KundaliData kundaliData;
  final ChartStyle chartStyle;
  final bool isDarkMode;
  final bool showGridLines;
  final bool showHouseNumbers;
  final bool showPlanetDegrees;
  final double zoomLevel;

  KundliChartPainter({
    required this.kundaliData,
    required this.chartStyle,
    required this.isDarkMode,
    required this.showGridLines,
    required this.showHouseNumbers,
    required this.showPlanetDegrees,
    required this.zoomLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0 * zoomLevel
          ..color = isDarkMode ? Colors.white : Colors.black;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.8 * zoomLevel;

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

    // Add house numbers if enabled
    if (showHouseNumbers) {
      _drawHouseNumbers(canvas, rect);
    }
  }

  void _drawSouthIndianChart(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
    Paint paint,
  ) {
    // Draw outer square
    final rect = Rect.fromCenter(
      center: center,
      width: radius * 2,
      height: radius * 2,
    );
    canvas.drawRect(rect, paint);

    // Draw grid (3x3 with center combined)
    final cellWidth = rect.width / 3;
    final cellHeight = rect.height / 3;

    for (int i = 1; i < 3; i++) {
      // Vertical lines
      canvas.drawLine(
        Offset(rect.left + cellWidth * i, rect.top),
        Offset(rect.left + cellWidth * i, rect.bottom),
        paint,
      );
      // Horizontal lines
      canvas.drawLine(
        Offset(rect.left, rect.top + cellHeight * i),
        Offset(rect.right, rect.top + cellHeight * i),
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

    // Draw 12 house divisions
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), paint);
    }

    // Draw inner circle
    canvas.drawCircle(center, radius * 0.4, paint);
  }

  void _drawHouseNumbers(Canvas canvas, Rect rect) {
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    // North Indian house positions
    final positions = [
      Offset(rect.center.dx, rect.top + 20), // 1st house
      Offset(rect.right - 30, rect.top + 30), // 2nd house
      // ... add all 12 house positions
    ];

    for (int i = 0; i < 12; i++) {
      textPainter.text = TextSpan(
        text: '${i + 1}',
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black54,
          fontSize: 12 * zoomLevel,
        ),
      );
      textPainter.layout();
      if (i < positions.length) {
        textPainter.paint(canvas, positions[i]);
      }
    }
  }

  void _drawPlanets(Canvas canvas, Size size, Offset center, double radius) {
    // Simplified planet drawing
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    // Example planet positions
    final planets = [
      {'symbol': 'Su', 'house': 1, 'degree': 15.5},
      {'symbol': 'Mo', 'house': 2, 'degree': 22.75},
      {'symbol': 'Ma', 'house': 3, 'degree': 8.25},
      // ... add all planets
    ];

    for (final planet in planets) {
      // Calculate position based on house and chart style
      // This is simplified - actual calculation would be more complex
      final position = _calculatePlanetPosition(
        planet['house'] as int,
        center,
        radius,
      );

      textPainter.text = TextSpan(
        text: planet['symbol'] as String,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 14 * zoomLevel,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, position);

      if (showPlanetDegrees) {
        textPainter.text = TextSpan(
          text: '${planet['degree']}°',
          style: TextStyle(
            color: isDarkMode ? Colors.white60 : Colors.black45,
            fontSize: 10 * zoomLevel,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, position.translate(0, 15 * zoomLevel));
      }
    }
  }

  Offset _calculatePlanetPosition(int house, Offset center, double radius) {
    // Simplified position calculation
    // In real implementation, this would depend on chart style
    final angle = (house - 1) * 30 * math.pi / 180;
    final r = radius * 0.7;
    return Offset(
      center.dx + r * math.cos(angle),
      center.dy + r * math.sin(angle),
    );
  }

  @override
  bool shouldRepaint(KundliChartPainter oldDelegate) {
    return oldDelegate.zoomLevel != zoomLevel ||
        oldDelegate.chartStyle != chartStyle ||
        oldDelegate.showGridLines != showGridLines ||
        oldDelegate.showHouseNumbers != showHouseNumbers ||
        oldDelegate.showPlanetDegrees != showPlanetDegrees ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
