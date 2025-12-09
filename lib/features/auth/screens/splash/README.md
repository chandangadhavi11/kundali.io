# Splash Screen

## Overview
The Splash Screen displays the app branding while initializing the application and determining the user's navigation destination.

## Features
- Animated logo display
- Cosmic gradient background
- Auto-navigation based on user state
- App initialization

## UI Components
- Animated logo with circular container
- App name with display typography
- Tagline text
- Cosmic gradient background

## Animations
- Fade animation (0-50% of duration)
- Scale animation with easeOutBack curve (0-50% of duration)
- 2-second total animation duration

## Navigation Logic
| Condition | Destination |
|-----------|-------------|
| Onboarding not completed | `/onboarding` |
| Onboarding completed | `/home` |

## State Checks
1. Waits for splash duration (defined in AppConstants)
2. Checks SharedPreferences for onboarding completion
3. Initializes AuthProvider
4. Navigates to appropriate screen

## Styling
- Cosmic gradient background from AppColors
- White surface for logo container
- Primary color for star icon
- Centered layout

## File
- `splash_screen.dart` - Main screen widget

## Dependencies
- `go_router` - Navigation
- `provider` - State management
- `shared_preferences` - Persistence

## Constants Used
- `AppConstants.splashDuration` - Wait time before navigation
- `AppConstants.onboardingKey` - SharedPreferences key
- `AppConstants.appName` - App display name
- `AppColors.cosmicGradient` - Background gradient





