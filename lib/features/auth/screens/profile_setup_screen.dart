import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';

// Responsive breakpoints
class ProfileBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

// Screen size categories
enum ScreenSize { mobile, tablet, desktop }

// Profile setup steps
enum ProfileStep { photo, birthDetails, interests }

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _pageController = PageController();

  // Text controllers
  final _birthPlaceController = TextEditingController();
  final _bioController = TextEditingController();

  // State variables
  ProfileStep _currentStep = ProfileStep.photo;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedGender = 'Male';
  bool _isLoading = false;

  // Interests selection
  final Set<String> _selectedInterests = {};
  final List<String> _availableInterests = [
    'Vedic Astrology',
    'Western Astrology',
    'Numerology',
    'Tarot',
    'Palmistry',
    'Vastu',
    'Gemstones',
    'Meditation',
    'Yoga',
    'Spirituality',
    'Career',
    'Love & Relationships',
    'Health',
    'Finance',
    'Family',
    'Education',
  ];

  // Animation controllers
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _updateProgress();
  }

  void _updateProgress() {
    final progress = (_currentStep.index + 1) / ProfileStep.values.length;
    _progressController.animateTo(progress);
  }

  @override
  void dispose() {
    _birthPlaceController.dispose();
    _bioController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  ScreenSize _getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < ProfileBreakpoints.mobile) return ScreenSize.mobile;
    if (width < ProfileBreakpoints.tablet) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  void _nextStep() {
    HapticFeedback.lightImpact();
    if (_currentStep.index < ProfileStep.values.length - 1) {
      setState(() {
        _currentStep = ProfileStep.values[_currentStep.index + 1];
      });
      _updateProgress();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _handleSave();
    }
  }

  void _previousStep() {
    HapticFeedback.lightImpact();
    if (_currentStep.index > 0) {
      setState(() {
        _currentStep = ProfileStep.values[_currentStep.index - 1];
      });
      _updateProgress();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
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

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select birth date and time'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser!;

    final birthDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final updatedUser = currentUser.copyWith(
      birthDate: _selectedDate,
      birthTime: birthDateTime,
      birthPlace: _birthPlaceController.text.trim(),
      gender: _selectedGender,
      // These will be calculated based on birth details
      zodiacSign: _getZodiacSign(_selectedDate!),
      moonSign: 'Taurus', // TODO: Calculate based on birth chart
      ascendant: 'Gemini', // TODO: Calculate based on birth chart
    );

    await authProvider.updateProfile(updatedUser);

    if (!mounted) return;

    setState(() => _isLoading = false);
    context.go('/home');
  }

  String _getZodiacSign(DateTime date) {
    final month = date.month;
    final day = date.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      return 'Aries';
    }
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return 'Taurus';
    }
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      return 'Gemini';
    }
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      return 'Cancer';
    }
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      return 'Libra';
    }
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return 'Scorpio';
    }
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return 'Sagittarius';
    }
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return 'Capricorn';
    }
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return 'Aquarius';
    }
    return 'Pisces';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = _getScreenSize(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            _buildProgressBar(context),
            // Header
            _buildHeader(context, screenSize),
            // Multi-step content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPhotoStep(context, l10n, screenSize),
                  _buildBirthDetailsStep(context, l10n, screenSize),
                  _buildInterestsStep(context, l10n, screenSize),
                ],
              ),
            ),
            // Navigation
            _buildNavigationButtons(context, l10n, screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return SizedBox(
      height: 4,
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: _progressAnimation.value,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ScreenSize screenSize) {
    final fontSize = _getResponsiveFontSize(screenSize);
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete Your Profile',
            style: TextStyle(
              fontSize: fontSize * 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getStepTitle(),
            style: TextStyle(
              fontSize: fontSize,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case ProfileStep.photo:
        return 'Add your profile photo';
      case ProfileStep.birthDetails:
        return 'Enter your birth details';
      case ProfileStep.interests:
        return 'Select your interests';
    }
  }

  Widget _buildPhotoStep(
    BuildContext context,
    AppLocalizations l10n,
    ScreenSize screenSize,
  ) {
    final imageSize = screenSize == ScreenSize.mobile ? 120.0 : 160.0;
    final fontSize = _getResponsiveFontSize(screenSize);

    return SingleChildScrollView(
      controller: _scrollController,
      padding: _getResponsivePadding(screenSize),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Profile image picker
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // TODO: Implement image picker
                },
                child: Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 3),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: imageSize * 0.4,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Add Profile Photo',
                style: TextStyle(
                  fontSize: fontSize * 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              // Bio field
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                maxLength: 200,
                decoration: InputDecoration(
                  labelText: 'Bio (Optional)',
                  hintText: 'Tell us about yourself...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                style: TextStyle(fontSize: fontSize),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBirthDetailsStep(
    BuildContext context,
    AppLocalizations l10n,
    ScreenSize screenSize,
  ) {
    final isTabletOrDesktop = screenSize != ScreenSize.mobile;
    final padding = _getResponsivePadding(screenSize);
    final spacing = _getResponsiveSpacing(screenSize);

    return SingleChildScrollView(
      controller: _scrollController,
      padding: padding,
      child: Form(
        key: _formKey,
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isTabletOrDesktop)
                Row(
                  children: [
                    Expanded(child: _buildDateField(context, l10n)),
                    SizedBox(width: spacing),
                    Expanded(child: _buildTimeField(context, l10n)),
                  ],
                )
              else ...[
                _buildDateField(context, l10n),
                SizedBox(height: spacing),
                _buildTimeField(context, l10n),
              ],
              _buildPlaceField(l10n),
              SizedBox(height: spacing),
              _buildGenderField(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterestsStep(
    BuildContext context,
    AppLocalizations l10n,
    ScreenSize screenSize,
  ) {
    final columns =
        screenSize == ScreenSize.mobile
            ? 2
            : screenSize == ScreenSize.tablet
            ? 3
            : 4;
    final fontSize = _getResponsiveFontSize(screenSize);

    return SingleChildScrollView(
      controller: _scrollController,
      padding: _getResponsivePadding(screenSize),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What interests you?',
            style: TextStyle(
              fontSize: fontSize * 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: screenSize == ScreenSize.mobile ? 2.5 : 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _availableInterests.length,
            itemBuilder: (context, index) {
              final interest = _availableInterests[index];
              final isSelected = _selectedInterests.contains(interest);

              return InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(interest);
                    } else {
                      _selectedInterests.add(interest);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : Theme.of(context).cardColor,
                    border: Border.all(
                      color:
                          isSelected
                              ? AppColors.primary
                              : Theme.of(context).dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      interest,
                      style: TextStyle(
                        fontSize: fontSize * 0.9,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color:
                            isSelected
                                ? AppColors.primary
                                : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context, AppLocalizations l10n) {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.dateOfBirth,
          prefixIcon: const Icon(Icons.calendar_today),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          _selectedDate == null
              ? 'Select Date'
              : DateFormat('dd MMM yyyy').format(_selectedDate!),
        ),
      ),
    );
  }

  Widget _buildTimeField(BuildContext context, AppLocalizations l10n) {
    return InkWell(
      onTap: _selectTime,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.timeOfBirth,
          prefixIcon: const Icon(Icons.access_time),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          _selectedTime == null
              ? 'Select Time'
              : _selectedTime!.format(context),
        ),
      ),
    );
  }

  Widget _buildPlaceField(AppLocalizations l10n) {
    return TextFormField(
      controller: _birthPlaceController,
      decoration: InputDecoration(
        labelText: l10n.placeOfBirth,
        prefixIcon: const Icon(Icons.location_on_outlined),
        hintText: 'e.g., Mumbai, India',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your birth place';
        }
        return null;
      },
    );
  }

  Widget _buildGenderField(BuildContext context, AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: l10n.gender,
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items:
          ['Male', 'Female', 'Other'].map((gender) {
            return DropdownMenuItem(value: gender, child: Text(gender));
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedGender = value!;
        });
      },
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    AppLocalizations l10n,
    ScreenSize screenSize,
  ) {
    final buttonHeight = screenSize == ScreenSize.mobile ? 48.0 : 56.0;
    final fontSize = _getResponsiveFontSize(screenSize);

    return Container(
      padding: _getResponsivePadding(screenSize),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
          if (_currentStep.index > 0)
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: OutlinedButton(
                  onPressed: _previousStep,
                  child: Text('Previous', style: TextStyle(fontSize: fontSize)),
                ),
              ),
            ),
          if (_currentStep.index > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: buttonHeight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _nextStep,
                child:
                    _isLoading
                        ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          _currentStep == ProfileStep.interests
                              ? 'Complete'
                              : 'Continue',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
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

  double _getResponsiveFontSize(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 14;
      case ScreenSize.tablet:
        return 15;
      case ScreenSize.desktop:
        return 16;
    }
  }

  double _getResponsiveSpacing(ScreenSize screenSize) {
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
