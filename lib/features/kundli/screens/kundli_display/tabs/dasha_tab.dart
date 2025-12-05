import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../shared/constants.dart';

/// Dasha Tab - Shows Vimshottari Dasha with drill-down capability
class DashaTab extends StatelessWidget {
  final KundaliData kundaliData;

  const DashaTab({super.key, required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    final dasha = kundaliData.dashaInfo;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      child: Column(
        children: [
          // Current Dasha Card
          _CurrentDashaCard(dasha: dasha),
          const SizedBox(height: 20),
          // Section header
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Row(
                children: [
                  Text(
                    'Dasha Sequence',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: KundliDisplayColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• Tap to explore',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: KundliDisplayColors.accentSecondary.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Dasha sequence list
          ...dasha.sequence.asMap().entries.map((entry) {
            final index = entry.key;
            final period = entry.value;
            final isCurrent = period.planet == dasha.currentMahadasha;
            return _DashaPeriodItem(
              period: period,
              index: index,
              isCurrent: isCurrent,
              dasha: dasha,
            );
          }),
        ],
      ),
    );
  }
}

// ============ Current Dasha Card ============
class _CurrentDashaCard extends StatelessWidget {
  final DashaInfo dasha;

  const _CurrentDashaCard({required this.dasha});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              KundliDisplayColors.accentSecondary.withOpacity(0.15),
              KundliDisplayColors.accentSecondary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: KundliDisplayColors.accentSecondary.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: KundliDisplayColors.textPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _getPlanetSymbol(dasha.currentMahadasha),
                  style: TextStyle(
                    fontSize: 20,
                    color: _getPlanetColor(dasha.currentMahadasha),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Mahadasha',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: KundliDisplayColors.accentSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dasha.currentMahadasha,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: KundliDisplayColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.hourglass_bottom_rounded,
                        size: 11,
                        color: KundliDisplayColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${dasha.remainingYears.toStringAsFixed(1)} years remaining',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: KundliDisplayColors.textMuted,
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
    );
  }
}

// ============ Dasha Period Item ============
class _DashaPeriodItem extends StatelessWidget {
  final DashaPeriod period;
  final int index;
  final bool isCurrent;
  final DashaInfo dasha;

  const _DashaPeriodItem({
    required this.period,
    required this.index,
    required this.isCurrent,
    required this.dasha,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _showDashaDetails(context, period.planet, dasha),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isCurrent
                ? KundliDisplayColors.accentSecondary.withOpacity(0.1)
                : KundliDisplayColors.surfaceColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isCurrent
                  ? KundliDisplayColors.accentSecondary.withOpacity(0.3)
                  : KundliDisplayColors.borderColor.withOpacity(0.4),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _getPlanetColor(period.planet).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    _getPlanetSymbol(period.planet),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getPlanetColor(period.planet),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  period.planet,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                    color: KundliDisplayColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${period.years} years',
                style: GoogleFonts.dmMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: KundliDisplayColors.textMuted,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: KundliDisplayColors.textMuted.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDashaDetails(BuildContext context, String mahadashaPlanet, DashaInfo dasha) {
    final mahadashaDetail = dasha.mahadashaSequence?.firstWhere(
      (m) => m.planet == mahadashaPlanet,
      orElse: () => dasha.mahadashaSequence!.first,
    );

    if (mahadashaDetail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Detailed dasha data not available for $mahadashaPlanet'),
          backgroundColor: KundliDisplayColors.accentSecondary,
        ),
      );
      return;
    }

    _showDashaPeriodSheet(context, mahadashaDetail, []);
  }
}

// ============ Dasha Period Bottom Sheet ============
void _showDashaPeriodSheet(
  BuildContext context,
  DashaPeriodDetail period,
  List<String> breadcrumbs,
) {
  final levelColors = {
    DashaLevel.mahadasha: const Color(0xFFE8B931),
    DashaLevel.antardasha: const Color(0xFFA78BFA),
    DashaLevel.pratyantara: const Color(0xFF6EE7B7),
    DashaLevel.sookshma: const Color(0xFF60A5FA),
    DashaLevel.prana: const Color(0xFFF472B6),
  };

  final levelColor = levelColors[period.level] ?? KundliDisplayColors.accentSecondary;
  final newBreadcrumbs = [...breadcrumbs, period.planet];
  final now = DateTime.now();
  final isCurrentPeriod = period.containsDate(now);

  final hasSubPeriods = period.subPeriods != null && period.subPeriods!.isNotEmpty;
  final nextLevel = _getNextLevel(period.level);
  final canDrillDeeper = nextLevel != null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: KundliDisplayColors.bgSecondary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: levelColor.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            // Handle bar
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
            _DashaPeriodHeader(
              period: period,
              breadcrumbs: breadcrumbs,
              levelColor: levelColor,
              isCurrentPeriod: isCurrentPeriod,
            ),
            // Sub-periods section header
            if (canDrillDeeper)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      '${_getLevelDisplayName(nextLevel)} Periods',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: KundliDisplayColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (hasSubPeriods)
                      Text(
                        '(${period.subPeriods!.length})',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: KundliDisplayColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            // Sub-periods list
            Expanded(
              child: hasSubPeriods
                  ? _SubPeriodsListView(
                      period: period,
                      scrollController: scrollController,
                      newBreadcrumbs: newBreadcrumbs,
                      levelColors: levelColors,
                      now: now,
                    )
                  : _LoadingPlaceholder(),
            ),
          ],
        ),
      ),
    ),
  );
}

// ============ Dasha Period Header ============
class _DashaPeriodHeader extends StatelessWidget {
  final DashaPeriodDetail period;
  final List<String> breadcrumbs;
  final Color levelColor;
  final bool isCurrentPeriod;

  const _DashaPeriodHeader({
    required this.period,
    required this.breadcrumbs,
    required this.levelColor,
    required this.isCurrentPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs
          if (breadcrumbs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 14,
                      color: KundliDisplayColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      breadcrumbs.join(' → '),
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: KundliDisplayColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          // Period info row
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: levelColor.withOpacity(0.3), width: 1),
                ),
                child: Center(
                  child: Text(
                    _getPlanetSymbol(period.planet),
                    style: TextStyle(fontSize: 22, color: levelColor),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: levelColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            period.levelName,
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: levelColor,
                            ),
                          ),
                        ),
                        if (isCurrentPeriod) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6EE7B7).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ACTIVE',
                              style: GoogleFonts.dmMono(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF6EE7B7),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${period.planet} ${period.levelName}',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: KundliDisplayColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Period dates and duration
          _PeriodDateInfo(period: period, levelColor: levelColor),
        ],
      ),
    );
  }
}

// ============ Period Date Info ============
class _PeriodDateInfo extends StatelessWidget {
  final DashaPeriodDetail period;
  final Color levelColor;

  const _PeriodDateInfo({required this.period, required this.levelColor});

  @override
  Widget build(BuildContext context) {
    final needsTime = _needsTimeDisplay(period.level);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: KundliDisplayColors.borderColor.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          _DateColumn(
            label: 'Start',
            date: period.startDate,
            needsTime: needsTime,
          ),
          Container(width: 1, height: 28, color: KundliDisplayColors.borderColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _DateColumn(
                label: 'End',
                date: period.endDate,
                needsTime: needsTime,
              ),
            ),
          ),
          Container(width: 1, height: 28, color: KundliDisplayColors.borderColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration',
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      color: KundliDisplayColors.textMuted,
                    ),
                  ),
                  Text(
                    _formatDuration(period.durationYears),
                    style: GoogleFonts.dmMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: levelColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateColumn extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool needsTime;

  const _DateColumn({
    required this.label,
    required this.date,
    required this.needsTime,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
            needsTime ? _formatDateWithTime(date) : _formatDate(date),
            style: GoogleFonts.dmMono(
              fontSize: needsTime ? 10 : 11,
              fontWeight: FontWeight.w500,
              color: KundliDisplayColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Sub Periods List View ============
class _SubPeriodsListView extends StatelessWidget {
  final DashaPeriodDetail period;
  final ScrollController scrollController;
  final List<String> newBreadcrumbs;
  final Map<DashaLevel, Color> levelColors;
  final DateTime now;

  const _SubPeriodsListView({
    required this.period,
    required this.scrollController,
    required this.newBreadcrumbs,
    required this.levelColors,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: period.subPeriods!.length,
      itemBuilder: (context, index) {
        final subPeriod = period.subPeriods![index];
        final isSubCurrent = subPeriod.containsDate(now);
        final subLevelColor = levelColors[subPeriod.level] ?? KundliDisplayColors.textMuted;
        final canDrillDeeperSub = _getNextLevel(subPeriod.level) != null;

        return _SubPeriodItem(
          subPeriod: subPeriod,
          isSubCurrent: isSubCurrent,
          subLevelColor: subLevelColor,
          canDrillDeeperSub: canDrillDeeperSub,
          newBreadcrumbs: newBreadcrumbs,
        );
      },
    );
  }
}

class _SubPeriodItem extends StatelessWidget {
  final DashaPeriodDetail subPeriod;
  final bool isSubCurrent;
  final Color subLevelColor;
  final bool canDrillDeeperSub;
  final List<String> newBreadcrumbs;

  const _SubPeriodItem({
    required this.subPeriod,
    required this.isSubCurrent,
    required this.subLevelColor,
    required this.canDrillDeeperSub,
    required this.newBreadcrumbs,
  });

  @override
  Widget build(BuildContext context) {
    final needsTime = _needsTimeDisplay(subPeriod.level);

    return GestureDetector(
      onTap: canDrillDeeperSub
          ? () {
              Navigator.pop(context);
              final deeperPeriod = _ensureSubPeriods(subPeriod);
              _showDashaPeriodSheet(context, deeperPeriod, newBreadcrumbs);
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSubCurrent
              ? subLevelColor.withOpacity(0.1)
              : KundliDisplayColors.surfaceColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSubCurrent
                ? subLevelColor.withOpacity(0.3)
                : KundliDisplayColors.borderColor.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getPlanetColor(subPeriod.planet).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _getPlanetSymbol(subPeriod.planet),
                  style: TextStyle(
                    fontSize: 14,
                    color: _getPlanetColor(subPeriod.planet),
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
                        subPeriod.planet,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: isSubCurrent ? FontWeight.w600 : FontWeight.w500,
                          color: KundliDisplayColors.textPrimary,
                        ),
                      ),
                      if (isSubCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6EE7B7).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'NOW',
                            style: GoogleFonts.dmMono(
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6EE7B7),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    needsTime
                        ? '${_formatDateShortWithTime(subPeriod.startDate)} - ${_formatDateShortWithTime(subPeriod.endDate)}'
                        : '${_formatDateShort(subPeriod.startDate)} - ${_formatDateShort(subPeriod.endDate)}',
                    style: GoogleFonts.dmMono(
                      fontSize: needsTime ? 8 : 9,
                      color: KundliDisplayColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatDuration(subPeriod.durationYears),
              style: GoogleFonts.dmMono(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: KundliDisplayColors.textMuted,
              ),
            ),
            if (canDrillDeeperSub) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: KundliDisplayColors.textMuted.withOpacity(0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hourglass_empty_rounded,
              size: 48,
              color: KundliDisplayColors.textMuted.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Sub-periods calculating...',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: KundliDisplayColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Please wait or try again',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: KundliDisplayColors.textMuted.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ Helper Functions ============

Color _getPlanetColor(String planet) {
  const colors = {
    'Sun': Color(0xFFD4AF37),
    'Moon': Color(0xFF6EE7B7),
    'Mars': Color(0xFFF87171),
    'Mercury': Color(0xFF34D399),
    'Jupiter': Color(0xFFFBBF24),
    'Venus': Color(0xFFF472B6),
    'Saturn': Color(0xFF9CA3AF),
    'Rahu': Color(0xFFA78BFA),
    'Ketu': Color(0xFFC2410C),
  };
  return colors[planet] ?? Colors.grey;
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
  };
  return symbols[planet] ?? planet.substring(0, 2);
}

DashaLevel? _getNextLevel(DashaLevel current) {
  switch (current) {
    case DashaLevel.mahadasha:
      return DashaLevel.antardasha;
    case DashaLevel.antardasha:
      return DashaLevel.pratyantara;
    case DashaLevel.pratyantara:
      return DashaLevel.sookshma;
    case DashaLevel.sookshma:
      return DashaLevel.prana;
    case DashaLevel.prana:
      return null;
  }
}

String _getLevelDisplayName(DashaLevel level) {
  switch (level) {
    case DashaLevel.mahadasha:
      return 'Mahadasha';
    case DashaLevel.antardasha:
      return 'Antardasha';
    case DashaLevel.pratyantara:
      return 'Pratyantara';
    case DashaLevel.sookshma:
      return 'Sookshma';
    case DashaLevel.prana:
      return 'Prana';
  }
}

bool _needsTimeDisplay(DashaLevel level) {
  return level == DashaLevel.sookshma || level == DashaLevel.prana;
}

DashaPeriodDetail _ensureSubPeriods(DashaPeriodDetail period) {
  if (period.subPeriods != null && period.subPeriods!.isNotEmpty) {
    return period;
  }

  final nextLevel = _getNextLevel(period.level);
  if (nextLevel == null) return period;

  final subPeriods = KundaliCalculationService.calculateSubDashas(
    parentPath: period.fullPath,
    parentPlanet: period.planet,
    parentDuration: period.durationYears,
    startDate: period.startDate,
    level: nextLevel,
    maxDepth: 1,
  );

  return DashaPeriodDetail(
    planet: period.planet,
    fullPath: period.fullPath,
    durationYears: period.durationYears,
    startDate: period.startDate,
    endDate: period.endDate,
    level: period.level,
    subPeriods: subPeriods,
  );
}

String _formatDate(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatDateWithTime(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute';
}

String _formatDateShort(DateTime date) {
  return '${date.day}/${date.month}/${date.year.toString().substring(2)}';
}

String _formatDateShortWithTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day}/${date.month} $hour:$minute';
}

String _formatDuration(double durationYears) {
  final totalDays = durationYears * 365.25;

  if (totalDays >= 365) {
    final years = totalDays ~/ 365.25;
    final remainingDays = totalDays - (years * 365.25);
    final months = remainingDays ~/ 30.44;
    final days = (remainingDays - (months * 30.44)).round();
    return '$years y, $months m, $days d';
  } else if (totalDays >= 30) {
    final months = totalDays ~/ 30.44;
    final days = (totalDays - (months * 30.44)).round();
    return '$months m, $days d';
  } else if (totalDays >= 1) {
    final days = totalDays.floor();
    final hours = ((totalDays - days) * 24).round();
    if (hours > 0) return '$days d, $hours h';
    return '$days days';
  } else {
    final totalHours = totalDays * 24;
    if (totalHours >= 1) {
      final hours = totalHours.floor();
      final minutes = ((totalHours - hours) * 60).round();
      if (minutes > 0) return '$hours h, $minutes m';
      return '$hours hours';
    } else {
      final minutes = (totalHours * 60).round();
      if (minutes > 0) return '$minutes min';
      return '< 1 min';
    }
  }
}

