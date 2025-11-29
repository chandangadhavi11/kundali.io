import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../../shared/models/kundali_data_model.dart';
import '../../../../core/constants/app_colors.dart';

// Responsive Kundli Input Screen Demo
// Full implementation would be in kundli_input_screen.dart

// Breakpoints
class KundliBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

enum ScreenSize { mobile, tablet, desktop }

enum FormLayout { single, twoColumn, multiColumn }

// Form steps
enum FormStep { personal, birthDetails, preferences, review }

class ResponsiveKundliInput extends StatefulWidget {
  const ResponsiveKundliInput({super.key});

  @override
  State<ResponsiveKundliInput> createState() => _ResponsiveKundliInputState();
}

class _ResponsiveKundliInputState extends State<ResponsiveKundliInput>
    with TickerProviderStateMixin {
  // Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();

  // Focus nodes for keyboard navigation
  final _nameFocusNode = FocusNode();
  final _placeFocusNode = FocusNode();

  // Form state
  FormStep _currentStep = FormStep.personal;
  final Map<FormStep, bool> _stepCompleted = {};

  // Data
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedGender = 'Male';
  double? _latitude;
  // ignore: unused_field
  double? _longitude;
  bool _isSearchingLocation = false;

  // Preferences
  ChartStyle _chartStyle = ChartStyle.northIndian;
  String _language = 'English';
  bool _isPrimary = false;

  // Animation
  late AnimationController _stepController;
  late Animation<double> _stepAnimation;

  @override
  void initState() {
    super.initState();
    _stepController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _stepAnimation = CurvedAnimation(
      parent: _stepController,
      curve: Curves.easeInOut,
    );
    _stepController.forward();

    // Setup keyboard navigation for desktop
    _setupKeyboardNavigation();
  }

  void _setupKeyboardNavigation() {
    // Tab navigation between fields
    RawKeyboard.instance.addListener((event) {
      if (event is RawKeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.tab) {
          // Handle tab navigation
        }
      }
    });
  }

  ScreenSize _getScreenSize(double width) {
    if (width < KundliBreakpoints.mobile) return ScreenSize.mobile;
    if (width < KundliBreakpoints.tablet) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  FormLayout _getFormLayout(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return FormLayout.single;
      case ScreenSize.tablet:
        return FormLayout.twoColumn;
      case ScreenSize.desktop:
        return FormLayout.multiColumn;
    }
  }

  // Get minimum touch target size
  double _getTouchTarget(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 48.0; // Material minimum
      case ScreenSize.tablet:
        return 44.0;
      case ScreenSize.desktop:
        return 40.0; // Mouse optimized
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    _nameFocusNode.dispose();
    _placeFocusNode.dispose();
    _stepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenSize = _getScreenSize(screenWidth);
        final formLayout = _getFormLayout(screenSize);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Generate Kundali'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: _buildResponsiveBody(screenSize, formLayout),
        );
      },
    );
  }

  Widget _buildResponsiveBody(ScreenSize screenSize, FormLayout layout) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return _buildMobileLayout();
      case ScreenSize.tablet:
        return _buildTabletLayout();
      case ScreenSize.desktop:
        return _buildDesktopLayout();
    }
  }

  // Mobile Layout - Multi-step form
  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Progress indicator
        _buildProgressIndicator(ScreenSize.mobile),

        // Form content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _buildStepContent(ScreenSize.mobile),
              ),
            ),
          ),
        ),

        // Navigation buttons
        _buildNavigationButtons(ScreenSize.mobile),
      ],
    );
  }

  // Tablet Layout - Two column with sidebar
  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Sidebar with progress
        Container(
          width: 240,
          color: Colors.grey[100],
          child: _buildVerticalProgress(),
        ),

        // Main content
        Expanded(
          child: Column(
            children: [
              // Form content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: _buildStepContent(ScreenSize.tablet),
                  ),
                ),
              ),

              // Navigation
              _buildNavigationButtons(ScreenSize.tablet),
            ],
          ),
        ),
      ],
    );
  }

  // Desktop Layout - Multi-column form
  Widget _buildDesktopLayout() {
    return Column(
      children: [
        // Header with progress
        _buildDesktopHeader(),

        // Form content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Form(key: _formKey, child: _buildAllStepsDesktop()),
              ),
            ),
          ),
        ),

        // Generate button
        _buildDesktopActions(),
      ],
    );
  }

  // Progress indicator
  Widget _buildProgressIndicator(ScreenSize screenSize) {
    final steps = FormStep.values;
    final currentIndex = steps.indexOf(_currentStep);
    final progress = (currentIndex + 1) / steps.length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                steps.map((step) {
                  final index = steps.indexOf(step);
                  final isActive = index <= currentIndex;
                  final isCompleted = _stepCompleted[step] ?? false;

                  return _buildStepIndicator(
                    index + 1,
                    _getStepTitle(step),
                    isActive,
                    isCompleted,
                    screenSize == ScreenSize.mobile,
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  // Vertical progress for tablet
  Widget _buildVerticalProgress() {
    final steps = FormStep.values;

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final isActive = index == steps.indexOf(_currentStep);
        final isCompleted = _stepCompleted[step] ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              _buildStepCircle(index + 1, isActive, isCompleted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStepTitle(step),
                      style: TextStyle(
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? AppColors.primary : Colors.grey[700],
                      ),
                    ),
                    Text(
                      _getStepDescription(step),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Desktop header
  Widget _buildDesktopHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Generate Kundali',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton.icon(
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Draft'),
            onPressed: () {
              // Save draft functionality
            },
          ),
        ],
      ),
    );
  }

  // Step indicator
  Widget _buildStepIndicator(
    int number,
    String title,
    bool isActive,
    bool isCompleted,
    bool compact,
  ) {
    return Column(
      children: [
        _buildStepCircle(number, isActive, isCompleted),
        if (!compact) ...[
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? AppColors.primary : Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStepCircle(int number, bool isActive, bool isCompleted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isCompleted
                ? Colors.green
                : (isActive ? AppColors.primary : Colors.grey[300]),
      ),
      child: Center(
        child:
            isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                  number.toString(),
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  // Build step content
  Widget _buildStepContent(ScreenSize screenSize) {
    switch (_currentStep) {
      case FormStep.personal:
        return _buildPersonalStep(screenSize);
      case FormStep.birthDetails:
        return _buildBirthDetailsStep(screenSize);
      case FormStep.preferences:
        return _buildPreferencesStep(screenSize);
      case FormStep.review:
        return _buildReviewStep(screenSize);
    }
  }

  // Personal information step
  Widget _buildPersonalStep(ScreenSize screenSize) {
    final touchTarget = _getTouchTarget(screenSize);

    return FadeTransition(
      opacity: _stepAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Name field
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Gender selection
          const Text('Gender', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children:
                ['Male', 'Female', 'Other'].map((gender) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGender = gender;
                          });
                          HapticFeedback.lightImpact();
                        },
                        child: Container(
                          height: touchTarget,
                          decoration: BoxDecoration(
                            color:
                                _selectedGender == gender
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.transparent,
                            border: Border.all(
                              color:
                                  _selectedGender == gender
                                      ? AppColors.primary
                                      : Colors.grey[400]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              gender,
                              style: TextStyle(
                                color:
                                    _selectedGender == gender
                                        ? AppColors.primary
                                        : Colors.grey[700],
                                fontWeight:
                                    _selectedGender == gender
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  // Birth details step
  Widget _buildBirthDetailsStep(ScreenSize screenSize) {
    final useColumns = screenSize != ScreenSize.mobile;

    return FadeTransition(
      opacity: _stepAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Birth Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Date and time pickers
          if (useColumns)
            Row(
              children: [
                Expanded(child: _buildDatePicker(screenSize)),
                const SizedBox(width: 16),
                Expanded(child: _buildTimePicker(screenSize)),
              ],
            )
          else
            Column(
              children: [
                _buildDatePicker(screenSize),
                const SizedBox(height: 16),
                _buildTimePicker(screenSize),
              ],
            ),

          const SizedBox(height: 20),

          // Location field with search
          _buildLocationField(screenSize),
        ],
      ),
    );
  }

  // Date picker
  Widget _buildDatePicker(ScreenSize screenSize) {
    final touchTarget = _getTouchTarget(screenSize);

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      child: Container(
        height: touchTarget + 16,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Birth Date',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    DateFormat('dd MMM yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 14,
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

  // Time picker
  Widget _buildTimePicker(ScreenSize screenSize) {
    final touchTarget = _getTouchTarget(screenSize);

    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        if (picked != null) {
          setState(() {
            _selectedTime = picked;
          });
        }
      },
      child: Container(
        height: touchTarget + 16,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Birth Time',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    _selectedTime.format(context),
                    style: const TextStyle(
                      fontSize: 14,
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

  // Location field
  Widget _buildLocationField(ScreenSize screenSize) {
    return Column(
      children: [
        TextFormField(
          controller: _placeController,
          focusNode: _placeFocusNode,
          decoration: InputDecoration(
            labelText: 'Birth Place',
            hintText: 'Search for a city',
            prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon:
                _isSearchingLocation
                    ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchLocation,
                    ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter birth place';
            }
            if (_latitude == null) {
              return 'Please search and select a valid location';
            }
            return null;
          },
        ),

        // Location suggestions would appear here
      ],
    );
  }

  // Preferences step
  Widget _buildPreferencesStep(ScreenSize screenSize) {
    return FadeTransition(
      opacity: _stepAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferences',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Chart style
          const Text('Chart Style', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children:
                ChartStyle.values.map((style) {
                  return ChoiceChip(
                    label: Text(style.displayName),
                    selected: _chartStyle == style,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _chartStyle = style;
                        });
                      }
                    },
                  );
                }).toList(),
          ),

          const SizedBox(height: 20),

          // Language
          const Text('Language', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children:
                ['English', 'Hindi', 'Sanskrit'].map((lang) {
                  return ChoiceChip(
                    label: Text(lang),
                    selected: _language == lang,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _language = lang;
                        });
                      }
                    },
                  );
                }).toList(),
          ),

          const SizedBox(height: 20),

          // Primary switch
          SwitchListTile(
            title: const Text('Set as Primary Kundali'),
            subtitle: const Text('Use this as your default birth chart'),
            value: _isPrimary,
            onChanged: (value) {
              setState(() {
                _isPrimary = value;
              });
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // Review step
  Widget _buildReviewStep(ScreenSize screenSize) {
    return FadeTransition(
      opacity: _stepAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildReviewItem('Name', _nameController.text),
                  _buildReviewItem('Gender', _selectedGender),
                  _buildReviewItem(
                    'Birth Date',
                    DateFormat('dd MMMM yyyy').format(_selectedDate),
                  ),
                  _buildReviewItem('Birth Time', _selectedTime.format(context)),
                  _buildReviewItem('Birth Place', _placeController.text),
                  _buildReviewItem('Chart Style', _chartStyle.displayName),
                  _buildReviewItem('Language', _language),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // All steps for desktop
  Widget _buildAllStepsDesktop() {
    return Column(
      children: [
        // Personal & Birth Details in columns
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildPersonalStep(ScreenSize.desktop)),
            const SizedBox(width: 32),
            Expanded(child: _buildBirthDetailsStep(ScreenSize.desktop)),
          ],
        ),
        const SizedBox(height: 32),
        // Preferences full width
        _buildPreferencesStep(ScreenSize.desktop),
      ],
    );
  }

  // Navigation buttons
  Widget _buildNavigationButtons(ScreenSize screenSize) {
    final canGoBack = _currentStep != FormStep.personal;
    final isLastStep = _currentStep == FormStep.review;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (canGoBack)
            Expanded(
              child: OutlinedButton(
                onPressed: _handleStepBack,
                child: const Text('Back'),
              ),
            ),
          if (canGoBack) const SizedBox(width: 16),
          Expanded(
            flex: canGoBack ? 1 : 2,
            child: ElevatedButton(
              onPressed: _handleStepContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(isLastStep ? 'Generate Kundali' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  // Desktop actions
  Widget _buildDesktopActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: _generateKundali,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Kundali'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleStepBack() {
    final steps = FormStep.values;
    final currentIndex = steps.indexOf(_currentStep);
    if (currentIndex > 0) {
      setState(() {
        _currentStep = steps[currentIndex - 1];
      });
      _stepController.forward(from: 0);
    }
  }

  void _handleStepContinue() {
    if (!_validateCurrentStep()) return;

    final steps = FormStep.values;
    final currentIndex = steps.indexOf(_currentStep);

    setState(() {
      _stepCompleted[_currentStep] = true;
    });

    if (currentIndex < steps.length - 1) {
      setState(() {
        _currentStep = steps[currentIndex + 1];
      });
      _stepController.forward(from: 0);
    } else {
      _generateKundali();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case FormStep.personal:
        return _nameController.text.isNotEmpty;
      case FormStep.birthDetails:
        return _placeController.text.isNotEmpty;
      case FormStep.preferences:
        return true;
      case FormStep.review:
        return _formKey.currentState?.validate() ?? false;
    }
  }

  void _searchLocation() async {
    setState(() {
      _isSearchingLocation = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _latitude = 28.6139;
      _longitude = 77.2090;
      _isSearchingLocation = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location found'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _generateKundali() {
    // Generate Kundali logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating Kundali...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  String _getStepTitle(FormStep step) {
    switch (step) {
      case FormStep.personal:
        return 'Personal';
      case FormStep.birthDetails:
        return 'Birth';
      case FormStep.preferences:
        return 'Preferences';
      case FormStep.review:
        return 'Review';
    }
  }

  String _getStepDescription(FormStep step) {
    switch (step) {
      case FormStep.personal:
        return 'Basic information';
      case FormStep.birthDetails:
        return 'Date, time & place';
      case FormStep.preferences:
        return 'Chart settings';
      case FormStep.review:
        return 'Verify details';
    }
  }
}
