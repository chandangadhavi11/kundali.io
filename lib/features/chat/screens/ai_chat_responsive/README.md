# AI Chat Screen - Responsive Demo

## Overview
A focused responsive implementation of the AI Chat Screen demonstrating responsive chat UI patterns.

## Features
- Simplified chat interface
- Responsive design demo
- Message bubbles with timestamps
- Typing indicator
- Keyboard-aware layout

## Purpose
This is a demonstration/prototype file showing:
- How chat UI adapts to different screen sizes
- Message bubble layouts
- Input field positioning with keyboard visibility
- Basic chat functionality patterns

## UI Components
- Chat message bubbles (user/AI differentiated)
- Message timestamps
- Text input field
- Send button
- Typing indicator

## State
- Message list
- Typing indicator state
- Keyboard visibility tracking

## Chat Message Model
```dart
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
}
```

## File
- `ai_chat_screen_responsive.dart` - Responsive demo widget

## Related
- See `ai_chat/ai_chat_screen.dart` for full implementation

## Dependencies
- `app_colors.dart` - Theme colors



