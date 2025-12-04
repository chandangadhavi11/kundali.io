# Auth Feature

## Overview
Handles user authentication flow including splash, onboarding, login, signup, and profile setup.

## Screens

| Screen | Route | Description |
|--------|-------|-------------|
| `splash_screen.dart` | `/splash` | Initial loading screen with app branding |
| `onboarding_screen.dart` | `/onboarding` | First-time user introduction slides |
| `login_screen.dart` | `/login` | Email/password and social login |
| `signup_screen.dart` | `/signup` | New user registration |
| `profile_setup_screen.dart` | `/profile-setup` | Birth details and preferences setup |

## Flow
```
Splash → Onboarding (first time) → Login/Signup → Profile Setup → Home
              ↓ (returning user)
            Home
```

## Features
- Email/password authentication
- Google Sign-In
- Facebook Sign-In
- Guest mode access
- Password strength indicator
- Form validation
- Responsive layouts (mobile/tablet/desktop)



