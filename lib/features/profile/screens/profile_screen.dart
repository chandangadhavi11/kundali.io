import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../core/providers/auth_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/quick_actions_section.dart';

// Premium Cosmic Colors
class _CosmicColors {
  static const background = Color(0xFF0A0612);
  static const cardDark = Color(0xFF16101F);
  static const golden = Color(0xFFE8B931);
  static const goldenLight = Color(0xFFF5D563);
  static const textPrimary = Color(0xFFFAFAFA);
  static const textSecondary = Color(0xFF9CA3AF);
  static const accent = Color(0xFF6C5CE7);
  static const danger = Color(0xFFFF6B6B);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: _CosmicColors.background,
      body: Stack(
        children: [
          // Cosmic background
          _buildCosmicBackground(),

          // Main content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Animated App Bar
              SliverAppBar(
                expandedHeight: 320,
                floating: false,
                pinned: true,
                backgroundColor: _scrollOffset > 100
                    ? _CosmicColors.background.withOpacity(0.95)
                    : Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: FadeTransition(
                    opacity: _entryController,
                    child: ProfileHeader(user: user),
                  ),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _buildGlassButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: _buildNotificationButton(),
                  ),
                ],
              ),

              // Guest Sign In Banner
              if (!authProvider.isAuthenticated)
                SliverToBoxAdapter(
                  child: _buildAnimatedSection(
                    delay: 0,
                    child: _buildGuestSignInBanner(context),
                  ),
                ),

              // Quick Actions
              SliverToBoxAdapter(
                child: _buildAnimatedSection(
                  delay: 0.1,
                  child: const QuickActionsSection(isDarkMode: true),
                ),
              ),

              // Menu Sections
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Charts & People Section
                      _buildAnimatedSection(
                        delay: 0.2,
                        child: ProfileMenuSection(
                          title: 'Charts & People',
                          items: [
                            ProfileMenuItem(
                              icon: Icons.auto_awesome_rounded,
                              title: 'My Kundlis',
                              subtitle: '3 saved charts',
                              color: _CosmicColors.accent,
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
                              icon: Icons.pan_tool_alt_rounded,
                              title: 'Palm & Numerology',
                              subtitle: 'Scans and profiles',
                              color: const Color(0xFF00B894),
                              onTap: () => _navigateToPalmNumerology(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Account Section
                      _buildAnimatedSection(
                        delay: 0.3,
                        child: ProfileMenuSection(
                          title: 'Account',
                          items: [
                            ProfileMenuItem(
                              icon: Icons.account_balance_wallet_rounded,
                              title: 'Wallet',
                              subtitle: '₹500 balance',
                              color: _CosmicColors.golden,
                              onTap: () => _navigateToWallet(),
                            ),
                            ProfileMenuItem(
                              icon: Icons.workspace_premium_rounded,
                              title: 'Subscription',
                              subtitle: user?.isPremium == true
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

                      const SizedBox(height: 20),

                      // Settings Section
                      _buildAnimatedSection(
                        delay: 0.4,
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
                              icon: Icons.shield_rounded,
                              title: 'Privacy & Security',
                              subtitle: 'Data management',
                              color: const Color(0xFF00CEC9),
                              onTap: () => _navigateToPrivacy(),
                            ),
                            ProfileMenuItem(
                              icon: Icons.help_outline_rounded,
                              title: 'Help & Support',
                              subtitle: 'FAQ, contact us',
                              color: const Color(0xFF74B9FF),
                              onTap: () => _navigateToSupport(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // More Section
                      _buildAnimatedSection(
                        delay: 0.5,
                        child: ProfileMenuSection(
                          title: 'More',
                          items: [
                            ProfileMenuItem(
                              icon: Icons.card_giftcard_rounded,
                              title: 'Refer & Earn',
                              subtitle: 'Invite friends',
                              color: const Color(0xFF00B894),
                              onTap: () => _navigateToRefer(),
                            ),
                            ProfileMenuItem(
                              icon: Icons.info_outline_rounded,
                              title: 'About',
                              subtitle: 'Version 1.0.0',
                              color: _CosmicColors.accent,
                              onTap: () => _navigateToAbout(),
                            ),
                            ProfileMenuItem(
                              icon: Icons.logout_rounded,
                              title: 'Sign Out',
                              subtitle: 'Log out of your account',
                              color: _CosmicColors.danger,
                              onTap: () => _showSignOutDialog(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCosmicBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            _CosmicColors.accent.withOpacity(0.06),
            _CosmicColors.background,
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: _CosmicColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showNotifications();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 20,
                  color: _CosmicColors.textPrimary,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _CosmicColors.danger,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _CosmicColors.background,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({
    required double delay,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (delay * 300).toInt()),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
    );
  }

  Widget _buildGuestSignInBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _CosmicColors.accent.withOpacity(0.2),
            _CosmicColors.golden.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _CosmicColors.golden.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _CosmicColors.golden.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lock_open_rounded,
                  color: _CosmicColors.golden,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock Full Experience',
                      style: TextStyle(
                        color: _CosmicColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sign in to save your data and access premium features',
                      style: TextStyle(
                        color: _CosmicColors.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.go('/login');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_CosmicColors.golden, _CosmicColors.goldenLight],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _CosmicColors.golden.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _CosmicColors.background,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.go('/signup');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _CosmicColors.golden.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          color: _CosmicColors.golden,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
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

  void _showNotifications() {
    HapticFeedback.lightImpact();
  }

  void _navigateToKundlis() {
    HapticFeedback.lightImpact();
  }

  void _navigateToMatchmaking() {
    HapticFeedback.lightImpact();
  }

  void _navigateToPalmNumerology() {
    HapticFeedback.lightImpact();
  }

  void _navigateToWallet() {
    HapticFeedback.lightImpact();
  }

  void _navigateToSubscription() {
    HapticFeedback.lightImpact();
  }

  void _navigateToDownloads() {
    HapticFeedback.lightImpact();
  }

  void _navigateToSettings() {
    HapticFeedback.lightImpact();
  }

  void _navigateToPrivacy() {
    HapticFeedback.lightImpact();
  }

  void _navigateToSupport() {
    HapticFeedback.lightImpact();
  }

  void _navigateToRefer() {
    HapticFeedback.lightImpact();
  }

  void _navigateToAbout() {
    HapticFeedback.lightImpact();
  }

  void _showSignOutDialog() {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _CosmicColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _CosmicColors.danger.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: _CosmicColors.danger,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _CosmicColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to sign out of your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _CosmicColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _CosmicColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        // Sign out logic
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _CosmicColors.danger,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Sign Out',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
