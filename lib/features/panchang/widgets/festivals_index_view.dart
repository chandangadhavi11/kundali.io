import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FestivalsIndexView extends StatefulWidget {
  const FestivalsIndexView({super.key});

  @override
  State<FestivalsIndexView> createState() => _FestivalsIndexViewState();
}

class _FestivalsIndexViewState extends State<FestivalsIndexView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _itemAnimations;

  final TextEditingController _searchController = TextEditingController();
  String _selectedRegion = 'All Regions';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _festivals = [
    {
      'name': 'Diwali',
      'date': 'Nov 12, 2024',
      'type': 'Major Festival',
      'color': const Color(0xFFFDAB3D),
      'icon': Icons.celebration_rounded,
    },
    {
      'name': 'Holi',
      'date': 'Mar 25, 2024',
      'type': 'Major Festival',
      'color': const Color(0xFFFF6B94),
      'icon': Icons.palette_rounded,
    },
    {
      'name': 'Navratri',
      'date': 'Oct 3-11, 2024',
      'type': 'Nine Nights',
      'color': const Color(0xFF6C5CE7),
      'icon': Icons.nights_stay_rounded,
    },
    {
      'name': 'Ganesh Chaturthi',
      'date': 'Sep 7, 2024',
      'type': 'Regional',
      'color': const Color(0xFF00B894),
      'icon': Icons.temple_hindu_rounded,
    },
    {
      'name': 'Raksha Bandhan',
      'date': 'Aug 19, 2024',
      'type': 'Family',
      'color': const Color(0xFFFF6B6B),
      'icon': Icons.favorite_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _itemAnimations = List.generate(
      10,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.05,
            0.5 + index * 0.05,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search Bar
        _buildSearchBar(isDarkMode),

        // Region Filter
        _buildRegionFilter(isDarkMode),

        // Festivals List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _festivals.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _itemAnimations[index % 10],
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      20 * (1 - _itemAnimations[index % 10].value),
                    ),
                    child: Opacity(
                      opacity: _itemAnimations[index % 10].value,
                      child: _buildFestivalCard(_festivals[index], isDarkMode),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color:
            isDarkMode ? Colors.grey[850]?.withOpacity(0.5) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDarkMode
                  ? Colors.grey[800]!.withOpacity(0.5)
                  : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white : Colors.grey[900],
              ),
              decoration: InputDecoration(
                hintText: 'Search festivals...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              icon: Icon(
                Icons.clear_rounded,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRegionFilter(bool isDarkMode) {
    final regions = [
      'All Regions',
      'North India',
      'South India',
      'East India',
      'West India',
    ];

    return SizedBox(
      height: 36,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: regions.length,
        itemBuilder: (context, index) {
          final region = regions[index];
          final isSelected = _selectedRegion == region;

          return Padding(
            padding: EdgeInsets.only(right: index < regions.length - 1 ? 8 : 0),
            child: FilterChip(
              label: Text(region),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedRegion = region;
                });
              },
              backgroundColor:
                  isDarkMode
                      ? Colors.grey[800]?.withOpacity(0.5)
                      : Colors.grey[100],
              selectedColor: const Color(0xFFFDAB3D).withOpacity(0.2),
              checkmarkColor: const Color(0xFFFDAB3D),
              labelStyle: TextStyle(
                fontSize: 12,
                color:
                    isSelected
                        ? const Color(0xFFFDAB3D)
                        : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color:
                      isSelected
                          ? const Color(0xFFFDAB3D).withOpacity(0.3)
                          : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFestivalCard(Map<String, dynamic> festival, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showFestivalDetail(festival);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900]?.withOpacity(0.7) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (festival['color'] as Color).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (festival['color'] as Color).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (festival['color'] as Color).withOpacity(0.2),
                    (festival['color'] as Color).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                festival['icon'] as IconData,
                color: festival['color'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    festival['name'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        festival['date'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (festival['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          festival['type'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: festival['color'] as Color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
    );
  }

  void _showFestivalDetail(Map<String, dynamic> festival) {
    // Show festival detail bottom sheet
  }
}


