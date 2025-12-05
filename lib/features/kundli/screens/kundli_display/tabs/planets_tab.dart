import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../shared/constants.dart';

/// Planets Tab - Shows all planetary positions
class PlanetsTab extends StatelessWidget {
  final KundaliData kundaliData;

  const PlanetsTab({super.key, required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: kundaliData.planetPositions.length,
      itemBuilder: (_, index) {
        final planet = kundaliData.planetPositions.values.elementAt(index);
        final color = getPlanetColor(planet.planet);

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 12 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _buildPlanetCard(planet, color),
        );
      },
    );
  }

  Widget _buildPlanetCard(PlanetPosition planet, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                getPlanetSymbol(planet.planet),
                style: TextStyle(fontSize: 16, color: color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planet.planet,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: KundliDisplayColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildPlanetChip(
                      '${planet.sign} ${planet.signDegree.toStringAsFixed(1)}°',
                      KundliDisplayColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    _buildPlanetChip(
                      'H${planet.house}',
                      KundliDisplayColors.accentSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        planet.nakshatra,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: KundliDisplayColors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildPlanetChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmMono(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

