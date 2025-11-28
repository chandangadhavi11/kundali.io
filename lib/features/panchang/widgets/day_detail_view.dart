import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class DayDetailView extends StatefulWidget {
  final DateTime date;

  const DayDetailView({super.key, required this.date});

  @override
  State<DayDetailView> createState() => _DayDetailViewState();
}

class _DayDetailViewState extends State<DayDetailView>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _rotationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    _itemAnimations = List.generate(
      10,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _slideController,
          curve: Interval(
            index * 0.05,
            0.5 + index * 0.05,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    // Stop all animations before disposing
    _slideController.stop();
    _rotationController.stop();

    _slideController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: size.height * 0.85,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            _buildHeader(isDarkMode),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Panchang Elements
                    _buildMainElements(isDarkMode),

                    const SizedBox(height: 20),

                    // Sun & Moon Timings
                    _buildSunMoonTimings(isDarkMode),

                    const SizedBox(height: 20),

                    // Auspicious/Inauspicious Times
                    _buildTimings(isDarkMode),

                    const SizedBox(height: 20),

                    // Choghadiya
                    _buildChoghadiya(isDarkMode),

                    const SizedBox(height: 20),

                    // Additional Info
                    _buildAdditionalInfo(isDarkMode),

                    const SizedBox(height: 20),

                    // Action Buttons
                    _buildActionButtons(isDarkMode),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFDAB3D).withOpacity(0.1),
            const Color(0xFFFF8E53).withOpacity(0.1),
          ],
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFDAB3D), Color(0xFFFF8E53)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFDAB3D).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.wb_sunny_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(widget.date),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Shukla Paksha Tritiya', // Mock Hindu date
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFDAB3D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainElements(bool isDarkMode) {
    final elements = [
      {
        'title': 'Tithi',
        'value': 'Shukla Paksha Tritiya',
        'icon': Icons.nightlight_rounded,
      },
      {'title': 'Nakshatra', 'value': 'Rohini', 'icon': Icons.star_rounded},
      {
        'title': 'Yoga',
        'value': 'Siddhi',
        'icon': Icons.self_improvement_rounded,
      },
      {'title': 'Karana', 'value': 'Gara', 'icon': Icons.schedule_rounded},
      {
        'title': 'Vaar',
        'value': DateFormat('EEEE').format(widget.date),
        'icon': Icons.today_rounded,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Panchang Elements',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
        const SizedBox(height: 12),
        ...elements.asMap().entries.map((entry) {
          final index = entry.key;
          final element = entry.value;

          return AnimatedBuilder(
            animation: _itemAnimations[index],
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(20 * (1 - _itemAnimations[index].value), 0),
                child: Opacity(
                  opacity: _itemAnimations[index].value,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.grey[850]?.withOpacity(0.5)
                              : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFDAB3D).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDAB3D).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            element['icon'] as IconData,
                            color: const Color(0xFFFDAB3D),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                element['title'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                ),
                              ),
                              Text(
                                element['value'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isDarkMode
                                          ? Colors.white
                                          : Colors.grey[900],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildSunMoonTimings(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _itemAnimations[5],
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + 0.2 * _itemAnimations[5].value,
          child: Opacity(
            opacity: _itemAnimations[5].value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFF6B6B).withOpacity(0.1),
                    const Color(0xFFFDAB3D).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFDAB3D).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sun & Moon',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeItem(
                          Icons.wb_sunny_rounded,
                          'Sunrise',
                          '06:15 AM',
                          const Color(0xFFFDAB3D),
                          isDarkMode,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimeItem(
                          Icons.wb_sunny_outlined,
                          'Sunset',
                          '06:45 PM',
                          const Color(0xFFFF8E53),
                          isDarkMode,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeItem(
                          Icons.nightlight_rounded,
                          'Moonrise',
                          '08:30 PM',
                          const Color(0xFF6C5CE7),
                          isDarkMode,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimeItem(
                          Icons.nightlight_outlined,
                          'Moonset',
                          '07:15 AM',
                          const Color(0xFF8B7EFF),
                          isDarkMode,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeItem(
    IconData icon,
    String label,
    String time,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850]?.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimings(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildTimingCard(
            'Auspicious',
            {
              'Abhijit': '11:55 AM - 12:45 PM',
              'Amrit Kaal': '10:30 AM - 12:00 PM',
            },
            Colors.green,
            Icons.check_circle_rounded,
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTimingCard(
            'Inauspicious',
            {
              'Rahu Kaal': '03:00 PM - 04:30 PM',
              'Gulika': '01:30 PM - 03:00 PM',
            },
            Colors.red,
            Icons.cancel_rounded,
            isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildTimingCard(
    String title,
    Map<String, String> timings,
    Color color,
    IconData icon,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
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
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...timings.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChoghadiya(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choghadiya',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? Colors.grey[850]?.withOpacity(0.5)
                    : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            itemBuilder: (context, index) {
              final isGood = index % 3 == 0;
              return Container(
                width: 80,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isGood
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isGood
                            ? Colors.green.withOpacity(0.3)
                            : Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isGood ? 'Shubh' : 'Rog',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isGood ? Colors.green : Colors.orange,
                      ),
                    ),
                    Text(
                      '${6 + index}:00',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isDarkMode ? Colors.grey[850]?.withOpacity(0.5) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow('Region', 'North India (Purnimant)', isDarkMode),
          _buildInfoRow('Ayana', 'Dakshinayana', isDarkMode),
          _buildInfoRow('Ritu', 'Varsha', isDarkMode),
          _buildInfoRow('Paksha', 'Shukla', isDarkMode),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Remind Me',
            Icons.notifications_rounded,
            const Color(0xFF6C5CE7),
            () {},
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Download PDF',
            Icons.download_rounded,
            const Color(0xFFFDAB3D),
            () {},
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Share',
            Icons.share_rounded,
            const Color(0xFFFF6B6B),
            () {},
            isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
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
}
