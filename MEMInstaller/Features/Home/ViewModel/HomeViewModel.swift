//
//  HomeViewModel.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI
import Zip
import Alamofire

// MARK: - State Management
enum LoadingState: Hashable {
    case idle
    case loading
    case uploading(String)
    case error
}

class HomeViewModel: ObservableObject, Identifiable {
    // Manage logged user profile
    @Published private(set) var userprofile: ZUserProfile?
    @Published private(set) var allObjects: [String: [ContentModel]] = [:]
    @Published var loadingState: LoadingState = .loading
    
    var id: Self { self }
    
    // Toast
    @Published private(set) var toastMessage: String?
    @Published var isPresentToast: Bool = false
    
    // Dependencies
    var userDataManager: UserDataManager?
    var repository: StratusRepository?
    var packageHandler: PackageExtractionHandler?
    
    init(
        repository: StratusRepository?,
        userDataManager: UserDataManager?,
        packageHandler: PackageExtractionHandler?
    ) {
        self.repository = repository
        self.userDataManager = userDataManager
        self.packageHandler = packageHandler
        
        DispatchQueue.main.async {
            self.retrieveLoggedUserFromKeychain()
        }
    }
    
    // MARK: - User Profile
    @MainActor
    private func retrieveLoggedUserFromKeychain() {
        self.userprofile = self.userDataManager?.retriveLoggedUserFromKeychain()
    }
    
    // MARK: Fetch bucket information
    @MainActor func fetchFoldersFromBucket() async {
        guard let email = userprofile?.email else { return }
        setLoadingState(.loading)
        
        let params: Parameters = ["bucket_name": "packages", "prefix": "\(email)/"]
        
        do {
            if let bucketObject = try await repository?.getFoldersFromBucket(params) {
                
                if bucketObject.contents.isEmpty {
                    setLoadingState(.idle)
                    return
                }
                
                await loadFilesFromFolders(bucketObject)
                setLoadingState(.idle)
            }
        }catch {
            handleError(error)
        }
    }
    
    @MainActor
    private func loadFilesFromFolders(_ bucketObject: BucketObjectModel) async {
        var folderContents: [String: [ContentModel]] = [:]
        for folder in bucketObject.contents where folder.actualKeyType == .folder {
            let folderName = URL(string: folder.url)!.lastPathComponent
            let params: Parameters = ["bucket_name": "packages", "prefix": "\(folder.key)/"]
            do {
                let files = try await repository?.getFoldersFromBucket(params)?.contents
                folderContents[folderName] = files
            } catch {
                handleError(error)
            }
        }
        
        self.allObjects = folderContents
    }
    
    // MARK: - Upload packages
    @MainActor func uploadPackage(endpoint: String?, _ callBack: @escaping () async -> Void) async {
        guard let endpoint else {
            showToast("Invalid upload endpoint.")
            return
        }
        
        do {
            // Upload *.ipa file
            setLoadingState(.uploading("Uploading application"))
            try await uploadApplication(endpoint)
            
            // Upload appIcon file
            setLoadingState(.uploading("Uploading app icon"))
            try await uploadIcon(endpoint)
            
            // Upload Info.plist file
            setLoadingState(.uploading("Uploading Info.plist"))
            try await uploadInfoPropertyList(endpoint)
            
            // Get url for upload *.ipa file
            setLoadingState(.uploading("Generating .plist"))
            if let objectURL = await fetchPackageURL(endpoint) {
                packageHandler?.generatePropertyList(fileURL: objectURL)
                try await uploadInstallerPropertyList(endpoint)
            }
            
            await callBack()
        }catch {
            handleError(error)
        }
    }
    
    // MARK: - Upload Helper Methods
    private func uploadApplication(_ path: String) async throws {
        guard let bundleName = packageHandler?.bundleProperties?.bundleName,
              let packageData = packageHandler?.sourceFileData
        else {
            showToast("Missing app data")
            return
        }
        
        let endpoint = ZAPIStrings.Endpoint.custom("/\(path)/\(bundleName).ipa")
        try await upload(data: packageData, to: endpoint, contentType: .document)
        ZLogs.shared.info("Application uploaded successfully")
    }
    
    private func uploadIcon(_ path: String) async throws {
        guard let iconData = packageHandler?.appIcon ?? generateDefaultAppIcon() else {
            showToast("Failed to generate app icon.")
            return
        }
        
        let endpoint = ZAPIStrings.Endpoint.custom("/\(path)/AppIcon60x60@2x.png")
        try await upload(data: iconData, to: endpoint, contentType: .png)
        ZLogs.shared.info("App icon uploaded successfully.")
    }
    
    private func uploadInfoPropertyList(_ path: String) async throws {
        guard let plistData = packageHandler?.infoPlistData else {
            showToast("Missing Info.plist data.")
            return
        }
        
        let endpoint = ZAPIStrings.Endpoint.custom("/\(path)/Info.plist")
        try await upload(data: plistData, to: endpoint, contentType: .document)
        ZLogs.shared.info("Info.plist uploaded successfully.")
    }
    
    private func upload(data: Data, to endpoint: ZAPIStrings.Endpoint, contentType: ContentType) async throws {
        let headers = HTTPHeaders([.contentType(contentType.rawValue)])
        let result = try await repository?.uploadObjects(endpoint: endpoint, headers: headers, data: data)
        if case .failure(let error) = result {
            throw error
        }
    }
    
    private func uploadInstallerPropertyList(_ path: String) async throws {
        guard let bundleName = packageHandler?.bundleProperties?.bundleName,
              let plistData = packageHandler?.sourcePlistData else {
            showToast("Missing .plist data.")
            return
        }
        let endpoint = ZAPIStrings.Endpoint.custom("/\(path)/\(bundleName).plist")
        try await upload(data: plistData, to: endpoint, contentType: .document)
        ZLogs.shared.info("\(bundleName).plist uploaded successfully.")
    }
    
    // MARK: - Download Property List
    @MainActor func downloadInfoFile(url: String) {
        setLoadingState(.loading)
        
        Download(url: url).downloadFile {[weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let fileData):
                do {
                    try self.packageHandler?.parseInfoPlist(fileData)
                    self.setLoadingState(.idle)
                }catch {
                    self.handleError(error)
                }
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    // MARK: - Download App Icon
    @MainActor func downloadAppIconFile(url: String) {
        setLoadingState(.loading)
        
        Download(url: url).downloadFile {[weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let iconData):
                self.packageHandler?.appIcon = iconData
                self.setLoadingState(.idle)
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    @MainActor private func fetchPackageURL(_ endpoint: String?) async -> String? {
        guard let prefix = endpoint else {
            showToast("Invalid reload endpoint")
            return nil
        }

        let params: Parameters = ["bucket_name": "packages",
                                  "prefix": "\(prefix)/"]

        do {
            if let bucketObject = try await repository?.getFoldersFromBucket(params) {
                
                if bucketObject.contents.isEmpty {
                    setLoadingState(.idle)
                    return nil
                }
                
                setLoadingState(.idle)
                return getPackageURL(from: bucketObject.contents)
            }
        } catch {
            handleError(error)
        }

        return nil
    }

    private func getPackageURL(from contents: [ContentModel]) -> String? {
        contents.filter({ $0.actualContentType == .document && $0.key.contains(".ipa")}).first?.url
    }
    
    // MARK: - Error and Toast Handling
    @MainActor private func handleError(_ error: Error) {
        setLoadingState(.error)
        ZLogs.shared.error(error.localizedDescription)
        showToast(error.localizedDescription)
    }
    
    func showToast(_ message: String) {
        toastMessage = message
        isPresentToast = true
    }
    
    @MainActor
    func setLoadingState(_ state: LoadingState) {
        withAnimation {
            self.loadingState = state
        }
    }
    
    private func generateDefaultAppIcon() -> Data? {
        imageWith(name: packageHandler?.bundleProperties?.bundleName)?.pngData()
    }
}
