//
//  Decimal+.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 27/11/24.
//

import Foundation

extension Decimal {
    /// Formats a `Decimal` value into a string with a specified number of decimal places.
    /// The default behavior is to format the number with two decimal places.
    /// - Parameters:
    ///   - maximumFractionDigits: The maximum number of digits to display after the decimal point. Default is 2.
    ///   - minimumFractionDigits: The minimum number of digits to display after the decimal point. Default is 2.
    /// - Returns: A formatted string representing the `Decimal` value, or a fallback string "Invalid number" if formatting fails.
    func formattedString(maximumFractionDigits: Int = 2, minimumFractionDigits: Int = 2) -> String {
        // Create a NumberFormatter instance to control the formatting.
        let formatter = NumberFormatter()
        
        // Set the formatter's style to decimal to properly format the number.
        formatter.numberStyle = .decimal
        
        // Set the maximum and minimum number of fraction digits for the formatted number.
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.minimumFractionDigits = minimumFractionDigits
        
        // Convert the current `Decimal` (self) to NSNumber for compatibility with `NumberFormatter`.
        return formatter.string(from: self as NSNumber) ?? "Invalid number"
    }
}
