//
//  ZAPIStrings.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 13/11/24.
//

import Foundation
import Alamofire

struct ZAPIStrings {
    
    static let BASE_URL: String = "https://console.catalyst.zoho.com/baas/v1/project/21317000000012001"
    static let UPLOAD_BASE_URL: String = "https://packages-development.zohostratus.com"
    
    enum Endpoint {
        case bucket
        case objects
        case delete
        case custom(String)
        
        var path: String {
            switch self {
            case .bucket: return "/bucket"
            case .objects: return "/bucket/objects"
            case .delete: return "/bucket/object/prefix"
            case .custom(let customPath): return customPath
            }
        }
    }
    
    enum Parameter {
        case folders(String)
        case packageURL(String)
        case delete(String)
        
        var value: Alamofire.Parameters {
            switch self {
            case .folders(let path):
                return ["bucket_name": "packages", "prefix": "\(path)/"]
            case .packageURL(let packageURL):
                return ["bucket_name": "packages", "prefix": "\(packageURL)/"]
            case .delete(let prefix):
                return ["bucket_name": "packages", "prefix": prefix]
            }
        }
    }
}
