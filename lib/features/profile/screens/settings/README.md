# Settings Screen

## Overview
App settings screen for customizing preferences, notifications, and regional settings.

## Features
- Language selection
- Region/location settings
- Chart style preference
- Notification controls
- Dark mode toggle
- Quiet hours configuration
- Animated sections

## Settings Categories

### Language & Region
| Setting | Options |
|---------|---------|
| Language | English, Hindi, etc. |
| Region | North India, South India, etc. |
| Chart Style | North Indian, South Indian |

### Notifications
| Setting | Type |
|---------|------|
| Daily Horoscope | Toggle |
| Panchang Alerts | Toggle |
| Festival Reminders | Toggle |
| Dasha Change | Toggle |
| Quiet Hours | Time Range |

### Appearance
| Setting | Type |
|---------|------|
| Dark Mode | Toggle (via ThemeProvider) |

## UI Components
- Section headers with icons
- Toggle switches
- Dropdown selectors
- Time picker for quiet hours
- Animated section transitions

## State Management
Uses `ThemeProvider` for theme settings.

## Animations
- Staggered section animations
- Toggle animations

## File
- `settings_screen.dart` - Settings widget

## Dependencies
- `provider` - State management



