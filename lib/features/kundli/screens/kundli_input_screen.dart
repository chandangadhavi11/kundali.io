import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/kundli_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/models/kundali_data_model.dart';
import '../../../shared/widgets/auth_required_dialog.dart';
import 'kundli_display_screen.dart';

class KundliInputScreen extends StatefulWidget {
  const KundliInputScreen({super.key});

  @override
  State<KundliInputScreen> createState() => _KundliInputScreenState();
}

class _KundliInputScreenState extends State<KundliInputScreen>
    with TickerProviderStateMixin {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  final _nameFocusNode = FocusNode();

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
  bool _showAdvanced = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // State
  KundaliData? _currentKundali;
  bool _isLoading = false;
  bool _hasUserGenerated = false;

  // Tap states for microinteractions
  final Map<String, bool> _pressedStates = {};

  @override
  void initState() {
    super.initState();
    _initializeDefaultValues();
    _initializeAnimations();
    // Note: Removed auto-generate on init to avoid heavy calculations on the input screen
    // User will generate Kundali when they tap the "Generate Kundali" button

    // Defer animation start to after first frame for smoother transition
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
        _shimmerController.repeat();
      }
    });
  }

  void _initializeDefaultValues() {
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    
    // Generate a descriptive default name with date and time
    final now = DateTime.now();
    final dateStr = DateFormat('d MMM yyyy').format(now);
    final timeStr = DateFormat('h:mm a').format(now);
    _nameController.text = '$dateStr, $timeStr';
    
    _placeController.text = 'New Delhi, India';
    _latitude = 28.6139;
    _longitude = 77.2090;
    _selectedGender = 'Male';
  }

  void _initializeAnimations() {
    // Main fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    );

    // Slide animation for staggered entry
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Pulse animation for the action button glow
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Shimmer animation - deferred start
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _nameController.dispose();
    _placeController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _setPressed(String key, bool value) {
    setState(() => _pressedStates[key] = value);
  }

  bool _isPressed(String key) => _pressedStates[key] ?? false;

  // Color palette - Refined cosmic theme
  static const _bgPrimary = Color(0xFF0D0B14);
  static const _bgSecondary = Color(0xFF131020);
  static const _surfaceColor = Color(0xFF1A1625);
  static const _borderColor = Color(0xFF2A2438);
  static const _accentPrimary = Color(0xFFD4AF37); // Elegant gold
  static const _accentSecondary = Color(0xFFA78BFA); // Soft violet
  static const _textPrimary = Color(0xFFF8F7FC);
  static const _textSecondary = Color(0xFF9B95A8);
  static const _textMuted = Color(0xFF6B6478);
  static const _successColor = Color(0xFF6EE7B7);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KundliProvider>();
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _bgPrimary,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_currentKundali != null) ...[
                                _buildChartPreview(),
                                const SizedBox(height: 28),
                              ],
                              // Recent Profiles Section
                              _buildRecentProfilesSection(context.watch<KundliProvider>()),
                              _buildAnimatedField(0, _buildNameField()),
                              const SizedBox(height: 20),
                              _buildAnimatedField(1, _buildGenderSelector()),
                              const SizedBox(height: 20),
                              _buildAnimatedField(2, _buildDateTimeRow()),
                              const SizedBox(height: 20),
                              _buildAnimatedField(3, _buildLocationField()),
                              const SizedBox(height: 16),
                              _buildAnimatedField(4, _buildAdvancedToggle()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom action bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(provider, bottomPadding),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF12101B), _bgPrimary, Color(0xFF0A080F)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Ambient glow - top right
        Positioned(
          top: -100,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _accentSecondary.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Ambient glow - bottom left
        Positioned(
          bottom: 100,
          left: -80,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_accentPrimary.withOpacity(0.05), Colors.transparent],
              ),
            ),
          ),
        ),
        // Subtle noise texture overlay
        Positioned.fill(
          child: Opacity(
            opacity: 0.015,
            child: CustomPaint(painter: _NoisePainter()),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          _buildIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _hasUserGenerated ? 'Edit Chart' : 'Create Kundali',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _hasUserGenerated ? 'Modify details' : 'Enter birth details',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: _textMuted,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          _buildIconButton(
            icon: Icons.help_outline_rounded,
            onTap: _showInfoSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTapDown: (_) => _setPressed('icon_$icon', true),
      onTapUp: (_) => _setPressed('icon_$icon', false),
      onTapCancel: () => _setPressed('icon_$icon', false),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedScale(
        scale: _isPressed('icon_$icon') ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _surfaceColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: _borderColor.withOpacity(0.5),
              width: 0.5,
            ),
          ),
          child: Icon(icon, size: 16, color: _textSecondary),
        ),
      ),
    );
  }

  Widget _buildAnimatedField(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
    );
  }

  Widget _buildChartPreview() {
    return _buildTappableCard(
      key: 'preview',
      onTap:
          () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (_, __, ___) =>
                      KundliDisplayScreen(kundaliData: _currentKundali!),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.02, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _accentSecondary.withOpacity(0.08),
              _accentSecondary.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _accentSecondary.withOpacity(0.12),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _accentSecondary.withOpacity(0.3),
                    _accentSecondary.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '॥',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    color: _textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentKundali!.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _buildMiniTag('☽ ${_currentKundali!.moonSign}'),
                      const SizedBox(width: 8),
                      _buildMiniTag('☉ ${_currentKundali!.sunSign}'),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: _textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTag(String text) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 11,
        color: _textMuted,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildRecentProfilesSection(KundliProvider provider) {
    final savedProfiles = provider.savedKundalis;
    
    // Don't show if no saved profiles
    if (savedProfiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _accentSecondary.withOpacity(0.3),
                        _accentSecondary.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    size: 11,
                    color: _accentSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Fill from Saved',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                Text(
                  '${savedProfiles.length} profile${savedProfiles.length > 1 ? 's' : ''}',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Horizontal scrollable profile cards
          SizedBox(
            height: 88,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: savedProfiles.length,
              itemBuilder: (context, index) {
                final profile = savedProfiles[savedProfiles.length - 1 - index]; // Show most recent first
                final isPrimary = profile.isPrimary;
                
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 60)),
                  curve: Curves.easeOutCubic,
                  builder: (context, animValue, child) {
                    return Transform.translate(
                      offset: Offset(20 * (1 - animValue), 0),
                      child: Opacity(opacity: animValue, child: child),
                    );
                  },
                  child: _buildProfileCard(profile, isPrimary, index),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // Divider with "or create new" text
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 0.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        _borderColor.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or enter new details',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _textMuted.withOpacity(0.8),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 0.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _borderColor.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileCard(KundaliData profile, bool isPrimary, int index) {
    final formattedDate = DateFormat('d MMM yyyy').format(profile.birthDateTime);
    final formattedTime = DateFormat('h:mm a').format(profile.birthDateTime);
    
    // Generate a unique gradient based on profile
    final gradientColors = _getProfileGradient(index);
    
    return GestureDetector(
      onTapDown: (_) => _setPressed('profile_${profile.id}', true),
      onTapUp: (_) => _setPressed('profile_${profile.id}', false),
      onTapCancel: () => _setPressed('profile_${profile.id}', false),
      onTap: () {
        HapticFeedback.mediumImpact();
        _fillFromProfile(profile);
        _showProfileSelectedFeedback(profile.name);
      },
      child: AnimatedScale(
        scale: _isPressed('profile_${profile.id}') ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 160,
          margin: EdgeInsets.only(right: 10, left: index == 0 ? 0 : 0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradientColors[0].withOpacity(0.12),
                gradientColors[1].withOpacity(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPrimary
                  ? _accentPrimary.withOpacity(0.4)
                  : gradientColors[0].withOpacity(0.2),
              width: isPrimary ? 1.0 : 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background decoration
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        gradientColors[0].withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top row with avatar and primary badge
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: gradientColors,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              profile.name.isNotEmpty 
                                  ? profile.name[0].toUpperCase() 
                                  : '?',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            profile.name,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isPrimary)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _accentPrimary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.star_rounded,
                              size: 10,
                              color: _accentPrimary,
                            ),
                          ),
                      ],
                    ),
                    // Bottom info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 9,
                              color: _textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: _textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              formattedTime,
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: _textMuted.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.place_rounded,
                              size: 9,
                              color: _textMuted,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                profile.birthPlace,
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  color: _textMuted.withOpacity(0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Tap indicator
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _surfaceColor.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 10,
                    color: gradientColors[0],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getProfileGradient(int index) {
    final gradients = [
      [const Color(0xFFA78BFA), const Color(0xFF818CF8)], // Purple
      [const Color(0xFF6EE7B7), const Color(0xFF34D399)], // Emerald
      [const Color(0xFFFBBF24), const Color(0xFFF59E0B)], // Amber
      [const Color(0xFF60A5FA), const Color(0xFF3B82F6)], // Blue
      [const Color(0xFFF472B6), const Color(0xFFEC4899)], // Pink
      [const Color(0xFF4ADE80), const Color(0xFF22C55E)], // Green
      [const Color(0xFFFB923C), const Color(0xFFF97316)], // Orange
      [const Color(0xFF38BDF8), const Color(0xFF0EA5E9)], // Sky
    ];
    return gradients[index % gradients.length];
  }

  void _fillFromProfile(KundaliData profile) {
    setState(() {
      _nameController.text = profile.name;
      _selectedDate = profile.birthDateTime;
      _selectedTime = TimeOfDay.fromDateTime(profile.birthDateTime);
      _placeController.text = profile.birthPlace;
      _latitude = profile.latitude;
      _longitude = profile.longitude;
      _selectedGender = profile.gender;
      _chartStyle = profile.chartStyle;
      _isPrimary = profile.isPrimary;
    });
  }

  void _showProfileSelectedFeedback(String name) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _successColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: _successColor,
                size: 14,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Filled details from "$name"',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _surfaceColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _successColor.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        elevation: 8,
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldContainer(
          label: 'Name',
          child: _buildInputField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            hint: 'Enter name',
            prefixIcon: Icons.person_outline_rounded,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 6),
          child: Text(
            'You can customize this name to identify your chart easily',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: _textMuted.withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldContainer({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String hint,
    required IconData prefixIcon,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              (focusNode?.hasFocus ?? false)
                  ? _accentSecondary.withOpacity(0.3)
                  : _borderColor.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(prefixIcon, size: 17, color: _textMuted),
          Expanded(
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: _textPrimary,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: _accentPrimary,
              cursorWidth: 1.5,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.dmSans(
                  color: _textMuted,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              onTap: () => setState(() {}),
              onEditingComplete: () {
                focusNode?.unfocus();
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return _buildFieldContainer(
      label: 'Gender',
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: _surfaceColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor.withOpacity(0.4), width: 0.5),
        ),
        child: Row(
          children:
              ['Male', 'Female', 'Other'].map((gender) {
                final isSelected = _selectedGender == gender;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedGender = gender);
                      HapticFeedback.selectionClick();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? _accentSecondary.withOpacity(0.15)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        border:
                            isSelected
                                ? Border.all(
                                  color: _accentSecondary.withOpacity(0.25),
                                  width: 0.5,
                                )
                                : null,
                      ),
                      child: Center(
                        child: Text(
                          gender,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? _accentSecondary : _textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateTimeRow() {
    return _buildFieldContainer(
      label: 'Birth Date & Time',
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: _buildTappableCard(
              key: 'date',
              onTap: () => _selectDate(context),
              child: _buildSelectorField(
                icon: Icons.calendar_today_rounded,
                iconColor: _accentPrimary,
                value: DateFormat('d MMM yyyy').format(_selectedDate),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: _buildTappableCard(
              key: 'time',
              onTap: () => _selectTime(context),
              child: _buildSelectorField(
                icon: Icons.schedule_rounded,
                iconColor: _accentPrimary,
                value: _selectedTime.format(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorField({
    required IconData icon,
    required Color iconColor,
    required String value,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor.withOpacity(0.4), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: iconColor.withOpacity(0.85)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
          ),
          Icon(
            Icons.unfold_more_rounded,
            size: 15,
            color: _textMuted.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField() {
    return _buildFieldContainer(
      label: 'Birth Place',
      child: _buildTappableCard(
        key: 'location',
        onTap: _showLocationSearch,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _borderColor.withOpacity(0.4),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.place_rounded,
                  size: 15,
                  color: _successColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _placeController.text,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${_latitude?.toStringAsFixed(3)}°N, ${_longitude?.toStringAsFixed(3)}°E',
                      style: GoogleFonts.dmMono(
                        fontSize: 10,
                        color: _textMuted,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.search_rounded,
                size: 16,
                color: _textMuted.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedToggle() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() => _showAdvanced = !_showAdvanced);
            HapticFeedback.selectionClick();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: _surfaceColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Advanced Options',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _textMuted,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _showAdvanced ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: const Icon(
                    Icons.expand_more_rounded,
                    size: 14,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChartStyleSelector(),
                if (context.read<AuthProvider>().isAuthenticated) ...[
                  const SizedBox(height: 16),
                  _buildPrimaryToggle(),
                ],
              ],
            ),
          ),
          crossFadeState:
              _showAdvanced
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 280),
          sizeCurve: Curves.easeOutCubic,
        ),
      ],
    );
  }

  Widget _buildChartStyleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            'Chart Style',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildChartOption(
                'North Indian',
                ChartStyle.northIndian,
                '॥',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildChartOption(
                'South Indian',
                ChartStyle.southIndian,
                '⊞',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartOption(String label, ChartStyle style, String symbol) {
    final isSelected = _chartStyle == style;
    return GestureDetector(
      onTap: () {
        setState(() => _chartStyle = style);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF3B82F6).withOpacity(0.1)
                  : _surfaceColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color:
                isSelected
                    ? const Color(0xFF3B82F6).withOpacity(0.3)
                    : _borderColor.withOpacity(0.4),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              symbol,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? const Color(0xFF60A5FA) : _textMuted,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF60A5FA) : _textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryToggle() {
    return GestureDetector(
      onTap: () {
        setState(() => _isPrimary = !_isPrimary);
        HapticFeedback.selectionClick();
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _surfaceColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: _borderColor.withOpacity(0.4), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(
              Icons.star_rounded,
              size: 16,
              color: _accentPrimary.withOpacity(0.85),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set as Primary',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    'For daily predictions',
                    style: GoogleFonts.dmSans(fontSize: 10, color: _textMuted),
                  ),
                ],
              ),
            ),
            _buildToggleSwitch(_isPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(bool value) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 38,
      height: 22,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: value ? _accentPrimary : _borderColor,
        borderRadius: BorderRadius.circular(11),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: value ? _bgPrimary : _textSecondary.withOpacity(0.8),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(KundliProvider provider, double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _bgPrimary.withOpacity(0),
            _bgPrimary.withOpacity(0.9),
            _bgPrimary,
          ],
          stops: const [0.0, 0.4, 0.7],
        ),
      ),
      child: _buildActionButton(provider),
    );
  }

  Widget _buildActionButton(KundliProvider provider) {
    final isLoading = provider.isGenerating || _isLoading;

    return GestureDetector(
      onTapDown: isLoading ? null : (_) => _setPressed('action', true),
      onTapUp: isLoading ? null : (_) => _setPressed('action', false),
      onTapCancel: isLoading ? null : () => _setPressed('action', false),
      onTap:
          isLoading
              ? null
              : () {
                HapticFeedback.mediumImpact();
                _generateKundali();
              },
      child: AnimatedScale(
        scale: _isPressed('action') ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isLoading
                          ? [_surfaceColor, _surfaceColor.withOpacity(0.8)]
                          : [
                            _accentPrimary,
                            const Color(0xFFE8C547),
                            _accentPrimary,
                          ],
                  stops: isLoading ? null : const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(13),
                boxShadow:
                    isLoading
                        ? []
                        : [
                          BoxShadow(
                            color: _accentPrimary.withOpacity(
                              0.25 * _pulseAnimation.value,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                            spreadRadius: -2,
                          ),
                        ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shimmer effect
                  if (!isLoading)
                    Positioned(
                      top: 0,
                      left: 16,
                      right: 16,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0),
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Content
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child:
                        isLoading
                            ? SizedBox(
                              key: const ValueKey('loading'),
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: _textSecondary,
                                strokeWidth: 2,
                              ),
                            )
                            : Row(
                              key: const ValueKey('content'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _hasUserGenerated
                                      ? Icons.refresh_rounded
                                      : Icons.auto_awesome_rounded,
                                  size: 17,
                                  color: _bgPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _hasUserGenerated
                                      ? 'Update Chart'
                                      : 'Generate Kundali',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _bgPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTappableCard({
    required String key,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(key, true),
      onTapUp: (_) => _setPressed(key, false),
      onTapCancel: () => _setPressed(key, false),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedScale(
        scale: _isPressed(key) ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: child,
      ),
    );
  }

  void _showInfoSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
            decoration: const BoxDecoration(
              color: _bgSecondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _accentSecondary.withOpacity(0.2),
                        _accentSecondary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: _accentSecondary,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'About Kundali',
                  style: GoogleFonts.dmSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A Kundali is a celestial map showing planetary positions at your birth. It reveals insights into personality, life path, and cosmic influences.',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    height: 1.6,
                    color: _textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildInfoTile('☽', 'Moon', 'Emotions'),
                    const SizedBox(width: 8),
                    _buildInfoTile('☉', 'Sun', 'Identity'),
                    const SizedBox(width: 8),
                    _buildInfoTile('⬆', 'Rising', 'Persona'),
                  ],
                ),
                SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
              ],
            ),
          ),
    );
  }

  Widget _buildInfoTile(String symbol, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _surfaceColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor.withOpacity(0.5), width: 0.5),
        ),
        child: Column(
          children: [
            Text(symbol, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(fontSize: 10, color: _textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateKundali() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated && _isPrimary) {
      await AuthRequiredDialog.show(
        context,
        feature: 'Save Kundali',
        description: 'Sign in to save your Kundali.',
        onSkip: () => _proceedGeneration(save: false),
      );
      return;
    }
    _proceedGeneration(save: auth.isAuthenticated);
  }

  Future<void> _proceedGeneration({required bool save}) async {
    setState(() => _isLoading = true);

    final dt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final provider = context.read<KundliProvider>();

    await provider.generateKundali(
      name: _nameController.text,
      birthDateTime: dt,
      birthPlace: _placeController.text,
      latitude: _latitude ?? 28.6139,
      longitude: _longitude ?? 77.2090,
      timezone: _timezone,
      gender: _selectedGender,
      isPrimary: save ? _isPrimary : false,
      chartStyle: _chartStyle,
      language: _language,
    );

    if (mounted) {
      _isLoading = false;
      if (provider.error.isEmpty && provider.currentKundali != null) {
        _currentKundali = provider.currentKundali;
        _hasUserGenerated = true;
        HapticFeedback.mediumImpact();

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (_, __, ___) =>
                    KundliDisplayScreen(kundaliData: provider.currentKundali!),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.03, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      } else {
        setState(() {});
        if (provider.error.isNotEmpty) {
          _showErrorSnackbar(provider.error);
        }
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder:
          (ctx, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: _accentPrimary,
                surface: _bgSecondary,
                onSurface: _textPrimary,
              ),
              dialogBackgroundColor: _bgSecondary,
            ),
            child: child!,
          ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder:
          (ctx, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: _accentPrimary,
                surface: _bgSecondary,
                onSurface: _textPrimary,
              ),
              dialogBackgroundColor: _bgSecondary,
            ),
            child: child!,
          ),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
      HapticFeedback.selectionClick();
    }
  }

  void _showLocationSearch() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => _LocationSheet(
            current: _placeController.text,
            onSelect: (name, lat, lng) {
              setState(() {
                _placeController.text = name;
                _latitude = lat;
                _longitude = lng;
              });
              Navigator.pop(context);
            },
          ),
    );
  }
}

// Custom painter for subtle noise texture - optimized for performance
class _NoisePainter extends CustomPainter {
  // Pre-generated points for performance
  static List<Offset>? _cachedPoints;
  static Size? _cachedSize;
  
  @override
  void paint(Canvas canvas, Size size) {
    // Use cached points if size matches
    if (_cachedPoints == null || _cachedSize != size) {
    final random = math.Random(42);
      _cachedPoints = List.generate(
        300, // Reduced from 2000 to 300 for much better performance
        (_) => Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
      );
      _cachedSize = size;
    }
    
    final paint = Paint()..color = Colors.white;
    for (final point in _cachedPoints!) {
      canvas.drawCircle(point, 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Location search sheet
class _LocationSheet extends StatefulWidget {
  final String current;
  final void Function(String, double, double) onSelect;

  const _LocationSheet({required this.current, required this.onSelect});

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late AnimationController _animController;
  String _searchQuery = '';

  static const _bgSecondary = Color(0xFF131020);
  static const _surfaceColor = Color(0xFF1A1625);
  static const _borderColor = Color(0xFF2A2438);
  static const _textPrimary = Color(0xFFF8F7FC);
  static const _textMuted = Color(0xFF6B6478);
  static const _successColor = Color(0xFF6EE7B7);

  final _cities = [
    {'name': 'New Delhi, India', 'lat': 28.6139, 'lng': 77.2090},
    {'name': 'Mumbai, India', 'lat': 19.0760, 'lng': 72.8777},
    {'name': 'Bangalore, India', 'lat': 12.9716, 'lng': 77.5946},
    {'name': 'Chennai, India', 'lat': 13.0827, 'lng': 80.2707},
    {'name': 'Kolkata, India', 'lat': 22.5726, 'lng': 88.3639},
    {'name': 'Hyderabad, India', 'lat': 17.3850, 'lng': 78.4867},
    {'name': 'Pune, India', 'lat': 18.5204, 'lng': 73.8567},
    {'name': 'Jaipur, India', 'lat': 26.9124, 'lng': 75.7873},
    {'name': 'Ahmedabad, India', 'lat': 23.0225, 'lng': 72.5714},
    {'name': 'Surat, India', 'lat': 21.1702, 'lng': 72.8311},
  ];

  List<Map<String, dynamic>> get _filteredCities {
    if (_searchQuery.isEmpty) return _cities;
    return _cities
        .where(
          (c) => (c['name'] as String).toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _controller.text = widget.current;
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
    // Expand sheet height when keyboard is visible to keep list accessible
    final sheetHeight = isKeyboardVisible
        ? MediaQuery.of(context).size.height * 0.9
        : MediaQuery.of(context).size.height * 0.6;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
      ),
      child: FadeTransition(
        opacity: _animController,
        child: Container(
          height: sheetHeight,
          padding: EdgeInsets.only(
            bottom: keyboardHeight,
          ),
          decoration: const BoxDecoration(
            color: _bgSecondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Search field
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _borderColor.withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Icon(Icons.search_rounded, size: 17, color: _textMuted),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: _textPrimary,
                          ),
                          cursorColor: _successColor,
                          cursorWidth: 1.5,
                          decoration: InputDecoration(
                            hintText: 'Search city...',
                            hintStyle: GoogleFonts.dmSans(color: _textMuted),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                          onChanged: (v) => setState(() => _searchQuery = v),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _controller.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: _textMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Label
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _searchQuery.isEmpty ? 'Popular Cities' : 'Results',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _textMuted,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              // City list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filteredCities.length,
                  itemBuilder: (_, index) {
                    final city = _filteredCities[index];
                    final isSelected = widget.current == city['name'];

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 200 + (index * 40)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 8 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: _buildCityTile(city, isSelected),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityTile(Map<String, dynamic> city, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onSelect(
          city['name'] as String,
          city['lat'] as double,
          city['lng'] as double,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? _successColor.withOpacity(0.08)
                  : _surfaceColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color:
                isSelected
                    ? _successColor.withOpacity(0.25)
                    : Colors.transparent,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? _successColor.withOpacity(0.15)
                        : _borderColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                isSelected ? Icons.check_circle_rounded : Icons.place_outlined,
                size: 14,
                color: isSelected ? _successColor : _textMuted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city['name'] as String,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? _successColor : _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(city['lat'] as double).toStringAsFixed(2)}°N, ${(city['lng'] as double).toStringAsFixed(2)}°E',
                    style: GoogleFonts.dmMono(
                      fontSize: 10,
                      color: _textMuted,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, size: 16, color: _successColor),
          ],
        ),
      ),
    );
  }
}
