import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/horoscope_provider.dart';
import '../../../core/providers/panchang_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller for stagger effect
  late AnimationController _staggerController;

  // Time and greeting
  Timer? _timeUpdateTimer;
  String _currentTime = '';
  String _greeting = '';
  String _greetingEmoji = '';

  // Scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _updateTimeAndGreeting();
    _startTimeUpdates();
    _loadData();
  }

  void _initializeAnimations() {
    // Stagger animation for items
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  void _updateTimeAndGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    setState(() {
      _currentTime = DateFormat('h:mm').format(now);

      if (hour >= 5 && hour < 12) {
        _greeting = 'Good Morning';
        _greetingEmoji = '☀️';
      } else if (hour >= 12 && hour < 17) {
        _greeting = 'Good Afternoon';
        _greetingEmoji = '🌤️';
      } else if (hour >= 17 && hour < 21) {
        _greeting = 'Good Evening';
        _greetingEmoji = '🌅';
      } else {
        _greeting = 'Good Night';
        _greetingEmoji = '🌙';
      }
    });
  }

  void _startTimeUpdates() {
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
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
    _staggerController.dispose();
    _timeUpdateTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    final user = authProvider.currentUser;
    final isGuest = user == null;
    final userName = isGuest ? 'Seeker' : user.name.split(' ').first;
    final userSign = isGuest ? 'Aries' : user.zodiacSign;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0612),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Animated Cosmic Background
          _buildCosmicBackground(),

          // Main Content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFFE8B931),
              backgroundColor: const Color(0xFF1A1425),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Premium Header
                  SliverToBoxAdapter(
                    child: _buildPremiumHeader(userName, isGuest),
                  ),

                  // Cosmic Divider
                  SliverToBoxAdapter(child: _buildCosmicDivider()),

                  // Today's Cosmic Energy Section
                  SliverToBoxAdapter(
                    child: _buildAnimatedItem(
                      delay: 0.1,
                      child: _buildCosmicEnergySection(
                        userSign,
                        horoscopeProvider,
                      ),
                    ),
                  ),

                  // Quick Actions Grid
                  SliverToBoxAdapter(
                    child: _buildAnimatedItem(
                      delay: 0.2,
                      child: _buildQuickActionsSection(),
                    ),
                  ),

                  // Panchang Card
                  SliverToBoxAdapter(
                    child: _buildAnimatedItem(
                      delay: 0.3,
                      child: _buildPanchangCard(),
                    ),
                  ),

                  // AI Astrologer Banner
                  if (!isGuest)
                    SliverToBoxAdapter(
                      child: _buildAnimatedItem(
                        delay: 0.4,
                        child: _buildAIAstrologerBanner(),
                      ),
                    ),

                  // Bottom Spacing
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCosmicBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0612), Color(0xFF1A0A2E), Color(0xFF0D0618)],
        ),
      ),
      child: Stack(
        children: [
          // Static star field (no animation to avoid issues)
          ...List.generate(25, (index) {
            final random = math.Random(index);
            final size = 1.5 + random.nextDouble() * 2;
            final opacity =
                0.15 + random.nextDouble() * 0.25; // Safe range 0.15-0.4
            return Positioned(
              left: random.nextDouble() * 400,
              top: random.nextDouble() * 800,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(opacity.clamp(0.0, 1.0)),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),

          // Cosmic Glow Effects
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6B3FA0).withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE8B931).withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(String userName, bool isGuest) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo and Brand
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8B931), Color(0xFFF4D03F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE8B931).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '॥',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A0A2E),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kundali',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      ShaderMask(
                        shaderCallback:
                            (bounds) => const LinearGradient(
                              colors: [Color(0xFFE8B931), Color(0xFFF4D03F)],
                            ).createShader(bounds),
                        child: const Text(
                          'Vedic Astrology',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Action Buttons
              Row(
                children: [
                  _buildIconButton(
                    icon: CupertinoIcons.bell,
                    onTap: () {},
                    badge: true,
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    icon: CupertinoIcons.person_circle,
                    onTap: () => context.go('/profile'),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Greeting Section
          Row(
            children: [
              Text(_greetingEmoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Time Display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  children: [
                    Text(
                      _currentTime,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      DateFormat('EEE, MMM d').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Guest Sign-in Prompt
          if (isGuest) ...[
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.go('/login');
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE8B931).withOpacity(0.15),
                      const Color(0xFFF4D03F).withOpacity(0.05),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE8B931).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8B931).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        CupertinoIcons.sparkles,
                        color: Color(0xFFE8B931),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Unlock Your Full Horoscope',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Sign in for personalized cosmic insights',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      CupertinoIcons.arrow_right_circle_fill,
                      color: Color(0xFFE8B931),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool badge = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 22),
            ),
            if (badge)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8B931),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCosmicDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.white.withOpacity(0.1)],
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStarIcon(size: 4),
                const SizedBox(width: 8),
                _buildStarIcon(size: 6),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8B931),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE8B931).withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStarIcon(size: 6),
                const SizedBox(width: 8),
                _buildStarIcon(size: 4),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarIcon({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildCosmicEnergySection(
    String userSign,
    HoroscopeProvider horoscopeProvider,
  ) {
    final horoscope = horoscopeProvider.dailyHoroscopes[userSign];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Today\'s Cosmic Energy',
            icon: CupertinoIcons.sparkles,
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.go('/horoscope');
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1E1432).withOpacity(0.8),
                    const Color(0xFF150E24).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B3FA0).withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Zodiac Symbol
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getZodiacColor(userSign),
                              _getZodiacColor(userSign).withOpacity(0.6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _getZodiacColor(userSign).withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _getZodiacSymbol(userSign),
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userSign,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Daily Horoscope',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // View Button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Read',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              CupertinoIcons.arrow_right,
                              size: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Horoscope Preview
                  Text(
                    horoscope?.general ??
                        'The celestial alignments today favor introspection and growth. Trust your intuition and remain open to unexpected opportunities.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 20),

                  // Cosmic Metrics Row
                  Row(
                    children: [
                      _buildCosmicMetric(
                        label: 'Mood',
                        value: horoscope?.mood ?? 'Inspired',
                        icon: CupertinoIcons.heart_fill,
                        color: const Color(0xFFFF6B9D),
                      ),
                      const SizedBox(width: 12),
                      _buildCosmicMetric(
                        label: 'Lucky Color',
                        value: horoscope?.luckyColor ?? 'Gold',
                        icon: CupertinoIcons.circle_fill,
                        color: const Color(0xFFE8B931),
                      ),
                      const SizedBox(width: 12),
                      _buildCosmicMetric(
                        label: 'Lucky Number',
                        value: horoscope?.luckyNumber.toString() ?? '7',
                        icon: CupertinoIcons.number,
                        color: const Color(0xFF4ECDC4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCosmicMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withOpacity(0.5),
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Explore', icon: CupertinoIcons.compass),
          const SizedBox(height: 16),

          // Primary Actions Row
          Row(
            children: [
              Expanded(
                child: _buildPrimaryActionCard(
                  title: 'Generate\nKundali',
                  subtitle: 'Birth Chart',
                  icon: '🔮',
                  gradient: const [Color(0xFF6B3FA0), Color(0xFF9B59B6)],
                  route: '/kundli',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPrimaryActionCard(
                  title: 'Match\nMaking',
                  subtitle: 'Compatibility',
                  icon: '💑',
                  gradient: const [Color(0xFFE74C8C), Color(0xFFFF6B9D)],
                  route: '/matchmaking',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Secondary Actions Grid
          Row(
            children: [
              Expanded(
                child: _buildSecondaryActionCard(
                  title: 'Horoscope',
                  icon: CupertinoIcons.star_circle_fill,
                  color: const Color(0xFF4ECDC4),
                  route: '/horoscope',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSecondaryActionCard(
                  title: 'Panchang',
                  icon: CupertinoIcons.calendar,
                  color: const Color(0xFFE8B931),
                  route: '/panchang',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSecondaryActionCard(
                  title: 'AI Guru',
                  icon: CupertinoIcons.sparkles,
                  color: const Color(0xFFFF6B35),
                  route: '/chat',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSecondaryActionCard(
                  title: 'Learn',
                  icon: CupertinoIcons.book_fill,
                  color: const Color(0xFF9B59B6),
                  route: '/learn',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionCard({
    required String title,
    required String subtitle,
    required String icon,
    required List<Color> gradient,
    required String route,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.go(route);
      },
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              right: -20,
              bottom: -20,
              child: Text(
                icon,
                style: TextStyle(
                  fontSize: 80,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(icon, style: const TextStyle(fontSize: 32)),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go(route);
      },
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanchangCard() {
    final panchangProvider = context.watch<PanchangProvider>();
    final panchang = panchangProvider.currentPanchang;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Today\'s Panchang',
            icon: CupertinoIcons.moon_stars_fill,
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.go('/panchang');
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A1425).withOpacity(0.9),
                    const Color(0xFF0D0A14).withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFE8B931).withOpacity(0.15),
                ),
              ),
              child: Column(
                children: [
                  // Hindu Date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8B931).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          CupertinoIcons.calendar_today,
                          color: Color(0xFFE8B931),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              panchang?.vara ?? 'Friday',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              panchang?.tithi ?? 'Panchami',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_right,
                        color: Colors.white.withOpacity(0.3),
                        size: 18,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Panchang Elements
                  Row(
                    children: [
                      _buildPanchangElement(
                        label: 'Nakshatra',
                        value: panchang?.nakshatra ?? 'Rohini',
                        color: const Color(0xFF9B59B6),
                      ),
                      const SizedBox(width: 12),
                      _buildPanchangElement(
                        label: 'Yoga',
                        value: panchang?.yoga ?? 'Siddhi',
                        color: const Color(0xFF4ECDC4),
                      ),
                      const SizedBox(width: 12),
                      _buildPanchangElement(
                        label: 'Karana',
                        value: panchang?.karana ?? 'Bava',
                        color: const Color(0xFFE74C8C),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Sunrise/Sunset
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSunTimeItem(
                          icon: CupertinoIcons.sunrise_fill,
                          label: 'Sunrise',
                          time: panchang?.sunrise ?? '6:45 AM',
                          color: const Color(0xFFFFB347),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        _buildSunTimeItem(
                          icon: CupertinoIcons.sunset_fill,
                          label: 'Sunset',
                          time: panchang?.sunset ?? '5:32 PM',
                          color: const Color(0xFFFF6B9D),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanchangElement({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunTimeItem({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAIAstrologerBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          context.go('/chat');
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2A1F4E), Color(0xFF1A1032)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF6B3FA0).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B3FA0).withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // AI Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8B931), Color(0xFFF4D03F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE8B931).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🧙‍♂️', style: TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'AI Astrologer',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ECDC4).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4ECDC4),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ask any question about your destiny',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  CupertinoIcons.arrow_right,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFE8B931)),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedItem({required double delay, required Widget child}) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, _) {
        final progress = ((_staggerController.value - delay) / (1 - delay))
            .clamp(0.0, 1.0);
        final curvedProgress = Curves.easeOutCubic.transform(progress);

        return Opacity(
          opacity: curvedProgress,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - curvedProgress)),
            child: child,
          ),
        );
      },
    );
  }

  Color _getZodiacColor(String sign) {
    final colors = {
      'Aries': const Color(0xFFFF4444),
      'Taurus': const Color(0xFF66BB6A),
      'Gemini': const Color(0xFFFFD54F),
      'Cancer': const Color(0xFF90CAF9),
      'Leo': const Color(0xFFFFB74D),
      'Virgo': const Color(0xFF8D6E63),
      'Libra': const Color(0xFFEC407A),
      'Scorpio': const Color(0xFF8B0000),
      'Sagittarius': const Color(0xFF9C27B0),
      'Capricorn': const Color(0xFF5D4037),
      'Aquarius': const Color(0xFF00ACC1),
      'Pisces': const Color(0xFF7E57C2),
    };
    return colors[sign] ?? const Color(0xFF6B3FA0);
  }

  String _getZodiacSymbol(String sign) {
    final symbols = {
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
