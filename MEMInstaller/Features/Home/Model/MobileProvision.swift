//
//  MobileProvision.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 26/11/24.
//

import Foundation

struct MobileProvision: Hashable {
    let name: String
    let teamIdentifier: [String]
    let creationDate: Date
    let expirationDate: Date
    let teamName: String
    let version: Int
    var isExpired: Bool {
        isMobileProvisionValid(expirationDate.formatted(date: .abbreviated, time: .shortened))
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case teamIdentifier = "TeamIdentifier"
        case creationDate = "CreationDate"
        case expirationDate = "ExpirationDate"
        case teamName = "TeamName"
        case version = "Version"
    }
    
    init?(from dictionary: [String: Any]) {
        guard let name = dictionary[CodingKeys.name.rawValue] as? String,
              let teamIdentifier = dictionary[CodingKeys.teamIdentifier.rawValue] as? [String],
              let creationDate = dictionary[CodingKeys.creationDate.rawValue] as? Date,
              let expirationDate = dictionary[CodingKeys.expirationDate.rawValue] as? Date,
              let teamName = dictionary[CodingKeys.teamName.rawValue] as? String,
              let version = dictionary[CodingKeys.version.rawValue] as? Int else {
            return nil
        }
        
        self.name = name
        self.teamIdentifier = teamIdentifier
        self.creationDate = creationDate
        self.expirationDate = expirationDate
        self.teamName = teamName
        self.version = version
    }
    
    private func isMobileProvisionValid(_ date: String?) -> Bool {
        guard let expireDate = date?.dateFormat(by: "d MMM yyyy 'at' h:mm a") else { return false }
        return expireDate < Date()
    }
}

struct Entitlements: Codable {
    let teamIdentifier: [String]?
    let getTaskAllow: Bool?
    let applicationIdentifier: String?
    let apsEnvironment: String?
    let keychainAccessGroups: [String]?
    
    enum CodingKeys: String, CodingKey {
        case teamIdentifier = "com.apple.developer.team-identifier"
        case getTaskAllow = "get-task-allow"
        case applicationIdentifier = "application-identifier"
        case apsEnvironment = "aps-environment"
        case keychainAccessGroups = "keychain-access-groups"
    }
}

// MARK: - Extensions for MobileProvision
extension MobileProvision {
    func value(for identifier: ProvisionCellIdentifiers) -> String? {
        switch identifier {
        case .name: return name
        case .teamIdentifier: return teamIdentifier.joined(separator: ", ")
        case .creationDate: return creationDate.formatted(date: .abbreviated, time: .shortened)
        case .expiredDate: return expirationDate.formatted(date: .abbreviated, time: .shortened)
        case .teamName: return teamName
        case .version: return String(version)
        }
    }
}
