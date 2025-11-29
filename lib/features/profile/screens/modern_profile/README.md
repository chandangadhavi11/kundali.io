# Modern Profile Screen

## Overview
Full-featured user profile screen with animated sections and comprehensive account management.

## Features
- Profile header with avatar
- Quick action buttons
- Menu sections with icons
- Animated transitions
- Scroll-based header effects
- Logout functionality

## UI Components
- Profile header (name, email, avatar)
- Quick actions section
- Menu sections (Account, Content, Preferences)
- Animated list items
- Floating elements

## Integrated Widgets
- `ProfileHeader` - Header section
- `ProfileMenuSection` - Menu groups
- `QuickActionsSection` - Action buttons

## Menu Items
### Account Section
- My Kundlis
- Saved Charts
- Subscription
- Edit Profile

### Content Section
- History
- Favorites
- Downloads

### Preferences
- Settings
- Help & Support
- About

## State Management
Uses `AuthProvider` for user data.

## Animations
- Header animation
- Menu item staggered animations
- Floating element animation
- Scroll-based parallax

## File
- `modern_profile_screen.dart` - Main profile widget

## Dependencies
- `provider` - State management
- `go_router` - Navigation
- Custom widgets from `../widgets/`

