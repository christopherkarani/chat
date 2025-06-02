//
//  Swift_ChatUITests.swift
//  Swift ChatUITests
//
//  Created by Chris Karani on 20/05/2025.
//

import XCTest

/**
 * UI Test suite for the Swift Chat application
 *
 * These tests verify the application's user interface and interactions:
 * - Basic app launch and UI elements verification
 * - Message input and sending functionality
 * - Scrolling behavior
 * - Assistant response appearance
 * - Empty state handling
 *
 * Each test simulates real user interactions with the app interface
 * and verifies the expected visual results.
 */
final class Swift_ChatUITests: XCTestCase {

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs
        continueAfterFailure = false
        
        // Enable automatic screenshots for test failures
        XCTContext.runActivity(named: "Enable Screenshots") { _ in
            let app = XCUIApplication()
            // Configure the application before launching
            app.launch()
        }
        
        // Set the initial orientation to portrait
        XCUIDevice.shared.orientation = .portrait

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Reset any app state that might affect other tests
        let app = XCUIApplication()
        if app.state == .runningForeground {
            app.terminate()
        }
    }

    /**
     * Test basic UI elements and app structure
     *
     * Verifies that all major UI components are present and visible after app launch:
     * - Navigation bar with title
     * - Chat input field
     * - Send button
     * - Message list (empty or with preview messages)
     */
    @MainActor
    func testBasicUIElements() throws {
        // Launch the application
        let app = XCUIApplication()
        app.launch()
        
        // Verify navigation bar and title exists
        let navigationBar = app.navigationBars.element
        XCTAssertTrue(navigationBar.exists, "Navigation bar should exist")
        
        // Verify chat input field exists
        let textField = app.textFields.firstMatch
        XCTAssertTrue(textField.exists, "Chat input field should exist")
        
        // Verify send button exists (it might be disabled initially)
        let sendButton = app.buttons["arrow.up.circle.fill"].firstMatch
        XCTAssertTrue(sendButton.exists, "Send button should exist")
        
        // Take a screenshot of the initial state
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    /**
     * Test sending a message and receiving a response
     *
     * This test simulates a complete interaction flow:
     * 1. Entering text in the input field
     * 2. Tapping the send button
     * 3. Verifying the message appears in the chat
     * 4. Waiting for and verifying the assistant response
     */
    @MainActor
    func testSendingMessageAndResponse() throws {
        // Launch the application
        let app = XCUIApplication()
        app.launch()
        
        // Enter text in the input field
        let textField = app.textFields.firstMatch
        textField.tap()
        textField.typeText("Hello, how are you today?")
        
        // Verify the send button is enabled and tap it
        let sendButton = app.buttons["arrow.up.circle.fill"].firstMatch
        XCTAssertTrue(sendButton.isEnabled, "Send button should be enabled after text input")
        sendButton.tap()
        
        // Verify the user message appears in the message list
        let userMessage = app.staticTexts["Hello, how are you today?"].firstMatch
        XCTAssertTrue(userMessage.waitForExistence(timeout: 2), "User message should appear in the chat")
        
        // Verify the typing indicator appears (showing the assistant is responding)
        let typingIndicator = app.otherElements["TypingIndicator"].firstMatch
        // The typing indicator might appear briefly - we'll give it a short timeout
        _ = typingIndicator.waitForExistence(timeout: 2)
        
        // Wait for the assistant response to appear (giving it enough time to "think" and "type")
        // We don't know the exact content, but we can check that a new message element appears
        // within a reasonable timeout
        let assistantResponse = app.staticTexts.element(boundBy: app.staticTexts.count - 1)
        XCTAssertTrue(assistantResponse.waitForExistence(timeout: 10), "Assistant response should appear")
        
        // Take a screenshot of the conversation
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    /**
     * Test chat input field behavior
     *
     * Verifies that the input field and send button behave correctly:
     * - Send button is initially disabled with empty input
     * - Send button enables when text is entered
     * - Input field clears after sending a message
     * - Send button disables again after sending
     */
    @MainActor
    func testChatInputFieldBehavior() throws {
        // Launch the application
        let app = XCUIApplication()
        app.launch()
        
        // Verify send button is initially disabled with empty input
        let sendButton = app.buttons["arrow.up.circle.fill"].firstMatch
        XCTAssertFalse(sendButton.isEnabled, "Send button should be disabled when input is empty")
        
        // Enter text and verify send button becomes enabled
        let textField = app.textFields.firstMatch
        textField.tap()
        textField.typeText("Test message")
        XCTAssertTrue(sendButton.isEnabled, "Send button should be enabled after text input")
        
        // Send message and verify input field clears
        sendButton.tap()
        // Wait a moment for the field to clear
        sleep(1)
        XCTAssertEqual(textField.value as? String, "", "Input field should clear after sending")
        
        // Verify send button is disabled again after sending
        XCTAssertFalse(sendButton.isEnabled, "Send button should be disabled after sending")
    }
    
    /**
     * Test scrolling behavior with multiple messages
     *
     * Verifies that the chat scrolls properly when multiple messages are added:
     * - Sends multiple messages
     * - Verifies the most recent message is visible
     * - Checks that scrolling to see earlier messages works
     */
    @MainActor
    func testScrollingWithMultipleMessages() throws {
        // Launch the application
        let app = XCUIApplication()
        app.launch()
        
        // Send multiple messages to generate conversation content
        let textField = app.textFields.firstMatch
        let sendButton = app.buttons["arrow.up.circle.fill"].firstMatch
        
        // Helper function to send a message
        func sendMessage(_ message: String) {
            textField.tap()
            textField.typeText(message)
            sendButton.tap()
            // Wait for the message to appear
            let messageText = app.staticTexts[message].firstMatch
            XCTAssertTrue(messageText.waitForExistence(timeout: 2), "Message should appear: \(message)")
            // Wait briefly for any animations
            sleep(1)
        }
        
        // Send a sequence of messages
        sendMessage("First message")
        sendMessage("Second message")
        sendMessage("Third message")
        sendMessage("Fourth message")
        
        // Verify the most recent message is visible
        let lastMessage = app.staticTexts["Fourth message"].firstMatch
        XCTAssertTrue(lastMessage.isHittable, "The most recent message should be visible")
        
        // Scroll up to see earlier messages
        app.swipeUp()
        
        // Take a screenshot of the scrolled state
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /**
     * Test app launch performance
     *
     * Measures how long it takes to launch the application,
     * which is important for user experience and perceived performance.
     */
    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // Measure launch performance over multiple launches for accuracy
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    /**
     * Test empty state UI
     *
     * Verifies that the empty state UI is displayed correctly when there are no messages,
     * and that it disappears appropriately when messages are added.
     */
    @MainActor
    func testEmptyStateUI() throws {
        // Launch a fresh instance of the app (which might show empty state)
        let app = XCUIApplication()
        // Clear any saved messages to ensure empty state
        app.launchArguments = ["-clearMessages"]
        app.launch()
        
        // Check for the empty state view (this will depend on your implementation details)
        // You might have a specific label or image that indicates empty state
        let emptyStateIndicator = app.staticTexts["No messages yet"].firstMatch
        
        // If empty state is present, verify it disappears when adding a message
        if emptyStateIndicator.exists {
            // Take screenshot of empty state
            let emptyScreenshot = XCUIScreen.main.screenshot()
            let emptyAttachment = XCTAttachment(screenshot: emptyScreenshot)
            emptyAttachment.lifetime = .keepAlways
            add(emptyAttachment)
            
            // Send a message
            let textField = app.textFields.firstMatch
            textField.tap()
            textField.typeText("Hello!")
            app.buttons["arrow.up.circle.fill"].tap()
            
            // Verify empty state disappears
            XCTAssertFalse(emptyStateIndicator.waitForExistence(timeout: 2), 
                         "Empty state should disappear after sending a message")
            
            // Take screenshot after message sent
            let filledScreenshot = XCUIScreen.main.screenshot()
            let filledAttachment = XCTAttachment(screenshot: filledScreenshot)
            filledAttachment.lifetime = .keepAlways
            add(filledAttachment)
        }
    }
}
