import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../shared/constants.dart';

/// Planets Tab - Shows all planetary positions with comprehensive details
/// Premium, elegant UI with clear visual hierarchy
class PlanetsTab extends StatelessWidget {
  final KundaliData kundaliData;

  const PlanetsTab({super.key, required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final sunPosition = kundaliData.planetPositions['Sun'];
    final planets = kundaliData.planetPositions.values.toList();

    // Calculate summary stats
    final stats = _calculatePlanetStats(planets, sunPosition);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ═══════════════════════════════════════════════════════════════
        // HEADER SECTION
        // ═══════════════════════════════════════════════════════════════
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                _PlanetsSummaryCard(
                  stats: stats,
                  totalPlanets: planets.length,
                ),
                const SizedBox(height: 16),
                _DignityLegend(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // ═══════════════════════════════════════════════════════════════
        // PLANETS LIST
        // ═══════════════════════════════════════════════════════════════
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final planet = planets[index];
              final color = getPlanetColor(planet.planet);
              final dignity = _calculateDignity(planet.planet, planet.sign);
              final nakshatraLord = _getNakshatraLord(planet.nakshatra);
              final nakshatraPada = _calculateNakshatraPada(planet.longitude);
              final isCombust = _checkCombustion(planet, sunPosition);
              final nature = _getPlanetNature(planet.planet);

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 200 + (index * 30)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 8 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: _PremiumPlanetCard(
                  planet: planet,
                  color: color,
                  dignity: dignity,
                  nakshatraLord: nakshatraLord,
                  nakshatraPada: nakshatraPada,
                  isCombust: isCombust,
                  nature: nature,
                ),
              );
            }, childCount: planets.length),
          ),
        ),
      ],
    );
  }

  Map<String, int> _calculatePlanetStats(
    List<PlanetPosition> planets,
    PlanetPosition? sunPosition,
  ) {
    int exalted = 0;
    int debilitated = 0;
    int retrograde = 0;
    int combust = 0;

    for (final planet in planets) {
      final dignity = _calculateDignity(planet.planet, planet.sign);
      if (dignity == 'Exalted') exalted++;
      if (dignity == 'Debilitated') debilitated++;
      if (planet.isRetrograde && planet.planet != 'Rahu' && planet.planet != 'Ketu') {
        retrograde++;
      }
      if (_checkCombustion(planet, sunPosition)) combust++;
    }

    return {
      'exalted': exalted,
      'debilitated': debilitated,
      'retrograde': retrograde,
      'combust': combust,
    };
  }

  String _calculateDignity(String planetName, String sign) {
    const exaltation = {
      'Sun': 'Aries', 'Moon': 'Taurus', 'Mars': 'Capricorn',
      'Mercury': 'Virgo', 'Jupiter': 'Cancer', 'Venus': 'Pisces',
      'Saturn': 'Libra', 'Rahu': 'Taurus', 'Ketu': 'Scorpio',
    };

    const debilitation = {
      'Sun': 'Libra', 'Moon': 'Scorpio', 'Mars': 'Cancer',
      'Mercury': 'Pisces', 'Jupiter': 'Capricorn', 'Venus': 'Virgo',
      'Saturn': 'Aries', 'Rahu': 'Scorpio', 'Ketu': 'Taurus',
    };

    const ownSigns = {
      'Sun': ['Leo'], 'Moon': ['Cancer'],
      'Mars': ['Aries', 'Scorpio'], 'Mercury': ['Gemini', 'Virgo'],
      'Jupiter': ['Sagittarius', 'Pisces'], 'Venus': ['Taurus', 'Libra'],
      'Saturn': ['Capricorn', 'Aquarius'], 'Rahu': ['Aquarius'], 'Ketu': ['Scorpio'],
    };

    const moolatrikona = {
      'Sun': 'Leo', 'Moon': 'Taurus', 'Mars': 'Aries',
      'Mercury': 'Virgo', 'Jupiter': 'Sagittarius',
      'Venus': 'Libra', 'Saturn': 'Aquarius',
    };

    if (exaltation[planetName] == sign) return 'Exalted';
    if (debilitation[planetName] == sign) return 'Debilitated';
    if (ownSigns[planetName]?.contains(sign) == true) {
      if (moolatrikona[planetName] == sign) return 'Moolatrikona';
      return 'Own Sign';
    }

    final friendlyEnemy = _getFriendlyEnemyStatus(planetName, sign);
    if (friendlyEnemy.isNotEmpty) return friendlyEnemy;

    return '';
  }

  String _getFriendlyEnemyStatus(String planet, String sign) {
    const signLords = {
      'Aries': 'Mars', 'Taurus': 'Venus', 'Gemini': 'Mercury', 'Cancer': 'Moon',
      'Leo': 'Sun', 'Virgo': 'Mercury', 'Libra': 'Venus', 'Scorpio': 'Mars',
      'Sagittarius': 'Jupiter', 'Capricorn': 'Saturn', 'Aquarius': 'Saturn', 'Pisces': 'Jupiter',
    };

    const friends = {
      'Sun': ['Moon', 'Mars', 'Jupiter'], 'Moon': ['Sun', 'Mercury'],
      'Mars': ['Sun', 'Moon', 'Jupiter'], 'Mercury': ['Sun', 'Venus'],
      'Jupiter': ['Sun', 'Moon', 'Mars'], 'Venus': ['Mercury', 'Saturn'],
      'Saturn': ['Mercury', 'Venus'],
    };

    const enemies = {
      'Sun': ['Venus', 'Saturn'], 'Moon': <String>[],
      'Mars': ['Mercury'], 'Mercury': ['Moon'],
      'Jupiter': ['Mercury', 'Venus'], 'Venus': ['Sun', 'Moon'],
      'Saturn': ['Sun', 'Moon', 'Mars'],
    };

    final signLord = signLords[sign];
    if (signLord == null) return '';

    if (friends[planet]?.contains(signLord) == true) return 'Friendly';
    if (enemies[planet]?.contains(signLord) == true) return 'Enemy';

    return 'Neutral';
  }

  String _getNakshatraLord(String nakshatra) {
    const lords = {
      'Ashwini': 'Ketu', 'Bharani': 'Venus', 'Krittika': 'Sun',
      'Rohini': 'Moon', 'Mrigashira': 'Mars', 'Ardra': 'Rahu',
      'Punarvasu': 'Jupiter', 'Pushya': 'Saturn', 'Ashlesha': 'Mercury',
      'Magha': 'Ketu', 'Purva Phalguni': 'Venus', 'Uttara Phalguni': 'Sun',
      'Hasta': 'Moon', 'Chitra': 'Mars', 'Swati': 'Rahu',
      'Vishakha': 'Jupiter', 'Anuradha': 'Saturn', 'Jyeshtha': 'Mercury',
      'Mula': 'Ketu', 'Purva Ashadha': 'Venus', 'Uttara Ashadha': 'Sun',
      'Shravana': 'Moon', 'Dhanishta': 'Mars', 'Shatabhisha': 'Rahu',
      'Purva Bhadrapada': 'Jupiter', 'Uttara Bhadrapada': 'Saturn', 'Revati': 'Mercury',
    };
    return lords[nakshatra] ?? 'Unknown';
  }

  int _calculateNakshatraPada(double longitude) {
    final nakshatraPosition = longitude % 13.333333;
    final pada = (nakshatraPosition / 3.333333).floor() + 1;
    return pada.clamp(1, 4);
  }

  bool _checkCombustion(PlanetPosition planet, PlanetPosition? sunPosition) {
    if (sunPosition == null ||
        planet.planet == 'Sun' ||
        planet.planet == 'Rahu' ||
        planet.planet == 'Ketu') {
      return false;
    }

    const combustionOrbs = {
      'Moon': 12.0, 'Mars': 17.0, 'Mercury': 14.0,
      'Jupiter': 11.0, 'Venus': 10.0, 'Saturn': 15.0,
    };

    final orb = combustionOrbs[planet.planet];
    if (orb == null) return false;

    double distance = (planet.longitude - sunPosition.longitude).abs();
    if (distance > 180) distance = 360 - distance;

    return distance <= orb;
  }

  String _getPlanetNature(String planet) {
    const benefics = ['Jupiter', 'Venus', 'Moon', 'Mercury'];
    const malefics = ['Sun', 'Mars', 'Saturn', 'Rahu', 'Ketu'];

    if (benefics.contains(planet)) return 'Benefic';
    if (malefics.contains(planet)) return 'Malefic';
    return 'Neutral';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUMMARY CARD
// ═══════════════════════════════════════════════════════════════════════════
class _PlanetsSummaryCard extends StatelessWidget {
  final Map<String, int> stats;
  final int totalPlanets;

  const _PlanetsSummaryCard({required this.stats, required this.totalPlanets});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KundliDisplayColors.accentPrimary.withOpacity(0.12),
            KundliDisplayColors.accentSecondary.withOpacity(0.06),
            KundliDisplayColors.surfaceColor.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: KundliDisplayColors.accentPrimary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: KundliDisplayColors.accentPrimary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Planet count display
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
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$totalPlanets',
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: KundliDisplayColors.accentPrimary,
                        height: 1,
                      ),
                    ),
                    Text(
                      'Grahas',
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: KundliDisplayColors.accentPrimary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'PLANETARY POSITIONS',
                            style: GoogleFonts.dmMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: KundliDisplayColors.accentPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Graha Sthiti',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: KundliDisplayColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Based on Swiss Ephemeris calculations',
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

          const SizedBox(height: 16),

          // Stats row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _SummaryStatItem(
                  icon: Icons.arrow_upward_rounded,
                  value: '${stats['exalted']}',
                  label: 'Exalted',
                  color: const Color(0xFF6EE7B7),
                ),
                _StatDivider(),
                _SummaryStatItem(
                  icon: Icons.arrow_downward_rounded,
                  value: '${stats['debilitated']}',
                  label: 'Debilitated',
                  color: const Color(0xFFF87171),
                ),
                _StatDivider(),
                _SummaryStatItem(
                  icon: Icons.replay_rounded,
                  value: '${stats['retrograde']}',
                  label: 'Retrograde',
                  color: const Color(0xFFFBBF24),
                ),
                _StatDivider(),
                _SummaryStatItem(
                  icon: Icons.local_fire_department_rounded,
                  value: '${stats['combust']}',
                  label: 'Combust',
                  color: const Color(0xFFF97316),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryStatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
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

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: KundliDisplayColors.borderColor.withOpacity(0.3),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DIGNITY LEGEND
// ═══════════════════════════════════════════════════════════════════════════
class _DignityLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: const [
          _LegendChip(label: 'Exalted', color: Color(0xFF6EE7B7), icon: Icons.arrow_upward_rounded),
          SizedBox(width: 6),
          _LegendChip(label: 'Own Sign', color: Color(0xFF60A5FA), icon: Icons.home_rounded),
          SizedBox(width: 6),
          _LegendChip(label: 'Friendly', color: Color(0xFFA78BFA), icon: Icons.favorite_rounded),
          SizedBox(width: 6),
          _LegendChip(label: 'Neutral', color: Color(0xFF9CA3AF), icon: Icons.remove_rounded),
          SizedBox(width: 6),
          _LegendChip(label: 'Enemy', color: Color(0xFFFBBF24), icon: Icons.warning_rounded),
          SizedBox(width: 6),
          _LegendChip(label: 'Debilitated', color: Color(0xFFF87171), icon: Icons.arrow_downward_rounded),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _LegendChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
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
// PREMIUM PLANET CARD
// ═══════════════════════════════════════════════════════════════════════════
class _PremiumPlanetCard extends StatelessWidget {
  final PlanetPosition planet;
  final Color color;
  final String dignity;
  final String nakshatraLord;
  final int nakshatraPada;
  final bool isCombust;
  final String nature;

  const _PremiumPlanetCard({
    required this.planet,
    required this.color,
    required this.dignity,
    required this.nakshatraLord,
    required this.nakshatraPada,
    required this.isCombust,
    required this.nature,
  });

  @override
  Widget build(BuildContext context) {
    final dignityColor = _getDignityColor(dignity);
    final isRetrograde = planet.isRetrograde &&
        planet.planet != 'Rahu' &&
        planet.planet != 'Ketu';
    final hasStatus = isRetrograde || isCombust;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dignity == 'Exalted'
              ? const Color(0xFF6EE7B7).withOpacity(0.4)
              : dignity == 'Debilitated'
                  ? const Color(0xFFF87171).withOpacity(0.4)
                  : color.withOpacity(0.2),
          width: dignity == 'Exalted' || dignity == 'Debilitated' ? 1 : 0.5,
        ),
        boxShadow: dignity == 'Exalted'
            ? [
                BoxShadow(
                  color: const Color(0xFF6EE7B7).withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Header row
                Row(
                  children: [
                    // Planet symbol with indicators
                    _PlanetSymbolBadge(
                      planet: planet.planet,
                      color: color,
                      isRetrograde: isRetrograde,
                      isCombust: isCombust,
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
                                planet.planet,
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: KundliDisplayColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _NatureBadge(nature: nature),
                              if (hasStatus) ...[
                                const SizedBox(width: 6),
                                if (isRetrograde)
                                  _StatusBadge(
                                    label: 'R',
                                    color: const Color(0xFFFBBF24),
                                  ),
                                if (isCombust) ...[
                                  const SizedBox(width: 4),
                                  _StatusBadge(
                                    label: '🔥',
                                    color: const Color(0xFFF97316),
                                    isEmoji: true,
                                  ),
                                ],
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Position row
                          Row(
                            children: [
                              Text(
                                _getSignSymbol(planet.sign),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: KundliDisplayColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                planet.sign,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: KundliDisplayColors.textSecondary,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: KundliDisplayColors.textMuted.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                '${planet.signDegree.toStringAsFixed(2)}°',
                                style: GoogleFonts.dmMono(
                                  fontSize: 11,
                                  color: KundliDisplayColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // House and dignity
                    _HouseDignityBadge(
                      house: planet.house,
                      dignity: dignity,
                      dignityColor: dignityColor,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Nakshatra row
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: const Color(0xFFFBBF24).withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              planet.nakshatra,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: KundliDisplayColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Pada $nakshatraPada',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    color: KundliDisplayColors.textMuted,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: KundliDisplayColors.textMuted.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  'Lord: ',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    color: KundliDisplayColors.textMuted,
                                  ),
                                ),
                                Text(
                                  nakshatraLord,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: getPlanetColor(nakshatraLord),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${planet.longitude.toStringAsFixed(2)}°',
                            style: GoogleFonts.dmMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: KundliDisplayColors.textMuted,
                            ),
                          ),
                          Text(
                            'longitude',
                            style: GoogleFonts.dmSans(
                              fontSize: 8,
                              color: KundliDisplayColors.textMuted.withOpacity(0.6),
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

          // Footer with combustion warning (if applicable)
          if (isCombust)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316).withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 14,
                    color: Color(0xFFF97316),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Combust: Too close to Sun - reduced strength',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: const Color(0xFFF97316),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getDignityColor(String dignity) {
    switch (dignity) {
      case 'Exalted':
        return const Color(0xFF6EE7B7);
      case 'Moolatrikona':
        return const Color(0xFF22D3EE);
      case 'Own Sign':
        return const Color(0xFF60A5FA);
      case 'Friendly':
        return const Color(0xFFA78BFA);
      case 'Neutral':
        return KundliDisplayColors.textMuted;
      case 'Enemy':
        return const Color(0xFFFBBF24);
      case 'Debilitated':
        return const Color(0xFFF87171);
      default:
        return KundliDisplayColors.textMuted;
    }
  }

  String _getSignSymbol(String sign) {
    const symbols = {
      'Aries': '♈', 'Taurus': '♉', 'Gemini': '♊', 'Cancer': '♋',
      'Leo': '♌', 'Virgo': '♍', 'Libra': '♎', 'Scorpio': '♏',
      'Sagittarius': '♐', 'Capricorn': '♑', 'Aquarius': '♒', 'Pisces': '♓',
    };
    return symbols[sign] ?? '?';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════════════════
class _PlanetSymbolBadge extends StatelessWidget {
  final String planet;
  final Color color;
  final bool isRetrograde;
  final bool isCombust;

  const _PlanetSymbolBadge({
    required this.planet,
    required this.color,
    required this.isRetrograde,
    required this.isCombust,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          getPlanetSymbol(planet),
          style: TextStyle(fontSize: 24, color: color),
        ),
      ),
    );
  }
}

class _NatureBadge extends StatelessWidget {
  final String nature;

  const _NatureBadge({required this.nature});

  @override
  Widget build(BuildContext context) {
    final color = nature == 'Benefic'
        ? const Color(0xFF6EE7B7)
        : nature == 'Malefic'
            ? const Color(0xFFF87171)
            : KundliDisplayColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        nature,
        style: GoogleFonts.dmMono(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isEmoji;

  const _StatusBadge({
    required this.label,
    required this.color,
    this.isEmoji = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: isEmoji
            ? const TextStyle(fontSize: 8)
            : GoogleFonts.dmMono(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: color,
              ),
      ),
    );
  }
}

class _HouseDignityBadge extends StatelessWidget {
  final int house;
  final String dignity;
  final Color dignityColor;

  const _HouseDignityBadge({
    required this.house,
    required this.dignity,
    required this.dignityColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: KundliDisplayColors.accentSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                'H$house',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: KundliDisplayColors.accentSecondary,
                ),
              ),
              Text(
                'House',
                style: GoogleFonts.dmSans(
                  fontSize: 8,
                  color: KundliDisplayColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        if (dignity.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: dignityColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: dignityColor.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Text(
              dignity,
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: dignityColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
