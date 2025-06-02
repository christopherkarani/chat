import SwiftUI

/**
 * Component for displaying a chat message bubble
 *
 * This view renders individual chat messages with appropriate styling based on sender type.
 * It includes the following features:
 * - Different styling for user and assistant messages
 * - Responsive bubble width based on screen size
 * - Formatted timestamps
 * - Accessibility support
 * - Proper text wrapping and multiline support
 * - Adaptive styling for different iOS versions
 */
public struct MessageBubbleView: View {
    /**
     * The message data to display in this bubble
     *
     * Contains the content, sender information, and timestamp
     */
    private let message: Message
    
    /**
     * Design constants for consistent styling
     */
    private struct Constants {
        /// Corner radius for user message bubbles
        static let userBubbleCornerRadius: CGFloat = 18
        
        /// Maximum width of message bubbles as a proportion of screen width
        static let maxBubbleWidth: CGFloat = 0.75 // 75% of screen width
        
        /// Size of avatar icons (not currently used but available for future implementation)
        static let avatarSize: CGFloat = 28
        
        /// Standard spacing between bubble elements
        static let spacing: CGFloat = 10
        
        /// Color for timestamp text
        static let timestampColor = Color(UIColor.tertiaryLabel)
        
        /// Font for timestamp text
        static let timestampFont = Font.caption2
        
        /// Font for message content
        static let messageFont = Font.body
        
        /// Line spacing for multiline message content
        static let messageLineSpacing: CGFloat = 4
        
        /// Padding inside user message bubbles
        static let userMessagePadding = EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        /// Padding inside assistant message bubbles
        static let assistantMessagePadding = EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0)
        
        // Bubble colors
        /// Fallback color for user message bubbles on iOS < 15
        static let userBubbleColor = Color(UIColor.systemGray6)
        
        /// Background color for assistant messages
        static let assistantBackgroundColor = Color(UIColor.systemBackground)
    }
    
    /**
     * Initializes a message bubble view
     *
     * - Parameter message: The Message object containing content to display
     */
    public init(message: Message) {
        self.message = message
    }
    
    /**
     * Main body of the view that conditionally displays either user or assistant message style
     *
     * This uses a conditional to choose between two completely different layouts based on
     * the message sender type, creating the appropriate chat bubble appearance.
     */
    public var body: some View {
        Group {
            if message.sender == .assistant {
                assistantMessageView
            } else {
                userMessageView
            }
        }
    }
    
    // MARK: - Assistant Message
    
    /**
     * Layout for messages from the assistant
     *
     * Assistant messages have the following characteristics:
     * - Left-aligned text without a containing bubble
     * - Timestamp below the message text, left-aligned
     * - Primary text color on system background
     * - Consistent padding for readability
     */
    private var assistantMessageView: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Assistant message text
            formattedMessageContent
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .foregroundColor(.primary)
            
            // Timestamp displayed below message content
            timestampView
                .padding(.leading, 16)
                .padding(.bottom, 2)
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - User Message
    
    /**
     * Layout for messages from the user
     *
     * User messages have the following characteristics:
     * - Right-aligned text in a translucent bubble
     * - Timestamp below the message, right-aligned
     * - Rounded corners with adaptive background material
     * - Limited width to maintain readability
     * - Consistent padding for visual appeal
     */
    private var userMessageView: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack(alignment: .bottom) {
                Spacer()
                
                // User message text with bubble background
                Text(message.content)
                    .font(Constants.messageFont)
                    .lineSpacing(Constants.messageLineSpacing)
                    .fixedSize(horizontal: false, vertical: true) // Allow vertical growth
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(Color.primary)
                    .padding(Constants.userMessagePadding)
                    .background {
                        bubbleBackground
                    }
                    .clipShape(RoundedRectangle(cornerRadius: Constants.userBubbleCornerRadius))
                    .frame(maxWidth: UIScreen.main.bounds.width * Constants.maxBubbleWidth, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            
            // Timestamp displayed below the message bubble
            timestampView
                .padding(.trailing, 16)
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - Helper Views
    
    /**
     * Creates the background for user message bubbles
     *
     * This view adapts based on iOS version:
     * - On iOS 15+: Uses ultraThinMaterial for a modern, translucent effect
     * - On iOS 14 and below: Uses a solid color as fallback
     *
     * The adaptive approach ensures consistent appearance across iOS versions
     * while taking advantage of newer UI capabilities when available.
     */
    private var bubbleBackground: some View {
        Group {
            if #available(iOS 15.0, *) {
                RoundedRectangle(cornerRadius: Constants.userBubbleCornerRadius)
                    .fill(.ultraThinMaterial)
            } else {
                RoundedRectangle(cornerRadius: Constants.userBubbleCornerRadius)
                    .fill(Constants.userBubbleColor)
            }
        }
    }
    
    /**
     * Formats the message content with proper text styling
     *
     * This view applies consistent text formatting to message content:
     * - Uses the defined message font
     * - Applies appropriate line spacing for readability
     * - Ensures text wraps properly with fixedSize modifier
     * - Aligns text to the leading edge (left in LTR languages)
     * - Limits maximum width to ensure readability on larger screens
     */
    private var formattedMessageContent: some View {
        Text(message.content)
            .font(Constants.messageFont)
            .lineSpacing(Constants.messageLineSpacing)
            .fixedSize(horizontal: false, vertical: true) // Allow text to wrap properly
            .multilineTextAlignment(.leading)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.85, alignment: .leading)
    }
    
    /**
     * Timestamp view with accessibility support
     *
     * Displays when the message was sent with these features:
     * - Uses a smaller, subtle font for visual users
     * - Uses a muted color to de-emphasize relative to message content
     * - Provides an enhanced accessibility label for screen reader users
     *   that includes both time and date information
     */
    private var timestampView: some View {
        Text(formatTimestamp(message.timestamp))
            .font(Constants.timestampFont)
            .foregroundColor(Constants.timestampColor)
            .accessibilityLabel("Sent at \(formatTimestampForAccessibility(message.timestamp))")
    }
    
    // MARK: - Helper Methods
    
    /**
     * Formats a timestamp for visual display
     *
     * This formatter shows only the time component (e.g., "10:30 AM") to keep
     * the timestamp compact in the UI. The date is omitted since in a chat context,
     * the time is often more immediately relevant than the date.
     *
     * - Parameter date: The Date object to format
     * - Returns: A short time string formatted according to the user's locale
     */
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /**
     * Formats a timestamp for screen reader accessibility
     *
     * This formatter provides more context than the visual timestamp by including
     * both the date and time. This additional information helps screen reader users
     * better understand when messages were sent, especially in longer conversations
     * that may span multiple days.
     *
     * - Parameter date: The Date object to format
     * - Returns: A string with both date and time information
     */
    private func formatTimestampForAccessibility(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Previews

/**
 * Preview provider for the MessageBubbleView
 *
 * This preview shows both assistant and user message bubbles side by side
 * to demonstrate the different styling and layout for each message type.
 * The preview uses a size-that-fits layout to focus on just the bubble
 * components without extra space.
 */
struct MessageBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview showing both message types together
            VStack {
                MessageBubbleView(message: Message(content: "Hello, how can I help you today?", sender: .assistant))
                MessageBubbleView(message: Message(content: "I need help with designing a chat interface", sender: .user))
            }
            .previewDisplayName("Regular Messages")
            .padding()
            .background(Color(UIColor.systemBackground))
            .previewLayout(.sizeThatFits)
        }
    }
}
