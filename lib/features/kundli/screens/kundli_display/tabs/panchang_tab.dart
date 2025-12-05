import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../shared/constants.dart';

/// Panchang Tab - Shows birth panchang, inauspicious periods, and varshphal
class PanchangTab extends StatelessWidget {
  final KundaliData kundaliData;

  const PanchangTab({super.key, required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final sunPos = kundaliData.planetPositions['Sun'];
    final moonPos = kundaliData.planetPositions['Moon'];

    final panchang = KundaliCalculationService.calculatePanchang(
      kundaliData.birthDateTime,
      sunPos?.longitude ?? 0,
      moonPos?.longitude ?? 0,
    );

    final varshphal = KundaliCalculationService.calculateVarshphal(
      kundaliData.birthDateTime,
      sunPos?.longitude ?? 0,
      DateTime.now().year,
    );

    final inauspiciousPeriods = KundaliCalculationService.calculateInauspiciousPeriods(
      kundaliData.birthDateTime,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Birth Panchang',
            subtitle: 'Lunar calendar details at birth',
            icon: Icons.calendar_today_rounded,
            color: const Color(0xFFF472B6),
          ),
          const SizedBox(height: 12),
          _PanchangCard(panchang: panchang),

          const SizedBox(height: 24),

          _SectionHeader(
            title: 'Inauspicious Periods',
            subtitle: 'Rahukala, Yamaghanda & Gulika at birth',
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFF87171),
          ),
          const SizedBox(height: 12),
          _InauspiciousPeriodsCard(
            periods: inauspiciousPeriods,
            birthDateTime: kundaliData.birthDateTime,
          ),

          const SizedBox(height: 24),

          _SectionHeader(
            title: 'Varshphal ${varshphal.year}',
            subtitle: 'Annual horoscope (Solar Return)',
            icon: Icons.cake_rounded,
            color: const Color(0xFFFBBF24),
          ),
          const SizedBox(height: 12),
          _VarshphalCard(varshphal: varshphal),
        ],
      ),
    );
  }
}

// ============ Section Header ============
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
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
        const SizedBox(width: 10),
        Column(
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
      ],
    );
  }
}

// ============ Panchang Card ============
class _PanchangCard extends StatelessWidget {
  final PanchangData panchang;

  const _PanchangCard({required this.panchang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF472B6).withOpacity(0.1),
            const Color(0xFFA78BFA).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF472B6).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _PanchangElement(
                  label: 'Tithi',
                  value: '${panchang.paksha} ${panchang.tithi}',
                  icon: Icons.brightness_2_rounded,
                  color: const Color(0xFF6EE7B7),
                ),
              ),
              Expanded(
                child: _PanchangElement(
                  label: 'Nakshatra',
                  value: '${panchang.nakshatra} (Pada ${panchang.nakshatraPada})',
                  icon: Icons.star_rounded,
                  color: const Color(0xFFFBBF24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PanchangElement(
                  label: 'Yoga',
                  value: panchang.yoga,
                  icon: Icons.link_rounded,
                  color: const Color(0xFF60A5FA),
                ),
              ),
              Expanded(
                child: _PanchangElement(
                  label: 'Karana',
                  value: panchang.karana,
                  icon: Icons.auto_awesome_rounded,
                  color: const Color(0xFFA78BFA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PanchangElement(
                  label: 'Vara',
                  value: panchang.vara,
                  icon: Icons.calendar_view_day_rounded,
                  color: const Color(0xFF22D3EE),
                ),
              ),
              Expanded(
                child: _PanchangElement(
                  label: 'Ruling Deity',
                  value: panchang.varaDeity,
                  icon: Icons.person_rounded,
                  color: KundliDisplayColors.accentPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PanchangElement extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _PanchangElement({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: KundliDisplayColors.borderColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  color: KundliDisplayColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: KundliDisplayColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ============ Inauspicious Periods Card ============
class _InauspiciousPeriodsCard extends StatelessWidget {
  final InauspiciousPeriods periods;
  final DateTime birthDateTime;

  const _InauspiciousPeriodsCard({
    required this.periods,
    required this.birthDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final currentPeriod = periods.getCurrentPeriod(birthDateTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF87171).withOpacity(0.08),
            const Color(0xFFFBBF24).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF87171).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          if (currentPeriod != null) ...[
            _BirthWarning(period: currentPeriod),
            const SizedBox(height: 12),
          ],

          _InauspiciousPeriodRow(
            period: periods.rahukala,
            color: const Color(0xFFF87171),
            icon: Icons.do_not_disturb_on_rounded,
          ),
          const SizedBox(height: 10),

          _InauspiciousPeriodRow(
            period: periods.yamaghanda,
            color: const Color(0xFFFBBF24),
            icon: Icons.warning_rounded,
          ),
          const SizedBox(height: 10),

          _InauspiciousPeriodRow(
            period: periods.gulika,
            color: const Color(0xFFA78BFA),
            icon: Icons.brightness_3_rounded,
          ),

          const SizedBox(height: 12),

          _InauspiciousTimeline(
            periods: periods,
            birthDateTime: birthDateTime,
          ),
        ],
      ),
    );
  }
}

class _BirthWarning extends StatelessWidget {
  final TimePeriod period;

  const _BirthWarning({required this.period});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF87171).withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFF87171).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF87171),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Birth during ${period.name}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF87171),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  period.description,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: KundliDisplayColors.textMuted,
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

class _InauspiciousPeriodRow extends StatelessWidget {
  final TimePeriod period;
  final Color color;
  final IconData icon;

  const _InauspiciousPeriodRow({
    required this.period,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: KundliDisplayColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  period.description,
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    color: KundliDisplayColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              period.formattedTime,
              style: GoogleFonts.dmMono(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InauspiciousTimeline extends StatelessWidget {
  final InauspiciousPeriods periods;
  final DateTime birthDateTime;

  const _InauspiciousTimeline({
    required this.periods,
    required this.birthDateTime,
  });

  @override
  Widget build(BuildContext context) {
    const startHour = 6;
    const endHour = 18;
    const totalMinutes = (endHour - startHour) * 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 12,
              color: KundliDisplayColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              'Day Timeline (6 AM - 6 PM)',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: KundliDisplayColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return SizedBox(
              height: 24,
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: KundliDisplayColors.surfaceColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  _TimelineSegment(
                    period: periods.rahukala,
                    startHour: startHour,
                    totalMinutes: totalMinutes,
                    color: const Color(0xFFF87171),
                    maxWidth: width,
                  ),
                  _TimelineSegment(
                    period: periods.yamaghanda,
                    startHour: startHour,
                    totalMinutes: totalMinutes,
                    color: const Color(0xFFFBBF24),
                    maxWidth: width,
                  ),
                  _TimelineSegment(
                    period: periods.gulika,
                    startHour: startHour,
                    totalMinutes: totalMinutes,
                    color: const Color(0xFFA78BFA),
                    maxWidth: width,
                  ),
                  _BirthTimeMarker(
                    birthTime: birthDateTime,
                    startHour: startHour,
                    totalMinutes: totalMinutes,
                    maxWidth: width,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('6 AM', style: GoogleFonts.dmMono(fontSize: 8, color: KundliDisplayColors.textMuted)),
            Text('9 AM', style: GoogleFonts.dmMono(fontSize: 8, color: KundliDisplayColors.textMuted)),
            Text('12 PM', style: GoogleFonts.dmMono(fontSize: 8, color: KundliDisplayColors.textMuted)),
            Text('3 PM', style: GoogleFonts.dmMono(fontSize: 8, color: KundliDisplayColors.textMuted)),
            Text('6 PM', style: GoogleFonts.dmMono(fontSize: 8, color: KundliDisplayColors.textMuted)),
          ],
        ),
      ],
    );
  }
}

class _TimelineSegment extends StatelessWidget {
  final TimePeriod period;
  final int startHour;
  final int totalMinutes;
  final Color color;
  final double maxWidth;

  const _TimelineSegment({
    required this.period,
    required this.startHour,
    required this.totalMinutes,
    required this.color,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final periodStartMinutes = (period.startTime.hour - startHour) * 60 + period.startTime.minute;
    final periodEndMinutes = (period.endTime.hour - startHour) * 60 + period.endTime.minute;

    final startFraction = (periodStartMinutes / totalMinutes).clamp(0.0, 1.0);
    final endFraction = (periodEndMinutes / totalMinutes).clamp(0.0, 1.0);
    final widthFraction = endFraction - startFraction;

    if (widthFraction <= 0) return const SizedBox();

    return Positioned(
      left: startFraction * maxWidth,
      top: 8,
      child: Container(
        width: widthFraction * maxWidth,
        height: 8,
        decoration: BoxDecoration(
          color: color.withOpacity(0.7),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _BirthTimeMarker extends StatelessWidget {
  final DateTime birthTime;
  final int startHour;
  final int totalMinutes;
  final double maxWidth;

  const _BirthTimeMarker({
    required this.birthTime,
    required this.startHour,
    required this.totalMinutes,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final birthMinutes = (birthTime.hour - startHour) * 60 + birthTime.minute;
    final fraction = (birthMinutes / totalMinutes).clamp(0.0, 1.0);

    return Positioned(
      left: fraction * (maxWidth - 4),
      top: 0,
      child: Container(
        width: 2,
        height: 24,
        decoration: BoxDecoration(
          color: KundliDisplayColors.accentPrimary,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

// ============ Varshphal Card ============
class _VarshphalCard extends StatelessWidget {
  final VarshphalData varshphal;

  const _VarshphalCard({required this.varshphal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFBBF24).withOpacity(0.12),
            const Color(0xFFF97316).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFBBF24).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: KundliDisplayColors.textPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${varshphal.age}',
                      style: GoogleFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: KundliDisplayColors.accentPrimary,
                      ),
                    ),
                    Text(
                      'years',
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        color: KundliDisplayColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solar Return ${varshphal.year}',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: KundliDisplayColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${DateFormat('d MMM yyyy').format(varshphal.solarReturnDate)}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: KundliDisplayColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _VarshphalInfo(
                  label: 'Muntha Sign',
                  value: varshphal.munthaSign,
                  icon: Icons.place_rounded,
                  color: KundliDisplayColors.accentSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VarshphalInfo(
                  label: 'Year Lord',
                  value: varshphal.yearLord,
                  icon: Icons.person_rounded,
                  color: KundliDisplayColors.accentPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VarshphalInfo extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _VarshphalInfo({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  color: KundliDisplayColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: KundliDisplayColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

