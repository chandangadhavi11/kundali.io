import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:async';
import '../../../../core/providers/panchang_provider.dart';
import '../../../../core/constants/app_colors.dart';

// Responsive Panchang Screen for Almanac Display
// Full implementation with adaptive calendar, collapsible sections, and visualizations

// Breakpoints
class PanchangBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double ultraWide = 1800;
}

// Screen sizes
enum ScreenSize { mobile, tablet, desktop, ultraWide }

// Layout modes
enum PanchangLayout {
  compact,     // Mobile - collapsible sections
  standard,    // Tablet - mixed layout
  expanded,    // Desktop - expanded sections
  dashboard,   // Ultra-wide - full dashboard
}

// Calendar view modes
enum CalendarViewMode { month, week, day, year }

// Section expansion state
class SectionExpansionState {
  final bool calendar;
  final bool tithiNakshatra;
  final bool sunriseSunset;
  final bool festivals;
  final bool muhurat;
  
  SectionExpansionState({
    this.calendar = true,
    this.tithiNakshatra = true,
    this.sunriseSunset = true,
    this.festivals = false,
    this.muhurat = false,
  });
  
  SectionExpansionState copyWith({
    bool? calendar,
    bool? tithiNakshatra,
    bool? sunriseSunset,
    bool? festivals,
    bool? muhurat,
  }) {
    return SectionExpansionState(
      calendar: calendar ?? this.calendar,
      tithiNakshatra: tithiNakshatra ?? this.tithiNakshatra,
      sunriseSunset: sunriseSunset ?? this.sunriseSunset,
      festivals: festivals ?? this.festivals,
      muhurat: muhurat ?? this.muhurat,
    );
  }
}

class ResponsivePanchangScreen extends StatefulWidget {
  const ResponsivePanchangScreen({super.key});

  @override
  State<ResponsivePanchangScreen> createState() =>
      _ResponsivePanchangScreenState();
}

class _ResponsivePanchangScreenState extends State<ResponsivePanchangScreen>
    with TickerProviderStateMixin {
  // Controllers
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  // Animation controllers
  late AnimationController _calendarAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _sunAnimationController;
  late AnimationController _expansionAnimationController;
  
  // Animations
  late Animation<double> _calendarScaleAnimation;
  late List<Animation<double>> _cardFadeAnimations;
  late Animation<double> _sunPathAnimation;
  // ignore: unused_field
  late Animation<double> _expansionAnimation;
  
  // State
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  // ignore: unused_field
  final CalendarViewMode _viewMode = CalendarViewMode.month;
  String _selectedRegion = 'North India';
  final String _selectedTimezone = 'Asia/Kolkata';
  SectionExpansionState _expansionState = SectionExpansionState();
  // ignore: unused_field
  final List<String> _selectedFilters = ['All'];
  
  // Responsive values
  ScreenSize _currentScreenSize = ScreenSize.mobile;
  PanchangLayout _currentLayout = PanchangLayout.compact;
  // ignore: unused_field
  final int _calendarCrossAxisCount = 7;
  double _calendarCellAspectRatio = 1.0;
  
  // Data
  Map<String, String>? _panchangData;
  List<Festival> _festivals = [];
  List<Muhurat> _muhurats = [];
  
  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
    _loadData();
  }
  
  void _initControllers() {
    _tabController = TabController(length: 5, vsync: this);
  }
  
  void _initAnimations() {
    // Calendar animation
    _calendarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _calendarScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _calendarAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
    
    // Card animations
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _cardFadeAnimations = List.generate(6, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardAnimationController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });
    
    // Sun animation
    _sunAnimationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    _sunPathAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sunAnimationController,
        curve: Curves.linear,
      ),
    );
    
    // Expansion animation
    _expansionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _expansionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _expansionAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start animations
    _calendarAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _cardAnimationController.forward();
      }
    });
  }
  
  Future<void> _loadData() async {
    final provider = context.read<PanchangProvider>();
    await provider.fetchPanchang(_selectedDate);
    
    if (mounted) {
      setState(() {
        // Create sample panchang data
        _panchangData = {
          'tithi': provider.currentPanchang?.tithi ?? 'Shukla Paksha Panchami',
          'nakshatra': provider.currentPanchang?.nakshatra ?? 'Rohini',
          'yoga': provider.currentPanchang?.yoga ?? 'Shobhana',
          'karana': provider.currentPanchang?.karana ?? 'Bava',
          'paksha': 'Shukla',  // Default values as these fields may not exist
          'rashi': 'Vrishabha',  // Default values as these fields may not exist
        };
        // Load sample data
        _festivals = _generateSampleFestivals();
        _muhurats = _generateSampleMuhurats();
      });
    }
  }
  
  List<Festival> _generateSampleFestivals() {
    return [
      Festival(
        name: 'Makar Sankranti',
        date: DateTime(2024, 1, 14),
        type: 'Major',
        description: 'Harvest festival',
      ),
      Festival(
        name: 'Vasant Panchami',
        date: DateTime(2024, 2, 14),
        type: 'Religious',
        description: 'Spring festival',
      ),
      Festival(
        name: 'Maha Shivratri',
        date: DateTime(2024, 3, 8),
        type: 'Major',
        description: 'Night of Shiva',
      ),
    ];
  }
  
  List<Muhurat> _generateSampleMuhurats() {
    return [
      Muhurat(
        name: 'Abhijit',
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        type: 'Auspicious',
      ),
      Muhurat(
        name: 'Brahma',
        startTime: DateTime.now().add(const Duration(hours: 5)),
        endTime: DateTime.now().add(const Duration(hours: 6)),
        type: 'Good',
      ),
    ];
  }
  
  // Get screen size
  ScreenSize _getScreenSize(double width) {
    if (width < PanchangBreakpoints.mobile) return ScreenSize.mobile;
    if (width < PanchangBreakpoints.tablet) return ScreenSize.tablet;
    if (width < PanchangBreakpoints.desktop) return ScreenSize.desktop;
    return ScreenSize.ultraWide;
  }
  
  // Get layout
  PanchangLayout _getLayout(ScreenSize screenSize, bool isLandscape) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return PanchangLayout.compact;
      case ScreenSize.tablet:
        return isLandscape ? PanchangLayout.standard : PanchangLayout.compact;
      case ScreenSize.desktop:
        return PanchangLayout.expanded;
      case ScreenSize.ultraWide:
        return PanchangLayout.dashboard;
    }
  }
  
  // Get calendar cell aspect ratio
  double _getCalendarCellAspectRatio(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 0.8;
      case ScreenSize.tablet:
        return 1.0;
      case ScreenSize.desktop:
        return 1.2;
      case ScreenSize.ultraWide:
        return 1.3;
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _calendarAnimationController.dispose();
    _cardAnimationController.dispose();
    _sunAnimationController.dispose();
    _expansionAnimationController.dispose();
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
        final layout = _getLayout(screenSize, isLandscape);
        
        // Update responsive values
        if (_currentScreenSize != screenSize) {
          _currentScreenSize = screenSize;
          _calendarCellAspectRatio = _getCalendarCellAspectRatio(screenSize);
          
          // Update expansion state based on layout
          if (layout == PanchangLayout.expanded || layout == PanchangLayout.dashboard) {
            _expansionState = SectionExpansionState(
              calendar: true,
              tithiNakshatra: true,
              sunriseSunset: true,
              festivals: true,
              muhurat: true,
            );
          }
        }
        
        if (_currentLayout != layout) {
          _currentLayout = layout;
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
    PanchangLayout layout,
    double screenWidth,
    double screenHeight,
  ) {
    switch (layout) {
      case PanchangLayout.compact:
        return _buildCompactLayout(context, screenSize);
      case PanchangLayout.standard:
        return _buildStandardLayout(context, screenSize, screenWidth);
      case PanchangLayout.expanded:
        return _buildExpandedLayout(context, screenSize, screenWidth);
      case PanchangLayout.dashboard:
        return _buildDashboardLayout(context, screenSize, screenWidth);
    }
  }
  
  // Compact layout for mobile
  Widget _buildCompactLayout(BuildContext context, ScreenSize screenSize) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App bar
        _buildSliverAppBar(context, screenSize),
        
        // Quick info cards
        SliverToBoxAdapter(
          child: _buildQuickInfoCards(context, screenSize),
        ),
        
        // Calendar section
        SliverToBoxAdapter(
          child: _buildCollapsibleSection(
            context,
            'Calendar',
            Icons.calendar_month,
            _expansionState.calendar,
            () {
              setState(() {
                _expansionState = _expansionState.copyWith(
                  calendar: !_expansionState.calendar,
                );
              });
            },
            _buildCalendarGrid(context, screenSize),
          ),
        ),
        
        // Tithi & Nakshatra section
        SliverToBoxAdapter(
          child: _buildCollapsibleSection(
            context,
            'Tithi & Nakshatra',
            Icons.stars,
            _expansionState.tithiNakshatra,
            () {
              setState(() {
                _expansionState = _expansionState.copyWith(
                  tithiNakshatra: !_expansionState.tithiNakshatra,
                );
              });
            },
            _buildTithiNakshatraCards(context, screenSize),
          ),
        ),
        
        // Sunrise & Sunset section
        SliverToBoxAdapter(
          child: _buildCollapsibleSection(
            context,
            'Sunrise & Sunset',
            Icons.wb_sunny,
            _expansionState.sunriseSunset,
            () {
              setState(() {
                _expansionState = _expansionState.copyWith(
                  sunriseSunset: !_expansionState.sunriseSunset,
                );
              });
            },
            _buildSunriseSunsetVisualization(context, screenSize),
          ),
        ),
        
        // Festivals section
        SliverToBoxAdapter(
          child: _buildCollapsibleSection(
            context,
            'Festivals',
            Icons.celebration,
            _expansionState.festivals,
            () {
              setState(() {
                _expansionState = _expansionState.copyWith(
                  festivals: !_expansionState.festivals,
                );
              });
            },
            _buildFestivalsList(context, screenSize),
          ),
        ),
        
        // Muhurat section
        SliverToBoxAdapter(
          child: _buildCollapsibleSection(
            context,
            'Muhurat',
            Icons.access_time,
            _expansionState.muhurat,
            () {
              setState(() {
                _expansionState = _expansionState.copyWith(
                  muhurat: !_expansionState.muhurat,
                );
              });
            },
            _buildMuhuratTimeline(context, screenSize),
          ),
        ),
        
        // Bottom padding
        const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
      ],
    );
  }
  
  // Standard layout for tablet
  Widget _buildStandardLayout(
    BuildContext context,
    ScreenSize screenSize,
    double screenWidth,
  ) {
    return Row(
      children: [
        // Left panel - Calendar
        SizedBox(
          width: screenWidth * 0.5,
          child: Column(
            children: [
              _buildCompactHeader(context, screenSize),
              Expanded(
                child: _buildCalendarGrid(context, screenSize),
              ),
            ],
          ),
        ),
        
        // Right panel - Details
        Expanded(
          child: Column(
            children: [
              _buildTabBar(context, screenSize),
              Expanded(
                child: _buildTabContent(context, screenSize),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Expanded layout for desktop
  Widget _buildExpandedLayout(
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
              // Calendar section
              Container(
                width: screenWidth * 0.35,
                padding: const EdgeInsets.all(20),
                child: _buildCalendarSection(context, screenSize),
              ),
              
              // Middle section - Tithi & Festivals
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildTithiNakshatraCards(context, screenSize),
                      const SizedBox(height: 20),
                      _buildFestivalsList(context, screenSize),
                    ],
                  ),
                ),
              ),
              
              // Right section - Sun & Muhurat
              Container(
                width: 320,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.5),
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    _buildSunriseSunsetVisualization(context, screenSize),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _buildMuhuratTimeline(context, screenSize),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Dashboard layout for ultra-wide
  Widget _buildDashboardLayout(
    BuildContext context,
    ScreenSize screenSize,
    double screenWidth,
  ) {
    return Column(
      children: [
        // Header with controls
        _buildDashboardHeader(context, screenSize),
        
        // Dashboard grid
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Top row - Calendar and quick info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calendar
                    Container(
                      width: 500,
                      height: 500,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: _buildCalendarGrid(context, screenSize),
                    ),
                    const SizedBox(width: 24),
                    
                    // Quick info and sun visualization
                    Expanded(
                      child: Column(
                        children: [
                          _buildQuickInfoCards(context, screenSize),
                          const SizedBox(height: 20),
                          _buildSunriseSunsetVisualization(context, screenSize),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Bottom row - Tithi, Festivals, Muhurat
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tithi & Nakshatra
                    Expanded(
                      child: _buildTithiNakshatraSection(context, screenSize),
                    ),
                    const SizedBox(width: 16),
                    
                    // Festivals
                    Expanded(
                      child: _buildFestivalsSection(context, screenSize),
                    ),
                    const SizedBox(width: 16),
                    
                    // Muhurat
                    Expanded(
                      child: _buildMuhuratSection(context, screenSize),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
          'Panchang',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isCompact ? 18 : 20,
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
              // Animated sun path
              AnimatedBuilder(
                animation: _sunPathAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: SunPathPainter(
                      progress: _sunPathAnimation.value,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  );
                },
              ),
              
              // Date and location info
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(isCompact ? 16 : 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateLocationInfo(context, screenSize),
                    ],
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
  
  // Build calendar grid
  Widget _buildCalendarGrid(BuildContext context, ScreenSize screenSize) {
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;
    
    return AnimatedBuilder(
      animation: _calendarScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _calendarScaleAnimation.value,
          child: Column(
            children: [
              // Month navigation
              _buildMonthNavigation(context, screenSize),
              
              // Weekday headers
              _buildWeekdayHeaders(context, screenSize),
              
              // Calendar grid
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: _calendarCellAspectRatio,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: 42, // 6 weeks
                  itemBuilder: (context, index) {
                    final dayNumber = index - firstWeekday + 2;
                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const SizedBox.shrink();
                    }
                    
                    final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
                    final isSelected = _isSameDay(date, _selectedDate);
                    final isToday = _isSameDay(date, DateTime.now());
                    final hasFestival = _hasFestival(date);
                    
                    return _buildCalendarCell(
                      context,
                      screenSize,
                      date,
                      dayNumber,
                      isSelected,
                      isToday,
                      hasFestival,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Build calendar cell
  Widget _buildCalendarCell(
    BuildContext context,
    ScreenSize screenSize,
    DateTime date,
    int dayNumber,
    bool isSelected,
    bool isToday,
    bool hasFestival,
  ) {
    final isCompact = screenSize == ScreenSize.mobile;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
        HapticFeedback.lightImpact();
        _showDayDetails(date);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isToday
                  ? AppColors.primary.withOpacity(0.1)
                  : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isToday
                ? AppColors.primary
                : Theme.of(context).dividerColor.withOpacity(0.3),
            width: isToday ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayNumber.toString(),
              style: TextStyle(
                fontSize: isCompact ? 14 : 16,
                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : null,
              ),
            ),
            if (!isCompact) ...[
              const SizedBox(height: 2),
              Text(
                _getLunarDay(date),
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? Colors.white70
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
            if (hasFestival)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Build tithi nakshatra cards
  Widget _buildTithiNakshatraCards(BuildContext context, ScreenSize screenSize) {
    final isCompact = screenSize == ScreenSize.mobile;
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildInfoCard(
          context,
          'Tithi',
          _panchangData?['tithi'] ?? 'Shukla Paksha Panchami',
          Icons.brightness_3,
          Colors.purple,
          0,
        ),
        _buildInfoCard(
          context,
          'Nakshatra',
          _panchangData?['nakshatra'] ?? 'Rohini',
          Icons.star,
          Colors.indigo,
          1,
        ),
        _buildInfoCard(
          context,
          'Yoga',
          _panchangData?['yoga'] ?? 'Shobhana',
          Icons.self_improvement,
          Colors.green,
          2,
        ),
        _buildInfoCard(
          context,
          'Karana',
          _panchangData?['karana'] ?? 'Bava',
          Icons.timeline,
          Colors.orange,
          3,
        ),
        if (!isCompact) ...[
          _buildInfoCard(
            context,
            'Paksha',
            _panchangData?['paksha'] ?? 'Shukla',
            Icons.contrast,
            Colors.blue,
            4,
          ),
          _buildInfoCard(
            context,
            'Rashi',
            _panchangData?['rashi'] ?? 'Vrishabha',
            Icons.stars,
            Colors.red,
            5,
          ),
        ],
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
      animation: index < _cardFadeAnimations.length
          ? _cardFadeAnimations[index]
          : _cardFadeAnimations.last,
      builder: (context, child) {
        final animation = index < _cardFadeAnimations.length
            ? _cardFadeAnimations[index]
            : _cardFadeAnimations.last;
        
        return FadeTransition(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: Container(
              constraints: const BoxConstraints(minWidth: 140),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Build sunrise sunset visualization
  Widget _buildSunriseSunsetVisualization(
    BuildContext context,
    ScreenSize screenSize,
  ) {
    final sunrise = DateTime.now().copyWith(hour: 6, minute: 30);
    final sunset = DateTime.now().copyWith(hour: 18, minute: 15);
    final currentTime = DateTime.now();
    
    final totalMinutes = sunset.difference(sunrise).inMinutes;
    final elapsedMinutes = currentTime.difference(sunrise).inMinutes;
    final progress = (elapsedMinutes / totalMinutes).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sun Position',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 16),
          
          // Sun arc visualization
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: Size.infinite,
              painter: SunArcPainter(
                progress: progress,
                sunriseTime: DateFormat('HH:mm').format(sunrise),
                sunsetTime: DateFormat('HH:mm').format(sunset),
                isDarkMode: Theme.of(context).brightness == Brightness.dark,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Times row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeInfo(context, 'Sunrise', sunrise, Icons.wb_sunny, Colors.orange),
              _buildTimeInfo(context, 'Solar Noon', 
                  sunrise.add(Duration(minutes: totalMinutes ~/ 2)), 
                  Icons.wb_sunny, Colors.yellow),
              _buildTimeInfo(context, 'Sunset', sunset, Icons.nightlight, Colors.purple),
            ],
          ),
          
          // Timezone display
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.public,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _selectedTimezone,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
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
  
  // Build time info
  Widget _buildTimeInfo(
    BuildContext context,
    String label,
    DateTime time,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        Text(
          DateFormat('HH:mm').format(time),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  // Build festivals list
  Widget _buildFestivalsList(BuildContext context, ScreenSize screenSize) {
    final isCompact = screenSize == ScreenSize.mobile;
    
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Festivals',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!isCompact)
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          ...List.generate(
            isCompact ? math.min(3, _festivals.length) : _festivals.length,
            (index) => _buildFestivalItem(
              context,
              screenSize,
              _festivals[index],
              isCompact,
            ),
          ),
        ],
      ),
    );
  }
  
  // Build festival item
  Widget _buildFestivalItem(
    BuildContext context,
    ScreenSize screenSize,
    Festival festival,
    bool isCompact,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(isCompact ? 8 : 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: isCompact ? 40 : 48,
            height: isCompact ? 40 : 48,
            decoration: BoxDecoration(
              color: _getFestivalColor(festival.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                DateFormat('dd').format(festival.date),
                style: TextStyle(
                  color: _getFestivalColor(festival.type),
                  fontWeight: FontWeight.bold,
                  fontSize: isCompact ? 14 : 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  festival.name,
                  style: TextStyle(
                    fontSize: isCompact ? 14 : 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isCompact)
                  Text(
                    festival.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getFestivalColor(festival.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              festival.type,
              style: TextStyle(
                fontSize: 10,
                color: _getFestivalColor(festival.type),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build muhurat timeline
  Widget _buildMuhuratTimeline(BuildContext context, ScreenSize screenSize) {
    final isCompact = screenSize == ScreenSize.mobile;
    
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Auspicious Timings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Timeline
          SizedBox(
            height: isCompact ? 200 : 300,
            child: CustomPaint(
              size: Size.infinite,
              painter: MuhuratTimelinePainter(
                muhurats: _muhurats,
                isDarkMode: Theme.of(context).brightness == Brightness.dark,
                isCompact: isCompact,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build collapsible section
  Widget _buildCollapsibleSection(
    BuildContext context,
    String title,
    IconData icon,
    bool isExpanded,
    VoidCallback onToggle,
    Widget content,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: content,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
  
  // Helper methods
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  bool _hasFestival(DateTime date) {
    return _festivals.any((f) => _isSameDay(f.date, date));
  }
  
  String _getLunarDay(DateTime date) {
    // Simplified lunar day calculation
    return 'S${(date.day % 15) + 1}';
  }
  
  Color _getFestivalColor(String type) {
    switch (type) {
      case 'Major':
        return Colors.red;
      case 'Religious':
        return Colors.orange;
      case 'Regional':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }
  
  void _showDayDetails(DateTime date) {
    // Show bottom sheet with day details
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DayDetailsSheet(date: date),
    );
  }
  
  // Additional UI builders (stubs)
  Widget _buildQuickInfoCards(BuildContext context, ScreenSize screenSize) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _buildTithiNakshatraCards(context, screenSize),
    );
  }
  
  Widget _buildCompactHeader(BuildContext context, ScreenSize screenSize) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: const Text(
        'Calendar',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
  
  Widget _buildTabBar(BuildContext context, ScreenSize screenSize) {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Details'),
        Tab(text: 'Tithi'),
        Tab(text: 'Festivals'),
        Tab(text: 'Muhurat'),
        Tab(text: 'Settings'),
      ],
    );
  }
  
  Widget _buildTabContent(BuildContext context, ScreenSize screenSize) {
    return TabBarView(
      controller: _tabController,
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildTithiNakshatraCards(context, screenSize),
        ),
        const Center(child: Text('Tithi Details')),
        _buildFestivalsList(context, screenSize),
        _buildMuhuratTimeline(context, screenSize),
        const Center(child: Text('Settings')),
      ],
    );
  }
  
  Widget _buildDesktopHeader(BuildContext context, ScreenSize screenSize) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month, color: AppColors.primary, size: 28),
          const SizedBox(width: 16),
          const Text(
            'Panchang',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          _buildRegionSelector(context),
          const SizedBox(width: 16),
          _buildTimezoneSelector(context),
        ],
      ),
    );
  }
  
  Widget _buildDashboardHeader(BuildContext context, ScreenSize screenSize) {
    return _buildDesktopHeader(context, screenSize);
  }
  
  Widget _buildCalendarSection(BuildContext context, ScreenSize screenSize) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildCalendarGrid(context, screenSize),
      ),
    );
  }
  
  Widget _buildTithiNakshatraSection(BuildContext context, ScreenSize screenSize) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tithi & Nakshatra',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTithiNakshatraCards(context, screenSize),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFestivalsSection(BuildContext context, ScreenSize screenSize) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildFestivalsList(context, screenSize),
      ),
    );
  }
  
  Widget _buildMuhuratSection(BuildContext context, ScreenSize screenSize) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildMuhuratTimeline(context, screenSize),
      ),
    );
  }
  
  Widget _buildMonthNavigation(BuildContext context, ScreenSize screenSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
            });
          },
        ),
        Text(
          DateFormat('MMMM yyyy').format(_focusedMonth),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildWeekdayHeaders(BuildContext context, ScreenSize screenSize) {
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Container(
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildDateLocationInfo(BuildContext context, ScreenSize screenSize) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Text(
          DateFormat('dd MMMM yyyy').format(_selectedDate),
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(width: 16),
        Icon(Icons.location_on, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Text(
          _selectedRegion,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }
  
  List<Widget> _buildAppBarActions(BuildContext context, ScreenSize screenSize) {
    return [
      IconButton(
        icon: const Icon(Icons.today),
        onPressed: () {
          setState(() {
            _selectedDate = DateTime.now();
            _focusedMonth = DateTime.now();
          });
        },
      ),
      PopupMenuButton<String>(
        onSelected: (value) {},
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'settings', child: Text('Settings')),
          const PopupMenuItem(value: 'export', child: Text('Export')),
        ],
      ),
    ];
  }
  
  Widget _buildRegionSelector(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedRegion,
      underline: const SizedBox(),
      items: ['North India', 'South India', 'East India', 'West India']
          .map((region) => DropdownMenuItem(
                value: region,
                child: Text(region),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedRegion = value;
          });
        }
      },
    );
  }
  
  Widget _buildTimezoneSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.public, size: 16),
          const SizedBox(width: 8),
          Text(_selectedTimezone, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

// Models
class Festival {
  final String name;
  final DateTime date;
  final String type;
  final String description;
  
  Festival({
    required this.name,
    required this.date,
    required this.type,
    required this.description,
  });
}

class Muhurat {
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final String type;
  
  Muhurat({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.type,
  });
}

// Custom painters
class SunPathPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  SunPathPainter({
    required this.progress,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Draw sun path arc
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      -size.height / 2,
      size.width,
      size.height,
    );
    
    canvas.drawPath(path, paint);
    
    // Draw sun position
    final sunPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    
    final sunX = size.width * progress;
    final sunY = size.height - (math.sin(progress * math.pi) * size.height);
    
    canvas.drawCircle(Offset(sunX, sunY), 8, sunPaint);
  }
  
  @override
  bool shouldRepaint(SunPathPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class SunArcPainter extends CustomPainter {
  final double progress;
  final String sunriseTime;
  final String sunsetTime;
  final bool isDarkMode;
  
  SunArcPainter({
    required this.progress,
    required this.sunriseTime,
    required this.sunsetTime,
    required this.isDarkMode,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw horizon line
    final horizonPaint = Paint()
      ..color = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawLine(
      Offset(0, size.height * 0.8),
      Offset(size.width, size.height * 0.8),
      horizonPaint,
    );
    
    // Draw sun path
    final pathPaint = Paint()
      ..color = Colors.orange.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.8);
    path.quadraticBezierTo(
      size.width / 2,
      size.height * 0.1,
      size.width * 0.9,
      size.height * 0.8,
    );
    
    canvas.drawPath(path, pathPaint);
    
    // Draw sun
    final sunPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    
    final sunX = size.width * 0.1 + (size.width * 0.8 * progress);
    final sunY = size.height * 0.8 - (math.sin(progress * math.pi) * size.height * 0.6);
    
    // Sun glow
    final glowPaint = Paint()
      ..color = Colors.orange.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(sunX, sunY), 20, glowPaint);
    canvas.drawCircle(Offset(sunX, sunY), 12, sunPaint);
    
    // Draw rays
    final rayPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final startX = sunX + math.cos(angle) * 16;
      final startY = sunY + math.sin(angle) * 16;
      final endX = sunX + math.cos(angle) * 24;
      final endY = sunY + math.sin(angle) * 24;
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
    }
  }
  
  @override
  bool shouldRepaint(SunArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class MuhuratTimelinePainter extends CustomPainter {
  final List<Muhurat> muhurats;
  final bool isDarkMode;
  final bool isCompact;
  
  MuhuratTimelinePainter({
    required this.muhurats,
    required this.isDarkMode,
    required this.isCompact,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw timeline
    final linePaint = Paint()
      ..color = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawLine(
      Offset(40, 0),
      Offset(40, size.height),
      linePaint,
    );
    
    // Draw muhurats
    final hourHeight = size.height / 24;
    
    for (final muhurat in muhurats) {
      final startY = muhurat.startTime.hour * hourHeight;
      final endY = muhurat.endTime.hour * hourHeight;
      
      // Draw muhurat block
      final blockPaint = Paint()
        ..color = _getMuhuratColor(muhurat.type).withOpacity(0.3)
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(60, startY, size.width - 80, endY - startY),
          const Radius.circular(8),
        ),
        blockPaint,
      );
      
      // Draw dot
      final dotPaint = Paint()
        ..color = _getMuhuratColor(muhurat.type)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(40, startY + (endY - startY) / 2), 6, dotPaint);
    }
  }
  
  Color _getMuhuratColor(String type) {
    switch (type) {
      case 'Auspicious':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Average':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  @override
  bool shouldRepaint(MuhuratTimelinePainter oldDelegate) {
    return oldDelegate.muhurats != muhurats;
  }
}

// Day details sheet
class DayDetailsSheet extends StatelessWidget {
  final DateTime date;
  
  const DayDetailsSheet({super.key, required this.date});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            DateFormat('EEEE, dd MMMM yyyy').format(date),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Add more day details here
          const Text('Detailed panchang information for this day'),
        ],
      ),
    );
  }
}
