# Details Tab Design System Guide

This document captures the complete design system, components, and patterns used in `details_tab.dart` to help maintain consistency across all Kundali display tabs.

---

## Table of Contents

1. [Design Tokens](#1-design-tokens)
2. [Color System](#2-color-system)
3. [Typography](#3-typography)
4. [Component Architecture](#4-component-architecture)
5. [Animation Patterns](#5-animation-patterns)
6. [Interactive Insight System](#6-interactive-insight-system)
7. [Card Components](#7-card-components)
8. [Reusable Widgets](#8-reusable-widgets)
9. [Helper Functions](#9-helper-functions)
10. [Navigation System](#10-navigation-system)
11. [Image Assets](#11-image-assets)
12. [Best Practices](#12-best-practices)

---

## 1. Design Tokens

The design system uses a `_DesignTokens` class with a private constructor to prevent instantiation.

### Spacing Scale

```dart
class _DesignTokens {
  _DesignTokens._();

  // Spacing scale (in logical pixels)
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space6 = 6;
  static const double space8 = 8;
  static const double space10 = 10;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
}
```

### Border Radius

```dart
// Border radius scale
static const double radiusSm = 8;   // Small elements, chips, badges
static const double radiusMd = 12;  // Medium elements, inner containers
static const double radiusLg = 16;  // Cards, main containers
```

### Shadows

```dart
// Subtle ambient shadow for elevated surfaces
static List<BoxShadow> get shadowSm => [
  BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 4,
    offset: const Offset(0, 2),
  ),
];
```

### Animation Constants

```dart
// Animation curves and durations
static const Duration durationFast = Duration(milliseconds: 150);
static const Curve curveStandard = Curves.easeOutCubic;
```

---

## 2. Color System

The color system uses a `_Colors` class with semantic color groups.

### Surface Colors (Dark Theme)

```dart
class _Colors {
  _Colors._();

  // Background & Surfaces (darkest to lightest)
  static const Color bgSecondary = Color(0xFF100E17);      // Deepest background
  static const Color surface = Color(0xFF16141F);          // Card background
  static const Color surfaceElevated = Color(0xFF1C1A26);  // Elevated elements
}
```

### Border Colors

```dart
// Borders (subtle separation)
static const Color border = Color(0xFF2A2838);        // Standard border
static const Color borderSubtle = Color(0xFF1E1C28); // Very subtle border
```

### Text Colors

```dart
// Text hierarchy (brightest to dimmest)
static const Color textPrimary = Color(0xFFF5F4F8);    // Main text, headings
static const Color textSecondary = Color(0xFFA09CAC); // Secondary info
static const Color textTertiary = Color(0xFF6E6A7A);  // Labels, hints
```

### Accent Colors

```dart
// Accent colors - muted and sophisticated
static const Color gold = Color(0xFFCFAE54);     // Lucky elements, premium
static const Color violet = Color(0xFF9580FF);   // Profile, primary accent
static const Color emerald = Color(0xFF4ADE80);  // Panchang, positive states
static const Color rose = Color(0xFFF472B6);     // Nakshatra, birth star
static const Color sky = Color(0xFF38BDF8);      // Dasha, periods
static const Color amber = Color(0xFFFBBF24);    // Warnings, retrograde
static const Color coral = Color(0xFFF87171);    // Guna, debilitated
static const Color teal = Color(0xFF2DD4BF);     // Planets, status
```

### Color Usage Guidelines

| Color   | Primary Use                        | Opacity Variants       |
|---------|------------------------------------|-----------------------|
| Violet  | Profile section, primary actions   | 0.08, 0.1, 0.15, 0.2 |
| Rose    | Nakshatra, birth star elements     | 0.1, 0.12, 0.2       |
| Emerald | Panchang, positive/exalted states  | 0.08, 0.1, 0.15      |
| Sky     | Dasha periods, time-related        | 0.1, 0.15, 0.25      |
| Coral   | Guna factors, debilitated states   | 0.08, 0.12, 0.15     |
| Gold    | Lucky elements, premium features   | 0.1, 0.2, 0.3        |
| Teal    | Planetary status, general info     | 0.08, 0.15, 0.2      |
| Amber   | Retrograde, warnings               | 0.1, 0.15, 0.25      |

---

## 3. Typography

All typography uses Google Fonts (Inter for UI, JetBrains Mono for data).

### Text Styles

```dart
// Extra small label (uppercase labels, hints)
static TextStyle get labelXs => GoogleFonts.inter(
  fontSize: 10,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.3,
  color: _Colors.textTertiary,
);

// Small label (secondary labels)
static TextStyle get labelSm => GoogleFonts.inter(
  fontSize: 11,
  fontWeight: FontWeight.w500,
  color: _Colors.textSecondary,
);

// Small body text (values, content)
static TextStyle get bodySm => GoogleFonts.inter(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: _Colors.textPrimary,
);

// Small title (tile headings)
static TextStyle get titleSm => GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: _Colors.textPrimary,
);

// Medium title (card headings)
static TextStyle get titleMd => GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: _Colors.textPrimary,
);

// Monospace (degrees, coordinates)
static TextStyle get mono => GoogleFonts.jetBrainsMono(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: _Colors.textSecondary,
);
```

### Typography Patterns

```dart
// Uppercase section headers
Text(
  'SECTION TITLE',
  style: GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: _Colors.textTertiary, // or accent color when highlighted
  ),
)

// Large display values
Text(
  'Value',
  style: GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: _Colors.textPrimary,
    letterSpacing: -0.5,
  ),
)

// Date formatting
Text(
  '${dt.day} ${months[dt.month - 1]} ${dt.year}',
  style: GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: _Colors.textPrimary,
    letterSpacing: -0.3,
  ),
)
```

---

## 4. Component Architecture

### Main Tab Structure

```dart
class YourTab extends StatefulWidget {
  final KundaliData kundaliData;
  
  const YourTab({super.key, required this.kundaliData});
  
  @override
  State<YourTab> createState() => _YourTabState();
}

class _YourTabState extends State<YourTab> {
  late final ScrollController _scrollController;
  final Map<String, GlobalKey> _sectionKeys = {};
  final Map<String, GlobalKey<_AnimatedSectionWrapperState>> _animatedKeys = {};
  int _activeIndex = 0;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Initialize keys for each section
    for (final section in _sections) {
      _sectionKeys[section.id] = GlobalKey();
      _animatedKeys[section.id] = GlobalKey<_AnimatedSectionWrapperState>();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Scrollable content
        SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sections with animated wrappers
              _AnimatedSectionWrapper(
                key: _animatedKeys['sectionId'],
                sectionKey: _sectionKeys['sectionId']!,
                accentColor: _Colors.violet,
                child: _YourSectionCard(data: widget.kundaliData),
              ),
              // More sections...
            ],
          ),
        ),
        
        // Floating navigation bar
        Positioned(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          child: FloatingNavBar(
            sections: _sections,
            activeIndex: _activeIndex,
            onTap: _scrollToSection,
          ),
        ),
      ],
    );
  }
}
```

### Section Structure Pattern

```dart
_AnimatedSectionWrapper(
  key: _animatedKeys['sectionId'],
  sectionKey: _sectionKeys['sectionId']!,
  accentColor: _Colors.emerald,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _AnimatedSectionHeader(
        title: 'Section Title',
        accentColor: _Colors.emerald,
      ),
      const SizedBox(height: _DesignTokens.space12),
      _AnimatedCardWrapper(
        delay: 50, // Stagger animation delay in ms
        child: _YourContentCard(data: data),
      ),
    ],
  ),
),
```

---

## 5. Animation Patterns

### Animated Section Wrapper

Provides highlight effect when scrolled to via nav bar.

```dart
class _AnimatedSectionWrapper extends StatefulWidget {
  final GlobalKey sectionKey;
  final Color accentColor;
  final Widget child;

  const _AnimatedSectionWrapper({
    super.key,
    required this.sectionKey,
    required this.accentColor,
    required this.child,
  });

  @override
  State<_AnimatedSectionWrapper> createState() => _AnimatedSectionWrapperState();
}

class _AnimatedSectionWrapperState extends State<_AnimatedSectionWrapper> {
  bool _isHighlighted = false;

  void triggerHighlight() {
    HapticFeedback.lightImpact();
    setState(() => _isHighlighted = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isHighlighted = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SectionAnimationProvider(
      isHighlighted: _isHighlighted,
      accentColor: widget.accentColor,
      child: Container(key: widget.sectionKey, child: widget.child),
    );
  }
}
```

### Animated Section Header

Underline sweep + text color pulse animation.

```dart
class _AnimatedSectionHeader extends StatefulWidget {
  final String title;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final textPulse = _textPulseAnimation.value;
        final underlineWidth = _underlineAnimation.value;

        final textColor = Color.lerp(
          _Colors.textTertiary,
          widget.accentColor,
          textPulse * 0.8,
        )!;

        return Padding(
          padding: const EdgeInsets.only(left: _DesignTokens.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              // Animated underline
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = math.min(constraints.maxWidth * 0.3, 40.0);
                  return Container(
                    height: 2,
                    width: maxWidth * underlineWidth,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.6 + textPulse * 0.4),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### Animated Card Wrapper

Scale pop + shadow lift animation on section highlight.

```dart
class _AnimatedCardWrapper extends StatefulWidget {
  final Widget child;
  final int delay; // Stagger delay in milliseconds

  const _AnimatedCardWrapper({required this.child, this.delay = 0});
}

// Animation values:
// - Scale: 1.0 → 1.025 → 1.0 (elastic overshoot)
// - Shadow: 0.0 → 1.0 → 0.0 (accent color glow)
```

### Interactive Press Animation

Standard pattern for tappable elements.

```dart
class _InteractiveWidget extends StatefulWidget {
  @override
  State<_InteractiveWidget> createState() => _InteractiveWidgetState();
}

class _InteractiveWidgetState extends State<_InteractiveWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100), // or 150ms for larger items
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97, // or 0.96-0.98 depending on size
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact(); // or selectionClick() for smaller items
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    // Trigger action
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                // Change color/border on press
                color: _isPressed 
                    ? accentColor.withOpacity(0.08) 
                    : _Colors.bgSecondary,
                border: Border.all(
                  color: _isPressed
                      ? accentColor.withOpacity(0.3)
                      : _Colors.borderSubtle,
                ),
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
```

---

## 6. Interactive Insight System

### Insight Data Model

```dart
class InsightData {
  final String title;           // Category label (e.g., "Rising Sign")
  final String value;           // Main value (e.g., "Aries")
  final String description;     // Detailed explanation
  final String significance;    // Why it matters
  final List<String> keyPoints; // Bullet points
  final Color accentColor;      // Theme color
  final IconData icon;          // Fallback icon
  final String? imagePath;      // Optional image asset

  const InsightData({
    required this.title,
    required this.value,
    required this.description,
    required this.significance,
    required this.keyPoints,
    required this.accentColor,
    required this.icon,
    this.imagePath,
  });
}
```

### Showing Insight Bottom Sheet

```dart
void _showInsightSheet(BuildContext context, InsightData insight) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (context) => _InsightBottomSheet(insight: insight),
  );
}
```

### Insight Bottom Sheet Design

```dart
class _InsightBottomSheet extends StatefulWidget {
  final InsightData insight;
  
  // Animations:
  // - Slide up from bottom (0.3 → 0.0 offset)
  // - Fade in (0.0 → 1.0 opacity)
  // - Duration: 400ms with easeOutCubic
}

// Layout:
// 1. Handle bar with accent glow
// 2. Header: Icon/Image + Title label + Value
// 3. Gradient divider
// 4. "What This Means" section with description
// 5. Significance card with icon
// 6. Key Points list with colored bullets
```

### Bottom Sheet Styling

```dart
Container(
  constraints: BoxConstraints(
    maxHeight: MediaQuery.of(context).size.height * 0.75,
  ),
  decoration: BoxDecoration(
    color: _Colors.surface,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    border: Border(
      top: BorderSide(
        color: insight.accentColor.withOpacity(0.3),
        width: 1,
      ),
    ),
    boxShadow: [
      BoxShadow(
        color: insight.accentColor.withOpacity(0.15),
        blurRadius: 40,
        spreadRadius: -10,
        offset: const Offset(0, -10),
      ),
    ],
  ),
)
```

### Insight Generator Functions

Create these for your specific data types:

```dart
InsightData _getYourDataInsight(String value, /* other params */) {
  return InsightData(
    title: 'Category',
    value: value,
    description: 'Detailed explanation about $value...',
    significance: 'Why this matters...',
    keyPoints: [
      'First key point',
      'Second key point',
      'Third key point',
      'Fourth key point',
    ],
    accentColor: _getRelevantColor(value),
    icon: Icons.relevant_icon,
    imagePath: _getImagePath(value), // optional
  );
}
```

---

## 7. Card Components

### Base Card Component

```dart
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const _Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(_DesignTokens.space16),
      decoration: BoxDecoration(
        color: _Colors.surface,
        borderRadius: BorderRadius.circular(_DesignTokens.radiusLg),
        border: Border.all(color: _Colors.borderSubtle, width: 1),
        boxShadow: _DesignTokens.shadowSm,
      ),
      child: child,
    );
  }
}
```

### Card with Header Row Pattern

```dart
_Card(
  child: Column(
    children: [
      // Header row with image/icon, title, and status chip
      Row(
        children: [
          // Image/Icon container (48-56px)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(_DesignTokens.radiusMd),
            ),
            child: /* Image or Icon */,
          ),
          const SizedBox(width: _DesignTokens.space12),
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _DesignTokens.titleMd),
                const SizedBox(height: _DesignTokens.space2),
                Text(subtitle, style: _DesignTokens.labelSm),
              ],
            ),
          ),
          // Status chip
          _StatusChip(label: status, color: statusColor),
        ],
      ),
      
      const SizedBox(height: _DesignTokens.space16),
      
      // Details section
      Container(
        padding: const EdgeInsets.all(_DesignTokens.space12),
        decoration: BoxDecoration(
          color: _Colors.bgSecondary,
          borderRadius: BorderRadius.circular(_DesignTokens.radiusMd),
        ),
        child: /* Details content */,
      ),
    ],
  ),
)
```

### Grid Layout Pattern

```dart
// 2x2 grid of metric tiles
Column(
  children: [
    Row(
      children: [
        Expanded(child: _MetricTile(/* ... */)),
        const SizedBox(width: _DesignTokens.space8),
        Expanded(child: _MetricTile(/* ... */)),
      ],
    ),
    const SizedBox(height: _DesignTokens.space8),
    Row(
      children: [
        Expanded(child: _MetricTile(/* ... */)),
        const SizedBox(width: _DesignTokens.space8),
        Expanded(child: _MetricTile(/* ... */)),
      ],
    ),
  ],
)

// GridView for more items
GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: _DesignTokens.space8,
    crossAxisSpacing: _DesignTokens.space8,
    childAspectRatio: 2.2, // Adjust based on content
  ),
  itemCount: items.length,
  itemBuilder: (context, index) => _YourCell(item: items[index]),
)
```

### Horizontal Scroll List Pattern

```dart
SizedBox(
  height: 88, // Fixed height for consistency
  child: ListView.separated(
    scrollDirection: Axis.horizontal,
    physics: const BouncingScrollPhysics(),
    itemCount: items.length,
    separatorBuilder: (_, __) => const SizedBox(width: _DesignTokens.space8),
    itemBuilder: (context, index) {
      return _ItemChip(item: items[index], isActive: index == activeIndex);
    },
  ),
)
```

---

## 8. Reusable Widgets

### Status Chip

```dart
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _DesignTokens.space8,
        vertical: _DesignTokens.space4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(_DesignTokens.radiusSm),
      ),
      child: Text(
        label,
        style: _DesignTokens.labelXs.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

### Info Cell (for grids)

```dart
class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  final bool isPlanet; // Show planet image instead of text

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: _DesignTokens.labelXs),
          const SizedBox(height: _DesignTokens.space6),
          if (isPlanet) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [/* subtle shadow */],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(_getPlanetImagePath(value), /* ... */),
              ),
            ),
            const SizedBox(height: _DesignTokens.space4),
            Text(value, style: /* colored style */),
          ] else
            Text(value, style: _DesignTokens.bodySm, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
```

### Metric Tile (Interactive)

```dart
class _MetricTile extends StatefulWidget {
  final String label;
  final String value;
  final String sublabel;
  final Color color;
  final bool showZodiacImage;
  final bool showPlanetImage;
  final bool showElementImage;
  final VoidCallback? onTap;
}

// Layout:
// [Image 36x36] | [Label]
//               | [Value - colored]
//               | [Sublabel]
```

### Info Row (Compact)

```dart
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 13,
          color: isHighlighted ? _Colors.textSecondary : _Colors.textTertiary,
        ),
        const SizedBox(width: _DesignTokens.space6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isHighlighted ? FontWeight.w500 : FontWeight.w400,
              color: isHighlighted ? _Colors.textSecondary : _Colors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
```

### Period/Item Chip

```dart
class _PeriodChip extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: _DesignTokens.space8),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : _Colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color.withOpacity(0.25) : _Colors.borderSubtle,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image/Icon
          // Title
          // Subtitle
        ],
      ),
    );
  }
}
```

### Interactive Row Item

```dart
class _StatusRowItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<String> items;
  final Color color;
}

// Pattern:
// - Tap triggers insight sheet
// - Pressed state changes background color
// - Shows icon + label on left, items/images on right
// - Empty state shows "None" text
```

---

## 9. Helper Functions

### Symbol Getters

```dart
String _getSignSymbol(String sign) {
  const symbols = {
    'Aries': '♈', 'Taurus': '♉', 'Gemini': '♊', 'Cancer': '♋',
    'Leo': '♌', 'Virgo': '♍', 'Libra': '♎', 'Scorpio': '♏',
    'Sagittarius': '♐', 'Capricorn': '♑', 'Aquarius': '♒', 'Pisces': '♓',
  };
  return symbols[sign] ?? '?';
}

String _getPlanetSymbol(String planet) {
  const symbols = {
    'Sun': '☉', 'Moon': '☽', 'Mars': '♂', 'Mercury': '☿',
    'Jupiter': '♃', 'Venus': '♀', 'Saturn': '♄', 'Rahu': '☊', 'Ketu': '☋',
  };
  return symbols[planet] ?? '•';
}
```

### Color Functions

```dart
/// Planet colors based on actual image visual palette
Color _getPlanetColor(String planet) {
  const colors = {
    'Sun': Color(0xFFFF9500),      // Fiery orange/yellow
    'Moon': Color(0xFF9BC4E2),     // Silvery blue
    'Mars': Color(0xFFE84C30),     // Fiery red/orange
    'Mercury': Color(0xFF5CAD8A),  // Teal/green
    'Jupiter': Color(0xFFE8943A),  // Warm amber/orange
    'Venus': Color(0xFFF5A878),    // Soft peachy pink
    'Saturn': Color(0xFFD4943A),   // Golden orange
    'Rahu': Color(0xFF9B7BF7),     // Mystical purple
    'Ketu': Color(0xFF2DD4BF),     // Cyan/teal
  };
  return colors[planet] ?? _Colors.textSecondary;
}

/// Zodiac colors based on image visual palette
Color _getZodiacColor(String sign) {
  const colors = {
    'Aries': Color(0xFFD4A84B),     // Golden yellow
    'Taurus': Color(0xFF4ECDC4),    // Cool teal
    'Gemini': Color(0xFFE85A6B),    // Deep red/coral
    'Cancer': Color(0xFFB794F6),    // Lavender
    'Leo': Color(0xFFE07B4C),       // Burnt orange
    'Virgo': Color(0xFFF5A6C4),     // Soft pink
    'Libra': Color(0xFF6BCB77),     // Mint green
    'Scorpio': Color(0xFFD9652B),   // Dark orange
    'Sagittarius': Color(0xFFE040FB), // Magenta
    'Capricorn': Color(0xFFB8956B),  // Earthy brown
    'Aquarius': Color(0xFF40E0D0),   // Turquoise
    'Pisces': Color(0xFF64B5F6),     // Ocean blue
  };
  return colors[sign] ?? const Color(0xFFA09CAC);
}
```

### Image Path Functions

```dart
String _getZodiacImagePath(String sign) {
  return 'assets/images/zodiac/${sign.toLowerCase()}.png';
}

String _getPlanetImagePath(String planet) {
  return 'assets/images/planets/${planet.toLowerCase()}.png';
}

String _getElementImagePath(String element) {
  return 'assets/images/elements/${element.toLowerCase()}.png';
}

String _getGemstoneImagePath(String gemstone) {
  const paths = {
    'Ruby': 'assets/images/gemstones/ruby.png',
    'Pearl': 'assets/images/gemstones/pearl.png',
    // ... etc
  };
  return paths[gemstone] ?? 'assets/images/gemstones/pearl.png';
}
```

### Data Lookup Functions

```dart
String _getSignElement(String sign) {
  const elements = {
    'Aries': 'Fire', 'Taurus': 'Earth', 'Gemini': 'Air', 'Cancer': 'Water',
    'Leo': 'Fire', 'Virgo': 'Earth', 'Libra': 'Air', 'Scorpio': 'Water',
    'Sagittarius': 'Fire', 'Capricorn': 'Earth', 'Aquarius': 'Air', 'Pisces': 'Water',
  };
  return elements[sign] ?? 'Unknown';
}

String _getLagnaLord(String sign) {
  const lords = {
    'Aries': 'Mars', 'Taurus': 'Venus', 'Gemini': 'Mercury', 'Cancer': 'Moon',
    'Leo': 'Sun', 'Virgo': 'Mercury', 'Libra': 'Venus', 'Scorpio': 'Mars',
    'Sagittarius': 'Jupiter', 'Capricorn': 'Saturn', 'Aquarius': 'Saturn', 'Pisces': 'Jupiter',
  };
  return lords[sign] ?? 'Unknown';
}

// Add more lookup functions as needed for your tab's data
```

### Short Name Formatter

```dart
String _getShortPlanetName(String planet) {
  const shortNames = {
    'Sun': 'Sun', 'Moon': 'Moon', 'Mars': 'Mars', 'Mercury': 'Merc',
    'Jupiter': 'Jup', 'Venus': 'Venus', 'Saturn': 'Sat', 'Rahu': 'Rahu', 'Ketu': 'Ketu',
  };
  return shortNames[planet] ?? planet;
}
```

---

## 10. Navigation System

### Section Definition

```dart
// Define in floating_nav_bar.dart or locally
class NavSection {
  final String id;
  final String label;
  final Color color;

  const NavSection({
    required this.id,
    required this.label,
    required this.color,
  });
}

// Define sections for your tab
const _sections = [
  NavSection(id: 'section1', label: 'Section 1', color: _Colors.violet),
  NavSection(id: 'section2', label: 'Section 2', color: _Colors.rose),
  // ... more sections
];
```

### Scroll Detection

```dart
void _onScroll() {
  if (_isScrolling) return;

  final viewportHeight = _scrollController.position.viewportDimension;
  final triggerPoint = viewportHeight * 0.3;

  int newActiveIndex = 0;

  for (int i = 0; i < _sections.length; i++) {
    final key = _sectionKeys[_sections[i].id];
    if (key?.currentContext != null) {
      final box = key!.currentContext!.findRenderObject() as RenderBox?;
      if (box != null) {
        final position = box.localToGlobal(Offset.zero);
        if (position.dy <= triggerPoint + 100) {
          newActiveIndex = i;
        }
      }
    }
  }

  if (newActiveIndex != _activeIndex) {
    setState(() => _activeIndex = newActiveIndex);
  }
}
```

### Scroll to Section

```dart
Future<void> _scrollToSection(int index) async {
  final section = _sections[index];
  final key = _sectionKeys[section.id];

  if (key?.currentContext == null) return;

  HapticFeedback.lightImpact();

  setState(() {
    _isScrolling = true;
    _activeIndex = index;
  });

  await Scrollable.ensureVisible(
    key!.currentContext!,
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeOutCubic,
    alignment: 0.08, // ~8% margin from top
  );

  // Trigger highlight animation
  _animatedKeys[section.id]?.currentState?.triggerHighlight();

  setState(() => _isScrolling = false);
}
```

---

## 11. Image Assets

### Directory Structure

```
assets/images/
├── zodiac/
│   ├── aries.png
│   ├── taurus.png
│   ├── gemini.png
│   └── ... (12 zodiac signs)
├── planets/
│   ├── sun.png
│   ├── moon.png
│   ├── mars.png
│   └── ... (9+ planets)
├── elements/
│   ├── fire.png
│   ├── water.png
│   ├── earth.png
│   └── air.png
└── gemstones/
    ├── ruby.png
    ├── pearl.png
    └── ... (9 gemstones)
```

### Image Loading Pattern

```dart
Container(
  width: 36, // or 28, 40, 48, 52, 56, 64 depending on context
  height: 36,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10), // or 8, 12, 14, 16
    boxShadow: [
      // Ambient shadow
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 8,
        spreadRadius: -3,
        offset: const Offset(0, 3),
      ),
      // Color glow (use accent color)
      BoxShadow(
        color: accentColor.withOpacity(_isPressed ? 0.2 : 0.08),
        blurRadius: _isPressed ? 14 : 10,
        spreadRadius: -4,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Image.asset(
      imagePath,
      width: 36,
      height: 36,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to symbol/icon
        return Container(
          color: accentColor.withOpacity(0.1),
          child: Center(
            child: Text(
              fallbackSymbol,
              style: TextStyle(fontSize: 18, color: accentColor),
            ),
          ),
        );
      },
    ),
  ),
)
```

---

## 12. Best Practices

### 1. Always Use Design Tokens

```dart
// ✅ Good
padding: const EdgeInsets.all(_DesignTokens.space16)

// ❌ Bad
padding: const EdgeInsets.all(16)
```

### 2. Consistent Color Usage

```dart
// ✅ Good - use semantic colors
color: _Colors.textSecondary

// ❌ Bad - hardcoded colors
color: Color(0xFFA09CAC)
```

### 3. Haptic Feedback on Interactions

```dart
// Light impact for most taps
HapticFeedback.lightImpact();

// Selection click for smaller items
HapticFeedback.selectionClick();

// Medium impact for important actions (opening sheets)
HapticFeedback.mediumImpact();
```

### 4. Animation Duration Guidelines

| Interaction Type | Duration |
|-----------------|----------|
| Press feedback | 100ms |
| Container changes | 100-150ms |
| Sheet entry | 400ms |
| Section highlight | 500-600ms |
| Scroll to section | 400ms |

### 5. Image Shadow Patterns

```dart
// Standard shadow for images
boxShadow: [
  // Ambient (always present)
  BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 8-12,
    spreadRadius: -3 to -4,
    offset: Offset(0, 3-4),
  ),
  // Color glow (changes on press)
  BoxShadow(
    color: accentColor.withOpacity(isPressed ? 0.2-0.25 : 0.08-0.15),
    blurRadius: isPressed ? 12-16 : 8-10,
    spreadRadius: -2 to -4,
    offset: Offset(0, 2-3),
  ),
]
```

### 6. Section Spacing

```dart
// Between major sections
const SizedBox(height: _DesignTokens.space24)

// Between header and content
const SizedBox(height: _DesignTokens.space12)

// Between items in a group
const SizedBox(height: _DesignTokens.space8)
```

### 7. Bottom Padding for Floating Nav

```dart
// Main content padding
padding: const EdgeInsets.fromLTRB(16, 12, 16, 120)
// 120px bottom for floating nav bar clearance
```

### 8. Safe Area for Floating Elements

```dart
Positioned(
  left: 16,
  right: 16,
  bottom: MediaQuery.of(context).padding.bottom + 16,
  child: FloatingNavBar(/* ... */),
)
```

---

## Quick Reference: Creating a New Tab

1. **Copy the base structure** from DetailsTab
2. **Define your sections** with ids, labels, and colors
3. **Create section keys** for scroll navigation
4. **Build your cards** using the patterns above
5. **Add insight generators** for your data types
6. **Wrap sections** with AnimatedSectionWrapper
7. **Wrap cards** with AnimatedCardWrapper
8. **Add floating nav bar** at the bottom
9. **Test haptics and animations**

---

## Import Requirements

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kundali_app/shared/models/kundali_data_model.dart';
import '../shared/floating_nav_bar.dart';
// Add any additional services/models needed for your tab
```

