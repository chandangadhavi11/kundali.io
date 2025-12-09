import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import '../shared/constants.dart';
import 'dasha/vimshottari_dasha_view.dart';
import 'dasha/mahadasha_phala_view.dart';
import 'dasha/yogini_dasha_view.dart';
import 'dasha/char_dasha_view.dart';
import 'dasha/dasha_shared_widgets.dart';

/// Dasha Tab - Multi-Dasha system with premium type selector
/// Supports Vimshottari, Mahadasha Phala, Yogini, and Char (Jaimini) Dasha systems
class DashaTab extends StatefulWidget {
  final KundaliData kundaliData;

  const DashaTab({super.key, required this.kundaliData});

  @override
  State<DashaTab> createState() => _DashaTabState();
}

class _DashaTabState extends State<DashaTab> with SingleTickerProviderStateMixin {
  DashaType _selectedType = DashaType.vimshottari;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _selectDashaType(DashaType type) {
    if (type == _selectedType) return;
    
    HapticFeedback.selectionClick();
    _animController.reverse().then((_) {
      setState(() => _selectedType = type);
      _animController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Premium Dasha Type Selector
        _DashaTypeSelector(
          selectedType: _selectedType,
          onSelect: _selectDashaType,
        ),
        
        // Content with animation
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildCurrentView(),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentView() {
    switch (_selectedType) {
      case DashaType.vimshottari:
        return VimshottariDashaView(kundaliData: widget.kundaliData);
      case DashaType.mahadashaPhala:
        return MahadashaPhalaView(kundaliData: widget.kundaliData);
      case DashaType.yogini:
        return YoginiDashaView(kundaliData: widget.kundaliData);
      case DashaType.char:
        return CharDashaView(kundaliData: widget.kundaliData);
    }
  }
}

/// Premium Dasha Type Selector - Pill-style switcher
class _DashaTypeSelector extends StatelessWidget {
  final DashaType selectedType;
  final ValueChanged<DashaType> onSelect;

  const _DashaTypeSelector({
    required this.selectedType,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: KundliDisplayColors.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KundliDisplayColors.borderColor.withOpacity(0.4),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: DashaType.values.map((type) {
          final isSelected = type == selectedType;
          return Expanded(
            child: _DashaTypeChip(
              type: type,
              isSelected: isSelected,
              onTap: () => onSelect(type),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DashaTypeChip extends StatefulWidget {
  final DashaType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _DashaTypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_DashaTypeChip> createState() => _DashaTypeChipState();
}

class _DashaTypeChipState extends State<_DashaTypeChip> {
  bool _isPressed = false;

  Color get _typeColor {
    switch (widget.type) {
      case DashaType.vimshottari:
        return DashaTypeColors.vimshottariPrimary;
      case DashaType.mahadashaPhala:
        return DashaTypeColors.phalaPrimary;
      case DashaType.yogini:
        return DashaTypeColors.yoginiPrimary;
      case DashaType.char:
        return DashaTypeColors.charPrimary;
    }
  }

  String get _typeIcon {
    switch (widget.type) {
      case DashaType.vimshottari:
        return '☽'; // Moon - Nakshatra based
      case DashaType.mahadashaPhala:
        return '✦'; // Star - Predictions
      case DashaType.yogini:
        return '✧'; // Star - Divine feminine
      case DashaType.char:
        return '♈'; // Zodiac - Sign based
    }
  }

  String _getSubtitle() {
    switch (widget.type) {
      case DashaType.vimshottari:
        return '120y cycle';
      case DashaType.mahadashaPhala:
        return 'Predictions';
      case DashaType.yogini:
        return '36y cycle';
      case DashaType.char:
        return 'Jaimini';
    }
  }

  @override
  Widget build(BuildContext context) {
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
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _typeColor.withOpacity(0.2),
                      _typeColor.withOpacity(0.08),
                    ],
                  )
                : null,
            color: widget.isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: widget.isSelected
                ? Border.all(color: _typeColor.withOpacity(0.4), width: 1)
                : null,
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: _typeColor.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: widget.isSelected ? 16 : 14,
                      color: widget.isSelected
                          ? _typeColor
                          : KundliDisplayColors.textMuted,
                    ),
                    child: Text(_typeIcon),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.type.displayName,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: widget.isSelected
                          ? _typeColor
                          : KundliDisplayColors.textMuted,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              if (widget.isSelected) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getSubtitle(),
                    style: GoogleFonts.dmMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: _typeColor.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
