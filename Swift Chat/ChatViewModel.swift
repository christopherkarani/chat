import Foundation
import Combine
import SwiftUI

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
        print("ChatViewModel init with \(initialMessages.count) messages")
        
        // Initialize with default messages for demonstration
        addUserMessage("What can you tell me about designing a chat interface?")
        
        // Add assistant response with slight delay to mimic response time
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.addAssistantMessage("Designing an effective chat interface involves several key principles:\n\n1. Clear visual hierarchy\n2. Distinct message bubbles for different senders\n3. Consistent spacing and padding\n4. Appropriate typography for readability\n5. Subtle timestamps\n6. Fixed input bar with clear send button\n7. Keyboard avoidance\n\nWould you like me to elaborate on any of these points?")
        }
    }
    
    /// Adds a user message
    func addUserMessage(_ content: String) {
        addMessage(content: content, sender: .user)
    }
    
    /// Adds an assistant message
    func addAssistantMessage(_ content: String) {
        addMessage(content: content, sender: .assistant)
    }
    
    /// Adds a new message to the chat
    func addMessage(content: String, sender: MessageSender) {
        let newMessage = Message(content: content, sender: sender)
        print("Adding message: \(content.prefix(20))...")
        messages.append(newMessage)
        print("Message count now: \(messages.count)")
    }
    
    /// Simulates sending a message (for MVP UI demonstration)
    func sendMessage() {
        guard !isInputEmpty else { return }
        
        let messageText = inputText
        print("Sending message: \(messageText)")
        
        // Add user message
        addMessage(content: messageText, sender: .user)
        
        // Clear input
        inputText = ""
        
        // In a real implementation, this would trigger a network request or other logic
        // For MVP UI demo, we'll just simulate a response after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.simulateAssistantResponse(to: messageText)
        }
    }
    
    /// Simulates a response from the assistant (for MVP UI demonstration)
    private func simulateAssistantResponse(to userMessage: String) {
        // For MVP UI demo, simulate different responses based on user input patterns
        let lowerMessage = userMessage.lowercased()
        
        if lowerMessage.contains("weather") {
            let response = "As of May 21, 2025, in your location, the weather is partly cloudy with a temperature of 22°C (72°F). There's a 15% chance of rain later today.\n\nWould you like to know the forecast for the coming days?"
            addMessage(content: response, sender: .assistant)
        }
        else if lowerMessage.contains("hello") || lowerMessage.contains("hi") {
            addMessage(content: "Hello! It's nice to meet you. How can I assist you today?", sender: .assistant)
        }
        else if lowerMessage.contains("help") || lowerMessage.contains("assist") {
            addMessage(content: "I'd be happy to help you! I can provide information, answer questions, offer suggestions, or have a conversation on almost any topic. What would you like assistance with today?", sender: .assistant)
        }
        else if lowerMessage.contains("thanks") || lowerMessage.contains("thank you") {
            addMessage(content: "You're welcome! If you need anything else, feel free to ask.", sender: .assistant)
        }
        else if lowerMessage.contains("how are you") {
            addMessage(content: "I'm functioning well, thank you for asking! As an AI, I don't experience feelings, but I'm operating at optimal capacity and ready to assist you. How are you doing today?", sender: .assistant)
        }
        else {
            // Generic response with some formatting to look like ChatGPT
            addMessage(content: "Thank you for your message. I understand you're asking about \"\(userMessage.prefix(20))...\"\n\nI'd be happy to help with this. Could you provide a bit more context or specific questions about this topic so I can give you the most helpful response?", sender: .assistant)
        }
    }
} 