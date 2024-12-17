//
//  HomeViewModel.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI
import Zip
import Alamofire
import UniformTypeIdentifiers

// MARK: - File Types
enum SupportedFileTypes {
    case icon, app, mobileprovision, installationPlist, infoPlist
}

enum DownloadType {
    case infoFile, provision
}

class HomeViewModel: ObservableObject {
    // Manage logged user profile
    @Published private(set) var userProfile: ZUserProfile?
    @Published private(set) var bucketObjectModels: [BucketObjectModel] = []
    
    @Published var selectedBucketObject: BucketObjectModel? = nil
    @Published var selectedPackageModel: PackageExtractionModel? = nil {
        didSet {
            selectedBucketObject = nil
        }
    }
    
    // Toast properties
    @Published private(set) var toastMessage: String?
    @Published var isPresentToast: Bool = false
    
    @Published var sideBarLoadingState: LoadingState = .loading {
        didSet {
            if case .loading = sideBarLoadingState {
                selectedBucketObject = nil
            }
        }
    }
    
    // Dependencies
    private let userDataManager: UserManagerProtocol = UserDataManager()
    private let repository: StratusRepository = StratusRepositoryImpl()
    private let packageHandler: PackageExtractionHandler = PackageExtractionHandler()
    
    init() {
        NotificationCenter.default.addObserver(forName: .refreshData, object: nil, queue: .main) { _ in
            self.fetchFolders()
        }
        self.userProfile = userDataManager.retrieveLoggedUserFromKeychain()
    }
    
    func fetchFolders() {
        Task {
            await fetchFoldersFromBucket()
        }
    }
    
    // MARK: Fetch bucket information
    @MainActor
    private func fetchFoldersFromBucket() async {
        // Initiate Loading ViewState in SideBar
        self.sideBarLoadingState = .loading
        
        let params: Parameters = ZAPIStrings.Parameter.folders(userProfile!.email).value
        
        do {
            let bucketObject = try await repository.getFoldersFromBucket(params)
            self.bucketObjectModels = try await processBucketContents(bucketObject)
            self.sideBarLoadingState = .loaded
        } catch {
            handleError(with: .error, error: error.localizedDescription)
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
    
    @MainActor
    func deleteContentFromBucket(_ prefix: String) {
        Task {
            let bucketDeletionModel = try await repository.deletePathObject(endpoint: .delete, parameters: ZAPIStrings.Parameter.delete(prefix).value)
            ZLogs.shared.info("This path \(bucketDeletionModel.path) is scheduled for deletion")
            self.showToast(bucketDeletionModel.message)
        }
    }
    
    /// Manage on-drop
    func handleDrop(provider: NSItemProvider) -> Bool {
        if provider.hasItemConformingToTypeIdentifier(UTType.ipa.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.ipa.identifier, options: nil) { item, error in
                if let error {
                    self.handleError(with: .error, error: error.localizedDescription)
                    return
                }
                
                guard let fileURL = item as? URL else { return }
                self.handleDroppedIpaFile(at: fileURL)
            }
        }
        return true
    }
    
    private func handleDroppedIpaFile(at url: URL) {
        guard url.pathExtension == "ipa" else {
            handleError(with: .warning, error: ZError.FileConversionError.unsupportedFile.localizedDescription)
            return
        }
        
        mainQueue {
            self.packageHandler.initiateAppExtraction(from: url)
            self.selectedPackageModel = self.packageHandler.getPackageExtractionModel()
        }
    }
    
    // MARK: - Error and Toast Handling
    func handleError(with type: LogLevel, error: String) {
        switch type {
        case .info:
            ZLogs.shared.info(error)
        case .warning:
            ZLogs.shared.warning(error)
        case .error:
            ZLogs.shared.error(error)
        }
        
        showToast(error)
    }
    
    func showToast(_ message: String) {
        toastMessage = message
        isPresentToast = true
    }
}
