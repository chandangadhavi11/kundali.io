import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../shared/constants.dart';

/// Transit Tab - Shows current planetary transits (Gochar)
class TransitTab extends StatelessWidget {
  final KundaliData kundaliData;

  const TransitTab({super.key, required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final currentPositions = _getCurrentTransitPositions();
    final transits = KundaliCalculationService.calculateTransits(
      kundaliData.planetPositions,
      currentPositions,
      kundaliData.moonSign,
    );

    final now = DateTime.now();
    final dateStr =
        '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Current Transits (Gochar)',
            subtitle: 'Planetary movements from Moon',
            icon: Icons.sync_rounded,
            color: const Color(0xFF22D3EE),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 12, color: KundliDisplayColors.textMuted),
              const SizedBox(width: 4),
              Text(
                'As of $dateStr',
                style: GoogleFonts.dmSans(fontSize: 10, color: KundliDisplayColors.textMuted),
              ),
              const Spacer(),
              Text(
                'Moon sign: ${kundaliData.moonSign}',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: KundliDisplayColors.accentSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _CurrentPositionsSummary(positions: currentPositions),
          const SizedBox(height: 16),

          _SectionHeader(
            title: 'Transit Effects',
            subtitle: 'Impact on your chart',
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF6EE7B7),
          ),
          const SizedBox(height: 12),
          ...transits.entries.map((entry) => _TransitCard(transit: entry.value)),
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

// ============ Current Positions Summary ============
class _CurrentPositionsSummary extends StatelessWidget {
  final Map<String, PlanetPosition> positions;

  const _CurrentPositionsSummary({required this.positions});

  @override
  Widget build(BuildContext context) {
    final vedicPlanets = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF22D3EE).withOpacity(0.08),
            const Color(0xFF6EE7B7).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF22D3EE).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.public_rounded, size: 14, color: Color(0xFF22D3EE)),
              const SizedBox(width: 6),
              Text(
                'Current Sky Positions',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: KundliDisplayColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6EE7B7).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'LIVE',
                  style: GoogleFonts.dmMono(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6EE7B7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vedicPlanets.map((planet) {
              final pos = positions[planet];
              if (pos == null) return const SizedBox();

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: KundliDisplayColors.surfaceColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: getPlanetColor(planet).withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      getPlanetSymbol(planet),
                      style: TextStyle(fontSize: 12, color: getPlanetColor(planet)),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pos.sign,
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: KundliDisplayColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${pos.signDegree.toStringAsFixed(1)}°${pos.isRetrograde ? ' ℞' : ''}',
                          style: GoogleFonts.dmMono(
                            fontSize: 8,
                            color: pos.isRetrograde
                                ? const Color(0xFFF87171)
                                : KundliDisplayColors.textMuted,
                          ),
                        ),
                      ],
                    ),
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

// ============ Transit Card ============
class _TransitCard extends StatelessWidget {
  final TransitData transit;

  const _TransitCard({required this.transit});

  @override
  Widget build(BuildContext context) {
    final color = transit.isFavorable ? const Color(0xFF4ADE80) : const Color(0xFFF87171);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: transit.isFavorable
              ? color.withOpacity(0.3)
              : KundliDisplayColors.borderColor.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: getPlanetColor(transit.planet).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    getPlanetSymbol(transit.planet),
                    style: TextStyle(fontSize: 16, color: getPlanetColor(transit.planet)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          transit.planet,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: KundliDisplayColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              transit.isFavorable ? Icons.thumb_up_rounded : Icons.thumb_down_rounded,
                              size: 12,
                              color: color,
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                transit.isFavorable ? 'Favorable' : 'Challenging',
                                style: GoogleFonts.dmSans(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _TransitChip(
                          text: '${transit.currentSign} ${transit.currentDegree.toStringAsFixed(1)}°',
                          color: KundliDisplayColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        _TransitChip(
                          text: 'House ${transit.transitHouse}',
                          color: KundliDisplayColors.accentSecondary,
                        ),
                        if (transit.aspectToNatal != 'None') ...[
                          const SizedBox(width: 6),
                          _TransitChip(
                            text: transit.aspectToNatal,
                            color: KundliDisplayColors.accentPrimary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (transit.effects.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: KundliDisplayColors.borderColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 12,
                    color: KundliDisplayColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      transit.effects,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: KundliDisplayColors.textSecondary,
                        height: 1.3,
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
}

class _TransitChip extends StatelessWidget {
  final String text;
  final Color color;

  const _TransitChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmMono(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

