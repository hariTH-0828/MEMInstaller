//
//  ToastViewStyle.swift
//  MEMToast
//
//  Created by Hariharan R S on 25/10/24.
//

import SwiftUI

public protocol ToastViewStyle {
    /// The type of view created by the style.
    associatedtype Body: View
    
    /// Creates a view for the Toast based on the provided message.
    ///
    /// - Parameter message: The message to display inside the Toast.
    /// - Returns: A view that represents the Toast.
    func makeBody(message: String?) -> Body
}

/// A type-erased wrapper for any `ToastViewStyle`.
///
/// `AnyToastViewStyle` allows for the use of any type conforming to `ToastViewStyle` without exposing the specific type.
///
/// - Note: This pattern is useful when you want to pass around styles dynamically while preserving type safety.
struct AnyToastViewStyle: ToastViewStyle {
    /// A closure that stores the type-erased `makeBody` implementation.
    private let _makeBody: (String?) -> AnyView
    
    /// Initializes the type-erased `AnyToastViewStyle` with a specific `ToastViewStyle`.
    ///
    /// - Parameter style: The concrete `ToastViewStyle` to wrap.
    init<S: ToastViewStyle>(_ style: S) {
        _makeBody = { message in
            AnyView(style.makeBody(message: message))
        }
    }
    
    /// Creates a view for the Toast based on the provided message, using the wrapped style.
    ///
    /// - Parameter message: The message to display inside the Toast.
    /// - Returns: A type-erased `View` that represents the Toast.
    func makeBody(message: String?) -> some View {
        _makeBody(message)
    }
}
