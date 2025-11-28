import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../core/constants/app_colors.dart';

class AuthRequiredDialog extends StatefulWidget {
  final String feature;
  final String? description;
  final VoidCallback? onSkip;

  const AuthRequiredDialog({
    super.key,
    required this.feature,
    this.description,
    this.onSkip,
  });

  static Future<void> show(
    BuildContext context, {
    required String feature,
    String? description,
    VoidCallback? onSkip,
  }) async {
    HapticFeedback.lightImpact();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AuthRequiredDialog(
            feature: feature,
            description: description,
            onSkip: onSkip,
          ),
    );
  }

  @override
  State<AuthRequiredDialog> createState() => _AuthRequiredDialogState();
}

class _AuthRequiredDialogState extends State<AuthRequiredDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _iconController;

  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _iconRotation;
  late Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();

    // Scale animation for dialog entrance
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Slide animation for content
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Icon animations
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _iconRotation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    // Start animations
    _scaleController.forward();
    _slideController.forward();
    _fadeController.forward();
    _iconController.forward();

    // Add a subtle repeat animation for the icon
    _iconController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _iconController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    context.go('/login');
  }

  void _handleSignup() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    context.go('/signup');
  }

  void _handleSkip() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
    widget.onSkip?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
        builder:
            (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isDark
                                  ? Colors.black.withOpacity(0.3)
                                  : AppColors.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          // Subtle gradient background
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary.withOpacity(0.05),
                                    AppColors.secondary.withOpacity(0.05),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Lock icon with animation
                                  AnimatedBuilder(
                                    animation: _iconController,
                                    builder:
                                        (context, child) => Transform.rotate(
                                          angle: _iconRotation.value,
                                          child: Transform.scale(
                                            scale: _iconScale.value,
                                            child: Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    AppColors.primary,
                                                    AppColors.primary
                                                        .withOpacity(0.7),
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.primary
                                                        .withOpacity(0.3),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.lock_outline_rounded,
                                                color: Colors.white,
                                                size: 36,
                                              ),
                                            ),
                                          ),
                                        ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Title
                                  Text(
                                    'Unlock ${widget.feature}',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),

                                  // Description
                                  Text(
                                    widget.description ??
                                        'Sign in to access this feature and save your data securely in the cloud.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.textTheme.bodySmall?.color,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),

                                  // Login button with gradient
                                  Container(
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primary.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _handleLogin,
                                        borderRadius: BorderRadius.circular(16),
                                        child: Center(
                                          child: Text(
                                            'Sign In',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Sign up button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: OutlinedButton(
                                      onPressed: _handleSignup,
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: AppColors.primary.withOpacity(
                                            0.3,
                                          ),
                                          width: 2,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Skip button (if provided)
                                  if (widget.onSkip != null) ...[
                                    const SizedBox(height: 16),
                                    TextButton(
                                      onPressed: _handleSkip,
                                      child: Text(
                                        'Maybe Later',
                                        style: TextStyle(
                                          color:
                                              theme.textTheme.bodySmall?.color,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          // Close button
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.close_rounded,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}








