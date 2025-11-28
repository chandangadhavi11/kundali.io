import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurvedNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CurvedNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CurvedNavigationBar> createState() => _CurvedNavigationBarState();
}

class _CurvedNavigationBarState extends State<CurvedNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _curveController;
  late AnimationController _iconController;
  late Animation<double> _curveAnimation;
  late List<Animation<double>> _iconScaleAnimations;
  late List<Animation<double>> _iconRotateAnimations;

  final List<CurvedNavItem> _items = [
    CurvedNavItem(
      icon: Icons.home_rounded,
      label: 'Home',
      color: const Color(0xFFFF6B6B),
    ),
    CurvedNavItem(
      icon: Icons.auto_awesome_rounded,
      label: 'Horoscope',
      color: const Color(0xFF6C5CE7),
    ),
    CurvedNavItem(
      icon: Icons.calendar_today_rounded,
      label: 'Panchang',
      color: const Color(0xFFFDAB3D),
    ),
    CurvedNavItem(
      icon: Icons.psychology_rounded,
      label: 'Chat',
      color: const Color(0xFF00B894),
    ),
    CurvedNavItem(
      icon: Icons.person_rounded,
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
    _curveController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _curveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _curveController, curve: Curves.easeInOutCubic),
    );

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _iconScaleAnimations = List.generate(
      _items.length,
      (index) => Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(
          parent: _iconController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        ),
      ),
    );

    _iconRotateAnimations = List.generate(
      _items.length,
      (index) => Tween<double>(begin: 0.0, end: 0.1).animate(
        CurvedAnimation(
          parent: _iconController,
          curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
        ),
      ),
    );

    _curveController.forward();
  }

  @override
  void didUpdateWidget(CurvedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _curveController.forward(from: 0);
      _iconController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _curveController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 85 + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SizedBox(
        height: 85,
        child: Stack(
          children: [
            // Curved background
            AnimatedBuilder(
              animation: _curveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(size.width, 85),
                  painter: CurvedPainter(
                    selectedIndex: widget.currentIndex,
                    itemCount: _items.length,
                    animation: _curveAnimation.value,
                    backgroundColor:
                        isDarkMode ? Colors.grey[900]! : Colors.white,
                    curveColor: _items[widget.currentIndex].color,
                    isDarkMode: isDarkMode,
                  ),
                );
              },
            ),

            // Navigation items
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:
                    _items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isSelected = widget.currentIndex == index;

                      return _buildNavItem(
                        item: item,
                        index: index,
                        isSelected: isSelected,
                        scaleAnimation: _iconScaleAnimations[index],
                        rotateAnimation: _iconRotateAnimations[index],
                        isDarkMode: isDarkMode,
                      );
                    }).toList(),
              ),
            ),

            // Center floating button
            Positioned(
              bottom: 25,
              left:
                  size.width / 2 -
                  30 +
                  (widget.currentIndex - 2) * (size.width / _items.length),
              child: AnimatedBuilder(
                animation: _curveAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _curveAnimation.value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _items[widget.currentIndex].color,
                            _items[widget.currentIndex].color.withOpacity(0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _items[widget.currentIndex].color
                                .withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _items[widget.currentIndex].icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required CurvedNavItem item,
    required int index,
    required bool isSelected,
    required Animation<double> scaleAnimation,
    required Animation<double> rotateAnimation,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation:
                  isSelected
                      ? scaleAnimation
                      : const AlwaysStoppedAnimation(1.0),
              builder: (context, child) {
                return Transform.rotate(
                  angle: isSelected ? rotateAnimation.value : 0,
                  child: Transform.scale(
                    scale: isSelected ? scaleAnimation.value : 1.0,
                    child: Icon(
                      item.icon,
                      color:
                          isSelected
                              ? Colors.transparent
                              : isDarkMode
                              ? Colors.grey[600]
                              : Colors.grey[400],
                      size: 24,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 0 : 10,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[500],
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class CurvedNavItem {
  final IconData icon;
  final String label;
  final Color color;

  CurvedNavItem({required this.icon, required this.label, required this.color});
}

class CurvedPainter extends CustomPainter {
  final int selectedIndex;
  final int itemCount;
  final double animation;
  final Color backgroundColor;
  final Color curveColor;
  final bool isDarkMode;

  CurvedPainter({
    required this.selectedIndex,
    required this.itemCount,
    required this.animation,
    required this.backgroundColor,
    required this.curveColor,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final itemWidth = size.width / itemCount;
    final centerX = itemWidth * selectedIndex + itemWidth / 2;

    // Draw shadow
    final shadowPath = Path();
    shadowPath.moveTo(0, 20);
    shadowPath.lineTo(0, size.height);
    shadowPath.lineTo(size.width, size.height);
    shadowPath.lineTo(size.width, 20);

    // Create curve for selected item with animation
    final curveStartX = centerX - itemWidth / 2 - 20;
    final curveEndX = centerX + itemWidth / 2 + 20;

    shadowPath.lineTo(curveEndX, 20);
    shadowPath.quadraticBezierTo(
      curveEndX - 20,
      20,
      curveEndX - 30,
      35 * animation,
    );
    shadowPath.quadraticBezierTo(
      centerX,
      55 * animation,
      curveStartX + 30,
      35 * animation,
    );
    shadowPath.quadraticBezierTo(curveStartX + 20, 20, curveStartX, 20);
    shadowPath.lineTo(0, 20);
    shadowPath.close();

    canvas.drawPath(shadowPath, shadowPaint);

    // Draw main shape
    final path = Path();
    path.moveTo(0, 20);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 20);

    // Create curve for selected item with animation
    path.lineTo(curveEndX, 20);
    path.quadraticBezierTo(curveEndX - 20, 20, curveEndX - 30, 35 * animation);
    path.quadraticBezierTo(
      centerX,
      55 * animation,
      curveStartX + 30,
      35 * animation,
    );
    path.quadraticBezierTo(curveStartX + 20, 20, curveStartX, 20);
    path.lineTo(0, 20);
    path.close();

    canvas.drawPath(path, paint);

    // Draw subtle gradient overlay
    final gradientPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              curveColor.withOpacity(0.05 * animation),
              Colors.transparent,
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant CurvedPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.animation != animation;
  }
}
