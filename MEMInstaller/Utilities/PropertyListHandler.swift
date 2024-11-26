//
//  PropertyListHandler.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import Foundation

enum PropertyListError: Error {
    case missingRequiredData
    case failedToCreateFile
}

final class PropertyListHandler {
    private let cacheDirectory: URL = ZFFileManager.shared.getAppCacheDirectory()
    
    /**
     Creates a plist file at the specified path with the given parameters.
     
     This function generates a property list (plist) file containing metadata and assets related to an app.
     It optionally takes an IPA URL, bundle identifier, version, file name, and additional content.
     If the required data is missing, the function returns an error.

     - Parameters:
       - ipaURL: The URL of the .ipa file. This is a required parameter.
       - bundleIdentifier: The bundle identifier of the app. Optional, used if not provided in content.
       - bundleVersion: The bundle version of the app. Optional, used if not provided in content.
       - fileName: The name of the plist file. Optional, used if not provided in content.
       - content: An optional dictionary containing additional bundle information such as `CFBundleName`, `CFBundleIdentifier`, and `CFBundleShortVersionString`.
     
     - Returns: A `Result` containing the URL of the created plist file on success or a `PropertyListError` on failure.
     */
    func createPlistFile(url ipaURL: String, bundleIdentifier: String? = nil, bundleVersion: String? = nil, fileName: String? = nil, content: [String: Any]? = nil) -> Result<URL, PropertyListError> {
        guard let (finalFileName, finalBundleIdentifier, finalBundleVersion) = resolvePlistData(content: content, fileName: fileName, bundleIdentifier: bundleIdentifier, bundleVersion: bundleVersion) else {
            return .failure(.missingRequiredData)
        }
        
        let plistDict = createPlistDictionary(ipaURL: ipaURL, fileName: finalFileName, bundleIdentifier: finalBundleIdentifier, bundleVersion: finalBundleVersion)
        let fileURL = generatePlistFileURL(fileName: finalFileName)
        
        do {
            let plistData = try PropertyListSerialization.data(fromPropertyList: plistDict, format: .xml, options: 0)
            return writePlistData(plistData, to: fileURL)
        } catch {
            ZLogs.shared.error("Failed to serialize plist data: \(error.localizedDescription)")
            return .failure(.failedToCreateFile)
        }
    }
    
    /**
     Extracts the property list (XML) data from a .mobileprovision file at the specified
     
     This method reads the content of a provisioning file and extracts the XML portion, which contains the property list data.
     - Parameter path: The file system path of the .mobileprovision file.
     - Returns: A `Data` object representing the extracted property list content.
     
     - Throws:
        - `ZError.FileConversionError.invalidFilePath` if the specified path is invalid or the file does not
        - `ZError.FileConversionError.fileReadFailed` if the XML content cannot be located or read.
     */
    func extractPropertyListData(fromProvisionFileAt path: String) throws -> Data {
        do {
            // Ensure the file exists at the given path
            guard FileManager.default.fileExists(atPath: path) else { throw ZError.FileConversionError.invalidFilePath }
            
            // Read the file content
            let provisionData = try Data(contentsOf: URL(fileURLWithPath: path))
            
            // Locate the XML start and end indices
            let (startRange, endRange) = try rangeOfStartAndEndIndex(of: provisionData)
            
            // Extract and return the XML portion
            return provisionData.subdata(in: startRange..<endRange)
        }catch {
            ZLogs.shared.error("Failed to extract properties from .mobileprovision: \(error.localizedDescription)")
            throw error
        }
    }
    
    /**
     Finds the start and end indices of the XML content within a data object.
    
     This method searches for the start (`<?xml`) and end (`</plist>`) markers in the given data
     to identify the range of the XML property list content.
     
     - Parameter data: The data to search for XML markers.
     - Returns: A tuple containing the start and end indices of the XML content.
     - Throws:
     - `ZError.FileConversionError.fileReadFailed` if the XML markers cannot be found.
     */
    private func rangeOfStartAndEndIndex(of data: Data) throws -> (Int, Int) {
        // Locate the start and end markers for the XML content
        guard let xmlStartRange = data.range(of: Data("<?xml".utf8))?.lowerBound,
              let plistEndRange = data.range(of: Data("</plist>".utf8))?.upperBound
        else {
            throw ZError.FileConversionError.fileReadFailed
        }
        
        return (xmlStartRange, plistEndRange)
    }
    
    /**
     Resolves the necessary data to generate a property list, using either the provided parameters or the content dictionary.
     
     This function ensures that the file name, bundle identifier, and bundle version are present and valid.
     If any of the required data is missing, the function returns `nil`.

     - Parameters:
       - content: An optional dictionary containing the bundle information (e.g., `CFBundleName`, `CFBundleIdentifier`, `CFBundleShortVersionString`).
       - fileName: The name of the plist file, if provided.
       - bundleIdentifier: The bundle identifier, if provided.
       - bundleVersion: The bundle version, if provided.

     - Returns: A tuple containing the resolved file name, bundle identifier, and bundle version, or `nil` if any data is missing.
     */
    private func resolvePlistData(content: [String: Any]?, fileName: String?, bundleIdentifier: String?, bundleVersion: String?) -> (String, String, String)? {
        var resolvedFileName = fileName
        var resolvedBundleIdentifier = bundleIdentifier
        var resolvedBundleVersion = bundleVersion
        
        if let content = content {
            resolvedFileName = content["CFBundleName"] as? String
            resolvedBundleIdentifier = content["CFBundleIdentifier"] as? String
            resolvedBundleVersion = content["CFBundleShortVersionString"] as? String
        }
        
        guard let finalFileName = resolvedFileName,
              let finalBundleIdentifier = resolvedBundleIdentifier,
              let finalBundleVersion = resolvedBundleVersion else {
            ZLogs.shared.error("Insufficient data provided to generate the property list")
            return nil
        }
        
        return (finalFileName, finalBundleIdentifier, finalBundleVersion)
    }
    
    /**
     Creates a property list dictionary with the given IPA URL, file name, bundle identifier, and bundle version.
     
     This function structures the data in a format suitable for serialization into a plist file.

     - Parameters:
       - ipaURL: The URL of the .ipa file.
       - fileName: The name of the plist file.
       - bundleIdentifier: The bundle identifier of the app.
       - bundleVersion: The bundle version of the app.

     - Returns: A dictionary representing the structure of the property list.
     */
    private func createPlistDictionary(ipaURL: String, fileName: String, bundleIdentifier: String, bundleVersion: String) -> [String: Any] {
        return [
            "items": [
                [
                    "assets": [
                        [
                            "kind": "software-package",
                            "url": ipaURL
                        ]
                    ],
                    "metadata": [
                        "bundle-identifier": bundleIdentifier,
                        "bundle-version": bundleVersion,
                        "kind": "software",
                        "title": fileName
                    ]
                ]
            ]
        ]
    }
    
    /**
     Generates a file URL for the property list file, appending the `.plist` extension.
     
     This function takes the file name and appends it to the app’s cache directory, with the `.plist` extension.

     - Parameters:
       - fileName: The name of the plist file.

     - Returns: The URL where the plist file will be saved.
     */
    private func generatePlistFileURL(fileName: String) -> URL {
        return cacheDirectory.appending(path: fileName).appendingPathExtension("plist")
    }
    
    /**
    Writes the serialized property list data to a file at the specified URL.
    
    This function attempts to write the provided data to the specified URL. If the write operation fails, it logs the error and returns a failure result.

    - Parameters:
      - data: The property list data to write.
      - fileURL: The URL where the plist data should be saved.

    - Returns: A `Result` containing the file URL on success or a `PropertyListError` on failure.
    */
    private func writePlistData(_ data: Data, to fileURL: URL) -> Result<URL, PropertyListError> {
        do {
            try data.write(to: fileURL)
            return .success(fileURL)
        } catch {
            ZLogs.shared.error("Failed to write plist to \(fileURL.path): \(error.localizedDescription)")
            return .failure(.failedToCreateFile)
        }
    }
}
