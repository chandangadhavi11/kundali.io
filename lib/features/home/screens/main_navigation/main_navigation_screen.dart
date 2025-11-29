import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/modern_bottom_navigation.dart';
import '../../../../shared/widgets/floating_navigation_bar.dart';
import '../../../../shared/widgets/curved_navigation_bar.dart';

// Responsive breakpoints
class NavigationBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

// Navigation display modes
enum NavigationMode {
  bottomBar, // Mobile
  rail, // Tablet portrait
  extendedRail, // Tablet landscape
  drawer, // Desktop
}

// Screen size categories
enum ScreenSize { mobile, tablet, desktop }

class MainNavigationScreen extends StatefulWidget {
  final Widget child;

  const MainNavigationScreen({super.key, required this.child});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  // Navigation state
  int _selectedIndex = 0;
  NavigationMode _navigationMode = NavigationMode.bottomBar;
  NavigationMode _previousMode = NavigationMode.bottomBar;

  // Drawer/Rail state
  bool _isRailExtended = false;
  bool _isDrawerOpen = false;

  // Animation controllers
  late AnimationController _pageController;
  late AnimationController _railController;
  late AnimationController _modeTransitionController;
  late AnimationController _contentShiftController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _railAnimation;
  late Animation<double> _contentShiftAnimation;

  // Navigation items
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      route: '/home',
    ),
    NavigationItem(
      icon: Icons.stars_outlined,
      selectedIcon: Icons.stars,
      label: 'Horoscope',
      route: '/horoscope',
    ),
    NavigationItem(
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today,
      label: 'Panchang',
      route: '/panchang',
    ),
    NavigationItem(
      icon: Icons.chat_bubble_outline,
      selectedIcon: Icons.chat_bubble,
      label: 'Chat',
      route: '/chat',
      badge: '3',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
      route: '/profile',
    ),
  ];

  // Toggle between bottom nav styles (for mobile only)
  int _bottomNavStyle = 0; // 0: Modern, 1: Floating, 2: Curved

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _updateNavigationMode();
  }

  void _initAnimations() {
    // Page transition animation
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeInOut),
    );

    // Rail animation
    _railController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _railAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _railController, curve: Curves.easeOutCubic),
    );

    // Mode transition animation
    _modeTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Content shift animation
    _contentShiftController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _contentShiftAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentShiftController,
        curve: Curves.easeOutCubic,
      ),
    );

    _pageController.forward();
    _modeTransitionController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _railController.dispose();
    _modeTransitionController.dispose();
    _contentShiftController.dispose();
    super.dispose();
  }

  void _updateNavigationMode() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final orientation = MediaQuery.of(context).orientation;
      final newMode = _getNavigationMode(size.width, orientation);

      if (newMode != _navigationMode && mounted) {
        setState(() {
          _previousMode = _navigationMode;
          _navigationMode = newMode;
        });
        _animateModeTransition();
      }
    });
  }

  void _animateModeTransition() {
    _modeTransitionController.forward(from: 0);
    _contentShiftController.forward(from: 0);

    // Handle rail animations
    if (_navigationMode == NavigationMode.rail ||
        _navigationMode == NavigationMode.extendedRail) {
      _railController.forward();
    } else {
      _railController.reverse();
    }
  }

  NavigationMode _getNavigationMode(double width, Orientation orientation) {
    if (width < NavigationBreakpoints.mobile) {
      return NavigationMode.bottomBar;
    } else if (width < NavigationBreakpoints.tablet) {
      return orientation == Orientation.portrait
          ? NavigationMode.rail
          : NavigationMode.extendedRail;
    } else if (width < NavigationBreakpoints.desktop) {
      return NavigationMode.extendedRail;
    } else {
      return NavigationMode.drawer;
    }
  }

  ScreenSize _getScreenSize(double width) {
    if (width < NavigationBreakpoints.mobile) return ScreenSize.mobile;
    if (width < NavigationBreakpoints.tablet) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedIndex = index;
      });

      // Animate page transition
      _pageController.forward(from: 0);

      // Navigate to route
      context.go(_navigationItems[index].route);
    }
  }

  void _toggleRailExtension() {
    HapticFeedback.lightImpact();
    setState(() {
      _isRailExtended = !_isRailExtended;
    });

    if (_isRailExtended) {
      _railController.forward();
    } else {
      _railController.reverse();
    }
  }

  void _toggleDrawer() {
    HapticFeedback.lightImpact();
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  @override
  void didUpdateWidget(MainNavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected index based on current route
    final String location =
        GoRouter.of(context).routeInformationProvider.value.uri.path;

    for (int i = 0; i < _navigationItems.length; i++) {
      if (location.startsWith(_navigationItems[i].route)) {
        if (_selectedIndex != i) {
          setState(() {
            _selectedIndex = i;
          });
        }
        break;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateNavigationMode();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final orientation = MediaQuery.of(context).orientation;
        final screenSize = _getScreenSize(size.width);
        _navigationMode = _getNavigationMode(size.width, orientation);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: _buildBody(context, screenSize),
          bottomNavigationBar:
              _navigationMode == NavigationMode.bottomBar
                  ? _buildBottomNavigation()
                  : null,
          drawer:
              _navigationMode == NavigationMode.drawer && _isDrawerOpen
                  ? _buildDrawer(context)
                  : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ScreenSize screenSize) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Row(
          children: [
            // Navigation Rail or Drawer Toggle
            if (_navigationMode != NavigationMode.bottomBar)
              _buildSideNavigation(context),

            // Main content area
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                child: Stack(
                  children: [
                    // Main content with animations
                    AnimatedBuilder(
                      animation: _contentShiftAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            _contentShiftAnimation.value *
                                10 *
                                (_previousMode == NavigationMode.bottomBar
                                    ? 1
                                    : 0),
                            0,
                          ),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: widget.child,
                          ),
                        );
                      },
                    ),

                    // Mobile nav style toggle (only for demo)
                    if (_navigationMode == NavigationMode.bottomBar)
                      _buildNavStyleToggle(context, isDarkMode),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSideNavigation(BuildContext context) {
    switch (_navigationMode) {
      case NavigationMode.rail:
        return _buildNavigationRail(context, extended: false);
      case NavigationMode.extendedRail:
        return _buildNavigationRail(context, extended: true);
      case NavigationMode.drawer:
        return _buildDrawerToggle(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNavigationRail(BuildContext context, {required bool extended}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final railWidth = extended || _isRailExtended ? 256.0 : 72.0;

    return AnimatedBuilder(
      animation: _railAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-72 * (1 - _railAnimation.value), 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: railWidth,
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
            child: NavigationRail(
              extended: extended || _isRailExtended,
              backgroundColor: Colors.transparent,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              leading: _buildRailHeader(context, extended),
              trailing: _buildRailFooter(context, extended),
              minWidth: 72,
              minExtendedWidth: 256,
              selectedIconTheme: IconThemeData(
                color: AppColors.primary,
                size: 28,
              ),
              unselectedIconTheme: IconThemeData(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                size: 24,
              ),
              selectedLabelTextStyle: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
              labelType:
                  extended || _isRailExtended
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.selected,
              destinations:
                  _navigationItems.map((item) {
                    return NavigationRailDestination(
                      icon: _buildNavIcon(item, false),
                      selectedIcon: _buildNavIcon(item, true),
                      label: Text(item.label),
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRailHeader(BuildContext context, bool extended) {
    if (_navigationMode == NavigationMode.rail && !_isRailExtended) {
      return Column(
        children: [
          const SizedBox(height: 8),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _toggleRailExtension,
            tooltip: 'Expand menu',
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (extended || _isRailExtended) ...[
            Icon(Icons.stars_rounded, color: AppColors.primary, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Kundali',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
          if (_navigationMode == NavigationMode.rail)
            IconButton(
              icon: Icon(_isRailExtended ? Icons.menu_open : Icons.menu),
              onPressed: _toggleRailExtension,
              tooltip: _isRailExtended ? 'Collapse menu' : 'Expand menu',
            ),
        ],
      ),
    );
  }

  Widget _buildRailFooter(BuildContext context, bool extended) {
    return const Column(children: [Divider(), SizedBox(height: 8)]);
  }

  Widget _buildDrawerToggle(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          IconButton(
            icon: const Icon(Icons.menu, size: 28),
            onPressed: _toggleDrawer,
            tooltip: 'Open menu',
          ),
          const Spacer(),
          // Quick access icons
          ..._navigationItems.take(3).map((item) {
            final isSelected = _selectedIndex == _navigationItems.indexOf(item);
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: IconButton(
                icon: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  color: isSelected ? AppColors.primary : null,
                ),
                onPressed: () => _onItemTapped(_navigationItems.indexOf(item)),
                tooltip: item.label,
              ),
            );
          }),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: 280,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      child: Column(
        children: [
          // Drawer header
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.stars_rounded, color: Colors.white, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Kundali App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your Astrology Companion',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children:
                  _navigationItems.map((item) {
                    final index = _navigationItems.indexOf(item);
                    final isSelected = _selectedIndex == index;

                    return ListTile(
                      leading: Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected ? AppColors.primary : null,
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppColors.primary : null,
                        ),
                      ),
                      trailing:
                          item.badge != null
                              ? Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
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
                      selected: isSelected,
                      selectedTileColor: AppColors.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        _onItemTapped(index);
                        Navigator.pop(context); // Close drawer
                      },
                    );
                  }).toList(),
            ),
          ),
          // Footer
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.push('/settings');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    switch (_bottomNavStyle) {
      case 1:
        return FloatingNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        );
      case 2:
        return CurvedNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        );
      default:
        return ModernBottomNavigation(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        );
    }
  }

  Widget _buildNavStyleToggle(BuildContext context, bool isDarkMode) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 10,
      child: AnimatedOpacity(
        opacity: 0.8,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? Colors.grey[800]?.withOpacity(0.8)
                    : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getNavStyleIcon(),
                size: 16,
                color: isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _bottomNavStyle = (_bottomNavStyle + 1) % 3;
                  });
                },
                child: Text(
                  _getNavStyleName(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(NavigationItem item, bool isSelected) {
    final icon = Icon(isSelected ? item.selectedIcon : item.icon, size: 24);

    if (item.badge != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                item.badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    return icon;
  }

  IconData _getNavStyleIcon() {
    switch (_bottomNavStyle) {
      case 1:
        return Icons.bubble_chart_rounded;
      case 2:
        return Icons.waves_rounded;
      default:
        return Icons.dock_rounded;
    }
  }

  String _getNavStyleName() {
    switch (_bottomNavStyle) {
      case 1:
        return 'Floating';
      case 2:
        return 'Curved';
      default:
        return 'Modern';
    }
  }
}

// Navigation item model
class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
  final String? badge;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
    this.badge,
  });
}
