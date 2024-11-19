//
//  ZAPIStrings.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 13/11/24.
//

import Foundation

struct ZAPIStrings {
    
    static let BASE_URL: String = "https://console.catalyst.zoho.com/baas/v1/project/21317000000012001"
    static let UPLOAD_BASE_URL: String = "https://packages-development.zohostratus.com"
    
    enum Endpoint {
        case bucket
        case objects
        case custom(String)
        
        var path: String {
            switch self {
            case .bucket:
                return "/bucket"
            case .objects:
                return "/bucket/objects"
            case .custom(let customPath):
                return customPath
            }
        }
    }
}
