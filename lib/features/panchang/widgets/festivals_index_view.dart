import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
}

class FestivalsIndexView extends StatefulWidget {
  const FestivalsIndexView({super.key});

  @override
  State<FestivalsIndexView> createState() => _FestivalsIndexViewState();
}

class _FestivalsIndexViewState extends State<FestivalsIndexView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final TextEditingController _searchController = TextEditingController();
  String _selectedRegion = 'All Regions';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _festivals = [
    {
      'name': 'Diwali',
      'date': 'Nov 12, 2024',
      'type': 'Major Festival',
      'color': const Color(0xFFE8B931),
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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildRegionFilter(),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _festivals.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + index * 100),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _buildFestivalCard(_festivals[index]),
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

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: _CosmicColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    style: TextStyle(
                      fontSize: 14,
                      color: _CosmicColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search festivals...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: _CosmicColors.textSecondary.withOpacity(0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Icon(
                      Icons.clear_rounded,
                      color: _CosmicColors.textSecondary,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegionFilter() {
    final regions = ['All Regions', 'North India', 'South India', 'East India', 'West India'];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: regions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final region = regions[index];
          final isSelected = _selectedRegion == region;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedRegion = region);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          _CosmicColors.golden.withOpacity(0.2),
                          _CosmicColors.golden.withOpacity(0.1),
                        ],
                      )
                    : null,
                color: !isSelected ? Colors.white.withOpacity(0.05) : null,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? _CosmicColors.golden.withOpacity(0.5)
                      : Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: _CosmicColors.golden,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    region,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? _CosmicColors.golden
                          : _CosmicColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFestivalCard(Map<String, dynamic> festival) {
    final color = festival['color'] as Color;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showFestivalDetail(festival);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                festival['icon'] as IconData,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    festival['name'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _CosmicColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 11,
                        color: _CosmicColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        festival['date'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: _CosmicColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          festival['type'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
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
              size: 14,
              color: _CosmicColors.textSecondary.withOpacity(0.5),
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
