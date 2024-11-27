//
//  PackageExtractionHandler.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 15/11/24.
//

import Foundation
import Zip
import SwiftUI

class PackageExtractionDataManager {
    private(set) var appIcon: Data?
    private(set) var sourceFileData: Data?
    private(set) var infoPlistData: Data?
    private(set) var installablePropertyListData: Data?
    
    func setAppIcon(_ icon: Data?) {
        self.appIcon = icon
    }
    
    func setSourceFileData(_ source: Data?) {
        self.sourceFileData = source
    }
    
    func setInfoData(_ info: Data?) {
        self.infoPlistData = info
    }
    
    func setInstallablePropertyData(_ info: Data?) {
        self.installablePropertyListData = info
    }
    
    func reset() {
        appIcon = nil
        sourceFileData = nil
        infoPlistData = nil
        installablePropertyListData = nil
    }
}

class PackageExtractionHandler {
    // Property Handler
    let plistHandler = PropertyListHandler()
    let packageDataManager = PackageExtractionDataManager()
    
    private var sourceURL: URL!
    
    var bundleProperties: BundleProperties?
    var mobileProvision: MobileProvision?
    var objectURL: String?
    
    // Attachment View
    @Published var shareItem: [URL] = []
    
    // FileManager
    private let fileManager = FileManager.default
    private let appCacheDirectory = ZFFileManager.shared.getAppCacheDirectory()
    
    func initiateAppExtraction(from url: URL) {
        self.sourceURL = url
        
        if sourceURL.startAccessingSecurityScopedResource() {
            packageDataManager.setSourceFileData(fileToData(from: sourceURL))
            sourceURL.stopAccessingSecurityScopedResource()
        }
        extractIpaFileContents()
        extractAppBundle()
    }
    
    // MARK: - Convert source as data
    func fileToData(from url: URL) -> Data? {
        do { return try Data(contentsOf: url) }
        catch { ZLogs.shared.error(error.localizedDescription) }
        
        return nil
    }
    
    // MARK: - Bundle Info
    func extractIpaFileContents() {
        guard let zipLocation = convertFileIpaToZip(to: "zip") else {
            ZLogs.shared.warning("File conversion failed")
            return
        }
        
        ZLogs.shared.info("ZIP Location: \(zipLocation)")
        unzip(from: zipLocation)
    }
    
    // MARK: - File Conversion
    private func convertFileIpaToZip(to newExtension: String) -> URL? {
        do {
            // clear the old data
            clearDirectory(at: appCacheDirectory)
            
            let newFileURL = createZipFileURL(from: sourceURL)
            try ZFFileManager.shared.copyFileToCache(from: sourceURL, to: newFileURL)
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
        
        let infoPlistPath = payLoadPath.path() + "/\(appName)/Info.plist"
        packageDataManager.setInfoData(fileToData(from: URL(fileURLWithPath: infoPlistPath)))
        
        try extractAppProperties(from: payLoadPath, appName: appName)
    }
    
    private func extractAppProperties(from payLoadPath: URL, appName: String) throws {
        // Info.plist
        if let propertyListObject = try readInfoPlistFile(from: payLoadPath, appName: appName) {
            loadBundleProperties(with: propertyListObject)
        }
        
        // embedded.plist
        if let mobileProvisionObj = try readMobileProvisionFile(from: payLoadPath, appName: appName) {
            loadMobileProvision(with: mobileProvisionObj)
        }
        
        // AppIcon
        let appIconData = try readApplicationIcon(from: payLoadPath, appName: appName)
        packageDataManager.setAppIcon(appIconData)
    }
    
    private func readInfoPlistFile(from payLoadPath: URL, appName: String) throws -> [String: Any]? {
        // Read Info.plist
        let infoPlistPath = (payLoadPath.path() as NSString).appendingPathComponent("\(appName)/Info.plist")
        
        // Check file exist in path and convert file into data
        guard fileManager.fileExists(atPath: infoPlistPath), let fileData = fileToData(from: URL(filePath: infoPlistPath)) else {
            throw ZError.FileConversionError.invalidFilePath
        }
        
        return parseInfoPlist(fileData)
    }
    
    private func readMobileProvisionFile(from payLoadPath: URL, appName: String) throws -> [String: Any]? {
        // Read embedded.mobileprovision
        let provisionPath = (payLoadPath.path() as NSString).appendingPathComponent("\(appName)/embedded.mobileprovision")
        
        // Check file exist in path and convert file into data
        guard fileManager.fileExists(atPath: provisionPath) else {
            throw ZError.FileConversionError.invalidFilePath
        }
        
        // Read the file content
        let provisionData = try Data(contentsOf: URL(fileURLWithPath: provisionPath))
        let fileData = try plistHandler.extractXMLDataFromMobileProvision(provisionData)
        
        return parseInfoPlist(fileData)
    }
    
    private func readApplicationIcon(from payLoadPath: URL, appName: String) throws -> Data {
        // Read App Icon
        let appIconPath = (payLoadPath.path() as NSString).appendingPathComponent("\(appName)/AppIcon60x60@2x.png")
        
        // Check file exist in path and convert file into data
        guard fileManager.fileExists(atPath: appIconPath), let fileData = fileToData(from: URL(filePath: appIconPath)) else {
            throw ZError.FileConversionError.invalidFilePath
        }
        
        return fileData
    }
    
    func parseInfoPlist(_ plistData: Data) -> [String: Any]? {
        guard let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] else {
            ZLogs.shared.error("Failed to cast Info.plist content to directory.")
            return nil
        }
        
        return plist
    }
    
    // MARK: - Bundle property manage
    func loadBundleProperties(with plistDictionary: [String: Any]) {
        let decoder = JSONDecoder()
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: plistDictionary)
            self.bundleProperties = try decoder.decode(BundleProperties.self, from: jsonData)
        }catch {
            ZLogs.shared.error(error.localizedDescription)
        }
    }
    
    func loadMobileProvision(with plistDictionary: [String: Any]) {
        guard let teamIdentifier = plistDictionary[MobileProvision.CodingKeys.teamIdentifier.rawValue] as? [String],
              let expirationDate = plistDictionary[MobileProvision.CodingKeys.expirationDate.rawValue] as? Date,
              let name = plistDictionary[MobileProvision.CodingKeys.name.rawValue] as? String,
              let teamName = plistDictionary[MobileProvision.CodingKeys.teamName.rawValue] as? String,
              let creationDate = plistDictionary[MobileProvision.CodingKeys.creationDate.rawValue] as? Date,
              let version = plistDictionary[MobileProvision.CodingKeys.version.rawValue] as? Int
        else {
            return
        }
    
        self.mobileProvision = MobileProvision(name: name,
                                               teamIdentifier: teamIdentifier,
                                               creationDate: creationDate,
                                               expirationDate: expirationDate,
                                               teamName: teamName, version: version)
    }
    
    func generatePropertyList(fileURL: String) {
        
        let plistURL = plistHandler.createPlistFile(url: fileURL,
                                                    bundleIdentifier: bundleProperties?.bundleIdentifier,
                                                    bundleVersion: bundleProperties?.bundleVersion,
                                                    fileName: bundleProperties?.bundleName)
        
        switch plistURL {
        case .success(let pathLocation):
            packageDataManager.setInstallablePropertyData(fileToData(from: pathLocation))
        case .failure(let failure):
            ZLogs.shared.error(failure.localizedDescription)
        }
    }
}
