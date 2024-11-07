//
//  UIColor+.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import UIKit
import SwiftUI

extension UIColor {
    /// Returns a UIColor that adapts based on the current user interface style (light/dark mode).
    ///
    /// - Parameters:
    ///   - dark: The color to be used in dark mode.
    ///   - light: The color to be used in light mode.
    /// - Returns: A UIColor that switches between dark and light colors based on the current interface style.
    public static func setAppearance(dark: UIColor, light: UIColor) -> UIColor {
        return UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        }
    }
    
    /// A convenience method that calls `setAppearance(dark:light:)` to apply dark and light colors.
    ///
    /// - Parameters:
    ///   - dark: The color to be used in dark mode.
    ///   - light: The color to be used in light mode.
    /// - Returns: A UIColor that adapts to dark/light mode.
    public static func setColor(dark: UIColor, light: UIColor) -> UIColor {
        return setAppearance(dark: dark, light: light)
    }
}
