import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../shared/constants.dart';
import '../widgets/moon_phase_widget.dart';

/// Panchang Tab - Shows birth panchang, inauspicious periods, and varshphal
/// Premium, elegant UI with clear visual hierarchy
class PanchangTab extends StatelessWidget {
  final KundaliData kundaliData;

  const PanchangTab({super.key, required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final sunPos = kundaliData.planetPositions['Sun'];
    final moonPos = kundaliData.planetPositions['Moon'];

    // Calculate Panchang from actual Sun/Moon positions
    final panchang = KundaliCalculationService.calculatePanchang(
      kundaliData.birthDateTime,
      sunPos?.longitude ?? 0,
      moonPos?.longitude ?? 0,
    );

    // Calculate Varshphal for current year
    final varshphal = KundaliCalculationService.calculateVarshphal(
      kundaliData.birthDateTime,
      sunPos?.longitude ?? 0,
      DateTime.now().year,
    );

    // Calculate inauspicious periods based on weekday and sunrise
    final inauspiciousPeriods = KundaliCalculationService.calculateInauspiciousPeriods(
      kundaliData.birthDateTime,
    );

    // Calculate Hora (planetary hour) at birth
    final hora = _calculateHora(kundaliData.birthDateTime);

    // Derive additional Panchang details
    final tithiLord = _getTithiLord(panchang.tithiNumber, panchang.paksha);
    final yogaType = _getYogaType(panchang.yogaNumber);
    final karanaType = _getKaranaType(panchang.karana);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════════════════
          // HERO MOON PHASE CARD
          // ═══════════════════════════════════════════════════════════════
          _MoonPhaseHeroCard(
            panchang: panchang,
            moonPos: moonPos,
            sunPos: sunPos,
            birthDateTime: kundaliData.birthDateTime,
          ),

          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════════
          // PANCHANG ELEMENTS
          // ═══════════════════════════════════════════════════════════════
          _SectionLabel(
            title: 'Five Limbs of Time',
            subtitle: 'Panchang elements at birth',
            icon: Icons.calendar_month_rounded,
          ),
          const SizedBox(height: 12),
          _PanchangElementsGrid(
            panchang: panchang,
            tithiLord: tithiLord,
            yogaType: yogaType,
            karanaType: karanaType,
          ),

          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════════
          // HORA & WEEKDAY
          // ═══════════════════════════════════════════════════════════════
          _SectionLabel(
            title: 'Hora & Weekday',
            subtitle: 'Planetary hour and day influences',
            icon: Icons.access_time_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HoraCard(hora: hora, birthTime: kundaliData.birthDateTime),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _WeekdayCard(panchang: panchang),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════════
          // INAUSPICIOUS PERIODS
          // ═══════════════════════════════════════════════════════════════
          _SectionLabel(
            title: 'Inauspicious Periods',
            subtitle: 'On ${DateFormat('EEEE').format(kundaliData.birthDateTime)}',
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFF87171),
          ),
          const SizedBox(height: 12),
          _InauspiciousPeriodsCard(
            periods: inauspiciousPeriods,
            birthDateTime: kundaliData.birthDateTime,
          ),

          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════════
          // VARSHPHAL (Annual Horoscope)
          // ═══════════════════════════════════════════════════════════════
          _SectionLabel(
            title: 'Varshphal ${varshphal.year}',
            subtitle: 'Solar Return / Annual Horoscope',
            icon: Icons.cake_rounded,
            color: const Color(0xFFFBBF24),
          ),
          const SizedBox(height: 12),
          _VarshphalCard(varshphal: varshphal),
        ],
      ),
    );
  }

  /// Calculate Hora (planetary hour) based on weekday and time
  String _calculateHora(DateTime dateTime) {
    const weekdayRulers = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'];
    const horaSequence = ['Sun', 'Venus', 'Mercury', 'Moon', 'Saturn', 'Jupiter', 'Mars'];

    final weekday = dateTime.weekday % 7;
    final dayRuler = weekdayRulers[weekday];
    final startIndex = horaSequence.indexOf(dayRuler);
    final hoursSinceSunrise = (dateTime.hour - 6 + 24) % 24;
    final horaIndex = (startIndex + hoursSinceSunrise) % 7;

    return horaSequence[horaIndex];
  }

  String _getTithiLord(int tithiNumber, String paksha) {
    const tithiLords = [
      'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn',
      'Rahu', 'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn',
    ];
    final index = (tithiNumber - 1) % 15;
    return tithiLords[index];
  }

  String _getYogaType(int yogaNumber) {
    const auspiciousYogas = [1, 2, 3, 6, 7, 10, 11, 14, 17, 21, 24, 26, 27];
    const inauspiciousYogas = [4, 9, 13, 19, 20, 23];

    if (auspiciousYogas.contains(yogaNumber)) return 'Auspicious';
    if (inauspiciousYogas.contains(yogaNumber)) return 'Inauspicious';
    return 'Neutral';
  }

  String _getKaranaType(String karana) {
    const movableKaranas = ['Bava', 'Balava', 'Kaulava', 'Taitila', 'Gara', 'Vanija', 'Vishti'];
    const fixedKaranas = ['Shakuni', 'Chatushpada', 'Nagava', 'Kimstughna'];

    if (movableKaranas.contains(karana)) {
      if (karana == 'Vishti') return 'Bhadra (Avoid)';
      return 'Chara (Movable)';
    }
    if (fixedKaranas.contains(karana)) return 'Sthira (Fixed)';
    return 'Unknown';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION LABEL
// ═══════════════════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? color;

  const _SectionLabel({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = color ?? KundliDisplayColors.accentSecondary;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: labelColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: labelColor),
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
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MOON PHASE HERO CARD
// ═══════════════════════════════════════════════════════════════════════════
class _MoonPhaseHeroCard extends StatelessWidget {
  final PanchangData panchang;
  final PlanetPosition? moonPos;
  final PlanetPosition? sunPos;
  final DateTime birthDateTime;

  const _MoonPhaseHeroCard({
    required this.panchang,
    required this.moonPos,
    required this.sunPos,
    required this.birthDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final moonLong = moonPos?.longitude ?? 0;
    final sunLong = sunPos?.longitude ?? 0;
    double elongation = moonLong - sunLong;
    if (elongation < 0) elongation += 360;

    final phaseDescription = _getPhaseDescription(panchang.tithiNumber, panchang.paksha);
    final illumination = _calculateIllumination(panchang.tithiNumber, panchang.paksha);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E1B4B).withOpacity(0.9),
            const Color(0xFF312E81).withOpacity(0.6),
            const Color(0xFF1E1B4B).withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row with Moon and Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Moon Phase Visualization
              Column(
                children: [
                  MoonPhaseWidget(
                    tithiNumber: panchang.tithiNumber,
                    paksha: panchang.paksha,
                    size: 80,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${illumination.toStringAsFixed(0)}% lit',
                      style: GoogleFonts.dmMono(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Tithi Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${panchang.paksha.toUpperCase()} PAKSHA',
                            style: GoogleFonts.dmMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.7),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      panchang.tithi,
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phaseDescription,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Birth date info
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('d MMMM yyyy').format(birthDateTime),
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              Text(
                                DateFormat('EEEE, HH:mm').format(birthDateTime),
                                style: GoogleFonts.dmMono(
                                  fontSize: 9,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Bottom stats row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _MoonStatItem(
                  icon: Icons.nightlight_round,
                  label: 'Moon Sign',
                  value: moonPos?.sign ?? '?',
                  color: const Color(0xFF6EE7B7),
                ),
                _MoonStatDivider(),
                _MoonStatItem(
                  icon: Icons.straighten_rounded,
                  label: 'Moon Degree',
                  value: '${(moonPos?.signDegree ?? 0).toStringAsFixed(1)}°',
                  color: const Color(0xFF60A5FA),
                ),
                _MoonStatDivider(),
                _MoonStatItem(
                  icon: Icons.compare_arrows_rounded,
                  label: 'Elongation',
                  value: '${elongation.toStringAsFixed(1)}°',
                  color: const Color(0xFFA78BFA),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPhaseDescription(int tithi, String paksha) {
    if (paksha == 'Shukla') {
      if (tithi <= 3) return 'Waxing Crescent';
      if (tithi <= 7) return 'First Quarter';
      if (tithi <= 11) return 'Waxing Gibbous';
      if (tithi <= 14) return 'Nearly Full';
      return 'Full Moon (Purnima)';
    } else {
      if (tithi <= 3) return 'Waning Gibbous';
      if (tithi <= 7) return 'Third Quarter';
      if (tithi <= 11) return 'Waning Crescent';
      if (tithi <= 14) return 'Nearly New';
      return 'New Moon (Amavasya)';
    }
  }

  double _calculateIllumination(int tithi, String paksha) {
    if (paksha == 'Shukla') {
      return (tithi / 15.0) * 100;
    } else {
      return ((15 - tithi + 1) / 15.0) * 100;
    }
  }
}

class _MoonStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MoonStatItem({
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
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoonStatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withOpacity(0.1),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PANCHANG ELEMENTS GRID
// ═══════════════════════════════════════════════════════════════════════════
class _PanchangElementsGrid extends StatelessWidget {
  final PanchangData panchang;
  final String tithiLord;
  final String yogaType;
  final String karanaType;

  const _PanchangElementsGrid({
    required this.panchang,
    required this.tithiLord,
    required this.yogaType,
    required this.karanaType,
  });

  @override
  Widget build(BuildContext context) {
    final yogaColor = _getYogaTypeColor(yogaType);
    final karanaColor = karanaType.contains('Bhadra')
        ? const Color(0xFFF87171)
        : const Color(0xFFA78BFA);

    return Column(
      children: [
        // Row 1: Tithi & Nakshatra
        Row(
          children: [
            Expanded(
              child: _PanchangElementCard(
                icon: Icons.brightness_2_rounded,
                label: 'Tithi',
                value: panchang.tithi,
                subValue: 'Lord: $tithiLord',
                color: const Color(0xFF6EE7B7),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PanchangElementCard(
                icon: Icons.star_rounded,
                label: 'Nakshatra',
                value: panchang.nakshatra,
                subValue: 'Pada ${panchang.nakshatraPada}',
                color: const Color(0xFFFBBF24),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Row 2: Yoga & Karana
        Row(
          children: [
            Expanded(
              child: _PanchangElementCard(
                icon: Icons.link_rounded,
                label: 'Yoga (${panchang.yogaNumber}/27)',
                value: panchang.yoga,
                subValue: yogaType,
                color: yogaColor,
                showIndicator: true,
                indicatorColor: yogaColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PanchangElementCard(
                icon: Icons.hourglass_bottom_rounded,
                label: 'Karana',
                value: panchang.karana,
                subValue: karanaType,
                color: karanaColor,
                showIndicator: karanaType.contains('Bhadra'),
                indicatorColor: karanaColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getYogaTypeColor(String type) {
    switch (type) {
      case 'Auspicious':
        return const Color(0xFF6EE7B7);
      case 'Inauspicious':
        return const Color(0xFFF87171);
      default:
        return const Color(0xFF60A5FA);
    }
  }
}

class _PanchangElementCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subValue;
  final Color color;
  final bool showIndicator;
  final Color? indicatorColor;

  const _PanchangElementCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subValue,
    required this.color,
    this.showIndicator = false,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.2),
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
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: KundliDisplayColors.textMuted,
                  ),
                ),
              ),
              if (showIndicator)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: indicatorColor ?? color,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: KundliDisplayColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subValue,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HORA CARD
// ═══════════════════════════════════════════════════════════════════════════
class _HoraCard extends StatelessWidget {
  final String hora;
  final DateTime birthTime;

  const _HoraCard({required this.hora, required this.birthTime});

  @override
  Widget build(BuildContext context) {
    final horaColor = _getHoraColor(hora);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: horaColor.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      horaColor.withOpacity(0.2),
                      horaColor.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _getHoraSymbol(hora),
                  style: TextStyle(fontSize: 18, color: horaColor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Birth Hora',
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        color: KundliDisplayColors.textMuted,
                      ),
                    ),
                    Text(
                      '$hora Hora',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: KundliDisplayColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _getHoraDescription(hora),
            style: GoogleFonts.dmSans(
              fontSize: 9,
              color: KundliDisplayColors.textMuted,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getHoraColor(String planet) {
    const colors = {
      'Sun': Color(0xFFD4AF37),
      'Moon': Color(0xFF6EE7B7),
      'Mars': Color(0xFFF87171),
      'Mercury': Color(0xFF34D399),
      'Jupiter': Color(0xFFFBBF24),
      'Venus': Color(0xFFF472B6),
      'Saturn': Color(0xFF9CA3AF),
    };
    return colors[planet] ?? KundliDisplayColors.textMuted;
  }

  String _getHoraSymbol(String planet) {
    const symbols = {
      'Sun': '☉',
      'Moon': '☽',
      'Mars': '♂',
      'Mercury': '☿',
      'Jupiter': '♃',
      'Venus': '♀',
      'Saturn': '♄',
    };
    return symbols[planet] ?? '•';
  }

  String _getHoraDescription(String planet) {
    const descriptions = {
      'Sun': 'Authority, government work, leadership',
      'Moon': 'Travel, emotions, public dealing',
      'Mars': 'Courage, competition, action',
      'Mercury': 'Communication, learning, business',
      'Jupiter': 'Education, spirituality, expansion',
      'Venus': 'Arts, relationships, pleasures',
      'Saturn': 'Hard work, discipline, patience',
    };
    return descriptions[planet] ?? '';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WEEKDAY CARD
// ═══════════════════════════════════════════════════════════════════════════
class _WeekdayCard extends StatelessWidget {
  final PanchangData panchang;

  const _WeekdayCard({required this.panchang});

  @override
  Widget build(BuildContext context) {
    final varaLord = _getVaraLord(panchang.vara);
    final varaColor = _getVaraColor(panchang.vara);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: varaColor.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      varaColor.withOpacity(0.2),
                      varaColor.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _getPlanetSymbol(varaLord),
                  style: TextStyle(fontSize: 18, color: varaColor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vara (Weekday)',
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        color: KundliDisplayColors.textMuted,
                      ),
                    ),
                    Text(
                      panchang.vara,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: KundliDisplayColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Lord: ',
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  color: KundliDisplayColors.textMuted,
                ),
              ),
              Text(
                varaLord,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: varaColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '• ${panchang.varaDeity}',
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  color: KundliDisplayColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getVaraLord(String vara) {
    const lords = {
      'Sunday': 'Sun',
      'Monday': 'Moon',
      'Tuesday': 'Mars',
      'Wednesday': 'Mercury',
      'Thursday': 'Jupiter',
      'Friday': 'Venus',
      'Saturday': 'Saturn',
    };
    return lords[vara] ?? 'Unknown';
  }

  Color _getVaraColor(String vara) {
    const colors = {
      'Sunday': Color(0xFFD4AF37),
      'Monday': Color(0xFF6EE7B7),
      'Tuesday': Color(0xFFF87171),
      'Wednesday': Color(0xFF34D399),
      'Thursday': Color(0xFFFBBF24),
      'Friday': Color(0xFFF472B6),
      'Saturday': Color(0xFF9CA3AF),
    };
    return colors[vara] ?? KundliDisplayColors.textMuted;
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
    };
    return symbols[planet] ?? '•';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INAUSPICIOUS PERIODS CARD
// ═══════════════════════════════════════════════════════════════════════════
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
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF87171).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          if (currentPeriod != null) ...[
            _BirthWarningBanner(period: currentPeriod),
            const SizedBox(height: 14),
          ],

          // Period rows
          _InauspiciousPeriodRow(
            period: periods.rahukala,
            color: const Color(0xFFF87171),
            icon: Icons.do_not_disturb_on_rounded,
          ),
          const SizedBox(height: 8),
          _InauspiciousPeriodRow(
            period: periods.yamaghanda,
            color: const Color(0xFFFBBF24),
            icon: Icons.warning_rounded,
          ),
          const SizedBox(height: 8),
          _InauspiciousPeriodRow(
            period: periods.gulika,
            color: const Color(0xFFA78BFA),
            icon: Icons.brightness_3_rounded,
          ),

          const SizedBox(height: 14),

          // Visual timeline
          _InauspiciousTimeline(
            periods: periods,
            birthDateTime: birthDateTime,
          ),
        ],
      ),
    );
  }
}

class _BirthWarningBanner extends StatelessWidget {
  final TimePeriod period;

  const _BirthWarningBanner({required this.period});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF87171).withOpacity(0.15),
            const Color(0xFFF87171).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF87171).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF87171).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFF87171),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.12), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
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
            const Spacer(),
            Container(
              width: 12,
              height: 2,
              color: KundliDisplayColors.accentPrimary,
            ),
            const SizedBox(width: 4),
            Text(
              'Birth',
              style: GoogleFonts.dmMono(
                fontSize: 8,
                color: KundliDisplayColors.accentPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return SizedBox(
              height: 28,
              child: Stack(
                children: [
                  Container(
                    height: 10,
                    margin: const EdgeInsets.only(top: 9),
                    decoration: BoxDecoration(
                      color: KundliDisplayColors.surfaceColor,
                      borderRadius: BorderRadius.circular(5),
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
            Text('6AM', style: GoogleFonts.dmMono(fontSize: 8, color: KundliDisplayColors.textMuted)),
            Text('9AM', style: GoogleFonts.dmMono(fontSize: 8, color: KundliDisplayColors.textMuted)),
            Text('12PM', style: GoogleFonts.dmMono(fontSize: 8, color: KundliDisplayColors.textMuted)),
            Text('3PM', style: GoogleFonts.dmMono(fontSize: 8, color: KundliDisplayColors.textMuted)),
            Text('6PM', style: GoogleFonts.dmMono(fontSize: 8, color: KundliDisplayColors.textMuted)),
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
      top: 9,
      child: Container(
        width: widthFraction * maxWidth,
        height: 10,
        decoration: BoxDecoration(
          color: color.withOpacity(0.7),
          borderRadius: BorderRadius.circular(5),
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
        width: 3,
        height: 28,
        decoration: BoxDecoration(
          color: KundliDisplayColors.accentPrimary,
          borderRadius: BorderRadius.circular(1.5),
          boxShadow: [
            BoxShadow(
              color: KundliDisplayColors.accentPrimary.withOpacity(0.4),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VARSHPHAL CARD
// ═══════════════════════════════════════════════════════════════════════════
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
          // Header row
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      KundliDisplayColors.accentPrimary.withOpacity(0.2),
                      KundliDisplayColors.accentPrimary.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: KundliDisplayColors.accentPrimary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${varshphal.age}',
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: KundliDisplayColors.accentPrimary,
                        height: 1,
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solar Return ${varshphal.year}',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: KundliDisplayColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.event_rounded,
                          size: 12,
                          color: KundliDisplayColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('d MMM yyyy').format(varshphal.solarReturnDate),
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: KundliDisplayColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Info row
          Row(
            children: [
              Expanded(
                child: _VarshphalInfoTile(
                  icon: Icons.place_rounded,
                  label: 'Muntha Sign',
                  value: varshphal.munthaSign,
                  color: KundliDisplayColors.accentSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VarshphalInfoTile(
                  icon: Icons.person_rounded,
                  label: 'Year Lord',
                  value: varshphal.yearLord,
                  color: KundliDisplayColors.accentPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Info footer
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
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
                    'Varshphal is the annual horoscope calculated from your solar return date',
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      color: KundliDisplayColors.textMuted.withOpacity(0.7),
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

class _VarshphalInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _VarshphalInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
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
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: KundliDisplayColors.textPrimary,
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
