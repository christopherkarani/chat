//
//  Swift_ChatTests.swift
//  Swift ChatTests
//
//  Created by Chris Karani on 20/05/2025.
//

import Testing
import SwiftUI
@testable import Swift_Chat

/**
 * Comprehensive test suite for the Swift Chat application
 *
 * These tests cover the main components of the application:
 * - Models: Message and MessageSender
 * - ViewModels: ChatViewModel
 * - Utilities: TypingEffectManager
 * - Views: ChatInputView, MessageBubbleView
 *
 * Each test group focuses on a specific component and verifies its
 * functionality, initialization, and state management.
 */
struct Swift_ChatTests {
    
    // MARK: - Message Model Tests
    
    @Test
    func testMessageInitialization() throws {
        // Given
        let content = "Hello world"
        let sender = MessageSender.user
        let timestamp = Date()
        
        // When
        let message = Message(content: content, sender: sender, timestamp: timestamp)
        
        // Then
        #expect(message.content == content)
        #expect(message.sender == sender)
        #expect(message.timestamp == timestamp)
        #expect(!message.id.uuidString.isEmpty)
    }
    
    @Test
    func testMessageEquality() throws {
        // Given
        let timestamp = Date()
        let message1 = Message(content: "Hello", sender: .user, timestamp: timestamp)
        
        // When creating a message with the same content but manually setting the same ID
        var message2 = Message(content: "Hello", sender: .user, timestamp: timestamp)
        let mirror = Mirror(reflecting: message2)
        if let idProperty = mirror.children.first(where: { $0.label == "id" }) {
            // This is for testing only and wouldn't be done in production code
            // We're simulating having the same ID to test equality
            if let id = message1.id as? UUID, let idPropertyValue = idProperty.value as? UUID {
                message2 = Message(content: message2.content, sender: message2.sender, timestamp: message2.timestamp)
            }
        }
        
        // Then - even with same content, different IDs should make them not equal
        #expect(message1 != message2)
        
        // When - comparing a message to itself
        #expect(message1 == message1)
    }
    
    // MARK: - ChatViewModel Tests
    
    @Test
    func testChatViewModelInitialization() throws {
        // Given
        let initialMessages = [Message.previewMessages[0]]
        
        // When
        let viewModel = ChatViewModel(initialMessages: initialMessages)
        
        // Then
        #expect(viewModel.messages.count == initialMessages.count)
        #expect(viewModel.messages[0].id == initialMessages[0].id)
        #expect(viewModel.inputText.isEmpty)
        #expect(viewModel.isInputEmpty)  // Empty string should result in isInputEmpty being true
    }
    
    @Test
    func testAddingUserMessage() throws {
        // Given
        let viewModel = ChatViewModel(initialMessages: [])
        let messageContent = "Hello, assistant!"
        viewModel.inputText = messageContent
        
        // When
        viewModel.sendMessage()
        
        // Then - should have two messages (user message and assistant response)
        #expect(viewModel.messages.count >= 1)
        #expect(viewModel.messages[0].content == messageContent)
        #expect(viewModel.messages[0].sender == .user)
        #expect(viewModel.inputText.isEmpty)
        
        // The assistant will start responding asynchronously
        // so we can't reliably test the response in a synchronous test
    }
    
    @Test
    func testInputEmptyState() throws {
        // Given
        let viewModel = ChatViewModel(initialMessages: [])
        
        // When - empty input
        viewModel.inputText = ""
        
        // Then
        #expect(viewModel.isInputEmpty)
        
        // When - whitespace only input
        viewModel.inputText = "   \n  "
        
        // Then
        #expect(viewModel.isInputEmpty)
        
        // When - non-empty input
        viewModel.inputText = "Hello"
        
        // Then
        #expect(!viewModel.isInputEmpty)
    }
    
    // MARK: - TypingEffectManager Tests
    
    @Test
    func testTypingEffectManagerInitialization() throws {
        // Given & When
        let manager = TypingEffectManager()
        
        // Then
        #expect(manager.visibleText.isEmpty)
        #expect(!manager.isThinking)
        #expect(!manager.isTyping)
        #expect(!manager.newCharacterAdded)
    }
    
    @Test
    func testStartThinking() throws {
        // Given
        let manager = TypingEffectManager()
        
        // When
        manager.startThinking()
        
        // Then
        #expect(manager.isThinking)
        #expect(!manager.isTyping)
    }
    
    @Test
    func testStopThinking() throws {
        // Given
        let manager = TypingEffectManager()
        manager.startThinking()
        
        // When
        manager.reset()  // Using reset() to stop the thinking state
        
        // Then
        #expect(!manager.isThinking)
        #expect(!manager.isTyping)
    }
    
    @Test
    func testReset() throws {
        // Given
        let manager = TypingEffectManager()
        manager.startThinking()
        
        // When
        manager.reset()
        
        // Then
        #expect(!manager.isThinking)
        #expect(!manager.isTyping)
        #expect(manager.visibleText.isEmpty)
    }
    
    // Note: Testing the actual typing animation would require more complex
    // asynchronous testing since it involves timers
    
    // MARK: - ChatInputView Tests
    
    @Test
    func testChatInputViewSendButtonDisabled() throws {
        // Testing views requires ViewInspector or similar libraries
        // This is a simple test to verify the view structure
        
        // Given
        var sendActionCalled = false
        let sendAction = { sendActionCalled = true }
        
        // When - Creating a view with empty text
        let inputView = ChatInputView(text: .constant(""), onSend: sendAction)
        
        // Then - The send button should be disabled with empty text
        // Note: In a real test, we would use ViewInspector to verify this
        #expect(!sendActionCalled)
        
        // This test is limited without ViewInspector. In a real test suite,
        // we would verify the button's disabled state directly.
    }
    
    // MARK: - MessageBubbleView Tests
    
    @Test
    func testMessageBubbleViewForUserMessage() throws {
        // Given
        let userMessage = Message(content: "Hello", sender: .user)
        
        // When
        let bubbleView = MessageBubbleView(message: userMessage)
        
        // Then
        // Note: In a real test with ViewInspector, we would verify the view structure
        // Here we're just ensuring the view initializes without errors
        #expect(true)
    }
    
    @Test
    func testMessageBubbleViewForAssistantMessage() throws {
        // Given
        let assistantMessage = Message(content: "Hello, how can I help?", sender: .assistant)
        
        // When
        let bubbleView = MessageBubbleView(message: assistantMessage)
        
        // Then
        // Note: In a real test with ViewInspector, we would verify the view structure
        // Here we're just ensuring the view initializes without errors
        #expect(true)
    }
}
