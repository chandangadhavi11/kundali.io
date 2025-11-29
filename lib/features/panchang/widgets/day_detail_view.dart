import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

// Premium Cosmic Colors
class _CosmicColors {
  static const background = Color(0xFF0A0612);
  static const cardDark = Color(0xFF16101F);
  static const cardLight = Color(0xFF1E1528);
  static const golden = Color(0xFFE8B931);
  static const goldenLight = Color(0xFFF5D563);
  static const textPrimary = Color(0xFFFAFAFA);
  static const textSecondary = Color(0xFF9CA3AF);
  static const accent = Color(0xFF6C5CE7);
  static const festival = Color(0xFFFF6B6B);
  static const fast = Color(0xFF00B894);
}

class DayDetailView extends StatefulWidget {
  final DateTime date;

  const DayDetailView({super.key, required this.date});

  @override
  State<DayDetailView> createState() => _DayDetailViewState();
}

class _DayDetailViewState extends State<DayDetailView>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: size.height * 0.85,
        decoration: BoxDecoration(
          color: _CosmicColors.background,
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
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainElements(),
                    const SizedBox(height: 20),
                    _buildSunMoonTimings(),
                    const SizedBox(height: 20),
                    _buildTimings(),
                    const SizedBox(height: 20),
                    _buildChoghadiya(),
                    const SizedBox(height: 20),
                    _buildAdditionalInfo(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _CosmicColors.golden.withOpacity(0.08),
            _CosmicColors.accent.withOpacity(0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_CosmicColors.golden, _CosmicColors.goldenLight],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _CosmicColors.golden.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.wb_sunny_rounded,
              color: _CosmicColors.background,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(widget.date),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _CosmicColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Shukla Paksha Tritiya',
                  style: TextStyle(
                    fontSize: 13,
                    color: _CosmicColors.golden,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _buildGlassButton(
            icon: Icons.close_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: _CosmicColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainElements() {
    final elements = [
      {'title': 'Tithi', 'value': 'Shukla Paksha Tritiya', 'icon': Icons.nightlight_rounded},
      {'title': 'Nakshatra', 'value': 'Rohini', 'icon': Icons.star_rounded},
      {'title': 'Yoga', 'value': 'Siddhi', 'icon': Icons.self_improvement_rounded},
      {'title': 'Karana', 'value': 'Gara', 'icon': Icons.schedule_rounded},
      {'title': 'Vaar', 'value': DateFormat('EEEE').format(widget.date), 'icon': Icons.today_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Panchang Elements'),
        const SizedBox(height: 12),
        ...elements.map((element) => _buildElementRow(element)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: _CosmicColors.golden,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _CosmicColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildElementRow(Map<String, dynamic> element) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _CosmicColors.golden.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _CosmicColors.golden.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              element['icon'] as IconData,
              color: _CosmicColors.golden,
              size: 18,
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
                    color: _CosmicColors.textSecondary,
                  ),
                ),
                Text(
                  element['value'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _CosmicColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunMoonTimings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _CosmicColors.golden.withOpacity(0.06),
            _CosmicColors.accent.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _CosmicColors.golden.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Sun & Moon'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTimeItem(Icons.wb_sunny_rounded, 'Sunrise', '06:15 AM', _CosmicColors.golden)),
              const SizedBox(width: 12),
              Expanded(child: _buildTimeItem(Icons.wb_twilight_rounded, 'Sunset', '06:45 PM', const Color(0xFFFF8E53))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTimeItem(Icons.nightlight_rounded, 'Moonrise', '08:30 PM', _CosmicColors.accent)),
              const SizedBox(width: 12),
              Expanded(child: _buildTimeItem(Icons.nightlight_outlined, 'Moonset', '07:15 AM', const Color(0xFF8B7EFF))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeItem(IconData icon, String label, String time, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: _CosmicColors.textSecondary,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _CosmicColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimings() {
    return Row(
      children: [
        Expanded(
          child: _buildTimingCard(
            'Auspicious',
            {'Abhijit': '11:55 AM - 12:45 PM', 'Amrit Kaal': '10:30 AM - 12:00 PM'},
            _CosmicColors.fast,
            Icons.check_circle_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTimingCard(
            'Inauspicious',
            {'Rahu Kaal': '03:00 PM - 04:30 PM', 'Gulika': '01:30 PM - 03:00 PM'},
            _CosmicColors.festival,
            Icons.cancel_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildTimingCard(String title, Map<String, String> timings, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
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
          const SizedBox(height: 10),
          ...timings.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 10,
                    color: _CosmicColors.textSecondary,
                  ),
                ),
                Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _CosmicColors.textPrimary,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildChoghadiya() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Choghadiya'),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            itemBuilder: (context, index) {
              final isGood = index % 3 == 0;
              final color = isGood ? _CosmicColors.fast : const Color(0xFFFF8E53);
              
              return Container(
                width: 72,
                margin: EdgeInsets.only(right: index < 7 ? 8 : 0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: color.withOpacity(0.2),
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
                        color: color,
                      ),
                    ),
                    Text(
                      '${6 + index}:00',
                      style: TextStyle(
                        fontSize: 10,
                        color: _CosmicColors.textSecondary,
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

  Widget _buildAdditionalInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow('Region', 'North India (Purnimant)'),
          _buildInfoRow('Ayana', 'Dakshinayana'),
          _buildInfoRow('Ritu', 'Varsha'),
          _buildInfoRow('Paksha', 'Shukla'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: _CosmicColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _CosmicColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(child: _buildActionButton('Remind', Icons.notifications_rounded, _CosmicColors.accent)),
        const SizedBox(width: 10),
        Expanded(child: _buildActionButton('Download', Icons.download_rounded, _CosmicColors.golden)),
        const SizedBox(width: 10),
        Expanded(child: _buildActionButton('Share', Icons.share_rounded, _CosmicColors.festival)),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
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
