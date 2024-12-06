//
//  AttachedFileDetailViewModel.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 05/12/24.
//

import Foundation
import SwiftUI
import Alamofire

enum PListCellIdentifiers: String, CaseIterable {
    case bundleName = "Bundle name"
    case bundleIdentifiers = "Bundle identifiers"
    case bundleVersionShort = "Bundle version (short)"
    case bundleVersion = "Bundle version"
    case minOSVersion = "Minimum OS version"
    case requiredDevice = "Required device compability"
    case supportedPlatform = "Suppported platform"
}

enum ProvisionCellIdentifiers: String, CaseIterable {
    case name = "Name"
    case teamIdentifier = "Team identifier"
    case creationDate = "Creation date"
    case expiredDate = "Expired date"
    case teamName = "Team name"
    case version = "Version"
}

enum AttachmentMode: Hashable {
    case install
    case upload
}

@MainActor
class AttachedFileDetailViewModel: ObservableObject {
    let packageHandler: PackageExtractionHandler = PackageExtractionHandler.shared

    let repository: StratusRepository = StratusRepositoryImpl()
    let userDataManager: UserDataManager = UserDataManager()
    
    @Published var detailViewState: LoadingState = .loading
    @Published var uploadProgress: Double = 0.0

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
            packageHandler.loadBundleProperties(with: fileProperties)
        case .provision:
            guard let extractedData = try? packageHandler.extractXMLFromProvision(data),
                  let mobileProvisionDic = packageHandler.parsePlist(extractedData) else { return }
            packageHandler.loadMobileProvision(with: mobileProvisionDic)
        }
    }

    // MARK: - Upload Handling
    @MainActor
    func uploadPackage(endpoint: String?, _ callBack: @escaping () async -> Void) async {
        guard let endpoint else {
            showToast("Invalid upload endpoint.")
            return
        }

        guard let appName = packageHandler.bundleProperties?.bundleName else {
            showToast("Bundle name is missing")
            return
        }

        do {
            try await uploadPackageComponents(endpoint: endpoint, appName: appName)
            try await generateInstallerPropertyList(endpoint)
            try await uploadComponent(type: .installerPlist(appName), endpoint: endpoint, message: "Uploading Installer")
            await callBack()
        }catch {
            showToast(error.localizedDescription)
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
//        updateLoadingState(for: .detail, to: .uploading(message))
        guard let data = try fetchData(for: type) else { throw ZError.NetworkError.missingData }
        let apiEndpoint = type.endpoint(for: endpoint)
        try await upload(data: data, to: apiEndpoint, contentType: type.contentType)
    }

    @MainActor
    private func fetchData(for type: UploadComponentType) throws -> Data? {
        switch type {
        case .application: return packageHandler.packageExtractionModel?.app
        case .icon: return packageHandler.packageExtractionModel?.appIcon ?? generateDefaultAppIcon()
        case .infoPlist: return packageHandler.packageExtractionModel?.infoPropertyList
        case .provision: return packageHandler.packageExtractionModel?.mobileProvision
        case .installerPlist: return packageHandler.packageExtractionModel?.installationPList
        }
    }

    @MainActor
    private func generateInstallerPropertyList(_ endpoint: String) async throws {
//        updateLoadingState(for: .detail, to: .uploading("Generating .plist"))
        if let objectURL = await fetchPackageURL(endpoint) {
            packageHandler.generatePropertyList(fileURL: objectURL)
        }else {
            throw ZError.LocalError.custom("Failed to generate installation property", nil)
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
//                updateLoadingState(for: .sidebar, to: .idle())
                return nil
            }

//            updateLoadingState(for: .sidebar, to: .idle())
            return bucketData.getPackageURL()
        } catch {
//            handleError(error.localizedDescription)
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

    private func generateDefaultAppIcon() -> Data? {
        imageWith(name: packageHandler.bundleProperties?.bundleName)?.pngData()
    }
    
    func handleError(_ error: String) {
        ZLogs.shared.error(error)
        showToast(error)
    }

    func showToast(_ message: String?) {
        self.toastMessage = message
        self.isShowingToast = true
    }
}


extension AttachedFileDetailViewModel {
    static var preview: AttachedFileDetailViewModel {
        AttachedFileDetailViewModel()
    }
}
