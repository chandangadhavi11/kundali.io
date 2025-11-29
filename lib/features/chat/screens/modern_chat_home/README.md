# Modern Chat Home Screen

## Overview
The Modern Chat Home Screen serves as the main hub for chat features, including AI chat and astrologer marketplace access.

## Features
- Tab-based navigation (AI Assistant, Astrologers, History)
- Search functionality with animations
- Responsive layout system
- Chat history management
- Astrologer marketplace integration
- Floating action button for new chat
- Swipe gestures support

## Responsive Breakpoints
| Screen Size | Width |
|-------------|-------|
| Mobile | < 600px |
| Tablet | 600px - 900px |
| Desktop | 900px - 1200px |
| Large Desktop | > 1800px |

## Chat Hub Layouts
| Layout | Description |
|--------|-------------|
| Single | Mobile - single view |
| Drawer | Tablet portrait - drawer list |
| Split | Tablet landscape - split view |
| Desktop | Desktop - full split with sidebar |

## Tabs
1. **AI Assistant** - Chat with AI astrologer
2. **Astrologers** - Browse marketplace
3. **History** - Chat history view

## UI Components
- Custom tab bar with badges
- Search bar with animations
- Chat list with avatars
- Floating action button
- Header with user info

## Integrated Views
- `AstrologersMarketplaceView` - Browse astrologers
- `ChatHistoryView` - View past conversations

## Animations
- Header animation
- Floating button animation
- Search bar animation
- List item animations
- Swipe gesture animations

## File
- `modern_chat_home_screen.dart` - Main hub screen widget

## Dependencies
- Custom widgets from `../widgets/`
- `app_colors.dart` - Theme colors

