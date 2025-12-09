import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../../shared/constants.dart';
import 'dasha_shared_widgets.dart';

/// Yogini Dasha View - Shows the 36-year Yogini Dasha with 8 divine Yoginis
class YoginiDashaView extends StatelessWidget {
  final KundaliData kundaliData;

  const YoginiDashaView({super.key, required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final yogini = kundaliData.yoginiDashaInfo;
    
    if (yogini == null) {
      return _buildNoDataView();
    }
    
    final now = DateTime.now();
    final dynamicRemainingYears = _calculateDynamicRemainingYears(yogini, now);
    
    // Get current index in sequence
    final currentIndex = yogini.sequence.indexWhere((p) => p.yogini == yogini.currentYogini);
    final completedPeriods = currentIndex >= 0 ? currentIndex : 0;
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          _YoginiHeroCard(
            yogini: yogini,
            dynamicRemainingYears: dynamicRemainingYears,
            now: now,
            completedPeriods: completedPeriods,
          ),
          
          const SizedBox(height: 20),
          
          // Current Periods Section
          DashaSectionHeader(
            icon: Icons.timeline_rounded,
            title: 'Active Yogini Periods',
            subtitle: 'Currently running Yogini phases',
            color: DashaTypeColors.yoginiPrimary,
          ),
          const SizedBox(height: 12),
          
          // Current Yogini & Antardasha
          Row(
            children: [
              Expanded(
                child: _CompactYoginiCard(
                  label: 'Mahadasha',
                  yogini: yogini.currentYogini,
                  remainingYears: dynamicRemainingYears,
                  progress: _calculateProgress(yogini, now),
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 10),
              if (yogini.currentAntardasha != null)
                Expanded(
                  child: _CompactYoginiCard(
                    label: 'Antardasha',
                    yogini: yogini.currentAntardasha!,
                    remainingYears: yogini.antardashaRemainingYears ?? 0,
                    progress: 0.5, // Approximate
                    isPrimary: false,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Yogini Wheel Visualization
          DashaSectionHeader(
            icon: Icons.donut_large_rounded,
            title: 'The 8 Divine Yoginis',
            subtitle: '36-year cosmic cycle of feminine energy',
            color: DashaTypeColors.yoginiSecondary,
          ),
          const SizedBox(height: 12),
          
          _YoginiWheelCard(
            currentYogini: yogini.currentYogini,
          ),
          
          const SizedBox(height: 24),
          
          // Life Timeline
          DashaSectionHeader(
            icon: Icons.view_timeline_rounded,
            title: 'Yogini Timeline',
            subtitle: '36-year cycle • Tap any period to explore',
            color: DashaTypeColors.yoginiPrimary,
          ),
          const SizedBox(height: 12),
          
          // Timeline bar
          _YoginiTimelineBar(
            currentYogini: yogini.currentYogini,
          ),
          
          const SizedBox(height: 16),
          
          // Yogini sequence with dates
          ..._buildYoginiSequenceWithDates(context, yogini, now),
          
          const SizedBox(height: 16),
          
          // Info footer
          const DashaInfoFooter(
            text: 'Yogini Dasha is a 36-year cycle based on 8 divine Yoginis representing cosmic feminine energies. Each Yogini governs specific life areas and brings unique influences.',
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoDataView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DashaTypeColors.yoginiPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.hourglass_empty_rounded,
                size: 40,
                color: DashaTypeColors.yoginiPrimary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Yogini Dasha Unavailable',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: KundliDisplayColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to calculate Yogini Dasha for this chart. Please ensure Moon position data is available.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: KundliDisplayColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  double _calculateProgress(YoginiDashaInfo yogini, DateTime now) {
    final totalYears = yogini.currentYogini.years.toDouble();
    final remainingYears = _calculateDynamicRemainingYears(yogini, now);
    final elapsedYears = totalYears - remainingYears;
    return (elapsedYears / totalYears).clamp(0.0, 1.0);
  }
  
  double _calculateDynamicRemainingYears(YoginiDashaInfo yogini, DateTime now) {
    if (yogini.yoginiEndDate != null) {
      final daysRemaining = yogini.yoginiEndDate!.difference(now).inDays;
      if (daysRemaining > 0) {
        return daysRemaining / 365.25;
      }
      return 0;
    }
    return yogini.remainingYears;
  }
  
  List<Widget> _buildYoginiSequenceWithDates(BuildContext context, YoginiDashaInfo yogini, DateTime now) {
    final widgets = <Widget>[];
    
    if (yogini.yoginiSequence != null && yogini.yoginiSequence!.isNotEmpty) {
      for (var i = 0; i < yogini.yoginiSequence!.length && i < 8; i++) {
        final periodDetail = yogini.yoginiSequence![i];
        final isCurrent = periodDetail.yogini == yogini.currentYogini;
        final isPast = periodDetail.endDate.isBefore(now);
        
        widgets.add(_YoginiPeriodItem(
          periodDetail: periodDetail,
          index: i,
          isCurrent: isCurrent,
          isPast: isPast,
        ));
      }
    } else {
      // Fallback: Build from sequence
      DateTime currentStart = yogini.startDate;
      
      for (var i = 0; i < yogini.sequence.length; i++) {
        final period = yogini.sequence[i];
        final endDate = currentStart.add(Duration(days: (period.years * 365.25).round()));
        final isCurrent = period.yogini == yogini.currentYogini;
        final isPast = endDate.isBefore(now);
        
        widgets.add(_YoginiPeriodItemFallback(
          period: period,
          index: i,
          isCurrent: isCurrent,
          isPast: isPast,
          startDate: currentStart,
          endDate: endDate,
        ));
        
        currentStart = endDate;
      }
    }
    
    return widgets;
  }
}

// ============ Yogini Hero Card ============
class _YoginiHeroCard extends StatelessWidget {
  final YoginiDashaInfo yogini;
  final double dynamicRemainingYears;
  final DateTime now;
  final int completedPeriods;

  const _YoginiHeroCard({
    required this.yogini,
    required this.dynamicRemainingYears,
    required this.now,
    required this.completedPeriods,
  });

  @override
  Widget build(BuildContext context) {
    final totalYears = yogini.currentYogini.years;
    final elapsedYears = totalYears - dynamicRemainingYears;
    final progressPercent = (elapsedYears / totalYears).clamp(0.0, 1.0);
    final yoginiColor = _getYoginiColor(yogini.currentYogini);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            yoginiColor.withOpacity(0.15),
            DashaTypeColors.yoginiPrimary.withOpacity(0.05),
            KundliDisplayColors.surfaceColor.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: yoginiColor.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: yoginiColor.withOpacity(0.1),
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
              // Yogini symbol
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      yoginiColor.withOpacity(0.25),
                      yoginiColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: yoginiColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    yogini.currentYogini.symbol,
                    style: TextStyle(
                      fontSize: 32,
                      color: yoginiColor,
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
                      '${yogini.currentYogini.displayName} Dasha',
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: KundliDisplayColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      yogini.currentYogini.nature,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: KundliDisplayColors.textMuted,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.public_rounded,
                          size: 12,
                          color: yoginiColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ruled by ${yogini.currentYogini.planet}',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: yoginiColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
                        color: yoginiColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DashaProgressBar(progress: progressPercent, color: yoginiColor),
                const SizedBox(height: 12),
                Row(
                  children: [
                    DashaHeroStatItem(
                      icon: Icons.hourglass_bottom_rounded,
                      label: 'Remaining',
                      value: formatDuration(dynamicRemainingYears),
                      color: yoginiColor,
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
                      value: '$completedPeriods/8',
                      color: const Color(0xFF6EE7B7),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Compact Yogini Card ============
class _CompactYoginiCard extends StatelessWidget {
  final String label;
  final Yogini yogini;
  final double remainingYears;
  final double progress;
  final bool isPrimary;

  const _CompactYoginiCard({
    required this.label,
    required this.yogini,
    required this.remainingYears,
    required this.progress,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getYoginiColor(yogini);
    
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
                    yogini.symbol,
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
                      yogini.displayName,
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

// ============ Yogini Wheel Card ============
class _YoginiWheelCard extends StatelessWidget {
  final Yogini currentYogini;

  const _YoginiWheelCard({required this.currentYogini});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KundliDisplayColors.borderColor.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Grid of 8 Yoginis
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Yogini.values.map((yogini) {
              final isCurrent = yogini == currentYogini;
              final color = _getYoginiColor(yogini);
              
              return Container(
                width: (MediaQuery.of(context).size.width - 80) / 4,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? color.withOpacity(0.15)
                      : KundliDisplayColors.surfaceColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent
                        ? color.withOpacity(0.4)
                        : KundliDisplayColors.borderColor.withOpacity(0.3),
                    width: isCurrent ? 1.5 : 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      yogini.symbol,
                      style: TextStyle(
                        fontSize: 20,
                        color: isCurrent ? color : color.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      yogini.displayName,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                        color: isCurrent
                            ? KundliDisplayColors.textPrimary
                            : KundliDisplayColors.textMuted,
                      ),
                    ),
                    Text(
                      '${yogini.years}y',
                      style: GoogleFonts.dmMono(
                        fontSize: 9,
                        color: isCurrent ? color : KundliDisplayColors.textMuted,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ============ Yogini Timeline Bar ============
class _YoginiTimelineBar extends StatelessWidget {
  final Yogini currentYogini;

  const _YoginiTimelineBar({required this.currentYogini});

  @override
  Widget build(BuildContext context) {
    final currentIndex = Yogini.values.indexOf(currentYogini);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: Yogini.values.asMap().entries.map((entry) {
          final yogini = entry.value;
          final isCurrent = yogini == currentYogini;
          final isPast = entry.key < currentIndex;
          final color = _getYoginiColor(yogini);
          
          return Expanded(
            flex: yogini.years,
            child: Tooltip(
              message: '${yogini.displayName}: ${yogini.years} years',
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
                    yogini.symbol,
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

// ============ Yogini Period Item ============
class _YoginiPeriodItem extends StatelessWidget {
  final YoginiPeriodDetail periodDetail;
  final int index;
  final bool isCurrent;
  final bool isPast;

  const _YoginiPeriodItem({
    required this.periodDetail,
    required this.index,
    required this.isCurrent,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final yoginiColor = _getYoginiColor(periodDetail.yogini);
    
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
        onTap: () => _showYoginiPeriodSheet(context, periodDetail),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isCurrent
                ? yoginiColor.withOpacity(0.08)
                : isPast
                    ? KundliDisplayColors.surfaceColor.withOpacity(0.2)
                    : KundliDisplayColors.surfaceColor.withOpacity(0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCurrent
                  ? yoginiColor.withOpacity(0.35)
                  : KundliDisplayColors.borderColor.withOpacity(isPast ? 0.15 : 0.3),
              width: isCurrent ? 1.5 : 0.5,
            ),
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
                          ? [yoginiColor.withOpacity(0.25), yoginiColor.withOpacity(0.1)]
                          : [yoginiColor.withOpacity(isPast ? 0.06 : 0.12), yoginiColor.withOpacity(isPast ? 0.03 : 0.06)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: yoginiColor.withOpacity(isCurrent ? 0.4 : 0.15),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      periodDetail.yogini.symbol,
                      style: TextStyle(
                        fontSize: 18,
                        color: isPast ? yoginiColor.withOpacity(0.5) : yoginiColor,
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
                            periodDetail.yogini.displayName,
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
                      const SizedBox(height: 2),
                      Text(
                        'Ruled by ${periodDetail.yogini.planet}',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: yoginiColor.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 2),
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
                    color: yoginiColor.withOpacity(isPast ? 0.05 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${periodDetail.durationYears.round()}',
                        style: GoogleFonts.dmMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isPast ? KundliDisplayColors.textMuted.withOpacity(0.5) : yoginiColor,
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

  void _showYoginiPeriodSheet(BuildContext context, YoginiPeriodDetail period) {
    showYoginiPeriodBottomSheet(context, period, []);
  }
}

// ============ Yogini Period Item Fallback ============
class _YoginiPeriodItemFallback extends StatelessWidget {
  final YoginiPeriod period;
  final int index;
  final bool isCurrent;
  final bool isPast;
  final DateTime startDate;
  final DateTime endDate;

  const _YoginiPeriodItemFallback({
    required this.period,
    required this.index,
    required this.isCurrent,
    required this.isPast,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final yoginiColor = _getYoginiColor(period.yogini);
    
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrent
              ? yoginiColor.withOpacity(0.08)
              : isPast
                  ? KundliDisplayColors.surfaceColor.withOpacity(0.2)
                  : KundliDisplayColors.surfaceColor.withOpacity(0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCurrent
                ? yoginiColor.withOpacity(0.35)
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
                color: yoginiColor.withOpacity(isCurrent ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  period.yogini.symbol,
                  style: TextStyle(
                    fontSize: 18,
                    color: isPast ? yoginiColor.withOpacity(0.5) : yoginiColor,
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
                        period.yogini.displayName,
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
                color: yoginiColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${period.years}y',
                style: GoogleFonts.dmMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: yoginiColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ Yogini Period Bottom Sheet ============
void showYoginiPeriodBottomSheet(
  BuildContext context,
  YoginiPeriodDetail period,
  List<String> breadcrumbs,
) {
  final levelColors = {
    YoginiLevel.mahadasha: DashaTypeColors.mahadasha,
    YoginiLevel.antardasha: DashaTypeColors.antardasha,
    YoginiLevel.pratyantara: DashaTypeColors.pratyantara,
    YoginiLevel.sookshma: DashaTypeColors.sookshma,
    YoginiLevel.prana: DashaTypeColors.prana,
  };

  final levelColor = levelColors[period.level] ?? DashaTypeColors.yoginiPrimary;
  final yoginiColor = _getYoginiColor(period.yogini);
  final newBreadcrumbs = [...breadcrumbs, period.yogini.displayName];
  final now = DateTime.now();
  final isCurrentPeriod = period.containsDate(now);

  final hasSubPeriods = period.subPeriods != null && period.subPeriods!.isNotEmpty;

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
          border: Border.all(color: yoginiColor.withOpacity(0.3), width: 1),
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
            Padding(
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
                          color: yoginiColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: yoginiColor.withOpacity(0.3), width: 1),
                        ),
                        child: Center(
                          child: Text(
                            period.yogini.symbol,
                            style: TextStyle(fontSize: 22, color: yoginiColor),
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
                              '${period.yogini.displayName} ${period.levelName}',
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start', style: GoogleFonts.dmSans(fontSize: 9, color: KundliDisplayColors.textMuted)),
                              Text(formatDate(period.startDate), style: GoogleFonts.dmMono(fontSize: 11, fontWeight: FontWeight.w500, color: KundliDisplayColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 28, color: KundliDisplayColors.borderColor),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('End', style: GoogleFonts.dmSans(fontSize: 9, color: KundliDisplayColors.textMuted)),
                                Text(formatDate(period.endDate), style: GoogleFonts.dmMono(fontSize: 11, fontWeight: FontWeight.w500, color: KundliDisplayColors.textSecondary)),
                              ],
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
                                Text('Duration', style: GoogleFonts.dmSans(fontSize: 9, color: KundliDisplayColors.textMuted)),
                                Text(formatDuration(period.durationYears), style: GoogleFonts.dmMono(fontSize: 11, fontWeight: FontWeight.w600, color: yoginiColor)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (hasSubPeriods) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Sub-Periods (${period.subPeriods!.length})',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: KundliDisplayColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: hasSubPeriods
                  ? ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: period.subPeriods!.length,
                      itemBuilder: (context, index) {
                        final subPeriod = period.subPeriods![index];
                        final isSubCurrent = subPeriod.containsDate(now);
                        final subColor = _getYoginiColor(subPeriod.yogini);

                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            final deeperPeriod = _ensureYoginiSubPeriods(subPeriod);
                            showYoginiPeriodBottomSheet(context, deeperPeriod, newBreadcrumbs);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSubCurrent
                                  ? subColor.withOpacity(0.1)
                                  : KundliDisplayColors.surfaceColor.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSubCurrent
                                    ? subColor.withOpacity(0.3)
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
                                    color: subColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      subPeriod.yogini.symbol,
                                      style: TextStyle(fontSize: 14, color: subColor),
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
                                            subPeriod.yogini.displayName,
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
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: KundliDisplayColors.textMuted.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'No sub-periods available',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: KundliDisplayColors.textMuted,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}

YoginiPeriodDetail _ensureYoginiSubPeriods(YoginiPeriodDetail period) {
  if (period.subPeriods != null && period.subPeriods!.isNotEmpty) {
    return period;
  }

  final nextLevel = _getNextYoginiLevel(period.level);
  if (nextLevel == null) return period;

  final subPeriods = KundaliCalculationService.calculateYoginiSubPeriodsOnDemand(
    parentPeriod: period,
    depth: 1,
  );

  return YoginiPeriodDetail(
    yogini: period.yogini,
    fullPath: period.fullPath,
    durationYears: period.durationYears,
    startDate: period.startDate,
    endDate: period.endDate,
    level: period.level,
    subPeriods: subPeriods,
  );
}

YoginiLevel? _getNextYoginiLevel(YoginiLevel current) {
  switch (current) {
    case YoginiLevel.mahadasha:
      return YoginiLevel.antardasha;
    case YoginiLevel.antardasha:
      return YoginiLevel.pratyantara;
    case YoginiLevel.pratyantara:
      return YoginiLevel.sookshma;
    case YoginiLevel.sookshma:
      return YoginiLevel.prana;
    case YoginiLevel.prana:
      return null;
  }
}

// ============ Helper Functions ============
Color _getYoginiColor(Yogini yogini) {
  const colors = {
    Yogini.mangala: Color(0xFF6EE7B7), // Moon - Green
    Yogini.pingala: Color(0xFFD4AF37), // Sun - Gold
    Yogini.dhanya: Color(0xFFFBBF24), // Jupiter - Yellow
    Yogini.bhramari: Color(0xFFF87171), // Mars - Red
    Yogini.bhadrika: Color(0xFF34D399), // Mercury - Teal
    Yogini.ulka: Color(0xFF9CA3AF), // Saturn - Gray
    Yogini.siddha: Color(0xFFF472B6), // Venus - Pink
    Yogini.sankata: Color(0xFFA78BFA), // Rahu - Purple
  };
  return colors[yogini] ?? DashaTypeColors.yoginiPrimary;
}

