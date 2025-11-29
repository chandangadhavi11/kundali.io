import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../../core/providers/kundli_provider.dart';
import '../../../../shared/models/kundali_data_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../modern_kundli_display/modern_kundli_display_screen.dart';

// Responsive Modern Kundli Input Screen with Material 3
// Full implementation with floating labels, adaptive stepper, and responsive design

// Breakpoints
class KundliInputBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double ultraWide = 1800;
}

// Screen sizes
enum ScreenSize { mobile, tablet, desktop, ultraWide }

// Stepper orientation
enum StepperOrientation { vertical, horizontal }

// Location search result
class LocationResult {
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String timezone;

  LocationResult({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });
}

class ModernKundliInputResponsive extends StatefulWidget {
  const ModernKundliInputResponsive({super.key});

  @override
  State<ModernKundliInputResponsive> createState() =>
      _ModernKundliInputResponsiveState();
}

class _ModernKundliInputResponsiveState
    extends State<ModernKundliInputResponsive>
    with TickerProviderStateMixin {
  // Form key and controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  final _scrollController = ScrollController();

  // Focus nodes for floating labels
  final _nameFocusNode = FocusNode();
  final _placeFocusNode = FocusNode();

  // Stepper state
  int _currentStep = 0;
  StepperOrientation _stepperOrientation = StepperOrientation.vertical;

  // Form data
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedGender = 'Male';
  double? _latitude;
  double? _longitude;
  String _timezone = 'IST';
  ChartStyle _chartStyle = ChartStyle.northIndian;
  String _language = 'English';
  bool _isPrimary = false;

  // UI State
  // ignore: unused_field
  final bool _isSearchingLocation = false;
  final List<LocationResult> _locationResults = [];
  bool _showLocationDropdown = false;
  final _locationOverlayController = OverlayPortalController();

  // Animation controllers
  late AnimationController _formAnimationController;
  late AnimationController _buttonAnimationController;
  late AnimationController _stepperAnimationController;
  late AnimationController _floatingLabelController;
  late AnimationController _validationAnimationController;

  // Animations
  // ignore: unused_field
  late List<Animation<double>> _fieldAnimations;
  late Animation<double> _buttonScaleAnimation;
  // ignore: unused_field
  late Animation<double> _stepperSlideAnimation;
  late Animation<double> _floatingLabelAnimation;
  // ignore: unused_field
  late Animation<double> _validationShakeAnimation;

  // Responsive values
  ScreenSize _currentScreenSize = ScreenSize.mobile;
  double _animationSpeed = 1.0;
  bool _supportsHaptics = true;

  @override
  void initState() {
    super.initState();
    _checkHapticSupport();
    _initAnimations();
    _loadDefaults();
    _setupFocusListeners();
  }

  void _checkHapticSupport() {
    // Check if platform supports haptic feedback
    _supportsHaptics =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
  }

  void _initAnimations() {
    // Get adaptive animation speed based on device
    _animationSpeed = _getAdaptiveAnimationSpeed();

    // Form field animations
    _formAnimationController = AnimationController(
      duration: Duration(milliseconds: (1500 * _animationSpeed).round()),
      vsync: this,
    );

    // Create staggered animations for form fields
    _fieldAnimations = List.generate(10, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _formAnimationController,
          curve: Interval(
            index * 0.08,
            (0.3 + index * 0.08).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    // Button animation
    _buttonAnimationController = AnimationController(
      duration: Duration(milliseconds: (600 * _animationSpeed).round()),
      vsync: this,
    );

    _buttonScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Stepper animation
    _stepperAnimationController = AnimationController(
      duration: Duration(milliseconds: (400 * _animationSpeed).round()),
      vsync: this,
    );

    _stepperSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stepperAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Floating label animation
    _floatingLabelController = AnimationController(
      duration: Duration(milliseconds: (200 * _animationSpeed).round()),
      vsync: this,
    );

    _floatingLabelAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingLabelController, curve: Curves.easeOut),
    );

    // Validation animation
    _validationAnimationController = AnimationController(
      duration: Duration(milliseconds: (500 * _animationSpeed).round()),
      vsync: this,
    );

    _validationShakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _validationAnimationController,
        curve: Curves.elasticIn,
      ),
    );

    // Start animations
    _formAnimationController.forward();
    _stepperAnimationController.forward();
    Future.delayed(Duration(milliseconds: (800 * _animationSpeed).round()), () {
      if (mounted) {
        _buttonAnimationController.forward();
      }
    });
  }

  void _setupFocusListeners() {
    // Setup floating label animations
    _nameFocusNode.addListener(() {
      if (_nameFocusNode.hasFocus || _nameController.text.isNotEmpty) {
        _floatingLabelController.forward();
      } else {
        _floatingLabelController.reverse();
      }
    });

    _placeFocusNode.addListener(() {
      if (_placeFocusNode.hasFocus || _placeController.text.isNotEmpty) {
        _floatingLabelController.forward();
      } else {
        _floatingLabelController.reverse();
      }
    });
  }

  void _loadDefaults() {
    final provider = context.read<KundliProvider>();
    setState(() {
      _chartStyle = provider.defaultChartStyle;
      _language = provider.defaultLanguage;
    });
  }

  // Get screen size
  ScreenSize _getScreenSize(double width) {
    if (width < KundliInputBreakpoints.mobile) return ScreenSize.mobile;
    if (width < KundliInputBreakpoints.tablet) return ScreenSize.tablet;
    if (width < KundliInputBreakpoints.desktop) return ScreenSize.desktop;
    return ScreenSize.ultraWide;
  }

  // Get adaptive animation speed
  double _getAdaptiveAnimationSpeed() {
    // Slower animations on larger screens
    switch (_currentScreenSize) {
      case ScreenSize.mobile:
        return 1.0;
      case ScreenSize.tablet:
        return 0.9;
      case ScreenSize.desktop:
        return 0.8;
      case ScreenSize.ultraWide:
        return 0.7;
    }
  }

  // Get stepper orientation
  StepperOrientation _getStepperOrientation(
    ScreenSize screenSize,
    bool isLandscape,
  ) {
    if (screenSize == ScreenSize.mobile && !isLandscape) {
      return StepperOrientation.vertical;
    }
    return StepperOrientation.horizontal;
  }

  // Get Material 3 spacing
  double _getSpacing(ScreenSize screenSize, String type) {
    switch (type) {
      case 'small':
        return screenSize == ScreenSize.mobile ? 8 : 12;
      case 'medium':
        return screenSize == ScreenSize.mobile ? 16 : 20;
      case 'large':
        return screenSize == ScreenSize.mobile ? 24 : 32;
      case 'xlarge':
        return screenSize == ScreenSize.mobile ? 32 : 48;
      default:
        return 16;
    }
  }

  // Adaptive haptic feedback
  void _haptic(String type) {
    if (!_supportsHaptics) return;

    switch (type) {
      case 'light':
        HapticFeedback.lightImpact();
        break;
      case 'medium':
        HapticFeedback.mediumImpact();
        break;
      case 'heavy':
        HapticFeedback.heavyImpact();
        break;
      case 'selection':
        HapticFeedback.selectionClick();
        break;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    _scrollController.dispose();
    _nameFocusNode.dispose();
    _placeFocusNode.dispose();
    _formAnimationController.dispose();
    _buttonAnimationController.dispose();
    _stepperAnimationController.dispose();
    _floatingLabelController.dispose();
    _validationAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final screenSize = _getScreenSize(screenWidth);
        final isLandscape = screenWidth > screenHeight;

        // Update current screen size
        if (_currentScreenSize != screenSize) {
          _currentScreenSize = screenSize;
          // Update animation speeds
          _animationSpeed = _getAdaptiveAnimationSpeed();
        }

        // Update stepper orientation
        final stepperOrientation = _getStepperOrientation(
          screenSize,
          isLandscape,
        );
        if (_stepperOrientation != stepperOrientation) {
          _stepperOrientation = stepperOrientation;
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: _buildResponsiveLayout(
            context,
            screenSize,
            screenWidth,
            isLandscape,
          ),
        );
      },
    );
  }

  // Build responsive layout
  Widget _buildResponsiveLayout(
    BuildContext context,
    ScreenSize screenSize,
    double screenWidth,
    bool isLandscape,
  ) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return _buildMobileLayout(context, screenSize);
      case ScreenSize.tablet:
        return _buildTabletLayout(context, screenSize, isLandscape);
      case ScreenSize.desktop:
        return _buildDesktopLayout(context, screenSize);
      case ScreenSize.ultraWide:
        return _buildUltraWideLayout(context, screenSize);
    }
  }

  // Mobile layout
  Widget _buildMobileLayout(BuildContext context, ScreenSize screenSize) {
    final spacing = _getSpacing(screenSize, 'medium');

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App bar
        _buildSliverAppBar(context, screenSize),

        // Content
        SliverPadding(
          padding: EdgeInsets.all(spacing),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Stepper
              _buildVerticalStepper(context, screenSize),

              SizedBox(height: spacing),

              // Form content
              _buildStepContent(context, screenSize),

              SizedBox(height: _getSpacing(screenSize, 'large')),

              // Actions
              _buildActions(context, screenSize),
            ]),
          ),
        ),
      ],
    );
  }

  // Tablet layout
  Widget _buildTabletLayout(
    BuildContext context,
    ScreenSize screenSize,
    bool isLandscape,
  ) {
    final spacing = _getSpacing(screenSize, 'medium');

    if (isLandscape) {
      // Horizontal layout with sidebar
      return Row(
        children: [
          // Sidebar with stepper
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                right: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Column(
              children: [
                // Header
                _buildCompactHeader(context, screenSize),

                // Vertical stepper
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(spacing),
                    child: _buildVerticalStepper(context, screenSize),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(spacing * 1.5),
                    child: _buildStepContent(context, screenSize),
                  ),
                ),

                // Actions
                Container(
                  padding: EdgeInsets.all(spacing),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      top: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: _buildActions(context, screenSize),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Vertical layout
      return CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App bar
          _buildSliverAppBar(context, screenSize),

          // Content
          SliverPadding(
            padding: EdgeInsets.all(spacing * 1.5),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Horizontal stepper
                _buildHorizontalStepper(context, screenSize),

                SizedBox(height: spacing * 2),

                // Form content in card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(spacing * 1.5),
                    child: _buildStepContent(context, screenSize),
                  ),
                ),

                SizedBox(height: spacing * 2),

                // Actions
                _buildActions(context, screenSize),
              ]),
            ),
          ),
        ],
      );
    }
  }

  // Desktop layout
  Widget _buildDesktopLayout(BuildContext context, ScreenSize screenSize) {
    final spacing = _getSpacing(screenSize, 'large');

    return Row(
      children: [
        // Left sidebar with stepper
        Container(
          width: 320,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.05),
                Theme.of(context).cardColor,
              ],
            ),
            border: Border(
              right: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Column(
            children: [
              // Header
              _buildDesktopHeader(context, screenSize),

              // Stepper
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(spacing),
                  child: _buildVerticalStepper(context, screenSize),
                ),
              ),

              // Progress
              _buildProgressIndicator(context, screenSize),
            ],
          ),
        ),

        // Main content
        Expanded(
          child: Column(
            children: [
              // Content
              Expanded(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    padding: EdgeInsets.all(spacing),
                    child: SingleChildScrollView(
                      child: _buildStepContent(context, screenSize),
                    ),
                  ),
                ),
              ),

              // Actions
              Container(
                padding: EdgeInsets.all(spacing),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: _buildActions(context, screenSize),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Ultra-wide layout
  Widget _buildUltraWideLayout(BuildContext context, ScreenSize screenSize) {
    final spacing = _getSpacing(screenSize, 'xlarge');

    return Row(
      children: [
        // Left panel - Stepper
        Container(
          width: 400,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.08),
                Theme.of(context).cardColor,
              ],
            ),
          ),
          child: Column(
            children: [
              _buildDesktopHeader(context, screenSize),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(spacing),
                  child: _buildVerticalStepper(context, screenSize),
                ),
              ),
              _buildProgressIndicator(context, screenSize),
            ],
          ),
        ),

        // Center content
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: spacing * 2),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(vertical: spacing),
                        child: _buildStepContent(context, screenSize),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: spacing),
                      child: _buildActions(context, screenSize),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Right panel - Preview
        Container(
          width: 350,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.5),
            border: Border(
              left: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: _buildPreviewPanel(context, screenSize),
        ),
      ],
    );
  }

  // Build sliver app bar
  Widget _buildSliverAppBar(BuildContext context, ScreenSize screenSize) {
    final isCompact = screenSize == ScreenSize.mobile;

    return SliverAppBar(
      expandedHeight: isCompact ? 180 : 220,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Generate Kundali',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isCompact ? 18 : 20,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Pattern
              CustomPaint(
                size: Size.infinite,
                painter: ZodiacPatternPainter(
                  color: AppColors.primary.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build compact header
  Widget _buildCompactHeader(BuildContext context, ScreenSize screenSize) {
    return Container(
      padding: EdgeInsets.all(_getSpacing(screenSize, 'medium')),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Text(
            'Kundali Generator',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  // Build desktop header
  Widget _buildDesktopHeader(BuildContext context, ScreenSize screenSize) {
    return Container(
      padding: EdgeInsets.all(_getSpacing(screenSize, 'large')),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kundali Generator',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headlineSmall?.color,
                      ),
                    ),
                    Text(
                      'Create your personalized birth chart',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build progress indicator
  Widget _buildProgressIndicator(BuildContext context, ScreenSize screenSize) {
    final progress = (_currentStep + 1) / 3;

    return Container(
      padding: EdgeInsets.all(_getSpacing(screenSize, 'medium')),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  // Build vertical stepper
  Widget _buildVerticalStepper(BuildContext context, ScreenSize screenSize) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(
          context,
        ).colorScheme.copyWith(primary: AppColors.primary),
      ),
      child: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) {
          setState(() {
            _currentStep = step;
          });
          _haptic('selection');
          _stepperAnimationController.forward(from: 0);
        },
        onStepContinue: _handleStepContinue,
        onStepCancel: _handleStepCancel,
        controlsBuilder: (context, details) {
          return const SizedBox.shrink();
        },
        steps: [
          Step(
            title: Text(
              'Personal Info',
              style: TextStyle(
                fontWeight:
                    _currentStep == 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            content: const SizedBox.shrink(),
            isActive: _currentStep == 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text(
              'Birth Details',
              style: TextStyle(
                fontWeight:
                    _currentStep == 1 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            content: const SizedBox.shrink(),
            isActive: _currentStep == 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text(
              'Preferences',
              style: TextStyle(
                fontWeight:
                    _currentStep == 2 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            content: const SizedBox.shrink(),
            isActive: _currentStep == 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          ),
        ],
      ),
    );
  }

  // Build horizontal stepper
  Widget _buildHorizontalStepper(BuildContext context, ScreenSize screenSize) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: _getSpacing(screenSize, 'medium'),
      ),
      child: Row(
        children: [
          for (int i = 0; i < 3; i++) ...[
            _buildHorizontalStep(context, i, _getStepTitle(i), screenSize),
            if (i < 2)
              Expanded(
                child: Container(
                  height: 2,
                  color:
                      i < _currentStep
                          ? AppColors.primary
                          : Theme.of(context).dividerColor,
                ),
              ),
          ],
        ],
      ),
    );
  }

  // Build horizontal step
  Widget _buildHorizontalStep(
    BuildContext context,
    int index,
    String title,
    ScreenSize screenSize,
  ) {
    final isActive = index == _currentStep;
    final isCompleted = index < _currentStep;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentStep = index;
        });
        _haptic('selection');
        _stepperAnimationController.forward(from: 0);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: (300 * _animationSpeed).round()),
        padding: EdgeInsets.all(_getSpacing(screenSize, 'small')),
        decoration: BoxDecoration(
          color:
              isActive
                  ? AppColors.primary
                  : isCompleted
                  ? AppColors.primary.withOpacity(0.3)
                  : Theme.of(context).cardColor,
          shape: BoxShape.circle,
          border: Border.all(
            color:
                isActive || isCompleted
                    ? AppColors.primary
                    : Theme.of(context).dividerColor,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    isActive || isCompleted ? Colors.white : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child:
                    isCompleted
                        ? Icon(Icons.check, color: AppColors.primary, size: 20)
                        : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color:
                                isActive
                                    ? AppColors.primary
                                    : Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color:
                    isActive
                        ? AppColors.primary
                        : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build step content
  Widget _buildStepContent(BuildContext context, ScreenSize screenSize) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: (400 * _animationSpeed).round()),
      child: _buildCurrentStepContent(context, screenSize),
    );
  }

  // Build current step content
  Widget _buildCurrentStepContent(BuildContext context, ScreenSize screenSize) {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep(context, screenSize);
      case 1:
        return _buildBirthDetailsStep(context, screenSize);
      case 2:
        return _buildPreferencesStep(context, screenSize);
      default:
        return const SizedBox.shrink();
    }
  }

  // Build personal info step
  Widget _buildPersonalInfoStep(BuildContext context, ScreenSize screenSize) {
    final spacing = _getSpacing(screenSize, 'medium');
    final useColumns = screenSize != ScreenSize.mobile;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: spacing),

          // Name field with floating label
          _buildFloatingLabelField(
            context: context,
            controller: _nameController,
            focusNode: _nameFocusNode,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                _showValidationError('Please enter a name');
                return 'Please enter a name';
              }
              return null;
            },
            screenSize: screenSize,
          ),

          SizedBox(height: spacing * 1.5),

          // Gender selection
          Text('Gender', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: spacing / 2),

          if (useColumns)
            Row(
              children: [
                for (final gender in ['Male', 'Female', 'Other']) ...[
                  Expanded(
                    child: _buildGenderOption(context, gender, screenSize),
                  ),
                  if (gender != 'Other') SizedBox(width: spacing),
                ],
              ],
            )
          else
            Column(
              children: [
                for (final gender in ['Male', 'Female', 'Other']) ...[
                  _buildGenderOption(context, gender, screenSize),
                  if (gender != 'Other') SizedBox(height: spacing / 2),
                ],
              ],
            ),
        ],
      ),
    );
  }

  // Build birth details step
  Widget _buildBirthDetailsStep(BuildContext context, ScreenSize screenSize) {
    final spacing = _getSpacing(screenSize, 'medium');
    final useColumns = screenSize != ScreenSize.mobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Birth Details', style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: spacing),

        // Date and time
        if (useColumns)
          Row(
            children: [
              Expanded(child: _buildDatePicker(context, screenSize)),
              SizedBox(width: spacing),
              Expanded(child: _buildTimePicker(context, screenSize)),
            ],
          )
        else
          Column(
            children: [
              _buildDatePicker(context, screenSize),
              SizedBox(height: spacing),
              _buildTimePicker(context, screenSize),
            ],
          ),

        SizedBox(height: spacing * 1.5),

        // Location field with autocomplete
        _buildLocationField(context, screenSize),
      ],
    );
  }

  // Build preferences step
  Widget _buildPreferencesStep(BuildContext context, ScreenSize screenSize) {
    final spacing = _getSpacing(screenSize, 'medium');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preferences', style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: spacing),

        // Chart style
        Text('Chart Style', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: spacing / 2),
        _buildChartStyleSelection(context, screenSize),

        SizedBox(height: spacing * 1.5),

        // Language
        Text('Language', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: spacing / 2),
        _buildLanguageSelection(context, screenSize),

        SizedBox(height: spacing * 1.5),

        // Primary switch
        _buildPrimarySwitch(context, screenSize),
      ],
    );
  }

  // Build floating label field
  Widget _buildFloatingLabelField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?)? validator,
    required ScreenSize screenSize,
  }) {
    final spacing = _getSpacing(screenSize, 'small');

    return AnimatedBuilder(
      animation: _floatingLabelAnimation,
      builder: (context, child) {
        final hasFocus = focusNode.hasFocus;
        final hasText = controller.text.isNotEmpty;
        final shouldFloat = hasFocus || hasText;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  hasFocus ? AppColors.primary : Theme.of(context).dividerColor,
              width: hasFocus ? 2 : 1,
            ),
            boxShadow:
                hasFocus
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: spacing + 40,
                  right: spacing,
                  top: shouldFloat ? 24 : 0,
                  bottom: spacing,
                ),
                child: TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: shouldFloat ? hint : '',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: validator,
                ),
              ),

              // Floating label
              AnimatedPositioned(
                duration: Duration(
                  milliseconds: (200 * _animationSpeed).round(),
                ),
                left: spacing + 40,
                top: shouldFloat ? 4 : 16,
                child: AnimatedDefaultTextStyle(
                  duration: Duration(
                    milliseconds: (200 * _animationSpeed).round(),
                  ),
                  style: TextStyle(
                    fontSize: shouldFloat ? 12 : 16,
                    color:
                        hasFocus
                            ? AppColors.primary
                            : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight:
                        shouldFloat ? FontWeight.w500 : FontWeight.normal,
                  ),
                  child: Text(label),
                ),
              ),

              // Icon
              Positioned(
                left: spacing,
                top: shouldFloat ? 20 : 14,
                child: Icon(
                  icon,
                  color:
                      hasFocus
                          ? AppColors.primary
                          : Theme.of(context).iconTheme.color?.withOpacity(0.5),
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build gender option
  Widget _buildGenderOption(
    BuildContext context,
    String gender,
    ScreenSize screenSize,
  ) {
    final isSelected = _selectedGender == gender;
    final icon =
        gender == 'Male'
            ? Icons.male
            : gender == 'Female'
            ? Icons.female
            : Icons.transgender;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
        _haptic('selection');
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: (200 * _animationSpeed).round()),
        padding: EdgeInsets.all(_getSpacing(screenSize, 'medium')),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? AppColors.primary : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              gender,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build date picker
  Widget _buildDatePicker(BuildContext context, ScreenSize screenSize) {
    return GestureDetector(
      onTap: () async {
        _haptic('light');
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(primary: AppColors.primary),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
          _haptic('selection');
        }
      },
      child: Container(
        padding: EdgeInsets.all(_getSpacing(screenSize, 'medium')),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Birth Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build time picker
  Widget _buildTimePicker(BuildContext context, ScreenSize screenSize) {
    return GestureDetector(
      onTap: () async {
        _haptic('light');
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(primary: AppColors.primary),
              ),
              child: child!,
            );
          },
        );
        if (time != null) {
          setState(() {
            _selectedTime = time;
          });
          _haptic('selection');
        }
      },
      child: Container(
        padding: EdgeInsets.all(_getSpacing(screenSize, 'medium')),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Birth Time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedTime.format(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build location field with autocomplete
  Widget _buildLocationField(BuildContext context, ScreenSize screenSize) {
    return OverlayPortal(
      controller: _locationOverlayController,
      overlayChildBuilder: (context) {
        return _buildLocationDropdown(context, screenSize);
      },
      child: _buildFloatingLabelField(
        context: context,
        controller: _placeController,
        focusNode: _placeFocusNode,
        label: 'Birth Place',
        hint: 'Search for city',
        icon: Icons.location_on_outlined,
        validator: (value) {
          if (value == null || value.isEmpty) {
            _showValidationError('Please enter birth place');
            return 'Please enter birth place';
          }
          if (_latitude == null || _longitude == null) {
            _showValidationError('Please select a valid location');
            return 'Please select a valid location';
          }
          return null;
        },
        screenSize: screenSize,
      ),
    );
  }

  // Build location dropdown
  Widget _buildLocationDropdown(BuildContext context, ScreenSize screenSize) {
    if (!_showLocationDropdown || _locationResults.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get the render box for positioning
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return Positioned(
      left: offset.dx,
      top: offset.dy + size.height + 4,
      width: size.width,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _locationResults.length,
            itemBuilder: (context, index) {
              final location = _locationResults[index];
              return ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 20,
                ),
                title: Text(location.name),
                subtitle: Text(
                  location.description,
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () {
                  _selectLocation(location);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Build chart style selection
  Widget _buildChartStyleSelection(
    BuildContext context,
    ScreenSize screenSize,
  ) {
    return Wrap(
      spacing: _getSpacing(screenSize, 'small'),
      runSpacing: _getSpacing(screenSize, 'small'),
      children:
          ChartStyle.values.map((style) {
            final isSelected = _chartStyle == style;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _chartStyle = style;
                });
                _haptic('selection');
              },
              child: AnimatedContainer(
                duration: Duration(
                  milliseconds: (200 * _animationSpeed).round(),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: _getSpacing(screenSize, 'medium'),
                  vertical: _getSpacing(screenSize, 'small'),
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.primary
                          : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isSelected
                            ? AppColors.primary
                            : Theme.of(context).dividerColor,
                  ),
                ),
                child: Text(
                  style.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  // Build language selection
  Widget _buildLanguageSelection(BuildContext context, ScreenSize screenSize) {
    final languages = ['English', 'Hindi', 'Sanskrit'];

    return Wrap(
      spacing: _getSpacing(screenSize, 'small'),
      runSpacing: _getSpacing(screenSize, 'small'),
      children:
          languages.map((lang) {
            final isSelected = _language == lang;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _language = lang;
                });
                _haptic('selection');
              },
              child: AnimatedContainer(
                duration: Duration(
                  milliseconds: (200 * _animationSpeed).round(),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: _getSpacing(screenSize, 'medium'),
                  vertical: _getSpacing(screenSize, 'small'),
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.primary
                          : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isSelected
                            ? AppColors.primary
                            : Theme.of(context).dividerColor,
                  ),
                ),
                child: Text(
                  lang,
                  style: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  // Build primary switch
  Widget _buildPrimarySwitch(BuildContext context, ScreenSize screenSize) {
    return Container(
      padding: EdgeInsets.all(_getSpacing(screenSize, 'medium')),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(Icons.star_outline, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Set as Primary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Make this your default Kundali',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isPrimary,
            onChanged: (value) {
              setState(() {
                _isPrimary = value;
              });
              _haptic('selection');
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // Build preview panel
  Widget _buildPreviewPanel(BuildContext context, ScreenSize screenSize) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(_getSpacing(screenSize, 'large')),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.preview, color: AppColors.primary),
              const SizedBox(width: 12),
              Text('Preview', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(_getSpacing(screenSize, 'large')),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPreviewSection(
                  'Name',
                  _nameController.text.isEmpty
                      ? 'Not provided'
                      : _nameController.text,
                ),
                _buildPreviewSection('Gender', _selectedGender),
                _buildPreviewSection(
                  'Birth Date',
                  DateFormat('dd MMM yyyy').format(_selectedDate),
                ),
                _buildPreviewSection(
                  'Birth Time',
                  _selectedTime.format(context),
                ),
                _buildPreviewSection(
                  'Birth Place',
                  _placeController.text.isEmpty
                      ? 'Not provided'
                      : _placeController.text,
                ),
                _buildPreviewSection('Chart Style', _chartStyle.displayName),
                _buildPreviewSection('Language', _language),
                _buildPreviewSection('Primary', _isPrimary ? 'Yes' : 'No'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Build preview section
  Widget _buildPreviewSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Build actions
  Widget _buildActions(BuildContext context, ScreenSize screenSize) {
    final canGoBack = _currentStep > 0;
    final isLastStep = _currentStep == 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (canGoBack)
          TextButton.icon(
            onPressed: _handleStepCancel,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          )
        else
          const SizedBox.shrink(),

        ScaleTransition(
          scale: _buttonScaleAnimation,
          child: ElevatedButton.icon(
            onPressed: isLastStep ? _generateKundali : _handleStepContinue,
            icon: Icon(isLastStep ? Icons.auto_awesome : Icons.arrow_forward),
            label: Text(
              isLastStep ? 'Generate Kundali' : 'Continue',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: _getSpacing(screenSize, 'large'),
                vertical: _getSpacing(screenSize, 'medium'),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Personal';
      case 1:
        return 'Birth';
      case 2:
        return 'Preferences';
      default:
        return '';
    }
  }

  void _handleStepContinue() {
    if (_currentStep < 2) {
      // Validate current step
      if (_validateStep()) {
        setState(() {
          _currentStep++;
        });
        _haptic('medium');
        _stepperAnimationController.forward(from: 0);
      }
    }
  }

  void _handleStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _haptic('light');
      _stepperAnimationController.forward(from: 0);
    }
  }

  bool _validateStep() {
    switch (_currentStep) {
      case 0:
        if (_nameController.text.isEmpty) {
          _showValidationError('Please enter your name');
          return false;
        }
        return true;
      case 1:
        if (_placeController.text.isEmpty) {
          _showValidationError('Please enter birth place');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showValidationError(String message) {
    _haptic('heavy');
    _validationAnimationController.forward(from: 0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _selectLocation(LocationResult location) {
    setState(() {
      _placeController.text = location.name;
      _latitude = location.latitude;
      _longitude = location.longitude;
      _timezone = location.timezone;
      _showLocationDropdown = false;
    });
    _locationOverlayController.hide();
    _haptic('selection');
  }

  void _generateKundali() {
    if (!_validateStep()) return;

    _haptic('medium');

    // Create Kundali data using factory constructor that calculates everything
    final kundaliData = KundaliData.fromBirthDetails(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      birthDateTime: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      birthPlace: _placeController.text,
      latitude: _latitude ?? 28.6139, // Default to Delhi if not selected
      longitude: _longitude ?? 77.2090,
      timezone: _timezone,
      gender: _selectedGender,
      chartStyle: _chartStyle,
      language: _language,
      isPrimary: _isPrimary,
    );

    // Save to provider
    final provider = context.read<KundliProvider>();
    provider.setCurrentKundali(kundaliData);

    // Navigate to display screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ModernKundliDisplayScreen(kundaliData: kundaliData),
      ),
    );
  }
}

// Zodiac pattern painter
class ZodiacPatternPainter extends CustomPainter {
  final Color color;

  ZodiacPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    // Draw zodiac symbols pattern
    // const symbols = ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'];
    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < 12; i++) {
      final x = (size.width / 12) * i + 20;
      final y = 50 + (random % 30);

      canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), 15, paint);
    }
  }

  @override
  bool shouldRepaint(ZodiacPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
