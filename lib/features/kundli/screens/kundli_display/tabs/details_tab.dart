import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../shared/constants.dart';
import '../widgets/moon_phase_widget.dart';

/// Details Tab - Shows comprehensive birth chart details
class DetailsTab extends StatelessWidget {
  final KundaliData kundaliData;

  const DetailsTab({super.key, required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _QuickStats(kundaliData: kundaliData),
          const SizedBox(height: 16),
          _BasicInfo(kundaliData: kundaliData),
          const SizedBox(height: 16),
          _AscendantDetails(kundaliData: kundaliData),
          const SizedBox(height: 16),
          _NakshatraDetails(kundaliData: kundaliData),
          const SizedBox(height: 16),
          _PanchangDetails(kundaliData: kundaliData),
          const SizedBox(height: 16),
          _CurrentDashaDetails(kundaliData: kundaliData),
          const SizedBox(height: 16),
          _CompatibilityDetails(kundaliData: kundaliData),
          const SizedBox(height: 16),
          _LuckyFactors(kundaliData: kundaliData),
          const SizedBox(height: 16),
          _PlanetaryStatus(kundaliData: kundaliData),
        ],
      ),
    );
  }
}

// ============ Quick Stats ============
class _QuickStats extends StatelessWidget {
  final KundaliData kundaliData;

  const _QuickStats({required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KundliDisplayColors.accentPrimary.withOpacity(0.12),
            KundliDisplayColors.accentSecondary.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KundliDisplayColors.accentPrimary.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          _StatItem(
            label: 'Ascendant',
            value: kundaliData.ascendant.sign,
            icon: Icons.north_east_rounded,
            color: KundliDisplayColors.accentSecondary,
          ),
          _StatDivider(),
          _StatItem(
            label: 'Moon Sign',
            value: kundaliData.moonSign,
            icon: Icons.nightlight_round,
            color: const Color(0xFF6EE7B7),
          ),
          _StatDivider(),
          _StatItem(
            label: 'Sun Sign',
            value: kundaliData.sunSign,
            icon: Icons.wb_sunny_rounded,
            color: KundliDisplayColors.accentPrimary,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: KundliDisplayColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              color: KundliDisplayColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: KundliDisplayColors.borderColor.withOpacity(0.4),
    );
  }
}

// ============ Basic Info ============
class _BasicInfo extends StatelessWidget {
  final KundaliData kundaliData;

  const _BasicInfo({required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      title: 'Birth Details',
      icon: Icons.info_outline_rounded,
      color: const Color(0xFF60A5FA),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DetailItem(
                  label: 'Date',
                  value: '${kundaliData.birthDateTime.day}/${kundaliData.birthDateTime.month}/${kundaliData.birthDateTime.year}',
                  icon: Icons.calendar_today_rounded,
                  color: const Color(0xFF6EE7B7),
                ),
              ),
              Expanded(
                child: DetailItem(
                  label: 'Time',
                  value: '${kundaliData.birthDateTime.hour.toString().padLeft(2, '0')}:${kundaliData.birthDateTime.minute.toString().padLeft(2, '0')}',
                  icon: Icons.access_time_rounded,
                  color: const Color(0xFFFBBF24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DetailItem(
                  label: 'Location',
                  value: kundaliData.birthPlace,
                  icon: Icons.place_rounded,
                  color: const Color(0xFFF472B6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ Ascendant Details ============
class _AscendantDetails extends StatelessWidget {
  final KundaliData kundaliData;

  const _AscendantDetails({required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final ascendant = kundaliData.ascendant;
    final lagnaLord = _getLagnaLord(ascendant.sign);
    final ascNakshatra = _getNakshatraFromLongitude(ascendant.longitude);
    final nakshatraLord = _getNakshatraLord(ascNakshatra);

    return DetailCard(
      title: 'Lagna (Ascendant)',
      icon: Icons.north_east_rounded,
      color: KundliDisplayColors.accentSecondary,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DetailItem(
                  label: 'Lagna Sign',
                  value: ascendant.sign,
                  icon: Icons.blur_circular_rounded,
                  color: KundliDisplayColors.accentSecondary,
                ),
              ),
              Expanded(
                child: DetailItem(
                  label: 'Degree',
                  value: '${(ascendant.longitude % 30).toStringAsFixed(2)}°',
                  icon: Icons.straighten_rounded,
                  color: const Color(0xFF60A5FA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DetailItem(
                  label: 'Nakshatra',
                  value: ascNakshatra,
                  icon: Icons.star_rounded,
                  color: const Color(0xFFFBBF24),
                ),
              ),
              Expanded(
                child: DetailItem(
                  label: 'Lagna Lord',
                  value: lagnaLord,
                  icon: Icons.person_rounded,
                  color: const Color(0xFF6EE7B7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DetailItem(
                  label: 'Nakshatra Lord',
                  value: nakshatraLord,
                  icon: Icons.auto_awesome_rounded,
                  color: const Color(0xFFF472B6),
                ),
              ),
              Expanded(
                child: DetailItem(
                  label: 'Element',
                  value: _getSignElement(ascendant.sign),
                  icon: _getElementIcon(ascendant.sign),
                  color: _getElementColor(ascendant.sign),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ Nakshatra Details ============
class _NakshatraDetails extends StatelessWidget {
  final KundaliData kundaliData;

  const _NakshatraDetails({required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final moonPos = kundaliData.planetPositions['Moon']!;
    final nakshatra = kundaliData.birthNakshatra;
    final pada = kundaliData.birthNakshatraPada;
    final nakshatraLord = _getNakshatraLord(nakshatra);
    final deity = _getNakshatraDeity(nakshatra);
    final gana = _getNakshatraGana(nakshatra);
    final symbol = _getNakshatraSymbol(nakshatra);

    return DetailCard(
      title: 'Nakshatra Details',
      icon: Icons.stars_rounded,
      color: const Color(0xFFF472B6),
      child: Column(
        children: [
          // Main nakshatra display
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF472B6).withOpacity(0.12),
                  const Color(0xFFA78BFA).withOpacity(0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF472B6).withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF472B6).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(symbol, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nakshatra,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: KundliDisplayColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pada $pada • ${moonPos.signDegree.toStringAsFixed(2)}° in ${moonPos.sign}',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: KundliDisplayColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getGanaColor(gana).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    gana,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getGanaColor(gana),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DetailItem(
                  label: 'Lord',
                  value: nakshatraLord,
                  icon: Icons.person_outline_rounded,
                  color: const Color(0xFFA78BFA),
                ),
              ),
              Expanded(
                child: DetailItem(
                  label: 'Deity',
                  value: deity,
                  icon: Icons.temple_hindu_rounded,
                  color: const Color(0xFFFBBF24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DetailItem(
                  label: 'Gana',
                  value: gana,
                  icon: Icons.group_rounded,
                  color: _getGanaColor(gana),
                ),
              ),
              Expanded(
                child: DetailItem(
                  label: 'Yoni',
                  value: _getNakshatraYoni(nakshatra),
                  icon: Icons.pets_rounded,
                  color: const Color(0xFF67E8F9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ Panchang Details ============
class _PanchangDetails extends StatelessWidget {
  final KundaliData kundaliData;

  const _PanchangDetails({required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final sunPos = kundaliData.planetPositions['Sun'];
    final moonPos = kundaliData.planetPositions['Moon'];

    final panchang = KundaliCalculationService.calculatePanchang(
      kundaliData.birthDateTime,
      sunPos?.longitude ?? 0,
      moonPos?.longitude ?? 0,
    );

    return DetailCard(
      title: 'Panchang at Birth',
      icon: Icons.calendar_month_rounded,
      color: const Color(0xFF6EE7B7),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6EE7B7).withOpacity(0.12),
                  const Color(0xFF22D3EE).withOpacity(0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6EE7B7).withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                MoonPhaseWidget(
                  tithiNumber: panchang.tithiNumber,
                  paksha: panchang.paksha,
                  size: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${panchang.paksha} Paksha',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: KundliDisplayColors.textMuted,
                        ),
                      ),
                      Text(
                        panchang.tithi,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: KundliDisplayColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6EE7B7).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    panchang.vara,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6EE7B7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DetailItem(
                  label: 'Yoga',
                  value: panchang.yoga,
                  icon: Icons.link_rounded,
                  color: const Color(0xFF60A5FA),
                ),
              ),
              Expanded(
                child: DetailItem(
                  label: 'Karana',
                  value: panchang.karana,
                  icon: Icons.hourglass_bottom_rounded,
                  color: const Color(0xFFA78BFA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DetailItem(
                  label: 'Vara Deity',
                  value: panchang.varaDeity,
                  icon: Icons.temple_hindu_rounded,
                  color: KundliDisplayColors.accentPrimary,
                ),
              ),
              Expanded(
                child: DetailItem(
                  label: 'Nakshatra',
                  value: panchang.nakshatra,
                  icon: Icons.star_rounded,
                  color: const Color(0xFFF472B6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ Current Dasha Details ============
class _CurrentDashaDetails extends StatelessWidget {
  final KundaliData kundaliData;

  const _CurrentDashaDetails({required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final dasha = kundaliData.dashaInfo;
    final currentPlanetColor = _getPlanetColor(dasha.currentMahadasha);

    return DetailCard(
      title: 'Current Dasha Period',
      icon: Icons.timeline_rounded,
      color: const Color(0xFF60A5FA),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  currentPlanetColor.withOpacity(0.15),
                  currentPlanetColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: currentPlanetColor.withOpacity(0.25),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: currentPlanetColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _getPlanetSymbol(dasha.currentMahadasha),
                      style: TextStyle(fontSize: 22, color: currentPlanetColor),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mahadasha',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: KundliDisplayColors.textMuted,
                        ),
                      ),
                      Text(
                        '${dasha.currentMahadasha} Dasha',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: KundliDisplayColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.hourglass_bottom_rounded,
                            size: 10,
                            color: KundliDisplayColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${dasha.remainingYears.toStringAsFixed(1)} years remaining',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
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
          ),
          const SizedBox(height: 12),
          Text(
            'Upcoming Periods',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: KundliDisplayColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: dasha.sequence.take(5).map((period) {
                final isCurrent = period.planet == dasha.currentMahadasha;
                final color = _getPlanetColor(period.planet);
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? color.withOpacity(0.15)
                        : KundliDisplayColors.surfaceColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCurrent
                          ? color.withOpacity(0.3)
                          : KundliDisplayColors.borderColor.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getPlanetSymbol(period.planet),
                        style: TextStyle(fontSize: 16, color: color),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        period.planet.substring(0, 3),
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isCurrent ? color : KundliDisplayColors.textMuted,
                        ),
                      ),
                      Text(
                        '${period.years}y',
                        style: GoogleFonts.dmMono(
                          fontSize: 8,
                          color: KundliDisplayColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Compatibility Details ============
class _CompatibilityDetails extends StatelessWidget {
  final KundaliData kundaliData;

  const _CompatibilityDetails({required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final nakshatra = kundaliData.birthNakshatra;
    final gana = _getNakshatraGana(nakshatra);
    final varna = _getVarna(kundaliData.moonSign);
    final nadi = _getNadi(nakshatra);
    final yoni = _getNakshatraYoni(nakshatra);

    return DetailCard(
      title: 'Compatibility Factors (Guna)',
      icon: Icons.favorite_rounded,
      color: const Color(0xFFF472B6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _GunaItem(name: 'Varna', value: varna, points: '1/1', color: const Color(0xFFFBBF24))),
              Expanded(child: _GunaItem(name: 'Vashya', value: _getVashya(kundaliData.moonSign), points: '2/2', color: const Color(0xFF60A5FA))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _GunaItem(name: 'Tara', value: 'Janma', points: '3/3', color: const Color(0xFF6EE7B7))),
              Expanded(child: _GunaItem(name: 'Yoni', value: yoni, points: '4/4', color: const Color(0xFFA78BFA))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _GunaItem(name: 'Graha Maitri', value: _getLagnaLord(kundaliData.moonSign), points: '5/5', color: const Color(0xFF67E8F9))),
              Expanded(child: _GunaItem(name: 'Gana', value: gana, points: '6/6', color: _getGanaColor(gana))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _GunaItem(name: 'Bhakoot', value: kundaliData.moonSign, points: '7/7', color: const Color(0xFFFCA5A5))),
              Expanded(child: _GunaItem(name: 'Nadi', value: nadi, points: '8/8', color: const Color(0xFFD8B4FE))),
            ],
          ),
        ],
      ),
    );
  }
}

class _GunaItem extends StatelessWidget {
  final String name;
  final String value;
  final String points;
  final Color color;

  const _GunaItem({
    required this.name,
    required this.value,
    required this.points,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15), width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.dmSans(fontSize: 9, color: KundliDisplayColors.textMuted)),
                Text(
                  value,
                  style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: KundliDisplayColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(points, style: GoogleFonts.dmMono(fontSize: 8, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }
}

// ============ Lucky Factors ============
class _LuckyFactors extends StatelessWidget {
  final KundaliData kundaliData;

  const _LuckyFactors({required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final moonSign = kundaliData.moonSign;

    return DetailCard(
      title: 'Lucky Factors',
      icon: Icons.auto_awesome_rounded,
      color: KundliDisplayColors.accentPrimary,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _LuckyItem(label: 'Lucky Numbers', value: _getLuckyNumbers(moonSign), icon: Icons.tag_rounded, color: KundliDisplayColors.accentPrimary)),
              Expanded(child: _LuckyItem(label: 'Lucky Day', value: _getLuckyDay(moonSign), icon: Icons.calendar_today_rounded, color: const Color(0xFF6EE7B7))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _LuckyItem(label: 'Lucky Colors', value: _getLuckyColors(moonSign), icon: Icons.palette_rounded, color: const Color(0xFFF472B6))),
              Expanded(child: _LuckyItem(label: 'Lucky Metal', value: _getLuckyMetal(moonSign), icon: Icons.hardware_rounded, color: const Color(0xFF9CA3AF))),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  KundliDisplayColors.accentPrimary.withOpacity(0.12),
                  const Color(0xFFA78BFA).withOpacity(0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KundliDisplayColors.accentPrimary.withOpacity(0.2), width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: KundliDisplayColors.accentPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.diamond_rounded, size: 20, color: KundliDisplayColors.accentPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Primary Gemstone', style: GoogleFonts.dmSans(fontSize: 10, color: KundliDisplayColors.textMuted)),
                      Text(_getLuckyGemstone(moonSign), style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: KundliDisplayColors.textPrimary)),
                    ],
                  ),
                ),
                Text(_getGemstoneEmoji(moonSign), style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LuckyItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _LuckyItem({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: KundliDisplayColors.borderColor.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 12, color: color), const SizedBox(width: 5), Text(label, style: GoogleFonts.dmSans(fontSize: 9, color: KundliDisplayColors.textMuted))]),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: KundliDisplayColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ============ Planetary Status ============
class _PlanetaryStatus extends StatelessWidget {
  final KundaliData kundaliData;

  const _PlanetaryStatus({required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final planets = kundaliData.planetPositions;

    final retrograde = <String>[];
    final exalted = <String>[];
    final debilitated = <String>[];

    const exaltationSigns = {'Sun': 'Aries', 'Moon': 'Taurus', 'Mars': 'Capricorn', 'Mercury': 'Virgo', 'Jupiter': 'Cancer', 'Venus': 'Pisces', 'Saturn': 'Libra', 'Rahu': 'Taurus', 'Ketu': 'Scorpio'};
    const debilitationSigns = {'Sun': 'Libra', 'Moon': 'Scorpio', 'Mars': 'Cancer', 'Mercury': 'Pisces', 'Jupiter': 'Capricorn', 'Venus': 'Virgo', 'Saturn': 'Aries', 'Rahu': 'Scorpio', 'Ketu': 'Taurus'};

    planets.forEach((name, planet) {
      if (exaltationSigns[name] == planet.sign) exalted.add(name);
      if (debilitationSigns[name] == planet.sign) debilitated.add(name);
      if (planet.isRetrograde) retrograde.add(name);
    });

    return DetailCard(
      title: 'Planetary Status',
      icon: Icons.public_rounded,
      color: const Color(0xFF22D3EE),
      child: Column(
        children: [
          _StatusRow(label: 'Exalted', planets: exalted.isEmpty ? ['None'] : exalted, color: const Color(0xFF4ADE80), icon: Icons.arrow_upward_rounded),
          const SizedBox(height: 8),
          _StatusRow(label: 'Debilitated', planets: debilitated.isEmpty ? ['None'] : debilitated, color: const Color(0xFFF87171), icon: Icons.arrow_downward_rounded),
          const SizedBox(height: 8),
          _StatusRow(label: 'Retrograde', planets: retrograde.isEmpty ? ['None'] : retrograde, color: const Color(0xFFFBBF24), icon: Icons.replay_rounded),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final List<String> planets;
  final Color color;
  final IconData icon;

  const _StatusRow({required this.label, required this.planets, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: KundliDisplayColors.textMuted)),
          const Spacer(),
          Wrap(
            spacing: 6,
            children: planets.map((p) {
              final planetColor = p == 'None' ? KundliDisplayColors.textMuted : _getPlanetColor(p);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: planetColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  p == 'None' ? p : p.substring(0, math.min(3, p.length)),
                  style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: planetColor),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ============ Shared Widgets ============
class DetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const DetailCard({super.key, required this.title, required this.icon, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, childWidget) {
        return Transform.translate(
          offset: Offset(0, 15 * (1 - value)),
          child: Opacity(opacity: value, child: childWidget),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: KundliDisplayColors.borderColor.withOpacity(0.4), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 14, color: color),
                ),
                const SizedBox(width: 8),
                Text(title, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: KundliDisplayColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const DetailItem({super.key, required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: KundliDisplayColors.borderColor.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.dmSans(fontSize: 9, color: KundliDisplayColors.textMuted)),
                Text(value, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: KundliDisplayColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Helper Functions ============
Color _getPlanetColor(String planet) {
  const colors = {'Sun': Color(0xFFD4AF37), 'Moon': Color(0xFF6EE7B7), 'Mars': Color(0xFFF87171), 'Mercury': Color(0xFF34D399), 'Jupiter': Color(0xFFFBBF24), 'Venus': Color(0xFFF472B6), 'Saturn': Color(0xFF9CA3AF), 'Rahu': Color(0xFFA78BFA), 'Ketu': Color(0xFFC2410C)};
  return colors[planet] ?? Colors.grey;
}

String _getPlanetSymbol(String planet) {
  const symbols = {'Sun': '☉', 'Moon': '☽', 'Mars': '♂', 'Mercury': '☿', 'Jupiter': '♃', 'Venus': '♀', 'Saturn': '♄', 'Rahu': '☊', 'Ketu': '☋'};
  return symbols[planet] ?? planet.substring(0, 2);
}

String _getLagnaLord(String sign) {
  const lords = {'Aries': 'Mars', 'Taurus': 'Venus', 'Gemini': 'Mercury', 'Cancer': 'Moon', 'Leo': 'Sun', 'Virgo': 'Mercury', 'Libra': 'Venus', 'Scorpio': 'Mars', 'Sagittarius': 'Jupiter', 'Capricorn': 'Saturn', 'Aquarius': 'Saturn', 'Pisces': 'Jupiter'};
  return lords[sign] ?? 'Unknown';
}

String _getNakshatraFromLongitude(double longitude) {
  final index = (longitude / 13.333333).floor() % 27;
  return KundaliCalculationService.nakshatras[index];
}

String _getNakshatraLord(String nakshatra) {
  const lords = {'Ashwini': 'Ketu', 'Bharani': 'Venus', 'Krittika': 'Sun', 'Rohini': 'Moon', 'Mrigashira': 'Mars', 'Ardra': 'Rahu', 'Punarvasu': 'Jupiter', 'Pushya': 'Saturn', 'Ashlesha': 'Mercury', 'Magha': 'Ketu', 'Purva Phalguni': 'Venus', 'Uttara Phalguni': 'Sun', 'Hasta': 'Moon', 'Chitra': 'Mars', 'Swati': 'Rahu', 'Vishakha': 'Jupiter', 'Anuradha': 'Saturn', 'Jyeshtha': 'Mercury', 'Mula': 'Ketu', 'Purva Ashadha': 'Venus', 'Uttara Ashadha': 'Sun', 'Shravana': 'Moon', 'Dhanishta': 'Mars', 'Shatabhisha': 'Rahu', 'Purva Bhadrapada': 'Jupiter', 'Uttara Bhadrapada': 'Saturn', 'Revati': 'Mercury'};
  return lords[nakshatra] ?? 'Unknown';
}

String _getNakshatraDeity(String nakshatra) {
  const deities = {'Ashwini': 'Ashwini Kumaras', 'Bharani': 'Yama', 'Krittika': 'Agni', 'Rohini': 'Brahma', 'Mrigashira': 'Soma', 'Ardra': 'Rudra', 'Punarvasu': 'Aditi', 'Pushya': 'Brihaspati', 'Ashlesha': 'Nagas', 'Magha': 'Pitris', 'Purva Phalguni': 'Bhaga', 'Uttara Phalguni': 'Aryaman', 'Hasta': 'Savitar', 'Chitra': 'Vishwakarma', 'Swati': 'Vayu', 'Vishakha': 'Indra-Agni', 'Anuradha': 'Mitra', 'Jyeshtha': 'Indra', 'Mula': 'Nirriti', 'Purva Ashadha': 'Apas', 'Uttara Ashadha': 'Vishvadevas', 'Shravana': 'Vishnu', 'Dhanishta': 'Vasus', 'Shatabhisha': 'Varuna', 'Purva Bhadrapada': 'Aja Ekapada', 'Uttara Bhadrapada': 'Ahir Budhnya', 'Revati': 'Pushan'};
  return deities[nakshatra] ?? 'Unknown';
}

String _getNakshatraGana(String nakshatra) {
  const ganas = {'Ashwini': 'Deva', 'Bharani': 'Manushya', 'Krittika': 'Rakshasa', 'Rohini': 'Manushya', 'Mrigashira': 'Deva', 'Ardra': 'Manushya', 'Punarvasu': 'Deva', 'Pushya': 'Deva', 'Ashlesha': 'Rakshasa', 'Magha': 'Rakshasa', 'Purva Phalguni': 'Manushya', 'Uttara Phalguni': 'Manushya', 'Hasta': 'Deva', 'Chitra': 'Rakshasa', 'Swati': 'Deva', 'Vishakha': 'Rakshasa', 'Anuradha': 'Deva', 'Jyeshtha': 'Rakshasa', 'Mula': 'Rakshasa', 'Purva Ashadha': 'Manushya', 'Uttara Ashadha': 'Manushya', 'Shravana': 'Deva', 'Dhanishta': 'Rakshasa', 'Shatabhisha': 'Rakshasa', 'Purva Bhadrapada': 'Manushya', 'Uttara Bhadrapada': 'Manushya', 'Revati': 'Deva'};
  return ganas[nakshatra] ?? 'Manushya';
}

String _getNakshatraSymbol(String nakshatra) {
  const symbols = {'Ashwini': '🐴', 'Bharani': '🔺', 'Krittika': '🔥', 'Rohini': '🛞', 'Mrigashira': '🦌', 'Ardra': '💎', 'Punarvasu': '🏹', 'Pushya': '🌸', 'Ashlesha': '🐍', 'Magha': '👑', 'Purva Phalguni': '🛏️', 'Uttara Phalguni': '🛏️', 'Hasta': '✋', 'Chitra': '💠', 'Swati': '🌱', 'Vishakha': '🎯', 'Anuradha': '🪷', 'Jyeshtha': '☂️', 'Mula': '🦁', 'Purva Ashadha': '🐘', 'Uttara Ashadha': '🐘', 'Shravana': '👂', 'Dhanishta': '🎵', 'Shatabhisha': '⭕', 'Purva Bhadrapada': '⚔️', 'Uttara Bhadrapada': '🐍', 'Revati': '🐟'};
  return symbols[nakshatra] ?? '⭐';
}

String _getNakshatraYoni(String nakshatra) {
  const yonis = {'Ashwini': 'Horse', 'Bharani': 'Elephant', 'Krittika': 'Goat', 'Rohini': 'Serpent', 'Mrigashira': 'Serpent', 'Ardra': 'Dog', 'Punarvasu': 'Cat', 'Pushya': 'Goat', 'Ashlesha': 'Cat', 'Magha': 'Rat', 'Purva Phalguni': 'Rat', 'Uttara Phalguni': 'Cow', 'Hasta': 'Buffalo', 'Chitra': 'Tiger', 'Swati': 'Buffalo', 'Vishakha': 'Tiger', 'Anuradha': 'Deer', 'Jyeshtha': 'Deer', 'Mula': 'Dog', 'Purva Ashadha': 'Monkey', 'Uttara Ashadha': 'Mongoose', 'Shravana': 'Monkey', 'Dhanishta': 'Lion', 'Shatabhisha': 'Horse', 'Purva Bhadrapada': 'Lion', 'Uttara Bhadrapada': 'Cow', 'Revati': 'Elephant'};
  return yonis[nakshatra] ?? 'Unknown';
}

Color _getGanaColor(String gana) {
  switch (gana) {
    case 'Deva': return const Color(0xFF6EE7B7);
    case 'Manushya': return const Color(0xFF60A5FA);
    case 'Rakshasa': return const Color(0xFFF87171);
    default: return KundliDisplayColors.textMuted;
  }
}

String _getSignElement(String sign) {
  const elements = {'Aries': 'Fire', 'Taurus': 'Earth', 'Gemini': 'Air', 'Cancer': 'Water', 'Leo': 'Fire', 'Virgo': 'Earth', 'Libra': 'Air', 'Scorpio': 'Water', 'Sagittarius': 'Fire', 'Capricorn': 'Earth', 'Aquarius': 'Air', 'Pisces': 'Water'};
  return elements[sign] ?? 'Unknown';
}

IconData _getElementIcon(String sign) {
  switch (_getSignElement(sign)) {
    case 'Fire': return Icons.local_fire_department_rounded;
    case 'Earth': return Icons.landscape_rounded;
    case 'Air': return Icons.air_rounded;
    case 'Water': return Icons.water_drop_rounded;
    default: return Icons.circle;
  }
}

Color _getElementColor(String sign) {
  switch (_getSignElement(sign)) {
    case 'Fire': return const Color(0xFFF87171);
    case 'Earth': return const Color(0xFF6EE7B7);
    case 'Air': return const Color(0xFF60A5FA);
    case 'Water': return const Color(0xFF67E8F9);
    default: return KundliDisplayColors.textMuted;
  }
}

String _getVarna(String moonSign) {
  const varnas = {'Aries': 'Kshatriya', 'Leo': 'Kshatriya', 'Sagittarius': 'Kshatriya', 'Taurus': 'Vaishya', 'Virgo': 'Vaishya', 'Capricorn': 'Vaishya', 'Gemini': 'Shudra', 'Libra': 'Shudra', 'Aquarius': 'Shudra', 'Cancer': 'Brahmin', 'Scorpio': 'Brahmin', 'Pisces': 'Brahmin'};
  return varnas[moonSign] ?? 'Unknown';
}

String _getVashya(String moonSign) {
  const vashyas = {'Aries': 'Chatushpad', 'Taurus': 'Chatushpad', 'Leo': 'Chatushpad', 'Sagittarius': 'Chatushpad', 'Capricorn': 'Chatushpad', 'Gemini': 'Nara', 'Virgo': 'Nara', 'Libra': 'Nara', 'Aquarius': 'Nara', 'Cancer': 'Jalachara', 'Pisces': 'Jalachara', 'Scorpio': 'Keeta'};
  return vashyas[moonSign] ?? 'Unknown';
}

String _getNadi(String nakshatra) {
  const nadis = {'Ashwini': 'Aadi', 'Bharani': 'Madhya', 'Krittika': 'Antya', 'Rohini': 'Aadi', 'Mrigashira': 'Madhya', 'Ardra': 'Antya', 'Punarvasu': 'Aadi', 'Pushya': 'Madhya', 'Ashlesha': 'Antya', 'Magha': 'Aadi', 'Purva Phalguni': 'Madhya', 'Uttara Phalguni': 'Antya', 'Hasta': 'Aadi', 'Chitra': 'Madhya', 'Swati': 'Antya', 'Vishakha': 'Aadi', 'Anuradha': 'Madhya', 'Jyeshtha': 'Antya', 'Mula': 'Aadi', 'Purva Ashadha': 'Madhya', 'Uttara Ashadha': 'Antya', 'Shravana': 'Aadi', 'Dhanishta': 'Madhya', 'Shatabhisha': 'Antya', 'Purva Bhadrapada': 'Aadi', 'Uttara Bhadrapada': 'Madhya', 'Revati': 'Antya'};
  return nadis[nakshatra] ?? 'Unknown';
}

String _getLuckyNumbers(String moonSign) {
  const numbers = {'Aries': '1, 8, 9', 'Taurus': '2, 6, 7', 'Gemini': '3, 5, 6', 'Cancer': '2, 4, 7', 'Leo': '1, 4, 5', 'Virgo': '3, 5, 6', 'Libra': '2, 6, 7', 'Scorpio': '3, 9, 4', 'Sagittarius': '3, 5, 8', 'Capricorn': '4, 8, 6', 'Aquarius': '4, 7, 8', 'Pisces': '3, 7, 9'};
  return numbers[moonSign] ?? '1, 7, 9';
}

String _getLuckyDay(String moonSign) {
  const days = {'Aries': 'Tuesday', 'Taurus': 'Friday', 'Gemini': 'Wednesday', 'Cancer': 'Monday', 'Leo': 'Sunday', 'Virgo': 'Wednesday', 'Libra': 'Friday', 'Scorpio': 'Tuesday', 'Sagittarius': 'Thursday', 'Capricorn': 'Saturday', 'Aquarius': 'Saturday', 'Pisces': 'Thursday'};
  return days[moonSign] ?? 'Sunday';
}

String _getLuckyColors(String moonSign) {
  const colors = {'Aries': 'Red, Orange', 'Taurus': 'Green, Pink', 'Gemini': 'Yellow, Green', 'Cancer': 'White, Silver', 'Leo': 'Gold, Orange', 'Virgo': 'Green, Brown', 'Libra': 'Blue, Pink', 'Scorpio': 'Red, Maroon', 'Sagittarius': 'Yellow, Purple', 'Capricorn': 'Black, Brown', 'Aquarius': 'Blue, Electric', 'Pisces': 'Sea Green, Lavender'};
  return colors[moonSign] ?? 'White';
}

String _getLuckyMetal(String moonSign) {
  const metals = {'Aries': 'Iron', 'Taurus': 'Copper', 'Gemini': 'Brass', 'Cancer': 'Silver', 'Leo': 'Gold', 'Virgo': 'Bronze', 'Libra': 'Copper', 'Scorpio': 'Iron', 'Sagittarius': 'Tin', 'Capricorn': 'Lead', 'Aquarius': 'Lead', 'Pisces': 'Tin'};
  return metals[moonSign] ?? 'Gold';
}

String _getLuckyGemstone(String moonSign) {
  const gems = {'Aries': 'Red Coral', 'Taurus': 'Diamond', 'Gemini': 'Emerald', 'Cancer': 'Pearl', 'Leo': 'Ruby', 'Virgo': 'Emerald', 'Libra': 'Diamond', 'Scorpio': 'Red Coral', 'Sagittarius': 'Yellow Sapphire', 'Capricorn': 'Blue Sapphire', 'Aquarius': 'Blue Sapphire', 'Pisces': 'Yellow Sapphire'};
  return gems[moonSign] ?? 'Pearl';
}

String _getGemstoneEmoji(String moonSign) {
  const gems = {'Aries': '🔴', 'Taurus': '💎', 'Gemini': '💚', 'Cancer': '🤍', 'Leo': '❤️', 'Virgo': '💚', 'Libra': '💎', 'Scorpio': '🔴', 'Sagittarius': '💛', 'Capricorn': '💙', 'Aquarius': '💙', 'Pisces': '💛'};
  return gems[moonSign] ?? '💎';
}

