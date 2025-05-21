import SwiftUI

/// Component for the chat input bar at the bottom of the screen
struct ChatInputView: View {
    @Binding var text: String
    var onSend: () -> Void
    
    /// Design constants
    private struct Constants {
        static let cornerRadius: CGFloat = 20
        static let minInputHeight: CGFloat = 40
        static let maxInputHeight: CGFloat = 120
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 12
        static let textPadding: CGFloat = 16
        static let backgroundColor = Color(UIColor.secondarySystemBackground)
        static let placeholderText = "Ask anything"
        static let placeholderColor = Color(UIColor.placeholderText)
        
        // Shadow properties
        static let shadowColor = Color.black.opacity(0.05)
        static let shadowRadius: CGFloat = 3
        static let shadowX: CGFloat = 0
        static let shadowY: CGFloat = 2
    }
    
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Top separator line
            Divider()
            
            HStack {
                // Text input field with improved styling
                ZStack(alignment: .leading) {
                    // Background with shadow
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .fill(Constants.backgroundColor)
                        .shadow(
                            color: Constants.shadowColor,
                            radius: Constants.shadowRadius,
                            x: Constants.shadowX,
                            y: Constants.shadowY
                        )
                    
                    // Placeholder text
                    if text.isEmpty {
                        Text(Constants.placeholderText)
                            .foregroundColor(Constants.placeholderColor)
                            .padding(.leading, Constants.textPadding)
                    }
                    
                    // Actual text input with send button integrated to the right
                    HStack {
                        TextField("", text: $text)
                            .focused($isInputFocused)
                            .padding(.leading, Constants.textPadding)
                            .padding(.trailing, 8)
                            .padding(.vertical, 10)
                        
                        // Send button only shows when text is present
                        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Button(action: {
                                onSend()
                                isInputFocused = true // Keep keyboard open after sending
                            }) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.blue)
                                    .padding(.trailing, 12)
                            }
                            .transition(.opacity)
                        }
                    }
                }
                .frame(height: Constants.minInputHeight)
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.vertical, Constants.verticalPadding)
            .background(Color(UIColor.systemBackground))
            
            // Add home indicator area padding on iPhone X and later
            Color.clear
                .frame(height: 10)
                .background(Color(UIColor.systemBackground))
        }
        .animation(.easeInOut(duration: 0.2), value: !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
}

struct ChatInputView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            ChatInputView(text: .constant(""), onSend: {})
            ChatInputView(text: .constant("Hello there"), onSend: {})
        }
    }
} 