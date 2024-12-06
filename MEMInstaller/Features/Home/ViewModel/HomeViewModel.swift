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
    case infoFile, provision
}

protocol HomeViewModelProtocol: ObservableObject {
    func fetchFolders()
    var bucketObjectModels: [BucketObjectModel] { get }
    var sideBarLoadingState: LoadingState { get }
    var toastMessage: String? { get }
    var isPresentToast: Bool { get }
    var userProfile: ZUserProfile? { get }
}

class HomeViewModel: HomeViewModelProtocol {
    // Manage logged user profile
    @Published private(set) var userProfile: ZUserProfile?
    @Published private(set) var bucketObjectModels: [BucketObjectModel] = []
    @Published var selectedBucketObject: BucketObjectModel? = nil
    @Published var selectedPackageModel: PackageExtractionModel? = nil {
        didSet {
            selectedBucketObject = nil
        }
    }
    
    @Published var sideBarLoadingState: LoadingState = .loading
    
    // Toast properties
    @Published private(set) var toastMessage: String?
    @Published var isPresentToast: Bool = false
    
    // Dependencies
    private let userDataManager: UserDataManager
    private let repository: StratusRepository
    
    init(
        repository: StratusRepository,
        userDataManager: UserDataManager
    ) {
        self.repository = repository
        self.userDataManager = userDataManager
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
            sideBarLoadingState = state
        }
    }
}
