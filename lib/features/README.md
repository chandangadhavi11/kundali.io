# Features Directory

## Overview
This directory contains all feature modules of the Kundali app, organized by functionality.

## Structure

```
lib/features/
├── auth/                  # Authentication & onboarding
├── navigation/            # App shell & navigation
├── home/                  # Home dashboard (Tab 1)
├── horoscope/             # Horoscope feature (Tab 2)
├── panchang/              # Panchang feature (Tab 3)
├── chat/                  # AI Chat feature (Tab 4)
├── profile/               # Profile feature (Tab 5)
├── kundli/                # Kundli generation & display
├── compatibility/         # Kundli matching
└── subscription/          # Premium subscriptions
```

## Navigation Flow

### Main Tabs (Bottom Navigation)
| Tab | Feature | Route |
|-----|---------|-------|
| 1 | Home | `/home` |
| 2 | Horoscope | `/horoscope` |
| 3 | Panchang | `/panchang` |
| 4 | Chat | `/chat` |
| 5 | Profile | `/profile` |

### Secondary Routes
| Feature | Route |
|---------|-------|
| Kundli Input | `/kundli/input` |
| Kundli Display | `/kundli/display` |
| Compatibility | `/compatibility` |
| Subscription | `/subscription` |

## Feature Module Convention

Each feature follows this structure:
```
feature_name/
├── README.md           # Feature documentation
├── screens/            # Screen widgets
│   └── feature_screen.dart
└── widgets/            # Reusable widgets (optional)
    └── custom_widget.dart
```

## Dependencies
- All features use providers from `lib/core/providers/`
- Shared widgets are in `lib/shared/widgets/`
- Theme and colors from `lib/core/theme/` and `lib/core/constants/`





