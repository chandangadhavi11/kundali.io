# Home Screen

## Overview
The Home Screen is the main landing page of the app, displaying personalized content and quick access to key features.

## Features
- Personalized greeting with time-based messages
- Daily horoscope preview
- Quick action feature grid
- Real-time clock display
- Guest mode sign-in prompt
- Pull-to-refresh functionality

## Greeting Logic
| Time | Greeting |
|------|----------|
| 00:00 - 11:59 | Good Morning |
| 12:00 - 16:59 | Good Afternoon |
| 17:00 - 20:59 | Good Evening |
| 21:00 - 23:59 | Good Night |

## Feature Grid
| Feature | Icon | Route | Color |
|---------|------|-------|-------|
| Generate Kundali | chart_pie_fill | /kundli | Purple |
| Match Making | heart_circle_fill | /matchmaking | Red |
| Horoscope | star_circle_fill | /horoscope | Teal |
| Panchang | calendar_circle_fill | /panchang | Orange |
| AI Astrologer | chat_bubble_2_fill | /chat | Green |
| Learn | book_fill | /learn | Purple |

## UI Components
- Floating app bar with Pro badge
- Greeting section with user name and emoji
- Date card with current date info
- Guest mode sign-in card
- Today's Insights section header
- Compact horoscope card with zodiac colors
- Lucky elements chips (mood, color, number)
- 3x2 feature grid

## Zodiac Colors
Each zodiac sign has a unique accent color for personalization.

## State Management
- Uses `AuthProvider` for user data
- Uses `HoroscopeProvider` for daily predictions
- Uses `PanchangProvider` for daily timings

## Animations
- Fade animation for header
- Slide animations for content
- Pulse animation for horoscope card
- Staggered animations for grid items

## File
- `home_screen.dart` - Main home screen widget

## Dependencies
- `go_router` - Navigation
- `provider` - State management
- `intl` - Date formatting

