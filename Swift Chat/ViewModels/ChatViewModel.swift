import Foundation
import Combine
import SwiftUI

/**
 * ViewModel for the chat interface
 *
 * This class manages the business logic for the chat interface, including:
 * - Maintaining the collection of messages
 * - Handling user input
 * - Managing typing animations and effects
 * - Simulating assistant responses
 *
 * It follows the MVVM pattern and uses Combine's @Published properties
 * for reactive updates to the UI.
 */
public class ChatViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /**
     * Collection of messages in the chat
     *
     * This property is marked private(set) to prevent external modification
     * while still allowing external read access. Changes to this property
     * will automatically trigger UI updates due to the @Published wrapper.
     */
    @Published private(set) public var messages: [Message] = []
    
    /**
     * Current text in the input field
     *
     * This property is bound to the text field in ChatInputView and updates
     * in real-time as the user types.
     */
    @Published public var inputText: String = ""
    
    /**
     * Manages typing animations and effects
     *
     * This object handles the visual representation of the assistant "thinking"
     * and "typing" states, including animations and timing.
     */
    @Published public var typingManager = TypingEffectManager()
    
    // MARK: - Computed Properties
    
    /**
     * Determines if the input text is empty (ignoring whitespace)
     *
     * This property is used to prevent sending empty messages and to
     * control the enabled state of the send button.
     *
     * - Returns: True if the input contains only whitespace or is empty
     */
    public var isInputEmpty: Bool {
        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Private Properties
    
    /**
     * Stores the content of the message currently being "typed" by the assistant
     *
     * This is used during the typing animation to track what message
     * will eventually be added to the chat history once typing is complete.
     */
    private var pendingMessage: String = ""
    
    // MARK: - Initialization
    
    /**
     * Initializes the view model with optional initial messages
     *
     * This constructor accepts an array of messages to populate the chat history.
     * If the array is empty, the chat will start in an empty state.
     *
     * - Parameter initialMessages: Array of Message objects to populate the chat
     */
    public init(initialMessages: [Message] = []) {
        self.messages = initialMessages
        
        // For empty state, we don't add any demo messages
        if initialMessages.isEmpty {
            return
        }
        
        print("ChatViewModel init with \(initialMessages.count) messages")
    }
    
    // MARK: - Public Methods
    
    /**
     * Adds a message from the user to the chat
     *
     * Convenience method that sets the sender to .user automatically.
     *
     * - Parameter content: The text content of the message
     */
    public func addUserMessage(_ content: String) {
        addMessage(content: content, sender: .user)
    }
    
    /**
     * Adds a message from the assistant to the chat
     *
     * Convenience method that sets the sender to .assistant automatically.
     *
     * - Parameter content: The text content of the message
     */
    public func addAssistantMessage(_ content: String) {
        addMessage(content: content, sender: .assistant)
    }
    
    /**
     * Adds a new message to the chat history
     *
     * Creates a new Message object with the provided content and sender,
     * then appends it to the messages array. This will automatically
     * trigger UI updates due to the @Published wrapper.
     *
     * - Parameters:
     *   - content: The text content of the message
     *   - sender: Who sent the message (user or assistant)
     */
    public func addMessage(content: String, sender: MessageSender) {
        let newMessage = Message(content: content, sender: sender)
        messages.append(newMessage)
    }
    
    /**
     * Processes the current input text as a user message and triggers the assistant response
     *
     * This method performs the following actions:
     * 1. Checks if the input is not empty
     * 2. Adds the input text as a user message to the chat
     * 3. Clears the input field
     * 4. Triggers the assistant's simulated thinking and typing response
     *
     * In a production app, this would likely trigger an API call to a backend service.
     */
    public func sendMessage() {
        guard !isInputEmpty else { return }
        
        let messageText = inputText
        
        // Add user message
        addMessage(content: messageText, sender: .user)
        
        // Clear input
        inputText = ""
        
        // In a real implementation, this would trigger a network request or other logic
        // For MVP UI demo, we'll simulate thinking and typing with delay
        simulateAssistantThinkingAndTyping(to: messageText)
    }
    
    /**
     * Simulates the assistant thinking about and typing a response
     *
     * This method creates a realistic typing effect simulation with these steps:
     * 1. Shows the "thinking" animation (pulsing dots)
     * 2. After a random delay (simulating "thinking" time), generates a response
     * 3. Shows the typing animation as if the assistant is typing character by character
     * 4. When typing is complete, adds the full message to the chat
     *
     * Uses weak self references to prevent potential memory leaks in the closures.
     *
     * - Parameter userMessage: The message from the user that the assistant is responding to
     */
    public func simulateAssistantThinkingAndTyping(to userMessage: String) {
        // Start thinking animation (pulsing dots)
        typingManager.startThinking()
        
        // Simulate AI "thinking" time (1-2 seconds)
        let thinkingTime = TimeInterval.random(in: 1.0...2.0)
        
        // After thinking time, simulate typing
        DispatchQueue.main.asyncAfter(deadline: .now() + thinkingTime) { [weak self] in
            guard let self = self else { return }
            
            // Generate the response
            let response = self.generateResponse(to: userMessage)
            self.pendingMessage = response
            
            // Start typing animation
            self.typingManager.startTyping(text: response)
            
            // After typing is complete, add the message to chat
            // We'll estimate typing completion based on character count
            let typingTime = TimeInterval(response.count) * self.typingManager.typingSpeed
            DispatchQueue.main.asyncAfter(deadline: .now() + typingTime + 0.3) { [weak self] in
                guard let self = self else { return }
                
                // Add message to chat history
                self.addAssistantMessage(response)
                
                // Reset typing effect
                self.typingManager.reset()
            }
        }
    }
    
    // MARK: - Private Methods
    
    /**
     * Generates an appropriate response to the user's message
     *
     * This method simulates an AI assistant by analyzing keywords in the user's
     * message and returning an appropriate response. In a production app, this
     * would likely be replaced by an actual API call to a language model service.
     *
     * The method checks for specific keywords like "weather", "hello", etc.,
     * and returns tailored responses. If no specific patterns are matched,
     * it returns a generic response asking for more context.
     *
     * - Parameter userMessage: The message from the user to respond to
     * - Returns: A response string appropriate to the user's message
     */
    private func generateResponse(to userMessage: String) -> String {
        // For MVP UI demo, simulate different responses based on user input patterns
        let lowerMessage = userMessage.lowercased()
        
        if lowerMessage.contains("weather") {
            return "As of May 21, 2025, in your location, the weather is partly cloudy with a temperature of 22°C (72°F). There's a 15% chance of rain later today.\n\nWould you like to know the forecast for the coming days?"
        }
        else if lowerMessage.contains("hello") || lowerMessage.contains("hi") {
            return "Hello! It's nice to meet you. How can I assist you today?"
        }
        else if lowerMessage.contains("help") || lowerMessage.contains("assist") {
            return "I'd be happy to help you! I can provide information, answer questions, offer suggestions, or have a conversation on almost any topic. What would you like assistance with today?"
        }
        else if lowerMessage.contains("thanks") || lowerMessage.contains("thank you") {
            return "You're welcome! If you need anything else, feel free to ask."
        }
        else if lowerMessage.contains("how are you") {
            return "I'm functioning well, thank you for asking! As an AI, I don't experience feelings, but I'm operating at optimal capacity and ready to assist you. How are you doing today?"
        }
        else {
            // Generic response with some formatting to look like ChatGPT
            return "Thank you for your message. I understand you're asking about \"\(userMessage.prefix(20))...\"\n\nI'd be happy to help with this. Could you provide a bit more context or specific questions about this topic so I can give you the most helpful response?"
        }
    }
}
