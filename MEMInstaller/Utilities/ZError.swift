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
    
    enum NetworkError: Error, LocalizedError {
        case tokenRetrievalFailed
        case badURL
        case badServerResponse
        case userAuthenticationRequired
        case noDataAvailable
        case accessRestricted
        case noNetworkAvailable
        case conflict
        case payloadTooLarge
        case tooManyRequest
        case serialization
        case timeOut
        case unknown
        case downloadFailed
        case invalidResponse
        
        var errorDescription: String? {
            switch self {
            case .tokenRetrievalFailed:
                return NSLocalizedString("Token retrieval error", comment: "Error when failing to retrieve token")
            case .badURL:
                return NSLocalizedString("Bad URL", comment: "Error when URL is malformed")
            case .badServerResponse:
                return NSLocalizedString("Bad server response", comment: "Error when server response is invalid")
            case .userAuthenticationRequired:
                return NSLocalizedString("User Authentication Failed", comment: "Error when user authentication fails")
            case .noDataAvailable:
                return NSLocalizedString("No data available", comment: "Error when no data is available")
            case .accessRestricted:
                return NSLocalizedString("You don't have permission to access this application.", comment: "Error when access is restricted")
            case .noNetworkAvailable:
                return NSLocalizedString("No network available", comment: "Error when try to make network call.")
            case .conflict:
                return NSLocalizedString("Network call conflict", comment: "Error when network call response at a same with different data.")
            case .payloadTooLarge:
                return NSLocalizedString("Payload Too Large", comment: "Data size is too large to perform this action.")
            case .tooManyRequest:
                return NSLocalizedString("Too many calls are requested", comment: "Error when try to make a continuous network call.")
            case .serialization:
                return NSLocalizedString("Data serialization failed", comment: "Error when network body is not match with codable.")
            case .timeOut:
                return NSLocalizedString("Request time out", comment: "Error when request time limit reached.")
            case .unknown:
                return NSLocalizedString("Something went wrong", comment: "Error when network responses are not match with us.")
            case .downloadFailed:
                return NSLocalizedString("Failed to download file", comment: "Error with some network reason or url may or maybe in wrong format.")
            case .invalidResponse:
                return NSLocalizedString("Invalid or missing HTTP response", comment: "Displayed when the HTTP response is invalid or missing")
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
