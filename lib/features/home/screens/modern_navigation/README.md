# Modern Navigation Screen

## Overview
An alternative navigation shell with modern Material 3 design, multiple style options, and enhanced animations.

## Features
- Multiple navigation styles (Modern, Glassmorphism, Neomorphism, Gradient)
- Responsive layout system
- Gesture-based navigation
- Animated background patterns
- Custom color per navigation item
- Tab controller integration

## Responsive Breakpoints
| Screen Size | Width |
|-------------|-------|
| Mobile | < 600px |
| Tablet | 600px - 900px |
| Desktop | 900px - 1200px |
| Large Desktop | > 1800px |

## Navigation Modes
| Mode | Description |
|------|-------------|
| Floating | Mobile - floating bottom bar |
| Docked | Tablet portrait - docked bottom |
| Top Tabs | Tablet landscape - top tab bar |
| Sidebar | Desktop - side navigation |

## Navigation Styles
| Style | Effect |
|-------|--------|
| Modern | Clean Material 3 design |
| Glassmorphism | Blurred glass effect |
| Neomorphism | Soft UI shadows |
| Gradient | Color gradient background |

## Navigation Items
| Label | Icon | Route | Color |
|-------|------|-------|-------|
| Home | home | /home | #6C5CE7 |
| Horoscope | auto_awesome | /horoscope | #FF6B6B |
| Panchang | calendar_month | /panchang | #4ECDC4 |
| Chat | forum | /chat | #FFD93D |
| Profile | account_circle | /profile | #A8E6CF |

## UI Components
- Style-specific navigation bars
- Animated background pattern painter
- Tab bar with badges
- Full sidebar with header
- Search and notification buttons

## Animations
- Page transition (fade, slide, scale)
- Navigation bar entrance
- Background pattern
- Swipe gesture handling

## File
- `modern_navigation_screen.dart` - Modern shell widget

## Dependencies
- `go_router` - Navigation

