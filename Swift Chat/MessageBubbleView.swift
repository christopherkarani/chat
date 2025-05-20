import SwiftUI

/// Component for displaying a chat message bubble
struct MessageBubbleView: View {
    let message: Message
    
    /// Design constants
    private struct Constants {
        static let userBubbleCornerRadius: CGFloat = 18
        static let padding: CGFloat = 12
        static let maxBubbleWidth: CGFloat = 0.75 // 75% of screen width
        static let avatarSize: CGFloat = 28
        static let spacing: CGFloat = 10
        static let userBubbleColor = Color(UIColor.systemGray4)
        static let assistantBackgroundColor = Color(UIColor.systemBackground)
        static let timestampColor = Color(UIColor.tertiaryLabel)
        static let timestampFont = Font.caption2
        static let messageFont = Font.body
        static let messageLineSpacing: CGFloat = 4
        static let userMessagePadding: EdgeInsets = EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        static let assistantMessagePadding: EdgeInsets = EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0)
    }
    
    var body: some View {
        Group {
            if message.sender == .assistant {
                assistantMessageView
            } else {
                userMessageView
            }
        }
    }
    
    // Assistant message
    private var assistantMessageView: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Assistant message text (no avatar)
            formattedMessageContent
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .foregroundColor(.primary)
            
            // Timestamp
            Text(formatTimestamp(message.timestamp))
                .font(Constants.timestampFont)
                .foregroundColor(Constants.timestampColor)
                .padding(.leading, 16)
                .padding(.bottom, 2)
                .accessibilityLabel("Sent at \(formatTimestampForAccessibility(message.timestamp))")
        }
        .padding(.vertical, 6)
    }
    
    // User message
    private var userMessageView: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack(alignment: .bottom) {
                Spacer()
                
                // User message text with bubble
                Text(message.content)
                    .font(Constants.messageFont)
                    .lineSpacing(Constants.messageLineSpacing)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(Color.primary)
                    .padding(Constants.userMessagePadding)
                    .background(Constants.userBubbleColor)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.userBubbleCornerRadius))
                    .frame(maxWidth: UIScreen.main.bounds.width * Constants.maxBubbleWidth, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            
            // Timestamp
            Text(formatTimestamp(message.timestamp))
                .font(Constants.timestampFont)
                .foregroundColor(Constants.timestampColor)
                .padding(.trailing, 16)
                .accessibilityLabel("Sent at \(formatTimestampForAccessibility(message.timestamp))")
        }
        .padding(.vertical, 6)
    }
    
    /// Formats the message content with proper text styling
    private var formattedMessageContent: some View {
        Text(message.content)
            .font(Constants.messageFont)
            .lineSpacing(Constants.messageLineSpacing)
            .fixedSize(horizontal: false, vertical: true) // Allow text to wrap properly
            .multilineTextAlignment(.leading)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.85, alignment: .leading)
    }
    
    /// Format timestamp to a readable form
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// Format timestamp for accessibility
    private func formatTimestampForAccessibility(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct MessageBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Regular messages
            VStack {
                MessageBubbleView(message: Message(content: "Hello, how can I help you today?", sender: .assistant))
                MessageBubbleView(message: Message(content: "I need help with designing a chat interface", sender: .user))
            }
            .previewDisplayName("Regular Messages")
            
            // Long message
            MessageBubbleView(message: Message(content: "This is a much longer message that will wrap to multiple lines to demonstrate how the bubble handles longer content and maintains proper formatting with good readability. The text should wrap nicely within the bubble.", sender: .assistant))
                .previewDisplayName("Long Message")
            
            // Message with line breaks
            MessageBubbleView(message: Message(content: "This message has\nmultiple line breaks\nto show how they appear\nin the chat bubble.", sender: .user))
                .previewDisplayName("Message with Line Breaks")
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .previewLayout(.sizeThatFits)
    }
} 