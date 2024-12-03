//
//  HomeViewModel.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI
import Zip
import Alamofire
import Combine

// MARK: - File Types
enum SupportedFileTypes {
    case icon, app, mobileprovision, installationPlist, infoPlist
}

enum DownloadType {
    case infoFile, appIcon, provision
}

protocol HomeViewModelProtocol: ObservableObject {
    func fetchFolders()
    func downloadFile(url: String, type: DownloadType) async
    var bucketObjectModels: [BucketObjectModel] { get }
    var sideBarLoadingState: LoadingState { get }
    var detailViewLoadingState: LoadingState { get }
    var uploadProgress: Double { get }
    var toastMessage: String? { get }
    var isPresentToast: Bool { get }
    var userProfile: ZUserProfile? { get }
}

class HomeViewModel: HomeViewModelProtocol {
    // Manage logged user profile
    @Published private(set) var userProfile: ZUserProfile?
    @Published private(set) var bucketObjectModels: [BucketObjectModel] = []
    
    @Published var sideBarLoadingState: LoadingState = .loading {
        didSet {
            if sideBarLoadingState == .loading { detailViewLoadingState = .idle() }
        }
    }
    @Published var detailViewLoadingState: LoadingState = .idle()
    @Published var uploadProgress: Double = 0.0
    
    // Toast properties
    @Published private(set) var toastMessage: String?
    @Published var isPresentToast: Bool = false
    
    // Dependencies
    private let userDataManager: UserDataManager
    private let repository: StratusRepository
    let packageHandler: PackageExtractionHandler
    private var cancellables = Set<AnyCancellable>()
    
    init(
        repository: StratusRepository,
        userDataManager: UserDataManager,
        packageHandler: PackageExtractionHandler
    ) {
        self.repository = repository
        self.userDataManager = userDataManager
        self.packageHandler = packageHandler
        self.userProfile = userDataManager.retrieveLoggedUserFromKeychain()
        
        bindRepositoryProgress()
    }
    
    /// Binds the repository's uploadProgress to the view model's uploadProgress
    private func bindRepositoryProgress() {
        if let repo = repository as? StratusRepositoryImpl {
            repo.$uploadProgress
                .receive(on: DispatchQueue.main)
                .assign(to: &$uploadProgress)
        }
    }
    
    func fetchFolders() {
        Task {
            await fetchFoldersFromBucket()
        }
    }
    
    func downloadFile(url: String, type: DownloadType) async {
        await downloadFileTask(url: url, type: type)
    }
    
    // MARK: Fetch bucket information
    @MainActor
    private func fetchFoldersFromBucket() async {
        updateLoadingState(for: .sidebar, to: .loading)
        
        let params: Parameters = ZAPIStrings.Parameter.folders(userProfile!.email).value
        
        do {
            let bucketObject = try await repository.getFoldersFromBucket(params)
            self.bucketObjectModels = try await processBucketContents(bucketObject)
            updateLoadingState(for: .sidebar, to: .idle())
            if bucketObjectModels.isEmpty { updateLoadingState(for: .detail, to: .idle(.empty)) }
        } catch {
            handleError(error.localizedDescription)
        }
    }
    
    @MainActor
    private func processBucketContents(_ bucketData: BucketObjectModel) async throws -> [BucketObjectModel] {
        try await withThrowingTaskGroup(of: BucketObjectModel.self) { group in
            for folder in bucketData.contents where folder.actualKeyType == .folder {
                let params: Parameters = ZAPIStrings.Parameter.folders(folder.key).value
                group.addTask {
                    try await self.repository.getFoldersFromBucket(params)
                }
            }
            var results: [BucketObjectModel] = []
            for try await bucket in group {
                results.append(bucket)
            }
            return results
        }
    }
    
    // MARK: - Fetch Application download link
    @MainActor 
    private func fetchPackageURL(_ endpoint: String?) async -> String? {
        guard let prefix = endpoint else { return nil }
        let params: Parameters = ZAPIStrings.Parameter.packageURL(prefix).value

        do {
            let bucketData = try await repository.getFoldersFromBucket(params)
            
            if bucketData.contents.isEmpty {
                updateLoadingState(for: .sidebar, to: .idle())
                return nil
            }
            
            updateLoadingState(for: .sidebar, to: .idle())
            return getPackageURL(from: bucketData.contents)
        } catch {
            handleError(error.localizedDescription)
        }

        return nil
    }
    
    // MARK: - Upload Handling
    @MainActor 
    func uploadPackage(endpoint: String?, _ callBack: @escaping () async -> Void) async {
        guard let endpoint else {
            showToast("Invalid upload endpoint.")
            return
        }
        
        guard let appName = packageHandler.bundleProperties?.bundleName else {
            handleError("Bundle name is missing")
            return
        }
        
        do {
            try await uploadPackageComponents(endpoint: endpoint, appName: appName)
            try await generateInstallerPropertyList(endpoint)
            try await uploadComponent(type: .installerPlist(appName), endpoint: endpoint, message: "Uploading Installer")
            await callBack()
        }catch {
            handleError(error.localizedDescription)
        }
    }
    
    @MainActor
    private func uploadPackageComponents(endpoint: String, appName: String) async throws {
        let components: [(UploadComponentType, String)] = [(.application(appName), "Uploading application"), (.icon, "Uploading app icon"), (.infoPlist, "Uploading Info.plist"), (.provision, "Uploading provision")]
        
        for (type, message) in components {
            try await uploadComponent(type: type, endpoint: endpoint, message: message)
        }
    }
    
    @MainActor
    private func uploadComponent(type: UploadComponentType, endpoint: String, message: String) async throws {
        updateLoadingState(for: .detail, to: .uploading(message))
        guard let data = try fetchData(for: type) else { throw ZError.NetworkError.missingData }
        let apiEndpoint = type.endpoint(for: endpoint)
        try await upload(data: data, to: apiEndpoint, contentType: type.contentType)
    }
    
    @MainActor
    private func fetchData(for type: UploadComponentType) throws -> Data? {
        switch type {
        case .application: return packageHandler.fileTypeDataMap[.app]!
        case .icon: return packageHandler.fileTypeDataMap[.icon] ?? generateDefaultAppIcon()
        case .infoPlist: return packageHandler.fileTypeDataMap[.infoPlist]!
        case .provision: return packageHandler.fileTypeDataMap[.mobileprovision]!
        case .installerPlist: return packageHandler.fileTypeDataMap[.installationPlist]!
        }
    }
    
    @MainActor
    private func generateInstallerPropertyList(_ endpoint: String) async throws {
        updateLoadingState(for: .detail, to: .uploading("Generating .plist"))
        if let objectURL = await fetchPackageURL(endpoint) {
            packageHandler.generatePropertyList(fileURL: objectURL)
        }else {
            throw ZError.LocalError.custom("Failed to generate installation property", nil)
        }
    }
    
    @MainActor
    private func upload(data: Data, to endpoint: ZAPIStrings.Endpoint, contentType: ContentType) async throws {
        let headers = HTTPHeaders([.contentType(contentType.rawValue)])
        let result = try await repository.uploadObjects(endpoint: endpoint, headers: headers, data: data)
        if case .failure(let error) = result {
            throw error
        }
    }
    
    private func downloadFileTask(url: String, type: DownloadType) async {
        do {
            let data = try await downloadFile(from: url)
            handleDownloadSuccess(data: data, type: type)
        }catch {
            handleError(error.localizedDescription)
        }
    }
    
    private func downloadFile(from url: String) async throws -> Data {
        return try await DownloadService(url: url).downloadFile()
    }
    
    private func handleDownloadSuccess(data: Data, type: DownloadType) {
        switch type {
        case .infoFile:
            guard let fileProperties = packageHandler.parsePlist(data) else {
                ZLogs.shared.error(ZError.FileConversionError.fileReadFailed.localizedDescription)
                return
            }
            packageHandler.loadBundleProperties(with: fileProperties)
        case .appIcon:
            packageHandler.fileTypeDataMap[.icon] = data
        case .provision:
            guard let extractedData = try? packageHandler.plistHandler.extractXMLDataFromMobileProvision(data),
                  let mobileProvisionDic = packageHandler.parsePlist(extractedData) else { return }
            packageHandler.loadMobileProvision(with: mobileProvisionDic)
        }
    }

    private func getPackageURL(from contents: [ContentModel]) -> String? {
        contents.filter({ $0.actualContentType == .document && $0.key.contains(".ipa")}).first?.url
    }
    
    /// Extracts the URLs for the app icon, Info.plist, and object plist file from a folder's content list.
    /// - Parameters:
    ///   - contents: The list of contents in the folder.
    ///   - folderName: The name of the folder being processed.
    /// - Returns: A tuple containing the app icon URL, Info.plist URL, and object plist URL (all optional).
    func extractFileURLs(from contents: [ContentModel], folderName: String) -> (iconURL: String?, infoPlistURL: String?, provisionURL: String?, objectURL: String?) {
        let iconURL = contents.first(where: { $0.actualContentType == .png && $0.key.contains("AppIcon60x60@") })?.url
        let infoPlistURL = contents.first(where: { $0.actualContentType == .document && $0.key.contains("Info.plist") })?.url
        let provisionURL = contents.first(where: { $0.actualContentType == .mobileProvision && $0.key.contains("embedded.mobileprovision") })?.url
        let objectURL = contents.first(where: { $0.actualContentType == .document && $0.key.contains("\(folderName).plist") })?.url
        return (iconURL, infoPlistURL, provisionURL, objectURL)
    }
    
    // MARK: - Error and Toast Handling
    func handleError(_ error: String) {
        ZLogs.shared.error(error)
        showToast(error)
        updateLoadingState(for: .detail, to: .error(.detailError))
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
