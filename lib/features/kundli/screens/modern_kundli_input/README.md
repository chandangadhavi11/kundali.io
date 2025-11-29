# Modern Kundli Input Screen

## Overview
Full-featured modern Kundali input form with Material 3 design and comprehensive birth details collection.

## Features
- Multi-step form wizard
- Auto-generate from profile
- Location search with geocoding
- Timezone auto-detection
- Date/time pickers with custom styling
- Form validation
- Authentication check for saving

## Form Steps
1. **Personal Info** - Name and gender
2. **Birth Date** - Date selection
3. **Birth Time** - Time selection with time zone
4. **Birth Place** - Location with coordinates

## Form Fields
| Field | Type | Required |
|-------|------|----------|
| Name | Text | Yes |
| Gender | Selection | Yes |
| Birth Date | Date Picker | Yes |
| Birth Time | Time Picker | Yes |
| Birth Place | Location Search | Yes |
| Latitude | Auto-filled | Yes |
| Longitude | Auto-filled | Yes |
| Timezone | Auto-detected | Yes |

## UI Components
- Floating action button for quick actions
- Stepper navigation
- Custom date/time pickers
- Location search with suggestions
- Gender selection chips
- Generate button with loading state

## State Management
- Uses `KundliProvider` for generation
- Uses `AuthProvider` for user profile
- Form state management

## Navigation
After generation → `ModernKundliDisplayScreen`

## File
- `modern_kundli_input_screen.dart` - Main input form widget

## Dependencies
- `provider` - State management
- `intl` - Date formatting
- `app_colors.dart` - Theme colors

