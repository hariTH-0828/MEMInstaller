//
//  ZFFileManager.swift
//  ZorroWare
//
//  Created by Hariharan R S on 27/08/24.
//

import SwiftUI
import UniformTypeIdentifiers

/// A structure that represents a file object with relevant metadata.
/// Conforms to `Hashable` to allow use in collections that require hashing.
struct ZFFileObject: Hashable {
    let fileName: String
    let fileSize: Int
    let fileLocation: URL
    let fileType: String
    let fileData: Data
    
    // Implement the Hashable protocol
    func hash(into hasher: inout Hasher) {
        hasher.combine(fileName)
        hasher.combine(fileSize)
        hasher.combine(fileLocation)
        hasher.combine(fileType)
    }
    
    // Ensure equality is based on relevant properties
    static func == (lhs: ZFFileObject, rhs: ZFFileObject) -> Bool {
        return lhs.fileName == rhs.fileName &&
               lhs.fileSize == rhs.fileSize &&
               lhs.fileLocation == rhs.fileLocation &&
               lhs.fileType == rhs.fileType
    }
}

class ZFFileManager: ZFFileProtocol {
    static let shared = ZFFileManager()
    
    private let fileManager = FileManager.default
    
    /// An array of `ZFFileObject` representing the files selected by the user.
    /// This property is published and updated when files are selected, allowing any observers to react to changes.
    @Published private(set) var selectedFiles = [ZFFileObject]()
    
    private init() { }
    
    /// Returns the URL of the cache directory for the application.
    /// If the directory does not exist, it creates the directory.
    /// - Returns: URL of the app's cache directory.
    internal var appCacheDirectory: URL {
        let cacheDirectoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            fatalError("Bundle Identifier is missing. Unable to locate the cache directory.")
        }
        
        let appSpecificCacheDirectoryURL = cacheDirectoryURL.appendingPathComponent(bundleIdentifier, isDirectory: true)
        
        return createCacheDirectory(of: appSpecificCacheDirectoryURL)
    }
    
    private func createCacheDirectory(of cacheDirectoryURL: URL) -> URL {
        // Create a directory if it does not exist
        if !fileManager.fileExists(atPath: cacheDirectoryURL.path(percentEncoded: true)) {
            do {
                try fileManager.createDirectory(at: cacheDirectoryURL, withIntermediateDirectories: true)
                ZLogs.shared.info("Successfully created cache directory at \(cacheDirectoryURL.path)")
            }catch {
                ZLogs.shared.error("Error creating cache directory at \(cacheDirectoryURL.path): \(error.localizedDescription)")
            }
        }
        
        return cacheDirectoryURL
    }
    
    /// Retrieves the application cache directory.
    /// - Returns: URL of the cache directory.
    func getAppCacheDirectory() -> URL {
        return appCacheDirectory
    }
    
    /// Handles selected file URLs, loads their data, and stores them in the `selectedFiles` property.
    /// - Parameter urls: An array of file URLs selected by the user.
    public func handleFileSelection(_ urls: [URL]) {
        selectedFiles = urls.compactMap { url in
            guard let fileData = try? Data(contentsOf: url) else { return nil }
            let fileName = url.lastPathComponent
            let fileSize = fileData.count
            let fileType = url.pathExtension
            return ZFFileObject(fileName: fileName, fileSize: fileSize, fileLocation: url, fileType: fileType, fileData: fileData)
        }
    }
    
    /// Stores a file in the cache directory and returns the URL of the saved file.
    /// - Parameters:
    ///   - data: The file data to be saved.
    ///   - fileName: The name of the file.
    ///   - type: The file type (UTType) of the file.
    /// - Returns: URL of the saved file in the cache directory.
    /// - Throws: An error if the file cannot be saved.
    public func saveFileInCache(_ data: Data, withName fileName: String, type: UTType) throws -> URL {
        let fileURL = appCacheDirectory.appendingPathComponent(fileName, conformingTo: type)
        do { try data.write(to: fileURL) }
        catch { throw error }
        return fileURL
    }
    
    public func copyFileToCache(from sourceURL: URL, to destinationURL: URL) throws {
        if sourceURL.startAccessingSecurityScopedResource() {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
        }else {
            ZLogs.shared.warning("Permission denied")
        }
        sourceURL.stopAccessingSecurityScopedResource()
    }
    
    /// Checks if a file exists in the cache directory by its name.
    /// - Parameter fileName: The name of the file to check.
    /// - Returns: A Boolean indicating whether the file exists in the cache directory.
    public func isFileExistInCache(fileName: String) -> Bool {
        let fileURL = appCacheDirectory.appending(path: fileName)
        return fileManager.fileExists(atPath: fileURL.path())
    }
    
    /// Retrieves the URL of a file in the cache directory.
    /// - Parameter fileName: The name of the file.
    /// - Returns: The URL of the file in the cache directory.
    /// - Throws: `ZError.LocalError.noDataFound` if the file does not exist.
    public func getFileURLFromCache(fileName: String) throws -> URL {
        if isFileExistInCache(fileName: fileName) {
            let fileURL = appCacheDirectory.appending(path: fileName)
            return fileURL
        }
        
        throw ZError.LocalError.noDataFound
    }
    
    /// Saves file data to a temporary location and returns the URL of the saved file.
    /// - Parameters:
    ///   - data: The file data to be saved.
    ///   - fileType: The type (UTType) of the file.
    /// - Returns: URL of the saved file in the temporary directory.
    /// - Throws: An error if the file cannot be saved.
    public func saveFileInTemp(with data: Data, fileType: UTType) throws -> URL {
        let originalName = generateFileName(with: fileType)
        let fileURL = fileManager.temporaryDirectory.appendingPathComponent(originalName)
        do { try data.write(to: fileURL) }
        catch { throw error }
        return fileURL
    }
    
    /// Deletes all files from the cache directory.
    /// - Throws: An error if the deletion fails.
    public func clearAllCache() throws {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: appCacheDirectory, includingPropertiesForKeys: nil)
            try fileURLs.forEach({ try fileManager.removeItem(at: $0) })
        }catch {
            throw error
        }
    }
    
    /// Deletes a specific file from the cache directory by its name.
    /// - Parameter fileName: The name of the file to delete.
    /// - Throws: An error if the deletion fails.
    public func removeCacheFile(fileName: String) throws {
        let fileURL = appCacheDirectory.appending(component: fileName)
        do { try fileManager.removeItem(at: fileURL) }
        catch { throw error }
    }
    
    /// Deletes all files from the temporary directory.
    /// - Throws: An error if the deletion fails.
    public func clearTempFiles() throws {
        let fileURLs = fileManager.temporaryDirectory
        try fileManager.removeItem(atPath: fileURLs.path())
    }
    
    /// Deletes a file at a given URL.
    /// - Parameter url: The URL of the file to delete.
    /// - Throws: An error if the deletion fails.
    public func removeItemUsing(fileURL url: URL) throws {
        if fileManager.fileExists(atPath: url.path()) {
            try fileManager.removeItem(atPath: url.path())
        }
    }
    
    /// Generates a unique file name using the current date and time, with the specified file extension.
    /// - Parameter fileExtension: The UTType of the file extension.
    /// - Returns: A unique file name as a String.
    public func generateFileName(with fileExtension: UTType) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd'@'hh-mm"
        let dateString = dateFormatter.string(from: Date())
        return "file_\(dateString).\(fileExtension.preferredFilenameExtension!)"
    }
    
    /// Retrieves the total size of a directory in a human-readable format.
    /// - Parameter fileURL: The URL of the directory to calculate the size for.
    /// - Returns: A formatted string representing the total size of the directory.
    /// - Throws: `ZError.LocalError.failedToGetCacheSize` if the size calculation fails.
    public func getDirectorySize(at fileURL: URL) throws -> String {
        do {
            let files = try fileManager.contentsOfDirectory(at: fileURL, includingPropertiesForKeys: [.fileSizeKey], options: [.skipsHiddenFiles])
            
            var totalSize: Int64 = 0
            
            for file in files {
                let attribute = try fileManager.attributesOfItem(atPath: file.path())
                if let fileSize = attribute[.size] as? Int64 {
                    totalSize += fileSize
                }
            }
            
            return format(size: totalSize)
        }catch {
            throw ZError.LocalError.failedToGetCacheSize
        }
    }
    
    /// Formats the size of a folder into a human-readable string.
    /// - Parameter size: The size of the folder in bytes.
    /// - Returns: A string representing the folder size.
    internal func format(size: Int64) -> String {
        let folderSizeAsString = ByteCountFormatter.string(fromByteCount: size, countStyle: ByteCountFormatter.CountStyle.file)
        return folderSizeAsString
    }
}
