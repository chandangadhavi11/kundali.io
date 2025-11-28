import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

// Responsive breakpoints
class OnboardingBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

// Screen size categories
enum ScreenCategory { mobile, tablet, desktop }

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Track swipe velocity for smooth transitions
  double _swipeVelocity = 0;
  
  // Flag to ensure orientation is set only once
  bool _orientationSet = false;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.auto_awesome,
      title: 'Generate Your Kundli',
      description:
          'Create accurate birth charts instantly with precise planetary calculations',
      color: AppColors.primary,
      backgroundPattern: OnboardingPattern.circles,
    ),
    OnboardingData(
      icon: Icons.calendar_today,
      title: 'Daily Panchang & Horoscope',
      description: 'Get personalized daily predictions and auspicious timings',
      color: AppColors.secondary,
      backgroundPattern: OnboardingPattern.waves,
    ),
    OnboardingData(
      icon: Icons.chat_bubble_outline,
      title: 'AI Astrologer',
      description:
          'Ask questions and receive instant guidance from our AI-powered astrologer',
      color: AppColors.accent,
      backgroundPattern: OnboardingPattern.stars,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set preferred orientations based on device type
    // This must be called here, not in initState, because MediaQuery is not available in initState
    if (!_orientationSet) {
      _setPreferredOrientations();
      _orientationSet = true;
    }
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Start initial animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _setPreferredOrientations() {
    // Allow all orientations for tablets and desktops
    final size = MediaQuery.of(context).size;
    if (size.shortestSide >= OnboardingBreakpoints.tablet) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  ScreenCategory _getScreenCategory(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < OnboardingBreakpoints.mobile) return ScreenCategory.mobile;
    if (width < OnboardingBreakpoints.tablet) return ScreenCategory.tablet;
    return ScreenCategory.desktop;
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    // Trigger animations on page change
    _fadeController.forward(from: 0);
    _slideController.forward(from: 0);
    _scaleController.forward(from: 0);
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingKey, true);
    if (!mounted) return;
    // Go directly to home for guest access
    context.go('/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenCategory = _getScreenCategory(context);
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final safeArea = MediaQuery.of(context).padding;

    // Determine if we should use horizontal layout
    final useHorizontalLayout =
        (screenCategory == ScreenCategory.tablet && isLandscape) ||
        screenCategory == ScreenCategory.desktop;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
            ],
          ),
        ),
        child: SafeArea(
          minimum: EdgeInsets.only(
            top: safeArea.top > 0 ? 0 : 20, // Handle notched devices
            bottom: safeArea.bottom > 0 ? 0 : 20,
          ),
          child:
              useHorizontalLayout
                  ? _buildHorizontalLayout(context, screenCategory)
                  : _buildVerticalLayout(context, screenCategory),
        ),
      ),
    );
  }

  // Vertical layout for mobile and portrait tablet
  Widget _buildVerticalLayout(BuildContext context, ScreenCategory category) {
    final size = MediaQuery.of(context).size;
    final textScaleFactor = _getTextScaleFactor(category);
    final buttonHeight = _getButtonHeight(category);
    final padding = _getResponsivePadding(category);

    return Column(
      children: [
        // Skip button with responsive padding
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.only(top: padding.top, right: padding.right),
            child: _buildSkipButton(context, category),
          ),
        ),
        // Page content with swipeable pages
        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              _swipeVelocity = details.velocity.pixelsPerSecond.dx;
              if (_swipeVelocity < -500 && _currentPage < _pages.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else if (_swipeVelocity > 500 && _currentPage > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _pages.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                    }
                    return Center(
                      child: SizedBox(
                        height:
                            Curves.easeOut.transform(value) * size.height * 0.7,
                        child: Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: value,
                            child: _buildPageContent(
                              _pages[index],
                              category,
                              textScaleFactor,
                              isVertical: true,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        // Page indicators and navigation
        Padding(
          padding: padding,
          child: Column(
            children: [
              // Page indicators with smooth animation
              _buildPageIndicators(category),
              SizedBox(height: _getResponsiveSpacing(category) * 1.5),
              // Navigation buttons
              _buildNavigationButtons(
                context,
                category,
                buttonHeight,
                textScaleFactor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Horizontal layout for landscape tablets and desktop
  Widget _buildHorizontalLayout(BuildContext context, ScreenCategory category) {
    final size = MediaQuery.of(context).size;
    final textScaleFactor = _getTextScaleFactor(category);
    final buttonHeight = _getButtonHeight(category);
    final padding = _getResponsivePadding(category);

    return Row(
      children: [
        // Left side - Content
        Expanded(
          flex: 3,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(padding.left),
                child: _buildPageContent(
                  _pages[index],
                  category,
                  textScaleFactor,
                  isVertical: false,
                ),
              );
            },
          ),
        ),
        // Right side - Controls
        Container(
          width: math.min(size.width * 0.35, 400),
          padding: padding,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.5),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              bottomLeft: Radius.circular(32),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: _buildSkipButton(context, category),
              ),
              const Spacer(),
              // Page indicators
              _buildPageIndicators(category),
              SizedBox(height: _getResponsiveSpacing(category) * 2),
              // Navigation buttons
              _buildNavigationButtons(
                context,
                category,
                buttonHeight,
                textScaleFactor,
              ),
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }

  // Build page content with responsive scaling
  Widget _buildPageContent(
    OnboardingData data,
    ScreenCategory category,
    double textScaleFactor, {
    required bool isVertical,
  }) {
    final iconSize = _getIconSize(category);
    final spacing = _getResponsiveSpacing(category);
    final maxContentWidth = _getMaxContentWidth(category);

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        padding: EdgeInsets.symmetric(horizontal: spacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animated icon with background pattern
            ScaleTransition(
              scale: _scaleAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background pattern
                  _buildBackgroundPattern(data, iconSize * 2.5),
                  // Icon container
                  Container(
                    width: iconSize * 2,
                    height: iconSize * 2,
                    decoration: BoxDecoration(
                      color: data.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: data.color.withOpacity(0.2),
                          blurRadius: iconSize * 0.5,
                          spreadRadius: iconSize * 0.1,
                        ),
                      ],
                    ),
                    child: Icon(data.icon, size: iconSize, color: data.color),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing * 2),
            // Title with responsive text
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  data.title,
                  style: _getTitleStyle(category, textScaleFactor),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: spacing * 0.75),
            // Description with responsive text
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                data.description,
                style: _getDescriptionStyle(category, textScaleFactor),
                textAlign: TextAlign.center,
                maxLines: isVertical ? 4 : 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build background pattern for visual interest
  Widget _buildBackgroundPattern(OnboardingData data, double size) {
    return CustomPaint(
      size: Size(size, size),
      painter: PatternPainter(
        color: data.color.withOpacity(0.05),
        pattern: data.backgroundPattern,
      ),
    );
  }

  // Build skip button with responsive sizing
  Widget _buildSkipButton(BuildContext context, ScreenCategory category) {
    final fontSize = _getButtonFontSize(category);
    final padding = _getButtonPadding(category);

    return TextButton(
      onPressed: _completeOnboarding,
      style: TextButton.styleFrom(
        padding: padding,
        minimumSize: Size(
          category == ScreenCategory.mobile ? 48 : 64,
          category == ScreenCategory.mobile ? 48 : 56,
        ),
      ),
      child: Text(
        'Skip',
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Build page indicators with smooth transitions
  Widget _buildPageIndicators(ScreenCategory category) {
    final indicatorSize = category == ScreenCategory.mobile ? 8.0 : 10.0;
    final activeWidth = category == ScreenCategory.mobile ? 24.0 : 32.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(
            horizontal: category == ScreenCategory.mobile ? 4 : 6,
          ),
          height: indicatorSize,
          width: _currentPage == index ? activeWidth : indicatorSize,
          decoration: BoxDecoration(
            color:
                _currentPage == index
                    ? _pages[_currentPage].color
                    : AppColors.textTertiary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(indicatorSize / 2),
            boxShadow:
                _currentPage == index
                    ? [
                      BoxShadow(
                        color: _pages[_currentPage].color.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                    : null,
          ),
        ),
      ),
    );
  }

  // Build navigation buttons with responsive sizing
  Widget _buildNavigationButtons(
    BuildContext context,
    ScreenCategory category,
    double buttonHeight,
    double textScaleFactor,
  ) {
    final fontSize = _getButtonFontSize(category);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous button (only shown after first page)
        AnimatedOpacity(
          opacity: _currentPage > 0 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: SizedBox(
            height: buttonHeight,
            child: OutlinedButton(
              onPressed:
                  _currentPage > 0
                      ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                      : null,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: buttonHeight * 0.5),
                side: BorderSide(color: _pages[_currentPage].color, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(buttonHeight / 2),
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                size: fontSize * 1.2,
                color: _pages[_currentPage].color,
              ),
            ),
          ),
        ),
        // Next/Get Started button
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: _currentPage > 0 ? 16 : 0),
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                if (_currentPage == _pages.length - 1) {
                  _completeOnboarding();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _pages[_currentPage].color,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: _pages[_currentPage].color.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(buttonHeight / 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (_currentPage < _pages.length - 1) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: fontSize * 1.2),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Responsive helper methods
  double _getTextScaleFactor(ScreenCategory category) {
    switch (category) {
      case ScreenCategory.mobile:
        return 0.9;
      case ScreenCategory.tablet:
        return 1.0;
      case ScreenCategory.desktop:
        return 1.1;
    }
  }

  double _getIconSize(ScreenCategory category) {
    switch (category) {
      case ScreenCategory.mobile:
        return 48;
      case ScreenCategory.tablet:
        return 64;
      case ScreenCategory.desktop:
        return 72;
    }
  }

  double _getButtonHeight(ScreenCategory category) {
    switch (category) {
      case ScreenCategory.mobile:
        return 48; // Thumb-friendly minimum
      case ScreenCategory.tablet:
        return 56;
      case ScreenCategory.desktop:
        return 64;
    }
  }

  double _getButtonFontSize(ScreenCategory category) {
    switch (category) {
      case ScreenCategory.mobile:
        return 16;
      case ScreenCategory.tablet:
        return 18;
      case ScreenCategory.desktop:
        return 20;
    }
  }

  EdgeInsets _getButtonPadding(ScreenCategory category) {
    switch (category) {
      case ScreenCategory.mobile:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ScreenCategory.tablet:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
      case ScreenCategory.desktop:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
  }

  EdgeInsets _getResponsivePadding(ScreenCategory category) {
    switch (category) {
      case ScreenCategory.mobile:
        return const EdgeInsets.all(20);
      case ScreenCategory.tablet:
        return const EdgeInsets.all(32);
      case ScreenCategory.desktop:
        return const EdgeInsets.all(48);
    }
  }

  double _getResponsiveSpacing(ScreenCategory category) {
    switch (category) {
      case ScreenCategory.mobile:
        return 16;
      case ScreenCategory.tablet:
        return 24;
      case ScreenCategory.desktop:
        return 32;
    }
  }

  double _getMaxContentWidth(ScreenCategory category) {
    switch (category) {
      case ScreenCategory.mobile:
        return 400;
      case ScreenCategory.tablet:
        return 500;
      case ScreenCategory.desktop:
        return 600;
    }
  }

  TextStyle _getTitleStyle(ScreenCategory category, double scaleFactor) {
    final baseSize = category == ScreenCategory.mobile ? 24.0 : 32.0;
    return TextStyle(
      fontSize: baseSize * scaleFactor,
      fontWeight: FontWeight.bold,
      height: 1.2,
      letterSpacing: -0.5,
    );
  }

  TextStyle _getDescriptionStyle(ScreenCategory category, double scaleFactor) {
    final baseSize = category == ScreenCategory.mobile ? 16.0 : 18.0;
    return TextStyle(
      fontSize: baseSize * scaleFactor,
      color: AppColors.textSecondary,
      height: 1.5,
      letterSpacing: 0.2,
    );
  }
}

// Enhanced onboarding data model
class OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final OnboardingPattern backgroundPattern;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.backgroundPattern,
  });
}

// Pattern types for background decoration
enum OnboardingPattern { circles, waves, stars }

// Custom painter for background patterns
class PatternPainter extends CustomPainter {
  final Color color;
  final OnboardingPattern pattern;

  PatternPainter({required this.color, required this.pattern});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    switch (pattern) {
      case OnboardingPattern.circles:
        _drawCircles(canvas, size, paint);
        break;
      case OnboardingPattern.waves:
        _drawWaves(canvas, size, paint);
        break;
      case OnboardingPattern.stars:
        _drawStars(canvas, size, paint);
        break;
    }
  }

  void _drawCircles(Canvas canvas, Size size, Paint paint) {
    final random = math.Random(42); // Fixed seed for consistent pattern
    for (int i = 0; i < 8; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 20 + 10;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawWaves(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final waveHeight = size.height * 0.1;
    final waveLength = size.width / 3;

    path.moveTo(0, size.height / 2);
    for (double x = 0; x <= size.width; x += 1) {
      final y =
          size.height / 2 +
          math.sin((x / waveLength) * 2 * math.pi) * waveHeight;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawStars(Canvas canvas, Size size, Paint paint) {
    final random = math.Random(42);
    for (int i = 0; i < 12; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = random.nextDouble() * 15 + 5;
      _drawStar(canvas, Offset(x, y), starSize, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final angle = math.pi / 5;

    for (int i = 0; i < 10; i++) {
      final radius = i.isEven ? size : size / 2;
      final x = center.dx + radius * math.cos(i * angle - math.pi / 2);
      final y = center.dy + radius * math.sin(i * angle - math.pi / 2);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
