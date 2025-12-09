import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../shared/constants.dart';

/// Transit Tab - Shows current planetary transits (Gochar)
/// Premium, elegant UI with clear visual hierarchy
class TransitTab extends StatelessWidget {
  final KundaliData kundaliData;

  const TransitTab({super.key, required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Get real-time planetary positions using Swiss Ephemeris
    final currentPositions = _getCurrentTransitPositions();

    // Calculate transit effects from Moon sign (Vedic Gochar)
    final transits = KundaliCalculationService.calculateTransits(
      kundaliData.planetPositions,
      currentPositions,
      kundaliData.moonSign,
    );

    // Calculate Sade Sati status
    final sadeSatiInfo = _calculateSadeSati(currentPositions, kundaliData.moonSign);

    // Calculate transit house from Moon
    final transitHouses = _calculateTransitHousesFromMoon(currentPositions, kundaliData.moonSign);

    // Count favorable vs unfavorable transits
    final favorableCount = transits.values.where((t) => t.isFavorable).length;
    final challengingCount = transits.values.length - favorableCount;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════════════════
          // HERO TRANSIT CARD
          // ═══════════════════════════════════════════════════════════════
          _TransitHeroCard(
            now: now,
            moonSign: kundaliData.moonSign,
            favorableCount: favorableCount,
            challengingCount: challengingCount,
            sadeSatiInfo: sadeSatiInfo,
          ),

          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════════
          // CURRENT SKY POSITIONS
          // ═══════════════════════════════════════════════════════════════
          _SectionLabel(
            title: 'Current Sky Positions',
            subtitle: 'Real-time planetary positions',
            icon: Icons.public_rounded,
            color: const Color(0xFF22D3EE),
            trailing: _LiveIndicator(),
          ),
          const SizedBox(height: 12),
          _CurrentPositionsCard(
            positions: currentPositions,
            natalPositions: kundaliData.planetPositions,
          ),

          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════════
          // GOCHAR GRID
          // ═══════════════════════════════════════════════════════════════
          _SectionLabel(
            title: 'Gochar (गोचर)',
            subtitle: 'Transit from ${kundaliData.moonSign} (Janma Rashi)',
            icon: Icons.home_rounded,
            color: const Color(0xFFA78BFA),
          ),
          const SizedBox(height: 12),
          _GocharLegend(),
          const SizedBox(height: 12),
          _GocharGrid(transitHouses: transitHouses, moonSign: kundaliData.moonSign),

          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════════
          // TRANSIT EFFECTS
          // ═══════════════════════════════════════════════════════════════
          _SectionLabel(
            title: 'Transit Effects',
            subtitle: 'Impact analysis on your chart',
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF6EE7B7),
          ),
          const SizedBox(height: 12),
          ...transits.entries.map((entry) => _PremiumTransitCard(
                transit: entry.value,
                natalPosition: kundaliData.planetPositions[entry.key],
              )),

          // ═══════════════════════════════════════════════════════════════
          // SADE SATI (if active)
          // ═══════════════════════════════════════════════════════════════
          if (sadeSatiInfo['isActive'] == true) ...[
            const SizedBox(height: 24),
            _SectionLabel(
              title: 'Sade Sati (साढ़े साती)',
              subtitle: 'Saturn\'s 7.5 year transit cycle',
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFF87171),
            ),
            const SizedBox(height: 12),
            _SadeSatiCard(sadeSatiInfo: sadeSatiInfo),
          ],
        ],
      ),
    );
  }

  Map<String, PlanetPosition> _getCurrentTransitPositions() {
    try {
      final now = DateTime.now();
      final result = KundaliCalculationService.calculateAll(
        birthDateTime: now,
        latitude: kundaliData.latitude,
        longitude: kundaliData.longitude,
        timezone: kundaliData.timezone,
      );
      return result.planetPositions;
    } catch (e) {
      debugPrint('Transit calculation error: $e');
      return kundaliData.planetPositions;
    }
  }

  Map<String, dynamic> _calculateSadeSati(
      Map<String, PlanetPosition> currentPositions, String moonSign) {
    final saturnPos = currentPositions['Saturn'];
    if (saturnPos == null) {
      return {'isActive': false};
    }

    final signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    final moonIndex = signs.indexOf(moonSign);
    final saturnIndex = signs.indexOf(saturnPos.sign);

    if (moonIndex == -1 || saturnIndex == -1) {
      return {'isActive': false};
    }

    int relativePos = (saturnIndex - moonIndex + 12) % 12;

    String phase = '';
    bool isActive = false;
    String description = '';
    int phaseNumber = 0;

    if (relativePos == 11) {
      isActive = true;
      phase = 'Rising (1st Phase)';
      phaseNumber = 1;
      description =
          'Saturn transiting 12th from Moon. Beginning of 7.5 year cycle. Increased expenses, travel, and mental stress possible.';
    } else if (relativePos == 0) {
      isActive = true;
      phase = 'Peak (2nd Phase)';
      phaseNumber = 2;
      description =
          'Saturn transiting over Moon sign. Most intense period. Health, emotions, and relationships may face challenges.';
    } else if (relativePos == 1) {
      isActive = true;
      phase = 'Setting (3rd Phase)';
      phaseNumber = 3;
      description =
          'Saturn transiting 2nd from Moon. Final phase. Financial matters, family, and speech may be affected.';
    }

    return {
      'isActive': isActive,
      'phase': phase,
      'phaseNumber': phaseNumber,
      'description': description,
      'saturnSign': saturnPos.sign,
      'saturnDegree': saturnPos.signDegree,
      'moonSign': moonSign,
    };
  }

  Map<String, int> _calculateTransitHousesFromMoon(
      Map<String, PlanetPosition> positions, String moonSign) {
    final signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    final moonIndex = signs.indexOf(moonSign);

    final transitHouses = <String, int>{};

    for (final entry in positions.entries) {
      final planetSign = entry.value.sign;
      final planetIndex = signs.indexOf(planetSign);
      if (planetIndex != -1 && moonIndex != -1) {
        final house = ((planetIndex - moonIndex + 12) % 12) + 1;
        transitHouses[entry.key] = house;
      }
    }

    return transitHouses;
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
  final Widget? trailing;

  const _SectionLabel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.trailing,
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
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _LiveIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF6EE7B7).withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF6EE7B7).withOpacity(0.3),
          width: 0.5,
        ),
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
            'LIVE',
            style: GoogleFonts.dmMono(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6EE7B7),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TRANSIT HERO CARD
// ═══════════════════════════════════════════════════════════════════════════
class _TransitHeroCard extends StatelessWidget {
  final DateTime now;
  final String moonSign;
  final int favorableCount;
  final int challengingCount;
  final Map<String, dynamic> sadeSatiInfo;

  const _TransitHeroCard({
    required this.now,
    required this.moonSign,
    required this.favorableCount,
    required this.challengingCount,
    required this.sadeSatiInfo,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(now);
    final timeStr = DateFormat('HH:mm').format(now);
    final overallBalance = favorableCount - challengingCount;
    final balanceStatus = _getBalanceStatus(overallBalance);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getBalanceColor(overallBalance).withOpacity(0.15),
            const Color(0xFF22D3EE).withOpacity(0.06),
            KundliDisplayColors.surfaceColor.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getBalanceColor(overallBalance).withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getBalanceColor(overallBalance).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance gauge
              _BalanceGauge(
                balance: overallBalance,
                favorable: favorableCount,
                challenging: challengingCount,
              ),
              const SizedBox(width: 20),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getBalanceColor(overallBalance).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            balanceStatus.toUpperCase(),
                            style: GoogleFonts.dmMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _getBalanceColor(overallBalance),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Transit Overview',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: KundliDisplayColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Favorable/Challenging chips
                    Row(
                      children: [
                        _StatBadge(
                          icon: Icons.thumb_up_rounded,
                          value: favorableCount,
                          label: 'Favorable',
                          color: const Color(0xFF4ADE80),
                        ),
                        const SizedBox(width: 10),
                        _StatBadge(
                          icon: Icons.thumb_down_rounded,
                          value: challengingCount,
                          label: 'Challenging',
                          color: const Color(0xFFF87171),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Date/Time & Moon Sign row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  value: dateStr,
                  color: KundliDisplayColors.textMuted,
                ),
                _VerticalDivider(),
                _InfoChip(
                  icon: Icons.access_time_rounded,
                  value: timeStr,
                  color: KundliDisplayColors.textMuted,
                ),
                _VerticalDivider(),
                Expanded(
                  child: _InfoChip(
                    icon: Icons.nightlight_round,
                    value: moonSign,
                    label: 'Janma Rashi',
                    color: const Color(0xFF6EE7B7),
                    isHighlighted: true,
                  ),
                ),
              ],
            ),
          ),

          // Sade Sati warning
          if (sadeSatiInfo['isActive'] == true) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF87171).withOpacity(0.12),
                    const Color(0xFFF87171).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF87171).withOpacity(0.25),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF87171).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: Color(0xFFF87171),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sade Sati Active',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFF87171),
                          ),
                        ),
                        Text(
                          '${sadeSatiInfo['phase']}',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: KundliDisplayColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SadeSatiPhaseIndicator(phase: sadeSatiInfo['phaseNumber'] ?? 0),
                ],
              ),
            ),
          ],
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

  String _getBalanceStatus(int balance) {
    if (balance >= 3) return 'Very Favorable';
    if (balance >= 1) return 'Favorable';
    if (balance >= -1) return 'Mixed';
    if (balance >= -3) return 'Challenging';
    return 'Difficult';
  }
}

class _BalanceGauge extends StatelessWidget {
  final int balance;
  final int favorable;
  final int challenging;

  const _BalanceGauge({
    required this.balance,
    required this.favorable,
    required this.challenging,
  });

  @override
  Widget build(BuildContext context) {
    final color = balance >= 0
        ? const Color(0xFF4ADE80)
        : const Color(0xFFF87171);

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
          color: color.withOpacity(0.4),
          width: 3,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            balance >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 24,
            color: color,
          ),
          Text(
            balance >= 0 ? '+$balance' : '$balance',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  const _StatBadge({
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
          const SizedBox(width: 6),
          Text(
            '$value',
            style: GoogleFonts.dmSans(
              fontSize: 14,
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
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String? label;
  final Color color;
  final bool isHighlighted;

  const _InfoChip({
    required this.icon,
    required this.value,
    this.label,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null)
              Text(
                label!,
                style: GoogleFonts.dmSans(
                  fontSize: 8,
                  color: KundliDisplayColors.textMuted.withOpacity(0.7),
                ),
              ),
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: isHighlighted ? 12 : 11,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                color: isHighlighted ? color : KundliDisplayColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: KundliDisplayColors.borderColor.withOpacity(0.3),
    );
  }
}

class _SadeSatiPhaseIndicator extends StatelessWidget {
  final int phase;

  const _SadeSatiPhaseIndicator({required this.phase});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final isActive = i < phase;
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFF87171)
                : const Color(0xFFF87171).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CURRENT POSITIONS CARD
// ═══════════════════════════════════════════════════════════════════════════
class _CurrentPositionsCard extends StatelessWidget {
  final Map<String, PlanetPosition> positions;
  final Map<String, PlanetPosition> natalPositions;

  const _CurrentPositionsCard({
    required this.positions,
    required this.natalPositions,
  });

  @override
  Widget build(BuildContext context) {
    final vedicPlanets = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'];

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
        children: [
          // Header
          Row(
            children: [
              Text(
                'Planet',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: KundliDisplayColors.textMuted,
                ),
              ),
              const Spacer(),
              Text(
                'Current',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: KundliDisplayColors.textMuted,
                ),
              ),
              const SizedBox(width: 40),
              Text(
                'Natal',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: KundliDisplayColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: KundliDisplayColors.borderColor.withOpacity(0.2), height: 1),
          const SizedBox(height: 8),
          // Planets
          ...vedicPlanets.map((planet) {
            final pos = positions[planet];
            final natalPos = natalPositions[planet];
            if (pos == null) return const SizedBox();

            final signChanged = natalPos != null && natalPos.sign != pos.sign;
            final planetColor = getPlanetColor(planet);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: planetColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Center(
                      child: Text(
                        getPlanetSymbol(planet),
                        style: TextStyle(fontSize: 13, color: planetColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 50,
                    child: Text(
                      planet,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: KundliDisplayColors.textPrimary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Current position
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: signChanged
                          ? const Color(0xFFFBBF24).withOpacity(0.1)
                          : KundliDisplayColors.surfaceColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6),
                      border: signChanged
                          ? Border.all(color: const Color(0xFFFBBF24).withOpacity(0.3), width: 0.5)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${pos.sign.substring(0, 3)} ${pos.signDegree.toStringAsFixed(1)}°',
                          style: GoogleFonts.dmMono(
                            fontSize: 10,
                            color: KundliDisplayColors.textPrimary,
                          ),
                        ),
                        if (pos.isRetrograde) ...[
                          const SizedBox(width: 4),
                          Text(
                            '℞',
                            style: GoogleFonts.dmMono(
                              fontSize: 10,
                              color: const Color(0xFFF87171),
                            ),
                          ),
                        ],
                        if (signChanged) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.swap_horiz_rounded,
                            size: 12,
                            color: const Color(0xFFFBBF24),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Natal position
                  SizedBox(
                    width: 70,
                    child: natalPos != null
                        ? Text(
                            '${natalPos.sign.substring(0, 3)} ${natalPos.signDegree.toStringAsFixed(1)}°',
                            style: GoogleFonts.dmMono(
                              fontSize: 10,
                              color: KundliDisplayColors.textMuted,
                            ),
                            textAlign: TextAlign.right,
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GOCHAR LEGEND
// ═══════════════════════════════════════════════════════════════════════════
class _GocharLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: KundliDisplayColors.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Favorable: 3, 6, 10, 11 from Moon • Other houses vary by planet',
              style: GoogleFonts.dmSans(
                fontSize: 9,
                color: KundliDisplayColors.textMuted,
              ),
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF4ADE80).withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '= Good',
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
// GOCHAR GRID
// ═══════════════════════════════════════════════════════════════════════════
class _GocharGrid extends StatelessWidget {
  final Map<String, int> transitHouses;
  final String moonSign;

  const _GocharGrid({required this.transitHouses, required this.moonSign});

  @override
  Widget build(BuildContext context) {
    final houseGroups = <int, List<String>>{};
    for (int i = 1; i <= 12; i++) {
      houseGroups[i] = [];
    }
    transitHouses.forEach((planet, house) {
      houseGroups[house]?.add(planet);
    });

    return Container(
      padding: const EdgeInsets.all(12),
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
          // Row 1: Houses 1-6
          Row(
            children: List.generate(
                6,
                (i) => Expanded(
                      child: _GocharCell(
                        house: i + 1,
                        planets: houseGroups[i + 1] ?? [],
                        isFavorable: _isFavorableHouse(i + 1),
                        isFirst: i == 0,
                      ),
                    )),
          ),
          const SizedBox(height: 6),
          // Row 2: Houses 7-12
          Row(
            children: List.generate(
                6,
                (i) => Expanded(
                      child: _GocharCell(
                        house: i + 7,
                        planets: houseGroups[i + 7] ?? [],
                        isFavorable: _isFavorableHouse(i + 7),
                        isFirst: false,
                      ),
                    )),
          ),
        ],
      ),
    );
  }

  bool _isFavorableHouse(int house) {
    return [3, 6, 10, 11].contains(house);
  }
}

class _GocharCell extends StatelessWidget {
  final int house;
  final List<String> planets;
  final bool isFavorable;
  final bool isFirst;

  const _GocharCell({
    required this.house,
    required this.planets,
    required this.isFavorable,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isFirst
        ? KundliDisplayColors.accentPrimary.withOpacity(0.1)
        : isFavorable
            ? const Color(0xFF4ADE80).withOpacity(0.08)
            : KundliDisplayColors.borderColor.withOpacity(0.08);

    final borderColor = isFirst
        ? KundliDisplayColors.accentPrimary.withOpacity(0.3)
        : isFavorable
            ? const Color(0xFF4ADE80).withOpacity(0.2)
            : KundliDisplayColors.borderColor.withOpacity(0.15);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'H$house',
                style: GoogleFonts.dmMono(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isFirst
                      ? KundliDisplayColors.accentPrimary
                      : isFavorable
                          ? const Color(0xFF4ADE80)
                          : KundliDisplayColors.textMuted,
                ),
              ),
              if (isFirst) ...[
                const SizedBox(width: 2),
                Text('☽', style: TextStyle(fontSize: 8, color: KundliDisplayColors.accentPrimary)),
              ] else if (isFavorable) ...[
                const SizedBox(width: 2),
                Icon(Icons.star_rounded, size: 8, color: const Color(0xFF4ADE80)),
              ],
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 24,
            child: planets.isEmpty
                ? Text(
                    '—',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: KundliDisplayColors.textMuted.withOpacity(0.3),
                    ),
                  )
                : Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    alignment: WrapAlignment.center,
                    children: planets
                        .map((p) => Text(
                              getPlanetSymbol(p),
                              style: TextStyle(fontSize: 11, color: getPlanetColor(p)),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PREMIUM TRANSIT CARD
// ═══════════════════════════════════════════════════════════════════════════
class _PremiumTransitCard extends StatelessWidget {
  final TransitData transit;
  final PlanetPosition? natalPosition;

  const _PremiumTransitCard({
    required this.transit,
    this.natalPosition,
  });

  @override
  Widget build(BuildContext context) {
    final color = transit.isFavorable ? const Color(0xFF4ADE80) : const Color(0xFFF87171);
    final planetColor = getPlanetColor(transit.planet);
    final speedInfo = _getPlanetSpeedInfo(transit.planet);
    final isSlowPlanet = speedInfo['isSlow'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: transit.isFavorable
              ? color.withOpacity(0.3)
              : KundliDisplayColors.borderColor.withOpacity(0.3),
          width: transit.isFavorable ? 1 : 0.5,
        ),
        boxShadow: transit.isFavorable
            ? [
                BoxShadow(
                  color: color.withOpacity(0.06),
                  blurRadius: 10,
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
                    // Planet symbol
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
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
                              getPlanetSymbol(transit.planet),
                              style: TextStyle(fontSize: 20, color: planetColor),
                            ),
                          ),
                        ),
                        // Slow planet badge
                        if (isSlowPlanet)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF60A5FA),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.hourglass_bottom,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Planet info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                transit.planet,
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: KundliDisplayColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isSlowPlanet)
                                Text(
                                  '(Major)',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 9,
                                    color: const Color(0xFF60A5FA),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _TransitInfoChip(
                                icon: _getSignSymbol(transit.currentSign),
                                text: '${transit.currentSign.substring(0, 3)} ${transit.currentDegree.toStringAsFixed(1)}°',
                              ),
                              const SizedBox(width: 6),
                              _TransitInfoChip(
                                icon: '☽',
                                text: 'H${transit.transitHouse}',
                                color: transit.isFavorable ? color : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            transit.isFavorable ? Icons.thumb_up_rounded : Icons.thumb_down_rounded,
                            size: 16,
                            color: color,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            transit.isFavorable ? 'Good' : 'Alert',
                            style: GoogleFonts.dmSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Aspect info
                if (transit.aspectToNatal != 'None') ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.link_rounded,
                          size: 12,
                          color: KundliDisplayColors.accentPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Aspect: ${transit.aspectToNatal}',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: KundliDisplayColors.textSecondary,
                          ),
                        ),
                        if (natalPosition != null) ...[
                          const Spacer(),
                          Text(
                            'to Natal ${transit.planet}',
                            style: GoogleFonts.dmSans(
                              fontSize: 9,
                              color: KundliDisplayColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Effects footer
          if (transit.effects.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 14,
                    color: color.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      transit.effects,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: KundliDisplayColors.textSecondary,
                        height: 1.4,
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

  String _getSignSymbol(String sign) {
    const symbols = {
      'Aries': '♈', 'Taurus': '♉', 'Gemini': '♊', 'Cancer': '♋',
      'Leo': '♌', 'Virgo': '♍', 'Libra': '♎', 'Scorpio': '♏',
      'Sagittarius': '♐', 'Capricorn': '♑', 'Aquarius': '♒', 'Pisces': '♓',
    };
    return symbols[sign] ?? '?';
  }

  Map<String, dynamic> _getPlanetSpeedInfo(String planet) {
    const slowPlanets = ['Saturn', 'Jupiter', 'Rahu', 'Ketu'];

    if (slowPlanets.contains(planet)) {
      return {
        'isSlow': true,
        'duration': planet == 'Saturn'
            ? '~2.5 years/sign'
            : planet == 'Jupiter'
                ? '~1 year/sign'
                : '~1.5 years/sign',
      };
    }

    return {'isSlow': false};
  }
}

class _TransitInfoChip extends StatelessWidget {
  final String icon;
  final String text;
  final Color? color;

  const _TransitInfoChip({
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? KundliDisplayColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: 10, color: chipColor)),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.dmMono(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SADE SATI CARD
// ═══════════════════════════════════════════════════════════════════════════
class _SadeSatiCard extends StatelessWidget {
  final Map<String, dynamic> sadeSatiInfo;

  const _SadeSatiCard({required this.sadeSatiInfo});

  @override
  Widget build(BuildContext context) {
    final phase = sadeSatiInfo['phaseNumber'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF87171).withOpacity(0.12),
            const Color(0xFFFBBF24).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF87171).withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFF87171).withOpacity(0.2),
                      const Color(0xFFF87171).withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFF87171).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    getPlanetSymbol('Saturn'),
                    style: const TextStyle(fontSize: 24, color: Color(0xFFF87171)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saturn\'s 7.5 Year Cycle',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: KundliDisplayColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sadeSatiInfo['phase'] ?? '',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFF87171),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF87171).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      'Saturn',
                      style: GoogleFonts.dmSans(
                        fontSize: 8,
                        color: KundliDisplayColors.textMuted,
                      ),
                    ),
                    Text(
                      '${sadeSatiInfo['saturnSign']}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: KundliDisplayColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Phase indicator
          _PhaseProgressBar(currentPhase: phase),

          const SizedBox(height: 16),

          // Description
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: KundliDisplayColors.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    sadeSatiInfo['description'] ?? '',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: KundliDisplayColors.textSecondary,
                      height: 1.4,
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

class _PhaseProgressBar extends StatelessWidget {
  final int currentPhase;

  const _PhaseProgressBar({required this.currentPhase});

  @override
  Widget build(BuildContext context) {
    final phases = [
      ('Rising', '12th from ☽'),
      ('Peak', 'Over ☽'),
      ('Setting', '2nd from ☽'),
    ];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i + 1 == currentPhase;
          final isPast = i + 1 < currentPhase;

          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isPast || isActive
                          ? const Color(0xFFF87171)
                          : KundliDisplayColors.borderColor.withOpacity(0.3),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFF87171).withOpacity(0.15)
                        : isPast
                            ? const Color(0xFFF87171).withOpacity(0.08)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: isActive
                        ? Border.all(
                            color: const Color(0xFFF87171).withOpacity(0.3),
                            width: 0.5,
                          )
                        : null,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isActive || isPast
                              ? const Color(0xFFF87171)
                              : KundliDisplayColors.borderColor.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: GoogleFonts.dmMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isActive || isPast
                                  ? Colors.white
                                  : KundliDisplayColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phases[i].$1,
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive
                              ? const Color(0xFFF87171)
                              : KundliDisplayColors.textMuted,
                        ),
                      ),
                      Text(
                        phases[i].$2,
                        style: GoogleFonts.dmMono(
                          fontSize: 7,
                          color: KundliDisplayColors.textMuted.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isPast
                          ? const Color(0xFFF87171)
                          : KundliDisplayColors.borderColor.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
