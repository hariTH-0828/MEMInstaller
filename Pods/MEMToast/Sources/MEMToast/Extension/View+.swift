//
//  View+.swift
//  MEMToast
//
//  Created by Hariharan R S on 25/10/24.
//

import SwiftUI

@available(iOS 16.0, *)
extension View {
    
    /// Displays a toast message over the current view when a binding condition is met.
    ///
    /// This method applies a `ToastModifier` to the view, which presents a custom toast
    /// message when `isShowing` is `true`. The toast will disappear when `isShowing` is set to `false`.
    ///
    /// - Parameters:
    ///   - message: The message to be displayed inside the toast. Can be `nil` if no message is to be shown.
    ///   - isShowing: A binding that controls the visibility of the toast. When set to `true`, the toast is shown; when `false`, it is hidden.
    /// - Returns: A modified view that can show a toast.
    ///
    /// Example usage:
    /// ```swift
    /// Text("Hello, World!")
    ///     .showToast(message: "This is a toast", isShowing: $isToastVisible)
    /// ```
    public func showToast(message: String?, isShowing: Binding<Bool>) -> some View {
        modifier(ToastModifier(message: message, isShowing: isShowing))
    }
    
    /// Sets a custom toast view style for the current view hierarchy.
    ///
    /// This method injects a given `ToastViewStyle` into the environment, making it available to all
    /// views in the hierarchy that present toast messages. It allows for dynamic customization of the
    /// appearance of toast views.
    ///
    /// - Parameter style: The custom `ToastViewStyle` to apply to the environment.
    /// - Returns: A view modified with the custom toast style in its environment.
    ///
    /// Example usage:
    /// ```swift
    /// Text("Hello, World!")
    ///     .toastViewStyle(MyCustomToastStyle())
    /// ```
    public func toastViewStyle<S>(_ style: S) -> some View where S: ToastViewStyle {
        environment(\.ToastStyle, AnyToastViewStyle(style))
    }
}

@available(iOS 16.0, *)
extension ToastViewStyle where Self == DefaultToastStyle {
    
    /// A static property that returns the default toast style.
    ///
    /// This property provides access to the `DefaultToastStyle` implementation, which
    /// is the basic or standard style for toast views.
    ///
    /// - Returns: A `DefaultToastStyle` instance.
    ///
    /// Example usage:
    /// ```swift
    /// .toastViewStyle(.defaultToastStyle)
    /// ```
    public static var defaultToastStyle: DefaultToastStyle {
        return DefaultToastStyle()
    }
    
    /// Returns a snack bar-style toast with a customizable action.
    ///
    /// Use this method to create a toast styled like a snack bar, with an optional action button.
    /// The action is triggered when the user taps the button.
    ///
    /// - Parameters:
    ///   - actionName: The name of the action displayed on the button.
    ///   - action: A closure that defines the action to perform when the button is tapped.
    ///
    /// - Returns: A `SnackBarToastStyle` instance with the specified action.
    ///
    /// Example usage:
    /// ```swift
    /// .toastViewStyle(.snackBarToastStyle("Undo", action: { /* perform undo */ }))
    /// ```
    public static func snackBarToastStyle(_ actionName: String, action: @escaping () -> Void) -> SnackBarToastStyle {
        return SnackBarToastStyle(actionName: actionName, action: action)
    }
}
