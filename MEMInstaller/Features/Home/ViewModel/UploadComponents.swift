//
//  UploadComponents.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 28/11/24.
//

import Foundation

// MARK: - Enum for upload components
enum UploadComponentType {
    case application(String)
    case icon, infoPlist, provision
    case installerPlist(String)

    func endpoint(for path: String) -> ZAPIStrings.Endpoint {
        switch self {
        case .application(let appName): return .custom("/\(path)/\(appName).ipa")
        case .icon: return .custom("/\(path)/AppIcon60x60@2x.png")
        case .infoPlist: return .custom("/\(path)/Info.plist")
        case .provision: return .custom("/\(path)/embedded.mobileprovision")
        case .installerPlist(let appName): return .custom("/\(path)/\(appName).plist")
        }
    }

    var contentType: ContentType {
        switch self {
        case .application, .infoPlist, .installerPlist: return .document
        case .icon: return .png
        case .provision: return .mobileProvision
        }
    }
}
