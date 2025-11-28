import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';

// Responsive breakpoints
class LoginBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

// Screen size categories
enum ScreenSize { mobile, tablet, desktop }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _scrollController = ScrollController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _keyboardVisible = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupKeyboardListener();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  void _setupKeyboardListener() {
    // Listen to focus changes to handle keyboard
    _emailFocusNode.addListener(_handleFocusChange);
    _passwordFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _keyboardVisible =
          _emailFocusNode.hasFocus || _passwordFocusNode.hasFocus;
    });

    // Scroll to focused field after a short delay
    if (_keyboardVisible) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent * 0.5,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  ScreenSize _getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < LoginBreakpoints.mobile) return ScreenSize.mobile;
    if (width < LoginBreakpoints.tablet) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      HapticFeedback.mediumImpact();
      if (authProvider.currentUser?.birthPlace.isEmpty ?? true) {
        context.go('/profile-setup');
      } else {
        context.go('/home');
      }
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: 20,
            right: 20,
          ),
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      HapticFeedback.mediumImpact();
      if (authProvider.currentUser?.birthPlace.isEmpty ?? true) {
        context.go('/profile-setup');
      } else {
        context.go('/home');
      }
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleGuestMode() {
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = _getScreenSize(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.97),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (screenSize == ScreenSize.desktop) {
                return _buildDesktopLayout(context, l10n, constraints);
              } else {
                return _buildMobileTabletLayout(
                  context,
                  l10n,
                  screenSize,
                  isKeyboardVisible,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // Desktop layout with centered card
  Widget _buildDesktopLayout(
    BuildContext context,
    AppLocalizations l10n,
    BoxConstraints constraints,
  ) {
    return Center(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: math.min(440, constraints.maxWidth * 0.9),
              margin: const EdgeInsets.symmetric(vertical: 40),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: _buildLoginForm(context, l10n, ScreenSize.desktop, false),
            ),
          ),
        ),
      ),
    );
  }

  // Mobile and tablet layout
  Widget _buildMobileTabletLayout(
    BuildContext context,
    AppLocalizations l10n,
    ScreenSize screenSize,
    bool isKeyboardVisible,
  ) {
    final padding = _getResponsivePadding(screenSize);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: isKeyboardVisible ? 0 : padding.bottom),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: padding.left,
          vertical: isKeyboardVisible ? 20 : padding.top,
        ),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildLoginForm(
              context,
              l10n,
              screenSize,
              isKeyboardVisible,
            ),
          ),
        ),
      ),
    );
  }

  // Main login form
  Widget _buildLoginForm(
    BuildContext context,
    AppLocalizations l10n,
    ScreenSize screenSize,
    bool isKeyboardVisible,
  ) {
    final textFieldHeight = _getTextFieldHeight(screenSize);
    final fontSize = _getFontSize(screenSize);
    final spacing = _getSpacing(screenSize);
    final buttonHeight = _getButtonHeight(screenSize);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo and title (hide when keyboard is visible on mobile)
          if (!isKeyboardVisible || screenSize != ScreenSize.mobile)
            _buildHeader(context, l10n, screenSize),

          SizedBox(height: spacing * 2),

          // Email field
          _buildEmailField(l10n, textFieldHeight, fontSize),

          SizedBox(height: spacing),

          // Password field
          _buildPasswordField(l10n, textFieldHeight, fontSize),

          SizedBox(height: spacing * 0.5),

          // Forgot password
          _buildForgotPassword(l10n, fontSize),

          SizedBox(height: spacing * 1.5),

          // Login button
          _buildLoginButton(l10n, buttonHeight, fontSize),

          SizedBox(height: spacing * 1.5),

          // Divider
          _buildDivider(context),

          SizedBox(height: spacing * 1.5),

          // Social login buttons
          _buildSocialLoginButtons(
            context,
            l10n,
            screenSize,
            buttonHeight,
            fontSize,
          ),

          SizedBox(height: spacing * 1.5),

          // Guest mode and sign up
          _buildBottomLinks(context, l10n, fontSize),
        ],
      ),
    );
  }

  // Build header with logo and title
  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    ScreenSize screenSize,
  ) {
    final logoSize = screenSize == ScreenSize.mobile ? 70.0 : 90.0;
    final iconSize = screenSize == ScreenSize.mobile ? 35.0 : 45.0;
    final titleSize = screenSize == ScreenSize.mobile ? 28.0 : 32.0;

    return Center(
      child: Column(
        children: [
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.stars_rounded,
              size: iconSize,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.welcome,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to continue',
            style: TextStyle(
              fontSize: screenSize == ScreenSize.mobile ? 14.0 : 16.0,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // Build email field
  Widget _buildEmailField(
    AppLocalizations l10n,
    double height,
    double fontSize,
  ) {
    return SizedBox(
      height: height,
      child: TextFormField(
        controller: _emailController,
        focusNode: _emailFocusNode,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          labelText: l10n.email,
          prefixIcon: Icon(Icons.email_outlined, size: fontSize * 1.3),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: height * 0.25,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Please enter a valid email';
          }
          return null;
        },
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(_passwordFocusNode);
        },
      ),
    );
  }

  // Build password field
  Widget _buildPasswordField(
    AppLocalizations l10n,
    double height,
    double fontSize,
  ) {
    return SizedBox(
      height: height,
      child: TextFormField(
        controller: _passwordController,
        focusNode: _passwordFocusNode,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.done,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          labelText: l10n.password,
          prefixIcon: Icon(Icons.lock_outline, size: fontSize * 1.3),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              size: fontSize * 1.2,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
            splashRadius: 20,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: height * 0.25,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
        onFieldSubmitted: (_) => _handleLogin(),
      ),
    );
  }

  // Build forgot password link
  Widget _buildForgotPassword(AppLocalizations l10n, double fontSize) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          // TODO: Implement forgot password
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: const Size(48, 48),
        ),
        child: Text(
          l10n.forgotPassword,
          style: TextStyle(fontSize: fontSize * 0.9),
        ),
      ),
    );
  }

  // Build login button
  Widget _buildLoginButton(
    AppLocalizations l10n,
    double height,
    double fontSize,
  ) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height * 0.25),
          ),
          elevation: _isLoading ? 0 : 2,
        ),
        child:
            _isLoading
                ? SizedBox(
                  width: fontSize * 1.5,
                  height: fontSize * 1.5,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                )
                : Text(
                  l10n.login,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  // Build divider
  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  // Build social login buttons
  Widget _buildSocialLoginButtons(
    BuildContext context,
    AppLocalizations l10n,
    ScreenSize screenSize,
    double buttonHeight,
    double fontSize,
  ) {
    final isSmallScreen = screenSize == ScreenSize.mobile;
    final iconSize = fontSize * 1.2;

    final googleButton = _SocialLoginButton(
      onPressed: _isLoading ? null : _handleGoogleSignIn,
      icon: FaIcon(FontAwesomeIcons.google, size: iconSize),
      label: isSmallScreen ? 'Google' : l10n.continueWithGoogle,
      height: buttonHeight,
      fontSize: fontSize,
      color: const Color(0xFFDB4437),
    );

    final facebookButton = _SocialLoginButton(
      onPressed:
          _isLoading
              ? null
              : () {
                HapticFeedback.lightImpact();
                // TODO: Implement Facebook sign in
              },
      icon: FaIcon(FontAwesomeIcons.facebook, size: iconSize),
      label: isSmallScreen ? 'Facebook' : l10n.continueWithFacebook,
      height: buttonHeight,
      fontSize: fontSize,
      color: const Color(0xFF1877F2),
    );

    // Stack vertically on mobile, horizontally on tablet+
    if (isSmallScreen) {
      return Column(
        children: [googleButton, const SizedBox(height: 12), facebookButton],
      );
    } else {
      return Row(
        children: [
          Expanded(child: googleButton),
          const SizedBox(width: 16),
          Expanded(child: facebookButton),
        ],
      );
    }
  }

  // Build bottom links
  Widget _buildBottomLinks(
    BuildContext context,
    AppLocalizations l10n,
    double fontSize,
  ) {
    return Column(
      children: [
        // Guest mode
        TextButton(
          onPressed: _isLoading ? null : _handleGuestMode,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(48, 48),
          ),
          child: Text(
            l10n.guestMode,
            style: TextStyle(
              fontSize: fontSize * 0.95,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Sign up link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(fontSize: fontSize * 0.9),
            ),
            TextButton(
              onPressed:
                  _isLoading
                      ? null
                      : () {
                        HapticFeedback.lightImpact();
                        context.go('/signup');
                      },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: const Size(48, 48),
              ),
              child: Text(
                l10n.signup,
                style: TextStyle(
                  fontSize: fontSize * 0.9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper methods for responsive sizing
  EdgeInsets _getResponsivePadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return const EdgeInsets.all(20);
      case ScreenSize.tablet:
        return const EdgeInsets.all(40);
      case ScreenSize.desktop:
        return const EdgeInsets.all(60);
    }
  }

  double _getTextFieldHeight(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 56; // Minimum 48dp + padding
      case ScreenSize.tablet:
        return 60;
      case ScreenSize.desktop:
        return 64;
    }
  }

  double _getButtonHeight(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 48; // Minimum touch target
      case ScreenSize.tablet:
        return 52;
      case ScreenSize.desktop:
        return 56;
    }
  }

  double _getFontSize(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 15;
      case ScreenSize.tablet:
        return 16;
      case ScreenSize.desktop:
        return 17;
    }
  }

  double _getSpacing(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 16;
      case ScreenSize.tablet:
        return 20;
      case ScreenSize.desktop:
        return 24;
    }
  }
}

// Custom social login button widget
class _SocialLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final double height;
  final double fontSize;
  final Color color;

  const _SocialLoginButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.height,
    required this.fontSize,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height * 0.25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme(data: IconThemeData(color: color), child: icon),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize * 0.95,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
