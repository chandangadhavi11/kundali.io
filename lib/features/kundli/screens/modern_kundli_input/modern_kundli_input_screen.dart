import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/kundli_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/models/kundali_data_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/auth_required_dialog.dart';
import '../modern_kundli_display/modern_kundli_display_screen.dart';

class ModernKundliInputScreen extends StatefulWidget {
  const ModernKundliInputScreen({super.key});

  @override
  State<ModernKundliInputScreen> createState() =>
      _ModernKundliInputScreenState();
}

class _ModernKundliInputScreenState extends State<ModernKundliInputScreen>
    with TickerProviderStateMixin {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();

  // Form values
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  String _selectedGender = 'Male';
  double? _latitude;
  double? _longitude;
  final String _timezone = 'IST';
  bool _isPrimary = false;
  ChartStyle _chartStyle = ChartStyle.northIndian;
  final String _language = 'English';

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late List<AnimationController> _itemControllers;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // State
  KundaliData? _currentKundali;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize with current date/time
    _initializeDefaultValues();

    // Setup animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Item animations
    _itemControllers = List.generate(
      10,
      (index) => AnimationController(
        duration: Duration(milliseconds: 300 + (index * 50)),
        vsync: this,
      ),
    );

    // Define animations
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    for (var controller in _itemControllers) {
      controller.forward();
    }

    // Auto-generate kundali after animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _autoGenerateKundali();
      });
    });
  }

  void _initializeDefaultValues() {
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _nameController.text = 'Today\'s Chart';
    _placeController.text = 'Current Location';
    _latitude = 28.6139; // Default to Delhi
    _longitude = 77.2090;
    _selectedGender = 'Male';
  }

  Future<void> _autoGenerateKundali() async {
    setState(() => _isLoading = true);

    final birthDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final provider = context.read<KundliProvider>();

    await provider.generateKundali(
      name: _nameController.text,
      birthDateTime: birthDateTime,
      birthPlace: _placeController.text,
      latitude: _latitude ?? 28.6139,
      longitude: _longitude ?? 77.2090,
      timezone: _timezone,
      gender: _selectedGender,
      isPrimary: false,
      chartStyle: _chartStyle,
      language: _language,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (provider.error.isEmpty && provider.currentKundali != null) {
          _currentKundali = provider.currentKundali;
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    _nameController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<KundliProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Compact App Bar
            SliverAppBar(
              expandedHeight: 56,
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  CupertinoIcons.arrow_left,
                  size: 20,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              title: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  _currentKundali != null ? 'Edit Chart' : 'Create Chart',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              centerTitle: true,
            ),

            // Content
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth > 600 ? 24 : 16,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Chart Preview (if available)
                  if (_currentKundali != null) ...[
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildCompactChartPreview(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Form Section
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Input
                        _buildAnimatedItem(
                          index: 0,
                          child: _buildCompactTextField(
                            controller: _nameController,
                            label: 'Name',
                            hint: 'Enter name',
                            icon: CupertinoIcons.person,
                            isDarkMode: isDarkMode,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Gender Selection
                        _buildAnimatedItem(
                          index: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gender',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildCompactGenderSelector(isDarkMode),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Date & Time Row
                        _buildAnimatedItem(
                          index: 2,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildCompactDateTimeField(
                                  label: 'Birth Date',
                                  value: DateFormat(
                                    'MMM d, y',
                                  ).format(_selectedDate),
                                  icon: CupertinoIcons.calendar,
                                  isDarkMode: isDarkMode,
                                  onTap: () => _selectDate(context),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildCompactDateTimeField(
                                  label: 'Birth Time',
                                  value: _selectedTime.format(context),
                                  icon: CupertinoIcons.clock,
                                  isDarkMode: isDarkMode,
                                  onTap: () => _selectTime(context),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Location Field
                        _buildAnimatedItem(
                          index: 3,
                          child: _buildCompactLocationField(isDarkMode),
                        ),

                        const SizedBox(height: 24),

                        // Chart Style Selection
                        _buildAnimatedItem(
                          index: 4,
                          child: _buildCompactChartStyleSection(isDarkMode),
                        ),

                        // Primary Toggle (if authenticated)
                        if (context.read<AuthProvider>().isAuthenticated) ...[
                          const SizedBox(height: 20),
                          _buildAnimatedItem(
                            index: 5,
                            child: _buildCompactPrimaryToggle(isDarkMode),
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Generate Button
                        _buildAnimatedItem(
                          index: 6,
                          child: _buildCompactGenerateButton(
                            isDarkMode,
                            provider,
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactChartPreview(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentKundali!.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'MMM d, y • h:mm a',
                      ).format(_currentKundali!.birthDateTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ModernKundliDisplayScreen(
                            kundaliData: _currentKundali!,
                          ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        CupertinoIcons.chevron_right,
                        color: AppColors.primary,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Compact Info Cards
          Row(
            children: [
              Expanded(
                child: _buildMiniInfoCard(
                  icon: CupertinoIcons.arrow_up_circle_fill,
                  label: 'Asc',
                  value: _currentKundali!.ascendant.sign,
                  color: const Color(0xFF6B4EE6),
                  isDarkMode: isDarkMode,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniInfoCard(
                  icon: CupertinoIcons.moon_fill,
                  label: 'Moon',
                  value: _currentKundali!.moonSign,
                  color: const Color(0xFF4ECDC4),
                  isDarkMode: isDarkMode,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniInfoCard(
                  icon: CupertinoIcons.sun_max_fill,
                  label: 'Sun',
                  value: _currentKundali!.sunSign,
                  color: const Color(0xFFFFB347),
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: TextFormField(
            controller: controller,
            validator: validator,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                size: 18,
              ),
              filled: true,
              fillColor:
                  isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.red.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.red.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactGenderSelector(bool isDarkMode) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children:
            ['Male', 'Female', 'Other'].map((gender) {
              final isSelected = _selectedGender == gender;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGender = gender;
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? (isDarkMode ? Colors.white : AppColors.primary)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        gender,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color:
                              isSelected
                                  ? (isDarkMode ? Colors.black : Colors.white)
                                  : (isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600]),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCompactDateTimeField({
    required String label,
    required String value,
    required IconData icon,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 68,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactLocationField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birth Location',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _searchLocation,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.location_fill,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _placeController.text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_latitude?.toStringAsFixed(4)}°N, ${_longitude?.toStringAsFixed(4)}°E',
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              isDarkMode ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.search,
                  size: 16,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactChartStyleSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chart Style',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildCompactChartStyleOption(
                label: 'North Indian',
                style: ChartStyle.northIndian,
                icon: CupertinoIcons.square_split_2x2,
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactChartStyleOption(
                label: 'South Indian',
                style: ChartStyle.southIndian,
                icon: CupertinoIcons.square_grid_3x2,
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactChartStyleOption({
    required String label,
    required ChartStyle style,
    required IconData icon,
    required bool isDarkMode,
  }) {
    final isSelected = _chartStyle == style;

    return GestureDetector(
      onTap: () {
        setState(() {
          _chartStyle = style;
        });
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : (isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.primary
                    : (isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey[300]!),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color:
                  isSelected
                      ? AppColors.primary
                      : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color:
                    isSelected
                        ? AppColors.primary
                        : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactPrimaryToggle(bool isDarkMode) {
    return Row(
      children: [
        Icon(CupertinoIcons.star_fill, color: AppColors.primary, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Set as Primary Chart',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
        Transform.scale(
          scale: 0.75,
          child: CupertinoSwitch(
            value: _isPrimary,
            onChanged: (value) {
              setState(() {
                _isPrimary = value;
              });
              HapticFeedback.lightImpact();
            },
            activeColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactGenerateButton(bool isDarkMode, KundliProvider provider) {
    return GestureDetector(
      onTapDown: (_) => _pulseController.forward(),
      onTapUp: (_) {
        _pulseController.reverse();
        _generateKundali();
      },
      onTapCancel: () => _pulseController.reverse(),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder:
            (context, child) => Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: provider.isGenerating ? null : _generateKundali,
                    borderRadius: BorderRadius.circular(14),
                    child: Center(
                      child:
                          provider.isGenerating || _isLoading
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.3,
                                  ),
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _currentKundali != null
                                        ? CupertinoIcons.refresh
                                        : CupertinoIcons.sparkles,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _currentKundali != null
                                        ? 'Update Chart'
                                        : 'Generate Chart',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
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

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    final controller = _itemControllers[index.clamp(0, 9)];
    return FadeTransition(
      opacity: CurvedAnimation(parent: controller, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
  }

  Future<void> _generateKundali() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated && _isPrimary) {
      await AuthRequiredDialog.show(
        context,
        feature: 'Save Kundali',
        description:
            'Sign in to save your Kundali and access it anytime. You can still view it without signing in.',
        onSkip: () {
          _proceedWithGeneration(saveKundali: false);
        },
      );
      return;
    }

    _proceedWithGeneration(saveKundali: authProvider.isAuthenticated);
  }

  Future<void> _proceedWithGeneration({required bool saveKundali}) async {
    setState(() => _isLoading = true);

    final birthDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final provider = context.read<KundliProvider>();

    await provider.generateKundali(
      name: _nameController.text,
      birthDateTime: birthDateTime,
      birthPlace: _placeController.text,
      latitude: _latitude ?? 28.6139,
      longitude: _longitude ?? 77.2090,
      timezone: _timezone,
      gender: _selectedGender,
      isPrimary: saveKundali ? _isPrimary : false,
      chartStyle: _chartStyle,
      language: _language,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (provider.error.isEmpty && provider.currentKundali != null) {
          _currentKundali = provider.currentKundali;
          HapticFeedback.mediumImpact();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _currentKundali != null ? 'Chart updated' : 'Chart generated',
                style: const TextStyle(fontSize: 14),
              ),
              backgroundColor: const Color(0xFF4ECB71),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          );
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
              onSurface: isDarkMode ? Colors.white : Colors.black87,
            ),
            dialogBackgroundColor:
                isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
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
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
              onSurface: isDarkMode ? Colors.white : Colors.black87,
            ),
            dialogBackgroundColor:
                isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
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
      HapticFeedback.lightImpact();
    }
  }

  void _searchLocation() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Location search coming soon',
          style: TextStyle(fontSize: 14),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
