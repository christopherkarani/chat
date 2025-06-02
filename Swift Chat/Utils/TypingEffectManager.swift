import SwiftUI
import Combine

/**
 * Manages typing effects, animation states, and haptic feedback
 *
 * This class is responsible for creating realistic typing animations that simulate
 * an AI assistant thinking and typing. It provides:
 * - A "thinking" state with animated dots
 * - A character-by-character typing animation
 * - Haptic feedback during state transitions and typing
 * - Published properties for reactive UI updates
 *
 * It's designed to work with SwiftUI's reactive architecture, publishing state
 * changes that can be observed by views to create dynamic UI updates.
 */
public class TypingEffectManager: ObservableObject {
    // MARK: - Published Properties
    
    /**
     * The text currently visible during the typing animation
     *
     * This string grows character by character during the typing animation
     * and is used by views to display the partial text as it's being "typed".
     */
    @Published public var visibleText: String = ""
    
    /**
     * Indicates if the assistant is in the "thinking" state
     *
     * When true, UI should display the thinking indicator (pulsing dots).
     * This state typically precedes the typing state.
     */
    @Published public var isThinking: Bool = false
    
    /**
     * Indicates if the assistant is actively "typing" text
     *
     * When true, the typing animation is in progress and characters
     * are being added to visibleText at regular intervals.
     */
    @Published public var isTyping: Bool = false
    
    /**
     * Number of characters at the end of visible text that should appear faded
     *
     * This creates a more realistic typing effect where the most recently
     * typed characters fade in gradually rather than appearing instantly.
     */
    @Published public var fadingCharacterCount: Int = 2
    
    /**
     * Boolean toggle that flips each time a new character is added
     *
     * This property allows views to observe when a new character is added
     * without having to compare the previous and current visibleText.
     * Views can use this to trigger subtle animations or haptic feedback.
     */
    @Published public var newCharacterAdded: Bool = false
    
    // MARK: - Private Properties
    
    /**
     * The complete text that will be revealed character by character
     *
     * This contains the entire message that will eventually be displayed
     * after the typing animation completes.
     */
    private var fullText: String = ""
    
    /**
     * Timer that controls the typing animation speed
     *
     * This timer fires at regular intervals to add characters to the visibleText.
     */
    private var typingTimer: Timer?
    
    /**
     * The current character position in the typing animation
     *
     * Used to track which character from fullText should be added next.
     */
    private var currentIndex: Int = 0
    
    /**
     * Haptic feedback generators for physical feedback during typing
     *
     * These provide subtle vibrations to enhance the typing experience:
     * - feedbackGenerator: Used for major state changes (start/end)
     * - selectionFeedbackGenerator: Used for subtle feedback during typing
     */
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    
    /**
     * The time interval between typing each character (in seconds)
     *
     * At 0.05 seconds per character, this produces a typing speed of
     * approximately 20 characters per second, which feels natural for an AI.
     * This is also used to estimate total typing duration.
     */
    public let typingSpeed: TimeInterval = 0.05 // 20 characters per second
    
    // MARK: - Initialization
    
    /**
     * Initializes the typing effect manager
     *
     * This prepares the haptic feedback generators to minimize latency
     * when they're first used during typing animations.
     */
    public init() {
        // Prepare feedback generators to reduce latency on first use
        feedbackGenerator.prepare()
        selectionFeedbackGenerator.prepare()
    }
    
    // MARK: - Public Methods
    
    /**
     * Starts the "thinking" animation with pulsing dots
     *
     * This method initiates the first stage of the assistant's response sequence,
     * showing that the assistant is processing the user's input before typing.
     * It resets any previous state and provides haptic feedback to indicate
     * the beginning of the process.
     */
    public func startThinking() {
        // Clear any previous state
        reset()
        
        // Set state for thinking animation (pulsing dots)
        isThinking = true
        isTyping = false
        
        // Generate haptic feedback for "thinking" state (medium intensity)
        feedbackGenerator.notificationOccurred(.warning)
    }
    
    /**
     * Starts the character-by-character typing animation for a message
     *
     * This method initiates the second stage of the assistant's response sequence,
     * showing the text being typed one character at a time. It transitions from
     * the thinking state and provides haptic feedback to signal this change.
     *
     * - Parameter text: The full text that will be gradually revealed
     */
    public func startTyping(text: String) {
        // Store the complete text and reset the animation state
        self.fullText = text
        self.currentIndex = 0
        self.visibleText = ""
        self.isThinking = false
        self.isTyping = true
        self.newCharacterAdded = false
        
        // Generate haptic feedback for transition to "typing" state
        feedbackGenerator.notificationOccurred(.success)
        
        // Start the timer that will add characters one by one
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { [weak self] timer in
            self?.typeNextCharacter()
        }
    }
    
    /**
     * Resets all typing effect state
     *
     * This method clears all animation state and stops any ongoing animations.
     * It's used when starting a new animation sequence or when manually
     * canceling the current animation.
     */
    public func reset() {
        // Stop the typing timer
        typingTimer?.invalidate()
        typingTimer = nil
        
        // Reset all state variables
        isThinking = false
        isTyping = false
        visibleText = ""
        currentIndex = 0
        newCharacterAdded = false
    }
    
    // MARK: - Private Methods
    
    /**
     * Adds the next character to the visible text
     *
     * This method is called by the typing timer at regular intervals to
     * add one character at a time from fullText to visibleText, creating
     * the typing animation effect. It also provides occasional haptic
     * feedback to enhance the typing sensation.
     */
    private func typeNextCharacter() {
        // Check if we've reached the end of the text
        guard currentIndex < fullText.count else {
            finishTyping()
            return
        }
        
        // Extract and add the next character from the full text
        let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
        visibleText += String(fullText[index])
        currentIndex += 1
        
        // Toggle flag to notify observers of the new character
        newCharacterAdded.toggle()
        
        // Add subtle haptic feedback every 10 characters for a more
        // natural typing feel without overwhelming the user
        if currentIndex % 10 == 0 {
            selectionFeedbackGenerator.selectionChanged()
        }
    }
    
    /**
     * Completes the typing animation
     *
     * This method is called when all characters have been added to visibleText.
     * It cleans up the timer, ensures the full text is visible, and provides
     * a final haptic feedback to signal completion.
     */
    private func finishTyping() {
        // Clean up the timer
        typingTimer?.invalidate()
        typingTimer = nil
        
        // Update state
        isTyping = false
        
        // Ensure the complete text is visible (in case any characters were missed)
        visibleText = fullText
        
        // Provide final haptic feedback to signal completion
        feedbackGenerator.notificationOccurred(.success)
    }
}
