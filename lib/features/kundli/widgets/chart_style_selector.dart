import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/models/kundali_data_model.dart';

/// A premium, elegant chart style selector widget for switching between
/// North Indian, South Indian, and Western chart styles.
class ChartStyleSelector extends StatelessWidget {
  final ChartStyle currentStyle;
  final ValueChanged<ChartStyle> onStyleChanged;
  final bool compact;

  const ChartStyleSelector({
    super.key,
    required this.currentStyle,
    required this.onStyleChanged,
    this.compact = false,
  });

  // Color palette
  static const _bgPrimary = Color(0xFF0D0B14);
  static const _surfaceColor = Color(0xFF1A1625);
  static const _borderColor = Color(0xFF2A2438);
  static const _accentPrimary = Color(0xFFD4AF37);
  static const _textMuted = Color(0xFF6B6478);

  @override
  Widget build(BuildContext context) {
    final styles = [
      {
        'style': ChartStyle.northIndian,
        'icon': Icons.diamond_outlined,
        'label': 'North Indian',
        'shortLabel': 'North',
      },
      {
        'style': ChartStyle.southIndian,
        'icon': Icons.grid_4x4_rounded,
        'label': 'South Indian',
        'shortLabel': 'South',
      },
      {
        'style': ChartStyle.western,
        'icon': Icons.circle_outlined,
        'label': 'Western',
        'shortLabel': 'Western',
      },
    ];

    if (compact) {
      return _buildCompactSelector(styles);
    }

    return _buildExpandedSelector(styles);
  }

  Widget _buildExpandedSelector(List<Map<String, dynamic>> styles) {
    return Row(
      children:
          styles.map((item) {
            final style = item['style'] as ChartStyle;
            final isSelected = currentStyle == style;
            final index = styles.indexOf(item);

            return Expanded(
              child: _ChartStyleCard(
                icon: item['icon'] as IconData,
                label: item['label'] as String,
                isSelected: isSelected,
                hasMarginRight: index < 2,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onStyleChanged(style);
                },
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCompactSelector(List<Map<String, dynamic>> styles) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            styles.map((item) {
              final style = item['style'] as ChartStyle;
              final isSelected = currentStyle == style;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onStyleChanged(style);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? _accentPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 14,
                          color: isSelected ? _bgPrimary : _textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item['shortLabel'] as String,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? _bgPrimary : _textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

/// Individual card for each chart style option
class _ChartStyleCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool hasMarginRight;
  final VoidCallback onTap;

  const _ChartStyleCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.hasMarginRight,
    required this.onTap,
  });

  @override
  State<_ChartStyleCard> createState() => _ChartStyleCardState();
}

class _ChartStyleCardState extends State<_ChartStyleCard> {
  bool _isPressed = false;

  static const _surfaceColor = Color(0xFF1A1625);
  static const _borderColor = Color(0xFF2A2438);
  static const _accentPrimary = Color(0xFFD4AF37);
  static const _textMuted = Color(0xFF6B6478);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.only(right: widget.hasMarginRight ? 8 : 0),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient:
                widget.isSelected
                    ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _accentPrimary.withOpacity(0.15),
                        _accentPrimary.withOpacity(0.05),
                      ],
                    )
                    : null,
            color: widget.isSelected ? null : _surfaceColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  widget.isSelected
                      ? _accentPrimary.withOpacity(0.3)
                      : _borderColor.withOpacity(0.25),
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      widget.isSelected
                          ? _accentPrimary.withOpacity(0.15)
                          : _borderColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: widget.isSelected ? _accentPrimary : _textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: widget.isSelected ? _accentPrimary : _textMuted,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
