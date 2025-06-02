import SwiftUI

/**
 * Component for the chat input bar at the bottom of the screen
 * 
 * This view provides the user input interface for the chat application, featuring:
 * - A text input field with placeholder text
 * - A send button that activates when text is entered
 * - Appropriate styling with shadows and rounded corners
 * - Proper keyboard integration
 * - Accessibility support
 * 
 * The component is designed to match modern chat application interfaces
 * and provides consistent visual feedback for user interactions.
 */
public struct ChatInputView: View {
    // MARK: - Properties
    
    /**
     * Two-way binding to the text input value
     * Updates when the user types and can be modified externally
     */
    @Binding private var text: String
    
    /**
     * Action to perform when the send button is tapped
     * or when the user presses the return key
     */
    private var onSend: () -> Void
    
    /**
     * Tracks whether the input field currently has keyboard focus
     * Used to programmatically control focus when needed
     */
    @FocusState private var isInputFocused: Bool
    
    // MARK: - Constants
    
    /**
     * Design constants for consistent visual styling
     * Centralizing these values makes it easier to maintain
     * a cohesive appearance throughout the application
     */
    private struct Constants {
        // Input field appearance
        /// Rounded corner radius for the input field
        static let cornerRadius: CGFloat = 25
        
        /// Minimum height for the input field to maintain consistent layout
        static let minInputHeight: CGFloat = 44
        
        /// Maximum height constraint for the input field (for multiline support)
        static let maxInputHeight: CGFloat = 120
        
        // Input field colors
        /// Background color for the text input field
        static let backgroundColor = Color(UIColor.systemGray6)
        
        /// Placeholder text shown when input is empty
        static let placeholderText = "Ask anything"
        
        /// Color for the placeholder text
        static let placeholderColor = Color(UIColor.placeholderText)
        
        // Spacing and padding
        /// Horizontal padding for the input container
        static let horizontalPadding: CGFloat = 16
        
        /// Vertical padding for the input container
        static let verticalPadding: CGFloat = 12
        
        // Shadow
        /// Color for the subtle shadow effect
        static let shadowColor = Color.black.opacity(0.06)
        
        /// Blur radius for the shadow
        static let shadowRadius: CGFloat = 3
        
        /// Horizontal offset for the shadow
        static let shadowX: CGFloat = 0
        
        /// Vertical offset for the shadow
        static let shadowY: CGFloat = 2
        
        // Button
        /// Size of the send button
        static let buttonSize: CGFloat = 40
        
        /// Internal padding within the button
        static let buttonPadding: CGFloat = 6
    }
    
    // MARK: - Initialization
    
    /**
     * Initialize a new chat input view
     *
     * - Parameters:
     *   - text: Binding to the input text string
     *   - onSend: Closure to execute when send is triggered
     */
    public init(text: Binding<String>, onSend: @escaping () -> Void) {
        self._text = text
        self.onSend = onSend
    }
    
    // MARK: - Body
    
    /**
     * Builds the main input view layout
     *
     * The layout consists of:
     * 1. A horizontal container with the send button and text input field
     * 2. A bottom padding area to accommodate the home indicator on modern iPhones
     *
     * Both areas use the system background color to blend with the rest of the UI
     * and provide appropriate padding for comfortable interaction.
     */
    public var body: some View {
        VStack(spacing: 0) {
            // Main input container with text field and send button
            HStack(spacing: 12) {
                // Send button positioned for easy thumb access
                sendButton
                
                // Input field that expands to fill available space
                inputField
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.vertical, Constants.verticalPadding)
            .background(Color(UIColor.systemBackground))
            
            // Bottom area (home indicator space)
            Rectangle()
                .fill(Color.clear)
                .frame(height: 30)
                .background(Color(UIColor.systemBackground))
        }
    }
    
    // MARK: - UI Components
    
    /**
     * Send button component
     *
     * Features:
     * - Uses SF Symbol "arrow.up.circle.fill" for recognizable send icon
     * - Automatically disables when the input is empty
     * - Uses the app's accent color for visibility
     * - Has an appropriately sized tap target for usability
     * - Triggers the sendMessage function when tapped
     */
    private var sendButton: some View {
        Button(action: sendMessage) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(Color.accentColor)
        }
        .frame(width: Constants.buttonSize, height: Constants.buttonSize)
        .contentShape(Circle()) // Ensures the entire button area is tappable
        .disabled(isInputEmpty) // Prevents sending empty messages
    }
    
    /**
     * Input field component for text entry
     *
     * Features:
     * - Custom placeholder text that appears when the field is empty
     * - Capsule shape with light background for visual distinction
     * - Subtle shadow for depth and elevation in the UI
     * - Submit action tied to the send button functionality
     * - Proper padding for comfortable text entry
     * - Focus state tracking for keyboard management
     *
     * The design uses a ZStack to overlay the placeholder text on the input field
     * when empty, creating a cleaner look than the default TextField placeholder.
     */
    private var inputField: some View {
        ZStack(alignment: .leading) {
            // Placeholder text (only visible when text is empty)
            if text.isEmpty {
                Text(Constants.placeholderText)
                    .foregroundColor(Constants.placeholderColor)
                    .padding(.leading, 12)
            }
            
            // Actual text input field
            TextField("", text: $text, onCommit: sendMessage)
                .focused($isInputFocused) // Connects to the focus state
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color.clear)
                .submitLabel(.send) // Shows send button on keyboard
        }
        .frame(height: Constants.minInputHeight)
        .background(Constants.backgroundColor)
        .clipShape(Capsule())
        .shadow(
            color: Constants.shadowColor,
            radius: Constants.shadowRadius,
            x: Constants.shadowX,
            y: Constants.shadowY
        )
    }
    
    // MARK: - Helper Methods
    
    /**
     * Determines if the input text is effectively empty
     *
     * This computed property checks if the text contains only whitespace
     * or newlines, which would result in an empty message. Used to
     * disable the send button and prevent sending blank messages.
     *
     * - Returns: True if the text is empty or contains only whitespace
     */
    private var isInputEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /**
     * Handles the send message action
     *
     * This method is called when the user taps the send button or
     * presses the return key. It checks if the message is non-empty
     * before calling the onSend closure to process the message.
     */
    private func sendMessage() {
        if !isInputEmpty {
            onSend()
        }
    }
}

// MARK: - Additional UI Components

/**
 * Reusable action button component
 *
 * This component provides a standardized button style for secondary actions
 * throughout the chat interface. It uses SF Symbols for icons and maintains
 * consistent sizing and coloring for visual harmony.
 *
 * Used for auxiliary actions like sharing, copying, or other operations
 * that might be needed in the chat interface.
 */
public struct ActionButton: View {
    /// SF Symbol name to use as the button icon
    private let imageName: String
    
    /// Action to perform when the button is tapped
    private let action: () -> Void
    
    /**
     * Initialize a new action button
     *
     * - Parameters:
     *   - imageName: SF Symbol name for the button icon
     *   - action: Closure to execute when button is tapped
     */
    public init(imageName: String, action: @escaping () -> Void) {
        self.imageName = imageName
        self.action = action
    }
    
    /**
     * Renders the action button with consistent styling
     */
    public var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .font(.system(size: 18))
                .foregroundColor(Color(UIColor.systemGray3))
        }
        .frame(width: 30, height: 30) // Consistent tap target size
    }
}

/**
 * Sources button component
 *
 * A specialized button designed specifically for showing source references
 * in AI-powered chat interfaces. This button has a distinct capsule shape
 * with a light background and "Sources" label.
 *
 * Typically used to provide attribution or supporting evidence for
 * information presented by the assistant in the chat interface.
 */
public struct SourcesButton: View {
    /// Action to perform when the sources button is tapped
    private let action: () -> Void
    
    /**
     * Initialize a new sources button
     *
     * - Parameter action: Closure to execute when button is tapped
     */
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    /**
     * Renders the sources button with a capsule style
     *
     * The button has a subtle appearance with light background and
     * gray text to not distract from the main conversation flow.
     */
    public var body: some View {
        Button(action: action) {
            Text("Sources")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(UIColor.systemGray))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGray6))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Previews

/**
 * Preview provider for the ChatInputView
 *
 * Demonstrates the input view in two states:
 * 1. Empty state with placeholder text visible
 * 2. Filled state with example text entered
 *
 * The preview positions the input at the bottom of the screen
 * with a background color to simulate how it would appear
 * in the actual chat interface.
 */
struct ChatInputView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            ChatInputView(text: .constant(""), onSend: {})
            ChatInputView(text: .constant("what's the weather like?"), onSend: {})
        }
        .background(Color(UIColor.systemGray6))
    }
}
