import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../../shared/constants.dart';
import 'dasha_shared_widgets.dart';

/// Vimshottari Dasha View - Shows the 120-year Vimshottari Dasha with drill-down
class VimshottariDashaView extends StatelessWidget {
  final KundaliData kundaliData;

  const VimshottariDashaView({super.key, required this.kundaliData});

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
          // Hero Section
          _VimshottariHeroCard(
            dasha: dasha,
            dynamicRemainingYears: dynamicRemainingYears,
            now: now,
            completedPeriods: completedPeriods,
          ),
          
          const SizedBox(height: 20),
          
          // Current Periods Section
          DashaSectionHeader(
            icon: Icons.timeline_rounded,
            title: 'Active Periods',
            subtitle: 'Currently running Dasha levels',
            color: const Color(0xFF6EE7B7),
          ),
          const SizedBox(height: 12),
          
          // Current Mahadasha & Antardasha
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
          
          // Birth Configuration
          if (dasha.balanceYearsAtBirth != null || dasha.birthNakshatraLord != null) ...[
            DashaSectionHeader(
              icon: Icons.child_care_rounded,
              title: 'Birth Configuration',
              subtitle: 'Starting point of your Dasha cycle',
              color: const Color(0xFFFBBF24),
            ),
            const SizedBox(height: 12),
            _BirthConfigCard(dasha: dasha, birthDateTime: kundaliData.birthDateTime),
            const SizedBox(height: 24),
          ],
          
          // Life Timeline
          DashaSectionHeader(
            icon: Icons.view_timeline_rounded,
            title: 'Life Timeline',
            subtitle: '120-year Vimshottari cycle • Tap any period to explore',
            color: DashaTypeColors.vimshottariPrimary,
          ),
          const SizedBox(height: 12),
          
          // Timeline bar
          _TimelineProgressBar(
            sequence: dasha.sequence,
            currentPlanet: dasha.currentMahadasha,
          ),
          
          const SizedBox(height: 16),
          
          // Dasha sequence with dates
          ..._buildDashaSequenceWithDates(context, dasha, now),
          
          const SizedBox(height: 16),
          
          // Info footer
          const DashaInfoFooter(
            text: 'Vimshottari Dasha is a 120-year cycle based on Moon\'s nakshatra at birth. Tap any period to see sub-periods (Antardasha, Pratyantara, etc.)',
          ),
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
  
  double _calculateDynamicRemainingYears(DashaInfo dasha, DateTime now) {
    if (dasha.mahadashaEndDate != null) {
      final daysRemaining = dasha.mahadashaEndDate!.difference(now).inDays;
      if (daysRemaining > 0) {
        return daysRemaining / 365.25;
      }
      return 0;
    }
    return dasha.remainingYears;
  }
  
  List<Widget> _buildDashaSequenceWithDates(BuildContext context, DashaInfo dasha, DateTime now) {
    final widgets = <Widget>[];
    
    if (dasha.mahadashaSequence != null && dasha.mahadashaSequence!.isNotEmpty) {
      for (var i = 0; i < dasha.mahadashaSequence!.length; i++) {
        final periodDetail = dasha.mahadashaSequence![i];
        final isCurrent = periodDetail.planet == dasha.currentMahadasha;
        final isPast = periodDetail.endDate.isBefore(now);
        final isFuture = periodDetail.startDate.isAfter(now);
        
        widgets.add(_DashaPeriodItem(
          periodDetail: periodDetail,
          index: i,
          isCurrent: isCurrent,
          isPast: isPast,
          isFuture: isFuture,
          dasha: dasha,
        ));
      }
    } else {
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

// ============ Vimshottari Hero Card ============
class _VimshottariHeroCard extends StatelessWidget {
  final DashaInfo dasha;
  final double dynamicRemainingYears;
  final DateTime now;
  final int completedPeriods;

  const _VimshottariHeroCard({
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
    final planetColor = getPlanetColor(dasha.currentMahadasha);

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Planet symbol
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
                    getPlanetSymbol(dasha.currentMahadasha),
                    style: TextStyle(
                      fontSize: 36,
                      color: planetColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                DashaProgressBar(progress: progressPercent, color: planetColor),
                const SizedBox(height: 12),
                Row(
                  children: [
                    DashaHeroStatItem(
                      icon: Icons.hourglass_bottom_rounded,
                      label: 'Remaining',
                      value: formatDuration(dynamicRemainingYears),
                      color: planetColor,
                    ),
                    Container(
                      width: 1,
                      height: 28,
                      color: KundliDisplayColors.borderColor.withOpacity(0.3),
                    ),
                    DashaHeroStatItem(
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
                    DashaHeroStatItem(
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
                    child: DashaDateBadge(
                      label: 'Started',
                      date: dasha.mahadashaStartDate!,
                      icon: Icons.play_circle_outline_rounded,
                    ),
                  ),
                const SizedBox(width: 10),
                if (dasha.mahadashaEndDate != null)
                  Expanded(
                    child: DashaDateBadge(
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

// ============ Compact Period Card ============
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
    final color = getPlanetColor(planet);
    
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
                    getPlanetSymbol(planet),
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
            '${formatDuration(remainingYears)} left',
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

// ============ Birth Config Card ============
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
                color: getPlanetColor(dasha.birthNakshatraLord!),
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
                value: formatDuration(dasha.balanceYearsAtBirth!),
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

// ============ Timeline Progress Bar ============
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
          final color = getPlanetColor(period.planet);
          
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
                    getPlanetSymbol(period.planet),
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

// ============ Period Item ============
class _DashaPeriodItem extends StatelessWidget {
  final DashaPeriodDetail periodDetail;
  final int index;
  final bool isCurrent;
  final bool isPast;
  final bool isFuture;
  final DashaInfo dasha;

  const _DashaPeriodItem({
    required this.periodDetail,
    required this.index,
    required this.isCurrent,
    required this.isPast,
    required this.isFuture,
    required this.dasha,
  });

  @override
  Widget build(BuildContext context) {
    final planetColor = getPlanetColor(periodDetail.planet);
    
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
        onTap: () => _showPeriodSheet(context, periodDetail),
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
                      getPlanetSymbol(periodDetail.planet),
                      style: TextStyle(
                        fontSize: 18,
                        color: isPast ? planetColor.withOpacity(0.5) : planetColor,
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
                          if (isCurrent) const ActiveNowBadge(),
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
                            '${formatDateShort(periodDetail.startDate)} → ${formatDateShort(periodDetail.endDate)}',
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

  void _showPeriodSheet(BuildContext context, DashaPeriodDetail period) {
    showVimshottariPeriodSheet(context, period, []);
  }
}

// ============ Period Item Fallback ============
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
    final planetColor = getPlanetColor(period.planet);
    
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
        onTap: () => _showDetailsFallback(context),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
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
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: planetColor.withOpacity(isCurrent ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    getPlanetSymbol(period.planet),
                    style: TextStyle(
                      fontSize: 18,
                      color: isPast ? planetColor.withOpacity(0.5) : planetColor,
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
                          period.planet,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                            color: isPast
                                ? KundliDisplayColors.textMuted
                                : KundliDisplayColors.textPrimary,
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: 8),
                          const ActiveNowBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatDateShort(startDate)} → ${formatDateShort(endDate)}',
                      style: GoogleFonts.dmMono(
                        fontSize: 10,
                        color: KundliDisplayColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: planetColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${period.years}y',
                  style: GoogleFonts.dmMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: planetColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: KundliDisplayColors.textMuted.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsFallback(BuildContext context) {
    // Create DashaPeriodDetail on the fly
    final subPeriods = KundaliCalculationService.calculateSubDashas(
      parentPath: period.planet,
      parentPlanet: period.planet,
      parentDuration: period.years.toDouble(),
      startDate: startDate,
      level: DashaLevel.antardasha,
      maxDepth: 1,
    );
    
    final periodDetail = DashaPeriodDetail(
      planet: period.planet,
      fullPath: period.planet,
      durationYears: period.years.toDouble(),
      startDate: startDate,
      endDate: endDate,
      level: DashaLevel.mahadasha,
      subPeriods: subPeriods,
    );
    
    showVimshottariPeriodSheet(context, periodDetail, []);
  }
}

// ============ Vimshottari Period Bottom Sheet ============
void showVimshottariPeriodSheet(
  BuildContext context,
  DashaPeriodDetail period,
  List<String> breadcrumbs,
) {
  final levelColors = {
    DashaLevel.mahadasha: DashaTypeColors.mahadasha,
    DashaLevel.antardasha: DashaTypeColors.antardasha,
    DashaLevel.pratyantara: DashaTypeColors.pratyantara,
    DashaLevel.sookshma: DashaTypeColors.sookshma,
    DashaLevel.prana: DashaTypeColors.prana,
  };

  final levelColor = levelColors[period.level] ?? KundliDisplayColors.accentSecondary;
  final newBreadcrumbs = [...breadcrumbs, period.planet];
  final now = DateTime.now();
  final isCurrentPeriod = period.containsDate(now);

  final hasSubPeriods = period.subPeriods != null && period.subPeriods!.isNotEmpty;
  final nextLevel = _getNextDashaLevel(period.level);
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
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: KundliDisplayColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _VimshottariPeriodHeader(
              period: period,
              breadcrumbs: breadcrumbs,
              levelColor: levelColor,
              isCurrentPeriod: isCurrentPeriod,
            ),
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
            Expanded(
              child: hasSubPeriods
                  ? ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: period.subPeriods!.length,
                      itemBuilder: (context, index) {
                        final subPeriod = period.subPeriods![index];
                        final isSubCurrent = subPeriod.containsDate(now);
                        final subLevelColor = levelColors[subPeriod.level] ?? KundliDisplayColors.textMuted;
                        final canDrillDeeperSub = _getNextDashaLevel(subPeriod.level) != null;

                        return _SubPeriodItem(
                          subPeriod: subPeriod,
                          isSubCurrent: isSubCurrent,
                          subLevelColor: subLevelColor,
                          canDrillDeeperSub: canDrillDeeperSub,
                          newBreadcrumbs: newBreadcrumbs,
                        );
                      },
                    )
                  : Center(
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
                            'Loading sub-periods...',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: KundliDisplayColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}

DashaLevel? _getNextDashaLevel(DashaLevel current) {
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

String _getLevelDisplayName(DashaLevel? level) {
  if (level == null) return '';
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

class _VimshottariPeriodHeader extends StatelessWidget {
  final DashaPeriodDetail period;
  final List<String> breadcrumbs;
  final Color levelColor;
  final bool isCurrentPeriod;

  const _VimshottariPeriodHeader({
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
                    getPlanetSymbol(period.planet),
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
                          const ActiveNowBadge(fontSize: 8),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _DateColumn(label: 'Start', date: period.startDate),
                Container(width: 1, height: 28, color: KundliDisplayColors.borderColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _DateColumn(label: 'End', date: period.endDate),
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
                          formatDuration(period.durationYears),
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
          ),
        ],
      ),
    );
  }
}

class _DateColumn extends StatelessWidget {
  final String label;
  final DateTime date;

  const _DateColumn({required this.label, required this.date});

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
            formatDate(date),
            style: GoogleFonts.dmMono(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: KundliDisplayColors.textSecondary,
            ),
          ),
        ],
      ),
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
    return GestureDetector(
      onTap: canDrillDeeperSub
          ? () {
              Navigator.pop(context);
              final deeperPeriod = _ensureSubPeriods(subPeriod);
              showVimshottariPeriodSheet(context, deeperPeriod, newBreadcrumbs);
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
                color: getPlanetColor(subPeriod.planet).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  getPlanetSymbol(subPeriod.planet),
                  style: TextStyle(
                    fontSize: 14,
                    color: getPlanetColor(subPeriod.planet),
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
                        const ActiveNowBadge(fontSize: 7),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatDateShort(subPeriod.startDate)} - ${formatDateShort(subPeriod.endDate)}',
                    style: GoogleFonts.dmMono(
                      fontSize: 9,
                      color: KundliDisplayColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatDuration(subPeriod.durationYears),
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

DashaPeriodDetail _ensureSubPeriods(DashaPeriodDetail period) {
  if (period.subPeriods != null && period.subPeriods!.isNotEmpty) {
    return period;
  }

  final nextLevel = _getNextDashaLevel(period.level);
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

