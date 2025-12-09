import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../shared/constants.dart';

/// Yogas & Doshas Tab - Shows all yogas and doshas with details
/// Premium, elegant UI with clear visual hierarchy
class YogasTab extends StatelessWidget {
  final KundaliData kundaliData;

  const YogasTab({super.key, required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final analyzedYogas = _analyzeYogas(kundaliData);
    final analyzedDoshas = _analyzeDoshas(kundaliData);

    final strongYogas = analyzedYogas.where((y) => y['strength'] == 'Strong').length;
    final partialYogas = analyzedYogas.length - strongYogas;
    final severeDoshas = analyzedDoshas.where((d) => d['severity'] == 'High').length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════════════════
          // HERO SUMMARY CARD
          // ═══════════════════════════════════════════════════════════════
          _YogaHeroCard(
            yogaCount: analyzedYogas.length,
            doshaCount: analyzedDoshas.length,
            strongYogas: strongYogas,
            partialYogas: partialYogas,
            severeDoshas: severeDoshas,
            ascendant: kundaliData.ascendant.sign,
          ),

          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════════
          // YOGAS SECTION
          // ═══════════════════════════════════════════════════════════════
          if (analyzedYogas.isNotEmpty) ...[
            _SectionLabel(
              title: 'Auspicious Yogas',
              subtitle: '${analyzedYogas.length} beneficial combinations',
              icon: Icons.auto_awesome_rounded,
              color: KundliDisplayColors.yogaGreen,
            ),
            const SizedBox(height: 12),
            _YogaTypeLegend(isYoga: true),
            const SizedBox(height: 12),
            ...analyzedYogas.asMap().entries.map((entry) => _PremiumYogaCard(
                  yogaData: entry.value,
                  index: entry.key,
                  isDosha: false,
                  planetPositions: kundaliData.planetPositions,
                )),
            const SizedBox(height: 24),
          ],

          // ═══════════════════════════════════════════════════════════════
          // DOSHAS SECTION
          // ═══════════════════════════════════════════════════════════════
          if (analyzedDoshas.isNotEmpty) ...[
            _SectionLabel(
              title: 'Doshas Present',
              subtitle: '${analyzedDoshas.length} detected',
              icon: Icons.warning_amber_rounded,
              color: KundliDisplayColors.doshaRed,
            ),
            const SizedBox(height: 12),
            _YogaTypeLegend(isYoga: false),
            const SizedBox(height: 12),
            ...analyzedDoshas.asMap().entries.map((entry) => _PremiumYogaCard(
                  yogaData: entry.value,
                  index: entry.key,
                  isDosha: true,
                  planetPositions: kundaliData.planetPositions,
                )),
            const SizedBox(height: 24),
          ],

          // ═══════════════════════════════════════════════════════════════
          // INSIGHTS SECTION
          // ═══════════════════════════════════════════════════════════════
          _SectionLabel(
            title: 'Astrological Insights',
            subtitle: 'Understanding your chart',
            icon: Icons.lightbulb_outline_rounded,
            color: KundliDisplayColors.accentPrimary,
          ),
          const SizedBox(height: 12),
          _InsightsGrid(
            hasKaalSarp: kundaliData.doshas.contains('Kaal Sarp Dosha'),
            hasManglik: kundaliData.doshas.contains('Manglik Dosha'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _analyzeYogas(KundaliData data) {
    final results = <Map<String, dynamic>>[];
    final positions = data.planetPositions;
    final houses = data.houses;
    final ascSign = data.ascendant.sign;

    for (final yogaName in data.yogas) {
      final analysis = _analyzeSpecificYoga(yogaName, positions, houses, ascSign);
      results.add(analysis);
    }

    return results;
  }

  List<Map<String, dynamic>> _analyzeDoshas(KundaliData data) {
    final results = <Map<String, dynamic>>[];
    final positions = data.planetPositions;
    final houses = data.houses;
    final ascSign = data.ascendant.sign;

    for (final doshaName in data.doshas) {
      final analysis = _analyzeSpecificDosha(doshaName, positions, houses, ascSign);
      results.add(analysis);
    }

    return results;
  }

  Map<String, dynamic> _analyzeSpecificYoga(
    String yogaName,
    Map<String, PlanetPosition> positions,
    List<House> houses,
    String ascSign,
  ) {
    final signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];

    Map<String, dynamic> result = {
      'name': yogaName,
      'planets': <String>[],
      'houses': <int>[],
      'strength': 'Moderate',
      'formationRule': '',
    };

    switch (yogaName) {
      case 'Gajakesari Yoga':
        final jupiter = positions['Jupiter'];
        final moon = positions['Moon'];
        if (jupiter != null && moon != null) {
          final jupHouse = _getHouseFromSign(jupiter.sign, ascSign, signs);
          final moonHouse = _getHouseFromSign(moon.sign, ascSign, signs);
          result['planets'] = ['Jupiter', 'Moon'];
          result['houses'] = [jupHouse, moonHouse];
          result['formationRule'] = 'Jupiter in Kendra from Moon';
          result['strength'] = _isInKendra(jupHouse) ? 'Strong' : 'Moderate';
        }
        break;

      case 'Hamsa Yoga':
        final jupiter = positions['Jupiter'];
        if (jupiter != null) {
          final jupHouse = _getHouseFromSign(jupiter.sign, ascSign, signs);
          result['planets'] = ['Jupiter'];
          result['houses'] = [jupHouse];
          result['formationRule'] = 'Jupiter in H$jupHouse (${jupiter.sign})';
          result['strength'] = (jupiter.sign == 'Sagittarius' ||
                  jupiter.sign == 'Pisces' ||
                  jupiter.sign == 'Cancer')
              ? 'Strong'
              : 'Moderate';
        }
        break;

      case 'Malavya Yoga':
        final venus = positions['Venus'];
        if (venus != null) {
          final venHouse = _getHouseFromSign(venus.sign, ascSign, signs);
          result['planets'] = ['Venus'];
          result['houses'] = [venHouse];
          result['formationRule'] = 'Venus in H$venHouse (${venus.sign})';
          result['strength'] = (venus.sign == 'Taurus' ||
                  venus.sign == 'Libra' ||
                  venus.sign == 'Pisces')
              ? 'Strong'
              : 'Moderate';
        }
        break;

      case 'Bhadra Yoga':
        final mercury = positions['Mercury'];
        if (mercury != null) {
          final merHouse = _getHouseFromSign(mercury.sign, ascSign, signs);
          result['planets'] = ['Mercury'];
          result['houses'] = [merHouse];
          result['formationRule'] = 'Mercury in H$merHouse (${mercury.sign})';
          result['strength'] =
              (mercury.sign == 'Gemini' || mercury.sign == 'Virgo') ? 'Strong' : 'Moderate';
        }
        break;

      case 'Ruchaka Yoga':
        final mars = positions['Mars'];
        if (mars != null) {
          final marsHouse = _getHouseFromSign(mars.sign, ascSign, signs);
          result['planets'] = ['Mars'];
          result['houses'] = [marsHouse];
          result['formationRule'] = 'Mars in H$marsHouse (${mars.sign})';
          result['strength'] = (mars.sign == 'Aries' ||
                  mars.sign == 'Scorpio' ||
                  mars.sign == 'Capricorn')
              ? 'Strong'
              : 'Moderate';
        }
        break;

      case 'Sasa Yoga':
        final saturn = positions['Saturn'];
        if (saturn != null) {
          final satHouse = _getHouseFromSign(saturn.sign, ascSign, signs);
          result['planets'] = ['Saturn'];
          result['houses'] = [satHouse];
          result['formationRule'] = 'Saturn in H$satHouse (${saturn.sign})';
          result['strength'] = (saturn.sign == 'Capricorn' ||
                  saturn.sign == 'Aquarius' ||
                  saturn.sign == 'Libra')
              ? 'Strong'
              : 'Moderate';
        }
        break;

      case 'Budhaditya Yoga':
        final sun = positions['Sun'];
        final mercury = positions['Mercury'];
        if (sun != null && mercury != null && sun.sign == mercury.sign) {
          final sunHouse = _getHouseFromSign(sun.sign, ascSign, signs);
          result['planets'] = ['Sun', 'Mercury'];
          result['houses'] = [sunHouse];
          result['formationRule'] = 'Sun-Mercury conjunction in H$sunHouse';
          final separation = (sun.signDegree - mercury.signDegree).abs();
          result['strength'] = separation > 14 ? 'Strong' : 'Moderate';
        }
        break;

      case 'Chandra-Mangal Yoga':
        final moon = positions['Moon'];
        final mars = positions['Mars'];
        if (moon != null && mars != null && moon.sign == mars.sign) {
          final moonHouse = _getHouseFromSign(moon.sign, ascSign, signs);
          result['planets'] = ['Moon', 'Mars'];
          result['houses'] = [moonHouse];
          result['formationRule'] = 'Moon-Mars conjunction in H$moonHouse';
          result['strength'] = 'Strong';
        }
        break;

      default:
        result['formationRule'] = 'Planetary combination forming $yogaName';
    }

    return result;
  }

  Map<String, dynamic> _analyzeSpecificDosha(
    String doshaName,
    Map<String, PlanetPosition> positions,
    List<House> houses,
    String ascSign,
  ) {
    final signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];

    Map<String, dynamic> result = {
      'name': doshaName,
      'planets': <String>[],
      'houses': <int>[],
      'severity': 'Moderate',
      'formationRule': '',
    };

    switch (doshaName) {
      case 'Manglik Dosha':
        final mars = positions['Mars'];
        if (mars != null) {
          final marsHouse = _getHouseFromSign(mars.sign, ascSign, signs);
          result['planets'] = ['Mars'];
          result['houses'] = [marsHouse];
          result['formationRule'] = 'Mars in H$marsHouse from Lagna';
          if (marsHouse == 7 || marsHouse == 8) {
            result['severity'] = 'High';
          } else if (mars.sign == 'Aries' || mars.sign == 'Scorpio' || mars.sign == 'Capricorn') {
            result['severity'] = 'Low';
          }
        }
        break;

      case 'Kaal Sarp Dosha':
        final rahu = positions['Rahu'];
        final ketu = positions['Ketu'];
        if (rahu != null && ketu != null) {
          final rahuHouse = _getHouseFromSign(rahu.sign, ascSign, signs);
          final ketuHouse = _getHouseFromSign(ketu.sign, ascSign, signs);
          result['planets'] = ['Rahu', 'Ketu'];
          result['houses'] = [rahuHouse, ketuHouse];
          result['formationRule'] = 'All planets between Rahu-Ketu axis';
          result['severity'] = 'High';
        }
        break;

      case 'Pitra Dosha':
        final sun = positions['Sun'];
        if (sun != null) {
          final sunHouse = _getHouseFromSign(sun.sign, ascSign, signs);
          result['planets'] = ['Sun'];
          result['houses'] = [sunHouse];
          result['formationRule'] = 'Sun afflicted in H$sunHouse';
          result['severity'] = 'Moderate';
        }
        break;

      case 'Guru Chandal Yoga':
        final jupiter = positions['Jupiter'];
        final rahu = positions['Rahu'];
        if (jupiter != null && rahu != null && jupiter.sign == rahu.sign) {
          final jupHouse = _getHouseFromSign(jupiter.sign, ascSign, signs);
          result['planets'] = ['Jupiter', 'Rahu'];
          result['houses'] = [jupHouse];
          result['formationRule'] = 'Jupiter-Rahu conjunction in H$jupHouse';
          result['severity'] = 'Moderate';
        }
        break;

      case 'Angarak Dosha':
        final mars = positions['Mars'];
        final rahu = positions['Rahu'];
        if (mars != null && rahu != null && mars.sign == rahu.sign) {
          final marsHouse = _getHouseFromSign(mars.sign, ascSign, signs);
          result['planets'] = ['Mars', 'Rahu'];
          result['houses'] = [marsHouse];
          result['formationRule'] = 'Mars-Rahu conjunction in H$marsHouse';
          result['severity'] = 'High';
        }
        break;

      default:
        result['formationRule'] = 'Planetary affliction causing $doshaName';
    }

    return result;
  }

  int _getHouseFromSign(String planetSign, String ascSign, List<String> signs) {
    final ascIndex = signs.indexOf(ascSign);
    final planetIndex = signs.indexOf(planetSign);
    return ((planetIndex - ascIndex + 12) % 12) + 1;
  }

  bool _isInKendra(int house) {
    return [1, 4, 7, 10].contains(house);
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
// YOGA HERO CARD
// ═══════════════════════════════════════════════════════════════════════════
class _YogaHeroCard extends StatelessWidget {
  final int yogaCount;
  final int doshaCount;
  final int strongYogas;
  final int partialYogas;
  final int severeDoshas;
  final String ascendant;

  const _YogaHeroCard({
    required this.yogaCount,
    required this.doshaCount,
    required this.strongYogas,
    required this.partialYogas,
    required this.severeDoshas,
    required this.ascendant,
  });

  @override
  Widget build(BuildContext context) {
    final balance = yogaCount - severeDoshas;
    final balanceStatus = _getBalanceStatus(balance, yogaCount, doshaCount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KundliDisplayColors.yogaGreen.withOpacity(0.12),
            KundliDisplayColors.accentSecondary.withOpacity(0.06),
            KundliDisplayColors.surfaceColor.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KundliDisplayColors.yogaGreen.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: KundliDisplayColors.yogaGreen.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row with counts
          Row(
            children: [
              // Yoga count
              Expanded(
                child: _HeroCountDisplay(
                  count: yogaCount,
                  label: 'Yogas',
                  icon: Icons.auto_awesome_rounded,
                  color: KundliDisplayColors.yogaGreen,
                ),
              ),
              Container(
                width: 1,
                height: 70,
                color: KundliDisplayColors.borderColor.withOpacity(0.3),
              ),
              // Dosha count
              Expanded(
                child: _HeroCountDisplay(
                  count: doshaCount,
                  label: 'Doshas',
                  icon: Icons.warning_amber_rounded,
                  color: KundliDisplayColors.doshaRed,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Balance & Details row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Balance status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _getBalanceColor(balance).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getBalanceIcon(balance),
                            size: 14,
                            color: _getBalanceColor(balance),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            balanceStatus,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getBalanceColor(balance),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$ascendant Lagna',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: KundliDisplayColors.textMuted,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Strength breakdown
                Row(
                  children: [
                    _StrengthChip(
                      icon: Icons.keyboard_double_arrow_up_rounded,
                      count: strongYogas,
                      label: 'Strong',
                      color: const Color(0xFF4ADE80),
                    ),
                    const SizedBox(width: 8),
                    _StrengthChip(
                      icon: Icons.remove_rounded,
                      count: partialYogas,
                      label: 'Moderate',
                      color: const Color(0xFFFBBF24),
                    ),
                    const SizedBox(width: 8),
                    _StrengthChip(
                      icon: Icons.warning_rounded,
                      count: severeDoshas,
                      label: 'Severe',
                      color: const Color(0xFFF87171),
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

  Color _getBalanceColor(int balance) {
    if (balance >= 3) return const Color(0xFF4ADE80);
    if (balance >= 0) return const Color(0xFF60A5FA);
    if (balance >= -2) return const Color(0xFFFBBF24);
    return const Color(0xFFF87171);
  }

  IconData _getBalanceIcon(int balance) {
    if (balance >= 3) return Icons.sentiment_very_satisfied_rounded;
    if (balance >= 0) return Icons.sentiment_satisfied_rounded;
    if (balance >= -2) return Icons.sentiment_neutral_rounded;
    return Icons.sentiment_dissatisfied_rounded;
  }

  String _getBalanceStatus(int balance, int yogas, int doshas) {
    if (yogas > 0 && doshas == 0) return 'Excellent Chart';
    if (balance >= 3) return 'Very Favorable';
    if (balance >= 1) return 'Favorable Balance';
    if (balance >= -1) return 'Mixed Influences';
    if (balance >= -3) return 'Needs Remedies';
    return 'Challenging';
  }
}

class _HeroCountDisplay extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color color;

  const _HeroCountDisplay({
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.08),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '$count',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: KundliDisplayColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StrengthChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _StrengthChip({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              '$count',
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

// ═══════════════════════════════════════════════════════════════════════════
// YOGA TYPE LEGEND
// ═══════════════════════════════════════════════════════════════════════════
class _YogaTypeLegend extends StatelessWidget {
  final bool isYoga;

  const _YogaTypeLegend({required this.isYoga});

  @override
  Widget build(BuildContext context) {
    final items = isYoga
        ? [
            ('Raja Yoga', const Color(0xFFD4AF37)),
            ('Dhana Yoga', const Color(0xFF4ADE80)),
            ('Pancha Mahapurusha', const Color(0xFFA78BFA)),
            ('Lunar Yoga', const Color(0xFF60A5FA)),
          ]
        : [
            ('High', const Color(0xFFF87171)),
            ('Moderate', const Color(0xFFFBBF24)),
            ('Low', const Color(0xFF60A5FA)),
          ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _LegendChip(label: item.$1, color: item.$2),
                ))
            .toList(),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendChip({required this.label, required this.color});

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
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
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
// PREMIUM YOGA CARD
// ═══════════════════════════════════════════════════════════════════════════
class _PremiumYogaCard extends StatelessWidget {
  final Map<String, dynamic> yogaData;
  final int index;
  final bool isDosha;
  final Map<String, PlanetPosition> planetPositions;

  const _PremiumYogaCard({
    required this.yogaData,
    required this.index,
    required this.isDosha,
    required this.planetPositions,
  });

  @override
  Widget build(BuildContext context) {
    final yogaName = yogaData['name'] as String;
    final planets = yogaData['planets'] as List<String>? ?? [];
    final strength = yogaData['strength'] as String? ?? yogaData['severity'] as String? ?? 'Moderate';
    final formationRule = yogaData['formationRule'] as String? ?? '';
    final yogaInfo = _getYogaInfo(yogaName, isDosha);

    final color = isDosha ? KundliDisplayColors.doshaRed : KundliDisplayColors.yogaGreen;
    final strengthColor = _getStrengthColor(strength);
    final typeColor = _getTypeColor(yogaInfo['type'] ?? '');

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 250 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 8 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _showYogaDetails(context, yogaName, isDosha, yogaData),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: strength == 'Strong' || strength == 'High'
                  ? strengthColor.withOpacity(0.4)
                  : color.withOpacity(0.2),
              width: strength == 'Strong' || strength == 'High' ? 1 : 0.5,
            ),
            boxShadow: strength == 'Strong'
                ? [
                    BoxShadow(
                      color: strengthColor.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // Header row
                    Row(
                      children: [
                        // Icon badge
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                color.withOpacity(0.2),
                                color.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: color.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              isDosha ? Icons.warning_amber_rounded : Icons.auto_awesome_rounded,
                              color: color,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Title and type
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      yogaName,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: KundliDisplayColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: typeColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      yogaInfo['type'] ?? (isDosha ? 'Dosha' : 'Yoga'),
                                      style: GoogleFonts.dmMono(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w600,
                                        color: typeColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Strength badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: strengthColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _getStrengthIcon(strength),
                                size: 16,
                                color: strengthColor,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                strength.split(' ').first,
                                style: GoogleFonts.dmSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: strengthColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Planets row
                    if (planets.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.hub_rounded,
                              size: 12,
                              color: KundliDisplayColors.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: planets.map((planet) {
                                  final pos = planetPositions[planet];
                                  final planetColor = getPlanetColor(planet);

                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: planetColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: planetColor.withOpacity(0.25),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          getPlanetSymbol(planet),
                                          style: TextStyle(fontSize: 12, color: planetColor),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          pos != null ? '${pos.sign.substring(0, 3)}' : planet,
                                          style: GoogleFonts.dmMono(
                                            fontSize: 9,
                                            color: KundliDisplayColors.textPrimary,
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
                      ),
                    ],
                  ],
                ),
              ),

              // Formation rule footer
              if (formationRule.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.04),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.rule_rounded,
                        size: 12,
                        color: KundliDisplayColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          formationRule,
                          style: GoogleFonts.dmMono(
                            fontSize: 9,
                            color: KundliDisplayColors.textSecondary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: KundliDisplayColors.textMuted.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStrengthColor(String strength) {
    switch (strength) {
      case 'Strong':
        return const Color(0xFF4ADE80);
      case 'High':
        return const Color(0xFFF87171);
      case 'Moderate':
        return const Color(0xFFFBBF24);
      case 'Low':
        return const Color(0xFF60A5FA);
      default:
        return const Color(0xFFFBBF24);
    }
  }

  IconData _getStrengthIcon(String strength) {
    switch (strength) {
      case 'Strong':
        return Icons.keyboard_double_arrow_up_rounded;
      case 'High':
        return Icons.priority_high_rounded;
      case 'Moderate':
        return Icons.remove_rounded;
      case 'Low':
        return Icons.keyboard_double_arrow_down_rounded;
      default:
        return Icons.remove_rounded;
    }
  }

  Color _getTypeColor(String type) {
    if (type.contains('Raja')) return const Color(0xFFD4AF37);
    if (type.contains('Dhana')) return const Color(0xFF4ADE80);
    if (type.contains('Pancha') || type.contains('Mahapurusha')) return const Color(0xFFA78BFA);
    if (type.contains('Lunar')) return const Color(0xFF60A5FA);
    if (type.contains('Dosha') || type.contains('Grahan')) return const Color(0xFFF87171);
    return KundliDisplayColors.textMuted;
  }

  void _showYogaDetails(
      BuildContext context, String yogaName, bool isDosha, Map<String, dynamic> yogaData) {
    final color = isDosha ? KundliDisplayColors.doshaRed : KundliDisplayColors.yogaGreen;
    final details = _getFullYogaDetails(yogaName, isDosha);
    final planets = yogaData['planets'] as List<String>? ?? [];
    final formationRule = yogaData['formationRule'] as String? ?? '';
    final strength = yogaData['strength'] as String? ?? yogaData['severity'] as String? ?? 'Moderate';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: KundliDisplayColors.bgSecondary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Column(
            children: [
              // Handle
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
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
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
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          isDosha ? Icons.warning_amber_rounded : Icons.auto_awesome_rounded,
                          color: color,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            yogaName,
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: KundliDisplayColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  details['type']!,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _getStrengthColor(strength).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  strength,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _getStrengthColor(strength),
                                  ),
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

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    // Formation
                    if (planets.isNotEmpty || formationRule.isNotEmpty)
                      _DetailSection(
                        title: 'Formation',
                        icon: Icons.architecture_rounded,
                        color: KundliDisplayColors.accentPrimary,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (planets.isNotEmpty) ...[
                              Text(
                                'Planets Involved',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  color: KundliDisplayColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: planets.map((planet) {
                                  final pos = planetPositions[planet];
                                  final planetColor = getPlanetColor(planet);

                                  return Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: planetColor.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: planetColor.withOpacity(0.2),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          getPlanetSymbol(planet),
                                          style: TextStyle(fontSize: 16, color: planetColor),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              planet,
                                              style: GoogleFonts.dmSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: KundliDisplayColors.textPrimary,
                                              ),
                                            ),
                                            if (pos != null)
                                              Text(
                                                '${pos.sign} ${pos.signDegree.toStringAsFixed(1)}°',
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
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (formationRule.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.rule_rounded,
                                      size: 14,
                                      color: KundliDisplayColors.textMuted,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        formationRule,
                                        style: GoogleFonts.dmMono(
                                          fontSize: 10,
                                          color: KundliDisplayColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Description
                    _DetailSection(
                      title: 'What is $yogaName?',
                      icon: Icons.info_outline_rounded,
                      color: KundliDisplayColors.accentSecondary,
                      child: Text(
                        details['description']!,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: KundliDisplayColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Effects
                    _DetailSection(
                      title: isDosha ? 'Potential Effects' : 'Benefits',
                      icon: isDosha ? Icons.warning_amber_outlined : Icons.star_outline_rounded,
                      color: isDosha ? const Color(0xFFFBBF24) : KundliDisplayColors.yogaGreen,
                      child: Text(
                        details['effects']!,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: KundliDisplayColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Remedies
                    _DetailSection(
                      title: isDosha ? 'Remedies' : 'How to Strengthen',
                      icon: Icons.healing_rounded,
                      color: const Color(0xFF60A5FA),
                      child: Text(
                        details['remedies']!,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: KundliDisplayColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _DetailSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.15),
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
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INSIGHTS GRID
// ═══════════════════════════════════════════════════════════════════════════
class _InsightsGrid extends StatelessWidget {
  final bool hasKaalSarp;
  final bool hasManglik;

  const _InsightsGrid({
    this.hasKaalSarp = false,
    this.hasManglik = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InsightCard(
                title: 'Understanding',
                description: 'Yogas are beneficial combinations that enhance life areas.',
                icon: Icons.lightbulb_outline_rounded,
                color: KundliDisplayColors.accentPrimary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InsightCard(
                title: 'Activation',
                description: 'Yogas manifest during their planetary Dasha periods.',
                icon: Icons.schedule_rounded,
                color: KundliDisplayColors.yogaGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _InsightCard(
                title: 'Strength',
                description: 'Planet placement determines yoga manifestation level.',
                icon: Icons.fitness_center_rounded,
                color: const Color(0xFFFBBF24),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InsightCard(
                title: 'Remedies',
                description: 'Most doshas can be mitigated through proper remedies.',
                icon: Icons.healing_outlined,
                color: const Color(0xFF60A5FA),
              ),
            ),
          ],
        ),
        if (hasKaalSarp || hasManglik) ...[
          const SizedBox(height: 16),
          if (hasKaalSarp)
            _SpecificRemedyCard(
              title: 'Kaal Sarp Remedy',
              description: 'Trimbakeshwar Puja recommended. Chant Maha Mrityunjaya Mantra 108 times daily.',
              icon: Icons.auto_fix_high_rounded,
              color: const Color(0xFFF87171),
            ),
          if (hasManglik) ...[
            const SizedBox(height: 10),
            _SpecificRemedyCard(
              title: 'Manglik Remedy',
              description: 'Perform Mangal Shanti Puja. Recite Hanuman Chalisa on Tuesdays.',
              icon: Icons.auto_fix_high_rounded,
              color: const Color(0xFFF87171),
            ),
          ],
        ],
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _InsightCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: KundliDisplayColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              color: KundliDisplayColors.textMuted,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecificRemedyCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _SpecificRemedyCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: KundliDisplayColors.textSecondary,
                    height: 1.3,
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
// DATA HELPERS
// ═══════════════════════════════════════════════════════════════════════════
Map<String, String> _getYogaInfo(String yogaName, bool isDosha) {
  final yogaInfoMap = {
    'Hamsa Yoga': {'type': 'Pancha Mahapurusha'},
    'Malavya Yoga': {'type': 'Pancha Mahapurusha'},
    'Bhadra Yoga': {'type': 'Pancha Mahapurusha'},
    'Ruchaka Yoga': {'type': 'Pancha Mahapurusha'},
    'Sasa Yoga': {'type': 'Pancha Mahapurusha'},
    'Gajakesari Yoga': {'type': 'Raja Yoga'},
    'Budhaditya Yoga': {'type': 'Raja Yoga'},
    'Chandra-Mangal Yoga': {'type': 'Dhana Yoga'},
    'Lakshmi Yoga': {'type': 'Dhana Yoga'},
    'Dhana Yoga': {'type': 'Dhana Yoga'},
    'Sunafa Yoga': {'type': 'Lunar Yoga'},
    'Anafa Yoga': {'type': 'Lunar Yoga'},
    'Manglik Dosha': {'type': 'Major Dosha'},
    'Kaal Sarp Dosha': {'type': 'Major Dosha'},
    'Pitra Dosha': {'type': 'Ancestral'},
    'Guru Chandal Yoga': {'type': 'Conjunction Dosha'},
    'Angarak Dosha': {'type': 'Major Dosha'},
  };

  return yogaInfoMap[yogaName] ?? {'type': isDosha ? 'Dosha' : 'Benefic Yoga'};
}

Map<String, String> _getFullYogaDetails(String yogaName, bool isDosha) {
  final detailsMap = {
    'Hamsa Yoga': {
      'type': 'Pancha Mahapurusha Yoga',
      'description':
          'Hamsa Yoga forms when Jupiter is in Kendra in own/exalted sign. One of the five great person yogas.',
      'effects':
          'Blessed with wisdom, spiritual inclination, respect from learned people, and virtuous life.',
      'remedies':
          'Worship Lord Vishnu, study scriptures, donate yellow items on Thursdays.',
    },
    'Gajakesari Yoga': {
      'type': 'Raja Yoga',
      'description':
          'One of the most auspicious yogas, formed when Jupiter is in a Kendra from the Moon.',
      'effects': 'Grants wisdom, intelligence, excellent reputation, wealth, and leadership.',
      'remedies':
          'Worship Lord Ganesha and Jupiter, chant Guru mantras on Thursdays.',
    },
    'Manglik Dosha': {
      'type': 'Major Dosha',
      'description':
          'Formed when Mars is in 1st, 4th, 7th, 8th, or 12th house from Ascendant.',
      'effects': 'May cause delays in marriage or challenges in married life.',
      'remedies':
          'Perform Mangal Shanti Puja, chant Hanuman Chalisa, fast on Tuesdays.',
    },
    'Kaal Sarp Dosha': {
      'type': 'Major Dosha',
      'description': 'All planets hemmed between Rahu and Ketu axis.',
      'effects': 'May bring sudden ups and downs, struggles, delays in success.',
      'remedies':
          'Visit Trimbakeshwar for Kaal Sarp Puja, chant Maha Mrityunjaya Mantra.',
    },
  };

  return detailsMap[yogaName] ??
      {
        'type': isDosha ? 'Dosha' : 'Benefic Yoga',
        'description': isDosha
            ? 'This dosha indicates certain karmic patterns creating challenges.'
            : 'This yoga indicates beneficial combinations enhancing life areas.',
        'effects': isDosha
            ? 'Effects vary based on planet strength and placement.'
            : 'Benefits manifest according to overall chart strength.',
        'remedies': isDosha
            ? 'Consult an astrologer for personalized remedies.'
            : 'Strengthen involved planets through mantras and gemstones.',
      };
}
