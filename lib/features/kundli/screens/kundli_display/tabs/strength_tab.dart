import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../shared/constants.dart';

/// Strength Tab - Shows Shadbala, Vimshopaka, and Ashtakavarga
class StrengthTab extends StatelessWidget {
  final KundaliData kundaliData;

  const StrengthTab({super.key, required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final shadbala = KundaliCalculationService.calculateShadbala(
      kundaliData.planetPositions,
      kundaliData.ascendant.longitude,
      kundaliData.birthDateTime,
    );
    final vimshopaka = KundaliCalculationService.calculateVimshopakaBala(
      kundaliData.planetPositions,
    );
    final ashtakavarga = KundaliCalculationService.calculateAshtakavarga(
      kundaliData.planetPositions,
    );
    final sav = KundaliCalculationService.calculateSarvashtakavarga(
      ashtakavarga,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shadbala Section
          _SectionHeader(
            title: 'Shadbala',
            subtitle: 'Six-fold planetary strength',
            icon: Icons.fitness_center_rounded,
            color: const Color(0xFFA78BFA),
          ),
          const SizedBox(height: 10),
          ...shadbala.entries.map((entry) => _ShadbalaCard(data: entry.value)),

          const SizedBox(height: 24),

          // Vimshopaka Bala Section
          _SectionHeader(
            title: 'Vimshopaka Bala',
            subtitle: 'Divisional chart strength',
            icon: Icons.layers_rounded,
            color: const Color(0xFF60A5FA),
          ),
          const SizedBox(height: 10),
          ...vimshopaka.entries.map((entry) => _VimshopakCard(data: entry.value)),

          const SizedBox(height: 24),

          // Ashtakavarga Section
          _SectionHeader(
            title: 'Ashtakavarga',
            subtitle: 'Point-based strength analysis',
            icon: Icons.grid_on_rounded,
            color: const Color(0xFF4ADE80),
          ),
          const SizedBox(height: 10),
          _AshtakavargaGrid(ashtakavarga: ashtakavarga, sav: sav),
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

// ============ Shadbala Card ============
class _ShadbalaCard extends StatelessWidget {
  final ShadbalaData data;

  const _ShadbalaCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final percentage = data.percentageOfRequired.clamp(0.0, 150.0);
    final color = data.isStrong ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24);

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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: getPlanetColor(data.planet).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    getPlanetSymbol(data.planet),
                    style: TextStyle(
                      fontSize: 14,
                      color: getPlanetColor(data.planet),
                    ),
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
                          data.planet,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: KundliDisplayColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            data.isStrong ? 'Strong' : 'Weak',
                            style: GoogleFonts.dmSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 150,
                        backgroundColor: KundliDisplayColors.borderColor.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data.totalBala.toStringAsFixed(1)} / ${data.requiredBala.toStringAsFixed(0)} (${percentage.toStringAsFixed(0)}%)',
                      style: GoogleFonts.dmMono(
                        fontSize: 9,
                        color: KundliDisplayColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _BalaChip(label: 'Sthana', value: data.sthanaBala),
              _BalaChip(label: 'Dig', value: data.digBala),
              _BalaChip(label: 'Kala', value: data.kalaBala),
              _BalaChip(label: 'Chesta', value: data.chestaBala),
              _BalaChip(label: 'Naisarg', value: data.naisargikaBala),
              _BalaChip(label: 'Drik', value: data.drikBala),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalaChip extends StatelessWidget {
  final String label;
  final double value;

  const _BalaChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: KundliDisplayColors.borderColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 7,
                color: KundliDisplayColors.textMuted,
              ),
            ),
            Text(
              value.toStringAsFixed(0),
              style: GoogleFonts.dmMono(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: KundliDisplayColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ Vimshopak Card ============
class _VimshopakCard extends StatelessWidget {
  final VimshopakaBalaData data;

  const _VimshopakCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = data.strength == 'Strong'
        ? const Color(0xFF4ADE80)
        : data.strength == 'Medium'
            ? const Color(0xFFFBBF24)
            : const Color(0xFFF87171);

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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: getPlanetColor(data.planet).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                getPlanetSymbol(data.planet),
                style: TextStyle(
                  fontSize: 14,
                  color: getPlanetColor(data.planet),
                ),
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
                      data.planet,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: KundliDisplayColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        data.strength,
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.totalPoints.toStringAsFixed(1)} / ${data.maxPoints.toStringAsFixed(0)} points (${data.percentage.toStringAsFixed(0)}%)',
                  style: GoogleFonts.dmMono(
                    fontSize: 9,
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

// ============ Ashtakavarga Grid ============
class _AshtakavargaGrid extends StatelessWidget {
  final Map<String, List<int>> ashtakavarga;
  final List<int> sav;

  const _AshtakavargaGrid({
    required this.ashtakavarga,
    required this.sav,
  });

  @override
  Widget build(BuildContext context) {
    final signs = ['Ari', 'Tau', 'Gem', 'Can', 'Leo', 'Vir', 'Lib', 'Sco', 'Sag', 'Cap', 'Aqu', 'Pis'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: KundliDisplayColors.borderColor.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: DataTable(
          columnSpacing: 12,
          horizontalMargin: 8,
          headingRowHeight: 32,
          dataRowMinHeight: 28,
          dataRowMaxHeight: 32,
          headingTextStyle: GoogleFonts.dmSans(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: KundliDisplayColors.textMuted,
          ),
          dataTextStyle: GoogleFonts.dmMono(
            fontSize: 10,
            color: KundliDisplayColors.textPrimary,
          ),
          columns: [
            const DataColumn(label: Text('Planet')),
            ...signs.map((s) => DataColumn(label: Text(s))),
            const DataColumn(label: Text('Total')),
          ],
          rows: [
            ...ashtakavarga.entries.map((entry) {
              final planetTotal = entry.value.fold<int>(0, (a, b) => a + b);
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      entry.key.substring(0, 3),
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        color: getPlanetColor(entry.key),
                      ),
                    ),
                  ),
                  ...entry.value.map((v) => DataCell(
                    Text(
                      '$v',
                      style: TextStyle(
                        color: v >= 4
                            ? const Color(0xFF4ADE80)
                            : v <= 2
                                ? const Color(0xFFF87171)
                                : KundliDisplayColors.textPrimary,
                      ),
                    ),
                  )),
                  DataCell(
                    Text(
                      '$planetTotal',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        color: KundliDisplayColors.accentPrimary,
                      ),
                    ),
                  ),
                ],
              );
            }),
            // SAV Row
            DataRow(
              color: WidgetStateProperty.all(
                KundliDisplayColors.accentPrimary.withOpacity(0.08),
              ),
              cells: [
                DataCell(
                  Text(
                    'SAV',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      color: KundliDisplayColors.accentPrimary,
                    ),
                  ),
                ),
                ...sav.map((v) => DataCell(
                  Text(
                    '$v',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      color: v >= 28
                          ? const Color(0xFF4ADE80)
                          : v <= 20
                              ? const Color(0xFFF87171)
                              : KundliDisplayColors.textPrimary,
                    ),
                  ),
                )),
                DataCell(
                  Text(
                    '${sav.fold<int>(0, (a, b) => a + b)}',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      color: KundliDisplayColors.accentPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

