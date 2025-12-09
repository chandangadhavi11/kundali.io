# Onboarding Screen

## Overview
The Onboarding Screen introduces new users to the key features of the Kundali app through an animated, swipeable carousel.

## Features
- 3-page introduction carousel
- Animated transitions between pages
- Skip functionality
- Responsive layout for all screen sizes
- Custom background patterns per page
- Progress indicators

## Pages
1. **Generate Your Kundli** - Birth chart creation feature
2. **Daily Panchang & Horoscope** - Daily predictions and timings
3. **AI Astrologer** - AI-powered guidance feature

## Responsive Breakpoints
| Screen Size | Width |
|-------------|-------|
| Mobile | < 600px |
| Tablet | 600px - 900px |
| Desktop | > 900px |

## Layouts
- **Vertical Layout** - Mobile and portrait tablet
- **Horizontal Layout** - Landscape tablets and desktop

## UI Components
- Animated icons with custom background patterns
- Page indicators with smooth transitions
- Skip button
- Previous/Next navigation buttons
- "Get Started" button on final page

## Navigation
| Action | Route |
|--------|-------|
| Skip | `/home` |
| Get Started | `/home` |

## Animations
- Page transition animations
- Icon scale animations
- Fade and slide animations for text
- Custom pattern painters (circles, waves, stars)

## State Management
Saves onboarding completion status to `SharedPreferences`.

## File
- `onboarding_screen.dart` - Main screen widget

## Dependencies
- `go_router` - Navigation
- `shared_preferences` - Persistence





