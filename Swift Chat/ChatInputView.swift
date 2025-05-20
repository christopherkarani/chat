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
        static let sendButtonSize: CGFloat = 44
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 10
        static let textPadding: CGFloat = 12
        static let backgroundColor = Color(UIColor.tertiarySystemBackground)
        static let placeholderText = "Message"
        static let placeholderColor = Color(UIColor.placeholderText)
    }
    
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            // Text input field
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .fill(Constants.backgroundColor)
                
                // Placeholder text
                if text.isEmpty {
                    Text(Constants.placeholderText)
                        .foregroundColor(Constants.placeholderColor)
                        .padding(.leading, Constants.textPadding)
                        .padding(.trailing, Constants.textPadding)
                }
                
                // Actual text input
                TextEditor(text: $text)
                    .focused($isInputFocused)
                    .padding(.leading, 4)
                    .padding(.trailing, 4)
                    .frame(minHeight: Constants.minInputHeight, maxHeight: Constants.maxInputHeight)
                    .background(Color.clear)
                    .padding(.horizontal, 8)
            }
            .frame(minHeight: Constants.minInputHeight)
            
            // Send button
            Button(action: {
                onSend()
                isInputFocused = true // Keep keyboard open after sending
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.sendButtonSize * 0.6, height: Constants.sendButtonSize * 0.6)
                    .foregroundColor(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
            }
            .frame(width: Constants.sendButtonSize, height: Constants.sendButtonSize)
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.vertical, Constants.verticalPadding)
        .background(Color(UIColor.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(UIColor.separator))
                .opacity(0.5),
            alignment: .top
        )
    }
}

struct ChatInputView_Previews: PreviewProvider {
    static var previews: some View {
        ChatInputView(text: .constant("Hello"), onSend: {})
    }
} 