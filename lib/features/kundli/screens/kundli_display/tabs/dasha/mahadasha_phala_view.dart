import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../../shared/constants.dart';
import 'dasha_shared_widgets.dart';

/// Mahadasha Phala View - Shows interpretations and predictions for current Mahadasha
class MahadashaPhalaView extends StatelessWidget {
  final KundaliData kundaliData;

  const MahadashaPhalaView({super.key, required this.kundaliData});

  // Amber/Orange theme for Mahadasha Phala
  static const _phalaAccent = Color(0xFFFF9500);
  static const _phalaSecondary = Color(0xFFFFB84D);

  @override
  Widget build(BuildContext context) {
    final dasha = kundaliData.dashaInfo;
    final interpretation = MahadashaInterpretations.getInterpretation(dasha.currentMahadasha);
    
    if (interpretation == null) {
      return _buildNoDataView();
    }
    
    final now = DateTime.now();
    final dynamicRemainingYears = _calculateDynamicRemainingYears(dasha, now);
    final planetColor = getPlanetColor(dasha.currentMahadasha);
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          _PhalaHeroCard(
            dasha: dasha,
            interpretation: interpretation,
            dynamicRemainingYears: dynamicRemainingYears,
            now: now,
          ),
          
          const SizedBox(height: 20),
          
          // Overall Theme
          _ThemeCard(
            theme: interpretation.overallTheme,
            planetColor: planetColor,
          ),
          
          const SizedBox(height: 20),
          
          // Key Effects Section
          DashaSectionHeader(
            icon: Icons.auto_awesome_rounded,
            title: 'Key Effects',
            subtitle: 'Primary influences during this period',
            color: _phalaAccent,
          ),
          const SizedBox(height: 12),
          
          _KeyEffectsCard(effects: interpretation.keyEffects, color: planetColor),
          
          const SizedBox(height: 20),
          
          // Life Areas Section
          DashaSectionHeader(
            icon: Icons.dashboard_rounded,
            title: 'Life Areas',
            subtitle: 'Impact on different aspects of life',
            color: const Color(0xFF60A5FA),
          ),
          const SizedBox(height: 12),
          
          _LifeAreasCard(lifeAreas: interpretation.lifeAreas),
          
          const SizedBox(height: 20),
          
          // Current Antardasha Section
          if (dasha.currentAntardasha != null) ...[
            DashaSectionHeader(
              icon: Icons.layers_rounded,
              title: 'Current Antardasha',
              subtitle: '${dasha.currentAntardasha} sub-period influence',
              color: DashaTypeColors.antardasha,
            ),
            const SizedBox(height: 12),
            _AntardashaCard(
              mahadasha: dasha.currentMahadasha,
              antardasha: dasha.currentAntardasha!,
              remainingYears: dasha.antardashaRemainingYears,
            ),
            const SizedBox(height: 20),
          ],
          
          // Favorable & Challenges
          DashaSectionHeader(
            icon: Icons.balance_rounded,
            title: 'Strengths & Challenges',
            subtitle: 'What works and what to watch',
            color: const Color(0xFF6EE7B7),
          ),
          const SizedBox(height: 12),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _AspectCard(
                  title: 'Favorable',
                  items: interpretation.favorableAspects,
                  color: const Color(0xFF6EE7B7),
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AspectCard(
                  title: 'Challenges',
                  items: interpretation.challenges,
                  color: const Color(0xFFF87171),
                  icon: Icons.warning_amber_rounded,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Remedies Section
          DashaSectionHeader(
            icon: Icons.healing_rounded,
            title: 'Remedies & Recommendations',
            subtitle: 'Ways to enhance positive effects',
            color: DashaTypeColors.yoginiPrimary,
          ),
          const SizedBox(height: 12),
          
          _RemediesCard(
            remedies: interpretation.remedies,
            gemstone: interpretation.gemstone,
            mantra: interpretation.mantra,
            deity: interpretation.deity,
            color: interpretation.color,
            dayOfWeek: interpretation.dayOfWeek,
          ),
          
          const SizedBox(height: 16),
          
          // Info footer
          const DashaInfoFooter(
            text: 'Mahadasha Phala provides general predictions based on Vedic astrology. Results vary based on individual chart, current transits, and personal karma. Consult an astrologer for personalized guidance.',
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoDataView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _phalaAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.hourglass_empty_rounded,
                size: 40,
                color: _phalaAccent.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Interpretation Unavailable',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: KundliDisplayColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load Mahadasha interpretation. Please try again.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: KundliDisplayColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  double _calculateDynamicRemainingYears(DashaInfo dasha, DateTime now) {
    if (dasha.mahadashaEndDate != null) {
      final daysRemaining = dasha.mahadashaEndDate!.difference(now).inDays;
      if (daysRemaining > 0) {
        return daysRemaining / 365.25;
      }
      return 0;
    }
    return dasha.remainingYears;
  }
}

// ============ Hero Card ============
class _PhalaHeroCard extends StatelessWidget {
  final DashaInfo dasha;
  final MahadashaPhalaData interpretation;
  final double dynamicRemainingYears;
  final DateTime now;

  const _PhalaHeroCard({
    required this.dasha,
    required this.interpretation,
    required this.dynamicRemainingYears,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final planetColor = getPlanetColor(dasha.currentMahadasha);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            planetColor.withOpacity(0.15),
            const Color(0xFFFF9500).withOpacity(0.08),
            KundliDisplayColors.surfaceColor.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: planetColor.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: planetColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Planet symbol with prediction badge
              Stack(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          planetColor.withOpacity(0.25),
                          planetColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: planetColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        getPlanetSymbol(dasha.currentMahadasha),
                        style: TextStyle(
                          fontSize: 32,
                          color: planetColor,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9500),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF9500).withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9500).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.insights_rounded,
                            size: 12,
                            color: Color(0xFFFF9500),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'PREDICTIONS',
                            style: GoogleFonts.dmMono(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFF9500),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${dasha.currentMahadasha} Mahadasha Phala',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: KundliDisplayColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_pin_rounded,
                          size: 12,
                          color: KundliDisplayColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Deity: ${interpretation.deity}',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: KundliDisplayColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.diamond_outlined,
                          size: 12,
                          color: planetColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          interpretation.gemstone,
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: planetColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Time info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TimeInfo(
                    icon: Icons.hourglass_bottom_rounded,
                    label: 'Time Remaining',
                    value: formatDuration(dynamicRemainingYears),
                    color: planetColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: KundliDisplayColors.borderColor.withOpacity(0.3),
                ),
                Expanded(
                  child: _TimeInfo(
                    icon: Icons.calendar_today_rounded,
                    label: 'Auspicious Day',
                    value: _getDayName(interpretation.dayOfWeek),
                    color: const Color(0xFFFF9500),
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: KundliDisplayColors.borderColor.withOpacity(0.3),
                ),
                Expanded(
                  child: _TimeInfo(
                    icon: Icons.palette_outlined,
                    label: 'Lucky Color',
                    value: interpretation.color.split(',').first,
                    color: planetColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int dayOfWeek) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[dayOfWeek % 7];
  }
}

class _TimeInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _TimeInfo({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color.withOpacity(0.7)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: KundliDisplayColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 8,
            color: KundliDisplayColors.textMuted,
          ),
        ),
      ],
    );
  }
}

// ============ Theme Card ============
class _ThemeCard extends StatelessWidget {
  final String theme;
  final Color planetColor;

  const _ThemeCard({required this.theme, required this.planetColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            planetColor.withOpacity(0.08),
            KundliDisplayColors.surfaceColor.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: planetColor.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: planetColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.format_quote_rounded,
              size: 18,
              color: planetColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              theme,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                height: 1.5,
                color: KundliDisplayColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Key Effects Card ============
class _KeyEffectsCard extends StatelessWidget {
  final List<String> effects;
  final Color color;

  const _KeyEffectsCard({required this.effects, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: KundliDisplayColors.borderColor.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Column(
        children: effects.asMap().entries.map((entry) {
          final index = entry.key;
          final effect = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: index < effects.length - 1 ? 10 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.dmMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    effect,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: KundliDisplayColors.textSecondary,
                      height: 1.4,
                    ),
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

// ============ Life Areas Card ============
class _LifeAreasCard extends StatelessWidget {
  final Map<String, String> lifeAreas;

  const _LifeAreasCard({required this.lifeAreas});

  static const _areaIcons = {
    'Career': Icons.work_outline_rounded,
    'Health': Icons.favorite_outline_rounded,
    'Relationships': Icons.people_outline_rounded,
    'Finance': Icons.account_balance_wallet_outlined,
    'Spirituality': Icons.self_improvement_rounded,
  };

  static const _areaColors = {
    'Career': Color(0xFF60A5FA),
    'Health': Color(0xFFF87171),
    'Relationships': Color(0xFFF472B6),
    'Finance': Color(0xFF6EE7B7),
    'Spirituality': Color(0xFFA78BFA),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: lifeAreas.entries.map((entry) {
        final area = entry.key;
        final description = entry.value;
        final icon = _areaIcons[area] ?? Icons.star_outline_rounded;
        final color = _areaColors[area] ?? KundliDisplayColors.accentSecondary;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: KundliDisplayColors.surfaceColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: KundliDisplayColors.borderColor.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              title: Text(
                area,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: KundliDisplayColors.textPrimary,
                ),
              ),
              iconColor: KundliDisplayColors.textMuted,
              collapsedIconColor: KundliDisplayColors.textMuted,
              children: [
                Text(
                  description,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: KundliDisplayColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ============ Antardasha Card ============
class _AntardashaCard extends StatelessWidget {
  final String mahadasha;
  final String antardasha;
  final double? remainingYears;

  const _AntardashaCard({
    required this.mahadasha,
    required this.antardasha,
    this.remainingYears,
  });

  @override
  Widget build(BuildContext context) {
    final antarColor = getPlanetColor(antardasha);
    final effect = MahadashaInterpretations.getAntardashaEffect(mahadasha, antardasha);
    final antarData = MahadashaInterpretations.getInterpretation(antardasha);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            antarColor.withOpacity(0.1),
            KundliDisplayColors.surfaceColor.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: antarColor.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: antarColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    getPlanetSymbol(antardasha),
                    style: TextStyle(fontSize: 18, color: antarColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$antardasha Antardasha',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: KundliDisplayColors.textPrimary,
                      ),
                    ),
                    if (remainingYears != null)
                      Text(
                        '${formatDuration(remainingYears!)} remaining',
                        style: GoogleFonts.dmMono(
                          fontSize: 10,
                          color: antarColor,
                        ),
                      ),
                  ],
                ),
              ),
              const ActiveNowBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              effect,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: KundliDisplayColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          if (antarData != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _MiniInfo(
                  label: 'Gemstone',
                  value: antarData.gemstone.split(' ').first,
                  color: antarColor,
                ),
                const SizedBox(width: 8),
                _MiniInfo(
                  label: 'Day',
                  value: _getDayShort(antarData.dayOfWeek),
                  color: antarColor,
                ),
                const SizedBox(width: 8),
                _MiniInfo(
                  label: 'Deity',
                  value: antarData.deity.split('/').first.replaceAll('Lord ', '').replaceAll('Goddess ', ''),
                  color: antarColor,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getDayShort(int dayOfWeek) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[dayOfWeek % 7];
  }
}

class _MiniInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniInfo({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}

// ============ Aspect Card ============
class _AspectCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  final IconData icon;

  const _AspectCard({
    required this.title,
    required this.items,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
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
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
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
          const SizedBox(height: 10),
          ...items.take(5).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: KundliDisplayColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ============ Remedies Card ============
class _RemediesCard extends StatelessWidget {
  final List<String> remedies;
  final String gemstone;
  final String mantra;
  final String deity;
  final String color;
  final int dayOfWeek;

  const _RemediesCard({
    required this.remedies,
    required this.gemstone,
    required this.mantra,
    required this.deity,
    required this.color,
    required this.dayOfWeek,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DashaTypeColors.yoginiPrimary.withOpacity(0.08),
            KundliDisplayColors.surfaceColor.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DashaTypeColors.yoginiPrimary.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Info Row
          Row(
            children: [
              _RemedyInfo(
                icon: Icons.diamond_outlined,
                label: 'Gemstone',
                value: gemstone.split('(').first.trim(),
              ),
              const SizedBox(width: 8),
              _RemedyInfo(
                icon: Icons.person_outline_rounded,
                label: 'Deity',
                value: deity.split('/').first.trim(),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Mantra
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.record_voice_over_outlined,
                      size: 12,
                      color: DashaTypeColors.yoginiPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Mantra',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: DashaTypeColors.yoginiPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  mantra,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 11,
                    color: KundliDisplayColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Remedies List
          Text(
            'Suggested Practices',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: KundliDisplayColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ...remedies.map((remedy) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 14,
                  color: DashaTypeColors.yoginiPrimary.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    remedy,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: KundliDisplayColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _RemedyInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RemedyInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: DashaTypeColors.yoginiPrimary),
            const SizedBox(width: 8),
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
                    value,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: KundliDisplayColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

