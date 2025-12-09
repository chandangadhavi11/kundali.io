import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../shared/constants.dart';

/// Dasha Tab - Shows Vimshottari Dasha with drill-down capability
/// Premium, elegant UI with clear visual hierarchy
class DashaTab extends StatelessWidget {
  final KundaliData kundaliData;

  const DashaTab({super.key, required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final dasha = kundaliData.dashaInfo;
    final now = DateTime.now();
    
    // Calculate dynamic remaining years based on current date
    final dynamicRemainingYears = _calculateDynamicRemainingYears(dasha, now);
    
    // Get current index in sequence
    final currentIndex = dasha.sequence.indexWhere((p) => p.planet == dasha.currentMahadasha);
    final completedPeriods = currentIndex >= 0 ? currentIndex : 0;
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════════════════
          // HERO SECTION - Current Dasha Overview
          // ═══════════════════════════════════════════════════════════════
          _DashaHeroCard(
            dasha: dasha,
            dynamicRemainingYears: dynamicRemainingYears,
            now: now,
            completedPeriods: completedPeriods,
          ),
          
          const SizedBox(height: 20),
          
          // ═══════════════════════════════════════════════════════════════
          // CURRENT PERIODS SECTION
          // ═══════════════════════════════════════════════════════════════
          _SectionHeader(
            icon: Icons.timeline_rounded,
            title: 'Active Periods',
            subtitle: 'Currently running Dasha levels',
            color: const Color(0xFF6EE7B7),
          ),
          const SizedBox(height: 12),
          
          // Current Mahadasha & Antardasha in a row
          Row(
            children: [
              Expanded(
                child: _CompactPeriodCard(
                  label: 'Mahadasha',
                  planet: dasha.currentMahadasha,
                  remainingYears: dynamicRemainingYears,
                  progress: _calculateProgress(dasha, now),
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 10),
              if (dasha.currentAntardasha != null || dasha.currentAntardashaDetail != null)
                Expanded(
                  child: _CompactPeriodCard(
                    label: 'Antardasha',
                    planet: dasha.currentAntardashaDetail?.planet ?? dasha.currentAntardasha ?? '',
                    remainingYears: _getAntardashaRemaining(dasha, now),
                    progress: _getAntardashaProgress(dasha, now),
                    isPrimary: false,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // ═══════════════════════════════════════════════════════════════
          // BIRTH CONFIGURATION
          // ═══════════════════════════════════════════════════════════════
          if (dasha.balanceYearsAtBirth != null || dasha.birthNakshatraLord != null) ...[
            _SectionHeader(
              icon: Icons.child_care_rounded,
              title: 'Birth Configuration',
              subtitle: 'Starting point of your Dasha cycle',
              color: const Color(0xFFFBBF24),
            ),
            const SizedBox(height: 12),
            _BirthConfigCard(dasha: dasha, birthDateTime: kundaliData.birthDateTime),
            const SizedBox(height: 24),
          ],
          
          // ═══════════════════════════════════════════════════════════════
          // LIFE TIMELINE - 120 Year Cycle
          // ═══════════════════════════════════════════════════════════════
          _SectionHeader(
            icon: Icons.view_timeline_rounded,
            title: 'Life Timeline',
            subtitle: '120-year Vimshottari cycle • Tap any period to explore',
            color: const Color(0xFFA78BFA),
          ),
          const SizedBox(height: 12),
          
          // Visual timeline bar
          _TimelineProgressBar(
            sequence: dasha.sequence,
            currentPlanet: dasha.currentMahadasha,
          ),
          
          const SizedBox(height: 16),
          
          // Dasha sequence list with calculated dates
          ..._buildDashaSequenceWithDates(dasha, now),
          
          const SizedBox(height: 16),
          
          // Info footer
          _DashaInfoFooter(),
        ],
      ),
    );
  }
  
  double _calculateProgress(DashaInfo dasha, DateTime now) {
    final totalYears = _getMahadashaDuration(dasha.currentMahadasha).toDouble();
    final remainingYears = _calculateDynamicRemainingYears(dasha, now);
    final elapsedYears = totalYears - remainingYears;
    return (elapsedYears / totalYears).clamp(0.0, 1.0);
  }
  
  double _getAntardashaRemaining(DashaInfo dasha, DateTime now) {
    final detail = dasha.currentAntardashaDetail;
    if (detail != null) {
      final daysRemaining = detail.endDate.difference(now).inDays;
      return daysRemaining > 0 ? daysRemaining / 365.25 : 0;
    }
    return dasha.antardashaRemainingYears ?? 0;
  }
  
  double _getAntardashaProgress(DashaInfo dasha, DateTime now) {
    final detail = dasha.currentAntardashaDetail;
    if (detail != null) {
      final remaining = _getAntardashaRemaining(dasha, now);
      final elapsed = detail.durationYears - remaining;
      return (elapsed / detail.durationYears).clamp(0.0, 1.0);
    }
    return 0.5;
  }
  
  /// Calculate dynamic remaining years based on current date
  double _calculateDynamicRemainingYears(DashaInfo dasha, DateTime now) {
    // If we have detailed mahadasha info with end date, calculate precisely
    if (dasha.mahadashaEndDate != null) {
      final daysRemaining = dasha.mahadashaEndDate!.difference(now).inDays;
      if (daysRemaining > 0) {
        return daysRemaining / 365.25;
      }
      return 0;
    }
    // Otherwise use the stored value (fallback)
    return dasha.remainingYears;
  }
  
  /// Build dasha sequence with calculated start/end dates
  List<Widget> _buildDashaSequenceWithDates(DashaInfo dasha, DateTime now) {
    final widgets = <Widget>[];
    
    // If we have mahadashaSequence with dates, use it
    if (dasha.mahadashaSequence != null && dasha.mahadashaSequence!.isNotEmpty) {
      for (var i = 0; i < dasha.mahadashaSequence!.length; i++) {
        final periodDetail = dasha.mahadashaSequence![i];
        final isCurrent = periodDetail.planet == dasha.currentMahadasha;
        final isPast = periodDetail.endDate.isBefore(now);
        final isFuture = periodDetail.startDate.isAfter(now);
        
        widgets.add(_DashaPeriodItemWithDates(
          periodDetail: periodDetail,
          index: i,
          isCurrent: isCurrent,
          isPast: isPast,
          isFuture: isFuture,
          dasha: dasha,
        ));
      }
    } else {
      // Fallback: Calculate dates from sequence using start date
      DateTime currentStart = dasha.startDate;
      
      for (var i = 0; i < dasha.sequence.length; i++) {
        final period = dasha.sequence[i];
        final endDate = currentStart.add(Duration(days: (period.years * 365.25).round()));
        final isCurrent = period.planet == dasha.currentMahadasha;
        final isPast = endDate.isBefore(now);
        final isFuture = currentStart.isAfter(now);
        
        widgets.add(_DashaPeriodItemFallback(
          period: period,
          index: i,
          isCurrent: isCurrent,
          isPast: isPast,
          isFuture: isFuture,
          startDate: currentStart,
          endDate: endDate,
          dasha: dasha,
        ));
        
        currentStart = endDate;
      }
    }
    
    return widgets;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION HEADER
// ═══════════════════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: KundliDisplayColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: KundliDisplayColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DASHA HERO CARD - Main overview
// ═══════════════════════════════════════════════════════════════════════════
class _DashaHeroCard extends StatelessWidget {
  final DashaInfo dasha;
  final double dynamicRemainingYears;
  final DateTime now;
  final int completedPeriods;

  const _DashaHeroCard({
    required this.dasha,
    required this.dynamicRemainingYears,
    required this.now,
    required this.completedPeriods,
  });

  @override
  Widget build(BuildContext context) {
    final totalYears = _getMahadashaDuration(dasha.currentMahadasha);
    final elapsedYears = totalYears - dynamicRemainingYears;
    final progressPercent = (elapsedYears / totalYears).clamp(0.0, 1.0);
    final planetColor = _getPlanetColor(dasha.currentMahadasha);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            planetColor.withOpacity(0.15),
            planetColor.withOpacity(0.05),
            KundliDisplayColors.surfaceColor.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: planetColor.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: planetColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row with planet symbol and status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large planet symbol
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: planetColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: planetColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getPlanetSymbol(dasha.currentMahadasha),
                    style: TextStyle(
                      fontSize: 36,
                      color: planetColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6EE7B7).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6EE7B7),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ACTIVE NOW',
                                style: GoogleFonts.dmMono(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF6EE7B7),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${dasha.currentMahadasha} Mahadasha',
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: KundliDisplayColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPlanetDescription(dasha.currentMahadasha),
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: KundliDisplayColors.textMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress section
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Progress bar with labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: KundliDisplayColors.textMuted,
                      ),
                    ),
                    Text(
                      '${(progressPercent * 100).toStringAsFixed(1)}%',
                      style: GoogleFonts.dmMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: planetColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress bar
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: KundliDisplayColors.borderColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progressPercent,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              planetColor.withOpacity(0.7),
                              planetColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: planetColor.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stats row
                Row(
                  children: [
                    _HeroStatItem(
                      icon: Icons.hourglass_bottom_rounded,
                      label: 'Remaining',
                      value: _formatDuration(dynamicRemainingYears),
                      color: planetColor,
                    ),
                    Container(
                      width: 1,
                      height: 28,
                      color: KundliDisplayColors.borderColor.withOpacity(0.3),
                    ),
                    _HeroStatItem(
                      icon: Icons.timer_outlined,
                      label: 'Duration',
                      value: '$totalYears years',
                      color: KundliDisplayColors.textMuted,
                    ),
                    Container(
                      width: 1,
                      height: 28,
                      color: KundliDisplayColors.borderColor.withOpacity(0.3),
                    ),
                    _HeroStatItem(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Completed',
                      value: '$completedPeriods/9',
                      color: const Color(0xFF6EE7B7),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Dates row
          if (dasha.mahadashaStartDate != null || dasha.mahadashaEndDate != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (dasha.mahadashaStartDate != null)
                  Expanded(
                    child: _DateBadge(
                      label: 'Started',
                      date: dasha.mahadashaStartDate!,
                      icon: Icons.play_circle_outline_rounded,
                    ),
                  ),
                const SizedBox(width: 10),
                if (dasha.mahadashaEndDate != null)
                  Expanded(
                    child: _DateBadge(
                      label: 'Ends',
                      date: dasha.mahadashaEndDate!,
                      icon: Icons.stop_circle_outlined,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  String _getPlanetDescription(String planet) {
    const descriptions = {
      'Sun': 'Period of self-expression, authority, and leadership',
      'Moon': 'Period of emotions, mind, and nurturing energies',
      'Mars': 'Period of action, courage, and determination',
      'Mercury': 'Period of intellect, communication, and learning',
      'Jupiter': 'Period of wisdom, expansion, and good fortune',
      'Venus': 'Period of love, beauty, and material comforts',
      'Saturn': 'Period of discipline, karma, and life lessons',
      'Rahu': 'Period of worldly desires and unconventional paths',
      'Ketu': 'Period of spirituality and past-life influences',
    };
    return descriptions[planet] ?? 'Planetary period of influence';
  }
}

class _HeroStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _HeroStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.dmMono(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: KundliDisplayColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 8,
              color: KundliDisplayColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final String label;
  final DateTime date;
  final IconData icon;

  const _DateBadge({
    required this.label,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: KundliDisplayColors.textMuted),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  color: KundliDisplayColors.textMuted,
                ),
              ),
              Text(
                _formatDate(date),
                style: GoogleFonts.dmMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: KundliDisplayColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// COMPACT PERIOD CARD
// ═══════════════════════════════════════════════════════════════════════════
class _CompactPeriodCard extends StatelessWidget {
  final String label;
  final String planet;
  final double remainingYears;
  final double progress;
  final bool isPrimary;

  const _CompactPeriodCard({
    required this.label,
    required this.planet,
    required this.remainingYears,
    required this.progress,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getPlanetColor(planet);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(isPrimary ? 0.08 : 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(isPrimary ? 0.2 : 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _getPlanetSymbol(planet),
                    style: TextStyle(fontSize: 14, color: color),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        color: KundliDisplayColors.textMuted,
                      ),
                    ),
                    Text(
                      planet,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: KundliDisplayColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Mini progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: KundliDisplayColors.borderColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(color.withOpacity(0.7)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatDuration(remainingYears) + ' left',
            style: GoogleFonts.dmMono(
              fontSize: 9,
              color: KundliDisplayColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BIRTH CONFIG CARD
// ═══════════════════════════════════════════════════════════════════════════
class _BirthConfigCard extends StatelessWidget {
  final DashaInfo dasha;
  final DateTime birthDateTime;

  const _BirthConfigCard({required this.dasha, required this.birthDateTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: KundliDisplayColors.borderColor.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          if (dasha.birthNakshatraLord != null) ...[
            Expanded(
              child: _ConfigItem(
                icon: Icons.stars_rounded,
                label: 'Nakshatra Lord',
                value: dasha.birthNakshatraLord!,
                color: _getPlanetColor(dasha.birthNakshatraLord!),
              ),
            ),
          ],
          if (dasha.birthNakshatraLord != null && dasha.balanceYearsAtBirth != null)
            Container(
              width: 1,
              height: 36,
              color: KundliDisplayColors.borderColor.withOpacity(0.3),
            ),
          if (dasha.balanceYearsAtBirth != null) ...[
            Expanded(
              child: _ConfigItem(
                icon: Icons.hourglass_top_rounded,
                label: 'Balance at Birth',
                value: _formatDuration(dasha.balanceYearsAtBirth!),
                color: const Color(0xFFFBBF24),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfigItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ConfigItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color.withOpacity(0.7)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 9,
                color: KundliDisplayColors.textMuted,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TIMELINE PROGRESS BAR
// ═══════════════════════════════════════════════════════════════════════════
class _TimelineProgressBar extends StatelessWidget {
  final List<DashaPeriod> sequence;
  final String currentPlanet;

  const _TimelineProgressBar({
    required this.sequence,
    required this.currentPlanet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: sequence.asMap().entries.map((entry) {
          final period = entry.value;
          final isCurrent = period.planet == currentPlanet;
          final isPast = entry.key < sequence.indexWhere((p) => p.planet == currentPlanet);
          final color = _getPlanetColor(period.planet);
          
          return Expanded(
            flex: period.years,
            child: Tooltip(
              message: '${period.planet}: ${period.years} years',
              child: Container(
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? color
                      : isPast
                          ? color.withOpacity(0.4)
                          : color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: isCurrent
                      ? Border.all(color: Colors.white.withOpacity(0.5), width: 1)
                      : null,
                ),
                child: Center(
                  child: Text(
                    _getPlanetSymbol(period.planet),
                    style: TextStyle(
                      fontSize: 10,
                      color: isCurrent || isPast
                          ? Colors.white
                          : color,
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
}

// ═══════════════════════════════════════════════════════════════════════════
// INFO FOOTER
// ═══════════════════════════════════════════════════════════════════════════
class _DashaInfoFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: KundliDisplayColors.borderColor.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 14,
            color: KundliDisplayColors.textMuted.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Vimshottari Dasha is a 120-year cycle based on Moon\'s nakshatra at birth. Tap any period to see sub-periods (Antardasha, Pratyantara, etc.)',
              style: GoogleFonts.dmSans(
                fontSize: 9,
                color: KundliDisplayColors.textMuted.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// Get Mahadasha duration in years for a planet
int _getMahadashaDuration(String planet) {
  const durations = {
    'Ketu': 7,
    'Venus': 20,
    'Sun': 6,
    'Moon': 10,
    'Mars': 7,
    'Rahu': 18,
    'Jupiter': 16,
    'Saturn': 19,
    'Mercury': 17,
  };
  return durations[planet] ?? 10;
}

// ═══════════════════════════════════════════════════════════════════════════
// DASHA PERIOD ITEM WITH DATES (Premium Design)
// ═══════════════════════════════════════════════════════════════════════════
class _DashaPeriodItemWithDates extends StatelessWidget {
  final DashaPeriodDetail periodDetail;
  final int index;
  final bool isCurrent;
  final bool isPast;
  final bool isFuture;
  final DashaInfo dasha;

  const _DashaPeriodItemWithDates({
    required this.periodDetail,
    required this.index,
    required this.isCurrent,
    required this.isPast,
    required this.isFuture,
    required this.dasha,
  });

  @override
  Widget build(BuildContext context) {
    final planetColor = _getPlanetColor(periodDetail.planet);
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 200 + (index * 25)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 6 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _showDashaPeriodSheet(context, periodDetail, []),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isCurrent
                ? planetColor.withOpacity(0.08)
                : isPast
                    ? KundliDisplayColors.surfaceColor.withOpacity(0.2)
                    : KundliDisplayColors.surfaceColor.withOpacity(0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCurrent
                  ? planetColor.withOpacity(0.35)
                  : KundliDisplayColors.borderColor.withOpacity(isPast ? 0.15 : 0.3),
              width: isCurrent ? 1.5 : 0.5,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: planetColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Planet symbol with glow for current
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isCurrent
                          ? [planetColor.withOpacity(0.25), planetColor.withOpacity(0.1)]
                          : [planetColor.withOpacity(isPast ? 0.06 : 0.12), planetColor.withOpacity(isPast ? 0.03 : 0.06)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: planetColor.withOpacity(isCurrent ? 0.4 : 0.15),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getPlanetSymbol(periodDetail.planet),
                      style: TextStyle(
                        fontSize: 18,
                        color: isPast ? planetColor.withOpacity(0.5) : planetColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Planet name and dates
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            periodDetail.planet,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                              color: isPast
                                  ? KundliDisplayColors.textMuted
                                  : KundliDisplayColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6EE7B7).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF6EE7B7),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'NOW',
                                    style: GoogleFonts.dmMono(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF6EE7B7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (isPast && !isCurrent)
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: KundliDisplayColors.textMuted.withOpacity(0.4),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.date_range_rounded,
                            size: 11,
                            color: KundliDisplayColors.textMuted.withOpacity(isPast ? 0.4 : 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatDateShort(periodDetail.startDate)} → ${_formatDateShort(periodDetail.endDate)}',
                            style: GoogleFonts.dmMono(
                              fontSize: 10,
                              color: isPast
                                  ? KundliDisplayColors.textMuted.withOpacity(0.4)
                                  : KundliDisplayColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Duration badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: planetColor.withOpacity(isPast ? 0.05 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${periodDetail.durationYears.round()}',
                        style: GoogleFonts.dmMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isPast ? KundliDisplayColors.textMuted.withOpacity(0.5) : planetColor,
                        ),
                      ),
                      Text(
                        'years',
                        style: GoogleFonts.dmSans(
                          fontSize: 8,
                          color: KundliDisplayColors.textMuted.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: KundliDisplayColors.textMuted.withOpacity(isPast ? 0.2 : 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DASHA PERIOD ITEM FALLBACK (Premium Design)
// ═══════════════════════════════════════════════════════════════════════════
class _DashaPeriodItemFallback extends StatelessWidget {
  final DashaPeriod period;
  final int index;
  final bool isCurrent;
  final bool isPast;
  final bool isFuture;
  final DateTime startDate;
  final DateTime endDate;
  final DashaInfo dasha;

  const _DashaPeriodItemFallback({
    required this.period,
    required this.index,
    required this.isCurrent,
    required this.isPast,
    required this.isFuture,
    required this.startDate,
    required this.endDate,
    required this.dasha,
  });

  @override
  Widget build(BuildContext context) {
    final planetColor = _getPlanetColor(period.planet);
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 200 + (index * 25)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 6 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _showDashaDetailsFallback(context, period.planet, startDate, endDate, period.years, dasha),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isCurrent
                ? planetColor.withOpacity(0.08)
                : isPast
                    ? KundliDisplayColors.surfaceColor.withOpacity(0.2)
                    : KundliDisplayColors.surfaceColor.withOpacity(0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCurrent
                  ? planetColor.withOpacity(0.35)
                  : KundliDisplayColors.borderColor.withOpacity(isPast ? 0.15 : 0.3),
              width: isCurrent ? 1.5 : 0.5,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: planetColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Planet symbol
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isCurrent
                          ? [planetColor.withOpacity(0.25), planetColor.withOpacity(0.1)]
                          : [planetColor.withOpacity(isPast ? 0.06 : 0.12), planetColor.withOpacity(isPast ? 0.03 : 0.06)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: planetColor.withOpacity(isCurrent ? 0.4 : 0.15),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getPlanetSymbol(period.planet),
                      style: TextStyle(
                        fontSize: 18,
                        color: isPast ? planetColor.withOpacity(0.5) : planetColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Planet name and dates
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            period.planet,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                              color: isPast
                                  ? KundliDisplayColors.textMuted
                                  : KundliDisplayColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6EE7B7).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF6EE7B7),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'NOW',
                                    style: GoogleFonts.dmMono(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF6EE7B7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (isPast && !isCurrent)
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: KundliDisplayColors.textMuted.withOpacity(0.4),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.date_range_rounded,
                            size: 11,
                            color: KundliDisplayColors.textMuted.withOpacity(isPast ? 0.4 : 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatDateShort(startDate)} → ${_formatDateShort(endDate)}',
                            style: GoogleFonts.dmMono(
                              fontSize: 10,
                              color: isPast
                                  ? KundliDisplayColors.textMuted.withOpacity(0.4)
                                  : KundliDisplayColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Duration badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: planetColor.withOpacity(isPast ? 0.05 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${period.years}',
                        style: GoogleFonts.dmMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isPast ? KundliDisplayColors.textMuted.withOpacity(0.5) : planetColor,
                        ),
                      ),
                      Text(
                        'years',
                        style: GoogleFonts.dmSans(
                          fontSize: 8,
                          color: KundliDisplayColors.textMuted.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: KundliDisplayColors.textMuted.withOpacity(isPast ? 0.2 : 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Show dasha details with fallback (create DashaPeriodDetail on the fly)
void _showDashaDetailsFallback(
  BuildContext context,
  String planet,
  DateTime startDate,
  DateTime endDate,
  int years,
  DashaInfo dasha,
) {
  // First check if we have it in mahadashaSequence
  if (dasha.mahadashaSequence != null && dasha.mahadashaSequence!.isNotEmpty) {
    try {
      final existing = dasha.mahadashaSequence!.firstWhere(
        (m) => m.planet == planet,
      );
      _showDashaPeriodSheet(context, existing, []);
      return;
    } catch (_) {
      // Not found, create a temporary one
    }
  }
  
  // Create a temporary DashaPeriodDetail with sub-periods
  final subPeriods = KundaliCalculationService.calculateSubDashas(
    parentPath: planet,
    parentPlanet: planet,
    parentDuration: years.toDouble(),
    startDate: startDate,
    level: DashaLevel.antardasha,
    maxDepth: 1,
  );
  
  final periodDetail = DashaPeriodDetail(
    planet: planet,
    fullPath: planet,
    durationYears: years.toDouble(),
    startDate: startDate,
    endDate: endDate,
    level: DashaLevel.mahadasha,
    subPeriods: subPeriods,
  );
  
  _showDashaPeriodSheet(context, periodDetail, []);
}

// ============ Dasha Period Bottom Sheet ============
void _showDashaPeriodSheet(
  BuildContext context,
  DashaPeriodDetail period,
  List<String> breadcrumbs,
) {
  final levelColors = {
    DashaLevel.mahadasha: const Color(0xFFE8B931),
    DashaLevel.antardasha: const Color(0xFFA78BFA),
    DashaLevel.pratyantara: const Color(0xFF6EE7B7),
    DashaLevel.sookshma: const Color(0xFF60A5FA),
    DashaLevel.prana: const Color(0xFFF472B6),
  };

  final levelColor = levelColors[period.level] ?? KundliDisplayColors.accentSecondary;
  final newBreadcrumbs = [...breadcrumbs, period.planet];
  final now = DateTime.now();
  final isCurrentPeriod = period.containsDate(now);

  final hasSubPeriods = period.subPeriods != null && period.subPeriods!.isNotEmpty;
  final nextLevel = _getNextLevel(period.level);
  final canDrillDeeper = nextLevel != null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: KundliDisplayColors.bgSecondary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: levelColor.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: KundliDisplayColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            _DashaPeriodHeader(
              period: period,
              breadcrumbs: breadcrumbs,
              levelColor: levelColor,
              isCurrentPeriod: isCurrentPeriod,
            ),
            // Sub-periods section header
            if (canDrillDeeper)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      '${_getLevelDisplayName(nextLevel)} Periods',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: KundliDisplayColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (hasSubPeriods)
                      Text(
                        '(${period.subPeriods!.length})',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: KundliDisplayColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            // Sub-periods list
            Expanded(
              child: hasSubPeriods
                  ? _SubPeriodsListView(
                      period: period,
                      scrollController: scrollController,
                      newBreadcrumbs: newBreadcrumbs,
                      levelColors: levelColors,
                      now: now,
                    )
                  : _LoadingPlaceholder(),
            ),
          ],
        ),
      ),
    ),
  );
}

// ============ Dasha Period Header ============
class _DashaPeriodHeader extends StatelessWidget {
  final DashaPeriodDetail period;
  final List<String> breadcrumbs;
  final Color levelColor;
  final bool isCurrentPeriod;

  const _DashaPeriodHeader({
    required this.period,
    required this.breadcrumbs,
    required this.levelColor,
    required this.isCurrentPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs
          if (breadcrumbs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 14,
                      color: KundliDisplayColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      breadcrumbs.join(' → '),
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: KundliDisplayColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          // Period info row
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: levelColor.withOpacity(0.3), width: 1),
                ),
                child: Center(
                  child: Text(
                    _getPlanetSymbol(period.planet),
                    style: TextStyle(fontSize: 22, color: levelColor),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: levelColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            period.levelName,
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: levelColor,
                            ),
                          ),
                        ),
                        if (isCurrentPeriod) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6EE7B7).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ACTIVE',
                              style: GoogleFonts.dmMono(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF6EE7B7),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${period.planet} ${period.levelName}',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: KundliDisplayColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Period dates and duration
          _PeriodDateInfo(period: period, levelColor: levelColor),
        ],
      ),
    );
  }
}

// ============ Period Date Info ============
class _PeriodDateInfo extends StatelessWidget {
  final DashaPeriodDetail period;
  final Color levelColor;

  const _PeriodDateInfo({required this.period, required this.levelColor});

  @override
  Widget build(BuildContext context) {
    final needsTime = _needsTimeDisplay(period.level);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: KundliDisplayColors.borderColor.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          _DateColumn(
            label: 'Start',
            date: period.startDate,
            needsTime: needsTime,
          ),
          Container(width: 1, height: 28, color: KundliDisplayColors.borderColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _DateColumn(
                label: 'End',
                date: period.endDate,
                needsTime: needsTime,
              ),
            ),
          ),
          Container(width: 1, height: 28, color: KundliDisplayColors.borderColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration',
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      color: KundliDisplayColors.textMuted,
                    ),
                  ),
                  Text(
                    _formatDuration(period.durationYears),
                    style: GoogleFonts.dmMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: levelColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateColumn extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool needsTime;

  const _DateColumn({
    required this.label,
    required this.date,
    required this.needsTime,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              color: KundliDisplayColors.textMuted,
            ),
          ),
          Text(
            needsTime ? _formatDateWithTime(date) : _formatDate(date),
            style: GoogleFonts.dmMono(
              fontSize: needsTime ? 10 : 11,
              fontWeight: FontWeight.w500,
              color: KundliDisplayColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Sub Periods List View ============
class _SubPeriodsListView extends StatelessWidget {
  final DashaPeriodDetail period;
  final ScrollController scrollController;
  final List<String> newBreadcrumbs;
  final Map<DashaLevel, Color> levelColors;
  final DateTime now;

  const _SubPeriodsListView({
    required this.period,
    required this.scrollController,
    required this.newBreadcrumbs,
    required this.levelColors,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: period.subPeriods!.length,
      itemBuilder: (context, index) {
        final subPeriod = period.subPeriods![index];
        final isSubCurrent = subPeriod.containsDate(now);
        final subLevelColor = levelColors[subPeriod.level] ?? KundliDisplayColors.textMuted;
        final canDrillDeeperSub = _getNextLevel(subPeriod.level) != null;

        return _SubPeriodItem(
          subPeriod: subPeriod,
          isSubCurrent: isSubCurrent,
          subLevelColor: subLevelColor,
          canDrillDeeperSub: canDrillDeeperSub,
          newBreadcrumbs: newBreadcrumbs,
        );
      },
    );
  }
}

class _SubPeriodItem extends StatelessWidget {
  final DashaPeriodDetail subPeriod;
  final bool isSubCurrent;
  final Color subLevelColor;
  final bool canDrillDeeperSub;
  final List<String> newBreadcrumbs;

  const _SubPeriodItem({
    required this.subPeriod,
    required this.isSubCurrent,
    required this.subLevelColor,
    required this.canDrillDeeperSub,
    required this.newBreadcrumbs,
  });

  @override
  Widget build(BuildContext context) {
    final needsTime = _needsTimeDisplay(subPeriod.level);

    return GestureDetector(
      onTap: canDrillDeeperSub
          ? () {
              Navigator.pop(context);
              final deeperPeriod = _ensureSubPeriods(subPeriod);
              _showDashaPeriodSheet(context, deeperPeriod, newBreadcrumbs);
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSubCurrent
              ? subLevelColor.withOpacity(0.1)
              : KundliDisplayColors.surfaceColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSubCurrent
                ? subLevelColor.withOpacity(0.3)
                : KundliDisplayColors.borderColor.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getPlanetColor(subPeriod.planet).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _getPlanetSymbol(subPeriod.planet),
                  style: TextStyle(
                    fontSize: 14,
                    color: _getPlanetColor(subPeriod.planet),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        subPeriod.planet,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: isSubCurrent ? FontWeight.w600 : FontWeight.w500,
                          color: KundliDisplayColors.textPrimary,
                        ),
                      ),
                      if (isSubCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6EE7B7).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'NOW',
                            style: GoogleFonts.dmMono(
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6EE7B7),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    needsTime
                        ? '${_formatDateShortWithTime(subPeriod.startDate)} - ${_formatDateShortWithTime(subPeriod.endDate)}'
                        : '${_formatDateShort(subPeriod.startDate)} - ${_formatDateShort(subPeriod.endDate)}',
                    style: GoogleFonts.dmMono(
                      fontSize: needsTime ? 8 : 9,
                      color: KundliDisplayColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatDuration(subPeriod.durationYears),
              style: GoogleFonts.dmMono(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: KundliDisplayColors.textMuted,
              ),
            ),
            if (canDrillDeeperSub) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: KundliDisplayColors.textMuted.withOpacity(0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hourglass_empty_rounded,
              size: 48,
              color: KundliDisplayColors.textMuted.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Sub-periods calculating...',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: KundliDisplayColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Please wait or try again',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: KundliDisplayColors.textMuted.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ Helper Functions ============

Color _getPlanetColor(String planet) {
  const colors = {
    'Sun': Color(0xFFD4AF37),
    'Moon': Color(0xFF6EE7B7),
    'Mars': Color(0xFFF87171),
    'Mercury': Color(0xFF34D399),
    'Jupiter': Color(0xFFFBBF24),
    'Venus': Color(0xFFF472B6),
    'Saturn': Color(0xFF9CA3AF),
    'Rahu': Color(0xFFA78BFA),
    'Ketu': Color(0xFFC2410C),
  };
  return colors[planet] ?? Colors.grey;
}

String _getPlanetSymbol(String planet) {
  const symbols = {
    'Sun': '☉',
    'Moon': '☽',
    'Mars': '♂',
    'Mercury': '☿',
    'Jupiter': '♃',
    'Venus': '♀',
    'Saturn': '♄',
    'Rahu': '☊',
    'Ketu': '☋',
  };
  return symbols[planet] ?? planet.substring(0, 2);
}

DashaLevel? _getNextLevel(DashaLevel current) {
  switch (current) {
    case DashaLevel.mahadasha:
      return DashaLevel.antardasha;
    case DashaLevel.antardasha:
      return DashaLevel.pratyantara;
    case DashaLevel.pratyantara:
      return DashaLevel.sookshma;
    case DashaLevel.sookshma:
      return DashaLevel.prana;
    case DashaLevel.prana:
      return null;
  }
}

String _getLevelDisplayName(DashaLevel level) {
  switch (level) {
    case DashaLevel.mahadasha:
      return 'Mahadasha';
    case DashaLevel.antardasha:
      return 'Antardasha';
    case DashaLevel.pratyantara:
      return 'Pratyantara';
    case DashaLevel.sookshma:
      return 'Sookshma';
    case DashaLevel.prana:
      return 'Prana';
  }
}

bool _needsTimeDisplay(DashaLevel level) {
  return level == DashaLevel.sookshma || level == DashaLevel.prana;
}

DashaPeriodDetail _ensureSubPeriods(DashaPeriodDetail period) {
  if (period.subPeriods != null && period.subPeriods!.isNotEmpty) {
    return period;
  }

  final nextLevel = _getNextLevel(period.level);
  if (nextLevel == null) return period;

  final subPeriods = KundaliCalculationService.calculateSubDashas(
    parentPath: period.fullPath,
    parentPlanet: period.planet,
    parentDuration: period.durationYears,
    startDate: period.startDate,
    level: nextLevel,
    maxDepth: 1,
  );

  return DashaPeriodDetail(
    planet: period.planet,
    fullPath: period.fullPath,
    durationYears: period.durationYears,
    startDate: period.startDate,
    endDate: period.endDate,
    level: period.level,
    subPeriods: subPeriods,
  );
}

String _formatDate(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatDateWithTime(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute';
}

String _formatDateShort(DateTime date) {
  return '${date.day}/${date.month}/${date.year.toString().substring(2)}';
}

String _formatDateShortWithTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day}/${date.month} $hour:$minute';
}

String _formatDuration(double durationYears) {
  final totalDays = durationYears * 365.25;

  if (totalDays >= 365) {
    final years = totalDays ~/ 365.25;
    final remainingDays = totalDays - (years * 365.25);
    final months = remainingDays ~/ 30.44;
    final days = (remainingDays - (months * 30.44)).round();
    return '$years y, $months m, $days d';
  } else if (totalDays >= 30) {
    final months = totalDays ~/ 30.44;
    final days = (totalDays - (months * 30.44)).round();
    return '$months m, $days d';
  } else if (totalDays >= 1) {
    final days = totalDays.floor();
    final hours = ((totalDays - days) * 24).round();
    if (hours > 0) return '$days d, $hours h';
    return '$days days';
  } else {
    final totalHours = totalDays * 24;
    if (totalHours >= 1) {
      final hours = totalHours.floor();
      final minutes = ((totalHours - hours) * 60).round();
      if (minutes > 0) return '$hours h, $minutes m';
      return '$hours hours';
    } else {
      final minutes = (totalHours * 60).round();
      if (minutes > 0) return '$minutes min';
      return '< 1 min';
    }
  }
}

