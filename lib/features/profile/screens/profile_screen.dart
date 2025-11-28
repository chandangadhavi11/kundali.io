import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/quick_actions_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _menuController;
  late AnimationController _floatingController;
  late Animation<double> _headerAnimation;
  late List<Animation<double>> _menuAnimations;
  late Animation<double> _floatingAnimation;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _scrollController.addListener(_onScroll);
  }

  void _initControllers() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _menuController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );

    _menuAnimations = List.generate(
      10,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _menuController,
          curve: Interval(
            index * 0.08,
            0.4 + index * 0.08,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _floatingAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _headerController.forward();
    _menuController.forward();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    // Stop all animations before disposing
    _headerController.stop();
    _menuController.stop();
    _floatingController.stop();

    _headerController.dispose();
    _menuController.dispose();
    _floatingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[950] : Colors.grey[50],
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Animated App Bar
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
            elevation: _scrollOffset > 100 ? 4 : 0,
            flexibleSpace: FlexibleSpaceBar(
              background: AnimatedBuilder(
                animation: _headerAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -30 * (1 - _headerAnimation.value)),
                    child: Opacity(
                      opacity: _headerAnimation.value,
                      child: ProfileHeader(
                        user: user,
                        floatingAnimation: _floatingAnimation,
                      ),
                    ),
                  );
                },
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      (_scrollOffset > 100
                          ? Colors.transparent
                          : (isDarkMode
                              ? Colors.grey[800]?.withOpacity(0.5)
                              : Colors.white.withOpacity(0.9))),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color:
                      _scrollOffset > 100
                          ? (isDarkMode ? Colors.white : Colors.grey[800])
                          : (isDarkMode ? Colors.white : Colors.grey[800]),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _showNotifications(),
                icon: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            (_scrollOffset > 100
                                ? Colors.transparent
                                : (isDarkMode
                                    ? Colors.grey[800]?.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.9))),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications_rounded,
                        size: 20,
                        color:
                            _scrollOffset > 100
                                ? (isDarkMode ? Colors.white : Colors.grey[800])
                                : (isDarkMode
                                    ? Colors.white
                                    : Colors.grey[800]),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B6B),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Guest Sign In Banner (show only for guest users)
          if (!authProvider.isAuthenticated)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                child: AnimatedBuilder(
                  animation: _menuAnimations[0],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - _menuAnimations[0].value)),
                      child: Opacity(
                        opacity: _menuAnimations[0].value,
                        child: _buildGuestSignInBanner(context, isDarkMode),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Quick Actions
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _menuAnimations[0],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - _menuAnimations[0].value)),
                  child: Opacity(
                    opacity: _menuAnimations[0].value,
                    child: QuickActionsSection(isDarkMode: isDarkMode),
                  ),
                );
              },
            ),
          ),

          // Menu Sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Charts & People Section
                  AnimatedBuilder(
                    animation: _menuAnimations[1],
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - _menuAnimations[1].value)),
                        child: Opacity(
                          opacity: _menuAnimations[1].value,
                          child: ProfileMenuSection(
                            title: 'Charts & People',
                            items: [
                              ProfileMenuItem(
                                icon: Icons.stars_rounded,
                                title: 'My Kundlis',
                                subtitle: '3 saved charts',
                                color: const Color(0xFF6C5CE7),
                                onTap: () => _navigateToKundlis(),
                                badge: '3',
                              ),
                              ProfileMenuItem(
                                icon: Icons.favorite_rounded,
                                title: 'Matchmaking',
                                subtitle: 'Compare compatibility',
                                color: const Color(0xFFFF6B94),
                                onTap: () => _navigateToMatchmaking(),
                              ),
                              ProfileMenuItem(
                                icon: Icons.pan_tool_rounded,
                                title: 'Palm & Numerology',
                                subtitle: 'Scans and profiles',
                                color: const Color(0xFF00B894),
                                onTap: () => _navigateToPalmNumerology(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Account Section
                  AnimatedBuilder(
                    animation: _menuAnimations[2],
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - _menuAnimations[2].value)),
                        child: Opacity(
                          opacity: _menuAnimations[2].value,
                          child: ProfileMenuSection(
                            title: 'Account',
                            items: [
                              ProfileMenuItem(
                                icon: Icons.account_balance_wallet_rounded,
                                title: 'Wallet',
                                subtitle: '₹500 balance',
                                color: const Color(0xFFFDAB3D),
                                onTap: () => _navigateToWallet(),
                              ),
                              ProfileMenuItem(
                                icon: Icons.workspace_premium_rounded,
                                title: 'Subscription',
                                subtitle:
                                    user?.isPremium == true
                                        ? 'Premium active'
                                        : 'Upgrade to Premium',
                                color: const Color(0xFFFF8E53),
                                onTap: () => _navigateToSubscription(),
                                badge: user?.isPremium == true ? 'PRO' : null,
                              ),
                              ProfileMenuItem(
                                icon: Icons.download_rounded,
                                title: 'Downloads',
                                subtitle: 'Offline content',
                                color: const Color(0xFF3498DB),
                                onTap: () => _navigateToDownloads(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Settings Section
                  AnimatedBuilder(
                    animation: _menuAnimations[3],
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - _menuAnimations[3].value)),
                        child: Opacity(
                          opacity: _menuAnimations[3].value,
                          child: ProfileMenuSection(
                            title: 'Settings',
                            items: [
                              ProfileMenuItem(
                                icon: Icons.settings_rounded,
                                title: 'App Settings',
                                subtitle: 'Language, notifications, theme',
                                color: const Color(0xFF95A5A6),
                                onTap: () => _navigateToSettings(),
                              ),
                              ProfileMenuItem(
                                icon: Icons.security_rounded,
                                title: 'Privacy & Security',
                                subtitle: 'Data management',
                                color: const Color(0xFF00CEC9),
                                onTap: () => _navigateToPrivacy(),
                              ),
                              ProfileMenuItem(
                                icon: Icons.help_rounded,
                                title: 'Help & Support',
                                subtitle: 'FAQ, contact us',
                                color: const Color(0xFF74B9FF),
                                onTap: () => _navigateToSupport(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // More Section
                  AnimatedBuilder(
                    animation: _menuAnimations[4],
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - _menuAnimations[4].value)),
                        child: Opacity(
                          opacity: _menuAnimations[4].value,
                          child: ProfileMenuSection(
                            title: 'More',
                            items: [
                              ProfileMenuItem(
                                icon: Icons.share_rounded,
                                title: 'Refer & Earn',
                                subtitle: 'Invite friends',
                                color: const Color(0xFF00B894),
                                onTap: () => _navigateToRefer(),
                              ),
                              ProfileMenuItem(
                                icon: Icons.info_rounded,
                                title: 'About',
                                subtitle: 'Version 1.0.0',
                                color: const Color(0xFF6C5CE7),
                                onTap: () => _navigateToAbout(),
                              ),
                              ProfileMenuItem(
                                icon: Icons.logout_rounded,
                                title: 'Sign Out',
                                subtitle: 'Log out of your account',
                                color: const Color(0xFFFF6B6B),
                                onTap: () => _showSignOutDialog(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    HapticFeedback.lightImpact();
    // Show notifications
  }

  void _navigateToKundlis() {
    HapticFeedback.lightImpact();
    // Navigate to Kundlis
  }

  void _navigateToMatchmaking() {
    HapticFeedback.lightImpact();
    // Navigate to Matchmaking
  }

  void _navigateToPalmNumerology() {
    HapticFeedback.lightImpact();
    // Navigate to Palm & Numerology
  }

  void _navigateToWallet() {
    HapticFeedback.lightImpact();
    // Navigate to Wallet
  }

  void _navigateToSubscription() {
    HapticFeedback.lightImpact();
    // Navigate to Subscription
  }

  void _navigateToDownloads() {
    HapticFeedback.lightImpact();
    // Navigate to Downloads
  }

  void _navigateToSettings() {
    HapticFeedback.lightImpact();
    // Navigate to Settings
  }

  void _navigateToPrivacy() {
    HapticFeedback.lightImpact();
    // Navigate to Privacy
  }

  void _navigateToSupport() {
    HapticFeedback.lightImpact();
    // Navigate to Support
  }

  void _navigateToRefer() {
    HapticFeedback.lightImpact();
    // Navigate to Refer
  }

  void _navigateToAbout() {
    HapticFeedback.lightImpact();
    // Navigate to About
  }

  void _showSignOutDialog() {
    HapticFeedback.mediumImpact();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
            title: Text(
              'Sign Out',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.grey[900],
              ),
            ),
            content: Text(
              'Are you sure you want to sign out?',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Sign out logic
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Color(0xFFFF6B6B)),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildGuestSignInBanner(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF7E57C2), const Color(0xFF5E35B1)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E57C2).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lock_open_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unlock Full Experience',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in to save your data and access premium features',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5E35B1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    context.go('/signup');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
