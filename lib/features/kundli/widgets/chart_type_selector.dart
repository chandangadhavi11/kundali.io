import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/models/kundali_data_model.dart';

/// A horizontally scrollable chart type selector for switching between
/// different Kundali types (Lagna, Chandra, Navamsa, etc.)
class ChartTypeSelector extends StatelessWidget {
  final KundaliType currentType;
  final ValueChanged<KundaliType> onTypeChanged;

  const ChartTypeSelector({
    super.key,
    required this.currentType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final types = KundaliType.values;

    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          final isSelected = currentType == type;

          return _ChartTypeCard(
            type: type,
            isSelected: isSelected,
            hasMarginRight: index < types.length - 1,
            onTap: () {
              HapticFeedback.selectionClick();
              onTypeChanged(type);
            },
          );
        },
      ),
    );
  }
}

/// Individual card for each chart type option
class _ChartTypeCard extends StatefulWidget {
  final KundaliType type;
  final bool isSelected;
  final bool hasMarginRight;
  final VoidCallback onTap;

  const _ChartTypeCard({
    required this.type,
    required this.isSelected,
    required this.hasMarginRight,
    required this.onTap,
  });

  @override
  State<_ChartTypeCard> createState() => _ChartTypeCardState();
}

class _ChartTypeCardState extends State<_ChartTypeCard> {
  bool _isPressed = false;

  static const _surfaceColor = Color(0xFF1A1625);
  static const _borderColor = Color(0xFF2A2438);
  static const _accentPrimary = Color(0xFFD4AF37);
  static const _accentSecondary = Color(0xFFA78BFA);
  static const _textPrimary = Color(0xFFF8F7FC);
  static const _textMuted = Color(0xFF6B6478);

  IconData _getIcon(KundaliType type) {
    switch (type) {
      case KundaliType.lagna:
        return Icons.north_east_rounded;
      case KundaliType.chandra:
        return Icons.nightlight_round;
      case KundaliType.surya:
        return Icons.wb_sunny_rounded;
      case KundaliType.navamsa:
        return Icons.favorite_rounded;
      case KundaliType.dasamsa:
        return Icons.work_rounded;
      case KundaliType.saptamsa:
        return Icons.child_care_rounded;
      case KundaliType.dwadasamsa:
        return Icons.people_rounded;
      case KundaliType.trimshamsa:
        return Icons.warning_amber_rounded;
    }
  }

  Color _getAccentColor(KundaliType type) {
    switch (type) {
      case KundaliType.lagna:
        return _accentSecondary;
      case KundaliType.chandra:
        return const Color(0xFF6EE7B7);
      case KundaliType.surya:
        return _accentPrimary;
      case KundaliType.navamsa:
        return const Color(0xFFF472B6);
      case KundaliType.dasamsa:
        return const Color(0xFF60A5FA);
      case KundaliType.saptamsa:
        return const Color(0xFFFBBF24);
      case KundaliType.dwadasamsa:
        return const Color(0xFF34D399);
      case KundaliType.trimshamsa:
        return const Color(0xFFF87171);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _getAccentColor(widget.type);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 80,
          margin: EdgeInsets.only(right: widget.hasMarginRight ? 10 : 0),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withOpacity(0.2),
                      accentColor.withOpacity(0.08),
                    ],
                  )
                : null,
            color: widget.isSelected ? null : _surfaceColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected
                  ? accentColor.withOpacity(0.4)
                  : _borderColor.withOpacity(0.3),
              width: widget.isSelected ? 1 : 0.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? accentColor.withOpacity(0.2)
                          : _borderColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getIcon(widget.type),
                      size: 18,
                      color: widget.isSelected ? accentColor : _textMuted,
                    ),
                  ),
                  // Short name badge
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? accentColor
                            : _borderColor.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.type.shortName,
                        style: GoogleFonts.dmMono(
                          fontSize: 7,
                          fontWeight: FontWeight.w700,
                          color: widget.isSelected
                              ? const Color(0xFF0D0B14)
                              : _textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Name
              Text(
                widget.type.displayName,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: widget.isSelected ? _textPrimary : _textMuted,
                  letterSpacing: 0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact version of chart type selector (dropdown style)
class ChartTypeDropdown extends StatelessWidget {
  final KundaliType currentType;
  final ValueChanged<KundaliType> onTypeChanged;

  const ChartTypeDropdown({
    super.key,
    required this.currentType,
    required this.onTypeChanged,
  });

  static const _surfaceColor = Color(0xFF1A1625);
  static const _borderColor = Color(0xFF2A2438);
  static const _accentPrimary = Color(0xFFD4AF37);
  static const _textPrimary = Color(0xFFF8F7FC);
  static const _textMuted = Color(0xFF6B6478);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTypeSelector(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _surfaceColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _borderColor.withOpacity(0.4),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _accentPrimary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                currentType.shortName,
                style: GoogleFonts.dmMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _accentPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              currentType.displayName,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: _textMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _showTypeSelector(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ChartTypeBottomSheet(
        currentType: currentType,
        onTypeChanged: (type) {
          Navigator.pop(context);
          onTypeChanged(type);
        },
      ),
    );
  }
}

class _ChartTypeBottomSheet extends StatelessWidget {
  final KundaliType currentType;
  final ValueChanged<KundaliType> onTypeChanged;

  const _ChartTypeBottomSheet({
    required this.currentType,
    required this.onTypeChanged,
  });

  static const _bgSecondary = Color(0xFF131020);
  static const _surfaceColor = Color(0xFF1A1625);
  static const _borderColor = Color(0xFF2A2438);
  static const _accentPrimary = Color(0xFFD4AF37);
  static const _textPrimary = Color(0xFFF8F7FC);
  static const _textSecondary = Color(0xFF9B95A8);
  static const _textMuted = Color(0xFF6B6478);

  IconData _getIcon(KundaliType type) {
    switch (type) {
      case KundaliType.lagna:
        return Icons.north_east_rounded;
      case KundaliType.chandra:
        return Icons.nightlight_round;
      case KundaliType.surya:
        return Icons.wb_sunny_rounded;
      case KundaliType.navamsa:
        return Icons.favorite_rounded;
      case KundaliType.dasamsa:
        return Icons.work_rounded;
      case KundaliType.saptamsa:
        return Icons.child_care_rounded;
      case KundaliType.dwadasamsa:
        return Icons.people_rounded;
      case KundaliType.trimshamsa:
        return Icons.warning_amber_rounded;
    }
  }

  Color _getAccentColor(KundaliType type) {
    switch (type) {
      case KundaliType.lagna:
        return const Color(0xFFA78BFA);
      case KundaliType.chandra:
        return const Color(0xFF6EE7B7);
      case KundaliType.surya:
        return _accentPrimary;
      case KundaliType.navamsa:
        return const Color(0xFFF472B6);
      case KundaliType.dasamsa:
        return const Color(0xFF60A5FA);
      case KundaliType.saptamsa:
        return const Color(0xFFFBBF24);
      case KundaliType.dwadasamsa:
        return const Color(0xFF34D399);
      case KundaliType.trimshamsa:
        return const Color(0xFFF87171);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: _bgSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Row(
              children: [
                Icon(
                  Icons.grid_view_rounded,
                  size: 18,
                  color: _accentPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Select Chart Type',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Grid of chart types
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: KundaliType.values.length,
              itemBuilder: (context, index) {
                final type = KundaliType.values[index];
                final isSelected = currentType == type;
                final accentColor = _getAccentColor(type);

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTypeChanged(type);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accentColor.withOpacity(0.15)
                          : _surfaceColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? accentColor.withOpacity(0.4)
                            : _borderColor.withOpacity(0.3),
                        width: isSelected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIcon(type),
                          size: 22,
                          color: isSelected ? accentColor : _textMuted,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          type.shortName,
                          style: GoogleFonts.dmMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? accentColor : _textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          type.displayName,
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected ? _textPrimary : _textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

