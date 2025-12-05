import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import '../shared/constants.dart';

/// Yogas & Doshas Tab - Shows all yogas and doshas with details
class YogasTab extends StatelessWidget {
  final KundaliData kundaliData;

  const YogasTab({super.key, required this.kundaliData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          _YogaSummaryCard(
            yogaCount: kundaliData.yogas.length,
            doshaCount: kundaliData.doshas.length,
          ),
          const SizedBox(height: 16),

          if (kundaliData.yogas.isNotEmpty) ...[
            _YogaSectionHeader(
              title: 'Auspicious Yogas',
              subtitle: '${kundaliData.yogas.length} present',
              color: KundliDisplayColors.yogaGreen,
              icon: Icons.auto_awesome_rounded,
            ),
            const SizedBox(height: 10),
            ...kundaliData.yogas.asMap().entries.map((entry) {
              return _YogaDetailCard(
                yogaName: entry.value,
                index: entry.key,
                isDosha: false,
              );
            }),
            const SizedBox(height: 20),
          ],

          if (kundaliData.doshas.isNotEmpty) ...[
            _YogaSectionHeader(
              title: 'Doshas Present',
              subtitle: '${kundaliData.doshas.length} present',
              color: KundliDisplayColors.doshaRed,
              icon: Icons.warning_amber_rounded,
            ),
            const SizedBox(height: 10),
            ...kundaliData.doshas.asMap().entries.map((entry) {
              return _YogaDetailCard(
                yogaName: entry.value,
                index: entry.key,
                isDosha: true,
              );
            }),
            const SizedBox(height: 20),
          ],

          const _InsightsSection(),
        ],
      ),
    );
  }
}

// ============ Summary Card ============
class _YogaSummaryCard extends StatelessWidget {
  final int yogaCount;
  final int doshaCount;

  const _YogaSummaryCard({
    required this.yogaCount,
    required this.doshaCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KundliDisplayColors.accentSecondary.withOpacity(0.12),
            KundliDisplayColors.accentPrimary.withOpacity(0.06),
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
          Expanded(
            child: _CountDisplay(
              count: yogaCount,
              label: 'Yogas',
              color: KundliDisplayColors.yogaGreen,
              icon: Icons.auto_awesome_rounded,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: KundliDisplayColors.borderColor,
          ),
          Expanded(
            child: _CountDisplay(
              count: doshaCount,
              label: 'Doshas',
              color: KundliDisplayColors.doshaRed,
              icon: Icons.warning_amber_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountDisplay extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final IconData icon;

  const _CountDisplay({
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: GoogleFonts.dmSans(
            fontSize: 22,
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
    );
  }
}

// ============ Section Header ============
class _YogaSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _YogaSectionHeader({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: KundliDisplayColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ============ Yoga Detail Card ============
class _YogaDetailCard extends StatelessWidget {
  final String yogaName;
  final int index;
  final bool isDosha;

  const _YogaDetailCard({
    required this.yogaName,
    required this.index,
    required this.isDosha,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDosha ? KundliDisplayColors.doshaRed : KundliDisplayColors.yogaGreen;
    final yogaInfo = _getYogaInfo(yogaName, isDosha);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _showYogaDetailsSheet(context, yogaName, isDosha),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.15), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isDosha ? Icons.warning_amber_rounded : Icons.auto_awesome_rounded,
                      color: color,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          yogaName,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: KundliDisplayColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          yogaInfo['type'] ?? (isDosha ? 'Dosha' : 'Benefic Yoga'),
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: KundliDisplayColors.textMuted.withOpacity(0.5),
                    size: 18,
                  ),
                ],
              ),
              if (yogaInfo['description'] != null) ...[
                const SizedBox(height: 10),
                Text(
                  yogaInfo['description']!,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: KundliDisplayColors.textMuted,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showYogaDetailsSheet(BuildContext context, String yogaName, bool isDosha) {
    final color = isDosha ? KundliDisplayColors.doshaRed : KundliDisplayColors.yogaGreen;
    final yogaDetails = _getFullYogaDetails(yogaName, isDosha);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: KundliDisplayColors.bgSecondary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
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
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isDosha ? Icons.warning_amber_rounded : Icons.auto_awesome_rounded,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
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
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              yogaDetails['type']!,
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
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
                    _YogaDetailSection(
                      title: 'What is $yogaName?',
                      content: yogaDetails['description']!,
                      icon: Icons.info_outline_rounded,
                      color: KundliDisplayColors.accentSecondary,
                    ),
                    const SizedBox(height: 16),
                    _YogaDetailSection(
                      title: isDosha ? 'Potential Effects' : 'Benefits',
                      content: yogaDetails['effects']!,
                      icon: isDosha ? Icons.warning_amber_outlined : Icons.star_outline_rounded,
                      color: isDosha ? const Color(0xFFFBBF24) : KundliDisplayColors.yogaGreen,
                    ),
                    const SizedBox(height: 16),
                    _YogaDetailSection(
                      title: isDosha ? 'Remedies' : 'How to Strengthen',
                      content: yogaDetails['remedies']!,
                      icon: Icons.healing_rounded,
                      color: const Color(0xFF60A5FA),
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

// ============ Detail Section ============
class _YogaDetailSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _YogaDetailSection({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: KundliDisplayColors.borderColor.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 8),
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
          Text(
            content,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: KundliDisplayColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Insights Section ============
class _InsightsSection extends StatelessWidget {
  const _InsightsSection();

  @override
  Widget build(BuildContext context) {
    final insights = [
      {
        'title': 'Understanding Yogas',
        'description': 'Yogas are beneficial planetary combinations that enhance specific areas of life.',
        'icon': Icons.lightbulb_outline_rounded,
        'color': KundliDisplayColors.accentPrimary,
      },
      {
        'title': 'Dosha Remedies',
        'description': 'Most doshas can be mitigated through proper remedies, mantras, and lifestyle changes.',
        'icon': Icons.healing_outlined,
        'color': const Color(0xFF60A5FA),
      },
      {
        'title': 'Strength Matters',
        'description': 'The strength of planets involved determines how strongly a yoga or dosha manifests.',
        'icon': Icons.fitness_center_rounded,
        'color': KundliDisplayColors.yogaGreen,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.tips_and_updates_rounded,
              size: 16,
              color: KundliDisplayColors.accentPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              'Astrological Insights',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: KundliDisplayColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...insights.map((insight) => _InsightCard(insight: insight)),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final Map<String, dynamic> insight;

  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: KundliDisplayColors.borderColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (insight['color'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              insight['icon'] as IconData,
              color: insight['color'] as Color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: KundliDisplayColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  insight['description'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: KundliDisplayColors.textMuted,
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

// ============ DATA: Yoga Info ============
Map<String, String> _getYogaInfo(String yogaName, bool isDosha) {
  final yogaInfoMap = {
    // Pancha Mahapurusha Yogas
    'Hamsa Yoga': {
      'type': 'Pancha Mahapurusha',
      'description': 'Jupiter in Kendra in own/exalted sign. Bestows wisdom and spiritual growth.',
    },
    'Malavya Yoga': {
      'type': 'Pancha Mahapurusha',
      'description': 'Venus in Kendra in own/exalted sign. Grants beauty, wealth, and luxury.',
    },
    'Bhadra Yoga': {
      'type': 'Pancha Mahapurusha',
      'description': 'Mercury in Kendra in own sign. Gives intelligence and communication skills.',
    },
    'Ruchaka Yoga': {
      'type': 'Pancha Mahapurusha',
      'description': 'Mars in Kendra in own/exalted sign. Bestows courage and leadership.',
    },
    'Sasa Yoga': {
      'type': 'Pancha Mahapurusha',
      'description': 'Saturn in Kendra in own/exalted sign. Grants authority and discipline.',
    },
    // Raja Yogas
    'Gajakesari Yoga': {
      'type': 'Raja Yoga',
      'description': 'Jupiter in Kendra from Moon. Brings fame, wisdom, and prosperity.',
    },
    'Budhaditya Yoga': {
      'type': 'Raja Yoga',
      'description': 'Sun-Mercury conjunction. Grants sharp intellect and communication skills.',
    },
    'Chandra-Mangal Yoga': {
      'type': 'Dhana Yoga',
      'description': 'Moon-Mars conjunction. Creates wealth through courage and determination.',
    },
    'Lakshmi Yoga': {
      'type': 'Dhana Yoga',
      'description': 'Strong Venus in Kendra. Brings abundant wealth and luxury.',
    },
    'Viparita Raja Yoga': {
      'type': 'Raja Yoga',
      'description': 'Dusthana lords in dusthana. Success through unconventional means.',
    },
    // Lunar Yogas
    'Sunafa Yoga': {
      'type': 'Lunar Yoga',
      'description': 'Planet in 2nd from Moon. Brings self-earned wealth.',
    },
    'Anafa Yoga': {
      'type': 'Lunar Yoga',
      'description': 'Planet in 12th from Moon. Grants good personality and fame.',
    },
    'Durudhura Yoga': {
      'type': 'Lunar Yoga',
      'description': 'Planets in both 2nd and 12th from Moon. Blessed with comforts.',
    },
    // Other Yogas
    'Dhana Yoga': {
      'type': 'Dhana Yoga',
      'description': '2nd and 11th house connection. Indicates wealth accumulation.',
    },
    'Amala Yoga': {
      'type': 'Benefic Yoga',
      'description': 'Benefic planet in 10th house. Pure and charitable nature.',
    },
    'Saraswati Yoga': {
      'type': 'Benefic Yoga',
      'description': 'Jupiter, Venus, Mercury well placed. Learning and wisdom.',
    },
    'Bhagya Yoga': {
      'type': 'Benefic Yoga',
      'description': 'Benefic in 9th house. Good fortune and luck.',
    },
    // Doshas
    'Manglik Dosha': {
      'type': 'Dosha',
      'description': 'Mars in 1, 4, 7, 8, or 12. May affect marriage compatibility.',
    },
    'Kaal Sarp Dosha': {
      'type': 'Dosha',
      'description': 'All planets between Rahu-Ketu axis. Karmic challenges and delays.',
    },
    'Pitra Dosha': {
      'type': 'Dosha',
      'description': 'Sun afflicted by Rahu/Ketu. Ancestral karma issues.',
    },
    'Surya Grahan Dosha': {
      'type': 'Grahan Dosha',
      'description': 'Sun with Rahu/Ketu. May affect career and father.',
    },
    'Chandra Grahan Dosha': {
      'type': 'Grahan Dosha',
      'description': 'Moon with Rahu/Ketu. May affect mental peace.',
    },
    'Shrapit Dosha': {
      'type': 'Dosha',
      'description': 'Saturn-Rahu conjunction. Past life karmic debt.',
    },
    'Guru Chandal Yoga': {
      'type': 'Dosha',
      'description': 'Jupiter-Rahu conjunction. May affect wisdom and ethics.',
    },
    'Kemdrum Dosha': {
      'type': 'Dosha',
      'description': 'No planets 2nd/12th from Moon. Emotional challenges.',
    },
    'Angarak Dosha': {
      'type': 'Dosha',
      'description': 'Mars-Rahu conjunction. Anger and conflict issues.',
    },
  };

  return yogaInfoMap[yogaName] ?? {
    'type': isDosha ? 'Dosha' : 'Benefic Yoga',
    'description': isDosha
        ? 'This dosha may create certain challenges. Tap for details and remedies.'
        : 'This yoga brings positive influences to your chart. Tap for details.',
  };
}

Map<String, String> _getFullYogaDetails(String yogaName, bool isDosha) {
  final detailsMap = {
    'Hamsa Yoga': {
      'type': 'Pancha Mahapurusha Yoga',
      'description': 'Hamsa Yoga is formed when Jupiter is placed in a Kendra house (1st, 4th, 7th, or 10th) in its own sign (Sagittarius or Pisces) or its exaltation sign (Cancer). This is one of the five great person yogas in Vedic astrology.',
      'effects': 'The native is blessed with divine qualities, profound wisdom, and spiritual inclination. They gain respect from learned people, achieve good fortune, and lead a virtuous life.',
      'remedies': 'Worship Lord Vishnu regularly, study sacred scriptures, perform charitable acts on Thursdays, wear yellow clothes and donate yellow items like turmeric, bananas, or gold.',
    },
    'Malavya Yoga': {
      'type': 'Pancha Mahapurusha Yoga',
      'description': 'Malavya Yoga forms when Venus occupies a Kendra house in its own sign (Taurus or Libra) or exaltation sign (Pisces).',
      'effects': 'Bestows physical beauty, artistic talents, luxurious lifestyle, happy marriage, and material wealth.',
      'remedies': 'Worship Goddess Lakshmi, appreciate arts, maintain cleanliness, donate white items on Fridays.',
    },
    'Gajakesari Yoga': {
      'type': 'Raja Yoga',
      'description': 'One of the most auspicious yogas, formed when Jupiter is in a Kendra from the Moon.',
      'effects': 'The native gains wisdom, intelligence, excellent reputation, wealth, and leadership qualities.',
      'remedies': 'Worship Lord Ganesha and Jupiter, chant Guru mantras on Thursdays, donate yellow items.',
    },
    'Budhaditya Yoga': {
      'type': 'Raja Yoga',
      'description': 'Formed when the Sun and Mercury are conjunct in the same sign.',
      'effects': 'Grants sharp intellect, excellent communication skills, success in education.',
      'remedies': 'Worship Lord Vishnu, recite Gayatri Mantra at sunrise, donate green items on Wednesday.',
    },
    'Manglik Dosha': {
      'type': 'Major Dosha',
      'description': 'Formed when Mars is placed in the 1st, 4th, 7th, 8th, or 12th house from the Ascendant.',
      'effects': 'May cause delays in marriage, conflicts with spouse, or challenges in married life.',
      'remedies': 'Perform Mangal Shanti Puja, chant Hanuman Chalisa daily, fast on Tuesdays, marry another Manglik.',
    },
    'Kaal Sarp Dosha': {
      'type': 'Major Dosha',
      'description': 'Occurs when all seven planets are hemmed between Rahu and Ketu.',
      'effects': 'May bring sudden ups and downs, struggles, delays in success.',
      'remedies': 'Visit Trimbakeshwar temple for Kaal Sarp Puja, chant Maha Mrityunjaya Mantra, donate to snake conservation.',
    },
    'Pitra Dosha': {
      'type': 'Ancestral Dosha',
      'description': 'Formed when Sun is afflicted by Rahu or Ketu, indicating unresolved ancestral karma.',
      'effects': 'May affect father, career, fortune, and overall progress.',
      'remedies': 'Perform Pitra Tarpan on Amavasya, do Shradh rituals, feed crows and dogs.',
    },
  };

  return detailsMap[yogaName] ?? {
    'type': isDosha ? 'Dosha' : 'Benefic Yoga',
    'description': isDosha
        ? 'This dosha indicates certain karmic patterns that may create challenges in specific life areas.'
        : 'This yoga indicates beneficial planetary combinations enhancing specific areas of life.',
    'effects': isDosha
        ? 'Effects vary based on the strength and placement of involved planets.'
        : 'The benefits manifest according to the overall chart strength.',
    'remedies': isDosha
        ? 'Consult a qualified astrologer for personalized remedies based on your complete chart.'
        : 'Strengthen the involved planets through their respective mantras and gemstones.',
  };
}

