# Login Screen

## Overview
The Login Screen provides user authentication functionality for the Kundali app.

## Features
- Email/Password login
- Google Sign-In integration
- Facebook Sign-In integration (placeholder)
- Guest mode access
- Forgot password functionality
- Navigation to signup screen
- Responsive design with breakpoints for mobile, tablet, and desktop

## Responsive Breakpoints
| Screen Size | Width |
|-------------|-------|
| Mobile | < 600px |
| Tablet | 600px - 900px |
| Desktop | > 900px |

## UI Components
- Animated logo with gradient background
- Email input field with validation
- Password input field with visibility toggle
- Social login buttons (Google, Facebook)
- Guest mode link
- Sign up navigation link

## Navigation
| Action | Route |
|--------|-------|
| Login Success (profile complete) | `/home` |
| Login Success (profile incomplete) | `/profile-setup` |
| Google Sign-In Success | `/home` or `/profile-setup` |
| Guest Mode | `/home` |
| Sign Up | `/signup` |

## State Management
Uses `AuthProvider` for authentication state management.

## Animations
- Fade animation on screen load
- Slide animation for form elements
- Scale animation for logo

## File
- `login_screen.dart` - Main screen widget

## Dependencies
- `go_router` - Navigation
- `provider` - State management
- `font_awesome_flutter` - Social login icons





