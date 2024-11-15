//
//  PackageExtractionHandler.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 15/11/24.
//

import Foundation
import Zip
import SwiftUI

class PackageExtractionHandler {
    // Property Handler
    private let plistHandler = PropertyListHandler()
    private var sourceURL: URL? = nil
    private(set) var appIcon: Data?
    var bundleProperties: BundleProperties?
    
    var plistDictionary: [String: Any] = [:] {
        didSet {
            loadBundleProperties()
        }
    }
    
    // Attachment View
    @Published var shareItem: [URL] = []
    
    // FileManager
    private let fileManager = FileManager.default
    private let appCacheDirectory = ZFFileManager.shared.getAppCacheDirectory()
    
    // MARK: - Bundle Info
    func extractIpaFileContents(from sourceURL: URL) {
        guard let zipLocation = convertFileIpaToZip(from: sourceURL, to: "zip") else {
            ZLogs.shared.warning("File conversion failed")
            return
        }
        
        ZLogs.shared.info("ZIP Location: \(zipLocation)")
        unzip(from: zipLocation)
    }
    
    // MARK: - File Conversion
    private func convertFileIpaToZip(from sourceURL: URL, to newExtension: String) -> URL? {
        self.sourceURL = sourceURL
        
        do {
            // clear the old data
            clearDirectory(at: appCacheDirectory)
            
            let newFileURL = createZipFileURL(from: sourceURL)
            try copyFileToCache(from: sourceURL, to: newFileURL)
            return newFileURL
        }catch {
            ZLogs.shared.error(error.localizedDescription)
            return nil
        }
    }
    
    private func createZipFileURL(from sourceURL: URL) -> URL {
        let fileName = sourceURL.deletingPathExtension().lastPathComponent
        return appCacheDirectory.appendingPathComponent(fileName, conformingTo: .zip)
    }
    
    private func copyFileToCache(from sourceURL: URL, to destinationURL: URL) throws {
        if sourceURL.startAccessingSecurityScopedResource() {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
        }else {
            ZLogs.shared.warning("Permission denied")
        }
        sourceURL.stopAccessingSecurityScopedResource()
    }
    
    // MARK: - Directory Managerment
    private func clearDirectory(at directory: URL) {
        do {
            try ZFFileManager.shared.clearAllCache()
        }catch {
            ZLogs.shared.warning("Failed to clear cache directory: \(error.localizedDescription)")
        }
    }
    
    func unzip(from sourceURL: URL) {
        do {
            try Zip.unzipFile(sourceURL, destination: appCacheDirectory, overwrite: true, password: "")
        }catch {
            ZLogs.shared.warning("Failed to unzip: \(error.localizedDescription)")
        }
    }
    
    func extractAppBundle() {
        let payLoadPath = appCacheDirectory.appending(path: "Payload")
        
        guard fileManager.fileExists(atPath: payLoadPath.path()) else {
            ZLogs.shared.warning("App bundle does not exist at path: \(payLoadPath)")
            return
        }
        
        do {
            try processAppBundleContents(at: payLoadPath)
        }catch {
            ZLogs.shared.warning(error.localizedDescription)
        }
    }
    
    private func processAppBundleContents(at payLoadPath: URL) throws {
        let contents = try fileManager.subpathsOfDirectory(atPath: payLoadPath.path())
        
        guard let appName = contents.first, contents.contains("\(appName)/Info.plist") else {
            ZLogs.shared.warning("Info.plist does not exist at path: \(payLoadPath.appending(path: contents[0]))")
            return
        }
        
        try extractAppProperties(from: payLoadPath, appName: appName)
    }
    
    private func extractAppProperties(from payLoadPath: URL, appName: String) throws {
        let infoPlistPath = (payLoadPath.path() as NSString).appendingPathComponent("\(appName)/Info.plist")
        let appIconPath = (payLoadPath.path() as NSString).appendingPathComponent("\(appName)/AppIcon60x60@2x.png")
        
        if let infoPlistData = fileManager.contents(atPath: infoPlistPath) {
            try parseInfoPlist(infoPlistData)
        }
        
        if let appIconData = fileManager.contents(atPath: appIconPath) {
            self.appIcon = appIconData
        }
    }
    
    private func parseInfoPlist(_ infoPlistData: Data) throws {
        if let plist = try PropertyListSerialization.propertyList(from: infoPlistData, format: nil) as? [String: Any] {
            self.plistDictionary = plist
        }else {
            ZLogs.shared.error("Failed to cast Info.plist content to directory.")
        }
    }
    
    // MARK: - Bundle property manage
    func loadBundleProperties() {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: plistDictionary)
            
            let decoder = JSONDecoder()
            self.bundleProperties = try decoder.decode(BundleProperties.self, from: jsonData)
        }catch {
            ZLogs.shared.error(error.localizedDescription)
        }
    }
    
    func generatePrivacyList(completion: @escaping () -> Void) {
        // MARK: UPDATE URL OF YOU FILE
        let fileName = sourceURL?.lastPathComponent
        
        guard let fileName, let fileURL = URL(string: "https://packages-development.zohostratus.com/ipa/\(fileName)") else {
            ZLogs.shared.log(.warning, message: "Invalid file url")
            return
        }
  
        let plistURL = plistHandler.createPlistFile(url: fileURL.absoluteString, content: plistDictionary)
        switch plistURL {
        case .success(let pathLocation):
            shareItem = [pathLocation]
            completion()
        case .failure(let failure):
            ZLogs.shared.error(failure.localizedDescription)
        }
    }
    
    // MARK: - Execute Install
    func executeInstall(_ url: String) {
        let itmsServicesURLString = "itms-services://?action=download-manifest&url=\(url)"

        if let itmsServiceURL = URL(string: itmsServicesURLString) {
            UIApplication.shared.open(itmsServiceURL)
        }
    }
}
