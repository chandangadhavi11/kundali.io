import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';

// Responsive breakpoints
class ModernBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1800;
}

// Screen size categories
enum ScreenSize { mobile, tablet, desktop, largeDesktop }

// Navigation display modes
enum NavigationMode {
  floating, // Floating bottom bar
  docked, // Docked bottom bar
  sidebar, // Side navigation bar
  topTabs, // Top tab bar
}

// Navigation styles
enum NavigationStyle {
  modern, // Modern Material 3 style
  glassmorphism, // Glass morphism effect
  neomorphism, // Soft UI style
  gradient, // Gradient style
}

class ModernNavigationScreen extends StatefulWidget {
  final Widget child;
  final NavigationStyle style;

  const ModernNavigationScreen({
    super.key,
    required this.child,
    this.style = NavigationStyle.modern,
  });

  @override
  State<ModernNavigationScreen> createState() => _ModernNavigationScreenState();
}

class _ModernNavigationScreenState extends State<ModernNavigationScreen>
    with TickerProviderStateMixin {
  // Navigation state
  int _selectedIndex = 0;
  NavigationMode _navigationMode = NavigationMode.floating;
  NavigationStyle _currentStyle = NavigationStyle.modern;

  // Animation controllers
  late AnimationController _pageTransitionController;
  late AnimationController _navigationAnimationController;
  late AnimationController _backdropController;
  late AnimationController _gestureController;
  late TabController _tabController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _navigationAnimation;
  late Animation<double> _backdropAnimation;

  // Gesture detection
  double _dragOffset = 0;
  bool _isDragging = false;

  // Device capabilities
  bool _supportsHaptics = true;

  // Navigation items
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      route: '/home',
      color: const Color(0xFF6C5CE7),
    ),
    NavigationItem(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome_rounded,
      label: 'Horoscope',
      route: '/horoscope',
      color: const Color(0xFFFF6B6B),
    ),
    NavigationItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Panchang',
      route: '/panchang',
      color: const Color(0xFF4ECDC4),
    ),
    NavigationItem(
      icon: Icons.forum_outlined,
      activeIcon: Icons.forum_rounded,
      label: 'Chat',
      route: '/chat',
      color: const Color(0xFFFFD93D),
      badge: '3',
    ),
    NavigationItem(
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle_rounded,
      label: 'Profile',
      route: '/profile',
      color: const Color(0xFFA8E6CF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentStyle = widget.style;
    _initAnimations();
    _updateIndexFromRoute();
    _checkDeviceCapabilities();
  }

  void _initAnimations() {
    // Page transition animations
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageTransitionController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.02),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _pageTransitionController,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageTransitionController,
        curve: Curves.easeOutBack,
      ),
    );

    // Navigation animations
    _navigationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _navigationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _navigationAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Backdrop animations
    _backdropController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _backdropAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backdropController, curve: Curves.easeInOut),
    );

    // Gesture animations
    _gestureController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Tab controller
    _tabController = TabController(
      length: _navigationItems.length,
      vsync: this,
    );

    // Start animations
    _pageTransitionController.forward();
    _navigationAnimationController.forward();
    _backdropController.forward();
  }

  void _checkDeviceCapabilities() {
    // Check if device supports haptics
    _supportsHaptics = true; // Generally available on most devices
  }

  void _updateIndexFromRoute() {
    final String location =
        GoRouter.of(context).routeInformationProvider.value.uri.path;

    for (int i = 0; i < _navigationItems.length; i++) {
      if (location.startsWith(_navigationItems[i].route)) {
        if (_selectedIndex != i) {
          setState(() {
            _selectedIndex = i;
          });
          _tabController.animateTo(i);
        }
        break;
      }
    }
  }

  void _updateNavigationMode(double width, Orientation orientation) {
    NavigationMode newMode;

    if (width < ModernBreakpoints.mobile) {
      newMode = NavigationMode.floating;
    } else if (width < ModernBreakpoints.tablet) {
      newMode =
          orientation == Orientation.portrait
              ? NavigationMode.docked
              : NavigationMode.topTabs;
    } else if (width < ModernBreakpoints.desktop) {
      newMode = NavigationMode.topTabs;
    } else {
      newMode = NavigationMode.sidebar;
    }

    if (newMode != _navigationMode) {
      setState(() {
        _navigationMode = newMode;
      });
      _navigationAnimationController.forward(from: 0);
    }
  }

  ScreenSize _getScreenSize(double width) {
    if (width < ModernBreakpoints.mobile) return ScreenSize.mobile;
    if (width < ModernBreakpoints.tablet) return ScreenSize.tablet;
    if (width < ModernBreakpoints.desktop) return ScreenSize.desktop;
    return ScreenSize.largeDesktop;
  }

  @override
  void didUpdateWidget(ModernNavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateIndexFromRoute();
    _pageTransitionController.forward(from: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    _updateNavigationMode(size.width, orientation);
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      if (_supportsHaptics) {
        HapticFeedback.lightImpact();
      }

      setState(() {
        _selectedIndex = index;
      });

      _tabController.animateTo(index);
      _pageTransitionController.forward(from: 0);
      context.go(_navigationItems[index].route);
    }
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    _navigationAnimationController.dispose();
    _backdropController.dispose();
    _gestureController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final orientation = MediaQuery.of(context).orientation;
        final screenSize = _getScreenSize(size.width);
        _updateNavigationMode(size.width, orientation);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: _buildResponsiveLayout(context, screenSize),
        );
      },
    );
  }

  Widget _buildResponsiveLayout(BuildContext context, ScreenSize screenSize) {
    switch (_navigationMode) {
      case NavigationMode.sidebar:
        return _buildSidebarLayout(context, screenSize);
      case NavigationMode.topTabs:
        return _buildTopTabsLayout(context, screenSize);
      case NavigationMode.docked:
        return _buildDockedLayout(context, screenSize);
      case NavigationMode.floating:
        return _buildFloatingLayout(context, screenSize);
    }
  }

  // Floating navigation layout (mobile)
  Widget _buildFloatingLayout(BuildContext context, ScreenSize screenSize) {
    return Stack(
      children: [
        // Main content with backdrop effect
        _buildBackdropContent(context, screenSize),

        // Floating navigation bar
        Positioned(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          child: AnimatedBuilder(
            animation: _navigationAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 100 * (1 - _navigationAnimation.value)),
                child: Opacity(
                  opacity: _navigationAnimation.value,
                  child: _buildFloatingNavBar(context, screenSize),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Docked navigation layout (tablet portrait)
  Widget _buildDockedLayout(BuildContext context, ScreenSize screenSize) {
    return Column(
      children: [
        // Main content
        Expanded(child: _buildBackdropContent(context, screenSize)),

        // Docked navigation bar
        _buildDockedNavBar(context, screenSize),
      ],
    );
  }

  // Top tabs layout (tablet landscape)
  Widget _buildTopTabsLayout(BuildContext context, ScreenSize screenSize) {
    return Column(
      children: [
        // Top app bar with tabs
        _buildTopAppBar(context, screenSize),

        // Main content
        Expanded(child: _buildBackdropContent(context, screenSize)),
      ],
    );
  }

  // Sidebar layout (desktop)
  Widget _buildSidebarLayout(BuildContext context, ScreenSize screenSize) {
    return Row(
      children: [
        // Sidebar navigation
        _buildSidebar(context, screenSize),

        // Main content
        Expanded(child: _buildBackdropContent(context, screenSize)),
      ],
    );
  }

  // Build backdrop content with Material 3 effects
  Widget _buildBackdropContent(BuildContext context, ScreenSize screenSize) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _backdropAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDarkMode ? Colors.grey[950] : Colors.grey[50])!,
                (isDarkMode ? Colors.grey[900] : Colors.white)!.withOpacity(
                  0.95,
                ),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated background pattern
              if (_currentStyle == NavigationStyle.modern)
                _buildAnimatedBackground(context, screenSize),

              // Main content with animations
              AnimatedBuilder(
                animation: _pageTransitionController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: widget.child,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Build animated background pattern
  Widget _buildAnimatedBackground(BuildContext context, ScreenSize screenSize) {
    return AnimatedBuilder(
      animation: _backdropController,
      builder: (context, child) {
        return CustomPaint(
          painter: BackgroundPatternPainter(
            color: _navigationItems[_selectedIndex].color.withOpacity(0.05),
            animation: _backdropAnimation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  // Build floating navigation bar with Material 3 design
  Widget _buildFloatingNavBar(BuildContext context, ScreenSize screenSize) {
    Widget navBar;

    switch (_currentStyle) {
      case NavigationStyle.glassmorphism:
        navBar = _buildGlassmorphicNavBar(context, screenSize);
        break;
      case NavigationStyle.neomorphism:
        navBar = _buildNeomorphicNavBar(context, screenSize);
        break;
      case NavigationStyle.gradient:
        navBar = _buildGradientNavBar(context, screenSize);
        break;
      case NavigationStyle.modern:
        navBar = _buildModernNavBar(context, screenSize);
        break;
    }

    // Add gesture detection for swipe navigation
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragOffset += details.delta.dx;
          _isDragging = true;
        });
        _gestureController.forward();
      },
      onHorizontalDragEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond.dx;
        final screenWidth = MediaQuery.of(context).size.width;

        if (velocity.abs() > 300 || _dragOffset.abs() > screenWidth * 0.3) {
          final direction = velocity > 0 || _dragOffset > 0 ? -1 : 1;
          final newIndex = (_selectedIndex + direction).clamp(
            0,
            _navigationItems.length - 1,
          );

          if (newIndex != _selectedIndex) {
            _onItemTapped(newIndex);
          }
        }

        setState(() {
          _dragOffset = 0;
          _isDragging = false;
        });
        _gestureController.reverse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(
          _isDragging ? _dragOffset * 0.1 : 0,
          0,
          0,
        ),
        child: navBar,
      ),
    );
  }

  // Modern Material 3 navigation bar
  Widget _buildModernNavBar(BuildContext context, ScreenSize screenSize) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            _navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = _selectedIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(index),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: Matrix4.translationValues(
                            0,
                            isSelected ? -2 : 0,
                            0,
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                isSelected ? item.activeIcon : item.icon,
                                color: isSelected ? item.color : Colors.grey,
                                size: isSelected ? 28 : 24,
                              ),
                              if (item.badge != null)
                                Positioned(
                                  right: -8,
                                  top: -8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      item.badge!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: isSelected ? 12 : 10,
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                            color: isSelected ? item.color : Colors.grey,
                          ),
                          child: Text(item.label),
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

  // Glassmorphic navigation bar
  Widget _buildGlassmorphicNavBar(BuildContext context, ScreenSize screenSize) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: _buildModernNavBar(context, screenSize),
        ),
      ),
    );
  }

  // Neomorphic navigation bar
  Widget _buildNeomorphicNavBar(BuildContext context, ScreenSize screenSize) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black54 : Colors.grey[400]!,
            offset: const Offset(4, 4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: isDarkMode ? Colors.grey[800]! : Colors.white,
            offset: const Offset(-4, -4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: _buildModernNavBar(context, screenSize),
    );
  }

  // Gradient navigation bar
  Widget _buildGradientNavBar(BuildContext context, ScreenSize screenSize) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _navigationItems[_selectedIndex].color.withOpacity(0.8),
            _navigationItems[_selectedIndex].color.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: _buildModernNavBar(context, screenSize),
    );
  }

  // Build docked navigation bar
  Widget _buildDockedNavBar(BuildContext context, ScreenSize screenSize) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: _buildModernNavBar(context, screenSize),
      ),
    );
  }

  // Build top app bar with tabs
  Widget _buildTopAppBar(BuildContext context, ScreenSize screenSize) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isCompact = screenSize == ScreenSize.tablet;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App header
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.stars_rounded, color: AppColors.primary, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'Kundali',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Tab bar
            TabBar(
              controller: _tabController,
              isScrollable: isCompact,
              onTap: _onItemTapped,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs:
                  _navigationItems.map((item) {
                    return Tab(
                      icon: Icon(
                        _selectedIndex == _navigationItems.indexOf(item)
                            ? item.activeIcon
                            : item.icon,
                      ),
                      text: item.label,
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Build sidebar navigation
  Widget _buildSidebar(BuildContext context, ScreenSize screenSize) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 280,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sidebar header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.stars_rounded, color: AppColors.primary, size: 40),
                const SizedBox(width: 16),
                Text(
                  'Kundali',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children:
                  _navigationItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = _selectedIndex == index;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? item.color.withOpacity(0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected ? item.color : Colors.grey,
                          size: 24,
                        ),
                        title: Text(
                          item.label,
                          style: TextStyle(
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                            color: isSelected ? item.color : null,
                          ),
                        ),
                        trailing:
                            item.badge != null
                                ? Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    item.badge!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                                : null,
                        onTap: () => _onItemTapped(index),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Navigation item model
class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final Color color;
  final String? badge;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.color,
    this.badge,
  });
}

// Background pattern painter
class BackgroundPatternPainter extends CustomPainter {
  final Color color;
  final double animation;

  BackgroundPatternPainter({required this.color, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final maxRadius = math.sqrt(centerX * centerX + centerY * centerY);

    for (int i = 0; i < 5; i++) {
      final radius = maxRadius * (0.2 + i * 0.2) * animation;
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        paint..color = color.withOpacity(0.02 * (5 - i)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPatternPainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.color != color;
  }
}
