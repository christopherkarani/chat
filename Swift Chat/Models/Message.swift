import Foundation

/**
 * Enumeration representing message sender type
 *
 * This enum distinguishes between messages sent by the user and
 * those sent by the AI assistant. It's used to determine the visual
 * styling and alignment of message bubbles in the UI.
 */
public enum MessageSender {
    /// Message sent by the human user
    case user
    /// Message sent by the AI assistant
    case assistant
}

/**
 * Model representing a chat message
 *
 * This struct encapsulates all data related to a single message in the chat.
 * It conforms to Identifiable for use in SwiftUI lists and Equatable for
 * comparison operations.
 */
public struct Message: Identifiable, Equatable {
    /// Unique identifier for the message, automatically generated
    public let id = UUID()
    
    /// The text content of the message
    public let content: String
    
    /// Indicates whether the message was sent by the user or assistant
    public let sender: MessageSender
    
    /// The time when the message was created
    public let timestamp: Date
    
    /**
     * Creates a new message
     *
     * - Parameters:
     *   - content: The text content of the message
     *   - sender: Who sent the message (user or assistant)
     *   - timestamp: When the message was sent (defaults to current time)
     */
    public init(content: String, sender: MessageSender, timestamp: Date = Date()) {
        self.content = content
        self.sender = sender
        self.timestamp = timestamp
    }
    
    /**
     * Compares two Message instances for equality
     *
     * Two messages are considered equal if they have the same id, content,
     * sender, and timestamp.
     *
     * - Parameters:
     *   - lhs: Left-hand side message
     *   - rhs: Right-hand side message
     * - Returns: True if messages are equal, false otherwise
     */
    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.sender == rhs.sender &&
        lhs.timestamp == rhs.timestamp
    }
}

// MARK: - Preview Data

/**
 * Extension providing sample data for SwiftUI previews and development
 */
public extension Message {
    /**
     * Sample message array for SwiftUI previews and testing
     *
     * This provides realistic conversation data that can be used in preview providers
     * and during development to test various UI scenarios without needing to generate
     * messages manually. The conversation follows a logical flow about designing a
     * chat interface.
     */
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
