import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class FloatingNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<FloatingNavigationBar> createState() => _FloatingNavigationBarState();
}

class _FloatingNavigationBarState extends State<FloatingNavigationBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _bubbleControllers;
  late List<Animation<double>> _bubbleAnimations;
  late AnimationController _selectionController;
  late Animation<double> _selectionAnimation;

  final List<FloatingNavItem> _items = [
    FloatingNavItem(
      icon: Icons.home_rounded,
      label: 'Home',
      gradient: const LinearGradient(
        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    FloatingNavItem(
      icon: Icons.stars_rounded,
      label: 'Horoscope',
      gradient: const LinearGradient(
        colors: [Color(0xFF6C5CE7), Color(0xFF8B7EFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    FloatingNavItem(
      icon: Icons.wb_sunny_rounded,
      label: 'Panchang',
      gradient: const LinearGradient(
        colors: [Color(0xFFFDAB3D), Color(0xFFFFBF5F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    FloatingNavItem(
      icon: Icons.auto_awesome_rounded,
      label: 'AI Chat',
      gradient: const LinearGradient(
        colors: [Color(0xFF00B894), Color(0xFF00D4AA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    FloatingNavItem(
      icon: Icons.person_rounded,
      label: 'Profile',
      gradient: const LinearGradient(
        colors: [Color(0xFF4ECDC4), Color(0xFF6DDDD4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _bubbleControllers = List.generate(
      _items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      )..repeat(reverse: true),
    );

    _bubbleAnimations =
        _bubbleControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: controller,
              curve: Interval(
                index * 0.1,
                0.5 + index * 0.1,
                curve: Curves.easeInOut,
              ),
            ),
          );
        }).toList();

    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();

    _selectionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _selectionController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(FloatingNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _selectionController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    // Stop all animations before disposing
    for (var controller in _bubbleControllers) {
      controller.stop();
    }
    _selectionController.stop();

    for (var controller in _bubbleControllers) {
      controller.dispose();
    }
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 90 + bottomPadding,
      padding: EdgeInsets.only(
        bottom: bottomPadding > 0 ? bottomPadding : 20,
        left: 20,
        right: 20,
      ),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? Colors.grey[900]?.withOpacity(0.95)
                  : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  _items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = widget.currentIndex == index;

                    return _buildFloatingItem(
                      item: item,
                      index: index,
                      isSelected: isSelected,
                      animation: _bubbleAnimations[index],
                      isDarkMode: isDarkMode,
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingItem({
    required FloatingNavItem item,
    required int index,
    required bool isSelected,
    required Animation<double> animation,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 8,
          vertical: 8,
        ),
        child: AnimatedBuilder(
          animation: _selectionAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Animated background bubble
                if (isSelected)
                  Transform.scale(
                    scale: _selectionAnimation.value,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: item.gradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: item.gradient.colors.first.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Floating bubble effect
                if (isSelected)
                  ...List.generate(3, (i) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        final offset = animation.value * 20 * (i + 1) / 3;
                        return Positioned(
                          bottom: offset,
                          child: Container(
                            width: 4 + i * 2,
                            height: 4 + i * 2,
                            decoration: BoxDecoration(
                              color: item.gradient.colors.first.withOpacity(
                                0.3 - i * 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    );
                  }),

                // Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      if (isSelected) {
                        return const LinearGradient(
                          colors: [Colors.white, Colors.white],
                        ).createShader(bounds);
                      }
                      return LinearGradient(
                        colors:
                            isDarkMode
                                ? [Colors.grey[400]!, Colors.grey[400]!]
                                : [Colors.grey[600]!, Colors.grey[600]!],
                      ).createShader(bounds);
                    },
                    child: Icon(
                      item.icon,
                      size: isSelected ? 28 : 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class FloatingNavItem {
  final IconData icon;
  final String label;
  final LinearGradient gradient;

  FloatingNavItem({
    required this.icon,
    required this.label,
    required this.gradient,
  });
}
