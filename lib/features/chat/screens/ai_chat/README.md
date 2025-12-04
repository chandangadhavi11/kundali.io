# AI Chat Screen

## Overview
The AI Chat Screen provides an AI-powered astrology assistant chat interface with support for multiple device layouts.

## Features
- Real-time chat with AI astrologer
- Message history
- Typing indicators
- Animated send button
- Authentication required for full access
- Responsive layout for all screen sizes
- Sidebar for chat history (tablet/desktop)

## Responsive Breakpoints
| Screen Size | Width |
|-------------|-------|
| Mobile | < 600px |
| Tablet | 600px - 900px |
| Desktop | 900px - 1200px |
| Large Desktop | > 1800px |

## Chat Layouts
| Layout | Description |
|--------|-------------|
| Single | Mobile - single column chat |
| Compact | Tablet portrait - compact sidebar |
| Expanded | Tablet landscape - expanded sidebar |
| Desktop | Desktop - full sidebar and features |

## UI Components
- Chat message bubbles
- Text input field with send button
- Typing indicator animation
- Sidebar for conversation history
- Quick action suggestions

## State Management
- Uses `AuthProvider` for authentication checks
- Message list management
- Keyboard visibility tracking

## Animations
- Send button animation
- Typing indicator animation
- Message appearance animation
- Sidebar toggle animation

## Authentication
- Requires login for full functionality
- Shows `AuthRequiredDialog` for guest users

## File
- `ai_chat_screen.dart` - Main screen widget

## Dependencies
- `provider` - State management
- Custom widgets from `shared/widgets`



