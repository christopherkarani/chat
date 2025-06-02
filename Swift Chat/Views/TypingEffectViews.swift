import SwiftUI
import Combine

/**
 * A view that displays a single pulsing dot animation
 *
 * This component creates a subtle animated circle that pulses between smaller/dimmer
 * and larger/brighter states, creating a visual indication of "thinking" or "processing".
 * It's used as part of the typing indicator to simulate AI thinking behavior.
 */
public struct PulsingDotsView: View {
    /**
     * Controls the animation state of the pulsing dot
     * When true, the dot is at full size and opacity
     * When false, the dot is at reduced size and opacity
     */
    @State private var isAnimating = false
    
    /**
     * Initialize a new pulsing dot view
     * No parameters needed as the dot uses standard styling
     */
    public init() {}
    
    /**
     * Renders the pulsing dot with animation
     *
     * The animation is controlled by the isAnimating state variable and
     * automatically starts when the view appears. The dot is presented as
     * a small gray circle that continuously pulses to indicate activity.
     */
    public var body: some View {
        // Single dot with pulsing animation
        Circle()
            .fill(Color.gray)
            .frame(width: 8, height: 8) // Small, consistent size
            .scaleEffect(isAnimating ? 1.0 : 0.5) // Pulsing size animation
            .opacity(isAnimating ? 1.0 : 0.5) // Pulsing opacity animation
            .animation(
                Animation.easeInOut(duration: 0.8) // Smooth, natural motion
                    .repeatForever(autoreverses: true), // Continuous animation
                value: isAnimating
            )
            .padding(8) // Padding within the capsule background
            .background(Color(UIColor.systemGray6)) // Light gray background
            .clipShape(Capsule()) // Rounded capsule shape around the dot
            .onAppear {
                // Start the animation as soon as the view appears
                isAnimating = true
            }
    }
}

/**
 * Component that displays visual indicators when the AI is thinking or typing
 *
 * This view has two main states:
 * 1. Thinking state: Displays a pulsing dot to indicate the AI is processing
 * 2. Typing state: Shows the text as it's being "typed" character by character
 *
 * The view adapts its appearance based on the current state of the TypingEffectManager,
 * creating a realistic simulation of an AI assistant's response behavior.
 */
public struct AITypingIndicatorView: View {
    @ObservedObject var typingManager: TypingEffectManager
    
    public init(typingManager: TypingEffectManager) {
        self.typingManager = typingManager
    }
    
    /**
     * Renders the appropriate typing indicator based on the current state
     *
     * The view adapts between three possible states:
     * 1. Thinking: Shows a pulsing dot when the AI is "thinking" (before typing starts)
     * 2. Typing: Shows the gradually appearing text as it's being "typed"
     * 3. Hidden: Shows nothing when neither thinking nor typing is active
     *
     * Animations are applied to ensure smooth transitions between states.
     */
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if typingManager.isThinking {
                // Single thinking dot (left aligned)
                HStack {
                    PulsingDotsView()
                        .padding(.leading, 16)
                    Spacer()
                }
            } else if typingManager.isTyping {
                // Simple typing effect view
                HStack(alignment: .top) {
                    if typingManager.visibleText.isEmpty {
                        // Show nothing while waiting for first character
                        EmptyView()
                    } else {
                        typingEffectView
                    }
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.85, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 6)
        // Only show when there is an active typing state
        .opacity((typingManager.isThinking || typingManager.isTyping) ? 1 : 0)
        // Smooth animations for state transitions
        .animation(.easeInOut(duration: 0.2), value: typingManager.isThinking)
        .animation(.easeInOut(duration: 0.2), value: typingManager.isTyping)
    }
    
    /**
     * Creates the view that displays the text being typed
     *
     * This displays the visibleText from the typingManager, which
     * is gradually revealed character by character during the typing animation.
     * The text uses consistent styling matching the message bubbles.
     */
    private var typingEffectView: some View {
        Text(typingManager.visibleText)
            .font(.body) // Consistent font with message bubbles
            .lineSpacing(4) // Proper spacing between lines
            .fixedSize(horizontal: false, vertical: true) // Allow vertical growth
            .foregroundColor(.primary) // Use system-defined text color
            .multilineTextAlignment(.leading) // Left-aligned text
    }
}

/**
 * A view modifier that applies the typing effect to just the most recent characters
 *
 * This more advanced modifier enables a specialized typing effect where only
 * the most recently typed characters are highlighted or animated, creating
 * a more sophisticated typing simulation. This is an alternative to the simpler
 * approach used in the main typing indicator.
 *
 * This can be applied to any Text view using the .typingEffect() modifier.
 */
public struct TypingTextModifier: ViewModifier {
    @ObservedObject var typingManager: TypingEffectManager
    
    public init(typingManager: TypingEffectManager) {
        self.typingManager = typingManager
    }
    
    /**
     * Implements the custom typing effect on the modified content
     *
     * This function applies different styling to the most recently typed characters
     * to create a more sophisticated typing effect. The approach involves:
     * 1. Passing through unchanged when not in typing mode
     * 2. Handling short text (fewer than the fading character count) as a special case
     * 3. For longer text, splitting it into "already typed" and "newly typed" sections
     * 4. Animating transitions when new characters are added
     *
     * - Parameter content: The original content being modified (unused in this implementation)
     * - Returns: A view with the typing effect applied
     */
    public func body(content: Content) -> some View {
        // Don't apply any modifications if not typing
        if !typingManager.isTyping {
            return content.eraseToAnyView()
        }
        
        let text = typingManager.visibleText
        
        // If text is shorter than the fading character count, just show it normally
        if text.count <= typingManager.fadingCharacterCount {
            return Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .eraseToAnyView()
        }
        
        // Otherwise, split the text into two parts: already visible and newly typed
        let clearIndex = text.index(text.endIndex, offsetBy: -min(typingManager.fadingCharacterCount, text.count))
        let clearText = text[..<clearIndex] // The portion of text that's already "typed"
        let fadingText = text[clearIndex...] // The newly typed portion that could have special effects
        
        return HStack(spacing: 0) {
            // The already typed portion
            Text(clearText)
                .font(.body)
                .foregroundColor(.primary)
            
            // The newly typed portion
            Text(fadingText)
                .font(.body)
                .foregroundColor(.primary)
                // Additional effects could be added here in future enhancements
        }
        // Animate changes when new characters are added
        .animation(.easeInOut(duration: 0.3), value: typingManager.newCharacterAdded)
        .eraseToAnyView()
    }
}

// MARK: - View Extensions

public extension View {
    /**
     * Applies the typing effect to a view
     *
     * This extension method makes it easy to apply the typing effect modifier
     * to any view with a clean, chainable syntax.
     *
     * - Parameter manager: The TypingEffectManager controlling the typing animation
     * - Returns: A view with the typing effect applied
     */
    func typingEffect(manager: TypingEffectManager) -> some View {
        self.modifier(TypingTextModifier(typingManager: manager))
    }
    
    /**
     * Helper to type erase views to AnyView
     *
     * This utility helps manage complex conditional view hierarchies
     * by erasing the specific view type to the type-erased AnyView.
     *
     * - Returns: An AnyView wrapping the original view
     */
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
