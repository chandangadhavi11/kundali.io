# Main Navigation Screen

## Overview
The Main Navigation Screen provides the primary navigation shell for the app, wrapping content with responsive navigation UI.

## Features
- Multi-style bottom navigation (mobile)
- Navigation rail (tablet)
- Drawer navigation (desktop)
- Route-based index tracking
- Badge support for notifications
- Navigation mode transitions

## Responsive Breakpoints
| Screen Size | Width |
|-------------|-------|
| Mobile | < 600px |
| Tablet | 600px - 900px |
| Desktop | > 900px |

## Navigation Modes
| Mode | Description |
|------|-------------|
| Bottom Bar | Mobile - fixed bottom navigation |
| Rail | Tablet portrait - side rail |
| Extended Rail | Tablet landscape - expanded rail |
| Drawer | Desktop - full drawer navigation |

## Bottom Navigation Styles
1. **Modern** - Clean Material 3 style
2. **Floating** - Elevated floating bar
3. **Curved** - Curved notch design

## Navigation Items
| Index | Label | Icon | Route | Badge |
|-------|-------|------|-------|-------|
| 0 | Home | home | /home | - |
| 1 | Horoscope | stars | /horoscope | - |
| 2 | Panchang | calendar | /panchang | - |
| 3 | Chat | chat_bubble | /chat | 3 |
| 4 | Profile | person | /profile | - |

## UI Components
- Conditional bottom navigation bar
- Navigation rail with header/footer
- Full drawer with header
- Nav style toggle (mobile only)
- Badge indicators

## Animations
- Page transition fade
- Rail expand/collapse
- Mode transition
- Content shift

## File
- `main_navigation_screen.dart` - Shell navigation widget

## Dependencies
- `go_router` - Navigation
- Custom navigation widgets from `shared/widgets`





