import SwiftUI
import Combine

/// Protocol to make keyboard state readable
protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
    /// Publisher that reports keyboard visibility changes
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}

extension View {
    /// Applies common modifiers for keyboard avoidance
    func keyboardAdaptive() -> some View {
        self.modifier(KeyboardAdaptiveModifier())
    }
}

/// View modifier that adjusts for keyboard
struct KeyboardAdaptiveModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(keyboardHeightPublisher) { keyboardHeight in
                self.keyboardHeight = keyboardHeight
            }
    }
    
    /// Publisher for keyboard height changes
    private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { notification in
                    notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                }
                .map { rect in
                    rect.height
                },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in
                    CGFloat(0)
                }
        )
        .eraseToAnyPublisher()
    }
} 