import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../shared/constants.dart';

/// Houses Tab - Shows all 12 houses with their signs, lords, and planets
/// Premium, elegant UI with clear visual hierarchy
class HousesTab extends StatelessWidget {
  final KundaliData kundaliData;

  const HousesTab({super.key, required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    // Calculate summary stats
    final houseStats = _calculateHouseStats();

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
                _HousesSummaryCard(
                  ascendant: kundaliData.ascendant.sign,
                  stats: houseStats,
                ),
                const SizedBox(height: 16),
                _HouseTypeLegend(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // ═══════════════════════════════════════════════════════════════
        // HOUSES LIST
        // ═══════════════════════════════════════════════════════════════
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final house = kundaliData.houses[index];
              final houseLord = _getSignLord(house.sign);
              final lordPlacement = _findPlanetHouse(houseLord);
              final karaka = _getHouseKaraka(house.number);
              final houseType = _getHouseType(house.number);

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
                child: _PremiumHouseCard(
                  house: house,
                  houseLord: houseLord,
                  lordPlacement: lordPlacement,
                  karaka: karaka,
                  houseType: houseType,
                  isFirstHouse: house.number == 1,
                  planetPositions: kundaliData.planetPositions,
                ),
              );
            }, childCount: kundaliData.houses.length),
          ),
        ),
      ],
    );
  }

  Map<String, int> _calculateHouseStats() {
    int occupiedHouses = 0;
    int totalPlanets = 0;

    for (final house in kundaliData.houses) {
      if (house.planets.isNotEmpty) {
        occupiedHouses++;
        totalPlanets += house.planets.length;
      }
    }

    return {
      'occupied': occupiedHouses,
      'empty': 12 - occupiedHouses,
      'planets': totalPlanets,
    };
  }

  String _getSignLord(String sign) {
    const signLords = {
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
    return signLords[sign] ?? 'Unknown';
  }

  int _findPlanetHouse(String planet) {
    for (final house in kundaliData.houses) {
      if (house.planets.contains(planet)) return house.number;
    }
    final planetPos = kundaliData.planetPositions[planet];
    if (planetPos != null) {
      for (final house in kundaliData.houses) {
        if (house.sign == planetPos.sign) return house.number;
      }
    }
    return 0;
  }

  String _getHouseKaraka(int houseNumber) {
    const karakas = {
      1: 'Sun',
      2: 'Jupiter',
      3: 'Mars',
      4: 'Moon',
      5: 'Jupiter',
      6: 'Mars',
      7: 'Venus',
      8: 'Saturn',
      9: 'Jupiter',
      10: 'Mercury',
      11: 'Jupiter',
      12: 'Saturn',
    };
    return karakas[houseNumber] ?? 'Unknown';
  }

  String _getHouseType(int houseNumber) {
    if ([1, 4, 7, 10].contains(houseNumber)) return 'Kendra';
    if ([5, 9].contains(houseNumber)) return 'Trikona';
    if ([6, 8, 12].contains(houseNumber)) return 'Dusthana';
    if ([3, 11].contains(houseNumber)) return 'Upachaya';
    if (houseNumber == 2) return 'Maraka';
    return '';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUMMARY CARD
// ═══════════════════════════════════════════════════════════════════════════
class _HousesSummaryCard extends StatelessWidget {
  final String ascendant;
  final Map<String, int> stats;

  const _HousesSummaryCard({required this.ascendant, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KundliDisplayColors.accentSecondary.withOpacity(0.12),
            KundliDisplayColors.accentPrimary.withOpacity(0.05),
            KundliDisplayColors.surfaceColor.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: KundliDisplayColors.accentSecondary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: KundliDisplayColors.accentSecondary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Ascendant display
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      KundliDisplayColors.accentSecondary.withOpacity(0.2),
                      KundliDisplayColors.accentSecondary.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: KundliDisplayColors.accentSecondary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getSignSymbol(ascendant),
                    style: TextStyle(
                      fontSize: 28,
                      color: KundliDisplayColors.accentSecondary,
                    ),
                  ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: KundliDisplayColors.accentSecondary
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '12 BHAVAS',
                            style: GoogleFonts.dmMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: KundliDisplayColors.accentSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$ascendant Lagna',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: KundliDisplayColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Houses starting from ${ascendant}',
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
                  value: '${stats['occupied']}',
                  label: 'Occupied',
                  color: const Color(0xFF6EE7B7),
                ),
                _StatDivider(),
                _SummaryStatItem(
                  value: '${stats['empty']}',
                  label: 'Empty',
                  color: KundliDisplayColors.textMuted,
                ),
                _StatDivider(),
                _SummaryStatItem(
                  value: '${stats['planets']}',
                  label: 'Planets',
                  color: const Color(0xFFFBBF24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSignSymbol(String sign) {
    const symbols = {
      'Aries': '♈',
      'Taurus': '♉',
      'Gemini': '♊',
      'Cancer': '♋',
      'Leo': '♌',
      'Virgo': '♍',
      'Libra': '♎',
      'Scorpio': '♏',
      'Sagittarius': '♐',
      'Capricorn': '♑',
      'Aquarius': '♒',
      'Pisces': '♓',
    };
    return symbols[sign] ?? '?';
  }
}

class _SummaryStatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SummaryStatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
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

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: KundliDisplayColors.borderColor.withOpacity(0.3),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HOUSE TYPE LEGEND
// ═══════════════════════════════════════════════════════════════════════════
class _HouseTypeLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _LegendChip(
            label: 'Kendra',
            color: const Color(0xFF6EE7B7),
            hint: '1,4,7,10',
          ),
          const SizedBox(width: 8),
          _LegendChip(
            label: 'Trikona',
            color: const Color(0xFFFBBF24),
            hint: '5,9',
          ),
          const SizedBox(width: 8),
          _LegendChip(
            label: 'Dusthana',
            color: const Color(0xFFF87171),
            hint: '6,8,12',
          ),
          const SizedBox(width: 8),
          _LegendChip(
            label: 'Upachaya',
            color: const Color(0xFF60A5FA),
            hint: '3,11',
          ),
          const SizedBox(width: 8),
          _LegendChip(
            label: 'Maraka',
            color: const Color(0xFFA78BFA),
            hint: '2',
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;
  final String hint;

  const _LegendChip({
    required this.label,
    required this.color,
    required this.hint,
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
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            hint,
            style: GoogleFonts.dmMono(
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
// PREMIUM HOUSE CARD
// ═══════════════════════════════════════════════════════════════════════════
class _PremiumHouseCard extends StatelessWidget {
  final House house;
  final String houseLord;
  final int lordPlacement;
  final String karaka;
  final String houseType;
  final bool isFirstHouse;
  final Map<String, PlanetPosition> planetPositions;

  const _PremiumHouseCard({
    required this.house,
    required this.houseLord,
    required this.lordPlacement,
    required this.karaka,
    required this.houseType,
    required this.isFirstHouse,
    required this.planetPositions,
  });

  @override
  Widget build(BuildContext context) {
    final houseColor = _getHouseTypeColor(houseType);
    final hasPlanets = house.planets.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isFirstHouse
                  ? KundliDisplayColors.accentPrimary.withOpacity(0.4)
                  : hasPlanets
                  ? houseColor.withOpacity(0.3)
                  : KundliDisplayColors.borderColor.withOpacity(0.3),
          width: isFirstHouse ? 1.5 : 0.5,
        ),
        boxShadow:
            isFirstHouse
                ? [
                  BoxShadow(
                    color: KundliDisplayColors.accentPrimary.withOpacity(0.08),
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
                    // House number with gradient
                    _HouseNumberBadge(
                      number: house.number,
                      isFirst: isFirstHouse,
                      houseColor: houseColor,
                    ),
                    const SizedBox(width: 14),
                    // House info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _getHouseName(house.number),
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: KundliDisplayColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isFirstHouse)
                                _TypeBadge(
                                  label: 'LAGNA',
                                  color: KundliDisplayColors.accentPrimary,
                                  isPrimary: true,
                                )
                              else if (houseType.isNotEmpty)
                                _TypeBadge(label: houseType, color: houseColor),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                _getSignSymbol(house.sign),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: KundliDisplayColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                house.sign,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: KundliDisplayColors.textSecondary,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: KundliDisplayColors.textMuted
                                      .withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                '${house.cuspDegree.toStringAsFixed(2)}°',
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
                    // Lord placement
                    _LordPlacementBadge(
                      lord: houseLord,
                      placement: lordPlacement,
                    ),
                  ],
                ),

                // Planets section
                if (hasPlanets) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6,
                              color: houseColor.withOpacity(0.6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Planets in this house',
                              style: GoogleFonts.dmSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: KundliDisplayColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children:
                              house.planets.map((planet) {
                                final pos = planetPositions[planet];
                                return _PlanetChip(
                                  planet: planet,
                                  degree: pos?.signDegree,
                                  isRetrograde: pos?.isRetrograde ?? false,
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Footer with significations
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: KundliDisplayColors.surfaceColor.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getHouseSignifications(house.number),
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: KundliDisplayColors.textMuted.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Karaka',
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        color: KundliDisplayColors.textMuted.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getPlanetSymbol(karaka),
                      style: TextStyle(
                        fontSize: 12,
                        color: getPlanetColor(karaka),
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

  Color _getHouseTypeColor(String type) {
    switch (type) {
      case 'Kendra':
        return const Color(0xFF6EE7B7);
      case 'Trikona':
        return const Color(0xFFFBBF24);
      case 'Dusthana':
        return const Color(0xFFF87171);
      case 'Upachaya':
        return const Color(0xFF60A5FA);
      case 'Maraka':
        return const Color(0xFFA78BFA);
      default:
        return KundliDisplayColors.textMuted;
    }
  }

  String _getSignSymbol(String sign) {
    const symbols = {
      'Aries': '♈',
      'Taurus': '♉',
      'Gemini': '♊',
      'Cancer': '♋',
      'Leo': '♌',
      'Virgo': '♍',
      'Libra': '♎',
      'Scorpio': '♏',
      'Sagittarius': '♐',
      'Capricorn': '♑',
      'Aquarius': '♒',
      'Pisces': '♓',
    };
    return symbols[sign] ?? '?';
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
      'Uranus': '♅',
      'Neptune': '♆',
      'Pluto': '♇',
    };
    return symbols[planet] ?? '•';
  }

  String _getHouseName(int n) {
    const names = [
      'Lagna (Self)',
      'Dhana (Wealth)',
      'Sahaja (Siblings)',
      'Sukha (Home)',
      'Putra (Children)',
      'Ari (Enemies)',
      'Yuvati (Spouse)',
      'Mrityu (Transformation)',
      'Dharma (Fortune)',
      'Karma (Career)',
      'Labha (Gains)',
      'Vyaya (Loss)',
    ];
    return names[(n - 1) % 12];
  }

  String _getHouseSignifications(int n) {
    const significations = {
      1: 'Body, appearance, personality, health, vitality',
      2: 'Family, speech, wealth, food, early education',
      3: 'Courage, siblings, communication, short journeys',
      4: 'Mother, property, vehicles, happiness, emotions',
      5: 'Children, creativity, intelligence, romance',
      6: 'Enemies, debts, diseases, service, competition',
      7: 'Marriage, partnerships, business, public relations',
      8: 'Longevity, sudden events, inheritance, occult',
      9: 'Father, fortune, religion, higher learning',
      10: 'Career, status, authority, achievements',
      11: 'Gains, income, friends, aspirations',
      12: 'Expenses, losses, foreign lands, liberation',
    };
    return significations[n] ?? '';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════════════════
class _HouseNumberBadge extends StatelessWidget {
  final int number;
  final bool isFirst;
  final Color houseColor;

  const _HouseNumberBadge({
    required this.number,
    required this.isFirst,
    required this.houseColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isFirst ? KundliDisplayColors.accentPrimary : houseColor;

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.25), color.withOpacity(0.08)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$number',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1,
            ),
          ),
          Text(
            _getOrdinal(number),
            style: GoogleFonts.dmMono(
              fontSize: 8,
              color: KundliDisplayColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _getOrdinal(int n) {
    if (n == 1) return 'st';
    if (n == 2) return 'nd';
    if (n == 3) return 'rd';
    return 'th';
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isPrimary;

  const _TypeBadge({
    required this.label,
    required this.color,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(isPrimary ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(4),
        border:
            isPrimary
                ? Border.all(color: color.withOpacity(0.3), width: 0.5)
                : null,
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.dmMono(
          fontSize: 8,
          fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _LordPlacementBadge extends StatelessWidget {
  final String lord;
  final int placement;

  const _LordPlacementBadge({required this.lord, required this.placement});

  @override
  Widget build(BuildContext context) {
    final lordColor = getPlanetColor(lord);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: lordColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: lordColor.withOpacity(0.15), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getPlanetSymbol(lord),
                style: TextStyle(fontSize: 14, color: lordColor),
              ),
              const SizedBox(width: 4),
              Text(
                lord,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: lordColor,
                ),
              ),
            ],
          ),
          if (placement > 0)
            Text(
              'in H$placement',
              style: GoogleFonts.dmMono(
                fontSize: 9,
                color: KundliDisplayColors.textMuted,
              ),
            ),
        ],
      ),
    );
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

class _PlanetChip extends StatelessWidget {
  final String planet;
  final double? degree;
  final bool isRetrograde;

  const _PlanetChip({
    required this.planet,
    this.degree,
    this.isRetrograde = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = getPlanetColor(planet);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getPlanetSymbol(planet),
            style: TextStyle(fontSize: 14, color: color),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    planet,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  if (isRetrograde) ...[
                    const SizedBox(width: 3),
                    Text(
                      'R',
                      style: GoogleFonts.dmMono(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFBBF24),
                      ),
                    ),
                  ],
                ],
              ),
              if (degree != null)
                Text(
                  '${degree!.toStringAsFixed(2)}°',
                  style: GoogleFonts.dmMono(
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
      'Uranus': '♅',
      'Neptune': '♆',
      'Pluto': '♇',
    };
    return symbols[planet] ?? '•';
  }
}
