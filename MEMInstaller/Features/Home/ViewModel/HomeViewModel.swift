//
//  HomeViewModel.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI
import Zip

@MainActor
class HomeViewModel: ObservableObject {
    @Published private(set) var userprofile: ZCUserProfile?
    @Published private(set) var appIcon: Data?
    @Published var bundleProperties: BundleProperties?
    @Published var isFileLoaded: Bool = false
    
    private var sourceURL: URL?
    var plistDictionary: [String: Any] = [:] {
        didSet {
            loadBundleProperties()
        }
    }
    
    // Property Handler
    private let plistHandler = PropertyListHandler()
    
    // FileManager
    private let fileManager = FileManager.default
    private let appCacheDirectory = ZFFileManager.shared.getAppCacheDirectory()
    
    // Toast
    @Published private(set) var toastMessage: String?
    @Published var isPresentToast: Bool = false
    
    init() {
        retriveLoggedUserFromKeychain()
    }
    
    // MARK: - User Profile
    private func retriveLoggedUserFromKeychain() {
        do {
            self.userprofile = try KeychainService.retrieve(forKey: KCKeys.loggedUserProfile)
        }catch {
            presentToast(message: error.localizedDescription)
        }
    }
    
    // MARK: - Bundle Info
    func extractIpaFileContents(from sourceURL: URL) {
        guard let zipLocation = convertFileIpaToZip(from: sourceURL, to: "zip") else {
            ZLogs.shared.warning("File conversion failed")
            self.presentToast(message: "File conversion failed")
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
            presentToast(message: error.localizedDescription)
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
            presentToast(message: "Permission denied")
        }
        sourceURL.stopAccessingSecurityScopedResource()
    }
    
    // MARK: - Directory Managerment
    private func clearDirectory(at directory: URL) {
        do {
            try ZFFileManager.shared.clearAllCache()
        }catch {
            ZLogs.shared.warning("Failed to clear cache directory: \(error.localizedDescription)")
            presentToast(message: error.localizedDescription)
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
            presentToast(message: error.localizedDescription)
        }
    }
    
    private func processAppBundleContents(at payLoadPath: URL) throws {
        let contents = try fileManager.subpathsOfDirectory(atPath: payLoadPath.path())
        
        guard let appName = contents.first, contents.contains("\(appName)/Info.plist") else {
            ZLogs.shared.warning("Info.plist does not exist at path: \(payLoadPath.appending(path: contents[0]))")
            return
        }
        
        try extractAppProperties(from: payLoadPath, appName: appName)
        self.isFileLoaded.toggle()
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
            presentToast(message: error.localizedDescription)
        }
    }
    
    func presentToast(message: String?) {
        toastMessage = message
        isPresentToast = true
    }
}
