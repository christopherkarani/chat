//
//  Swift_ChatApp.swift
//  Swift Chat
//
//  Created by Chris Karani on 20/05/2025.
//

import SwiftUI
import Combine

/// Enumeration representing message sender type
enum MessageSender {
    case user
    case assistant
}

/// Model representing a chat message
struct Message: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let sender: MessageSender
    let timestamp: Date
    
    /// Creates a message with the current timestamp
    init(content: String, sender: MessageSender) {
        self.content = content
        self.sender = sender
        self.timestamp = Date()
    }
    
    /// Implementation of Equatable
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.sender == rhs.sender &&
        lhs.timestamp == rhs.timestamp
    }
}

/// Preview data for development
extension Message {
    static var previewMessages: [Message] = [
        Message(content: "Hello! How can I assist you today?", sender: .assistant),
        Message(content: "I need help designing a new app interface", sender: .user),
        Message(content: "I'd be happy to help with that! What kind of app are you designing?", sender: .assistant),
        Message(content: "It's a chat application that needs to look similar to ChatGPT", sender: .user),
        Message(content: "Great choice! A chat interface typically includes message bubbles, an input field, and a clear distinction between sent and received messages. Would you like me to suggest some design principles to follow?", sender: .assistant),
        Message(content: "Yes please, that would be very helpful", sender: .user),
        Message(content: "Here are some key design principles for a chat interface:\n\n1. Clear visual hierarchy\n2. Distinct message bubbles for different senders\n3. Consistent spacing and padding\n4. Appropriate typography for readability\n5. Subtle timestamps\n6. Fixed input bar with clear send button\n7. Keyboard avoidance\n\nWould you like me to elaborate on any of these points?", sender: .assistant)
    ]
}

@main
struct Swift_ChatApp: App {
    var body: some Scene {
        WindowGroup {
            ChatView()
        }
    }
}
