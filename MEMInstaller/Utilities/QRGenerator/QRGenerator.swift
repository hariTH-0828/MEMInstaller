//
//  QRGenerator.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 11/12/24.
//

import Foundation
import CoreImage.CIFilterBuiltins
import UIKit

final class QRCodeGenerator {
    
    // MARK: - Properties
    /// QR Code generator filter.
    private static let filter = CIFilter.qrCodeGenerator()
    
    /// Correction level for QR code error handling.
    enum CorrectionLevel: String {
        case low = "L"     // Recovers up to 7% of data (Low)
        case medium = "M"  // Recovers up to 15% of data (Medium)
        case high = "Q"   // Recovers up to 25% of data (Quartile)
        case veryhigh = "H"    // Recovers up to 30% of data (High)
    }
    
    /// QR Code size presets.
    enum QRCodeSize: CGFloat {
        case low = 0.25
        case medium = 0.5
        case high = 0.75
        case veryhigh = 1.0
    }
    
    /// Generates a QR code image from the given string.
    /// - Parameters:
    ///   - string: The string to encode in the QR code.
    ///   - correctionLevel: The error correction level (default is high).
    /// - Returns: A UIImage representing the QR code, or nil if generation fails.
    static func generate(from string: String, quality: QRCodeSize = .high, correctionLevel: CorrectionLevel = .medium) -> Data? {
        // Create data from the input string
        guard let data = string.data(using: .ascii, allowLossyConversion: false) else { return nil }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(correctionLevel.rawValue, forKey: "inputCorrectionLevel")
        
        // Generate the CIImage for the QR Code.
        guard let ciImage = filter.outputImage else { return nil }
        
        // Scale the QR code image to a higher resolution.
        let transform = CGAffineTransform(scaleX: quality.rawValue * 10, y: quality.rawValue * 10)
        let scaledCIImage = ciImage.transformed(by: transform)
        
        return UIImage(ciImage: scaledCIImage).pngData()
    }
}
