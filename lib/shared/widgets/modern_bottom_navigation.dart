import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModernBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<ModernBottomNavigation> createState() => _ModernBottomNavigationState();
}

class _ModernBottomNavigationState extends State<ModernBottomNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _iconControllers;
  late List<Animation<double>> _iconAnimations;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;

  int _previousIndex = 0;

  final List<NavigationItem> _items = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      color: const Color(0xFFFF6B6B),
    ),
    NavigationItem(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome_rounded,
      label: 'Horoscope',
      color: const Color(0xFF6C5CE7),
    ),
    NavigationItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today_rounded,
      label: 'Panchang',
      color: const Color(0xFFFDAB3D),
    ),
    NavigationItem(
      icon: Icons.psychology_outlined,
      activeIcon: Icons.psychology_rounded,
      label: 'Chat',
      color: const Color(0xFF00B894),
    ),
    NavigationItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      color: const Color(0xFF4ECDC4),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _iconControllers = List.generate(
      _items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );

    _iconAnimations =
        _iconControllers.map((controller) {
          return Tween<double>(begin: 1.0, end: 0.8).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );
        }).toList();

    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _indicatorAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _indicatorController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Animate the initially selected item
    if (widget.currentIndex < _iconControllers.length) {
      _iconControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(ModernBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animateToIndex(widget.currentIndex);
    }
  }

  void _animateToIndex(int index) {
    if (_previousIndex != index && _previousIndex < _iconControllers.length) {
      _iconControllers[_previousIndex].reverse();
    }
    if (index < _iconControllers.length) {
      _iconControllers[index].forward();
    }
    _previousIndex = index;
    _indicatorController.forward(from: 0);
  }

  @override
  void dispose() {
    for (var controller in _iconControllers) {
      controller.dispose();
    }
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 80 + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color:
                isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SizedBox(
        height: 80,
        child: Stack(
          children: [
            // Animated background indicator
            AnimatedBuilder(
              animation: _indicatorAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 80),
                  painter: IndicatorPainter(
                    currentIndex: widget.currentIndex,
                    previousIndex: _previousIndex,
                    animation: _indicatorAnimation.value,
                    itemCount: _items.length,
                    color: _items[widget.currentIndex].color.withOpacity(0.1),
                  ),
                );
              },
            ),

            // Navigation items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:
                  _items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = widget.currentIndex == index;

                    return Expanded(
                      child: _buildNavItem(
                        item: item,
                        index: index,
                        isSelected: isSelected,
                        animation: _iconAnimations[index],
                        isDarkMode: isDarkMode,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required NavigationItem item,
    required int index,
    required bool isSelected,
    required Animation<double> animation,
    required bool isDarkMode,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap(index);
      },
      splashColor: item.color.withOpacity(0.1),
      highlightColor: item.color.withOpacity(0.05),
      child: SizedBox(
        height: 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated dot indicator
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: isSelected ? 8 : 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 6 : 0,
                height: isSelected ? 6 : 0,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: item.color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                          : [],
                ),
              ),
            ),

            // Icon and label
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                // Animated icon container
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isSelected ? animation.value : 1.0,
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
                        builder: (context, value, child) {
                          return Container(
                            padding: EdgeInsets.all(isSelected ? 8 : 4),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? item.color.withOpacity(0.1 * value)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color:
                                  isSelected
                                      ? item.color
                                      : isDarkMode
                                      ? Colors.grey[600]
                                      : Colors.grey[500],
                              size: isSelected ? 26 : 24,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                // Animated label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: isSelected ? 11 : 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        isSelected
                            ? item.color
                            : isDarkMode
                            ? Colors.grey[600]
                            : Colors.grey[500],
                    letterSpacing: isSelected ? 0.2 : 0,
                  ),
                  child: Text(item.label),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Navigation item model
class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}

// Custom painter for the background indicator
class IndicatorPainter extends CustomPainter {
  final int currentIndex;
  final int previousIndex;
  final double animation;
  final int itemCount;
  final Color color;

  IndicatorPainter({
    required this.currentIndex,
    required this.previousIndex,
    required this.animation,
    required this.itemCount,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final itemWidth = size.width / itemCount;
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    // Calculate position with animation
    final startX =
        previousIndex * itemWidth +
        (currentIndex - previousIndex) * itemWidth * animation;
    final centerX = startX + itemWidth / 2;

    // Draw smooth curved indicator
    final path = Path();
    path.moveTo(centerX - itemWidth / 3, size.height);
    path.quadraticBezierTo(
      centerX - itemWidth / 4,
      size.height * 0.7,
      centerX - itemWidth / 6,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      centerX,
      size.height * 0.5,
      centerX + itemWidth / 6,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      centerX + itemWidth / 4,
      size.height * 0.7,
      centerX + itemWidth / 3,
      size.height,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant IndicatorPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.currentIndex != currentIndex ||
        oldDelegate.previousIndex != previousIndex;
  }
}
