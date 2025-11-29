import 'package:flutter/material.dart';
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

class ProfileHeader extends StatelessWidget {
  final dynamic user;
  final Animation<double>? floatingAnimation;

  const ProfileHeader({
    super.key,
    required this.user,
    this.floatingAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isPremium = user?.isPremium ?? false;
    final name = user?.name ?? 'Guest User';
    final email = user?.email ?? 'guest@example.com';
    final walletBalance = '₹500';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _CosmicColors.accent.withOpacity(0.15),
            _CosmicColors.background,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Cosmic pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _CosmicPatternPainter(),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar
                  _buildAvatar(name, isPremium),

                  const SizedBox(height: 16),

                  // Name
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: _CosmicColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Email
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: _CosmicColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatPill(
                        Icons.account_balance_wallet_rounded,
                        walletBalance,
                        _CosmicColors.golden,
                      ),
                      const SizedBox(width: 12),
                      _buildStatPill(
                        isPremium ? Icons.verified_rounded : Icons.lock_rounded,
                        isPremium ? 'Premium' : 'Free Plan',
                        isPremium ? _CosmicColors.golden : _CosmicColors.accent,
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

  Widget _buildAvatar(String name, bool isPremium) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _CosmicColors.golden.withOpacity(0.3),
                _CosmicColors.accent.withOpacity(0.3),
              ],
            ),
          ),
        ),

        // Avatar circle
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _CosmicColors.cardDark,
                _CosmicColors.background,
              ],
            ),
            border: Border.all(
              color: _CosmicColors.golden.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _CosmicColors.golden.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w600,
                color: _CosmicColors.golden,
              ),
            ),
          ),
        ),

        // Premium badge
        if (isPremium)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_CosmicColors.golden, _CosmicColors.goldenLight],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _CosmicColors.golden.withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                color: _CosmicColors.background,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatPill(IconData icon, String text, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CosmicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
