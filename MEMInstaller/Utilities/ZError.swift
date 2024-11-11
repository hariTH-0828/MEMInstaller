//
//  ZError.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import Foundation

struct ZError {
    
    enum LocalError: Error, LocalizedError {
        case castingFailed
        case failedToSaveFile
        case failedToCreateDirectory
        case nilCheckFailed
        case noDataFound
        case failedToGetCacheSize
        case noFileFound
        
        var errorDescription: String? {
            switch self {
            case .castingFailed:
                return NSLocalizedString("Object typecasting failed", comment: "Error when converting to object.")
            case .failedToSaveFile:
                return NSLocalizedString("Failed to save file", comment: "Error when try to save file in the directory.")
            case .failedToCreateDirectory:
                return NSLocalizedString("Failed to create directory", comment: "Error when try to create a directory.")
            case .nilCheckFailed:
                return NSLocalizedString("Unwrapping failed", comment: "Error when try unwrapping the optional type.")
            case .noDataFound:
                return NSLocalizedString("No data available", comment: "Displayed when data is unavailable.")
            case .failedToGetCacheSize:
                return NSLocalizedString("Failed to get cache size", comment: "Displayed when failed to get cache directory size.")
            case .noFileFound:
                return NSLocalizedString("No file has been found", comment: "Displayed when there is not file exist in the provided url.")
            }
        }
    }
}
