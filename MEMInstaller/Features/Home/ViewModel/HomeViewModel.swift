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

// MARK: - View Type
enum ViewType {
    case sidebar
    case detail
}

// MARK: - File Types
enum SupportedFileTypes {
    case icon
    case app
    case mobileprovision
    case installationPlist
    case infoPlist
}

class HomeViewModel: ObservableObject {
    // Manage logged user profile
    var userprofile: ZUserProfile? {
        return userDataManager.retriveLoggedUserFromKeychain()
    }
    
    @Published private(set) var allObjects: [String: [ContentModel]] = [:]
    
    @Published var sideBarLoadingState: LoadingState = .loading
    @Published var detailViewLoadingState: LoadingState = .idle
    
    @Published var shouldShowDetailView: Bool = false
    @Published var shouldShowUploadView: Bool = false
    
    // Toast properties
    @Published private(set) var toastMessage: String?
    @Published var isPresentToast: Bool = false
    
    // Dependencies
    var userDataManager: UserDataManager
    var repository: StratusRepository
    var packageHandler: PackageExtractionHandler
    
    // MARK: - Initialise
    init(repository: StratusRepository, userDataManager: UserDataManager, packageHandler: PackageExtractionHandler) {
        self.repository = repository
        self.userDataManager = userDataManager
        self.packageHandler = packageHandler
    }
    
    // MARK: Fetch bucket information
    @MainActor 
    func fetchFoldersFromBucket() async {
        guard let email = userprofile?.email else { return }
        updateLoadingState(for: .sidebar, to: .loading)
        
        let params: Parameters = ["bucket_name": "packages", "prefix": "\(email)/"]
        
        do {
            guard let bucketObject = try await repository.getFoldersFromBucket(params) else { return }
            
            if !bucketObject.contents.isEmpty {
                await processBucketContents(bucketObject)
            }
            
            updateLoadingState(for: .sidebar, to: .idle)
        }catch {
            handleError(error.localizedDescription)
        }
    }
    
    @MainActor
    private func processBucketContents(_ bucketData: BucketObjectModel) async {
        var contentDict: [String: [ContentModel]] = [:]
        for folder in bucketData.contents where folder.actualKeyType == .folder {
            let folderName = URL(string: folder.url)!.lastPathComponent
            let params: Parameters = ["bucket_name": "packages", "prefix": "\(folder.key)/"]
            do {
                let files = try await repository.getFoldersFromBucket(params)?.contents
                contentDict[folderName] = files
            } catch {
                handleError(error.localizedDescription)
            }
        }
        
        self.allObjects = contentDict
        updateLoadingState(for: .sidebar, to: .idle)
    }
    
    // MARK: - Upload Handling
    @MainActor func uploadPackage(endpoint: String?, _ callBack: @escaping () async -> Void) async {
        guard let endpoint, let appName = packageHandler.bundleProperties?.bundleName else {
            showToast("Invalid upload endpoint.")
            return
        }
        
        do {
            try await uploadPackageComponents(endpoint: endpoint)
            try await generateInstallerPropertyList(endpoint)
            try await uploadComponent(type: .installerPlist(appName), endpoint: endpoint, message: "Uploading Installer")
            await callBack()
        }catch {
            handleError(error.localizedDescription)
        }
    }
    
    private func uploadPackageComponents(endpoint: String) async throws {
        guard let appName = packageHandler.bundleProperties?.bundleName else {
            handleError("Bundle name not found while uploading packages")
            return
        }
        
        try await uploadComponent(type: .application(appName), endpoint: endpoint, message: "Uploading application")
        try await uploadComponent(type: .icon, endpoint: endpoint, message: "Uploading app icon")
        try await uploadComponent(type: .infoPlist, endpoint: endpoint, message: "Uploading Info.plist")
        try await uploadComponent(type: .provision, endpoint: endpoint, message: "Uploading provision")
    }
    
    private func uploadComponent(type: UploadComponentType, endpoint: String, message: String) async throws {
        updateLoadingState(for: .detail, to: .uploading(message))
        guard let data = try fetchData(for: type) else { throw ZError.NetworkError.missingData }
        let apiEndpoint = type.endpoint(for: endpoint)
        try await upload(data: data, to: apiEndpoint, contentType: type.contentType)
    }
    
    private func fetchData(for type: UploadComponentType) throws -> Data? {
        switch type {
        case .application: return packageHandler.fileTypeDataMap[.app]!
        case .icon: return packageHandler.fileTypeDataMap[.icon]! ?? generateDefaultAppIcon()
        case .infoPlist: return packageHandler.fileTypeDataMap[.infoPlist]!
        case .provision: return packageHandler.fileTypeDataMap[.mobileprovision]!
        case .installerPlist: return packageHandler.fileTypeDataMap[.installationPlist]!
        }
    }
    
    private func generateInstallerPropertyList(_ endpoint: String) async throws {
        updateLoadingState(for: .detail, to: .uploading("Generating .plist"))
        if let objectURL = await fetchPackageURL(endpoint) {
            packageHandler.generatePropertyList(fileURL: objectURL)
        }else {
            throw ZError.LocalError.custom("Failed to generate installation property", nil)
        }
    }
    
    private func upload(data: Data, to endpoint: ZAPIStrings.Endpoint, contentType: ContentType) async throws {
        let headers = HTTPHeaders([.contentType(contentType.rawValue)])
        let result = try await repository.uploadObjects(endpoint: endpoint, headers: headers, data: data)
        if case .failure(let error) = result {
            throw error
        }
    }
    
    // MARK: - Download Property List
    @MainActor func downloadInfoFile(url: String, completion: @escaping () -> Void) {
        updateLoadingState(for: .detail, to: .loading)
        
        Download(url: url).downloadFile {[weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let fileData):
                guard let fileProperties = self.packageHandler.parseInfoPlist(fileData) else {
                    ZLogs.shared.error(ZError.FileConversionError.fileReadFailed.localizedDescription)
                    return
                }
                
                self.packageHandler.loadBundleProperties(with: fileProperties)
                updateLoadingState(for: .detail, to: .idle)
                completion()
            case .failure(let error):
                updateLoadingState(for: .detail, to: .error)
                handleError(error.localizedDescription)
                completion()
            }
        }
    }
    
    // MARK: - Download App Icon
    @MainActor func downloadAppIconFile(url: String, completion: @escaping () -> Void) {
        updateLoadingState(for: .detail, to: .loading)
        
        Download(url: url).downloadFile {[weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let iconData):
                self.packageHandler.fileTypeDataMap[.icon] = iconData
                updateLoadingState(for: .detail, to: .error)
                completion()
            case .failure(let error):
                updateLoadingState(for: .detail, to: .error)
                handleError(error.localizedDescription)
                completion()
            }
        }
    }
    
    @MainActor func downloadProvisionFile(url: String, completion: @escaping () -> Void) {
        updateLoadingState(for: .detail, to: .loading)
        
        Download(url: url).downloadFile {[weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let provisionFile):
                guard let extractedData = try? self.packageHandler.plistHandler.extractXMLDataFromMobileProvision(provisionFile) else { return }
                if let mobileProvisionDic = self.packageHandler.parseInfoPlist(extractedData) {
                    self.packageHandler.loadMobileProvision(with: mobileProvisionDic)
                    updateLoadingState(for: .detail, to: .idle)
                    completion()
                }
            case .failure(let error):
                updateLoadingState(for: .detail, to: .error)
                handleError(error.localizedDescription)
                completion()
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
            guard let bucketData = try await repository.getFoldersFromBucket(params) else { return nil }
            
            if bucketData.contents.isEmpty {
                updateLoadingState(for: .sidebar, to: .idle)
                return nil
            }
            
            updateLoadingState(for: .sidebar, to: .idle)
            return getPackageURL(from: bucketData.contents)
        } catch {
            handleError(error.localizedDescription)
        }

        return nil
    }

    private func getPackageURL(from contents: [ContentModel]) -> String? {
        contents.filter({ $0.actualContentType == .document && $0.key.contains(".ipa")}).first?.url
    }
    
    // MARK: - Error and Toast Handling
    private func handleError(_ error: String) {
        ZLogs.shared.error(error)
        showToast(error)
        updateLoadingState(for: .detail, to: .error)
    }
    
    func showToast(_ message: String) {
        toastMessage = message
        isPresentToast = true
    }
    
    func updateLoadingState(for view: ViewType, to state: LoadingState) {
        withAnimation {
            switch view {
            case .sidebar: sideBarLoadingState = state
            case .detail: detailViewLoadingState = state
            }
        }
    }
    
    private func generateDefaultAppIcon() -> Data? {
        imageWith(name: packageHandler.bundleProperties?.bundleName)?.pngData()
    }
}
