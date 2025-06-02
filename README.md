# SwiftUI Chat Interface MVP

This project implements a minimalistic SwiftUI-based chat interface for an iOS MVP, closely resembling the ChatGPT iOS app. The interface is designed for portrait orientation only.

## Features

- Clean, modern design following Apple's Human Interface Guidelines
- Distinct message bubbles for user and assistant messages
- Avatar placeholders and timestamps for every message
- Fixed input bar with text input field and send button
- Responsive layout that adapts to all iPhone screen sizes in portrait orientation
- Keyboard avoidance for smooth user experience

## Project Structure

- **Models**
  - `Message` - Core data structure representing a chat message
  - `MessageSender` - Enumeration to distinguish between user and assistant messages

- **ViewModels**
  - `ChatViewModel` - Manages chat state and message operations

- **Views**
  - `ChatView` - Main view orchestrating the entire chat interface
  - `MessageBubbleView` - Component for displaying individual chat messages
  - `ChatInputView` - Input bar component for entering and sending messages

- **Utilities**
  - `KeyboardReadable` - Protocol and extensions for keyboard management

## Design Rationale

### Platform & Orientation Requirements
- Implemented fully in SwiftUI, leveraging its declarative approach
- Designed exclusively for portrait orientation with responsive layout adjustments

### Layout & Components
- Scrollable chat window using SwiftUI's `ScrollView` and `ScrollViewReader` for auto-scrolling
- Message bubbles styled differently for user vs assistant using conditional styling
- Avatar placeholders implemented as simple colored circles (can be replaced with images)
- Timestamps displayed under each message using DateFormatter for consistency
- Fixed input bar pinned to bottom using ZStack with bottom alignment
- TextEditor for rich input functionality with proper keyboard handling

### Visual Style
- Modern, light color scheme using system colors for adaptability to light/dark mode
- System font for optimal legibility and consistency with iOS guidelines
- Rounded corners (16pt) on message bubbles
- Minimum tappable areas of 44×44 points for all interactive elements
- Subtle blue accent color for user messages and send button

### Responsiveness
- Layout adapts to all iPhone screen sizes using flexible spacers
- Message bubbles limited to 75% of screen width for comfortable reading
- Dynamic text input height to accommodate multi-line messages
- Keyboard avoidance using Combine publishers to monitor keyboard events

## Integration Notes

This MVP focuses exclusively on the front-end UI components and does not include:
- Backend connectivity
- Message persistence
- Authentication
- Actual message sending logic

To integrate with a backend:
1. Modify the `ChatViewModel` to connect to your messaging service
2. Replace the `simulateAssistantResponse` method with actual API calls
3. Implement persistence if needed using CoreData, UserDefaults, or a database
4. Add authentication as required for your application

## Preview

The interface can be previewed in Xcode using the preview providers in each view file. Multiple device sizes are configured in the previews to ensure responsive design.

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+ 