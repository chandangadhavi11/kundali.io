import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/constants.dart';

/// Shared Section Header Widget for all Dasha views
class DashaSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const DashaSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
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
    );
  }
}

/// Date Badge Widget for showing start/end dates
class DashaDateBadge extends StatelessWidget {
  final String label;
  final DateTime date;
  final IconData icon;

  const DashaDateBadge({
    super.key,
    required this.label,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: KundliDisplayColors.textMuted),
          const SizedBox(width: 8),
          Column(
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
                formatDate(date),
                style: GoogleFonts.dmMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: KundliDisplayColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Info Footer Widget for Dasha explanations
class DashaInfoFooter extends StatelessWidget {
  final String text;

  const DashaInfoFooter({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: KundliDisplayColors.borderColor.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 14,
            color: KundliDisplayColors.textMuted.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 9,
                color: KundliDisplayColors.textMuted.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Active Badge Widget showing "NOW" indicator
class ActiveNowBadge extends StatelessWidget {
  final double fontSize;

  const ActiveNowBadge({super.key, this.fontSize = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF6EE7B7).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF6EE7B7),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'NOW',
            style: GoogleFonts.dmMono(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6EE7B7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress Bar Widget
class DashaProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final double height;

  const DashaProgressBar({
    super.key,
    required this.progress,
    required this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: KundliDisplayColors.borderColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
        FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.7),
                  color,
                ],
              ),
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Hero Stat Item Widget
class DashaHeroStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const DashaHeroStatItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.dmMono(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: KundliDisplayColors.textPrimary,
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

/// Dasha Type Colors
class DashaTypeColors {
  DashaTypeColors._();

  // Vimshottari - Gold theme
  static const vimshottariPrimary = Color(0xFFD4AF37);
  static const vimshottariSecondary = Color(0xFFE8C547);

  // Mahadasha Phala - Amber/Orange theme
  static const phalaPrimary = Color(0xFFFF9500);
  static const phalaSecondary = Color(0xFFFFB84D);

  // Yogini - Purple theme
  static const yoginiPrimary = Color(0xFFA78BFA);
  static const yoginiSecondary = Color(0xFFC4B5FD);

  // Char - Emerald theme
  static const charPrimary = Color(0xFF6EE7B7);
  static const charSecondary = Color(0xFF34D399);

  // Level colors
  static const mahadasha = Color(0xFFE8B931);
  static const antardasha = Color(0xFFA78BFA);
  static const pratyantara = Color(0xFF6EE7B7);
  static const sookshma = Color(0xFF60A5FA);
  static const prana = Color(0xFFF472B6);
}

// ============ Helper Functions ============

/// Format date as "d MMM yyyy"
String formatDate(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// Format date as "d/M/yy"
String formatDateShort(DateTime date) {
  return '${date.day}/${date.month}/${date.year.toString().substring(2)}';
}

/// Format date with time
String formatDateWithTime(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute';
}

/// Format date short with time
String formatDateShortWithTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day}/${date.month} $hour:$minute';
}

/// Format duration in years, months, days
String formatDuration(double durationYears) {
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

// Note: getPlanetColor and getPlanetSymbol are available from constants.dart

/// Get sign color
Color getSignColor(String sign) {
  // Fire signs - Red/Orange
  if (['Aries', 'Leo', 'Sagittarius'].contains(sign)) {
    return const Color(0xFFF87171);
  }
  // Earth signs - Green/Brown
  if (['Taurus', 'Virgo', 'Capricorn'].contains(sign)) {
    return const Color(0xFF6EE7B7);
  }
  // Air signs - Blue/Cyan
  if (['Gemini', 'Libra', 'Aquarius'].contains(sign)) {
    return const Color(0xFF60A5FA);
  }
  // Water signs - Purple/Blue
  if (['Cancer', 'Scorpio', 'Pisces'].contains(sign)) {
    return const Color(0xFFA78BFA);
  }
  return const Color(0xFF9CA3AF);
}

/// Get sign symbol
String getSignSymbol(String sign) {
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
  return symbols[sign] ?? '⭐';
}

