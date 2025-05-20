import SwiftUI

/// Main chat interface view
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel(initialMessages: Message.previewMessages)
    @FocusState private var isInputFocused: Bool
    @State private var keyboardIsVisible = false
    
    /// Design constants
    private struct Constants {
        static let bottomPadding: CGFloat = 60
        static let topPadding: CGFloat = 8
        static let emptyStateTopPadding: CGFloat = 120
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Message list or empty state
                Group {
                    if viewModel.messages.isEmpty {
                        // Empty state
                        VStack {
                            Spacer().frame(height: Constants.emptyStateTopPadding)
                            Text("No messages yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Start a conversation")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    } else {
                        // Chat message list
                        messageListView
                    }
                }
                .padding(.bottom, Constants.bottomPadding) // Add space for input bar
                
                // Input bar
                VStack(spacing: 0) {
                    ChatInputView(
                        text: $viewModel.inputText,
                        onSend: {
                            viewModel.sendMessage()
                        }
                    )
                }
                .background(Color(UIColor.systemBackground))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(UIColor.separator))
                        .opacity(0.5),
                    alignment: .top
                )
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .keyboardAdaptive() // Apply keyboard handling
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        // Dismiss keyboard when tapping outside text field
                        isInputFocused = false
                    }
            )
            .safeAreaInset(edge: .bottom) {
                // Ensure content doesn't go under bottom safe area
                Color.clear.frame(height: 0)
            }
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
            }
        }
        // Apply device-specific adjustments
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    /// Message list view with scroll capability
    private var messageListView: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Top spacer
                    Color.clear.frame(height: Constants.topPadding)
                    
                    // Messages
                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }
                    
                    // Bottom spacer that we'll scroll to
                    Color.clear
                        .frame(height: Constants.topPadding)
                        .id("bottomID")
                }
            }
            .onChange(of: viewModel.messages) { _ in
                withAnimation {
                    scrollView.scrollTo("bottomID", anchor: .bottom)
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