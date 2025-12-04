# Kundli Display Screen

## Overview
Entry point for displaying generated Kundali (birth chart) data.

## Features
- Wrapper/entry point for Kundali display
- Checks for existing Kundali data
- Delegates to ModernKundliDisplayScreen

## Logic
- If `currentKundali` exists in provider → Shows ModernKundliDisplayScreen
- If no Kundali generated → Shows placeholder message

## State Management
Uses `KundliProvider` via Consumer widget.

## Navigation
Route: `/kundli-display`

## File
- `kundli_display_screen.dart` - Entry point widget

## Related
- See `modern_kundli_display/modern_kundli_display_screen.dart` for full implementation
- See `kundli_display_responsive/kundli_display_responsive.dart` for responsive demo



