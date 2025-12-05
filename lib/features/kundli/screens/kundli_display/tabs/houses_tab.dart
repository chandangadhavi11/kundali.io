import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../shared/constants.dart';

/// Houses Tab - Shows all 12 houses with their signs and planets
class HousesTab extends StatelessWidget {
  final KundaliData kundaliData;

  const HousesTab({super.key, required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: kundaliData.houses.length,
      itemBuilder: (_, index) {
        final house = kundaliData.houses[index];

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 40)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 12 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _buildHouseCard(house),
        );
      },
    );
  }

  Widget _buildHouseCard(House house) {
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  KundliDisplayColors.accentSecondary.withOpacity(0.25),
                  KundliDisplayColors.accentSecondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${house.number}',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: KundliDisplayColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getHouseName(house.number),
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: KundliDisplayColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• ${house.sign}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: KundliDisplayColors.textMuted,
                      ),
                    ),
                  ],
                ),
                if (house.planets.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: house.planets.map((p) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: getPlanetColor(p).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          p,
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: getPlanetColor(p),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getHouseName(int n) {
    const names = [
      'Self',
      'Wealth',
      'Siblings',
      'Home',
      'Children',
      'Health',
      'Partner',
      'Transform',
      'Fortune',
      'Career',
      'Gains',
      'Liberation',
    ];
    return names[(n - 1) % 12];
  }
}

