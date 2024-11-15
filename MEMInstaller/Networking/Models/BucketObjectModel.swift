//
//  BucketObjectModel.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 15/11/24.
//

import Foundation

struct BucketObjectModel: Codable, Hashable {
    let prefix: String?
    let keyCount: Int
    let contents: [ContentModel]
    
    var id: Self { return self }
    
    enum CodingKeys: String, CodingKey {
        case prefix = "prefix"
        case keyCount = "key_count"
        case contents = "contents"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.prefix = try container.decodeIfPresent(String.self, forKey: .prefix)
        self.keyCount = try container.decode(Int.self, forKey: .keyCount)
        self.contents = try container.decode([ContentModel].self, forKey: .contents)
    }
}

struct ContentModel: Codable, Hashable {
    let keyType: String
    let key: String
    let size: Decimal
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case keyType = "key_type"
        case key = "key"
        case size = "size"
        case url = "object_url"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.keyType = try container.decode(String.self, forKey: .keyType)
        self.key = try container.decode(String.self, forKey: .key)
        self.size = try container.decode(Decimal.self, forKey: .size)
        self.url = try container.decode(String.self, forKey: .url)
    }
}
