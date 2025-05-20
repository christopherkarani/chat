import SwiftUI

/// Component for the chat input bar at the bottom of the screen
struct ChatInputView: View {
    @Binding var text: String
    var onSend: () -> Void
    
    /// Design constants
    private struct Constants {
        static let cornerRadius: CGFloat = 25
        static let minHeight: CGFloat = 50
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 8
        static let backgroundColor = Color(UIColor.systemGray6)
        static let placeholderText = "Ask anything"
        static let placeholderColor = Color(UIColor.placeholderText)
        static let bottomPadding: CGFloat = 30 // For home indicator area
        static let iconSize: CGFloat = 24
        static let iconColor = Color.gray
    }
    
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Main input row
            HStack(spacing: 16) {
                // Attachment button
                Button(action: {
                    // Placeholder for attachment functionality
                }) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 20))
                        .foregroundColor(Constants.iconColor)
                }
                .frame(width: Constants.iconSize, height: Constants.iconSize)
                
                // Input field
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(Constants.placeholderText)
                            .foregroundColor(Constants.placeholderColor)
                            .padding(.leading, 5)
                    }
                    
                    TextField("", text: $text)
                        .focused($isInputFocused)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 5)
                }
                .frame(height: Constants.minHeight)
                .frame(maxWidth: .infinity)
                
                // Microphone button for empty text or send button for non-empty text
                Group {
                    if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button(action: {
                            // Placeholder for microphone functionality
                        }) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Constants.iconColor)
                        }
                    } else {
                        Button(action: onSend) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                }
                .frame(width: Constants.iconSize, height: Constants.iconSize)
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.vertical, Constants.verticalPadding)
            .background(Color(UIColor.systemBackground))
            
            // Home indicator area padding
            Rectangle()
                .fill(Color.clear)
                .frame(height: Constants.bottomPadding)
                .background(Color(UIColor.systemBackground))
        }
        .overlay(
            // Full-width rounded rectangle background for the input field
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(Color(UIColor.separator), lineWidth: 0.5)
                .background(Constants.backgroundColor.cornerRadius(Constants.cornerRadius))
                .padding(.horizontal, Constants.horizontalPadding + 40) // Wider padding to exclude buttons
                .padding(.vertical, Constants.verticalPadding)
                .allowsHitTesting(false) // Don't block interaction with underlying controls
        )
    }
}

struct ChatInputView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                ChatInputView(text: .constant(""), onSend: {})
            }
        }
        .previewDisplayName("Empty Input")
        
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                ChatInputView(text: .constant("What's the weather like?"), onSend: {})
            }
        }
        .previewDisplayName("With Text")
    }
} 