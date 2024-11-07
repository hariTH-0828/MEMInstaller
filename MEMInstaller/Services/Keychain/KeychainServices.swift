//
//  KeychainServices.swift
//  ZorroWare
//
//  Created by Hariharan R S on 14/05/24.
//

import Foundation
import Security

enum KeychainError: Error {
    case noPassword                 // No password found for the given key
    case unexpectedPasswordData     // Unexpected data type retrieved from Keychain
    case unableToAccess             // Failed to access Keychain
    case unableToSave               // Failed to save data to Keychain
    case unableToDelete             // Failed to delete data from Keychain
    case notFound                   // No data are found
}

/// Service to manage saving, retrieving, and deleting data in Keychain
struct KeychainService {
    
    /// Saves a value of any Codable type into the Keychain for a specified key
    /// - Parameters:
    ///   - value: The value to be saved, must conform to Codable
    ///   - key: The key used to identify the stored value
    /// - Throws: Throws KeychainError.unableToSave if saving fails
    static func save<T: Codable>(value: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(value)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unableToSave
        }
    }
    
    /// Retrieves a value of any Codable type from the Keychain for a specified key
    /// - Parameter key: The key used to retrieve the value
    /// - Returns: The decoded value of the specified Codable type
    /// - Throws: Throws specific KeychainError cases if retrieval fails
    static func retrieve<T: Codable>(forKey key: String) throws -> T {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.notFound
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unableToAccess
        }
        
        guard let data = item as? Data else {
            throw KeychainError.unexpectedPasswordData
        }
        
        let value = try JSONDecoder().decode(T.self, from: data)
        return value
    }
    
    /// Deletes an item from the Keychain for a specified key
    /// - Parameter key: The key for the item to be deleted
    /// - Throws: Throws KeychainError.unableToDelete if deletion fails
    static func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unableToDelete
        }
    }
    
    /// Update an existing item in the Keychain
    /// - Parameters:
    ///   - value: The value to update, must conform to Codable
    ///   - key: The key used to identify the stored value
    /// - Throws: Throws KeychainError if updating fails
    static func update<T: Codable>(value: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(value)
        
        // Query to find the existing item
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        if status == errSecItemNotFound {
            try save(value: value, forKey: key)
        } else if status != errSecSuccess {
            throw KeychainError.unableToSave
        }
    }
}

