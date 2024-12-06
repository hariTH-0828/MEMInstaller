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
    
    init() {
        self.prefix = "hariharan.rs@zohocorp.com/SDP/"
        self.keyCount = 2
        self.contents = [
            ContentModel(keyType: .file, key: "hariharan.rs@zohocorp.com/SDP/embedded.mobileprovision", size: 12732, contentType: .mobileProvision, lastModified: "", url: "https://packages-development.zohostratus.com/hariharan.rs@zohocorp.com/SDP/embedded.mobileprovision"),
            ContentModel(keyType: .file, key: "hariharan.rs@zohocorp.com/SDP/SDP.plist", size: 775, contentType: .document, lastModified: "", url: "https://packages-development.zohostratus.com/hariharan.rs@zohocorp.com/SDP/SDP.plist"),
            ContentModel(keyType: .file, key: "hariharan.rs@zohocorp.com/SDP/Info.plist", size: 3823, contentType: .document, lastModified: "", url: "https://packages-development.zohostratus.com/hariharan.rs@zohocorp.com/SDP/Info.plist"),
            ContentModel(keyType: .file, key: "hariharan.rs@zohocorp.com/SDP/AppIcon60x60@2x.png", size: 25390, contentType: .png, lastModified: "", url: "https://packages-development.zohostratus.com/hariharan.rs@zohocorp.com/SDP/AppIcon60x60@2x.png"),
            ContentModel(keyType: .file, key: "hariharan.rs@zohocorp.com/SDP/SDP.ipa", size: 24059477, contentType: .document, lastModified: "", url: "https://packages-development.zohostratus.com/hariharan.rs@zohocorp.com/SDP/SDP.ipa"),
        ]
        self.folderName = "SDP"
    }
}

struct ContentModel: Codable, Hashable {
    let keyType: String
    let key: String
    let size: Decimal
    let contentType: String?
    let lastModified: String
    let url: String
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
    }
    
    init(keyType: ContentKeyType, key: String, size: Decimal, contentType: ContentType, lastModified: String, url: String) {
        self.keyType = keyType.rawValue
        self.key = key
        self.size = size
        self.contentType = contentType.rawValue
        self.lastModified = lastModified
        self.url = url
        self.actualKeyType = keyType
        self.actualContentType = contentType
    }
}

extension BucketObjectModel {
    // MARK: - HELPER METHODS
    static var preview: BucketObjectModel {
        BucketObjectModel()
    }
    
    func getAppIcon() -> String? {
        self.contents.first(where: { $0.actualContentType == .png && $0.key.contains("AppIcon60x60@") })?.url
    }
    
    func getPackageURL() -> String? {
        contents.filter({ $0.actualContentType == .document && $0.key.contains(".ipa")}).first?.url
    }
    
    func getInfoPropertyListURL() -> String? {
        contents.first(where: { $0.actualContentType == .document && $0.key.contains("Info.plist") })?.url
    }
    
    func getMobileProvisionURL() -> String? {
        contents.first(where: { $0.actualContentType == .mobileProvision && $0.key.contains("embedded.mobileprovision") })?.url
    }
    
    func getObjectURL() -> String? {
        contents.first(where: { $0.actualContentType == .document && $0.key.contains("\(folderName).plist") })?.url
    }
    
    /// Calculates the size of a package based on its contents.
    ///
    /// This method filters the provided content list to find the first item with a `.file` key type
    /// and a key containing `.ipa`, then calculates its size.
    ///
    /// - Returns: A `String` representing the calculated size of the package, formatted by `calculatePackageSize`.
    ///
    /// - Note: If no `.ipa` file is found in the contents, the size will be determined as `0` and handled by `calculatePackageSize`.
    ///
    /// - SeeAlso: `calculatePackageSize(_:)`
    func getPackageFileSize() -> String {
        let packageSizeAsBytes = contents.filter({ $0.actualKeyType == .file && $0.key.contains(".ipa") }).first?.size
        return calculatePackageSize(packageSizeAsBytes)
    }
    
    /// Calculates the size of a package in megabytes (MB) and returns a formatted string.
    /// - Parameter size: The size in bytes (Decimal?). If the value is nil, it returns "0 MB".
    /// - Returns: A string representing the size in MB, formatted with two decimal places (default behavior).
    func calculatePackageSize(_ size: Decimal?) -> String {
        guard let size else { return "0 MB" }
        let sizeInMB = size / 1048576
        return sizeInMB.formattedString() + " MB"
    }
}
