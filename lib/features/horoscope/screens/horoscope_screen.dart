import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/horoscope_provider.dart';
import '../../../core/constants/app_colors.dart';

// Responsive breakpoints
class HoroscopeBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1800;
}

// Screen size categories
enum ScreenSize { mobile, tablet, desktop, largeDesktop }

// Layout modes
enum HoroscopeLayout {
  compact, // Mobile - single column
  expanded, // Tablet - two columns
  desktop, // Desktop - multi-panel
  ultraWide, // Large desktop - maximum content
}

// Category display modes
enum CategoryDisplay {
  horizontal, // Mobile - horizontal scroll
  grid, // Tablet+ - grid layout
  cards, // Desktop - large cards
}

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen>
    with TickerProviderStateMixin {
  // Controllers
  late TabController _mainTabController;
  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _glassController;
  late AnimationController _cardElevationController;
  late AnimationController _planetaryController;
  late AnimationController _luckyElementsController;
  late ScrollController _categoryScrollController;

  // Animations
  late Animation<double> _headerAnimation;
  // ignore: unused_field
  late Animation<double> _contentFadeAnimation;
  late Animation<double> _glassAnimation;
  // ignore: unused_field
  late Animation<double> _cardElevationAnimation;
  late Animation<double> _planetaryRotation;
  late Animation<double> _luckyElementsAnimation;

  // State
  int _currentTab = 0;
  bool _isKundliMode = true;
  String _selectedCategory = 'general';
  String _userSign = 'Aries';
  HoroscopeLayout _currentLayout = HoroscopeLayout.compact;
  bool _isFirstLoad = true;

  // Categories
  final List<HoroscopeCategory> _categories = [
    HoroscopeCategory(
      'general',
      'General',
      Icons.stars_rounded,
      const Color(0xFF6C5CE7),
    ),
    HoroscopeCategory(
      'love',
      'Love',
      Icons.favorite_rounded,
      const Color(0xFFFF6B94),
    ),
    HoroscopeCategory(
      'career',
      'Career',
      Icons.work_rounded,
      const Color(0xFF3498DB),
    ),
    HoroscopeCategory(
      'health',
      'Health',
      Icons.health_and_safety_rounded,
      const Color(0xFF4ECDC4),
    ),
    HoroscopeCategory(
      'finance',
      'Finance',
      Icons.account_balance_wallet_rounded,
      const Color(0xFFFFA502),
    ),
    HoroscopeCategory(
      'family',
      'Family',
      Icons.family_restroom_rounded,
      const Color(0xFF95E1D3),
    ),
  ];

  // Lucky elements
  final Map<String, LuckyElements> _luckyElements = {
    'Aries': LuckyElements(
      color: const Color(0xFFFF6B6B),
      number: 9,
      gemstone: 'Ruby',
      day: 'Tuesday',
      direction: 'East',
    ),
    'Taurus': LuckyElements(
      color: const Color(0xFF4ECDC4),
      number: 6,
      gemstone: 'Emerald',
      day: 'Friday',
      direction: 'South',
    ),
    // Add more signs...
  };

  // Planetary positions
  final List<PlanetaryPosition> _planetaryPositions = [
    PlanetaryPosition('Sun', 0, const Color(0xFFFFA502), 24),
    PlanetaryPosition('Moon', 45, const Color(0xFF95E1D3), 20),
    PlanetaryPosition('Mercury', 90, const Color(0xFF3498DB), 16),
    PlanetaryPosition('Venus', 135, const Color(0xFFFF6B94), 18),
    PlanetaryPosition('Mars', 180, const Color(0xFFFF6B6B), 20),
    PlanetaryPosition('Jupiter', 225, const Color(0xFFB983FF), 28),
    PlanetaryPosition('Saturn', 270, const Color(0xFF6C5B7B), 26),
  ];

  @override
  void initState() {
    super.initState();
    _categoryScrollController = ScrollController();
    _mainTabController = TabController(length: 4, vsync: this);
    // Initialize controllers with default durations, will update in didChangeDependencies
    _initControllersWithDefaults();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now safe to access MediaQuery and context
    _updateAnimationControllers();

    // Only load data once
    if (_isFirstLoad) {
      _isFirstLoad = false;
      _loadData();
    }
  }

  void _initControllersWithDefaults() {
    // Initialize with default durations (will be updated in didChangeDependencies)
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _glassController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _cardElevationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _planetaryController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _luckyElementsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Initialize animations
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeInOut),
    );

    _glassAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glassController, curve: Curves.easeInOut),
    );

    _cardElevationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardElevationController,
        curve: Curves.easeOutBack,
      ),
    );

    _planetaryRotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _planetaryController, curve: Curves.linear),
    );

    _luckyElementsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _luckyElementsController,
        curve: Curves.elasticOut,
      ),
    );

    // Start animations
    _headerController.forward();
    _contentController.forward();
    _glassController.forward();
    _cardElevationController.forward();
    _luckyElementsController.forward();

    // Tab listener
    _mainTabController.addListener(() {
      if (_mainTabController.index != _currentTab) {
        setState(() {
          _currentTab = _mainTabController.index;
        });
        _contentController.forward(from: 0);
        _glassController.forward(from: 0);
      }
    });
  }

  void _updateAnimationControllers() {
    // Update animation durations based on screen size
    final animationSpeed = _getAdaptiveAnimationSpeed();

    _headerController.duration = Duration(milliseconds: animationSpeed.header);
    _contentController.duration = Duration(
      milliseconds: animationSpeed.content,
    );
    _glassController.duration = Duration(milliseconds: animationSpeed.glass);
    _cardElevationController.duration = Duration(
      milliseconds: animationSpeed.card,
    );
    _luckyElementsController.duration = Duration(
      milliseconds: animationSpeed.elements,
    );
  }

  Future<void> _loadData() async {
    final horoscopeProvider = context.read<HoroscopeProvider>();
    await horoscopeProvider.fetchDailyHoroscopes();

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user?.zodiacSign != null) {
      setState(() {
        _userSign = user!.zodiacSign;
      });
    }
  }

  // Get screen size category
  ScreenSize _getScreenSize(double width) {
    if (width < HoroscopeBreakpoints.mobile) return ScreenSize.mobile;
    if (width < HoroscopeBreakpoints.tablet) return ScreenSize.tablet;
    if (width < HoroscopeBreakpoints.desktop) return ScreenSize.desktop;
    return ScreenSize.largeDesktop;
  }

  // Get layout mode
  HoroscopeLayout _getLayout(double width) {
    final screenSize = _getScreenSize(width);
    switch (screenSize) {
      case ScreenSize.mobile:
        return HoroscopeLayout.compact;
      case ScreenSize.tablet:
        return HoroscopeLayout.expanded;
      case ScreenSize.desktop:
        return HoroscopeLayout.desktop;
      case ScreenSize.largeDesktop:
        return HoroscopeLayout.ultraWide;
    }
  }

  // Get category display mode
  CategoryDisplay _getCategoryDisplay(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return CategoryDisplay.horizontal;
      case ScreenSize.tablet:
        return CategoryDisplay.grid;
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return CategoryDisplay.cards;
    }
  }

  // Get adaptive animation speeds
  AnimationSpeed _getAdaptiveAnimationSpeed() {
    final width = MediaQuery.of(context).size.width;
    final screenSize = _getScreenSize(width);

    switch (screenSize) {
      case ScreenSize.mobile:
        return AnimationSpeed(
          header: 600,
          content: 400,
          glass: 300,
          card: 200,
          elements: 500,
        );
      case ScreenSize.tablet:
        return AnimationSpeed(
          header: 700,
          content: 500,
          glass: 400,
          card: 300,
          elements: 600,
        );
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return AnimationSpeed(
          header: 800,
          content: 600,
          glass: 500,
          card: 400,
          elements: 700,
        );
    }
  }

  // Get responsive elevation
  double _getResponsiveElevation(
    ScreenSize screenSize, {
    bool isHovered = false,
  }) {
    final baseElevation = switch (screenSize) {
      ScreenSize.mobile => 2.0,
      ScreenSize.tablet => 4.0,
      ScreenSize.desktop => 6.0,
      ScreenSize.largeDesktop => 8.0,
    };

    return isHovered ? baseElevation * 1.5 : baseElevation;
  }

  // Get responsive shadow
  List<BoxShadow> _getResponsiveShadow(
    ScreenSize screenSize,
    Color color, {
    bool isHovered = false,
  }) {
    final elevation = _getResponsiveElevation(screenSize, isHovered: isHovered);

    return [
      BoxShadow(
        color: color.withOpacity(0.1 * (elevation / 8)),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
      ),
      if (screenSize != ScreenSize.mobile)
        BoxShadow(
          color: color.withOpacity(0.05),
          blurRadius: elevation * 4,
          offset: Offset(0, elevation * 2),
        ),
    ];
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _headerController.dispose();
    _contentController.dispose();
    _glassController.dispose();
    _cardElevationController.dispose();
    _planetaryController.dispose();
    _luckyElementsController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final screenSize = _getScreenSize(screenWidth);
        final layout = _getLayout(screenWidth);
        final categoryDisplay = _getCategoryDisplay(screenSize);

        // Update layout state
        if (_currentLayout != layout) {
          _currentLayout = layout;
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              // Animated background
              if (screenSize != ScreenSize.mobile)
                _buildAnimatedBackground(screenSize),

              // Main content
              _buildResponsiveLayout(
                context,
                screenSize,
                layout,
                categoryDisplay,
                screenWidth,
                screenHeight,
              ),
            ],
          ),
        );
      },
    );
  }

  // Build animated background
  Widget _buildAnimatedBackground(ScreenSize screenSize) {
    return AnimatedBuilder(
      animation: _planetaryRotation,
      builder: (context, child) {
        return CustomPaint(
          painter: CosmicBackgroundPainter(
            rotation: _planetaryRotation.value,
            opacity: 0.05,
          ),
          child: Container(),
        );
      },
    );
  }

  // Build responsive layout
  Widget _buildResponsiveLayout(
    BuildContext context,
    ScreenSize screenSize,
    HoroscopeLayout layout,
    CategoryDisplay categoryDisplay,
    double screenWidth,
    double screenHeight,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    switch (layout) {
      case HoroscopeLayout.compact:
        return _buildMobileLayout(
          context,
          screenSize,
          categoryDisplay,
          isDarkMode,
        );
      case HoroscopeLayout.expanded:
        return _buildTabletLayout(
          context,
          screenSize,
          categoryDisplay,
          isDarkMode,
          screenWidth,
        );
      case HoroscopeLayout.desktop:
        return _buildDesktopLayout(
          context,
          screenSize,
          categoryDisplay,
          isDarkMode,
          screenWidth,
        );
      case HoroscopeLayout.ultraWide:
        return _buildUltraWideLayout(
          context,
          screenSize,
          categoryDisplay,
          isDarkMode,
          screenWidth,
        );
    }
  }

  // Mobile layout
  Widget _buildMobileLayout(
    BuildContext context,
    ScreenSize screenSize,
    CategoryDisplay categoryDisplay,
    bool isDarkMode,
  ) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          _buildResponsiveHeader(context, screenSize, isDarkMode),

          // Tab bar
          _buildResponsiveTabBar(context, screenSize, isDarkMode),

          // Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Categories (horizontal scroll)
                  _buildCategorySection(
                    context,
                    screenSize,
                    categoryDisplay,
                    isDarkMode,
                  ),

                  // Main prediction card
                  _buildMainPredictionCard(context, screenSize, isDarkMode),

                  // Lucky elements
                  _buildLuckyElementsSection(context, screenSize, isDarkMode),

                  // Planetary positions
                  _buildPlanetaryPositions(context, screenSize, isDarkMode),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tablet layout
  Widget _buildTabletLayout(
    BuildContext context,
    ScreenSize screenSize,
    CategoryDisplay categoryDisplay,
    bool isDarkMode,
    double screenWidth,
  ) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          _buildResponsiveHeader(context, screenSize, isDarkMode),

          // Tab bar
          _buildResponsiveTabBar(context, screenSize, isDarkMode),

          // Content
          Expanded(
            child: Row(
              children: [
                // Left panel
                SizedBox(
                  width: screenWidth * 0.4,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildPlanetaryPositions(
                          context,
                          screenSize,
                          isDarkMode,
                        ),
                        const SizedBox(height: 16),
                        _buildLuckyElementsSection(
                          context,
                          screenSize,
                          isDarkMode,
                        ),
                      ],
                    ),
                  ),
                ),

                // Right panel
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildCategorySection(
                          context,
                          screenSize,
                          categoryDisplay,
                          isDarkMode,
                        ),
                        const SizedBox(height: 16),
                        _buildMainPredictionCard(
                          context,
                          screenSize,
                          isDarkMode,
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
    );
  }

  // Desktop layout
  Widget _buildDesktopLayout(
    BuildContext context,
    ScreenSize screenSize,
    CategoryDisplay categoryDisplay,
    bool isDarkMode,
    double screenWidth,
  ) {
    return SafeArea(
      child: Row(
        children: [
          // Sidebar
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
              border: Border(
                right: BorderSide(
                  color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
            ),
            child: Column(
              children: [
                _buildResponsiveHeader(context, screenSize, isDarkMode),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildPlanetaryPositions(
                          context,
                          screenSize,
                          isDarkMode,
                        ),
                        const SizedBox(height: 20),
                        _buildLuckyElementsSection(
                          context,
                          screenSize,
                          isDarkMode,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Tab bar
                _buildResponsiveTabBar(context, screenSize, isDarkMode),

                // Content area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildCategorySection(
                          context,
                          screenSize,
                          categoryDisplay,
                          isDarkMode,
                        ),
                        const SizedBox(height: 24),
                        _buildMainPredictionCard(
                          context,
                          screenSize,
                          isDarkMode,
                        ),
                        const SizedBox(height: 24),
                        _buildAdditionalInsights(
                          context,
                          screenSize,
                          isDarkMode,
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
    );
  }

  // Ultra-wide layout
  Widget _buildUltraWideLayout(
    BuildContext context,
    ScreenSize screenSize,
    CategoryDisplay categoryDisplay,
    bool isDarkMode,
    double screenWidth,
  ) {
    return SafeArea(
      child: Row(
        children: [
          // Left sidebar
          Container(
            width: 360,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
              border: Border(
                right: BorderSide(
                  color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
            ),
            child: Column(
              children: [
                _buildResponsiveHeader(context, screenSize, isDarkMode),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildPlanetaryPositions(
                          context,
                          screenSize,
                          isDarkMode,
                        ),
                        const SizedBox(height: 24),
                        _buildLuckyElementsSection(
                          context,
                          screenSize,
                          isDarkMode,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Column(
              children: [
                _buildResponsiveTabBar(context, screenSize, isDarkMode),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        _buildCategorySection(
                          context,
                          screenSize,
                          categoryDisplay,
                          isDarkMode,
                        ),
                        const SizedBox(height: 32),
                        _buildMainPredictionCard(
                          context,
                          screenSize,
                          isDarkMode,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right sidebar
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
              border: Border(
                left: BorderSide(
                  color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildAdditionalInsights(context, screenSize, isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  // Build responsive header
  Widget _buildResponsiveHeader(
    BuildContext context,
    ScreenSize screenSize,
    bool isDarkMode,
  ) {
    final isCompact = screenSize == ScreenSize.mobile;

    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: Container(
              padding: EdgeInsets.all(isCompact ? 16 : 24),
              child: Row(
                children: [
                  if (!isCompact)
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Horoscope',
                          style: TextStyle(
                            fontSize: isCompact ? 24 : 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Your cosmic guidance',
                          style: TextStyle(
                            fontSize: isCompact ? 13 : 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildModeSwitcher(isDarkMode, isCompact),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Build mode switcher
  Widget _buildModeSwitcher(bool isDarkMode, bool isCompact) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _isKundliMode = !_isKundliMode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: isCompact ? 8 : 10,
        ),
        decoration: BoxDecoration(
          gradient:
              _isKundliMode
                  ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  )
                  : null,
          color:
              !_isKundliMode
                  ? (isDarkMode ? Colors.grey[800] : Colors.grey[200])
                  : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isKundliMode
                  ? Icons.auto_awesome_rounded
                  : Icons.wb_sunny_rounded,
              size: isCompact ? 16 : 20,
              color:
                  _isKundliMode
                      ? Colors.white
                      : (isDarkMode ? Colors.white : Colors.grey[700]),
            ),
            if (!isCompact) ...[
              const SizedBox(width: 8),
              Text(
                _isKundliMode ? 'Kundli' : 'Sun Sign',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      _isKundliMode
                          ? Colors.white
                          : (isDarkMode ? Colors.white : Colors.grey[700]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Build responsive tab bar
  Widget _buildResponsiveTabBar(
    BuildContext context,
    ScreenSize screenSize,
    bool isDarkMode,
  ) {
    final isCompact = screenSize == ScreenSize.mobile;
    final tabs = ['Today', 'Forecast', 'All Signs', 'Reports'];
    final icons = [
      Icons.today_rounded,
      Icons.calendar_view_week_rounded,
      Icons.grid_view_rounded,
      Icons.description_rounded,
    ];

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 24,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color:
            isDarkMode ? Colors.grey[900]?.withOpacity(0.5) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _mainTabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        tabs: List.generate(
          tabs.length,
          (index) => Tab(
            height: isCompact ? 40 : 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icons[index], size: isCompact ? 16 : 20),
                if (!isCompact || screenSize == ScreenSize.tablet) ...[
                  const SizedBox(width: 4),
                  Text(
                    tabs[index],
                    style: TextStyle(fontSize: isCompact ? 12 : 14),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build category section
  Widget _buildCategorySection(
    BuildContext context,
    ScreenSize screenSize,
    CategoryDisplay display,
    bool isDarkMode,
  ) {
    switch (display) {
      case CategoryDisplay.horizontal:
        return _buildHorizontalCategories(context, screenSize, isDarkMode);
      case CategoryDisplay.grid:
        return _buildGridCategories(context, screenSize, isDarkMode);
      case CategoryDisplay.cards:
        return _buildCardCategories(context, screenSize, isDarkMode);
    }
  }

  // Build horizontal scrolling categories (mobile)
  Widget _buildHorizontalCategories(
    BuildContext context,
    ScreenSize screenSize,
    bool isDarkMode,
  ) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        controller: _categoryScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category.id == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category.id;
              });
              HapticFeedback.lightImpact();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? LinearGradient(
                          colors: [
                            category.color,
                            category.color.withOpacity(0.7),
                          ],
                        )
                        : null,
                color:
                    !isSelected
                        ? (isDarkMode ? Colors.grey[900] : Colors.white)
                        : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _getResponsiveShadow(
                  screenSize,
                  category.color,
                  isHovered: isSelected,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category.icon,
                    size: 32,
                    color: isSelected ? Colors.white : category.color,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected
                              ? Colors.white
                              : (isDarkMode ? Colors.white : Colors.grey[800]),
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

  // Build grid categories (tablet)
  Widget _buildGridCategories(
    BuildContext context,
    ScreenSize screenSize,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category.id == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category.id;
              });
              HapticFeedback.lightImpact();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? LinearGradient(
                          colors: [
                            category.color,
                            category.color.withOpacity(0.7),
                          ],
                        )
                        : null,
                color:
                    !isSelected
                        ? (isDarkMode ? Colors.grey[900] : Colors.white)
                        : null,
                borderRadius: BorderRadius.circular(20),
                boxShadow: _getResponsiveShadow(
                  screenSize,
                  category.color,
                  isHovered: isSelected,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category.icon,
                    size: 36,
                    color: isSelected ? Colors.white : category.color,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected
                              ? Colors.white
                              : (isDarkMode ? Colors.white : Colors.grey[800]),
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

  // Build card categories (desktop)
  Widget _buildCardCategories(
    BuildContext context,
    ScreenSize screenSize,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children:
            _categories.map((category) {
              final isSelected = category.id == _selectedCategory;

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category.id;
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 160,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient:
                          isSelected
                              ? LinearGradient(
                                colors: [
                                  category.color,
                                  category.color.withOpacity(0.7),
                                ],
                              )
                              : null,
                      color:
                          !isSelected
                              ? (isDarkMode ? Colors.grey[900] : Colors.white)
                              : null,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: _getResponsiveShadow(
                        screenSize,
                        category.color,
                        isHovered: isSelected,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category.icon,
                          size: 48,
                          color: isSelected ? Colors.white : category.color,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          category.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                isSelected
                                    ? Colors.white
                                    : (isDarkMode
                                        ? Colors.white
                                        : Colors.grey[800]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  // Build main prediction card with glass morphism
  Widget _buildMainPredictionCard(
    BuildContext context,
    ScreenSize screenSize,
    bool isDarkMode,
  ) {
    final isCompact = screenSize == ScreenSize.mobile;

    return AnimatedBuilder(
      animation: _glassAnimation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.all(isCompact ? 16 : 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: 10 * _glassAnimation.value,
                sigmaY: 10 * _glassAnimation.value,
              ),
              child: Container(
                padding: EdgeInsets.all(isCompact ? 20 : 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (isDarkMode ? Colors.white : Colors.black).withOpacity(
                        0.1,
                      ),
                      (isDarkMode ? Colors.white : Colors.black).withOpacity(
                        0.05,
                      ),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: (isDarkMode ? Colors.white : Colors.black)
                        .withOpacity(0.1),
                  ),
                  boxShadow: _getResponsiveShadow(
                    screenSize,
                    AppColors.primary,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: isCompact ? 48 : 60,
                          height: isCompact ? 48 : 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getZodiacColor(_userSign),
                                _getZodiacColor(_userSign).withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _getZodiacIcon(_userSign),
                            color: Colors.white,
                            size: isCompact ? 28 : 36,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userSign,
                                style: TextStyle(
                                  fontSize: isCompact ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Today\'s Horoscope',
                                style: TextStyle(
                                  fontSize: isCompact ? 14 : 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'The stars align in your favor today. Your natural charisma '
                      'and leadership qualities will help you overcome any challenges. '
                      'This is an excellent time to pursue new opportunities and make '
                      'important decisions that will shape your future.',
                      style: TextStyle(
                        fontSize: isCompact ? 14 : 16,
                        height: 1.6,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Build planetary positions
  Widget _buildPlanetaryPositions(
    BuildContext context,
    ScreenSize screenSize,
    bool isDarkMode,
  ) {
    final isCompact = screenSize == ScreenSize.mobile;
    final size = isCompact ? 200.0 : 280.0;

    return AnimatedBuilder(
      animation: _planetaryRotation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.all(isCompact ? 16 : 20),
          padding: EdgeInsets.all(isCompact ? 16 : 24),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: _getResponsiveShadow(screenSize, AppColors.primary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Planetary Positions',
                style: TextStyle(
                  fontSize: isCompact ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: size,
                  height: size,
                  child: CustomPaint(
                    painter: PlanetaryPositionsPainter(
                      planets: _planetaryPositions,
                      rotation: _planetaryRotation.value,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build lucky elements section
  Widget _buildLuckyElementsSection(
    BuildContext context,
    ScreenSize screenSize,
    bool isDarkMode,
  ) {
    final isCompact = screenSize == ScreenSize.mobile;
    final luckyElements = _luckyElements[_userSign] ?? _luckyElements['Aries']!;

    return AnimatedBuilder(
      animation: _luckyElementsAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _luckyElementsAnimation.value),
          child: Container(
            margin: EdgeInsets.all(isCompact ? 16 : 20),
            padding: EdgeInsets.all(isCompact ? 16 : 24),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: _getResponsiveShadow(screenSize, luckyElements.color),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lucky Elements',
                  style: TextStyle(
                    fontSize: isCompact ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: isCompact ? 12 : 16,
                  runSpacing: isCompact ? 12 : 16,
                  children: [
                    _buildLuckyElement('Color', luckyElements.color, isCompact),
                    _buildLuckyElement(
                      'Number',
                      luckyElements.number,
                      isCompact,
                    ),
                    _buildLuckyElement(
                      'Gemstone',
                      luckyElements.gemstone,
                      isCompact,
                    ),
                    _buildLuckyElement('Day', luckyElements.day, isCompact),
                    _buildLuckyElement(
                      'Direction',
                      luckyElements.direction,
                      isCompact,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build lucky element item
  Widget _buildLuckyElement(String title, dynamic value, bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 16,
        vertical: isCompact ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isCompact ? 11 : 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          if (value is Color)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value,
                borderRadius: BorderRadius.circular(6),
              ),
            )
          else
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: isCompact ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  // Build additional insights (desktop only)
  Widget _buildAdditionalInsights(
    BuildContext context,
    ScreenSize screenSize,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Insights',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildInsightCard(
          'Compatibility',
          'Libra, Sagittarius',
          Icons.favorite,
          Colors.pink,
          isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          'Element',
          'Fire',
          Icons.local_fire_department,
          Colors.orange,
          isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          'Quality',
          'Cardinal',
          Icons.diamond,
          Colors.blue,
          isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          'Ruling Planet',
          'Mars',
          Icons.language,
          Colors.red,
          isDarkMode,
        ),
      ],
    );
  }

  // Build insight card
  Widget _buildInsightCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
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
        ],
      ),
    );
  }

  // Get zodiac color
  Color _getZodiacColor(String sign) {
    final colors = {
      'Aries': const Color(0xFFFF6B6B),
      'Taurus': const Color(0xFF4ECDC4),
      'Gemini': const Color(0xFFFFD93D),
      'Cancer': const Color(0xFF95E1D3),
      'Leo': const Color(0xFFFFA502),
      'Virgo': const Color(0xFFA8E6CF),
      'Libra': const Color(0xFFFF8B94),
      'Scorpio': const Color(0xFF8B5CF6),
      'Sagittarius': const Color(0xFFB983FF),
      'Capricorn': const Color(0xFF6C5B7B),
      'Aquarius': const Color(0xFF3498DB),
      'Pisces': const Color(0xFF74B9FF),
    };
    return colors[sign] ?? AppColors.primary;
  }

  // Get zodiac icon
  IconData _getZodiacIcon(String sign) {
    switch (sign.toLowerCase()) {
      case 'aries':
        return Icons.whatshot_rounded;
      case 'taurus':
        return Icons.terrain_rounded;
      case 'gemini':
        return Icons.people_rounded;
      case 'cancer':
        return Icons.home_rounded;
      case 'leo':
        return Icons.sunny;
      case 'virgo':
        return Icons.eco_rounded;
      case 'libra':
        return Icons.balance_rounded;
      case 'scorpio':
        return Icons.water_drop_rounded;
      case 'sagittarius':
        return Icons.explore_rounded;
      case 'capricorn':
        return Icons.landscape_rounded;
      case 'aquarius':
        return Icons.air_rounded;
      case 'pisces':
        return Icons.waves_rounded;
      default:
        return Icons.stars_rounded;
    }
  }
}

// Models
class HoroscopeCategory {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  HoroscopeCategory(this.id, this.title, this.icon, this.color);
}

class LuckyElements {
  final Color color;
  final int number;
  final String gemstone;
  final String day;
  final String direction;

  LuckyElements({
    required this.color,
    required this.number,
    required this.gemstone,
    required this.day,
    required this.direction,
  });
}

class PlanetaryPosition {
  final String name;
  final double angle;
  final Color color;
  final double size;

  PlanetaryPosition(this.name, this.angle, this.color, this.size);
}

class AnimationSpeed {
  final int header;
  final int content;
  final int glass;
  final int card;
  final int elements;

  AnimationSpeed({
    required this.header,
    required this.content,
    required this.glass,
    required this.card,
    required this.elements,
  });
}

// Custom painters
class CosmicBackgroundPainter extends CustomPainter {
  final double rotation;
  final double opacity;

  CosmicBackgroundPainter({required this.rotation, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..strokeWidth = 2;

    // Draw rotating cosmic elements
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 * math.pi / 180) + rotation;
      final x = size.width / 2 + math.cos(angle) * size.width * 0.3;
      final y = size.height / 2 + math.sin(angle) * size.height * 0.3;

      paint.color = AppColors.primary.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), 50, paint);
    }
  }

  @override
  bool shouldRepaint(CosmicBackgroundPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}

class PlanetaryPositionsPainter extends CustomPainter {
  final List<PlanetaryPosition> planets;
  final double rotation;
  final bool isDarkMode;

  PlanetaryPositionsPainter({
    required this.planets,
    required this.rotation,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw orbit circles
    final orbitPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1);

    for (double i = 0.3; i <= 0.9; i += 0.2) {
      canvas.drawCircle(center, radius * i, orbitPaint);
    }

    // Draw planets
    for (final planet in planets) {
      final angle = (planet.angle * math.pi / 180) + rotation;
      final x = center.dx + math.cos(angle) * radius * 0.7;
      final y = center.dy + math.sin(angle) * radius * 0.7;

      final planetPaint =
          Paint()
            ..style = PaintingStyle.fill
            ..color = planet.color;

      canvas.drawCircle(Offset(x, y), planet.size / 2, planetPaint);
    }

    // Draw sun at center
    final sunPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xFFFFA502);

    canvas.drawCircle(center, 20, sunPaint);
  }

  @override
  bool shouldRepaint(PlanetaryPositionsPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}
