import SwiftUI
import Combine

/**
 * Main chat interface view
 *
 * This is the primary view of the application, implementing a chat interface
 * similar to modern messaging applications. It includes:
 * - A scrolling message list with support for both user and assistant messages
 * - Real-time typing indicators and animations
 * - A fixed input bar for sending messages
 * - Automatic keyboard handling and scroll adjustment
 * - Empty state UI when no messages exist
 */
public struct ChatView: View {
    // MARK: - View Model
    
    /**
     * The view model that manages chat data and business logic
     *
     * Using @StateObject ensures the view model persists across view updates.
     * We initialize it with sample messages for demonstration purposes.
     */
    @StateObject private var viewModel = ChatViewModel(initialMessages: Message.previewMessages)
    
    // MARK: - State Variables
    
    /**
     * Controls the focus state of the input field
     *
     * Used to programmatically focus/unfocus the text input field
     */
    @FocusState private var isInputFocused: Bool
    
    /**
     * Tracks whether the keyboard is currently visible
     *
     * Used to adjust UI layout when keyboard appears/disappears
     */
    @State private var keyboardIsVisible = false
    
    /**
     * Flag to control automatic scrolling to the bottom of messages
     *
     * When true, the view will automatically scroll to show the most recent messages
     */
    @State private var scrollToBottom = true
    
    // MARK: - Constants
    
    /**
     * Design constants used throughout the view
     *
     * Centralizing these values makes it easier to maintain consistent
     * spacing and sizing throughout the UI, and simplifies future adjustments.
     */
    private struct Constants {
        /// Padding at the bottom of the message list
        static let bottomPadding: CGFloat = 8
        
        /// Padding at the top of the message list
        static let topPadding: CGFloat = 8
        
        /// Top padding for the empty state view
        static let emptyStateTopPadding: CGFloat = 120
        
        /// Height of the input bar at the bottom of the screen
        static let inputBarHeight: CGFloat = 60
    }
    
    // MARK: - Body
    
    /**
     * Main view body defining the complete UI structure
     *
     * The view hierarchy is organized as follows:
     * - NavigationView as the root container, providing navigation bar and title
     * - VStack containing the main content areas (messages and input)
     * - Conditional view switching between empty state and message list
     * - Fixed input bar at the bottom for sending messages
     */
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages area - shows either empty state or message list
                if viewModel.messages.isEmpty && !viewModel.typingManager.isThinking && !viewModel.typingManager.isTyping {
                    // Empty state view when no messages exist
                    emptyStateView
                } else {
                    // Scrollable message list with typing indicators
                    messageListView
                }
                
                // Input bar at the bottom of the screen
                ChatInputView(
                    text: $viewModel.inputText,
                    onSend: {
                        withAnimation {
                            scrollToBottom = true
                            viewModel.sendMessage()
                        }
                    }
                )
                .background(Color(UIColor.systemBackground))
            }
            .edgesIgnoringSafeArea(.bottom) // Extend content to the bottom edge of the screen
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                navigationToolbarItems
            }
            .keyboardAdaptive() // Apply keyboard height adjustment from extension
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        // Dismiss keyboard when tapping outside text field
                        isInputFocused = false
                    }
            )
            .onReceive(keyboardNotifications) { isVisible in
                handleKeyboardVisibility(isVisible)
            }
        }
        // Use stack navigation style for consistent appearance across devices
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - UI Components
    
    /**
     * Navigation toolbar items for the top navigation bar
     *
     * Defines the buttons that appear in the navigation bar:
     * - Left side: Menu button (hamburger icon)
     * - Right side: New chat button (pencil icon)
     *
     * Note: In this MVP version, these buttons don't have any functionality
     * but are included to demonstrate the intended UI design.
     */
    private var navigationToolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // Menu button - no action implemented in MVP
                    // In a full implementation, this would open a sidebar menu
                }) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.primary)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // New chat button - no action implemented in MVP
                    // In a full implementation, this would start a new conversation
                }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    /**
     * View displayed when there are no messages in the chat
     *
     * This empty state provides visual feedback and a call-to-action
     * for users to begin using the chat interface. It includes:
     * - Informational text explaining the empty state
     * - A button to start a demo conversation
     */
    private var emptyStateView: some View {
        VStack {
            // Top spacing to position content appropriately
            Spacer().frame(height: Constants.emptyStateTopPadding)
            
            // Primary empty state message
            Text("No messages yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Secondary instructional text
            Text("Start a conversation")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Call-to-action button that initiates a demo conversation
            Button("Start Chat") {
                startDemoChat()
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            .padding(.top, 20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
    
    /**
     * Scrollable message list with automatic scrolling behavior
     *
     * This view displays the chat message history and typing indicators.
     * It implements several key features:
     * - Automatic scrolling to most recent messages
     * - Message bubbles for both user and assistant messages
     * - Real-time typing indicator display
     * - Scroll position management tied to various state changes
     */
    private var messageListView: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                VStack(spacing: 16) {
                    // Top spacer to provide padding above first message
                    Color.clear.frame(height: Constants.topPadding)
                    
                    // Message bubbles for each message in the conversation
                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(message: message)
                    }
                    
                    // Typing indicator that appears when assistant is thinking/typing
                    AITypingIndicatorView(typingManager: viewModel.typingManager)
                    
                    // Bottom spacer with ID that's used as the scroll target
                    Color.clear
                        .frame(height: Constants.bottomPadding + 20)
                        .id("bottomID")
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .background(Color(UIColor.systemBackground))
            // Automatic scrolling behavior based on state changes
            .onChange(of: viewModel.messages) { _ in
                // Scroll when a new message is added
                scrollToBottom(scrollView)
            }
            .onChange(of: viewModel.typingManager.isThinking) { isThinking in
                // Scroll when thinking indicator appears
                if isThinking {
                    scrollToBottom(scrollView)
                }
            }
            .onChange(of: viewModel.typingManager.isTyping) { isTyping in
                // Scroll when typing indicator appears
                if isTyping {
                    scrollToBottom(scrollView)
                }
            }
            .onChange(of: viewModel.typingManager.visibleText) { _ in
                // Scroll as typing text updates
                scrollToBottom(scrollView)
            }
            .onAppear {
                // Initial scroll to bottom when view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    scrollToBottom(scrollView)
                }
            }
        }
    }
    
    // MARK: - Keyboard Handling
    
    /**
     * Combine publisher that monitors keyboard show/hide notifications
     *
     * This publisher merges two notification publishers into a single stream of boolean values:
     * - true when keyboard is about to show
     * - false when keyboard is about to hide
     *
     * It uses the Combine framework to convert system notifications into a reactive data stream.
     */
    private var keyboardNotifications: Publishers.Merge<Publishers.Map<NotificationCenter.Publisher, Bool>, Publishers.Map<NotificationCenter.Publisher, Bool>> {
        Publishers.Merge(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
    }
    
    /**
     * Responds to changes in keyboard visibility
     *
     * This method is called whenever the keyboard appears or disappears.
     * It updates the keyboardIsVisible state and ensures the view scrolls
     * to the bottom when the keyboard appears to keep the latest messages visible.
     *
     * - Parameter isVisible: Whether the keyboard is becoming visible (true) or hidden (false)
     */
    private func handleKeyboardVisibility(_ isVisible: Bool) {
        keyboardIsVisible = isVisible
        
        if isVisible {
            // When keyboard appears, ensure we scroll to the bottom
            scrollToBottom = true
        }
    }
    
    // MARK: - Helper Methods
    
    /**
     * Scrolls the message list to show the most recent messages
     *
     * This method uses ScrollViewProxy to programmatically scroll to the bottom
     * of the message list. The scroll happens with a slight delay (0.1s) to ensure
     * layout updates have completed, and uses animation for a smooth experience.
     *
     * - Parameter scrollView: The ScrollViewProxy to use for scrolling
     */
    private func scrollToBottom(_ scrollView: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                scrollView.scrollTo("bottomID", anchor: .bottom)
            }
        }
    }
    
    /**
     * Initiates a demonstration conversation
     *
     * This method is triggered by the "Start Chat" button in the empty state view.
     * It adds an initial user message and then triggers the assistant's thinking
     * and typing simulation to demonstrate the chat interaction flow to the user.
     */
    private func startDemoChat() {
        // Add a sample user message
        viewModel.addMessage(content: "Hello! What can you tell me about this chat app?", sender: .user)
        
        // Trigger the assistant's thinking and typing simulation
        viewModel.simulateAssistantThinkingAndTyping(to: "Hello! What can you tell me about this chat app?")
    }
}

// MARK: - Previews

/**
 * Preview provider for SwiftUI canvas
 *
 * This provides preview configurations for the ChatView across different devices
 * and appearance modes to help ensure the UI looks good in various contexts.
 */
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Standard size iPhone preview
            ChatView()
                .previewDevice("iPhone 13")
                .previewDisplayName("iPhone 13")
            
            // Smaller iPhone preview to test layout constraints
            ChatView()
                .previewDevice("iPhone SE (3rd generation)")
                .previewDisplayName("iPhone SE")
            
            // Dark mode preview to test color schemes
            ChatView()
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 13")
                .previewDisplayName("Dark Mode")
        }
    }
}
