import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AstrologersMarketplaceView extends StatefulWidget {
  const AstrologersMarketplaceView({super.key});

  @override
  State<AstrologersMarketplaceView> createState() =>
      _AstrologersMarketplaceViewState();
}

class _AstrologersMarketplaceViewState extends State<AstrologersMarketplaceView>
    with TickerProviderStateMixin {
  late AnimationController _filterController;
  late AnimationController _cardController;
  late Animation<double> _filterAnimation;
  late List<Animation<double>> _cardAnimations;

  String _selectedCategory = 'All';
  String _selectedLanguage = 'All';
  String _sortBy = 'Rating';

  final List<String> _categories = [
    'All',
    'Vedic',
    'KP',
    'Numerology',
    'Tarot',
    'Vastu',
  ];

  final List<String> _languages = [
    'All',
    'Hindi',
    'English',
    'Tamil',
    'Telugu',
    'Bengali',
  ];

  final List<Map<String, dynamic>> _astrologers = [
    {
      'name': 'Dr. Rajesh Sharma',
      'expertise': 'Vedic Astrology',
      'experience': '15 years',
      'rating': 4.8,
      'reviews': 2456,
      'price': 50,
      'isOnline': true,
      'languages': ['Hindi', 'English'],
      'nextAvailable': 'Available Now',
      'image': '👨‍🏫',
    },
    {
      'name': 'Priya Mehta',
      'expertise': 'Tarot & Numerology',
      'experience': '8 years',
      'rating': 4.9,
      'reviews': 1823,
      'price': 40,
      'isOnline': false,
      'languages': ['English', 'Hindi'],
      'nextAvailable': 'In 30 mins',
      'image': '👩‍🏫',
    },
    {
      'name': 'K. Subramanian',
      'expertise': 'KP Astrology',
      'experience': '20 years',
      'rating': 4.7,
      'reviews': 3012,
      'price': 60,
      'isOnline': true,
      'languages': ['Tamil', 'English'],
      'nextAvailable': 'Available Now',
      'image': '👨‍🏫',
    },
  ];

  @override
  void initState() {
    super.initState();

    _filterController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _filterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _filterController, curve: Curves.easeOutCubic),
    );

    _cardAnimations = List.generate(
      10,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _filterController.forward();
    _cardController.forward();
  }

  @override
  void dispose() {
    _filterController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Filters
        AnimatedBuilder(
          animation: _filterAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -20 * (1 - _filterAnimation.value)),
              child: Opacity(
                opacity: _filterAnimation.value,
                child: _buildFilters(isDarkMode),
              ),
            );
          },
        ),

        // Sort options
        _buildSortOptions(isDarkMode),

        // Astrologers list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _astrologers.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _cardAnimations[index % 10],
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      30 * (1 - _cardAnimations[index % 10].value),
                    ),
                    child: Opacity(
                      opacity: _cardAnimations[index % 10].value,
                      child: _buildAstrologerCard(
                        _astrologers[index],
                        isDarkMode,
                      ),
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

  Widget _buildFilters(bool isDarkMode) {
    return Column(
      children: [
        // Category filter
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;

              return Padding(
                padding: EdgeInsets.only(
                  right: index < _categories.length - 1 ? 8 : 0,
                ),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  backgroundColor:
                      isDarkMode
                          ? Colors.grey[800]?.withOpacity(0.5)
                          : Colors.grey[100],
                  selectedColor: const Color(0xFF00B894).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF00B894),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color:
                        isSelected
                            ? const Color(0xFF00B894)
                            : (isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600]),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color:
                          isSelected
                              ? const Color(0xFF00B894).withOpacity(0.3)
                              : Colors.transparent,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Language filter
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final language = _languages[index];
              final isSelected = _selectedLanguage == language;

              return Padding(
                padding: EdgeInsets.only(
                  right: index < _languages.length - 1 ? 8 : 0,
                ),
                child: FilterChip(
                  label: Text(language),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedLanguage = language;
                    });
                  },
                  backgroundColor:
                      isDarkMode
                          ? Colors.grey[800]?.withOpacity(0.5)
                          : Colors.grey[100],
                  selectedColor: const Color(0xFF6C5CE7).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF6C5CE7),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color:
                        isSelected
                            ? const Color(0xFF6C5CE7)
                            : (isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600]),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color:
                          isSelected
                              ? const Color(0xFF6C5CE7).withOpacity(0.3)
                              : Colors.transparent,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSortOptions(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900]?.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            Icons.sort_rounded,
            size: 18,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            'Sort by:',
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                _buildSortChip('Rating', isDarkMode),
                const SizedBox(width: 8),
                _buildSortChip('Price', isDarkMode),
                const SizedBox(width: 8),
                _buildSortChip('Experience', isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, bool isDarkMode) {
    final isSelected = _sortBy == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _sortBy = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF00B894).withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color:
                isSelected
                    ? const Color(0xFF00B894)
                    : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Widget _buildAstrologerCard(
    Map<String, dynamic> astrologer,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900]?.withOpacity(0.7) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              astrologer['isOnline']
                  ? const Color(0xFF00B894).withOpacity(0.2)
                  : (isDarkMode
                      ? Colors.grey[800]!.withOpacity(0.5)
                      : Colors.grey[200]!),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00B894).withOpacity(0.2),
                            const Color(0xFF00CEC9).withOpacity(0.2),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          astrologer['image'],
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                    if (astrologer['isOnline'])
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B894),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isDarkMode ? Colors.grey[900]! : Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        astrologer['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${astrologer['expertise']} • ${astrologer['experience']}',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${astrologer['rating']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDarkMode ? Colors.white : Colors.grey[900],
                            ),
                          ),
                          Text(
                            ' (${astrologer['reviews']} reviews)',
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  isDarkMode
                                      ? Colors.grey[500]
                                      : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${astrologer['price']}/min',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF00B894),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            astrologer['isOnline']
                                ? const Color(0xFF00B894).withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        astrologer['nextAvailable'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color:
                              astrologer['isOnline']
                                  ? const Color(0xFF00B894)
                                  : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Languages
            Row(
              children: [
                Icon(
                  Icons.language_rounded,
                  size: 14,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                ),
                const SizedBox(width: 6),
                ...List.generate(
                  (astrologer['languages'] as List).length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      right:
                          index < (astrologer['languages'] as List).length - 1
                              ? 6
                              : 0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        astrologer['languages'][index],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6C5CE7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Chat',
                    Icons.chat_bubble_rounded,
                    const Color(0xFF00B894),
                    astrologer['isOnline'],
                    () => _startChat(astrologer),
                    isDarkMode,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'Call',
                    Icons.phone_rounded,
                    const Color(0xFF6C5CE7),
                    astrologer['isOnline'],
                    () => _startCall(astrologer),
                    isDarkMode,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'Video',
                    Icons.videocam_rounded,
                    const Color(0xFFFF6B94),
                    astrologer['isOnline'],
                    () => _startVideo(astrologer),
                    isDarkMode,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    bool isEnabled,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap:
          isEnabled
              ? () {
                HapticFeedback.lightImpact();
                onTap();
              }
              : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color:
              isEnabled
                  ? color.withOpacity(0.1)
                  : (isDarkMode
                      ? Colors.grey[850]?.withOpacity(0.5)
                      : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isEnabled
                    ? color.withOpacity(0.3)
                    : (isDarkMode
                        ? Colors.grey[800]!.withOpacity(0.5)
                        : Colors.grey[300]!),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color:
                  isEnabled
                      ? color
                      : (isDarkMode ? Colors.grey[600] : Colors.grey[400]),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    isEnabled
                        ? color
                        : (isDarkMode ? Colors.grey[600] : Colors.grey[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startChat(Map<String, dynamic> astrologer) {
    // Navigate to chat screen
  }

  void _startCall(Map<String, dynamic> astrologer) {
    // Start voice call
  }

  void _startVideo(Map<String, dynamic> astrologer) {
    // Start video call
  }
}
