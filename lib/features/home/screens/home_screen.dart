import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/horoscope_provider.dart';
import '../../../core/providers/panchang_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late List<AnimationController> _itemControllers;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // Time and greeting
  Timer? _timeUpdateTimer;
  String _currentTime = '';
  String _greeting = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _updateTimeAndGreeting();
    _startTimeUpdates();
    _loadData();
  }

  void _initializeAnimations() {
    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Item animations
    _itemControllers = List.generate(
      10,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400 + (index * 50)),
        vsync: this,
      ),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    for (var controller in _itemControllers) {
      controller.forward();
    }
  }

  void _updateTimeAndGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    setState(() {
      _currentTime = DateFormat('h:mm a').format(now);

      if (hour < 12) {
        _greeting = 'Good Morning';
      } else if (hour < 17) {
        _greeting = 'Good Afternoon';
      } else if (hour < 21) {
        _greeting = 'Good Evening';
      } else {
        _greeting = 'Good Night';
      }
    });
  }

  void _startTimeUpdates() {
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeAndGreeting();
    });
  }

  Future<void> _loadData() async {
    final horoscopeProvider = context.read<HoroscopeProvider>();
    final panchangProvider = context.read<PanchangProvider>();

    await Future.wait([
      horoscopeProvider.fetchDailyHoroscopes(),
      panchangProvider.fetchPanchang(DateTime.now()),
    ]);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    _timeUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    final user = authProvider.currentUser;
    final isGuest = user == null;
    final userName = isGuest ? 'Guest' : user.name.split(' ').first;
    final userSign = isGuest ? 'Aries' : user.zodiacSign;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 56,
                title: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    children: [
                      Text(
                        'Kundali',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Pro',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      CupertinoIcons.bell,
                      size: 22,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Greeting Section
                    _buildAnimatedItem(
                      index: 0,
                      child: _buildGreetingSection(
                        isDarkMode,
                        userName,
                        isGuest,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Today's Insights
                    _buildAnimatedItem(
                      index: 1,
                      child: _buildSectionHeader(
                        'Today\'s Insights',
                        isDarkMode,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Horoscope Card
                    if (!horoscopeProvider.isLoading &&
                        horoscopeProvider.dailyHoroscopes[userSign] != null)
                      _buildAnimatedItem(
                        index: 2,
                        child: _buildCompactHoroscopeCard(
                          userSign,
                          horoscopeProvider.dailyHoroscopes[userSign]!,
                          isDarkMode,
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildAnimatedItem(
                      index: 3,
                      child: _buildSectionHeader('Quick Actions', isDarkMode),
                    ),
                    const SizedBox(height: 12),

                    // Feature Grid
                    _buildFeatureGrid(isDarkMode),

                    const SizedBox(height: 80), // Bottom padding for navigation
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(bool isDarkMode, String userName, bool isGuest) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting with time
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Hi, $userName',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('👋', style: const TextStyle(fontSize: 24)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Time display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _currentTime,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              isDarkMode ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Date and Guest Status Cards
            Row(
              children: [
                // Date Card
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            isDarkMode ? 0.2 : 0.05,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEEE').format(DateTime.now()),
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      isDarkMode
                                          ? Colors.grey[500]
                                          : Colors.grey[600],
                                ),
                              ),
                              Text(
                                DateFormat('dd').format(DateTime.now()),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                ),
                              ),
                              Text(
                                DateFormat('MMMM yyyy').format(DateTime.now()),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Guest Sign In Card
                if (isGuest)
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.go('/login');
                      },
                      child: Container(
                        height: 94,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFF6B6B),
                              const Color(0xFFFF6B6B).withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B6B).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.lock_shield,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Guest Mode',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sign in',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Icon(
                              CupertinoIcons.arrow_right,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactHoroscopeCard(
    String sign,
    dynamic horoscope,
    bool isDarkMode,
  ) {
    final zodiacColors = {
      'Aries': const Color(0xFFFF6B6B),
      'Taurus': const Color(0xFF4ECDC4),
      'Gemini': const Color(0xFFFFD93D),
      'Cancer': const Color(0xFF95E1D3),
      'Leo': const Color(0xFFFFA502),
      'Virgo': const Color(0xFFA8E6CF),
      'Libra': const Color(0xFFFF8B94),
      'Scorpio': const Color(0xFF8B5CF6),
      'Sagittarius': const Color(0xFFB983FF),
      'Capricorn': const Color(0xFF6C5B7B),
      'Aquarius': const Color(0xFF3498DB),
      'Pisces': const Color(0xFF74B9FF),
    };

    final color = zodiacColors[sign] ?? const Color(0xFFFF6B6B);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go('/horoscope');
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder:
            (context, child) => Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              CupertinoIcons.sparkles,
                              color: color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Daily Horoscope',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      _getZodiacIcon(sign),
                                      size: 14,
                                      color: color,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      sign,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 20,
                            color:
                                isDarkMode
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Content
                      Text(
                        horoscope.general ??
                            'Today brings new opportunities for growth and self-discovery. Stay open to unexpected changes.',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      // Lucky elements
                      Row(
                        children: [
                          _buildLuckyChip(
                            icon: CupertinoIcons.heart_fill,
                            label: horoscope.mood ?? 'Positive',
                            color: const Color(0xFFFF6B94),
                          ),
                          const SizedBox(width: 8),
                          _buildLuckyChip(
                            icon: CupertinoIcons.paintbrush_fill,
                            label: horoscope.luckyColor ?? 'Blue',
                            color: const Color(0xFF4ECDC4),
                          ),
                          const SizedBox(width: 8),
                          _buildLuckyChip(
                            icon: CupertinoIcons.number,
                            label: horoscope.luckyNumber?.toString() ?? '7',
                            color: const Color(0xFF95E1D3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildLuckyChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(bool isDarkMode) {
    final features = [
      {
        'title': 'Generate Kundali',
        'icon': CupertinoIcons.chart_pie_fill,
        'image': 'assets/images/ai/kundali_chart.png',
        'color': const Color(0xFF6B4EE6),
        'route': '/kundli',
      },
      {
        'title': 'Match Making',
        'icon': CupertinoIcons.heart_circle_fill,
        'image': 'assets/images/ai/match_making.png',
        'color': const Color(0xFFFF6B6B),
        'route': '/matchmaking',
      },
      {
        'title': 'Horoscope',
        'icon': CupertinoIcons.star_circle_fill,
        'image': 'assets/images/ai/horoscope_zodiac.png',
        'color': const Color(0xFF4ECDC4),
        'route': '/horoscope',
      },
      {
        'title': 'Panchang',
        'icon': CupertinoIcons.calendar_circle_fill,
        'image': 'assets/images/ai/panchang_calendar.png',
        'color': const Color(0xFFFFB347),
        'route': '/panchang',
      },
      {
        'title': 'AI Astrologer',
        'icon': CupertinoIcons.chat_bubble_2_fill,
        'image': 'assets/images/ai/ai_astrologer.png',
        'color': const Color(0xFF4ECB71),
        'route': '/chat',
      },
      {
        'title': 'Learn',
        'icon': CupertinoIcons.book_fill,
        'image': 'assets/images/ai/learn_astrology.png',
        'color': const Color(0xFF9B59B6),
        'route': '/learn',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildAnimatedItem(
          index: index + 4,
          child: _buildFeatureCard(
            title: feature['title'] as String,
            icon: feature['icon'] as IconData,
            image: feature['image'] as String?,
            color: feature['color'] as Color,
            route: feature['route'] as String,
            isDarkMode: isDarkMode,
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    String? image,
    required Color color,
    required String route,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go(route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    image != null
                        ? Image.asset(
                          image,
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to icon if image fails to load
                            return Icon(icon, color: color, size: 24);
                          },
                        )
                        : Icon(icon, color: color, size: 24),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    final controller = _itemControllers[index.clamp(0, 9)];
    return FadeTransition(
      opacity: CurvedAnimation(parent: controller, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
  }

  IconData _getZodiacIcon(String sign) {
    switch (sign.toLowerCase()) {
      case 'aries':
        return CupertinoIcons.flame_fill;
      case 'taurus':
        return CupertinoIcons.leaf_arrow_circlepath;
      case 'gemini':
        return CupertinoIcons.person_2_fill;
      case 'cancer':
        return CupertinoIcons.house_fill;
      case 'leo':
        return CupertinoIcons.sun_max_fill;
      case 'virgo':
        return CupertinoIcons.leaf_arrow_circlepath;
      case 'libra':
        return CupertinoIcons.equal;
      case 'scorpio':
        return CupertinoIcons.drop_fill;
      case 'sagittarius':
        return CupertinoIcons.location_north_fill;
      case 'capricorn':
        return CupertinoIcons.triangle_fill;
      case 'aquarius':
        return CupertinoIcons.wind;
      case 'pisces':
        return CupertinoIcons.drop_fill;
      default:
        return CupertinoIcons.star_fill;
    }
  }
}
