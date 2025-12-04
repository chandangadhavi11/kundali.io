# Signup Screen

## Overview
The Signup Screen allows new users to create an account with their personal details.

## Features
- Complete registration form
- Password strength indicator
- Terms and conditions acceptance
- Responsive design with desktop card layout
- Form validation
- Keyboard management

## Responsive Breakpoints
| Screen Size | Width |
|-------------|-------|
| Mobile | < 600px |
| Tablet | 600px - 900px |
| Desktop | > 900px |

## UI Components
- Back navigation button
- Name input field
- Email input field
- Phone number input (with +91 prefix)
- Date of birth picker
- Gender dropdown
- Password field with visibility toggle
- Password strength indicator
- Confirm password field
- Terms checkbox
- Sign up button
- Login link

## Form Fields
| Field | Type | Validation |
|-------|------|------------|
| Name | Text | Min 2 characters |
| Email | Email | Valid email format |
| Phone | Phone | 10 digits |
| Date of Birth | Date | Required |
| Gender | Dropdown | Required |
| Password | Password | Min 6 chars, strength check |
| Confirm Password | Password | Must match password |
| Terms | Checkbox | Must be checked |

## Password Strength
| Level | Criteria |
|-------|----------|
| Weak | < 3 criteria met |
| Fair | 3 criteria met |
| Good | 4-5 criteria met |
| Strong | 6 criteria met |

**Criteria:**
- Length ≥ 8 characters
- Length ≥ 12 characters
- Contains uppercase
- Contains lowercase
- Contains numbers
- Contains special characters

## Navigation
| Action | Route |
|--------|-------|
| Sign Up Success | `/profile-setup` |
| Login | `/login` |
| Back | `/login` |

## State Management
Uses `AuthProvider` for registration.

## Animations
- Fade animation on load
- Slide animation for form

## File
- `signup_screen.dart` - Main screen widget

## Dependencies
- `go_router` - Navigation
- `provider` - State management
- `intl` - Date formatting



