import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';

// Responsive breakpoints
class SignupBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

// Screen size categories
enum ScreenSize { mobile, tablet, desktop }

// Password strength levels
enum PasswordStrength { weak, fair, good, strong }

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Text controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Focus nodes for keyboard management
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  // State variables
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  DateTime? _selectedDate;
  String? _selectedGender;
  PasswordStrength _passwordStrength = PasswordStrength.weak;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupListeners();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  void _setupListeners() {
    // Listen to password changes for strength calculation
    _passwordController.addListener(_calculatePasswordStrength);

    // Setup focus listeners for keyboard management
    _nameFocusNode.addListener(_handleFocusChange);
    _emailFocusNode.addListener(_handleFocusChange);
    _passwordFocusNode.addListener(_handleFocusChange);
    _confirmPasswordFocusNode.addListener(_handleFocusChange);
    _phoneFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    // Scroll to focused field after a short delay
    if (_nameFocusNode.hasFocus ||
        _emailFocusNode.hasFocus ||
        _passwordFocusNode.hasFocus ||
        _confirmPasswordFocusNode.hasFocus ||
        _phoneFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          if (keyboardHeight > 0) {
            _scrollController.animateTo(
              _scrollController.offset + 100,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      });
    }
  }

  void _calculatePasswordStrength() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _passwordStrength = PasswordStrength.weak);
      return;
    }

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    setState(() {
      if (strength <= 2) {
        _passwordStrength = PasswordStrength.weak;
      } else if (strength <= 3) {
        _passwordStrength = PasswordStrength.fair;
      } else if (strength <= 5) {
        _passwordStrength = PasswordStrength.good;
      } else {
        _passwordStrength = PasswordStrength.strong;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _phoneFocusNode.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  ScreenSize _getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < SignupBreakpoints.mobile) return ScreenSize.mobile;
    if (width < SignupBreakpoints.tablet) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to the terms and conditions'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: 20,
            right: 20,
          ),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signup(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      HapticFeedback.mediumImpact();
      context.go('/profile-setup');
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = _getScreenSize(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
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
                constraints,
              );
            }
          },
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
        child: Container(
          width: math.min(800, constraints.maxWidth * 0.9),
          margin: const EdgeInsets.symmetric(vertical: 40),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  _buildHeader(context, l10n, ScreenSize.desktop),
                  const SizedBox(height: 40),
                  _buildForm(context, l10n, ScreenSize.desktop, false),
                ],
              ),
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
    BoxConstraints constraints,
  ) {
    final padding = _getResponsivePadding(screenSize);

    return Column(
      children: [
        // App bar
        _buildAppBar(context, screenSize),
        // Form content
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: padding,
            child: Column(
              children: [
                if (!isKeyboardVisible || screenSize != ScreenSize.mobile)
                  _buildHeader(context, l10n, screenSize),
                SizedBox(height: isKeyboardVisible ? 20 : 32),
                _buildForm(context, l10n, screenSize, isKeyboardVisible),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Build app bar
  Widget _buildAppBar(BuildContext context, ScreenSize screenSize) {
    final iconSize = screenSize == ScreenSize.mobile ? 24.0 : 28.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, size: iconSize),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.go('/login');
            },
            splashRadius: 24,
          ),
          if (screenSize != ScreenSize.mobile) ...[
            const SizedBox(width: 8),
            Text(
              'Create Account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  // Build header
  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    ScreenSize screenSize,
  ) {
    final titleSize = screenSize == ScreenSize.mobile ? 24.0 : 28.0;
    final subtitleSize = screenSize == ScreenSize.mobile ? 14.0 : 16.0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Create Account',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign up to get started with your astrology journey',
            style: TextStyle(
              fontSize: subtitleSize,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Build form
  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n,
    ScreenSize screenSize,
    bool isKeyboardVisible,
  ) {
    final isTabletOrDesktop = screenSize != ScreenSize.mobile;
    final fieldHeight = _getFieldHeight(screenSize);
    final fontSize = _getFontSize(screenSize);
    final spacing = _getSpacing(screenSize);

    return SlideTransition(
      position: _slideAnimation,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name and Email row (two columns on tablet+)
            if (isTabletOrDesktop)
              Row(
                children: [
                  Expanded(child: _buildNameField(l10n, fieldHeight, fontSize)),
                  SizedBox(width: spacing),
                  Expanded(
                    child: _buildEmailField(l10n, fieldHeight, fontSize),
                  ),
                ],
              )
            else ...[
              _buildNameField(l10n, fieldHeight, fontSize),
              SizedBox(height: spacing),
              _buildEmailField(l10n, fieldHeight, fontSize),
            ],

            SizedBox(height: spacing),

            // Phone and Birth Date row (two columns on tablet+)
            if (isTabletOrDesktop)
              Row(
                children: [
                  Expanded(
                    child: _buildPhoneField(l10n, fieldHeight, fontSize),
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: _buildDateField(
                      context,
                      l10n,
                      fieldHeight,
                      fontSize,
                    ),
                  ),
                ],
              )
            else ...[
              _buildPhoneField(l10n, fieldHeight, fontSize),
              SizedBox(height: spacing),
              _buildDateField(context, l10n, fieldHeight, fontSize),
            ],

            SizedBox(height: spacing),

            // Gender selection
            _buildGenderSelection(context, l10n, fieldHeight, fontSize),

            SizedBox(height: spacing),

            // Password fields with strength indicator
            _buildPasswordField(l10n, fieldHeight, fontSize),
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildPasswordStrengthIndicator(screenSize),
            ],

            SizedBox(height: spacing),

            // Confirm password
            _buildConfirmPasswordField(l10n, fieldHeight, fontSize),

            SizedBox(height: spacing * 1.5),

            // Terms and conditions
            _buildTermsCheckbox(context, fontSize),

            SizedBox(height: spacing * 1.5),

            // Sign up button
            _buildSignupButton(l10n, screenSize),

            SizedBox(height: spacing),

            // Login link
            _buildLoginLink(context, l10n, fontSize),
          ],
        ),
      ),
    );
  }

  // Build name field
  Widget _buildNameField(
    AppLocalizations l10n,
    double height,
    double fontSize,
  ) {
    return TextFormField(
      controller: _nameController,
      focusNode: _nameFocusNode,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      style: TextStyle(fontSize: fontSize),
      decoration: InputDecoration(
        labelText: l10n.name,
        prefixIcon: Icon(Icons.person_outline, size: fontSize * 1.3),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: height * 0.2,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorStyle: TextStyle(fontSize: fontSize * 0.75),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name';
        }
        if (value.length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_emailFocusNode);
      },
    );
  }

  // Build email field
  Widget _buildEmailField(
    AppLocalizations l10n,
    double height,
    double fontSize,
  ) {
    return TextFormField(
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
          vertical: height * 0.2,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorStyle: TextStyle(fontSize: fontSize * 0.75),
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
        FocusScope.of(context).requestFocus(_phoneFocusNode);
      },
    );
  }

  // Build phone field
  Widget _buildPhoneField(
    AppLocalizations l10n,
    double height,
    double fontSize,
  ) {
    return TextFormField(
      controller: _phoneController,
      focusNode: _phoneFocusNode,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      style: TextStyle(fontSize: fontSize),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        labelText: 'Phone Number',
        prefixIcon: Icon(Icons.phone_outlined, size: fontSize * 1.3),
        prefixText: '+91 ',
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: height * 0.2,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorStyle: TextStyle(fontSize: fontSize * 0.75),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your phone number';
        }
        if (value.length != 10) {
          return 'Please enter a valid 10-digit number';
        }
        return null;
      },
      onFieldSubmitted: (_) {
        _selectDate(context);
      },
    );
  }

  // Build date field
  Widget _buildDateField(
    BuildContext context,
    AppLocalizations l10n,
    double height,
    double fontSize,
  ) {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: Icon(Icons.calendar_today, size: fontSize * 1.3),
          suffixIcon: Icon(Icons.arrow_drop_down, size: fontSize * 1.3),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: height * 0.2,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          errorStyle: TextStyle(fontSize: fontSize * 0.75),
        ),
        child: Text(
          _selectedDate != null
              ? DateFormat('dd MMM yyyy').format(_selectedDate!)
              : 'Select your birth date',
          style: TextStyle(
            fontSize: fontSize,
            color:
                _selectedDate != null
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Theme.of(
                      context,
                    ).textTheme.bodyLarge?.color?.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  // Build gender selection
  Widget _buildGenderSelection(
    BuildContext context,
    AppLocalizations l10n,
    double height,
    double fontSize,
  ) {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: Icon(Icons.person_outline, size: fontSize * 1.3),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: height * 0.2,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorStyle: TextStyle(fontSize: fontSize * 0.75),
      ),
      style: TextStyle(
        fontSize: fontSize,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      items:
          ['Male', 'Female', 'Other'].map((gender) {
            return DropdownMenuItem(value: gender, child: Text(gender));
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your gender';
        }
        return null;
      },
    );
  }

  // Build password field
  Widget _buildPasswordField(
    AppLocalizations l10n,
    double height,
    double fontSize,
  ) {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
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
          vertical: height * 0.2,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorStyle: TextStyle(fontSize: fontSize * 0.75),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        if (_passwordStrength == PasswordStrength.weak) {
          return 'Password is too weak';
        }
        return null;
      },
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
      },
    );
  }

  // Build password strength indicator
  Widget _buildPasswordStrengthIndicator(ScreenSize screenSize) {
    final barHeight = screenSize == ScreenSize.mobile ? 4.0 : 6.0;
    final fontSize = screenSize == ScreenSize.mobile ? 12.0 : 14.0;

    Color strengthColor;
    String strengthText;
    double strengthValue;

    switch (_passwordStrength) {
      case PasswordStrength.weak:
        strengthColor = Colors.red;
        strengthText = 'Weak';
        strengthValue = 0.25;
        break;
      case PasswordStrength.fair:
        strengthColor = Colors.orange;
        strengthText = 'Fair';
        strengthValue = 0.5;
        break;
      case PasswordStrength.good:
        strengthColor = Colors.amber;
        strengthText = 'Good';
        strengthValue = 0.75;
        break;
      case PasswordStrength.strong:
        strengthColor = Colors.green;
        strengthText = 'Strong';
        strengthValue = 1.0;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(barHeight / 2),
                child: LinearProgressIndicator(
                  value: strengthValue,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                  minHeight: barHeight,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strengthText,
              style: TextStyle(
                fontSize: fontSize,
                color: strengthColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Use 8+ characters with uppercase, lowercase, numbers & symbols',
          style: TextStyle(
            fontSize: fontSize * 0.85,
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  // Build confirm password field
  Widget _buildConfirmPasswordField(
    AppLocalizations l10n,
    double height,
    double fontSize,
  ) {
    return TextFormField(
      controller: _confirmPasswordController,
      focusNode: _confirmPasswordFocusNode,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      style: TextStyle(fontSize: fontSize),
      decoration: InputDecoration(
        labelText: l10n.confirmPassword,
        prefixIcon: Icon(Icons.lock_outline, size: fontSize * 1.3),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            size: fontSize * 1.2,
          ),
          onPressed: () {
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
          },
          splashRadius: 20,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: height * 0.2,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorStyle: TextStyle(fontSize: fontSize * 0.75),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
      onFieldSubmitted: (_) => _handleSignup(),
    );
  }

  // Build terms checkbox
  Widget _buildTermsCheckbox(BuildContext context, double fontSize) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (value) {
              setState(() => _agreedToTerms = value ?? false);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _agreedToTerms = !_agreedToTerms);
            },
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: TextStyle(fontSize: fontSize * 0.9),
                children: [
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build signup button
  Widget _buildSignupButton(AppLocalizations l10n, ScreenSize screenSize) {
    final buttonHeight = _getButtonHeight(screenSize);
    final fontSize = _getFontSize(screenSize);

    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignup,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonHeight * 0.25),
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
                  l10n.signup,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  // Build login link
  Widget _buildLoginLink(
    BuildContext context,
    AppLocalizations l10n,
    double fontSize,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(fontSize: fontSize * 0.9),
        ),
        TextButton(
          onPressed:
              _isLoading
                  ? null
                  : () {
                    HapticFeedback.lightImpact();
                    context.go('/login');
                  },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: const Size(48, 48),
          ),
          child: Text(
            l10n.login,
            style: TextStyle(
              fontSize: fontSize * 0.9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  EdgeInsets _getResponsivePadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return const EdgeInsets.all(20);
      case ScreenSize.tablet:
        return const EdgeInsets.all(32);
      case ScreenSize.desktop:
        return const EdgeInsets.all(40);
    }
  }

  double _getFieldHeight(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 52; // Compact but accessible
      case ScreenSize.tablet:
        return 56;
      case ScreenSize.desktop:
        return 60;
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
        return 14;
      case ScreenSize.tablet:
        return 15;
      case ScreenSize.desktop:
        return 16;
    }
  }

  double _getSpacing(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 14;
      case ScreenSize.tablet:
        return 16;
      case ScreenSize.desktop:
        return 20;
    }
  }
}
