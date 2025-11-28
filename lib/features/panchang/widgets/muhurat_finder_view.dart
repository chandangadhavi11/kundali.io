import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MuhuratFinderView extends StatefulWidget {
  const MuhuratFinderView({super.key});

  @override
  State<MuhuratFinderView> createState() => _MuhuratFinderViewState();
}

class _MuhuratFinderViewState extends State<MuhuratFinderView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  String _selectedEvent = 'Marriage';
  DateTimeRange? _selectedDateRange;
  final String _selectedLocation = 'Current Location';

  final List<Map<String, dynamic>> _eventTypes = [
    {
      'name': 'Marriage',
      'icon': Icons.favorite_rounded,
      'color': const Color(0xFFFF6B94),
    },
    {
      'name': 'Griha Pravesh',
      'icon': Icons.home_rounded,
      'color': const Color(0xFF00B894),
    },
    {
      'name': 'Naamkaran',
      'icon': Icons.child_care_rounded,
      'color': const Color(0xFF6C5CE7),
    },
    {
      'name': 'Business',
      'icon': Icons.business_rounded,
      'color': const Color(0xFFFDAB3D),
    },
    {
      'name': 'Travel',
      'icon': Icons.flight_rounded,
      'color': const Color(0xFF3498DB),
    },
    {
      'name': 'Custom',
      'icon': Icons.edit_rounded,
      'color': const Color(0xFF95A5A6),
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Type Selector
            _buildEventTypeSelector(isDarkMode),

            const SizedBox(height: 24),

            // Date Range Selector
            _buildDateRangeSelector(isDarkMode),

            const SizedBox(height: 20),

            // Location Selector
            _buildLocationSelector(isDarkMode),

            const SizedBox(height: 24),

            // Find Muhurat Button
            _buildFindButton(isDarkMode),

            const SizedBox(height: 24),

            // Recommended Slots
            if (_selectedDateRange != null) _buildRecommendedSlots(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTypeSelector(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Event Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: _eventTypes.length,
          itemBuilder: (context, index) {
            final event = _eventTypes[index];
            final isSelected = _selectedEvent == event['name'];

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedEvent = event['name'] as String;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? (event['color'] as Color).withOpacity(0.1)
                          : (isDarkMode
                              ? Colors.grey[900]?.withOpacity(0.7)
                              : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        isSelected
                            ? (event['color'] as Color).withOpacity(0.5)
                            : (isDarkMode
                                ? Colors.grey[800]!.withOpacity(0.5)
                                : Colors.grey[200]!),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: (event['color'] as Color).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                          : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      event['icon'] as IconData,
                      color: event['color'] as Color,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event['name'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isSelected
                                ? (event['color'] as Color)
                                : (isDarkMode
                                    ? Colors.white
                                    : Colors.grey[900]),
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

  Widget _buildDateRangeSelector(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date Range',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final DateTimeRange? picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: const Color(0xFFFDAB3D),
                      onPrimary: Colors.white,
                      surface: isDarkMode ? Colors.grey[900]! : Colors.white,
                      onSurface: isDarkMode ? Colors.white : Colors.grey[900]!,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              setState(() {
                _selectedDateRange = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.grey[850]?.withOpacity(0.5)
                      : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFDAB3D).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.date_range_rounded,
                  color: const Color(0xFFFDAB3D),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDateRange != null
                        ? '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.end)}'
                        : 'Tap to select dates',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          _selectedDateRange != null
                              ? FontWeight.w600
                              : FontWeight.w500,
                      color:
                          _selectedDateRange != null
                              ? (isDarkMode ? Colors.white : Colors.grey[900])
                              : (isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600]),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSelector(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? Colors.grey[850]?.withOpacity(0.5)
                    : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF6C5CE7).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: const Color(0xFF6C5CE7),
                size: 24,
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
                        color: isDarkMode ? Colors.white : Colors.grey[900],
                      ),
                    ),
                    Text(
                      'New Delhi, India',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // Change location
                },
                child: const Text(
                  'Change',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6C5CE7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFindButton(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              if (_selectedDateRange != null) {
                // Find muhurat
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFDAB3D), Color(0xFFFF8E53)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFDAB3D).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Find Auspicious Times',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendedSlots(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Muhurat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.withOpacity(0.05),
                  Colors.green.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Excellent',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
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
                        color: isDarkMode ? Colors.white : Colors.grey[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${10 + index}:30 AM - ${12 + index}:00 PM',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nakshatra: Rohini | Tithi: Shukla Panchami',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
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


