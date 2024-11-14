//
//  HorizontalCircularViewStyle.swift
//  ZorroWare
//
//  Created by Hariharan R S on 25/09/24.
//

import SwiftUI

/// Defines the body of the progress view style with a circular progress indicator
/// and an optional label or a default "Loading" text.
///
///```swift
///    struct ContentView: View {
///         var body: some View {
///             ZStack {
///                 ProgressView("Loading")
///                     .progressViewStyle(.horizontalCircular)
///             }
///         }
///    }
///```
///
/// - Parameter configuration: Provides the configuration for the progress view,
///   including label if available.
/// - Returns: A horizontal view with a circular progress indicator and a label or default text.
struct HorizontalCircularViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 8) {
            // Circular progress indicator
            ProgressView()

            // Display either a custom label or a default "Loading" text
            if let label = configuration.label { label }
            else { Text("Loading") }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.regularMaterial) // Uses material background for a translucent effect
        )
    }
}

extension ProgressViewStyle where Self == HorizontalCircularViewStyle {
    /// A convenience method to access the custom `HorizontalCircularViewStyle`.
    static var horizontalCircular: HorizontalCircularViewStyle {
        return HorizontalCircularViewStyle()
    }
}
