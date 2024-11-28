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

// MARK: - ViewType
enum ViewType {
    case sidebar
    case detail
}

// MARK: - Enum for upload components
enum UploadComponentType {
    case application(String)
    case icon, infoPlist, provision
    case installerPlist(String)

    func endpoint(for path: String) -> ZAPIStrings.Endpoint {
        switch self {
        case .application(let appName): return .custom("/\(path)/\(appName).ipa")
        case .icon: return .custom("/\(path)/AppIcon60x60@2x.png")
        case .infoPlist: return .custom("/\(path)/Info.plist")
        case .provision: return .custom("/\(path)/embedded.mobileprovision")
        case .installerPlist(let appName): return .custom("/\(path)/\(appName).plist")
        }
    }

    var contentType: ContentType {
        switch self {
        case .application, .infoPlist, .installerPlist: return .document
        case .icon: return .png
        case .provision: return .mobileProvision
        }
    }
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
    
    // Toast
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
//        Task { await retrieveLoggedUserFromKeychain() }
    }
    
    // MARK: Fetch bucket information
    @MainActor func fetchFoldersFromBucket() async {
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
        guard let endpoint, let appName = packageHandler.packageDataManager.bundleProperties?.bundleName else {
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
        
//        do {
//            // Upload *.ipa file
//            updateLoadingState(for: .detail, to: .uploading("Uploading application"))
//            try await uploadApplication(endpoint)
//            
//            // Upload appIcon file
//            updateLoadingState(for: .detail, to: .uploading("Uploading app icon"))
//            try await uploadIcon(endpoint)
//            
//            // Upload Info.plist file
//            updateLoadingState(for: .detail, to: .uploading("Uploading Info.plist"))
//            try await uploadInfoPropertyList(endpoint)
//            
//            // Upload mobile provision
//            updateLoadingState(for: .detail, to: .uploading("Uploading provision"))
//            try await uploadProvisionProfile(endpoint)
//            
//            
//            
//            await callBack()
//        }catch {
//            handleError(error)
//        }
    }
    
    private func uploadPackageComponents(endpoint: String) async throws {
        guard let appName = packageHandler.packageDataManager.bundleProperties?.bundleName else {
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
        case .application: return packageHandler.packageDataManager.sourceFileData
        case .icon: return packageHandler.packageDataManager.appIcon ?? generateDefaultAppIcon()
        case .infoPlist: return packageHandler.packageDataManager.infoPlistData
        case .provision: return packageHandler.packageDataManager.provisionProfileData
        case .installerPlist: return packageHandler.packageDataManager.installablePropertyListData
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
    
//    private func uploadInstallerPropertyList(_ path: String) async throws {
//        guard let bundleName = packageHandler.packageDataManager.bundleProperties?.bundleName,
//              let plistData = packageHandler.packageDataManager.installablePropertyListData else {
//            showToast("Missing .plist data.")
//            return
//        }
//        let endpoint = ZAPIStrings.Endpoint.custom("/\(path)/\(bundleName).plist")
//        try await upload(data: plistData, to: endpoint, contentType: .document)
//        ZLogs.shared.info("\(bundleName).plist uploaded successfully.")
//    }
    
    
    // MARK: - Upload Helper Methods
//    private func uploadApplication(_ path: String) async throws {
//        guard let bundleName = packageHandler.packageDataManager.bundleProperties?.bundleName,
//              let packageData = packageHandler.packageDataManager.sourceFileData
//        else {
//            showToast("Missing app data")
//            return
//        }
//        
//        let endpoint = ZAPIStrings.Endpoint.custom("/\(path)/\(bundleName).ipa")
//        try await upload(data: packageData, to: endpoint, contentType: .document)
//        ZLogs.shared.info("Application uploaded successfully")
//    }
//    
//    private func uploadIcon(_ path: String) async throws {
//        guard let iconData = packageHandler.packageDataManager.appIcon ?? generateDefaultAppIcon() else {
//            showToast("Failed to generate app icon.")
//            return
//        }
//        
//        let endpoint = ZAPIStrings.Endpoint.custom("/\(path)/AppIcon60x60@2x.png")
//        try await upload(data: iconData, to: endpoint, contentType: .png)
//        ZLogs.shared.info("App icon uploaded successfully.")
//    }
//    
//    private func uploadInfoPropertyList(_ path: String) async throws {
//        guard let plistData = packageHandler.packageDataManager.infoPlistData else {
//            showToast("Missing Info.plist data.")
//            return
//        }
//        
//        let endpoint = ZAPIStrings.Endpoint.custom("/\(path)/Info.plist")
//        try await upload(data: plistData, to: endpoint, contentType: .document)
//        ZLogs.shared.info("Info.plist uploaded successfully.")
//    }
//    
//    private func uploadProvisionProfile(_ path: String) async throws {
//        guard let plistData = packageHandler.packageDataManager.provisionProfileData else {
//            showToast("Missing embedded.mobileprovision data.")
//            return
//        }
//        
//        let endpoint = ZAPIStrings.Endpoint.custom("/\(path)/embedded.mobileprovision")
//        try await upload(data: plistData, to: endpoint, contentType: .mobileProvision)
//        ZLogs.shared.info("embedded.mobileprovision uploaded successfully.")
//    }
//    
    
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
                self.packageHandler.packageDataManager.appIcon = iconData
                updateLoadingState(for: .detail, to: .error)
                completion()
            case .failure(let error):
                updateLoadingState(for: .detail, to: .error)
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
        imageWith(name: packageHandler.packageDataManager.bundleProperties?.bundleName)?.pngData()
    }
}
