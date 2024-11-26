//
//  MobileProvision.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 26/11/24.
//

import Foundation

struct MobileProvision {
    let name: String
    let teamIdentifier: [String]
    let creationDate: Date
    let expirationDate: Date
    let teamName: String
    let version: Int
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case teamIdentifier = "TeamIdentifier"
        case creationDate = "CreationDate"
        case expirationDate = "ExpirationDate"
        case teamName = "TeamName"
        case version = "Version"
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
