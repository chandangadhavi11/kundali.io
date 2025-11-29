import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/horoscope_provider.dart';

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  String _selectedCategory = 'general';
  String _userSign = 'Aries';

  final List<_Category> _categories = [
    _Category(
      'general',
      'Overview',
      CupertinoIcons.sparkles,
      const Color(0xFF8B5CF6),
    ),
    _Category(
      'love',
      'Love',
      CupertinoIcons.heart_fill,
      const Color(0xFFEC4899),
    ),
    _Category(
      'career',
      'Career',
      CupertinoIcons.briefcase_fill,
      const Color(0xFF3B82F6),
    ),
    _Category(
      'health',
      'Wellness',
      CupertinoIcons.leaf_arrow_circlepath,
      const Color(0xFF10B981),
    ),
    _Category(
      'finance',
      'Wealth',
      CupertinoIcons.chart_bar_alt_fill,
      const Color(0xFFE8B931),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _loadData();
  }

  Future<void> _loadData() async {
    final horoscopeProvider = context.read<HoroscopeProvider>();
    await horoscopeProvider.fetchDailyHoroscopes();

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user?.zodiacSign != null && mounted) {
      setState(() => _userSign = user!.zodiacSign);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0612),
      body: Stack(
        children: [
          // Animated cosmic background
          _buildAnimatedBackground(),

          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTodayTab(),
                      _buildWeeklyTab(),
                      _buildAllSignsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A0A2E), Color(0xFF0A0612), Color(0xFF0D0618)],
            ),
          ),
        ),

        // Rotating constellation ring
        Positioned(
          top: -150,
          right: -150,
          child: AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: child,
              );
            },
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Stack(
                children: List.generate(12, (index) {
                  final angle = (index * 30) * math.pi / 180;
                  return Positioned(
                    left: 200 + 180 * math.cos(angle) - 4,
                    top: 200 + 180 * math.sin(angle) - 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8B931).withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),

        // Pulsing glow
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Positioned(
              top: 100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(
                        0xFF6B3FA0,
                      ).withOpacity(0.15 + _pulseController.value * 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Stars
        ...List.generate(30, (index) {
          final random = math.Random(index);
          return Positioned(
            left: random.nextDouble() * MediaQuery.of(context).size.width,
            top: random.nextDouble() * MediaQuery.of(context).size.height,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                final twinkle =
                    (math.sin(_pulseController.value * math.pi + index) + 1) /
                    2;
                return Container(
                  width: 2 + random.nextDouble() * 2,
                  height: 2 + random.nextDouble() * 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2 + twinkle * 0.3),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHeader() {
    final zodiacColor = _getZodiacColor(_userSign);

    return FadeTransition(
      opacity: _fadeController,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFE8B931).withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Your Cosmic Guide',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Zodiac selector with glow
            GestureDetector(
              onTap: () => _showSignSelector(),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      zodiacColor.withOpacity(0.5),
                      zodiacColor.withOpacity(0.2),
                    ],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16101F),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getZodiacSymbol(_userSign),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userSign,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _getZodiacDates(_userSign),
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        CupertinoIcons.chevron_down,
                        size: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8B931), Color(0xFFF4D03F)],
          ),
          borderRadius: BorderRadius.circular(11),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE8B931).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF0A0612),
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Today', height: 38),
          Tab(text: 'This Week', height: 38),
          Tab(text: 'All Signs', height: 38),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    final horoscope = horoscopeProvider.dailyHoroscopes[_userSign];

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFFE8B931),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        child: Column(
          children: [
            // Cosmic Score Card
            _buildCosmicScoreCard(horoscope),
            const SizedBox(height: 16),

            // Category Pills
            _buildCategories(),
            const SizedBox(height: 16),

            // Main Reading Card
            _buildReadingCard(horoscope),
            const SizedBox(height: 16),

            // Lucky Elements Row
            _buildLuckyElementsRow(horoscope),
            const SizedBox(height: 16),

            // Planetary Influence
            _buildPlanetaryInfluence(),
            const SizedBox(height: 16),

            // Compatibility Glimpse
            _buildCompatibilityGlimpse(),
          ],
        ),
      ),
    );
  }

  Widget _buildCosmicScoreCard(dynamic horoscope) {
    final zodiacColor = _getZodiacColor(_userSign);
    final score = (horoscope?.rating ?? 4) * 20;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [zodiacColor.withOpacity(0.2), const Color(0xFF16101F)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: zodiacColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: zodiacColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated Score Circle
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: zodiacColor.withOpacity(
                            0.3 + _pulseController.value * 0.1,
                          ),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Progress ring
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(zodiacColor),
                ),
              ),
              // Center content
              Column(
                children: [
                  Text(
                    '$score',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'score',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 20),

          // Sign info and mood
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getZodiacSymbol(_userSign),
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userSign,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _getZodiacElement(_userSign),
                          style: TextStyle(
                            fontSize: 11,
                            color: zodiacColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Mood chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.sun_max_fill,
                        size: 14,
                        color: const Color(0xFFE8B931),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        horoscope?.mood ?? 'Optimistic',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE8B931),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category.id == _selectedCategory;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedCategory = category.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? LinearGradient(
                          colors: [
                            category.color,
                            category.color.withOpacity(0.7),
                          ],
                        )
                        : null,
                color: isSelected ? null : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected
                          ? Colors.transparent
                          : Colors.white.withOpacity(0.1),
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: category.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Row(
                children: [
                  Icon(
                    category.icon,
                    size: 14,
                    color:
                        isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.6),
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

  Widget _buildReadingCard(dynamic horoscope) {
    final category = _categories.firstWhere((c) => c.id == _selectedCategory);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF16101F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(category.icon, size: 18, color: category.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${category.title} Reading',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Updated today at ${_getCurrentTime()}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
              // Share button
              GestureDetector(
                onTap: () => HapticFeedback.lightImpact(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    CupertinoIcons.share,
                    size: 16,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Reading text with quote styling
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border(left: BorderSide(color: category.color, width: 3)),
            ),
            child: Text(
              _getHoroscopeText(horoscope),
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Rating stars
          Row(
            children: [
              Text(
                'Today\'s Energy',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 8),
              ...List.generate(5, (index) {
                final rating = horoscope?.rating ?? 4;
                return Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Icon(
                    index < rating
                        ? CupertinoIcons.star_fill
                        : CupertinoIcons.star,
                    size: 14,
                    color:
                        index < rating
                            ? const Color(0xFFE8B931)
                            : Colors.white.withOpacity(0.2),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyElementsRow(dynamic horoscope) {
    return Row(
      children: [
        Expanded(
          child: _buildLuckyCard(
            icon: CupertinoIcons.circle_fill,
            label: 'Color',
            value: horoscope?.luckyColor ?? 'Gold',
            color: _getLuckyColor(horoscope?.luckyColor ?? 'Gold'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildLuckyCard(
            icon: CupertinoIcons.number,
            label: 'Number',
            value: horoscope?.luckyNumber?.toString() ?? '7',
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildLuckyCard(
            icon: CupertinoIcons.clock,
            label: 'Peak Hour',
            value: '2 PM',
            color: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildLuckyCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16101F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetaryInfluence() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6B3FA0).withOpacity(0.15),
            const Color(0xFF16101F),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🪐', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text(
                'Planetary Influence',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildPlanetChip('Mercury', '↗', const Color(0xFF3B82F6)),
              const SizedBox(width: 8),
              _buildPlanetChip('Venus', '→', const Color(0xFFEC4899)),
              const SizedBox(width: 8),
              _buildPlanetChip('Mars', '↗', const Color(0xFFEF4444)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Mercury in direct motion enhances communication today.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetChip(String planet, String direction, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            planet,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(direction, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCompatibilityGlimpse() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16101F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💫', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              const Text(
                'Best Match Today',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCompatSign(_getCompatibleSign(_userSign), true),
              const SizedBox(width: 8),
              _buildCompatSign(_getSecondCompatibleSign(_userSign), false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompatSign(String sign, bool primary) {
    final color = _getZodiacColor(sign);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            primary ? color.withOpacity(0.15) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: primary ? Border.all(color: color.withOpacity(0.3)) : null,
      ),
      child: Row(
        children: [
          Text(_getZodiacSymbol(sign), style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sign,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primary ? color : Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                primary ? '95% match' : '88% match',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFFE8B931),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        child: Column(
          children: [
            _buildWeekOverview(),
            const SizedBox(height: 16),
            ...[
              'Mon',
              'Tue',
              'Wed',
              'Thu',
              'Fri',
              'Sat',
              'Sun',
            ].asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildDayCard(entry.value, entry.key),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekOverview() {
    final zodiacColor = _getZodiacColor(_userSign);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [zodiacColor.withOpacity(0.2), const Color(0xFF16101F)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: zodiacColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _getZodiacSymbol(_userSign),
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_userSign\'s Week',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'A transformative week ahead',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildWeekStat('Best Day', 'Saturday', const Color(0xFF10B981)),
              const SizedBox(width: 12),
              _buildWeekStat('Focus', 'Career', const Color(0xFF3B82F6)),
              const SizedBox(width: 12),
              _buildWeekStat('Avoid', 'Tuesday', const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(String day, int index) {
    final isToday = day == 'Sat';
    final dayNames = {
      'Mon': 'Monday',
      'Tue': 'Tuesday',
      'Wed': 'Wednesday',
      'Thu': 'Thursday',
      'Fri': 'Friday',
      'Sat': 'Saturday',
      'Sun': 'Sunday',
    };
    final ratings = [4, 3, 5, 4, 3, 5, 4];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            isToday
                ? const Color(0xFFE8B931).withOpacity(0.1)
                : const Color(0xFF16101F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isToday
                  ? const Color(0xFFE8B931).withOpacity(0.4)
                  : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient:
                  isToday
                      ? const LinearGradient(
                        colors: [Color(0xFFE8B931), Color(0xFFF4D03F)],
                      )
                      : null,
              color: isToday ? null : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color:
                      isToday
                          ? const Color(0xFF0A0612)
                          : Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? 'Today' : dayNames[day] ?? day,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isToday ? const Color(0xFFE8B931) : Colors.white,
                  ),
                ),
                Text(
                  _getDayForecast(index),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          _buildDayRating(ratings[index]),
        ],
      ),
    );
  }

  Widget _buildDayRating(int rating) {
    Color color;
    String label;
    if (rating >= 5) {
      color = const Color(0xFF10B981);
      label = 'Great';
    } else if (rating >= 4) {
      color = const Color(0xFF3B82F6);
      label = 'Good';
    } else {
      color = const Color(0xFFE8B931);
      label = 'Okay';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _getDayForecast(int index) {
    const forecasts = [
      'Focus on growth',
      'Financial planning',
      'New opportunities',
      'Connect with others',
      'Complete tasks',
      'Rest & reflect',
      'Spiritual focus',
    ];
    return forecasts[index];
  }

  Widget _buildAllSignsTab() {
    final signs = [
      'Aries',
      'Taurus',
      'Gemini',
      'Cancer',
      'Leo',
      'Virgo',
      'Libra',
      'Scorpio',
      'Sagittarius',
      'Capricorn',
      'Aquarius',
      'Pisces',
    ];

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.95,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: signs.length,
      itemBuilder: (context, index) {
        final sign = signs[index];
        final isSelected = sign == _userSign;
        final color = _getZodiacColor(sign);

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _userSign = sign);
            _tabController.animateTo(0);
          },
          child: Container(
            decoration: BoxDecoration(
              gradient:
                  isSelected
                      ? LinearGradient(
                        colors: [
                          color.withOpacity(0.3),
                          color.withOpacity(0.1),
                        ],
                      )
                      : null,
              color: isSelected ? null : const Color(0xFF16101F),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color:
                    isSelected
                        ? color.withOpacity(0.5)
                        : Colors.white.withOpacity(0.06),
                width: isSelected ? 2 : 1,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: color.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getZodiacSymbol(sign),
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 6),
                Text(
                  sign,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? color : Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getZodiacElement(sign),
                  style: TextStyle(
                    fontSize: 9,
                    color:
                        isSelected
                            ? color.withOpacity(0.7)
                            : Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSignSelector() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildSignSelector(),
    );
  }

  Widget _buildSignSelector() {
    final signs = [
      'Aries',
      'Taurus',
      'Gemini',
      'Cancer',
      'Leo',
      'Virgo',
      'Libra',
      'Scorpio',
      'Sagittarius',
      'Capricorn',
      'Aquarius',
      'Pisces',
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF16101F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '✨ Select Your Sign',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  signs.map((sign) {
                    final isSelected = sign == _userSign;
                    final color = _getZodiacColor(sign);

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _userSign = sign);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient:
                              isSelected
                                  ? LinearGradient(
                                    colors: [
                                      color.withOpacity(0.3),
                                      color.withOpacity(0.15),
                                    ],
                                  )
                                  : null,
                          color:
                              isSelected
                                  ? null
                                  : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                isSelected
                                    ? color.withOpacity(0.5)
                                    : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _getZodiacSymbol(sign),
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sign,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                color:
                                    isSelected
                                        ? color
                                        : Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Helper methods
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️ Good Morning';
    if (hour < 17) return '🌤️ Good Afternoon';
    return '🌙 Good Evening';
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${now.minute.toString().padLeft(2, '0')} $period';
  }

  String _getHoroscopeText(dynamic horoscope) {
    switch (_selectedCategory) {
      case 'love':
        return horoscope?.love ??
            'Venus graces your love sector, bringing warmth and romantic possibilities. Open your heart to meaningful connections today.';
      case 'career':
        return horoscope?.career ??
            'Professional energies are aligned in your favor. Bold moves and innovative thinking will open new doors of opportunity.';
      case 'health':
        return horoscope?.health ??
            'Your vital energy flows strong today. Channel it into activities that nurture both body and spirit for optimal wellness.';
      case 'finance':
        return horoscope?.finance ??
            'Abundance consciousness is heightened. Trust your financial instincts and watch for unexpected opportunities.';
      default:
        return horoscope?.general ??
            'The cosmos aligns to illuminate your path today. Your intuition is sharp—trust the guidance from within.';
    }
  }

  String _getZodiacDates(String sign) {
    const dates = {
      'Aries': 'Mar 21 - Apr 19',
      'Taurus': 'Apr 20 - May 20',
      'Gemini': 'May 21 - Jun 20',
      'Cancer': 'Jun 21 - Jul 22',
      'Leo': 'Jul 23 - Aug 22',
      'Virgo': 'Aug 23 - Sep 22',
      'Libra': 'Sep 23 - Oct 22',
      'Scorpio': 'Oct 23 - Nov 21',
      'Sagittarius': 'Nov 22 - Dec 21',
      'Capricorn': 'Dec 22 - Jan 19',
      'Aquarius': 'Jan 20 - Feb 18',
      'Pisces': 'Feb 19 - Mar 20',
    };
    return dates[sign] ?? '';
  }

  String _getZodiacElement(String sign) {
    const elements = {
      'Aries': '🔥 Fire',
      'Taurus': '🌍 Earth',
      'Gemini': '💨 Air',
      'Cancer': '💧 Water',
      'Leo': '🔥 Fire',
      'Virgo': '🌍 Earth',
      'Libra': '💨 Air',
      'Scorpio': '💧 Water',
      'Sagittarius': '🔥 Fire',
      'Capricorn': '🌍 Earth',
      'Aquarius': '💨 Air',
      'Pisces': '💧 Water',
    };
    return elements[sign] ?? '';
  }

  String _getCompatibleSign(String sign) {
    const compat = {
      'Aries': 'Leo',
      'Taurus': 'Virgo',
      'Gemini': 'Libra',
      'Cancer': 'Scorpio',
      'Leo': 'Sagittarius',
      'Virgo': 'Capricorn',
      'Libra': 'Aquarius',
      'Scorpio': 'Pisces',
      'Sagittarius': 'Aries',
      'Capricorn': 'Taurus',
      'Aquarius': 'Gemini',
      'Pisces': 'Cancer',
    };
    return compat[sign] ?? 'Leo';
  }

  String _getSecondCompatibleSign(String sign) {
    const compat = {
      'Aries': 'Sagittarius',
      'Taurus': 'Capricorn',
      'Gemini': 'Aquarius',
      'Cancer': 'Pisces',
      'Leo': 'Aries',
      'Virgo': 'Taurus',
      'Libra': 'Gemini',
      'Scorpio': 'Cancer',
      'Sagittarius': 'Leo',
      'Capricorn': 'Virgo',
      'Aquarius': 'Libra',
      'Pisces': 'Scorpio',
    };
    return compat[sign] ?? 'Aries';
  }

  Color _getLuckyColor(String colorName) {
    const colors = {
      'Red': Color(0xFFEF4444),
      'Blue': Color(0xFF3B82F6),
      'Green': Color(0xFF10B981),
      'Yellow': Color(0xFFE8B931),
      'Purple': Color(0xFF8B5CF6),
      'Pink': Color(0xFFEC4899),
      'Orange': Color(0xFFF97316),
      'Gold': Color(0xFFE8B931),
      'White': Color(0xFFE2E8F0),
    };
    return colors[colorName] ?? const Color(0xFFE8B931);
  }

  Color _getZodiacColor(String sign) {
    const colors = {
      'Aries': Color(0xFFEF4444),
      'Taurus': Color(0xFF10B981),
      'Gemini': Color(0xFFE8B931),
      'Cancer': Color(0xFF06B6D4),
      'Leo': Color(0xFFF97316),
      'Virgo': Color(0xFF84CC16),
      'Libra': Color(0xFFEC4899),
      'Scorpio': Color(0xFF8B5CF6),
      'Sagittarius': Color(0xFFA855F7),
      'Capricorn': Color(0xFF6366F1),
      'Aquarius': Color(0xFF3B82F6),
      'Pisces': Color(0xFF14B8A6),
    };
    return colors[sign] ?? const Color(0xFFE8B931);
  }

  String _getZodiacSymbol(String sign) {
    const symbols = {
      'Aries': '♈',
      'Taurus': '♉',
      'Gemini': '♊',
      'Cancer': '♋',
      'Leo': '♌',
      'Virgo': '♍',
      'Libra': '♎',
      'Scorpio': '♏',
      'Sagittarius': '♐',
      'Capricorn': '♑',
      'Aquarius': '♒',
      'Pisces': '♓',
    };
    return symbols[sign] ?? '✦';
  }
}

class _Category {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  _Category(this.id, this.title, this.icon, this.color);
}
