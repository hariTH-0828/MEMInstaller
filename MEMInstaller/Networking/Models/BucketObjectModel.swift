//
//  BucketObjectModel.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 15/11/24.
//

import Foundation

enum ContentKeyType: String {
    case folder = "folder"
    case file = "file"
}

enum ContentType: String {
    case document = "application/octet-stream"
    case mobileProvision = "application/x-apple-aspen-mobileprovision"
    case png = "image/png"
}

struct BucketObjectModel: Codable, Hashable {
    let prefix: String
    let keyCount: Int
    let contents: [ContentModel]
    let folderName: String
    
    var id: Self { return self }
    
    enum CodingKeys: String, CodingKey {
        case prefix = "prefix"
        case keyCount = "key_count"
        case contents = "contents"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.prefix = try container.decode(String.self, forKey: .prefix)
        self.keyCount = try container.decode(Int.self, forKey: .keyCount)
        self.contents = try container.decode([ContentModel].self, forKey: .contents)
        
        // Get the folder name from the prefix
        let paths = prefix.components(separatedBy: "/")
        self.folderName = paths.count > 2 ? paths[paths.count - 2] : paths[0]
    }
}

struct ContentModel: Codable, Hashable {
    let keyType: String
    let key: String
    let size: Decimal
    let contentType: String?
    let lastModified: String
    let url: String
//    let folderName: String
    let actualKeyType: ContentKeyType
    let actualContentType: ContentType
    
    enum CodingKeys: String, CodingKey {
        case keyType = "key_type"
        case key = "key"
        case size = "size"
        case contentType = "content_type"
        case lastModified = "last_modified"
        case url = "object_url"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.keyType = try container.decode(String.self, forKey: .keyType)
        self.actualKeyType = ContentKeyType(rawValue: keyType)!
        self.key = try container.decode(String.self, forKey: .key)
        self.size = try container.decode(Decimal.self, forKey: .size)
        self.url = try container.decode(String.self, forKey: .url)
        self.lastModified = try container.decode(String.self, forKey: .lastModified)
        self.contentType = try container.decodeIfPresent(String.self, forKey: .contentType)
        self.actualContentType = ContentType(rawValue: contentType ?? "application/octet-stream")!
//        self.folderName = URL(string: url)!.lastPathComponent
    }
    
    init() {
        self.keyType = "file"
        self.key = "hariharan.rs@zohocorp.com/ZohoFaciMap/Info.plist"
        self.size = 6095
        self.contentType = "application/octet-stream"
        self.lastModified = "Nov 16, 2024 11:08 PM"
        self.url = "https://packages-development.zohostratus.com/hariharan.rs@zohocorp.com/ZohoFaciMap/Info.plist"
        self.actualKeyType = .file
        self.actualContentType = .document
//        self.folderName = "Info"
    }
}
