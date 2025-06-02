# Swift Chat

A modern, SwiftUI-based chat application with a clean architecture and intuitive UI.

## Project Structure

The project follows a clean, organized architecture with the following components:

### Models

- `Message.swift`: Defines the Message model and MessageSender enum

### Views

- `ChatView.swift`: Main chat interface
- `ChatInputView.swift`: Input bar with text field and send button
- `MessageBubbleView.swift`: UI component for displaying chat messages
- `TypingEffectViews.swift`: Components for showing typing effects and animations

### ViewModels

- `ChatViewModel.swift`: Business logic for the chat interface

### Utils

- `TypingEffectManager.swift`: Manages typing animation states and effects

### Extensions

- `KeyboardReadable.swift`: SwiftUI extensions for keyboard handling

## Design Patterns

- **MVVM Architecture**: Clear separation of Model, View, and ViewModel
- **Composition over Inheritance**: UI components designed for reusability
- **Protocol-Oriented Programming**: Using protocols like KeyboardReadable
- **Publisher-Subscriber Pattern**: Using Combine for reactive updates

## Key Features

- Real-time chat interface with user and assistant messages
- Animated typing indicators
- Keyboard avoidance
- Haptic feedback
- Accessibility support
- Dark mode compatibility

## Development Notes

- Swift 5.5+
- iOS 15.0+ compatibility
- SwiftUI for UI components
- Combine for reactive programming
