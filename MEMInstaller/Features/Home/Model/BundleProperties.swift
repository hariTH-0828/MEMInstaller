//
//  BundleProperties.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import Foundation

struct BundleProperties: Decodable, Identifiable, Hashable {
    var id: String { bundleIdentifier ?? UUID().uuidString }
    let bundleName: String?
    let bundleVersionShort: String?
    let bundleVersion: String?
    let bundleIdentifier: String?
    let minimumOSVersion: String?
    let requiredDeviceCompability: [String]?
    let supportedPlatform: [String]?
    let bundleIcon: String?
    let redirectURL: String?
    
    enum CodingKeys: String, CodingKey {
        case bundleName = "CFBundleName"
        case bundleVersionShort = "CFBundleShortVersionString"
        case bundleVersion = "CFBundleVersion"
        case bundleIdentifier = "CFBundleIdentifier"
        case minimumOSVersion = "MinimumOSVersion"
        case requiredDeviceCompability = "UIRequiredDeviceCapabilities"
        case supportedPlatform = "CFBundleSupportedPlatforms"
        case bundleIcon = "CFBundleIcons"
        case redirectURL = "CFBundleURLTypes"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.bundleName = try container.decodeIfPresent(String.self, forKey: .bundleName)
        self.bundleVersionShort = try container.decodeIfPresent(String.self, forKey: .bundleVersionShort)
        self.bundleVersion = try container.decodeIfPresent(String.self, forKey: .bundleVersion)
        self.bundleIdentifier = try container.decodeIfPresent(String.self, forKey: .bundleIdentifier)
        self.minimumOSVersion = try container.decodeIfPresent(String.self, forKey: .minimumOSVersion)
        self.requiredDeviceCompability = try container.decodeIfPresent([String].self, forKey: .requiredDeviceCompability)
        self.supportedPlatform = try container.decodeIfPresent([String].self, forKey: .supportedPlatform)
        
        let bundleIconDecoder = try container.decodeIfPresent(BundleIcon.self, forKey: .bundleIcon)
        if let primaryIcon = bundleIconDecoder?.primaryIcon, let iconFiles = primaryIcon.iconFiles, let fileName = iconFiles.first {
            self.bundleIcon = fileName
        }else {
            self.bundleIcon = nil
        }
        
        let redirectURLDecoder = try container.decodeIfPresent([BundleURLTypes].self, forKey: .redirectURL)
        if let urlName = redirectURLDecoder?.first?.urlName {
            self.redirectURL = urlName
        }else { self.redirectURL = nil }
    }
    
    // Custom initializer for testing purposes
    init(
        bundleName: String?,
        bundleVersionShort: String?,
        bundleVersion: String?,
        bundleIdentifier: String?,
        minimumOSVersion: String? = nil,
        requiredDeviceCompability: [String] = ["arm64"],
        supportedPlatform: [String] = ["iPhoneOS"],
        bundleIcon: String? = nil,
        redirectURL: String? = "zadminfacimap"
    ) {
        self.bundleName = bundleName
        self.bundleVersionShort = bundleVersionShort
        self.bundleVersion = bundleVersion
        self.bundleIdentifier = bundleIdentifier
        self.minimumOSVersion = minimumOSVersion
        self.requiredDeviceCompability = requiredDeviceCompability
        self.supportedPlatform = supportedPlatform
        self.bundleIcon = bundleIcon
        self.redirectURL = redirectURL
    }
}

fileprivate struct BundleIcon: Decodable {
    let primaryIcon: PrimaryIcon?
        
    enum CodingKeys: String, CodingKey {
        case primaryIcon = "CFBundlePrimaryIcon"
    }
    
    struct PrimaryIcon: Decodable {
        let iconFiles: [String]?
        
        enum CodingKeys: String, CodingKey {
            case iconFiles = "CFBundleIconFiles"
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.iconFiles = try container.decodeIfPresent([String].self, forKey: .iconFiles)
        }
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.primaryIcon = try container.decodeIfPresent(PrimaryIcon.self, forKey: .primaryIcon)
    }
}

fileprivate struct BundleURLTypes: Decodable {
    let urlName: String
    
    enum CodingKeys: String, CodingKey {
        case urlName = "CFBundleURLName"
    }
}

// MARK: - Extensions for BundleProperties
extension BundleProperties {
    func value(for identifier: PListCellIdentifiers) -> String? {
        switch identifier {
        case .bundleName: return bundleName
        case .bundleIdentifiers: return bundleIdentifier
        case .bundleVersionShort: return bundleVersionShort
        case .bundleVersion: return bundleVersion
        case .minOSVersion: return minimumOSVersion
        case .requiredDevice: return requiredDeviceCompability?.joined(separator: ", ")
        case .supportedPlatform: return supportedPlatform?.joined(separator: ", ")
        }
    }
}
