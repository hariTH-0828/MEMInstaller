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
    
    enum IAMError: Error, LocalizedError {
        case userProfileNotFound
        case notSignedIn
        case tokenRetrievalFailed
        
        var errorDescription: String? {
            switch self {
            case .userProfileNotFound:
                return NSLocalizedString("User profile not found", comment: "Error when get current logged user profile")
            case .notSignedIn:
                return NSLocalizedString("User not signed in", comment: "Error when user check if the user is signin")
            case .tokenRetrievalFailed:
                return NSLocalizedString("Failed to retrive token", comment: "Error when try to fetch the access token")
            }
        }
    }
    
    enum KeyChainError: Error, LocalizedError {
        case failedToSave
        case failedToRetrieve
        
        var errorDescription: String? {
            switch self {
            case .failedToSave:
                return NSLocalizedString("Failed to save data to the Keychain", comment: "Keychain error when attempting to save data")
            case .failedToRetrieve:
                return NSLocalizedString("Failed to retrieve data from the Keychain", comment: "Keychain error when attempting to retrieve data")
            }
        }
    }
}
