import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

// Premium Cosmic Colors
class _CosmicColors {
  static const background = Color(0xFF0A0612);
  static const cardDark = Color(0xFF16101F);
  static const golden = Color(0xFFE8B931);
  static const goldenLight = Color(0xFFF5D563);
  static const textPrimary = Color(0xFFFAFAFA);
  static const textSecondary = Color(0xFF9CA3AF);
  static const accent = Color(0xFF6C5CE7);
  static const success = Color(0xFF00B894);
}

class MuhuratFinderView extends StatefulWidget {
  const MuhuratFinderView({super.key});

  @override
  State<MuhuratFinderView> createState() => _MuhuratFinderViewState();
}

class _MuhuratFinderViewState extends State<MuhuratFinderView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  String _selectedEvent = 'Marriage';
  DateTimeRange? _selectedDateRange;
  final String _selectedLocation = 'Current Location';

  final List<Map<String, dynamic>> _eventTypes = [
    {'name': 'Marriage', 'icon': Icons.favorite_rounded, 'color': const Color(0xFFFF6B94)},
    {'name': 'Griha Pravesh', 'icon': Icons.home_rounded, 'color': const Color(0xFF00B894)},
    {'name': 'Naamkaran', 'icon': Icons.child_care_rounded, 'color': const Color(0xFF6C5CE7)},
    {'name': 'Business', 'icon': Icons.business_rounded, 'color': const Color(0xFFE8B931)},
    {'name': 'Travel', 'icon': Icons.flight_rounded, 'color': const Color(0xFF3498DB)},
    {'name': 'Custom', 'icon': Icons.edit_rounded, 'color': const Color(0xFF95A5A6)},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: FadeTransition(
        opacity: _animationController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventTypeSelector(),
            const SizedBox(height: 20),
            _buildDateRangeSelector(),
            const SizedBox(height: 16),
            _buildLocationSelector(),
            const SizedBox(height: 24),
            _buildFindButton(),
            const SizedBox(height: 24),
            if (_selectedDateRange != null) _buildRecommendedSlots(),
          ],
        ),
      ),
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

  Widget _buildEventTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Select Event Type'),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemCount: _eventTypes.length,
          itemBuilder: (context, index) {
            final event = _eventTypes[index];
            final isSelected = _selectedEvent == event['name'];
            final color = event['color'] as Color;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedEvent = event['name'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.12)
                      : Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? color.withOpacity(0.4)
                        : Colors.white.withOpacity(0.08),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      event['icon'] as IconData,
                      color: color,
                      size: 26,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event['name'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? color : _CosmicColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Select Date Range'),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: _CosmicColors.golden,
                      surface: _CosmicColors.cardDark,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() => _selectedDateRange = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _CosmicColors.golden.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _CosmicColors.golden.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.date_range_rounded,
                    color: _CosmicColors.golden,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDateRange != null
                        ? '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.end)}'
                        : 'Tap to select dates',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _selectedDateRange != null ? FontWeight.w600 : FontWeight.w400,
                      color: _selectedDateRange != null
                          ? _CosmicColors.textPrimary
                          : _CosmicColors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: _CosmicColors.textSecondary.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSelector() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _CosmicColors.accent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _CosmicColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: _CosmicColors.accent,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedLocation,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _CosmicColors.textPrimary,
                  ),
                ),
                Text(
                  'New Delhi, India',
                  style: TextStyle(
                    fontSize: 12,
                    color: _CosmicColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
            ),
            child: Text(
              'Change',
              style: TextStyle(
                fontSize: 12,
                color: _CosmicColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (_selectedDateRange == null) {
          // Show message to select date range
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_CosmicColors.golden, _CosmicColors.goldenLight],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _CosmicColors.golden.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              color: _CosmicColors.background,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Find Auspicious Times',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _CosmicColors.background,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Recommended Muhurat'),
        const SizedBox(height: 14),
        ...List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _CosmicColors.success.withOpacity(0.08),
                  _CosmicColors.success.withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _CosmicColors.success.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _CosmicColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: _CosmicColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Excellent',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _CosmicColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Nov ${15 + index}, 2024',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _CosmicColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${10 + index}:30 AM - ${12 + index}:00 PM',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _CosmicColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nakshatra: Rohini | Tithi: Shukla Panchami',
                  style: TextStyle(
                    fontSize: 11,
                    color: _CosmicColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
