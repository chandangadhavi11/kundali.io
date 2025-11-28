import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZodiacGridView extends StatefulWidget {
  const ZodiacGridView({super.key});

  @override
  State<ZodiacGridView> createState() => _ZodiacGridViewState();
}

class _ZodiacGridViewState extends State<ZodiacGridView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _scaleAnimations;

  final List<Map<String, dynamic>> _zodiacSigns = [
    {
      'name': 'Aries',
      'icon': Icons.whatshot_rounded,
      'color': Color(0xFFFF6B6B),
      'dates': 'Mar 21 - Apr 19',
    },
    {
      'name': 'Taurus',
      'icon': Icons.terrain_rounded,
      'color': Color(0xFF4ECDC4),
      'dates': 'Apr 20 - May 20',
    },
    {
      'name': 'Gemini',
      'icon': Icons.people_rounded,
      'color': Color(0xFFFFD93D),
      'dates': 'May 21 - Jun 20',
    },
    {
      'name': 'Cancer',
      'icon': Icons.home_rounded,
      'color': Color(0xFF95E1D3),
      'dates': 'Jun 21 - Jul 22',
    },
    {
      'name': 'Leo',
      'icon': Icons.sunny,
      'color': Color(0xFFFFA502),
      'dates': 'Jul 23 - Aug 22',
    },
    {
      'name': 'Virgo',
      'icon': Icons.eco_rounded,
      'color': Color(0xFFA8E6CF),
      'dates': 'Aug 23 - Sep 22',
    },
    {
      'name': 'Libra',
      'icon': Icons.balance_rounded,
      'color': Color(0xFFFF8B94),
      'dates': 'Sep 23 - Oct 22',
    },
    {
      'name': 'Scorpio',
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFF8B5CF6),
      'dates': 'Oct 23 - Nov 21',
    },
    {
      'name': 'Sagittarius',
      'icon': Icons.explore_rounded,
      'color': Color(0xFFB983FF),
      'dates': 'Nov 22 - Dec 21',
    },
    {
      'name': 'Capricorn',
      'icon': Icons.landscape_rounded,
      'color': Color(0xFF6C5B7B),
      'dates': 'Dec 22 - Jan 19',
    },
    {
      'name': 'Aquarius',
      'icon': Icons.air_rounded,
      'color': Color(0xFF3498DB),
      'dates': 'Jan 20 - Feb 18',
    },
    {
      'name': 'Pisces',
      'icon': Icons.waves_rounded,
      'color': Color(0xFF74B9FF),
      'dates': 'Feb 19 - Mar 20',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimations = List.generate(
      12,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.05,
            0.5 + index * 0.05,
            curve: Curves.easeOutBack,
          ),
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: _zodiacSigns.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _scaleAnimations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimations[index].value,
              child: _buildZodiacCard(_zodiacSigns[index], isDarkMode),
            );
          },
        );
      },
    );
  }

  Widget _buildZodiacCard(Map<String, dynamic> sign, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigate to sign detail
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900]?.withOpacity(0.7) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (sign['color'] as Color).withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (sign['color'] as Color).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (sign['color'] as Color).withOpacity(0.2),
                    (sign['color'] as Color).withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                sign['icon'] as IconData,
                color: sign['color'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              sign['name'] as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.grey[900],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sign['dates'] as String,
              style: TextStyle(
                fontSize: 9,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


