import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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

  // Scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    // Stagger animation for items
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    final user = authProvider.currentUser;
    final isGuest = user == null;
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
                  SliverToBoxAdapter(child: _buildPremiumHeader()),

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

  Widget _buildPremiumHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8B931), Color(0xFFF4D03F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Center(
                      child: Text(
                        '॥',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A0A2E),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kundali',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Vedic Astrology',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFE8B931).withOpacity(0.8),
                          letterSpacing: 0.5,
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
                  const SizedBox(width: 6),
                  _buildIconButton(
                    icon: CupertinoIcons.person_circle,
                    onTap: () => context.go('/profile'),
                  ),
                ],
              ),
            ],
          ),
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(icon, color: Colors.white.withOpacity(0.6), size: 18),
            ),
            if (badge)
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 6,
                  height: 6,
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
    return const SizedBox(height: 8);
  }

  Widget _buildCosmicEnergySection(
    String userSign,
    HoroscopeProvider horoscopeProvider,
  ) {
    final horoscope = horoscopeProvider.dailyHoroscopes[userSign];
    final zodiacColor = _getZodiacColor(userSign);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _buildSectionTitle('Daily Horoscope', icon: CupertinoIcons.sparkles),
          const SizedBox(height: 14),

          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.go('/horoscope');
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF16101F),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      // Zodiac Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [zodiacColor, zodiacColor.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            _getZodiacSymbol(userSign),
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Sign Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userSign,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Today\'s Reading',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Arrow
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          CupertinoIcons.chevron_right,
                          size: 16,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Horoscope Text
                  Text(
                    horoscope?.general ??
                        'The stars align in your favor today. Trust your instincts and embrace new opportunities that come your way.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 14),

                  // Divider
                  Container(height: 1, color: Colors.white.withOpacity(0.06)),

                  const SizedBox(height: 14),

                  // Metrics Row - Simplified
                  Row(
                    children: [
                      _buildMinimalMetric(
                        label: 'Mood',
                        value: horoscope?.mood ?? 'Positive',
                        color: const Color(0xFFFF6B9D),
                      ),
                      _buildMetricDivider(),
                      _buildMinimalMetric(
                        label: 'Color',
                        value: horoscope?.luckyColor ?? 'Gold',
                        color: const Color(0xFFE8B931),
                      ),
                      _buildMetricDivider(),
                      _buildMinimalMetric(
                        label: 'Number',
                        value: horoscope?.luckyNumber.toString() ?? '7',
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

  Widget _buildMinimalMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.4),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withOpacity(0.08),
    );
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Quick Actions', icon: CupertinoIcons.bolt_fill),
          const SizedBox(height: 14),

          // Primary Actions Row
          Row(
            children: [
              Expanded(
                child: _buildPrimaryActionCard(
                  title: 'Kundali',
                  subtitle: 'Birth Chart',
                  icon: '🔮',
                  gradient: const [Color(0xFF6B3FA0), Color(0xFF8B5CF6)],
                  route: '/kundli',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPrimaryActionCard(
                  title: 'Matching',
                  subtitle: 'Compatibility',
                  icon: '💫',
                  gradient: const [Color(0xFFD946EF), Color(0xFFF472B6)],
                  route: '/matchmaking',
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Secondary Actions Grid
          Row(
            children: [
              Expanded(
                child: _buildSecondaryActionCard(
                  title: 'Horoscope',
                  icon: CupertinoIcons.sparkles,
                  color: const Color(0xFF4ECDC4),
                  route: '/horoscope',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSecondaryActionCard(
                  title: 'Panchang',
                  icon: CupertinoIcons.calendar,
                  color: const Color(0xFFE8B931),
                  route: '/panchang',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSecondaryActionCard(
                  title: 'AI Guru',
                  icon: CupertinoIcons.bubble_left_fill,
                  color: const Color(0xFFFF6B35),
                  route: '/chat',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSecondaryActionCard(
                  title: 'Learn',
                  icon: CupertinoIcons.book_fill,
                  color: const Color(0xFF8B5CF6),
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
        height: 100,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: Colors.white.withOpacity(0.6),
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
        height: 72,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF16101F),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.7),
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Panchang', icon: CupertinoIcons.moon_fill),
          const SizedBox(height: 14),

          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.go('/panchang');
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF16101F),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                children: [
                  // Header Row
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8B931).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          CupertinoIcons.calendar,
                          color: Color(0xFFE8B931),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              panchang?.vara ?? 'Friday',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              panchang?.tithi ?? 'Panchami',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          CupertinoIcons.chevron_right,
                          size: 16,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Container(height: 1, color: Colors.white.withOpacity(0.06)),

                  const SizedBox(height: 14),

                  // Panchang Info Grid
                  Row(
                    children: [
                      _buildPanchangItem(
                        label: 'Nakshatra',
                        value: panchang?.nakshatra ?? 'Rohini',
                      ),
                      _buildPanchangDivider(),
                      _buildPanchangItem(
                        label: 'Yoga',
                        value: panchang?.yoga ?? 'Siddhi',
                      ),
                      _buildPanchangDivider(),
                      _buildPanchangItem(
                        label: 'Karana',
                        value: panchang?.karana ?? 'Bava',
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Sunrise/Sunset Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildSunTimeCompact(
                          icon: CupertinoIcons.sunrise_fill,
                          time: panchang?.sunrise ?? '6:45 AM',
                          color: const Color(0xFFFFB347),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSunTimeCompact(
                          icon: CupertinoIcons.sunset_fill,
                          time: panchang?.sunset ?? '5:32 PM',
                          color: const Color(0xFFFF6B9D),
                        ),
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

  Widget _buildPanchangItem({required String label, required String value}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanchangDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withOpacity(0.08),
    );
  }

  Widget _buildSunTimeCompact({
    required IconData icon,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            time,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAstrologerBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          context.go('/chat');
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6B3FA0).withOpacity(0.3),
                const Color(0xFF4A2882).withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              // AI Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8B931), Color(0xFFF4D03F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('✨', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ask AI Astrologer',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Get personalized guidance',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: Colors.white.withOpacity(0.5),
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
        Icon(icon, size: 16, color: const Color(0xFFE8B931)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
