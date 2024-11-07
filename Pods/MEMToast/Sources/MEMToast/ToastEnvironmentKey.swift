//
//  ToastEnvironmentKey.swift
//  MEMToast
//
//  Created by Hariharan R S on 25/10/24.
//

import SwiftUI

/// A private struct that defines a custom environment key for managing Toast styles.
///
/// This key is used to store and retrieve a type-erased `ToastViewStyle` from the environment.
/// The default value is set to `AnyToastViewStyle` wrapping a `DefaultToastStyle`.
///
/// - Note: This key is meant to be used internally within the `EnvironmentValues` extension.
@available(iOS 16.0, *)
private struct ToastStyleKey: EnvironmentKey {
    /// The default value for the environment key, which is an `AnyToastViewStyle`
    /// wrapping the `DefaultToastStyle`. This will be used if no other toast style
    /// is explicitly set in the environment.
    static let defaultValue: AnyToastViewStyle = AnyToastViewStyle(DefaultToastStyle())
}

@available(iOS 16.0, *)
extension EnvironmentValues {
    /// A property to access and set the current `AnyToastViewStyle` in the environment.
    ///
    /// This property allows views to read or modify the `ToastViewStyle` being used in
    /// their environment. The style can be accessed using the `toastStyle` property, or
    /// set by injecting a new style through environment modifiers.
    ///
    /// Example usage:
    /// ```swift
    /// .environment(\.toastStyle, AnyToastViewStyle(CustomToastStyle()))
    /// ```
    var ToastStyle: AnyToastViewStyle {
        get { self[ToastStyleKey.self] }
        set { self[ToastStyleKey.self] = newValue }
    }
}
