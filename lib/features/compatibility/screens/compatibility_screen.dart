import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/kundali_data_model.dart';
import '../../../shared/models/compatibility_result.dart';
import '../../../core/providers/kundli_provider.dart';
import '../../../core/providers/compatibility_provider.dart';
import '../../../core/services/compatibility_service.dart';

class CompatibilityScreen extends StatefulWidget {
  const CompatibilityScreen({super.key});

  @override
  State<CompatibilityScreen> createState() => _CompatibilityScreenState();
}

class _CompatibilityScreenState extends State<CompatibilityScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _scoreController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Tap states for microinteractions
  final Map<String, bool> _pressedStates = {};

  // Colors - matching app theme
  static const _bgPrimary = Color(0xFF0D0B14);
  static const _surfaceColor = Color(0xFF1A1625);
  static const _borderColor = Color(0xFF2A2438);
  static const _accentPrimary = Color(0xFFD4AF37);
  static const _accentSecondary = Color(0xFFA78BFA);
  static const _compatibilityAccent = Color(0xFFF472B6);
  static const _textPrimary = Color(0xFFF8F7FC);
  static const _textSecondary = Color(0xFF9B95A8);
  static const _textMuted = Color(0xFF6B6478);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  void _setPressed(String key, bool value) {
    setState(() => _pressedStates[key] = value);
  }

  bool _isPressed(String key) => _pressedStates[key] ?? false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPrimary,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Consumer<CompatibilityProvider>(
                        builder: (context, provider, _) {
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildProfileSelectionSection(provider),
                                const SizedBox(height: 20),
                                _buildMatchButton(provider),
                                if (provider.hasResult) ...[
                                  const SizedBox(height: 24),
                                  _buildResultsSection(provider.currentResult!),
                                ],
                                if (provider.matchHistory.isNotEmpty &&
                                    !provider.hasResult) ...[
                                  const SizedBox(height: 24),
                                  _buildHistorySection(provider),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
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
        // Pink accent glow for compatibility theme
        Positioned(
          top: -80,
          right: -50,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 200 + (_pulseController.value * 20),
                height: 200 + (_pulseController.value * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _compatibilityAccent.withOpacity(
                        0.08 + _pulseController.value * 0.02,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 150,
          left: -60,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_accentPrimary.withOpacity(0.04), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          _buildIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kundli Matching',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Ashtakoot Gun Milan',
                  style: GoogleFonts.dmSans(fontSize: 11, color: _textMuted),
                ),
              ],
            ),
          ),
          _buildIconButton(
            icon: Icons.history_rounded,
            onTap: () => _showHistorySheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final key = 'icon_${icon.hashCode}';
    return GestureDetector(
      onTapDown: (_) => _setPressed(key, true),
      onTapUp: (_) => _setPressed(key, false),
      onTapCancel: () => _setPressed(key, false),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedScale(
        scale: _isPressed(key) ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _surfaceColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(10),
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

  Widget _buildProfileSelectionSection(CompatibilityProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.people_alt_rounded,
              size: 14,
              color: _compatibilityAccent,
            ),
            const SizedBox(width: 6),
            Text(
              'Select Profiles',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildProfileCard(
                person: provider.person1,
                personNumber: 1,
                label: 'Person 1',
                icon: Icons.person_rounded,
                onTap: () => _showProfileSelector(1),
              ),
            ),
            const SizedBox(width: 12),
            // Swap button
            GestureDetector(
              onTap:
                  provider.canCalculate
                      ? () {
                        HapticFeedback.lightImpact();
                        provider.swapPersons();
                      }
                      : null,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color:
                      provider.canCalculate
                          ? _accentPrimary.withOpacity(0.15)
                          : _surfaceColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        provider.canCalculate
                            ? _accentPrimary.withOpacity(0.3)
                            : _borderColor.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.swap_horiz_rounded,
                  size: 18,
                  color: provider.canCalculate ? _accentPrimary : _textMuted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProfileCard(
                person: provider.person2,
                personNumber: 2,
                label: 'Person 2',
                icon: Icons.person_outline_rounded,
                onTap: () => _showProfileSelector(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileCard({
    required KundaliData? person,
    required int personNumber,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final key = 'profile_$personNumber';
    final hasProfile = person != null;

    return GestureDetector(
      onTapDown: (_) => _setPressed(key, true),
      onTapUp: (_) => _setPressed(key, false),
      onTapCancel: () => _setPressed(key, false),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedScale(
        scale: _isPressed(key) ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient:
                hasProfile
                    ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _compatibilityAccent.withOpacity(0.12),
                        _compatibilityAccent.withOpacity(0.04),
                      ],
                    )
                    : null,
            color: hasProfile ? null : _surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  hasProfile
                      ? _compatibilityAccent.withOpacity(0.3)
                      : _borderColor.withOpacity(0.4),
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      hasProfile
                          ? _compatibilityAccent.withOpacity(0.15)
                          : _borderColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        hasProfile
                            ? _compatibilityAccent.withOpacity(0.3)
                            : _borderColor.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child:
                    hasProfile
                        ? Center(
                          child: Text(
                            person.name.substring(0, 1).toUpperCase(),
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: _compatibilityAccent,
                            ),
                          ),
                        )
                        : Icon(Icons.add_rounded, size: 22, color: _textMuted),
              ),
              const SizedBox(height: 10),
              // Name or label
              Text(
                hasProfile ? person.name : label,
                style: GoogleFonts.dmSans(
                  fontSize: hasProfile ? 13 : 11,
                  fontWeight: hasProfile ? FontWeight.w600 : FontWeight.w500,
                  color: hasProfile ? _textPrimary : _textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              if (hasProfile) ...[
                const SizedBox(height: 4),
                // Moon Sign
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _accentSecondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    person.moonSign,
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: _accentSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Nakshatra
                Text(
                  person.birthNakshatra,
                  style: GoogleFonts.dmSans(fontSize: 9, color: _textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ] else ...[
                const SizedBox(height: 4),
                Text(
                  'Tap to select',
                  style: GoogleFonts.dmSans(fontSize: 9, color: _textMuted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchButton(CompatibilityProvider provider) {
    final canMatch = provider.canCalculate;
    final isCalculating = provider.isCalculating;

    return GestureDetector(
      onTap:
          canMatch && !isCalculating
              ? () async {
                HapticFeedback.mediumImpact();
                await provider.calculateMatch();
                if (provider.hasResult) {
                  _scoreController.forward(from: 0);
                }
              }
              : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient:
              canMatch
                  ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFD4AF37), Color(0xFFB8962F)],
                  )
                  : null,
          color: canMatch ? null : _surfaceColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          boxShadow:
              canMatch
                  ? [
                    BoxShadow(
                      color: _accentPrimary.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isCalculating) ...[
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _bgPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Calculating...',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _bgPrimary,
                ),
              ),
            ] else ...[
              Icon(
                Icons.favorite_rounded,
                size: 18,
                color: canMatch ? _bgPrimary : _textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                'Match Horoscopes',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: canMatch ? _bgPrimary : _textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection(CompatibilityResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Radial Score Chart
        _buildRadialScoreChart(result),
        const SizedBox(height: 20),
        // Verdict Banner
        _buildVerdictBanner(result),
        const SizedBox(height: 20),
        // Kuta Breakdown
        _buildKutaBreakdown(result),
        // Doshas Section
        if (result.doshas.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildDoshasSection(result.doshas),
        ],
        // Love Compatibility
        if (result.loveCompatibility != null) ...[
          const SizedBox(height: 20),
          _buildLoveCompatibilityCard(result.loveCompatibility!),
        ],
      ],
    );
  }

  Widget _buildRadialScoreChart(CompatibilityResult result) {
    return AnimatedBuilder(
      animation: _scoreController,
      builder: (context, child) {
        final animatedScore =
            (result.totalScore * _scoreController.value).round();
        final percentage = (animatedScore / 36) * 100;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _surfaceColor.withOpacity(0.6),
                _surfaceColor.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _borderColor.withOpacity(0.4),
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_graph_rounded,
                    size: 16,
                    color: _accentPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Compatibility Score',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Radial Chart
              SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(
                  painter: _RadialScorePainter(
                    score: animatedScore,
                    maxScore: 36,
                    progress: _scoreController.value,
                    primaryColor: Color(
                      CompatibilityService.getVerdictColorValue(
                        result.overallVerdict,
                      ),
                    ),
                    backgroundColor: _borderColor.withOpacity(0.3),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$animatedScore',
                          style: GoogleFonts.dmSans(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                            height: 1,
                          ),
                        ),
                        Text(
                          'out of 36',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: _textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: GoogleFonts.dmMono(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(
                              CompatibilityService.getVerdictColorValue(
                                result.overallVerdict,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Names
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    result.person1.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 14,
                      color: _compatibilityAccent,
                    ),
                  ),
                  Text(
                    result.person2.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerdictBanner(CompatibilityResult result) {
    final verdictColor = Color(
      CompatibilityService.getVerdictColorValue(result.overallVerdict),
    );
    final description = CompatibilityService.getVerdictDescription(
      result.overallVerdict,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            verdictColor.withOpacity(0.15),
            verdictColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: verdictColor.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getVerdictIcon(result.overallVerdict),
                size: 20,
                color: verdictColor,
              ),
              const SizedBox(width: 8),
              Text(
                '${result.overallVerdict} Match!',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: verdictColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: _textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getVerdictIcon(String verdict) {
    switch (verdict) {
      case 'Excellent':
        return Icons.stars_rounded;
      case 'Good':
        return Icons.thumb_up_rounded;
      case 'Average':
        return Icons.thumbs_up_down_rounded;
      case 'Poor':
        return Icons.warning_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Widget _buildKutaBreakdown(CompatibilityResult result) {
    final kutaOrder = [
      'varna',
      'vashya',
      'tara',
      'yoni',
      'grahaMaitri',
      'gana',
      'bhakoot',
      'nadi',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics_rounded, size: 14, color: _accentSecondary),
            const SizedBox(width: 6),
            Text(
              'Kuta Breakdown (Ashtakoot)',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Grid of kuta cards
        ...List.generate((kutaOrder.length / 2).ceil(), (rowIndex) {
          final startIdx = rowIndex * 2;
          return Padding(
            padding: EdgeInsets.only(bottom: rowIndex < 3 ? 8 : 0),
            child: Row(
              children: [
                Expanded(
                  child: _buildKutaCard(
                    kutaOrder[startIdx],
                    result.kutaScores[kutaOrder[startIdx]]!,
                    rowIndex * 100,
                  ),
                ),
                const SizedBox(width: 8),
                if (startIdx + 1 < kutaOrder.length)
                  Expanded(
                    child: _buildKutaCard(
                      kutaOrder[startIdx + 1],
                      result.kutaScores[kutaOrder[startIdx + 1]]!,
                      rowIndex * 100 + 50,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildKutaCard(String kutaKey, KutaScore kuta, int delayMs) {
    final color = CompatibilityProvider.getKutaColor(kutaKey);
    final icon = CompatibilityProvider.getKutaIcon(kutaKey);
    final isGood = kuta.obtained >= (kuta.maximum / 2);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _surfaceColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isGood ? color.withOpacity(0.3) : _borderColor.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 12, color: color),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isGood
                            ? const Color(0xFF10B981).withOpacity(0.15)
                            : const Color(0xFFEF4444).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${kuta.obtained}/${kuta.maximum}',
                    style: GoogleFonts.dmMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color:
                          isGood
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              kuta.name,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              kuta.description,
              style: GoogleFonts.dmSans(fontSize: 9, color: _textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: kuta.maximum > 0 ? kuta.obtained / kuta.maximum : 0,
                backgroundColor: _borderColor.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoshasSection(List<DoshaInfo> doshas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 14,
              color: const Color(0xFFFBBF24),
            ),
            const SizedBox(width: 6),
            Text(
              'Dosha Analysis',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...doshas.map(
          (dosha) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildDoshaCard(dosha),
          ),
        ),
      ],
    );
  }

  Widget _buildDoshaCard(DoshaInfo dosha) {
    final isCancelled = dosha.severity == 'Cancelled';
    final color =
        isCancelled
            ? const Color(0xFF10B981)
            : dosha.severity == 'High'
            ? const Color(0xFFEF4444)
            : const Color(0xFFFBBF24);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCancelled ? Icons.check_circle_rounded : Icons.error_rounded,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                dosha.name,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  dosha.severity,
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dosha.description,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: _textSecondary,
              height: 1.4,
            ),
          ),
          if (dosha.remedies.isNotEmpty && !isCancelled) ...[
            const SizedBox(height: 10),
            Text(
              'Remedies:',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  dosha.remedies
                      .take(3)
                      .map(
                        (remedy) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _surfaceColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _borderColor.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            remedy,
                            style: GoogleFonts.dmSans(
                              fontSize: 9,
                              color: _textSecondary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoveCompatibilityCard(LoveCompatibility love) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _compatibilityAccent.withOpacity(0.12),
            _compatibilityAccent.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _compatibilityAccent.withOpacity(0.25),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _compatibilityAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 18,
                  color: _compatibilityAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Love Compatibility',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    Text(
                      'Based on Sun Signs',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _compatibilityAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${love.percentage}%',
                  style: GoogleFonts.dmMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _compatibilityAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            love.description,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: _textSecondary,
              height: 1.4,
            ),
          ),
          if (love.strengths.isNotEmpty || love.challenges.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (love.strengths.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.add_circle_rounded,
                              size: 12,
                              color: const Color(0xFF10B981),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Strengths',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ...love.strengths
                            .take(2)
                            .map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  '• $s',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 9,
                                    color: _textMuted,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                if (love.strengths.isNotEmpty && love.challenges.isNotEmpty)
                  const SizedBox(width: 12),
                if (love.challenges.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.remove_circle_rounded,
                              size: 12,
                              color: const Color(0xFFFBBF24),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Challenges',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFBBF24),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ...love.challenges
                            .take(2)
                            .map(
                              (c) => Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  '• $c',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 9,
                                    color: _textMuted,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistorySection(CompatibilityProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history_rounded, size: 14, color: _accentPrimary),
            const SizedBox(width: 6),
            Text(
              'Recent Matches',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showHistorySheet(),
              child: Text(
                'See All',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _accentPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...provider.matchHistory
            .take(3)
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildHistoryCard(item),
              ),
            ),
      ],
    );
  }

  Widget _buildHistoryCard(MatchHistoryItem item) {
    final verdictColor = Color(
      CompatibilityService.getVerdictColorValue(item.verdict),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          // Score circle
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: verdictColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: verdictColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '${item.totalScore}',
                style: GoogleFonts.dmMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: verdictColor,
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
                  '${item.person1Name} & ${item.person2Name}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.person1MoonSign} • ${item.person2MoonSign}',
                  style: GoogleFonts.dmSans(fontSize: 10, color: _textMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: verdictColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.verdict,
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: verdictColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('d MMM').format(item.matchedAt),
                style: GoogleFonts.dmSans(fontSize: 9, color: _textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showProfileSelector(int personNumber) {
    final kundliProvider = context.read<KundliProvider>();
    final compatProvider = context.read<CompatibilityProvider>();
    final savedKundalis = kundliProvider.savedKundalis;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => _ProfileSelectorSheet(
            savedKundalis: savedKundalis,
            personNumber: personNumber,
            currentSelection:
                personNumber == 1
                    ? compatProvider.person1
                    : compatProvider.person2,
            onSelect: (kundali) {
              if (personNumber == 1) {
                compatProvider.setPerson1(kundali);
              } else {
                compatProvider.setPerson2(kundali);
              }
            },
          ),
    );
  }

  void _showHistorySheet() {
    final provider = context.read<CompatibilityProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => _MatchHistorySheet(
            history: provider.matchHistory,
            onDelete: (id) => provider.deleteHistoryItem(id),
            onClear: () => provider.clearHistory(),
          ),
    );
  }
}

// Radial Score Painter
class _RadialScorePainter extends CustomPainter {
  final int score;
  final int maxScore;
  final double progress;
  final Color primaryColor;
  final Color backgroundColor;

  _RadialScorePainter({
    required this.score,
    required this.maxScore,
    required this.progress,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    final strokeWidth = 12.0;

    // Background arc
    final bgPaint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      bgPaint,
    );

    // Progress arc
    final progressPaint =
        Paint()
          ..color = primaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / maxScore) * 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Glow effect
    final glowPaint =
        Paint()
          ..color = primaryColor.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 8
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadialScorePainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor;
  }
}

// Profile Selector Sheet
class _ProfileSelectorSheet extends StatefulWidget {
  final List<KundaliData> savedKundalis;
  final int personNumber;
  final KundaliData? currentSelection;
  final Function(KundaliData) onSelect;

  const _ProfileSelectorSheet({
    required this.savedKundalis,
    required this.personNumber,
    required this.currentSelection,
    required this.onSelect,
  });

  @override
  State<_ProfileSelectorSheet> createState() => _ProfileSelectorSheetState();
}

class _ProfileSelectorSheetState extends State<_ProfileSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showNewForm = false;

  // Form controllers for new profile
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  final _birthPlaceController = TextEditingController();
  double _latitude = 28.6139;
  double _longitude = 77.2090;

  static const _bgPrimary = Color(0xFF0D0B14);
  static const _surfaceColor = Color(0xFF1A1625);
  static const _borderColor = Color(0xFF2A2438);
  static const _textPrimary = Color(0xFFF8F7FC);
  static const _textMuted = Color(0xFF6B6478);
  static const _accentPrimary = Color(0xFFD4AF37);
  static const _compatibilityAccent = Color(0xFFF472B6);

  List<KundaliData> get filteredKundalis {
    if (_searchQuery.isEmpty) return widget.savedKundalis;
    return widget.savedKundalis
        .where((k) => k.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _birthPlaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: _bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: _borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  _showNewForm
                      ? 'Add New Profile'
                      : 'Select Person ${widget.personNumber}',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const Spacer(),
                if (_showNewForm)
                  GestureDetector(
                    onTap: () => setState(() => _showNewForm = false),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _compatibilityAccent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _showNewForm ? _buildNewProfileForm() : _buildProfileList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileList() {
    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _surfaceColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _borderColor.withOpacity(0.4),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 18, color: _textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: _textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search profiles...',
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: _textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Add New Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _showNewForm = true);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _accentPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _accentPrimary.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 18, color: _accentPrimary),
                  const SizedBox(width: 8),
                  Text(
                    'Add New Profile',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _accentPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // List
        Expanded(
          child:
              filteredKundalis.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_off_rounded,
                          size: 48,
                          color: _textMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No profiles found',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: _textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create a Kundli first or add new profile',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredKundalis.length,
                    itemBuilder: (context, index) {
                      final kundali = filteredKundalis[index];
                      final isSelected =
                          widget.currentSelection?.id == kundali.id;
                      return _buildKundaliItem(kundali, isSelected);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildKundaliItem(KundaliData kundali, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onSelect(kundali);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? LinearGradient(
                    colors: [
                      _compatibilityAccent.withOpacity(0.15),
                      _compatibilityAccent.withOpacity(0.05),
                    ],
                  )
                  : null,
          color: isSelected ? null : _surfaceColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? _compatibilityAccent.withOpacity(0.4)
                    : _borderColor.withOpacity(0.3),
            width: isSelected ? 1 : 0.5,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? _compatibilityAccent.withOpacity(0.2)
                        : _borderColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  kundali.name.substring(0, 1).toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? _compatibilityAccent : _textMuted,
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
                    kundali.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${kundali.moonSign} • ${kundali.birthNakshatra}',
                    style: GoogleFonts.dmSans(fontSize: 10, color: _textMuted),
                  ),
                  Text(
                    DateFormat('d MMM yyyy').format(kundali.birthDateTime),
                    style: GoogleFonts.dmSans(fontSize: 10, color: _textMuted),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: _compatibilityAccent,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewProfileForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          _buildFormField(
            label: 'Name',
            child: TextField(
              controller: _nameController,
              style: GoogleFonts.dmSans(fontSize: 14, color: _textPrimary),
              decoration: _inputDecoration('Enter name'),
            ),
          ),
          const SizedBox(height: 14),
          // Date of Birth
          _buildFormField(
            label: 'Date of Birth',
            child: GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _birthDate ?? DateTime(2000, 1, 1),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _birthDate = date);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _surfaceColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _borderColor.withOpacity(0.4),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _birthDate != null
                          ? DateFormat('d MMMM yyyy').format(_birthDate!)
                          : 'Select date',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: _birthDate != null ? _textPrimary : _textMuted,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: _textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Time of Birth
          _buildFormField(
            label: 'Time of Birth',
            child: GestureDetector(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime:
                      _birthTime ?? const TimeOfDay(hour: 12, minute: 0),
                );
                if (time != null) setState(() => _birthTime = time);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _surfaceColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _borderColor.withOpacity(0.4),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _birthTime != null
                          ? _birthTime!.format(context)
                          : 'Select time',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: _birthTime != null ? _textPrimary : _textMuted,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: _textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Birth Place
          _buildFormField(
            label: 'Birth Place',
            child: TextField(
              controller: _birthPlaceController,
              style: GoogleFonts.dmSans(fontSize: 14, color: _textPrimary),
              decoration: _inputDecoration('Enter city name'),
              onChanged: (value) {
                // In a real app, you'd use a places API
                // For now, use default Delhi coordinates
              },
            ),
          ),
          const SizedBox(height: 24),
          // Submit Button
          GestureDetector(
            onTap: _canSubmit ? _submitNewProfile : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient:
                    _canSubmit
                        ? const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFB8962F)],
                        )
                        : null,
                color: _canSubmit ? null : _surfaceColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Create & Select',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _canSubmit ? _bgPrimary : _textMuted,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  bool get _canSubmit =>
      _nameController.text.isNotEmpty &&
      _birthDate != null &&
      _birthTime != null &&
      _birthPlaceController.text.isNotEmpty;

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _textMuted,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(fontSize: 14, color: _textMuted),
      filled: true,
      fillColor: _surfaceColor.withOpacity(0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _borderColor.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _borderColor.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _accentPrimary.withOpacity(0.5),
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  void _submitNewProfile() {
    HapticFeedback.mediumImpact();

    final birthDateTime = DateTime(
      _birthDate!.year,
      _birthDate!.month,
      _birthDate!.day,
      _birthTime!.hour,
      _birthTime!.minute,
    );

    final newKundali = KundaliData.fromBirthDetails(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      birthDateTime: birthDateTime,
      birthPlace: _birthPlaceController.text,
      latitude: _latitude,
      longitude: _longitude,
      timezone: 'IST',
      gender: 'Unknown',
    );

    // Save to provider
    context.read<KundliProvider>().generateKundali(
      name: _nameController.text,
      birthDateTime: birthDateTime,
      birthPlace: _birthPlaceController.text,
      latitude: _latitude,
      longitude: _longitude,
      timezone: 'IST',
      gender: 'Unknown',
    );

    widget.onSelect(newKundali);
    Navigator.pop(context);
  }
}

// Match History Sheet
class _MatchHistorySheet extends StatelessWidget {
  final List<MatchHistoryItem> history;
  final Function(String) onDelete;
  final VoidCallback onClear;

  const _MatchHistorySheet({
    required this.history,
    required this.onDelete,
    required this.onClear,
  });

  static const _bgPrimary = Color(0xFF0D0B14);
  static const _surfaceColor = Color(0xFF1A1625);
  static const _borderColor = Color(0xFF2A2438);
  static const _textPrimary = Color(0xFFF8F7FC);
  static const _textMuted = Color(0xFF6B6478);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: _bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: _borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Match History',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const Spacer(),
                if (history.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onClear();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Clear All',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // List
          Expanded(
            child:
                history.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 48,
                            color: _textMuted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No match history',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        final verdictColor = Color(
                          CompatibilityService.getVerdictColorValue(
                            item.verdict,
                          ),
                        );

                        return Dismissible(
                          key: Key(item.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => onDelete(item.id),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete_rounded,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _surfaceColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _borderColor.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: verdictColor.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${item.totalScore}',
                                      style: GoogleFonts.dmMono(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: verdictColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${item.person1Name} & ${item.person2Name}',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _textPrimary,
                                        ),
                                      ),
                                      Text(
                                        DateFormat(
                                          'd MMM yyyy, h:mm a',
                                        ).format(item.matchedAt),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 10,
                                          color: _textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: verdictColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.verdict,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: verdictColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
