import Foundation
import Combine

/// ViewModel for the chat interface
class ChatViewModel: ObservableObject {
    /// Published property that triggers view updates when messages change
    @Published private(set) var messages: [Message] = []
    
    /// Current input message text
    @Published var inputText: String = ""
    
    /// Boolean that indicates whether the input text is empty
    var isInputEmpty: Bool {
        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(initialMessages: [Message] = []) {
        self.messages = initialMessages
    }
    
    /// Adds a new message to the chat
    func addMessage(content: String, sender: MessageSender) {
        let newMessage = Message(content: content, sender: sender)
        messages.append(newMessage)
    }
    
    /// Simulates sending a message (for MVP UI demonstration)
    func sendMessage() {
        guard !isInputEmpty else { return }
        
        // Add user message
        addMessage(content: inputText, sender: .user)
        
        // Clear input
        inputText = ""
        
        // In a real implementation, this would trigger a network request or other logic
        // For MVP UI demo, we'll just simulate a response after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.simulateAssistantResponse()
        }
    }
    
    /// Simulates a response from the assistant (for MVP UI demonstration)
    private func simulateAssistantResponse() {
        // For MVP UI demonstration only
        addMessage(content: "Thank you for your message. This is a placeholder response for the UI demonstration.", sender: .assistant)
    }
} 