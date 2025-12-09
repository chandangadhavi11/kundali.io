# Profile Setup Screen

## Overview
The Profile Setup Screen guides users through completing their profile with birth details required for astrological calculations.

## Features
- Multi-step form wizard
- Progress bar indicator
- Photo upload (placeholder)
- Birth details collection
- Interest selection
- Responsive design

## Setup Steps
1. **Photo** - Profile photo and optional bio
2. **Birth Details** - Date, time, place, and gender
3. **Interests** - Select astrological interests

## Responsive Breakpoints
| Screen Size | Width |
|-------------|-------|
| Mobile | < 600px |
| Tablet | 600px - 900px |
| Desktop | > 900px |

## UI Components
- Progress bar with animated transitions
- Profile photo picker
- Date picker with themed styling
- Time picker with themed styling
- Location input field
- Gender dropdown
- Interest selection grid

## Form Fields
| Field | Type | Required |
|-------|------|----------|
| Profile Photo | Image | No |
| Bio | Text (max 200 chars) | No |
| Birth Date | Date | Yes |
| Birth Time | Time | Yes |
| Birth Place | Text | Yes |
| Gender | Dropdown | No |
| Interests | Multi-select | No |

## Available Interests
- Vedic Astrology
- Western Astrology
- Numerology
- Tarot
- Palmistry
- Vastu
- Gemstones
- Meditation
- Yoga
- Spirituality
- Career
- Love & Relationships
- Health
- Finance
- Family
- Education

## Navigation
| Action | Route |
|--------|-------|
| Complete | `/home` |

## State Management
Uses `AuthProvider` to update user profile.

## Calculations
- Automatic zodiac sign calculation from birth date

## File
- `profile_setup_screen.dart` - Main screen widget

## Dependencies
- `go_router` - Navigation
- `provider` - State management
- `intl` - Date formatting





