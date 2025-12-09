import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../../shared/constants.dart';
import 'dasha_shared_widgets.dart';

/// Char Dasha View - Shows Jaimini Char Dasha with Karakas and Sign-based timeline
class CharDashaView extends StatelessWidget {
  final KundaliData kundaliData;

  const CharDashaView({super.key, required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final charDasha = kundaliData.charDashaInfo;
    
    if (charDasha == null) {
      return _buildNoDataView();
    }
    
    final now = DateTime.now();
    final dynamicRemainingYears = _calculateDynamicRemainingYears(charDasha, now);
    
    // Get current index in sequence
    final currentIndex = charDasha.sequence.indexWhere((p) => p.sign == charDasha.currentSign);
    final completedPeriods = currentIndex >= 0 ? currentIndex : 0;
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          _CharHeroCard(
            charDasha: charDasha,
            dynamicRemainingYears: dynamicRemainingYears,
            now: now,
            completedPeriods: completedPeriods,
          ),
          
          const SizedBox(height: 20),
          
          // Jaimini Karakas Section
          DashaSectionHeader(
            icon: Icons.star_rounded,
            title: 'Jaimini Karakas',
            subtitle: '8 significators based on planetary degrees',
            color: DashaTypeColors.charPrimary,
          ),
          const SizedBox(height: 12),
          
          _KarakasCard(karakas: charDasha.karakas),
          
          const SizedBox(height: 24),
          
          // Current Periods Section
          DashaSectionHeader(
            icon: Icons.timeline_rounded,
            title: 'Active Rasi Dasha',
            subtitle: 'Currently running sign periods',
            color: const Color(0xFF60A5FA),
          ),
          const SizedBox(height: 12),
          
          // Current Sign & Antardasha
          Row(
            children: [
              Expanded(
                child: _CompactSignCard(
                  label: 'Rasi Dasha',
                  sign: charDasha.currentSign,
                  remainingYears: dynamicRemainingYears,
                  progress: _calculateProgress(charDasha, now),
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 10),
              if (charDasha.currentAntardasha != null)
                Expanded(
                  child: _CompactSignCard(
                    label: 'Antardasha',
                    sign: charDasha.currentAntardasha!,
                    remainingYears: charDasha.antardashaRemainingYears ?? 0,
                    progress: 0.5,
                    isPrimary: false,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Direction Indicator
          _DirectionCard(
            startingSign: charDasha.startingSign,
            isClockwise: charDasha.isClockwise,
          ),
          
          const SizedBox(height: 24),
          
          // Life Timeline
          DashaSectionHeader(
            icon: Icons.view_timeline_rounded,
            title: 'Rasi Dasha Timeline',
            subtitle: 'Sign-based cycle • Tap any period to explore',
            color: DashaTypeColors.charPrimary,
          ),
          const SizedBox(height: 12),
          
          // Timeline bar
          _CharTimelineBar(
            sequence: charDasha.sequence,
            currentSign: charDasha.currentSign,
          ),
          
          const SizedBox(height: 16),
          
          // Dasha sequence with dates
          ..._buildCharSequenceWithDates(context, charDasha, now),
          
          const SizedBox(height: 16),
          
          // Info footer
          const DashaInfoFooter(
            text: 'Char Dasha (Jaimini) is a sign-based Dasha system. The sequence and direction depend on your Lagna (Ascendant) sign. Duration varies based on the position of the sign\'s lord.',
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
                color: DashaTypeColors.charPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.hourglass_empty_rounded,
                size: 40,
                color: DashaTypeColors.charPrimary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Char Dasha Unavailable',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: KundliDisplayColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to calculate Char Dasha for this chart. Please ensure Ascendant data is available.',
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
  
  double _calculateProgress(CharDashaInfo charDasha, DateTime now) {
    final currentPeriod = charDasha.sequence.firstWhere(
      (p) => p.sign == charDasha.currentSign,
      orElse: () => CharaPeriod(charDasha.currentSign, 9),
    );
    final totalYears = currentPeriod.years.toDouble();
    final remainingYears = _calculateDynamicRemainingYears(charDasha, now);
    final elapsedYears = totalYears - remainingYears;
    return (elapsedYears / totalYears).clamp(0.0, 1.0);
  }
  
  double _calculateDynamicRemainingYears(CharDashaInfo charDasha, DateTime now) {
    if (charDasha.signEndDate != null) {
      final daysRemaining = charDasha.signEndDate!.difference(now).inDays;
      if (daysRemaining > 0) {
        return daysRemaining / 365.25;
      }
      return 0;
    }
    return charDasha.remainingYears;
  }
  
  List<Widget> _buildCharSequenceWithDates(BuildContext context, CharDashaInfo charDasha, DateTime now) {
    final widgets = <Widget>[];
    
    if (charDasha.charSequence != null && charDasha.charSequence!.isNotEmpty) {
      for (var i = 0; i < charDasha.charSequence!.length; i++) {
        final periodDetail = charDasha.charSequence![i];
        final isCurrent = periodDetail.sign == charDasha.currentSign;
        final isPast = periodDetail.endDate.isBefore(now);
        
        widgets.add(_CharPeriodItem(
          periodDetail: periodDetail,
          index: i,
          isCurrent: isCurrent,
          isPast: isPast,
          isClockwise: charDasha.isClockwise,
        ));
      }
    } else {
      // Fallback
      DateTime currentStart = charDasha.startDate;
      
      for (var i = 0; i < charDasha.sequence.length; i++) {
        final period = charDasha.sequence[i];
        final endDate = currentStart.add(Duration(days: (period.years * 365.25).round()));
        final isCurrent = period.sign == charDasha.currentSign;
        final isPast = endDate.isBefore(now);
        
        widgets.add(_CharPeriodItemFallback(
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

// ============ Char Hero Card ============
class _CharHeroCard extends StatelessWidget {
  final CharDashaInfo charDasha;
  final double dynamicRemainingYears;
  final DateTime now;
  final int completedPeriods;

  const _CharHeroCard({
    required this.charDasha,
    required this.dynamicRemainingYears,
    required this.now,
    required this.completedPeriods,
  });

  @override
  Widget build(BuildContext context) {
    final currentPeriod = charDasha.sequence.firstWhere(
      (p) => p.sign == charDasha.currentSign,
      orElse: () => CharaPeriod(charDasha.currentSign, 9),
    );
    final totalYears = currentPeriod.years;
    final elapsedYears = totalYears - dynamicRemainingYears;
    final progressPercent = (elapsedYears / totalYears).clamp(0.0, 1.0);
    final signColor = getSignColor(charDasha.currentSign);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            signColor.withOpacity(0.15),
            DashaTypeColors.charPrimary.withOpacity(0.05),
            KundliDisplayColors.surfaceColor.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: signColor.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: signColor.withOpacity(0.1),
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
              // Sign symbol
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      signColor.withOpacity(0.25),
                      signColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: signColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    getSignSymbol(charDasha.currentSign),
                    style: TextStyle(
                      fontSize: 32,
                      color: signColor,
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
                      '${charDasha.currentSign} Rasi Dasha',
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: KundliDisplayColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSignDescription(charDasha.currentSign),
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
                          color: signColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Lord: ${_getSignLord(charDasha.currentSign)}',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: signColor,
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
                        color: signColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DashaProgressBar(progress: progressPercent, color: signColor),
                const SizedBox(height: 12),
                Row(
                  children: [
                    DashaHeroStatItem(
                      icon: Icons.hourglass_bottom_rounded,
                      label: 'Remaining',
                      value: formatDuration(dynamicRemainingYears),
                      color: signColor,
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
                      value: '$completedPeriods/12',
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
  
  String _getSignDescription(String sign) {
    const descriptions = {
      'Aries': 'Period of initiative, leadership, and new beginnings',
      'Taurus': 'Period of stability, material comfort, and values',
      'Gemini': 'Period of communication, learning, and versatility',
      'Cancer': 'Period of emotions, home, and nurturing',
      'Leo': 'Period of creativity, self-expression, and authority',
      'Virgo': 'Period of service, health, and analytical work',
      'Libra': 'Period of partnerships, balance, and diplomacy',
      'Scorpio': 'Period of transformation, depth, and intensity',
      'Sagittarius': 'Period of expansion, philosophy, and higher learning',
      'Capricorn': 'Period of ambition, structure, and achievement',
      'Aquarius': 'Period of innovation, humanity, and independence',
      'Pisces': 'Period of spirituality, intuition, and transcendence',
    };
    return descriptions[sign] ?? 'Period of cosmic influence';
  }
  
  String _getSignLord(String sign) {
    const lords = {
      'Aries': 'Mars',
      'Taurus': 'Venus',
      'Gemini': 'Mercury',
      'Cancer': 'Moon',
      'Leo': 'Sun',
      'Virgo': 'Mercury',
      'Libra': 'Venus',
      'Scorpio': 'Mars',
      'Sagittarius': 'Jupiter',
      'Capricorn': 'Saturn',
      'Aquarius': 'Saturn',
      'Pisces': 'Jupiter',
    };
    return lords[sign] ?? 'Unknown';
  }
}

// ============ Karakas Card ============
class _KarakasCard extends StatelessWidget {
  final JaiminiKarakas karakas;

  const _KarakasCard({required this.karakas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DashaTypeColors.charPrimary.withOpacity(0.08),
            KundliDisplayColors.surfaceColor.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DashaTypeColors.charPrimary.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary Karakas row (AK, AmK, BK, MK)
          Row(
            children: [
              Expanded(child: _KarakaItem(
                shortName: 'AK',
                fullName: 'Atmakaraka',
                planet: karakas.atmakaraka,
                degree: karakas.atmakarakaDegree,
                isHighlight: true,
              )),
              Expanded(child: _KarakaItem(
                shortName: 'AmK',
                fullName: 'Amatyakaraka',
                planet: karakas.amatyakaraka,
                degree: karakas.amatyakarakaDegree,
              )),
              Expanded(child: _KarakaItem(
                shortName: 'BK',
                fullName: 'Bhratrikaraka',
                planet: karakas.bhratrikaraka,
                degree: karakas.bhratrikarakaDegree,
              )),
              Expanded(child: _KarakaItem(
                shortName: 'MK',
                fullName: 'Matrikaraka',
                planet: karakas.matrikaraka,
                degree: karakas.matrikarakaDegree,
              )),
            ],
          ),
          const SizedBox(height: 12),
          // Secondary Karakas row (PiK, PuK, GK, DK)
          Row(
            children: [
              Expanded(child: _KarakaItem(
                shortName: 'PiK',
                fullName: 'Pitrikaraka',
                planet: karakas.pitrikaraka,
                degree: karakas.pitrikarakaDegree,
              )),
              Expanded(child: _KarakaItem(
                shortName: 'PuK',
                fullName: 'Putrakaraka',
                planet: karakas.putrakaraka,
                degree: karakas.putrakarakaDegree,
              )),
              Expanded(child: _KarakaItem(
                shortName: 'GK',
                fullName: 'Gnatikaraka',
                planet: karakas.gnatikaraka,
                degree: karakas.gnatrikarakaDegree,
              )),
              Expanded(child: _KarakaItem(
                shortName: 'DK',
                fullName: 'Darakaraka',
                planet: karakas.darakaraka,
                degree: karakas.darakarakaDegree,
              )),
            ],
          ),
          const SizedBox(height: 12),
          // Karakamsa
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: KundliDisplayColors.borderColor.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: DashaTypeColors.charPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      getSignSymbol(karakas.karakamsa),
                      style: TextStyle(
                        fontSize: 14,
                        color: DashaTypeColors.charPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Karakamsa',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: KundliDisplayColors.textMuted,
                      ),
                    ),
                    Text(
                      '${karakas.karakamsa} (AK in Navamsa)',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: KundliDisplayColors.textPrimary,
                      ),
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

class _KarakaItem extends StatelessWidget {
  final String shortName;
  final String fullName;
  final String planet;
  final double degree;
  final bool isHighlight;

  const _KarakaItem({
    required this.shortName,
    required this.fullName,
    required this.planet,
    required this.degree,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final planetColor = getPlanetColor(planet);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isHighlight
            ? planetColor.withOpacity(0.1)
            : KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHighlight
              ? planetColor.withOpacity(0.3)
              : KundliDisplayColors.borderColor.withOpacity(0.3),
          width: isHighlight ? 1 : 0.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            getPlanetSymbol(planet),
            style: TextStyle(
              fontSize: 18,
              color: planetColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            shortName,
            style: GoogleFonts.dmMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isHighlight ? planetColor : KundliDisplayColors.textSecondary,
            ),
          ),
          Text(
            planet,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              color: KundliDisplayColors.textMuted,
            ),
          ),
          Text(
            '${degree.toStringAsFixed(1)}°',
            style: GoogleFonts.dmMono(
              fontSize: 8,
              color: KundliDisplayColors.textMuted.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Direction Card ============
class _DirectionCard extends StatelessWidget {
  final String startingSign;
  final bool isClockwise;

  const _DirectionCard({
    required this.startingSign,
    required this.isClockwise,
  });

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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DashaTypeColors.charPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                isClockwise ? Icons.rotate_right_rounded : Icons.rotate_left_rounded,
                size: 22,
                color: DashaTypeColors.charPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dasha Direction',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: KundliDisplayColors.textMuted,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      isClockwise ? 'Clockwise' : 'Anti-clockwise',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: KundliDisplayColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: getSignColor(startingSign).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'from $startingSign',
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          color: getSignColor(startingSign),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: getSignColor(startingSign).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                getSignSymbol(startingSign),
                style: TextStyle(
                  fontSize: 16,
                  color: getSignColor(startingSign),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Compact Sign Card ============
class _CompactSignCard extends StatelessWidget {
  final String label;
  final String sign;
  final double remainingYears;
  final double progress;
  final bool isPrimary;

  const _CompactSignCard({
    required this.label,
    required this.sign,
    required this.remainingYears,
    required this.progress,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final color = getSignColor(sign);
    
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
                    getSignSymbol(sign),
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
                      sign,
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

// ============ Char Timeline Bar ============
class _CharTimelineBar extends StatelessWidget {
  final List<CharaPeriod> sequence;
  final String currentSign;

  const _CharTimelineBar({
    required this.sequence,
    required this.currentSign,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = sequence.indexWhere((p) => p.sign == currentSign);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: sequence.asMap().entries.map((entry) {
          final period = entry.value;
          final isCurrent = period.sign == currentSign;
          final isPast = entry.key < currentIndex;
          final color = getSignColor(period.sign);
          
          return Expanded(
            child: Tooltip(
              message: '${period.sign}: ${period.years} years',
              child: Container(
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 0.5),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? color
                      : isPast
                          ? color.withOpacity(0.4)
                          : color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(3),
                  border: isCurrent
                      ? Border.all(color: Colors.white.withOpacity(0.5), width: 1)
                      : null,
                ),
                child: Center(
                  child: Text(
                    getSignSymbol(period.sign),
                    style: TextStyle(
                      fontSize: 9,
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

// ============ Char Period Item ============
class _CharPeriodItem extends StatelessWidget {
  final CharaPeriodDetail periodDetail;
  final int index;
  final bool isCurrent;
  final bool isPast;
  final bool isClockwise;

  const _CharPeriodItem({
    required this.periodDetail,
    required this.index,
    required this.isCurrent,
    required this.isPast,
    required this.isClockwise,
  });

  @override
  Widget build(BuildContext context) {
    final signColor = getSignColor(periodDetail.sign);
    
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
        onTap: () => _showCharPeriodSheet(context, periodDetail, isClockwise),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isCurrent
                ? signColor.withOpacity(0.08)
                : isPast
                    ? KundliDisplayColors.surfaceColor.withOpacity(0.2)
                    : KundliDisplayColors.surfaceColor.withOpacity(0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCurrent
                  ? signColor.withOpacity(0.35)
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
                          ? [signColor.withOpacity(0.25), signColor.withOpacity(0.1)]
                          : [signColor.withOpacity(isPast ? 0.06 : 0.12), signColor.withOpacity(isPast ? 0.03 : 0.06)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: signColor.withOpacity(isCurrent ? 0.4 : 0.15),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      getSignSymbol(periodDetail.sign),
                      style: TextStyle(
                        fontSize: 18,
                        color: isPast ? signColor.withOpacity(0.5) : signColor,
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
                            periodDetail.sign,
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
                      if (periodDetail.signLord != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Lord: ${periodDetail.signLord}',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: signColor.withOpacity(0.8),
                          ),
                        ),
                      ],
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
                    color: signColor.withOpacity(isPast ? 0.05 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${periodDetail.durationYears.round()}',
                        style: GoogleFonts.dmMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isPast ? KundliDisplayColors.textMuted.withOpacity(0.5) : signColor,
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

  void _showCharPeriodSheet(BuildContext context, CharaPeriodDetail period, bool isClockwise) {
    showCharPeriodBottomSheet(context, period, [], isClockwise);
  }
}

// ============ Char Period Item Fallback ============
class _CharPeriodItemFallback extends StatelessWidget {
  final CharaPeriod period;
  final int index;
  final bool isCurrent;
  final bool isPast;
  final DateTime startDate;
  final DateTime endDate;

  const _CharPeriodItemFallback({
    required this.period,
    required this.index,
    required this.isCurrent,
    required this.isPast,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final signColor = getSignColor(period.sign);
    
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
              ? signColor.withOpacity(0.08)
              : isPast
                  ? KundliDisplayColors.surfaceColor.withOpacity(0.2)
                  : KundliDisplayColors.surfaceColor.withOpacity(0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCurrent
                ? signColor.withOpacity(0.35)
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
                color: signColor.withOpacity(isCurrent ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  getSignSymbol(period.sign),
                  style: TextStyle(
                    fontSize: 18,
                    color: isPast ? signColor.withOpacity(0.5) : signColor,
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
                        period.sign,
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
                color: signColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${period.years}y',
                style: GoogleFonts.dmMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: signColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ Char Period Bottom Sheet ============
void showCharPeriodBottomSheet(
  BuildContext context,
  CharaPeriodDetail period,
  List<String> breadcrumbs,
  bool isClockwise,
) {
  final levelColors = {
    CharLevel.mahadasha: DashaTypeColors.mahadasha,
    CharLevel.antardasha: DashaTypeColors.antardasha,
    CharLevel.pratyantara: DashaTypeColors.pratyantara,
    CharLevel.sookshma: DashaTypeColors.sookshma,
    CharLevel.prana: DashaTypeColors.prana,
  };

  final levelColor = levelColors[period.level] ?? DashaTypeColors.charPrimary;
  final signColor = getSignColor(period.sign);
  final newBreadcrumbs = [...breadcrumbs, period.sign];
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
          border: Border.all(color: signColor.withOpacity(0.3), width: 1),
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
                          color: signColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: signColor.withOpacity(0.3), width: 1),
                        ),
                        child: Center(
                          child: Text(
                            getSignSymbol(period.sign),
                            style: TextStyle(fontSize: 22, color: signColor),
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
                              '${period.sign} ${period.levelName}',
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
                                Text(formatDuration(period.durationYears), style: GoogleFonts.dmMono(fontSize: 11, fontWeight: FontWeight.w600, color: signColor)),
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
                        final subColor = getSignColor(subPeriod.sign);

                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            final deeperPeriod = _ensureCharSubPeriods(subPeriod, isClockwise);
                            showCharPeriodBottomSheet(context, deeperPeriod, newBreadcrumbs, isClockwise);
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
                                      getSignSymbol(subPeriod.sign),
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
                                            subPeriod.sign,
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

CharaPeriodDetail _ensureCharSubPeriods(CharaPeriodDetail period, bool isClockwise) {
  if (period.subPeriods != null && period.subPeriods!.isNotEmpty) {
    return period;
  }

  final nextLevel = _getNextCharLevel(period.level);
  if (nextLevel == null) return period;

  final subPeriods = KundaliCalculationService.calculateCharSubPeriodsOnDemand(
    parentPeriod: period,
    isClockwise: isClockwise,
    depth: 1,
  );

  return CharaPeriodDetail(
    sign: period.sign,
    fullPath: period.fullPath,
    durationYears: period.durationYears,
    startDate: period.startDate,
    endDate: period.endDate,
    level: period.level,
    subPeriods: subPeriods,
    signLord: period.signLord,
  );
}

CharLevel? _getNextCharLevel(CharLevel current) {
  switch (current) {
    case CharLevel.mahadasha:
      return CharLevel.antardasha;
    case CharLevel.antardasha:
      return CharLevel.pratyantara;
    case CharLevel.pratyantara:
      return CharLevel.sookshma;
    case CharLevel.sookshma:
      return CharLevel.prana;
    case CharLevel.prana:
      return null;
  }
}

