import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/horoscope_provider.dart';
import 'prediction_micro_card.dart';
import 'lucky_elements_card.dart';
import 'transit_explainer_card.dart';

class DailyHoroscopeView extends StatefulWidget {
  final String userSign;
  final bool isKundliMode;

  const DailyHoroscopeView({
    super.key,
    required this.userSign,
    required this.isKundliMode,
  });

  @override
  State<DailyHoroscopeView> createState() => _DailyHoroscopeViewState();
}

class _DailyHoroscopeViewState extends State<DailyHoroscopeView>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _floatController;
  late List<Animation<double>> _cardAnimations;
  late Animation<double> _floatAnimation;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _cardAnimations = List.generate(
      6,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _floatAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    // Stop all animations before disposing
    _entranceController.stop();
    _floatController.stop();

    _entranceController.dispose();
    _floatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    final horoscope = horoscopeProvider.dailyHoroscopes[widget.userSign];

    if (horoscope == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        await horoscopeProvider.fetchDailyHoroscopes();
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Summary Card
            AnimatedBuilder(
              animation: _cardAnimations[0],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - _cardAnimations[0].value)),
                  child: Opacity(
                    opacity: _cardAnimations[0].value,
                    child: _buildDailySummaryCard(isDarkMode, horoscope),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Lucky Elements
            AnimatedBuilder(
              animation: _cardAnimations[1],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - _cardAnimations[1].value)),
                  child: Opacity(
                    opacity: _cardAnimations[1].value,
                    child: LuckyElementsCard(
                      luckyNumber: horoscope.luckyNumber,
                      luckyColor: horoscope.luckyColor,
                      luckyTime: horoscope.luckyTime ?? '11:00 AM - 1:00 PM',
                      mood: horoscope.mood,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Micro Cards Section
            _buildMicroCardsSection(isDarkMode, horoscope),

            const SizedBox(height: 20),

            // Do's and Don'ts
            AnimatedBuilder(
              animation: _cardAnimations[4],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - _cardAnimations[4].value)),
                  child: Opacity(
                    opacity: _cardAnimations[4].value,
                    child: _buildDosAndDonts(isDarkMode),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Transit Explainer
            AnimatedBuilder(
              animation: _cardAnimations[5],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - _cardAnimations[5].value)),
                  child: Opacity(
                    opacity: _cardAnimations[5].value,
                    child: TransitExplainerCard(
                      transit: 'Moon in Pushya Nakshatra',
                      explanation:
                          'This transit brings nurturing energy and emotional stability. Good for family matters and creative pursuits.',
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // CTA Row
            _buildCTARow(isDarkMode),

            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildDailySummaryCard(bool isDarkMode, dynamic horoscope) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6C5CE7).withOpacity(0.9),
                  const Color(0xFF8B7EFF).withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Prediction',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _getDateString(),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber[300],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${horoscope.rating}/5',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  horoscope.general,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.95),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMicroCardsSection(bool isDarkMode, dynamic horoscope) {
    final categories = [
      {
        'title': 'Love',
        'icon': Icons.favorite_rounded,
        'color': const Color(0xFFFF6B94),
        'content': horoscope.love,
      },
      {
        'title': 'Career',
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFF4ECDC4),
        'content': horoscope.career,
      },
      {
        'title': 'Health',
        'icon': Icons.favorite_border_rounded,
        'color': const Color(0xFF95E1D3),
        'content': horoscope.health,
      },
      {
        'title': 'Finance',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFFFDAB3D),
        'content':
            horoscope.finance ??
            'Financial stability expected today. Avoid impulsive purchases.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Life Areas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _cardAnimations[2 + (index ~/ 2)],
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + 0.2 * _cardAnimations[2 + (index ~/ 2)].value,
                  child: Opacity(
                    opacity: _cardAnimations[2 + (index ~/ 2)].value,
                    child: PredictionMicroCard(
                      title: categories[index]['title'] as String,
                      icon: categories[index]['icon'] as IconData,
                      color: categories[index]['color'] as Color,
                      content: categories[index]['content'] as String,
                      delay: index * 100,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDosAndDonts(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900]?.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDarkMode
                  ? Colors.grey[800]!.withOpacity(0.5)
                  : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Guidance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGuidanceItem(
                  'Do',
                  [
                    'Trust your intuition',
                    'Connect with loved ones',
                    'Start new projects',
                  ],
                  Colors.green,
                  Icons.check_circle_rounded,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGuidanceItem(
                  'Don\'t',
                  [
                    'Make hasty decisions',
                    'Ignore health signs',
                    'Overspend on luxuries',
                  ],
                  Colors.red,
                  Icons.cancel_rounded,
                  isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceItem(
    String title,
    List<String> items,
    Color color,
    IconData icon,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $item',
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTARow(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildCTAButton(
            'Ask AI',
            Icons.psychology_rounded,
            const Color(0xFF00B894),
            () {
              // Navigate to AI chat
            },
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCTAButton(
            'Set Alert',
            Icons.notifications_rounded,
            const Color(0xFF6C5CE7),
            () {
              // Set daily alert
            },
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCTAButton(
            'Share',
            Icons.share_rounded,
            const Color(0xFFFF6B6B),
            () {
              // Share horoscope
            },
            isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildCTAButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDateString() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}
