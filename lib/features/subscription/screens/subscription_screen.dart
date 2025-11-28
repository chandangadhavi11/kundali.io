import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';
import 'dart:math' as math;

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _cardsController;
  late AnimationController _tableController;
  late AnimationController _testimonialController;

  late Animation<double> _heroFadeAnimation;
  late Animation<double> _heroScaleAnimation;
  late Animation<double> _cardsSlideAnimation;
  late Animation<double> _tableExpandAnimation;

  int _selectedPlanIndex = 1; // 0: Monthly, 1: Yearly (default)
  int _currentTestimonialIndex = 0;
  final PageController _testimonialPageController = PageController();

  // Mock data - replace with actual subscription status
  bool isPremium = false;
  DateTime? nextBillingDate = DateTime.now().add(const Duration(days: 30));
  String currentPlan = "Free";

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startTestimonialAutoScroll();
  }

  void _initializeAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _tableController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _testimonialController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _heroFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _heroController, curve: Curves.easeOut));

    _heroScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.elasticOut),
    );

    _cardsSlideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _cardsController, curve: Curves.easeOutCubic),
    );

    _tableExpandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tableController, curve: Curves.easeInOut),
    );

    // Start animations
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _tableController.forward();
      _testimonialController.forward();
    });
  }

  void _startTestimonialAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _currentTestimonialIndex =
              (_currentTestimonialIndex + 1) % _testimonials.length;
        });
        _testimonialPageController.animateToPage(
          _currentTestimonialIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startTestimonialAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _cardsController.dispose();
    _tableController.dispose();
    _testimonialController.dispose();
    _testimonialPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor:
                isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Premium',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative elements
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.secondary.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Hero Section
                AnimatedBuilder(
                  animation: _heroController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _heroScaleAnimation.value,
                      child: Opacity(
                        opacity: _heroFadeAnimation.value,
                        child: _buildHeroSection(isDarkMode),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Benefits Section (for Free users)
                if (!isPremium) ...[
                  AnimatedBuilder(
                    animation: _cardsController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _cardsSlideAnimation.value),
                        child: Opacity(
                          opacity: _cardsController.value,
                          child: _buildBenefitsSection(isDarkMode),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],

                // Pricing Cards
                if (!isPremium) ...[
                  AnimatedBuilder(
                    animation: _cardsController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _cardsSlideAnimation.value * 1.5),
                        child: Opacity(
                          opacity: _cardsController.value,
                          child: _buildPricingSection(isDarkMode),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],

                // Premium Management (for Premium users)
                if (isPremium) ...[
                  _buildPremiumManagement(isDarkMode),
                  const SizedBox(height: 32),
                ],

                // Comparison Table
                AnimatedBuilder(
                  animation: _tableController,
                  builder: (context, child) {
                    return SizeTransition(
                      sizeFactor: _tableExpandAnimation,
                      child: _buildComparisonTable(isDarkMode),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Trust Badges
                _buildTrustBadges(isDarkMode),

                const SizedBox(height: 32),

                // Testimonials
                AnimatedBuilder(
                  animation: _testimonialController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _testimonialController.value,
                      child: _buildTestimonials(isDarkMode),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isPremium
                  ? [
                    const Color(0xFFFFD700).withOpacity(0.2),
                    const Color(0xFFFFA500).withOpacity(0.1),
                  ]
                  : [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                  ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isPremium
                  ? const Color(0xFFFFD700).withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Status Icon
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * math.pi,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors:
                          isPremium
                              ? [
                                const Color(0xFFFFD700),
                                const Color(0xFFFFA500),
                              ]
                              : [Colors.grey.shade400, Colors.grey.shade600],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isPremium
                                ? const Color(0xFFFFD700).withOpacity(0.5)
                                : Colors.grey.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    isPremium
                        ? Icons.stars_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Status Text
          Text(
            isPremium ? 'Premium Member' : 'Free Plan',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          // Status Description
          Text(
            isPremium
                ? 'Enjoy unlimited access to all features'
                : 'Upgrade to unlock premium features',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),

          if (!isPremium) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '2 AI questions remaining today',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(bool isDarkMode) {
    final benefits = [
      {
        'icon': Icons.chat_bubble_outline_rounded,
        'title': 'Unlimited AI Chat',
        'description': 'Ask unlimited questions (vs 3/day)',
        'color': const Color(0xFF6366F1),
      },
      {
        'icon': Icons.block_rounded,
        'title': 'Ad-Free Experience',
        'description': 'No interruptions, pure focus',
        'color': const Color(0xFF10B981),
      },
      {
        'icon': Icons.article_outlined,
        'title': 'Detailed Reports',
        'description': 'Exclusive in-depth analysis',
        'color': const Color(0xFFF59E0B),
      },
      {
        'icon': Icons.rocket_launch_rounded,
        'title': 'Early Access',
        'description': 'Try new features first',
        'color': const Color(0xFFEF4444),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium Benefits',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: benefits.length,
          itemBuilder: (context, index) {
            final benefit = benefits[index];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 500 + (index * 100)),
              tween: Tween(begin: 0, end: 1),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (benefit['color'] as Color).withOpacity(0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (benefit['color'] as Color).withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (benefit['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            benefit['icon'] as IconData,
                            color: benefit['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          benefit['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          benefit['description'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPricingSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Pricing Cards
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedPlanIndex = 0);
                  HapticFeedback.lightImpact();
                },
                child: _buildPricingCard(
                  title: 'Monthly',
                  price: '₹199',
                  period: '/month',
                  isSelected: _selectedPlanIndex == 0,
                  isDarkMode: isDarkMode,
                  savings: null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedPlanIndex = 1);
                  HapticFeedback.lightImpact();
                },
                child: _buildPricingCard(
                  title: 'Yearly',
                  price: '₹999',
                  period: '/year',
                  isSelected: _selectedPlanIndex == 1,
                  isDarkMode: isDarkMode,
                  savings: '58% OFF',
                  isPopular: true,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Subscribe Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _handleSubscribe,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  _selectedPlanIndex == 0
                      ? 'Subscribe for ₹199/month'
                      : 'Subscribe for ₹999/year',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Payment Methods
        _buildPaymentMethods(isDarkMode),
      ],
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    required String period,
    required bool isSelected,
    required bool isDarkMode,
    String? savings,
    bool isPopular = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            isSelected
                ? (isDarkMode ? Colors.grey.shade900 : Colors.white)
                : (isDarkMode
                    ? Colors.grey.shade800.withOpacity(0.5)
                    : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
                : [],
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'MOST POPULAR',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          if (isPopular) const SizedBox(height: 8),

          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                period,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),

          if (savings != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                savings,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(bool isDarkMode) {
    final paymentMethods = [
      {'icon': FontAwesomeIcons.googlePay, 'name': 'Google Pay'},
      {'icon': Icons.credit_card, 'name': 'Card'},
      {'icon': Icons.account_balance, 'name': 'UPI'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Secure Payment Methods',
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              paymentMethods.map((method) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode
                            ? Colors.grey.shade800.withOpacity(0.5)
                            : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Icon(
                    method['icon'] as IconData,
                    size: 24,
                    color:
                        isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildPremiumManagement(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(0.1),
            const Color(0xFFFFA500).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Subscription',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Plan Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Plan',
                style: TextStyle(
                  color:
                      isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              Text(
                'Premium Yearly',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next billing date',
                style: TextStyle(
                  color:
                      isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              Text(
                'Dec 25, 2024',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount',
                style: TextStyle(
                  color:
                      isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              Text(
                '₹999/year',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _handleManageSubscription,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Manage'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _handleCancelSubscription,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.red.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(bool isDarkMode) {
    final features = [
      {'name': 'AI Chat Questions', 'free': '3/day', 'premium': 'Unlimited'},
      {'name': 'Kundli Generation', 'free': '✓', 'premium': '✓'},
      {'name': 'Daily Horoscope', 'free': '✓', 'premium': '✓'},
      {'name': 'Panchang Access', 'free': '✓', 'premium': '✓'},
      {'name': 'Detailed Reports', 'free': '✗', 'premium': '✓'},
      {'name': 'Ad-Free Experience', 'free': '✗', 'premium': '✓'},
      {'name': 'Priority Support', 'free': '✗', 'premium': '✓'},
      {'name': 'Early Access', 'free': '✗', 'premium': '✓'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compare Plans',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? Colors.grey.shade800.withOpacity(0.5)
                          : Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(flex: 2, child: SizedBox()),
                    Expanded(
                      child: Text(
                        'Free',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Premium',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Features
              ...features.map((feature) {
                final index = features.indexOf(feature);
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          feature['name']!,
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          feature['free']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                feature['free'] == '✗'
                                    ? Colors.red.withOpacity(0.7)
                                    : (isDarkMode
                                        ? Colors.white
                                        : Colors.black87),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          feature['premium']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                feature['premium'] == '✓'
                                    ? Colors.green
                                    : (isDarkMode
                                        ? Colors.white
                                        : Colors.black87),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBadges(bool isDarkMode) {
    final badges = [
      {'icon': Icons.security, 'text': 'Secure Payment'},
      {'icon': Icons.refresh, 'text': '30-Day Money Back'},
      {'icon': Icons.support_agent, 'text': '24/7 Support'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          badges.map((badge) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    badge['icon'] as IconData,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  badge['text'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildTestimonials(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What Our Users Say',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _testimonialPageController,
            onPageChanged: (index) {
              setState(() => _currentTestimonialIndex = index);
            },
            itemCount: _testimonials.length,
            itemBuilder: (context, index) {
              final testimonial = _testimonials[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          Icons.star,
                          size: 16,
                          color:
                              i < testimonial['rating']
                                  ? Colors.amber
                                  : Colors.grey.shade300,
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      testimonial['text']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color:
                            isDarkMode
                                ? Colors.grey.shade300
                                : Colors.grey.shade700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '- ${testimonial['name']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Page Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_testimonials.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: index == _currentTestimonialIndex ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color:
                    index == _currentTestimonialIndex
                        ? AppColors.primary
                        : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Mock testimonials data
  final List<Map<String, dynamic>> _testimonials = [
    {
      'name': 'Priya Sharma',
      'rating': 5,
      'text':
          'The AI astrologer is incredibly accurate! Unlimited questions have helped me make better life decisions.',
    },
    {
      'name': 'Rahul Verma',
      'rating': 5,
      'text':
          'Ad-free experience makes using the app so much better. Worth every rupee!',
    },
    {
      'name': 'Anita Patel',
      'rating': 5,
      'text':
          'Detailed reports gave me insights I never had before. Premium is a game-changer!',
    },
    {
      'name': 'Suresh Kumar',
      'rating': 4,
      'text':
          'Great value for money. The yearly plan saved me a lot compared to monthly.',
    },
  ];

  void _handleSubscribe() {
    HapticFeedback.mediumImpact();
    // TODO: Implement payment gateway integration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedPlanIndex == 0
              ? 'Processing Monthly subscription...'
              : 'Processing Yearly subscription...',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _handleManageSubscription() {
    HapticFeedback.lightImpact();
    // TODO: Navigate to subscription management
  }

  void _handleCancelSubscription() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Subscription?'),
            content: const Text(
              'Are you sure you want to cancel your premium subscription? You will lose access to all premium features.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Keep Premium'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement subscription cancellation
                },
                child: const Text(
                  'Cancel Subscription',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}


