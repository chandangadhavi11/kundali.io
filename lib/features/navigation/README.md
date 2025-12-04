# Navigation Feature

## Overview
Provides the main app shell with responsive navigation UI that adapts to different screen sizes.

## Screen
- `main_navigation_screen.dart` - Shell wrapper for all main tab screens

## Navigation Items

| Index | Label | Icon | Route |
|-------|-------|------|-------|
| 0 | Home | home | `/home` |
| 1 | Horoscope | stars | `/horoscope` |
| 2 | Panchang | calendar | `/panchang` |
| 3 | Chat | chat_bubble | `/chat` |
| 4 | Profile | person | `/profile` |

## Responsive Breakpoints

| Screen Size | Width | Navigation Mode |
|-------------|-------|-----------------|
| Mobile | < 600px | Bottom Bar |
| Tablet Portrait | 600-900px | Navigation Rail |
| Tablet Landscape | 900-1200px | Extended Rail |
| Desktop | > 1200px | Drawer |

## Bottom Navigation Styles (Mobile)
1. **Modern** - Clean Material 3 style
2. **Floating** - Elevated floating bar
3. **Curved** - Curved notch design

## Features
- Multi-style bottom navigation
- Navigation rail with expand/collapse
- Full drawer navigation for desktop
- Badge support for notifications
- Smooth mode transitions
- Route-based index tracking



