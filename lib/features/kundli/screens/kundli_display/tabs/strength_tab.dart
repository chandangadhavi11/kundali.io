import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../shared/constants.dart';

/// Strength Tab - Shows Shadbala, Vimshopaka, and Ashtakavarga
/// Premium, elegant UI with clear visual hierarchy
class StrengthTab extends StatelessWidget {
  final KundaliData kundaliData;

  const StrengthTab({super.key, required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    // Calculate Shadbala (Six-fold strength) from planetary positions
    final shadbala = KundaliCalculationService.calculateShadbala(
      kundaliData.planetPositions,
      kundaliData.ascendant.longitude,
      kundaliData.birthDateTime,
    );

    // Calculate Vimshopaka Bala (Divisional chart strength)
    final vimshopaka = KundaliCalculationService.calculateVimshopakaBala(
      kundaliData.planetPositions,
    );

    // Calculate Ashtakavarga (Benefic points by sign)
    final ashtakavarga = KundaliCalculationService.calculateAshtakavarga(
      kundaliData.planetPositions,
    );

    // Calculate Sarvashtakavarga (Combined benefic points)
    final sav = KundaliCalculationService.calculateSarvashtakavarga(
      ashtakavarga,
    );

    // Calculate strength rankings
    final strengthRanking = _calculateStrengthRanking(shadbala);
    final strongestPlanet = strengthRanking.isNotEmpty ? strengthRanking.first : null;
    final weakestPlanet = strengthRanking.isNotEmpty ? strengthRanking.last : null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════════════════
          // HERO SUMMARY CARD
          // ═══════════════════════════════════════════════════════════════
          _StrengthHeroCard(
            shadbala: shadbala,
            strongestPlanet: strongestPlanet,
            weakestPlanet: weakestPlanet,
            ascendantSign: kundaliData.ascendant.sign,
          ),

          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════════
          // SHADBALA SECTION
          // ═══════════════════════════════════════════════════════════════
          _SectionLabel(
            title: 'Shadbala (षड्बल)',
            subtitle: 'Six-fold planetary strength',
            icon: Icons.fitness_center_rounded,
            color: const Color(0xFFA78BFA),
          ),
          const SizedBox(height: 12),
          _ShadbalaLegend(),
          const SizedBox(height: 12),
          ...shadbala.entries.map((entry) => _PremiumShadbalaCard(
                data: entry.value,
                rank: strengthRanking.indexOf(entry.key) + 1,
                totalPlanets: strengthRanking.length,
              )),

          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════════
          // VIMSHOPAKA BALA SECTION
          // ═══════════════════════════════════════════════════════════════
          _SectionLabel(
            title: 'Vimshopaka Bala',
            subtitle: 'Divisional chart strength (20-point scale)',
            icon: Icons.layers_rounded,
            color: const Color(0xFF60A5FA),
          ),
          const SizedBox(height: 12),
          _VimshopakaSummary(vimshopaka: vimshopaka),
          const SizedBox(height: 12),
          _VimshopakaBarsCard(vimshopaka: vimshopaka),

          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════════
          // ASHTAKAVARGA SECTION
          // ═══════════════════════════════════════════════════════════════
          _SectionLabel(
            title: 'Ashtakavarga (अष्टकवर्ग)',
            subtitle: 'Transit strength by sign',
            icon: Icons.grid_on_rounded,
            color: const Color(0xFF4ADE80),
          ),
          const SizedBox(height: 12),
          _AshtakavargaSummaryCard(ashtakavarga: ashtakavarga, sav: sav),
          const SizedBox(height: 12),
          _AshtakavargaHeatmap(ashtakavarga: ashtakavarga, sav: sav),
        ],
      ),
    );
  }

  List<String> _calculateStrengthRanking(Map<String, ShadbalaData> shadbala) {
    final entries = shadbala.entries.toList();
    entries.sort((a, b) => b.value.percentageOfRequired.compareTo(a.value.percentageOfRequired));
    return entries.map((e) => e.key).toList();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION LABEL
// ═══════════════════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SectionLabel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
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
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STRENGTH HERO CARD
// ═══════════════════════════════════════════════════════════════════════════
class _StrengthHeroCard extends StatelessWidget {
  final Map<String, ShadbalaData> shadbala;
  final String? strongestPlanet;
  final String? weakestPlanet;
  final String ascendantSign;

  const _StrengthHeroCard({
    required this.shadbala,
    required this.strongestPlanet,
    required this.weakestPlanet,
    required this.ascendantSign,
  });

  @override
  Widget build(BuildContext context) {
    final totalPercentage = shadbala.values
        .map((d) => d.percentageOfRequired)
        .fold<double>(0.0, (a, b) => a + b);
    final avgStrength = shadbala.isNotEmpty ? totalPercentage / shadbala.length : 0.0;
    final strongCount = shadbala.values.where((d) => d.isStrong).length;
    final weakCount = shadbala.values.length - strongCount;
    final lagnaLord = _getLagnaLord(ascendantSign);
    final lagnaLordStrength = shadbala[lagnaLord];
    final strengthLevel = _getStrengthLevel(avgStrength);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getStrengthColor(avgStrength).withOpacity(0.15),
            const Color(0xFFA78BFA).withOpacity(0.06),
            KundliDisplayColors.surfaceColor.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStrengthColor(avgStrength).withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStrengthColor(avgStrength).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row with gauge and info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Strength gauge
              _StrengthGauge(
                percentage: avgStrength,
                color: _getStrengthColor(avgStrength),
              ),
              const SizedBox(width: 20),
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
                            color: _getStrengthColor(avgStrength).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            strengthLevel.toUpperCase(),
                            style: GoogleFonts.dmMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _getStrengthColor(avgStrength),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chart Strength',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: KundliDisplayColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Strong/Weak count
                    Row(
                      children: [
                        _StatChip(
                          icon: Icons.trending_up_rounded,
                          value: '$strongCount',
                          label: 'Strong',
                          color: const Color(0xFF4ADE80),
                        ),
                        const SizedBox(width: 12),
                        _StatChip(
                          icon: Icons.trending_down_rounded,
                          value: '$weakCount',
                          label: 'Weak',
                          color: const Color(0xFFFBBF24),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Strongest and Weakest planets
          Row(
            children: [
              if (strongestPlanet != null)
                Expanded(
                  child: _PlanetHighlight(
                    label: 'Strongest',
                    planet: strongestPlanet!,
                    percentage: shadbala[strongestPlanet]?.percentageOfRequired ?? 0,
                    isPositive: true,
                  ),
                ),
              const SizedBox(width: 10),
              if (weakestPlanet != null)
                Expanded(
                  child: _PlanetHighlight(
                    label: 'Weakest',
                    planet: weakestPlanet!,
                    percentage: shadbala[weakestPlanet]?.percentageOfRequired ?? 0,
                    isPositive: false,
                  ),
                ),
            ],
          ),

          // Lagna Lord
          if (lagnaLordStrength != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: KundliDisplayColors.accentPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.home_rounded,
                      size: 16,
                      color: KundliDisplayColors.accentPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lagna Lord Strength',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: KundliDisplayColors.textMuted,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              lagnaLord,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: getPlanetColor(lagnaLord),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(Lord of $ascendantSign)',
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: lagnaLordStrength.isStrong
                          ? const Color(0xFF4ADE80).withOpacity(0.12)
                          : const Color(0xFFFBBF24).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${lagnaLordStrength.percentageOfRequired.toStringAsFixed(0)}%',
                      style: GoogleFonts.dmMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: lagnaLordStrength.isStrong
                            ? const Color(0xFF4ADE80)
                            : const Color(0xFFFBBF24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStrengthColor(double percentage) {
    if (percentage >= 100) return const Color(0xFF4ADE80);
    if (percentage >= 75) return const Color(0xFF60A5FA);
    if (percentage >= 50) return const Color(0xFFFBBF24);
    return const Color(0xFFF87171);
  }

  String _getStrengthLevel(double percentage) {
    if (percentage >= 100) return 'Excellent';
    if (percentage >= 75) return 'Good';
    if (percentage >= 50) return 'Average';
    return 'Needs Support';
  }

  String _getLagnaLord(String sign) {
    const lords = {
      'Aries': 'Mars', 'Taurus': 'Venus', 'Gemini': 'Mercury', 'Cancer': 'Moon',
      'Leo': 'Sun', 'Virgo': 'Mercury', 'Libra': 'Venus', 'Scorpio': 'Mars',
      'Sagittarius': 'Jupiter', 'Capricorn': 'Saturn', 'Aquarius': 'Saturn', 'Pisces': 'Jupiter',
    };
    return lords[sign] ?? 'Sun';
  }
}

class _StrengthGauge extends StatelessWidget {
  final double percentage;
  final Color color;

  const _StrengthGauge({required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 3,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              'AVG',
              style: GoogleFonts.dmMono(
                fontSize: 9,
                color: KundliDisplayColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: KundliDisplayColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanetHighlight extends StatelessWidget {
  final String label;
  final String planet;
  final double percentage;
  final bool isPositive;

  const _PlanetHighlight({
    required this.label,
    required this.planet,
    required this.percentage,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24);
    final planetColor = getPlanetColor(planet);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  planetColor.withOpacity(0.2),
                  planetColor.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                getPlanetSymbol(planet),
                style: TextStyle(fontSize: 16, color: planetColor),
              ),
            ),
          ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: GoogleFonts.dmMono(
                fontSize: 11,
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

// ═══════════════════════════════════════════════════════════════════════════
// SHADBALA LEGEND
// ═══════════════════════════════════════════════════════════════════════════
class _ShadbalaLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: const [
          _LegendItem(label: 'Sthana', hint: 'Position', color: Color(0xFFA78BFA)),
          SizedBox(width: 8),
          _LegendItem(label: 'Dig', hint: 'Direction', color: Color(0xFF60A5FA)),
          SizedBox(width: 8),
          _LegendItem(label: 'Kala', hint: 'Time', color: Color(0xFF6EE7B7)),
          SizedBox(width: 8),
          _LegendItem(label: 'Chesta', hint: 'Motion', color: Color(0xFFFBBF24)),
          SizedBox(width: 8),
          _LegendItem(label: 'Naisarg', hint: 'Natural', color: Color(0xFFF472B6)),
          SizedBox(width: 8),
          _LegendItem(label: 'Drik', hint: 'Aspect', color: Color(0xFF22D3EE)),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final String hint;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.hint,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15), width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            hint,
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

// ═══════════════════════════════════════════════════════════════════════════
// PREMIUM SHADBALA CARD
// ═══════════════════════════════════════════════════════════════════════════
class _PremiumShadbalaCard extends StatelessWidget {
  final ShadbalaData data;
  final int rank;
  final int totalPlanets;

  const _PremiumShadbalaCard({
    required this.data,
    required this.rank,
    required this.totalPlanets,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = data.percentageOfRequired.clamp(0.0, 150.0);
    final strengthColor = data.isStrong ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24);
    final planetColor = getPlanetColor(data.planet);
    final isBottomRank = rank >= totalPlanets - 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank == 1
              ? const Color(0xFF4ADE80).withOpacity(0.4)
              : isBottomRank
                  ? const Color(0xFFF87171).withOpacity(0.3)
                  : KundliDisplayColors.borderColor.withOpacity(0.3),
          width: rank == 1 ? 1.5 : 0.5,
        ),
        boxShadow: rank == 1
            ? [
                BoxShadow(
                  color: const Color(0xFF4ADE80).withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // Header row
            Row(
              children: [
                // Planet symbol with rank
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            planetColor.withOpacity(0.2),
                            planetColor.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: planetColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          getPlanetSymbol(data.planet),
                          style: TextStyle(fontSize: 22, color: planetColor),
                        ),
                      ),
                    ),
                    // Rank badge
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRankColor(rank, totalPlanets),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          '#$rank',
                          style: GoogleFonts.dmMono(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Planet info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            data.planet,
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: KundliDisplayColors.textPrimary,
                            ),
                          ),
                          if (rank == 1) ...[
                            const SizedBox(width: 6),
                            const Text('👑', style: TextStyle(fontSize: 12)),
                          ],
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: strengthColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              data.isStrong ? 'Strong' : 'Weak',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: strengthColor,
                              ),
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
                              color: KundliDisplayColors.borderColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percentage / 150,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    strengthColor.withOpacity(0.7),
                                    strengthColor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          // 100% marker
                          Positioned(
                            left: (100 / 150) * MediaQuery.of(context).size.width * 0.5,
                            top: 0,
                            child: Container(
                              width: 2,
                              height: 8,
                              color: KundliDisplayColors.textMuted.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${data.totalBala.toStringAsFixed(1)} / ${data.requiredBala.toStringAsFixed(0)} Rupas',
                            style: GoogleFonts.dmMono(
                              fontSize: 10,
                              color: KundliDisplayColors.textMuted,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: GoogleFonts.dmMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: strengthColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bala components
            _BalaComponentsRow(data: data),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank, int total) {
    if (rank == 1) return const Color(0xFF4ADE80);
    if (rank == 2) return const Color(0xFF60A5FA);
    if (rank == 3) return const Color(0xFFFBBF24);
    if (rank >= total - 1) return const Color(0xFFF87171);
    return KundliDisplayColors.textMuted;
  }
}

class _BalaComponentsRow extends StatelessWidget {
  final ShadbalaData data;

  const _BalaComponentsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final balas = [
      ('Sthana', data.sthanaBala, const Color(0xFFA78BFA)),
      ('Dig', data.digBala, const Color(0xFF60A5FA)),
      ('Kala', data.kalaBala, const Color(0xFF6EE7B7)),
      ('Chesta', data.chestaBala, const Color(0xFFFBBF24)),
      ('Naisarg', data.naisargikaBala, const Color(0xFFF472B6)),
      ('Drik', data.drikBala, const Color(0xFF22D3EE)),
    ];

    final maxValue = balas.map((b) => b.$2).reduce((a, b) => a > b ? a : b);
    final minValue = balas.map((b) => b.$2).reduce((a, b) => a < b ? a : b);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: balas.map((bala) {
          final isMax = bala.$2 == maxValue;
          final isMin = bala.$2 == minValue;

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isMax
                    ? const Color(0xFF4ADE80).withOpacity(0.12)
                    : isMin
                        ? const Color(0xFFF87171).withOpacity(0.08)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: isMax || isMin
                    ? Border.all(
                        color: isMax
                            ? const Color(0xFF4ADE80).withOpacity(0.3)
                            : const Color(0xFFF87171).withOpacity(0.2),
                        width: 0.5,
                      )
                    : null,
              ),
              child: Column(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: bala.$3,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bala.$2.toStringAsFixed(0),
                    style: GoogleFonts.dmMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isMax
                          ? const Color(0xFF4ADE80)
                          : isMin
                              ? const Color(0xFFF87171)
                              : KundliDisplayColors.textPrimary,
                    ),
                  ),
                  Text(
                    bala.$1,
                    style: GoogleFonts.dmSans(
                      fontSize: 7,
                      color: KundliDisplayColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VIMSHOPAKA SUMMARY
// ═══════════════════════════════════════════════════════════════════════════
class _VimshopakaSummary extends StatelessWidget {
  final Map<String, VimshopakaBalaData> vimshopaka;

  const _VimshopakaSummary({required this.vimshopaka});

  @override
  Widget build(BuildContext context) {
    final strongCount = vimshopaka.values.where((d) => d.strength == 'Strong').length;
    final mediumCount = vimshopaka.values.where((d) => d.strength == 'Medium').length;
    final weakCount = vimshopaka.values.where((d) => d.strength == 'Weak').length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF60A5FA).withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF60A5FA).withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: KundliDisplayColors.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Strength from 16 divisional charts (D1-D60)',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: KundliDisplayColors.textMuted,
              ),
            ),
          ),
          _MiniCount(count: strongCount, label: 'Strong', color: const Color(0xFF4ADE80)),
          const SizedBox(width: 8),
          _MiniCount(count: mediumCount, label: 'Med', color: const Color(0xFFFBBF24)),
          const SizedBox(width: 8),
          _MiniCount(count: weakCount, label: 'Weak', color: const Color(0xFFF87171)),
        ],
      ),
    );
  }
}

class _MiniCount extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _MiniCount({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: GoogleFonts.dmMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 8,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VIMSHOPAKA BARS CARD
// ═══════════════════════════════════════════════════════════════════════════
class _VimshopakaBarsCard extends StatelessWidget {
  final Map<String, VimshopakaBalaData> vimshopaka;

  const _VimshopakaBarsCard({required this.vimshopaka});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KundliDisplayColors.borderColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: vimshopaka.entries.map((entry) {
          final data = entry.value;
          final color = data.strength == 'Strong'
              ? const Color(0xFF4ADE80)
              : data.strength == 'Medium'
                  ? const Color(0xFFFBBF24)
                  : const Color(0xFFF87171);
          final planetColor = getPlanetColor(data.planet);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: planetColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      getPlanetSymbol(data.planet),
                      style: TextStyle(fontSize: 14, color: planetColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  data.planet.substring(0, 3),
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: KundliDisplayColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: KundliDisplayColors.borderColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: data.percentage / 100,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color.withOpacity(0.6), color],
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 50,
                  child: Text(
                    '${data.percentage.toStringAsFixed(0)}%',
                    style: GoogleFonts.dmMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ASHTAKAVARGA SUMMARY CARD
// ═══════════════════════════════════════════════════════════════════════════
class _AshtakavargaSummaryCard extends StatelessWidget {
  final Map<String, List<int>> ashtakavarga;
  final List<int> sav;

  const _AshtakavargaSummaryCard({required this.ashtakavarga, required this.sav});

  @override
  Widget build(BuildContext context) {
    int maxSav = 0, minSav = 56, maxIndex = 0, minIndex = 0;
    for (int i = 0; i < sav.length; i++) {
      if (sav[i] > maxSav) {
        maxSav = sav[i];
        maxIndex = i;
      }
      if (sav[i] < minSav) {
        minSav = sav[i];
        minIndex = i;
      }
    }

    final signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    final totalSav = sav.fold<int>(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF4ADE80).withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF4ADE80).withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: KundliDisplayColors.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Points 0-8 per sign. ≥4 = Auspicious. SAV ≥28 = Strong sign',
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    color: KundliDisplayColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SavHighlight(
                  label: 'Strongest',
                  sign: signs[maxIndex],
                  points: maxSav,
                  icon: Icons.arrow_upward_rounded,
                  color: const Color(0xFF4ADE80),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SavHighlight(
                  label: 'Weakest',
                  sign: signs[minIndex],
                  points: minSav,
                  icon: Icons.arrow_downward_rounded,
                  color: const Color(0xFFF87171),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SavHighlight(
                  label: 'Total SAV',
                  sign: '$totalSav',
                  points: -1,
                  icon: Icons.functions_rounded,
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

class _SavHighlight extends StatelessWidget {
  final String label;
  final String sign;
  final int points;
  final IconData icon;
  final Color color;

  const _SavHighlight({
    required this.label,
    required this.sign,
    required this.points,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
            sign,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: KundliDisplayColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (points >= 0)
            Text(
              '$points pts',
              style: GoogleFonts.dmMono(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ASHTAKAVARGA HEATMAP
// ═══════════════════════════════════════════════════════════════════════════
class _AshtakavargaHeatmap extends StatelessWidget {
  final Map<String, List<int>> ashtakavarga;
  final List<int> sav;

  const _AshtakavargaHeatmap({required this.ashtakavarga, required this.sav});

  @override
  Widget build(BuildContext context) {
    final signs = ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'];
    final planets = ashtakavarga.keys.toList();

    return Container(
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KundliDisplayColors.borderColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Header row with signs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '',
                    style: GoogleFonts.dmSans(fontSize: 9),
                  ),
                ),
                ...signs.map((s) => Expanded(
                      child: Center(
                        child: Text(
                          s,
                          style: TextStyle(
                            fontSize: 12,
                            color: KundliDisplayColors.textMuted,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),

          // Data rows
          ...planets.map((planet) {
            final values = ashtakavarga[planet]!;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: KundliDisplayColors.borderColor.withOpacity(0.15),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      planet.substring(0, 3),
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: getPlanetColor(planet),
                      ),
                    ),
                  ),
                  ...values.map((v) => Expanded(
                        child: Center(
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _getHeatmapColor(v),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                '$v',
                                style: GoogleFonts.dmMono(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: v >= 4 ? Colors.white : KundliDisplayColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            );
          }),

          // SAV row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: KundliDisplayColors.accentPrimary.withOpacity(0.06),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    'SAV',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: KundliDisplayColors.accentPrimary,
                    ),
                  ),
                ),
                ...sav.map((v) => Expanded(
                      child: Center(
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _getSavColor(v),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '$v',
                              style: GoogleFonts.dmMono(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: v >= 28 ? Colors.white : KundliDisplayColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getHeatmapColor(int value) {
    if (value >= 6) return const Color(0xFF4ADE80);
    if (value >= 4) return const Color(0xFF4ADE80).withOpacity(0.4);
    if (value >= 3) return const Color(0xFFFBBF24).withOpacity(0.3);
    if (value >= 2) return const Color(0xFFF87171).withOpacity(0.2);
    return const Color(0xFFF87171).withOpacity(0.1);
  }

  Color _getSavColor(int value) {
    if (value >= 30) return const Color(0xFF4ADE80);
    if (value >= 28) return const Color(0xFF4ADE80).withOpacity(0.6);
    if (value >= 25) return const Color(0xFFFBBF24).withOpacity(0.4);
    if (value >= 22) return const Color(0xFFF87171).withOpacity(0.3);
    return const Color(0xFFF87171).withOpacity(0.15);
  }
}

