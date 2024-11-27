//
//  ZFFileProtocol.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 27/11/24.
//

import Foundation
import UniformTypeIdentifiers

public protocol ZFFileProtocol: ObservableObject {
    var appCacheDirectory: URL { get }
    
    // Saving file
    func saveFileInCache(_ data: Data, withName fileName: String, type: UTType) throws -> URL
    func saveFileInTemp(with data: Data, fileType: UTType) throws -> URL
    
    // Copy file to cache
    func copyFileToCache(from sourceURL: URL, to destinationURL: URL) throws
    
    func getFileURLFromCache(fileName: String) throws -> URL
    func isFileExistInCache(fileName: String) -> Bool
    
    // Remove data from cache
    func clearAllCache() throws
    func removeCacheFile(fileName: String) throws
    func clearTempFiles() throws
    
    func getDirectorySize(at fileURL: URL) throws -> String
    func format(size: Int64) -> String
}
