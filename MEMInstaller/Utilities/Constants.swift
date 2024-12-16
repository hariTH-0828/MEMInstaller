//
//  Constants.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 28/11/24.
//

import Foundation

struct Constants {
    static let payload: String = "Payload"
    static let infoPlist: String = "Info.plist"
    static let embeddedProvision: String = "embedded.mobileprovision"
    static let appIconName: String = "AppIcon60x60@2x.png"
    static let installationPrefix: String = "itms-services://?action=download-manifest&url="
    
    enum FilePath {
        case infoPlist(String)
        case embeddedProvision(String)
        case appIcon(String)
        
        var path: String {
            switch self {
            case .infoPlist(let string):
                return "\(string)/\(Constants.infoPlist)"
            case .embeddedProvision(let string):
                return "\(string)/\(Constants.embeddedProvision)"
            case .appIcon(let string):
                return "\(string)/\(Constants.appIconName)"
            }
        }
    }
}
