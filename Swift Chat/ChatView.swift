import SwiftUI
import Combine

/// Main chat interface view
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel(initialMessages: Message.previewMessages)
    @FocusState private var isInputFocused: Bool
    @State private var keyboardIsVisible = false
    @State private var scrollToBottom = true
    
    /// Design constants
    private struct Constants {
        static let bottomPadding: CGFloat = 8
        static let topPadding: CGFloat = 8
        static let emptyStateTopPadding: CGFloat = 120
        static let inputBarHeight: CGFloat = 60
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Main content area
                VStack(spacing: 0) {
                    // Messages area
                    if viewModel.messages.isEmpty {
                        // Empty state view
                        emptyStateView
                    } else {
                        // Message list
                        messageListView
                    }
                    
                    Spacer(minLength: 0)
                }
                .edgesIgnoringSafeArea(.bottom)
                
                // Input bar overlay at the bottom
                VStack(spacing: 0) {
                    Spacer()
                    
                    ChatInputView(
                        text: $viewModel.inputText,
                        onSend: {
                            withAnimation {
                                scrollToBottom = true
                                viewModel.sendMessage()
                            }
                        }
                    )
                }
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // Menu button - no action for MVP
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // New chat button - no action for MVP
                    }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.primary)
                    }
                }
            }
            .keyboardAdaptive() // Apply keyboard handling
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        // Dismiss keyboard when tapping outside text field
                        isInputFocused = false
                    }
            )
            .onReceive(
                // Monitor keyboard visibility
                Publishers.Merge(
                    NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                        .map { _ in true },
                    NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                        .map { _ in false }
                )
            ) { isVisible in
                keyboardIsVisible = isVisible
                
                if isVisible {
                    // When keyboard appears, scroll to bottom
                    scrollToBottom = true
                }
            }
            .onAppear {
                // Add initial messages when view appears
                if viewModel.messages.isEmpty {
                    print("Adding initial messages")
                    
                    // Force add some initial messages
                    viewModel.addMessage(content: "What can you tell me about designing a chat interface?", sender: .user)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.addMessage(content: "Designing an effective chat interface involves several key principles:\n\n1. Clear visual hierarchy\n2. Distinct message bubbles for different senders\n3. Consistent spacing and padding\n4. Appropriate typography for readability\n5. Subtle timestamps\n6. Fixed input bar with clear send button\n7. Keyboard avoidance\n\nWould you like me to elaborate on any of these points?", sender: .assistant)
                    }
                }
            }
        }
        // Apply device-specific adjustments
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    /// Empty state view
    private var emptyStateView: some View {
        VStack {
            Spacer().frame(height: Constants.emptyStateTopPadding)
            Text("No messages yet")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Start a conversation")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Debug button to add a test message
            Button("Start Chat") {
                viewModel.addMessage(content: "Hello! What can you tell me about this chat app?", sender: .user)
                
                // Add assistant response after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.addMessage(content: "This is a chat interface built with SwiftUI to demonstrate a clean, minimal design similar to ChatGPT. It features message bubbles for user messages and clean text for AI responses, with timestamps and avatars.\n\nWhat would you like to know about it?", sender: .assistant)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.top, 20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
    
    /// Message list view with scroll capability
    private var messageListView: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                VStack(spacing: 16) {
                    // Top spacer
                    Color.clear.frame(height: Constants.topPadding)
                    
                    // Messages
                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(message: message)
                    }
                    
                    // Bottom spacer that we'll scroll to
                    Color.clear
                        .frame(height: Constants.bottomPadding + Constants.inputBarHeight + 40)
                        .id("bottomID")
                }
                .padding(.horizontal, 4)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .background(Color(UIColor.systemBackground))
            .onChange(of: viewModel.messages) { _ in
                // Scroll to bottom when messages change
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        scrollView.scrollTo("bottomID", anchor: .bottom)
                    }
                }
            }
            .onAppear {
                // Scroll to bottom when view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        scrollView.scrollTo("bottomID", anchor: .bottom)
                    }
                }
            }
        }
    }
}

/// Preview for development
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatView()
                .previewDevice("iPhone 13")
                .previewDisplayName("iPhone 13")
            
            ChatView()
                .previewDevice("iPhone SE (3rd generation)")
                .previewDisplayName("iPhone SE")
            
            ChatView()
                .previewDevice("iPhone 13 Pro Max")
                .previewDisplayName("iPhone 13 Pro Max")
        }
    }
} 
