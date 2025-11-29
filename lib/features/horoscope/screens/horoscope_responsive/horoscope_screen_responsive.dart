import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

// This is a simplified responsive demo of the Horoscope Screen
// The full implementation is in horoscope_screen.dart

class ResponsiveHoroscopeDemo extends StatefulWidget {
  const ResponsiveHoroscopeDemo({super.key});

  @override
  State<ResponsiveHoroscopeDemo> createState() =>
      _ResponsiveHoroscopeDemoState();
}

class _ResponsiveHoroscopeDemoState extends State<ResponsiveHoroscopeDemo>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedZodiac = 'Aries';
  final Map<String, bool> _expandedCards = {};
  DateTime _selectedDate = DateTime.now();

  final List<ZodiacSign> _zodiacSigns = [
    ZodiacSign('Aries', '♈', const Color(0xFFFF6B6B), Icons.whatshot_rounded),
    ZodiacSign('Taurus', '♉', const Color(0xFF4ECDC4), Icons.terrain_rounded),
    ZodiacSign('Gemini', '♊', const Color(0xFFFFD93D), Icons.people_rounded),
    ZodiacSign('Cancer', '♋', const Color(0xFF95E1D3), Icons.home_rounded),
    ZodiacSign('Leo', '♌', const Color(0xFFFFA502), Icons.sunny),
    ZodiacSign('Virgo', '♍', const Color(0xFFA8E6CF), Icons.eco_rounded),
    ZodiacSign('Libra', '♎', const Color(0xFFFF8B94), Icons.balance_rounded),
    ZodiacSign(
      'Scorpio',
      '♏',
      const Color(0xFF8B5CF6),
      Icons.water_drop_rounded,
    ),
    ZodiacSign(
      'Sagittarius',
      '♐',
      const Color(0xFFB983FF),
      Icons.explore_rounded,
    ),
    ZodiacSign(
      'Capricorn',
      '♑',
      const Color(0xFF6C5B7B),
      Icons.landscape_rounded,
    ),
    ZodiacSign('Aquarius', '♒', const Color(0xFF3498DB), Icons.air_rounded),
    ZodiacSign('Pisces', '♓', const Color(0xFF74B9FF), Icons.waves_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horoscope - Responsive Demo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isMobile = screenWidth < 600;
          final isTablet = screenWidth >= 600 && screenWidth < 900;

          if (isMobile) {
            return _buildMobileLayout();
          } else if (isTablet) {
            return _buildTabletLayout(screenWidth);
          } else {
            return _buildDesktopLayout(screenWidth);
          }
        },
      ),
    );
  }

  // Mobile Layout - Stacked cards
  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Tab navigation
        _buildTabBar(compact: true),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Date picker
                _buildDatePicker(compact: true),
                const SizedBox(height: 16),

                // Selected zodiac card
                _buildSelectedZodiacCard(compact: true),
                const SizedBox(height: 16),

                // Expandable prediction cards
                _buildExpandablePredictionCards(),
                const SizedBox(height: 16),

                // Zodiac grid (2 columns)
                _buildZodiacGrid(columns: 2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Tablet Layout - Side by side
  Widget _buildTabletLayout(double screenWidth) {
    return Column(
      children: [
        // Tab navigation
        _buildTabBar(compact: false),

        // Content
        Expanded(
          child: Row(
            children: [
              // Left panel - Zodiac grid
              SizedBox(
                width: screenWidth * 0.4,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDatePicker(compact: false),
                      const SizedBox(height: 16),
                      _buildZodiacGrid(columns: 3),
                    ],
                  ),
                ),
              ),

              // Right panel - Predictions
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSelectedZodiacCard(compact: false),
                      const SizedBox(height: 16),
                      _buildStaticPredictionCards(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Desktop Layout - Multi-column
  Widget _buildDesktopLayout(double screenWidth) {
    return Row(
      children: [
        // Sidebar - Zodiac grid
        Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(right: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            children: [
              _buildDatePicker(compact: false),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildZodiacGrid(columns: 4),
                ),
              ),
            ],
          ),
        ),

        // Main content
        Expanded(
          child: Column(
            children: [
              // Tab navigation
              _buildTabBar(compact: false),

              // Predictions
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildSelectedZodiacCard(compact: false),
                      const SizedBox(height: 24),
                      _buildStaticPredictionCards(),
                      const SizedBox(height: 24),
                      _buildCompatibilityChart(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build tab bar
  Widget _buildTabBar({required bool compact}) {
    final tabs = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        tabs:
            tabs
                .map((tab) => Tab(height: compact ? 36 : 48, text: tab))
                .toList(),
      ),
    );
  }

  // Build date picker
  Widget _buildDatePicker({required bool compact}) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _showDatePicker(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _formatDate(_selectedDate),
                    style: TextStyle(
                      fontSize: compact ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
            },
          ),
        ],
      ),
    );
  }

  // Build zodiac grid
  Widget _buildZodiacGrid({required int columns}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _zodiacSigns.length,
      itemBuilder: (context, index) {
        final sign = _zodiacSigns[index];
        final isSelected = sign.name == _selectedZodiac;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedZodiac = sign.name;
            });
            HapticFeedback.lightImpact();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient:
                  isSelected
                      ? LinearGradient(
                        colors: [sign.color, sign.color.withOpacity(0.7)],
                      )
                      : null,
              color: !isSelected ? Colors.white : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? sign.color : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(color: sign.color.withOpacity(0.3), blurRadius: 8),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Maintain aspect ratio for icon
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: FittedBox(
                      child: Icon(
                        sign.icon,
                        color: isSelected ? Colors.white : sign.color,
                      ),
                    ),
                  ),
                ),
                Text(
                  sign.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build selected zodiac card
  Widget _buildSelectedZodiacCard({required bool compact}) {
    final sign = _zodiacSigns.firstWhere((s) => s.name == _selectedZodiac);

    return Container(
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [sign.color, sign.color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: sign.color.withOpacity(0.3), blurRadius: 16),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 60 : 80,
            height: compact ? 60 : 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              sign.icon,
              size: compact ? 32 : 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${sign.name} ${sign.symbol}',
                  style: TextStyle(
                    fontSize: compact ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < 4 ? Icons.star : Icons.star_outline,
                      size: 16,
                      color: Colors.white,
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build expandable prediction cards (mobile)
  Widget _buildExpandablePredictionCards() {
    final categories = [
      ('General', Icons.stars_rounded, Colors.purple),
      ('Love', Icons.favorite_rounded, Colors.pink),
      ('Career', Icons.work_rounded, Colors.blue),
      ('Health', Icons.health_and_safety_rounded, Colors.green),
    ];

    return Column(
      children:
          categories.map((category) {
            final isExpanded = _expandedCards[category.$1] ?? false;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _expandedCards[category.$1] = !isExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: category.$3.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(category.$2, color: category.$3),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category.$1,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: const Icon(Icons.expand_more),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                        'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    crossFadeState:
                        isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  // Build static prediction cards (tablet/desktop)
  Widget _buildStaticPredictionCards() {
    final categories = [
      ('General', Icons.stars_rounded, Colors.purple),
      ('Love', Icons.favorite_rounded, Colors.pink),
      ('Career', Icons.work_rounded, Colors.blue),
      ('Health', Icons.health_and_safety_rounded, Colors.green),
    ];

    return Column(
      children:
          categories.map((category) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: category.$3.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(category.$2, color: category.$3),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category.$1,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                    'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  // Build compatibility chart
  Widget _buildCompatibilityChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Compatibility Chart',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Simulated chart
          AspectRatio(
            aspectRatio: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('Chart Visualization')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ZodiacSign {
  final String name;
  final String symbol;
  final Color color;
  final IconData icon;

  ZodiacSign(this.name, this.symbol, this.color, this.icon);
}
