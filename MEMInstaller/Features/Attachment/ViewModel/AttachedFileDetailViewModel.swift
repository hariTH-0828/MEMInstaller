//
//  AttachedFileDetailViewModel.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 05/12/24.
//

import Foundation
import SwiftUI
import Alamofire

enum AttachmentMode: Hashable {
    case install
    case upload
}

@MainActor
class AttachedFileDetailViewModel: ObservableObject {
    private let packageHandler: PackageExtractionHandler = PackageExtractionHandler()
    
    @Published var detailLoadingState: LoadingState = .loaded {
        didSet {
            if case .loading = detailLoadingState {
                resetViewModel()
            }
        }
    }
    @Published var uploadProgress: Double = 0.0
    
    @Published var bundleProperties: BundleProperties?
    @Published var mobileProvision: MobileProvision?
    
    private var packageExtractionModel: PackageExtractionModel?

    private let repository: StratusRepository = StratusRepositoryImpl()
    private let userDataManager: UserManagerProtocol = UserDataManager()

    // Toast
    @Published var isShowingToast: Bool = false
    @Published private(set) var toastMessage: String?

    var userProfile: ZUserProfile? {
        return userDataManager.retrieveLoggedUserFromKeychain()
    }
    
    init() {
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
    
    // MARK: - Download Handling
    func downloadFile(url: String, type: DownloadType) async {
        await downloadFileTask(url: url, type: type)
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
            self.bundleProperties = packageHandler.loadBundleProperties(with: fileProperties)
        case .provision:
            guard let extractedData = try? packageHandler.extractXMLFromProvision(data),
                  let mobileProvisionDic = packageHandler.parsePlist(extractedData) else { return }
            self.mobileProvision = packageHandler.loadMobileProvision(with: mobileProvisionDic)
        }
    }
    
    // MARK: - File Data to properties
    func readFileDataToProperites(infoProperties: Data?, mobileProvision: Data?) {
        guard let infoProperties, let mobileProvision else { return }
        handleDownloadSuccess(data: infoProperties, type: .infoFile)
        handleDownloadSuccess(data: mobileProvision, type: .provision)
    }

    // MARK: - Upload Handling
    @MainActor
    func uploadPackage(endpoint: String?, packageExtractionModel model: PackageExtractionModel?, _ callBack: @escaping () async -> Void) async {
        guard let endpoint else {
            showToast("Invalid upload endpoint.")
            return
        }

        guard let appName = bundleProperties?.bundleName else {
            showToast("Bundle name is missing")
            return
        }
        
        self.packageExtractionModel = model

        do {
            try await uploadPackageComponents(endpoint: endpoint, appName: appName)
            try await generateInstallerPropertyList(endpoint)
            try await uploadComponent(type: .installerPlist(appName), endpoint: endpoint, message: "Uploading Installer")
            await callBack()
        }catch {
            // MARK: Handle Deletion
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
        self.detailLoadingState = .uploading(message)
        guard let data = try fetchData(for: type) else { throw ZError.NetworkError.missingData }
        let apiEndpoint = type.endpoint(for: endpoint)
        try await upload(data: data, to: apiEndpoint, contentType: type.contentType)
    }

    @MainActor
    private func fetchData(for type: UploadComponentType) throws -> Data? {
        switch type {
        case .application: return packageExtractionModel?.app
        case .icon: return packageExtractionModel?.appIcon ?? generateDefaultAppIcon()
        case .infoPlist: return packageExtractionModel?.infoPropertyList
        case .provision: return packageExtractionModel?.mobileProvision
        case .installerPlist: return packageExtractionModel?.installationPList
        }
    }

    @MainActor
    private func generateInstallerPropertyList(_ endpoint: String) async throws {
        self.detailLoadingState = .uploading("Generating .plist")
        
        if let objectURL = await fetchPackageURL(endpoint) {
            generatePropertyList(objectURL)
        }else {
            throw ZError.LocalError.custom("Failed to generate installation property", nil)
        }
    }
    
    private func generatePropertyList(_ objectURL: String) {
        guard let bundleId = bundleProperties?.bundleIdentifier,
              let bundleVersion = bundleProperties?.bundleVersion,
              let fileName = bundleProperties?.bundleName else { return }
        
        let installationProperty = packageHandler.generatePropertyList(fileURL: objectURL,
                                            bundleId: bundleId,
                                            bundleVersion: bundleVersion,
                                            fileName: fileName)
        
        self.packageExtractionModel?.installationPList = installationProperty
    }

    // MARK: - Fetch Application download link
    @MainActor
    private func fetchPackageURL(_ endpoint: String?) async -> String? {
        guard let prefix = endpoint else { return nil }
        let params: Parameters = ZAPIStrings.Parameter.packageURL(prefix).value

        do {
            let bucketData = try await repository.getFoldersFromBucket(params)

            if bucketData.contents.isEmpty {
                return nil
            }

            return bucketData.getPackageURL()
        } catch {
            handleError(error.localizedDescription)
        }

        return nil
    }

    @MainActor
    private func upload(data: Data, to endpoint: ZAPIStrings.Endpoint, contentType: ContentType) async throws {
        let headers = HTTPHeaders([.contentType(contentType.rawValue)])
        let result = try await repository.uploadObjects(endpoint: endpoint, headers: headers, data: data)
        if case .failure(let error) = result {
            throw error
        }
    }
    
    func installApplication(_ installationFileURL: String?) {
        guard let objectURL = installationFileURL else {
            handleError("Error: Installation - objectURL not found")
            return
        }

        let itmsServicesURLString: String = Constants.installationPrefix + objectURL

        if let itmsServiceURL = URL(string: itmsServicesURLString) {
            UIApplication.shared.open(itmsServiceURL)
        }
    }
    
    func checkApplicationCanOpen() -> Bool {
        guard let url = bundleProperties?.redirectURL else { return false }
        return UIApplication.shared.canOpenURL(URL(string: "\(url)://")!)
    }

    private func generateDefaultAppIcon() -> Data? {
        imageWith(name: bundleProperties?.bundleName)?.pngData()
    }
    
    func handleError(_ error: String) {
        ZLogs.shared.error(error)
        showToast(error)
        self.detailLoadingState = .loaded
    }

    func showToast(_ message: String?) {
        self.toastMessage = message
        self.isShowingToast = true
    }
    
    func resetViewModel() {
        bundleProperties = nil
        mobileProvision = nil
    }
}
