//
//  PackageExtractionHandler.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 15/11/24.
//

import Foundation
import Zip
import SwiftUI

@MainActor
class PackageExtractionHandler: ObservableObject {
    // Property Handler
    private let plistHandler = PropertyListHandler()
    private var sourceURL: URL!
    
    private var fileTypeDataMap: [SupportedFileTypes: Data] = [:]
    
    // FileManager
    private let fileManager = FileManager.default
    private let appCacheDirectory = ZFFileManager.shared.getAppCacheDirectory()
    
    func initiateAppExtraction(from url: URL) {
        self.sourceURL = url
        
        if sourceURL.startAccessingSecurityScopedResource() {
            fileTypeDataMap[.app] = fileToData(from: sourceURL)
            sourceURL.stopAccessingSecurityScopedResource()
        }

        AppPackageProcessor(sourceURL: url).extractIpaFileContents()
        extractAppBundle()
    }
    
    func getPackageExtractionModel() -> PackageExtractionModel? {
        PackageExtractionModel(appIcon: fileTypeDataMap[.icon],
                               app: fileTypeDataMap[.app],
                               mobileProvision: fileTypeDataMap[.mobileprovision],
                               infoPropertyList: fileTypeDataMap[.infoPlist],
                               installationPList: fileTypeDataMap[.installationPlist])
    }
    
    func extractXMLFromProvision(_ data: Data) throws -> Data {
        try plistHandler.extractXMLDataFromMobileProvision(data)
    }
    
    private func extractAppBundle() {
        let payLoadPath = appCacheDirectory.appending(path: Constants.payload)
        
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
        
        guard let appName = contents.first, contents.contains(Constants.FilePath.infoPlist(appName).path) else {
            ZLogs.shared.warning("Info.plist does not exist at path: \(payLoadPath.appending(path: contents[0]))")
            return
        }
        
        let infoPlistPath = payLoadPath.path().appending("/") + Constants.FilePath.infoPlist(appName).path
        fileTypeDataMap[.infoPlist] = fileToData(from: URL(fileURLWithPath: infoPlistPath))
        
        try extractAppProperties(from: payLoadPath, appName: appName)
    }
    
    private func extractAppProperties(from payLoadPath: URL, appName: String) throws {
        // embedded.plist
        try readMobileProvisionFile(from: payLoadPath, appName: appName)
        
        // AppIcon
        try readApplicationIcon(from: payLoadPath, appName: appName)
    }
    
    private func readMobileProvisionFile(from payLoadPath: URL, appName: String) throws {
        // Read embedded.mobileprovision
        let provisionPath = (payLoadPath.path() as NSString).appendingPathComponent(Constants.FilePath.embeddedProvision(appName).path)
        
        // Check file exist in path and convert file into data
        guard fileManager.fileExists(atPath: provisionPath) else {
            throw ZError.FileConversionError.invalidFilePath
        }
        
        // Read the file content
        let provisionData = try Data(contentsOf: URL(fileURLWithPath: provisionPath))
        fileTypeDataMap[.mobileprovision] = provisionData
    }
    
    private func readApplicationIcon(from payLoadPath: URL, appName: String) throws {
        // Read App Icon
        let appIconPath = (payLoadPath.path() as NSString).appendingPathComponent(Constants.FilePath.appIcon(appName).path)
        
        // Check file exist in path and convert file into data
        guard fileManager.fileExists(atPath: appIconPath), let fileData = fileToData(from: URL(filePath: appIconPath)) else {
            throw ZError.FileConversionError.invalidFilePath
        }
        
        fileTypeDataMap[.icon] = fileData
    }
    
    func parsePlist(_ plistData: Data) -> [String: Any]? {
        guard let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] else {
            ZLogs.shared.error("Failed to cast Info.plist content to directory.")
            return nil
        }
        
        return plist
    }
    
    // MARK: - Bundle property manage
    func loadBundleProperties(with plistDictionary: [String: Any]) -> BundleProperties? {
        let decoder = JSONDecoder()
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: plistDictionary)
            return try decoder.decode(BundleProperties.self, from: jsonData)
        }catch {
            ZLogs.shared.error(error.localizedDescription)
            return nil
        }
    }
    
    func loadMobileProvision(with plist: [String: Any]) -> MobileProvision? {
        guard let provision = MobileProvision(from: plist) else { return nil }
        return provision
    }
    
    func generatePropertyList(fileURL: String, bundleId: String, bundleVersion: String, fileName: String) -> Data? {
        switch plistHandler.createPlistFile(url: fileURL, bundleIdentifier: bundleId, bundleVersion: bundleVersion, fileName: fileName) {
        case .success(let url):
            return try? Data(contentsOf: url)
        case .failure(let error):
            ZLogs.shared.error(error.localizedDescription)
            return nil
        }
    }
    
    // MARK: - Convert source as data
    private func fileToData(from url: URL) -> Data? {
        do { return try Data(contentsOf: url) }
        catch { ZLogs.shared.error(error.localizedDescription) }
        
        return nil
    }
    
}
