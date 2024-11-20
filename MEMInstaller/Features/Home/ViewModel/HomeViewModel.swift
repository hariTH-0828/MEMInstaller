//
//  HomeViewModel.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI
import Zip
import Alamofire

@MainActor
class HomeViewModel: ObservableObject {
    // Manage logged user profile
    @Published private(set) var userprofile: ZUserProfile?
    @Published private(set) var allObject: [String: [ContentModel]] = [String: [ContentModel]]()
    
    @Published var isLoading: Bool = true
    @Published var isDownOrUpStateEnable: Bool = false
    @Published var progressTitle: String = "Loading"
    
    let userDataManager = UserDataManager()
    var packageHandler = PackageExtractionHandler()
    
    // Toast
    @Published private(set) var toastMessage: String?
    @Published var isPresentToast: Bool = false
    
    let repository: StratusRepository
    
    init(_ repository: StratusRepository) {
        self.repository = repository
        retriveLoggedUserFromKeychain()
    }
    
    // MARK: - User Profile
    private func retriveLoggedUserFromKeychain() {
        self.userprofile = userDataManager.retriveLoggedUserFromKeychain()
    }
    
    // MARK: Fetch bucket information
    func fetchFoldersFromBucket() async {
        if let email = userprofile?.email {
            let params: Parameters = ["bucket_name": "packages", "prefix": "\(email)/"]
            
            do {
                let bucketObject = try await repository.getFoldersFromBucket(params)
                
                // Iterate and save all file objects from the folder
                if !bucketObject.contents.isEmpty {
                    await getFilesFromTheFolder(bucketObject)
                }else {
                    withAnimation { isLoading = false }
                }
            }catch {
                withAnimation { isLoading = false }
                presentToast(message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Upload packages
    func uploadPackageIntoFolder(_ endpoint: String?) async {
        guard let endpoint else {
            presentToast(message: "Upload failed")
            return
        }
        
        do {
            // Upload *.ipa file
            withAnimation { isDownOrUpStateEnable = true }
            try await uploadApplication(endpoint)
            
            // Upload appIcon file
            withAnimation { isDownOrUpStateEnable = true }
            try await uploadIcon(endpoint)
            
            // Upload Info.plist file
            withAnimation { isDownOrUpStateEnable = true }
            try await uploadInfoPropertyList(endpoint)
            
            // Get url for upload *.ipa file
            withAnimation { isDownOrUpStateEnable = true }
            guard let objectURL = await fetchPackageURL(endpoint) else { return }
            
            // Generate *.plist
            withAnimation { isDownOrUpStateEnable = true }
            packageHandler.generatePropertyList(fileURL: objectURL)
            
            // Upload *.plist
            withAnimation { isDownOrUpStateEnable = true }
            try await uploadInstallerPropertyList(endpoint)
            
            // Reload view
            withAnimation { isLoading = true }
            await fetchFoldersFromBucket()
            
            // Success
            withAnimation { isDownOrUpStateEnable = false }
        }catch {
            ZLogs.shared.error(error.localizedDescription)
            withAnimation { isDownOrUpStateEnable = false }
            presentToast(message: error.localizedDescription)
        }
    }
    
    // MARK: - Download Property List
    func downloadInfoFile(url: String) {
        // Enable loading state
        isDownOrUpStateEnable = true
        
        Download(url: url).downloadFile {[weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let fileData):
                try? self.packageHandler.parseInfoPlist(fileData)
                self.isDownOrUpStateEnable = false
            case .failure(let error):
                isDownOrUpStateEnable = false
                self.presentToast(message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Download App Icon
    func downloadAppIconFile(url: String) {
        // Enable loading state
        isDownOrUpStateEnable = true
        
        Download(url: url).downloadFile {[weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let iconData):
                self.packageHandler.appIcon = iconData
                isDownOrUpStateEnable = false
            case .failure(let error):
                isDownOrUpStateEnable = false
                self.presentToast(message: error.localizedDescription)
            }
        }
    }
    
    private func uploadIcon(_ path: String) async throws {
        // Construct the custom endpoint
        let endpoint = ZAPIStrings.Endpoint.custom("/\(path)/AppIcon60x60@2x.png")
        
        // Get image data
        guard let imageData = packageHandler.appIcon ??
                              imageWith(name: packageHandler.bundleProperties?.bundleName)?.pngData() 
        else {
            ZLogs.shared.warning("Failed to generate app icon. Please check your build configuration.")
            presentToast(message: "Failed to generate app icon")
            return
        }
        
        // Upload the image
        let result = try await repository.uploadObjects(
            endpoint: endpoint,
            headers: HTTPHeaders(arrayLiteral: .contentType(ContentType.png.rawValue)),
            data: imageData
        )
        
        switch result {
        case .success(_):
            self.progressTitle = "App icon uploaded"
            ZLogs.shared.info("App icon uploaded")
        case .failure(let error):
            ZLogs.shared.error(error.localizedDescription)
            withAnimation { isDownOrUpStateEnable = false }
        }
    }
    
    private func uploadApplication(_ path: String) async throws {
        // Construct the custom endpoint
        let bundleName = packageHandler.bundleProperties?.bundleName
        let endpoint = ZAPIStrings.Endpoint.custom("/\(path)/\(bundleName!).ipa")
        
        // Get package data
        guard let packageData = packageHandler.sourceFileData else {
            ZLogs.shared.warning("Failed to get application. Please check your build configuration.")
            presentToast(message: "Failed to get app data")
            return
        }
        
        // Upload the package
        self.progressTitle = "Uploading Packages"
        let result = try await repository.uploadObjects(
            endpoint: endpoint,
            headers: HTTPHeaders(arrayLiteral: .contentType(ContentType.document.rawValue)),
            data: packageData
        )
        
        switch result {
        case .success(_):
            self.progressTitle = "Package uploaded"
            ZLogs.shared.info("Package uploaded")
        case .failure(let error):
            ZLogs.shared.error(error.localizedDescription)
            withAnimation { isDownOrUpStateEnable = false }
        }
    }
    
    private func uploadInfoPropertyList(_ path: String) async throws {
        // Construct the custom endpoint
        let endpoint = ZAPIStrings.Endpoint.custom("/\(path)/Info.plist")
        
        // Get package data
        guard let infoPlistData = packageHandler.infoPlistData
        else {
            ZLogs.shared.warning("Failed to get property list data. Please check your build configuration.")
            presentToast(message: "Failed to property data")
            return
        }
        
        // Upload the package
        let result = try await repository.uploadObjects(
            endpoint: endpoint,
            headers: HTTPHeaders(arrayLiteral: .contentType(ContentType.document.rawValue)),
            data: infoPlistData
        )
        
        switch result {
        case .success(_):
            self.progressTitle = "Property file uploaded"
            ZLogs.shared.info("Property file uploaded")
        case .failure(let error):
            ZLogs.shared.error(error.localizedDescription)
            withAnimation { isDownOrUpStateEnable = false }
        }
    }
    
    private func uploadInstallerPropertyList(_ path: String) async throws {
        // Construct the custom endpoint
        guard let bundleName = packageHandler.bundleProperties?.bundleName else { return }
        
        let endpoint = ZAPIStrings.Endpoint.custom("/\(path)/\(bundleName).plist")
        
        // Get package data
        guard let infoPlistData = packageHandler.sourcePlistData
        else {
            ZLogs.shared.warning("Failed to get property list data. Please check your build configuration.")
            presentToast(message: "Failed to property data")
            return
        }
        
        // Upload the package
        let result = try await repository.uploadObjects(
            endpoint: endpoint,
            headers: HTTPHeaders(arrayLiteral: .contentType(ContentType.document.rawValue)),
            data: infoPlistData
        )
        
        switch result {
        case .success(_):
            self.progressTitle = "\(bundleName).plist uploaded"
            ZLogs.shared.info("\(bundleName).plist uploaded")
        case .failure(let error):
            ZLogs.shared.error(error.localizedDescription)
            withAnimation { isDownOrUpStateEnable = false }
        }
    }
    
    private func fetchPackageURL(_ endpoint: String?) async -> String? {
        if let prefix = endpoint {
            let params: Parameters = ["bucket_name": "packages",
                                      "prefix": "\(prefix)/"]
            
            do {
                let bucketObject = try await repository.getFoldersFromBucket(params)
                
                // Iterate and save all file objects from the folder
                if !bucketObject.contents.isEmpty {
                    return getPackageURL(from: bucketObject.contents)
                }else {
                    withAnimation { isDownOrUpStateEnable = false }
                }
            }catch {
                withAnimation { isDownOrUpStateEnable = false }
                presentToast(message: error.localizedDescription)
            }
            
            return nil
        }
        
        return nil
    }
    
    private func getPackageURL(from contents: [ContentModel]) -> String? {
        contents.filter({ $0.actualContentType == .document && $0.key.contains(".ipa")}).first?.url
    }
    
    private func getFilesFromTheFolder(_ rootObject: BucketObjectModel) async {
        var objects: [String: [ContentModel]] = [String: [ContentModel]]()
        
        for content in rootObject.contents {
            // Check whether key type is folder
            if content.actualKeyType == .folder {
                // Get folder name
                let folderName = URL(string: content.url)!.lastPathComponent
                let params: Parameters = ["bucket_name": "packages", "prefix": "\(content.key)/"]
                
                do {
                    let fileObjects = try await repository.getFoldersFromBucket(params).contents
                    objects[folderName] = fileObjects
                }catch {
                    withAnimation { isLoading = false }
                    ZLogs.shared.info(error.localizedDescription)
                    presentToast(message: error.localizedDescription)
                }
            }
        }
        
        self.allObject = objects
        
        withAnimation { isLoading = false }
    }
    
    func presentToast(message: String?) {
        toastMessage = message
        isPresentToast = true
    }
}
