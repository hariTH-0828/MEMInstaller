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
    @Published var isDownloadStateEnable: Bool = false
    
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
    
    func downloadInfoFile(url: String) {
        // Enable loading state
        isDownloadStateEnable = true
        
        Download(url: url).downloadFile {[weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let fileData):
                try? self.packageHandler.parseInfoPlist(fileData)
                self.isDownloadStateEnable = false
            case .failure(let error):
                isDownloadStateEnable = false
                self.presentToast(message: error.localizedDescription)
            }
        }
    }
    
    func downloadAppIconFile(url: String) {
        // Enable loading state
        isDownloadStateEnable = true
        
        Download(url: url).downloadFile {[weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let iconData):
                self.packageHandler.appIcon = iconData
                isDownloadStateEnable = false
            case .failure(let error):
                isDownloadStateEnable = false
                self.presentToast(message: error.localizedDescription)
            }
        }
    }
    
    private func getFilesFromTheFolder(_ rootObject: BucketObjectModel) async {
        for content in rootObject.contents {
            // Check whether key type is folder
            if content.actualKeyType == .folder {
                // Get folder name
                let folderName = URL(string: content.url)!.lastPathComponent
                let params: Parameters = ["bucket_name": "packages", "prefix": "\(content.key)/"]
                
                do {
                    let fileObjects = try await repository.getFoldersFromBucket(params).contents
                    self.allObject[folderName] = fileObjects
                }catch {
                    withAnimation { isLoading = false }
                    ZLogs.shared.info(error.localizedDescription)
                    presentToast(message: error.localizedDescription)
                }
            }
        }
        
        withAnimation { isLoading = false }
    }
    
    func presentToast(message: String?) {
        toastMessage = message
        isPresentToast = true
    }
}
