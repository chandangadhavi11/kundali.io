import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class CosmicNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CosmicNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CosmicNavigationBar> createState() => _CosmicNavigationBarState();
}

class _CosmicNavigationBarState extends State<CosmicNavigationBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;

  final List<_NavItem> _items = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
      label: 'Horoscope',
    ),
    _NavItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      label: 'Panchang',
    ),
    _NavItem(
      icon: Icons.psychology_outlined,
      activeIcon: Icons.psychology,
      label: 'Chat',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTap(int index) {
    HapticFeedback.lightImpact();
    
    // Animate tap
    _controllers[index].forward().then((_) {
      _controllers[index].reverse();
    });

    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        // Gradient background matching cosmic theme
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1425).withOpacity(0.98),
            const Color(0xFF0F0B18),
          ],
        ),
        // Top border with subtle golden glow
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE8B931).withOpacity(0.15),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
          BoxShadow(
            color: const Color(0xFF6B3FA0).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: SafeArea(
            top: false,
            child: Container(
              height: 70,
              padding: EdgeInsets.only(
                left: 6,
                right: 6,
                top: 6,
                bottom: bottomPadding > 0 ? 0 : 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_items.length, (index) {
                  final isSelected = widget.currentIndex == index;
                  return _buildNavItem(index, isSelected);
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, bool isSelected) {
    final item = _items[index];

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _scaleAnimations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimations[index].value,
              child: child,
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated indicator dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: isSelected ? 4 : 0,
                height: 4,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8B931),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFFE8B931).withOpacity(0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              // Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(6),
                decoration: isSelected
                    ? BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFE8B931).withOpacity(0.12),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      )
                    : null,
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: isSelected ? 26 : 23,
                  color: isSelected
                      ? const Color(0xFFE8B931)
                      : Colors.white.withOpacity(0.45),
                ),
              ),
              const SizedBox(height: 2),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFFE8B931)
                      : Colors.white.withOpacity(0.4),
                  letterSpacing: 0.3,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

