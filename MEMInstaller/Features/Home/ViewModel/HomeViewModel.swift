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
    @Published private(set) var bucket: BucketObjectModel?
    @Published var isLoading: Bool = true
    
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
    func fetchBucket() async {
        guard let email = userprofile?.email else { return }
        
        do {
            let params: Parameters = ["bucket_name": "packages", "prefix": "\(email)/ipa/"]
            self.bucket = try await repository.getAllObjects(params)
            isLoading = false
            print(bucket!)
        }catch {
            ZLogs.shared.error("Error in FetchBucket() - \(error.localizedDescription)")
            presentToast(message: error.localizedDescription)
            isLoading = false
        }
    }
    
    func a() {
        
    }
    
    func presentToast(message: String?) {
        toastMessage = message
        isPresentToast = true
    }
}



/*
 
 BucketModel(bucketName: "packages", projectDetails: ProjectDetail(projectName: "ZInstaller", projectId: 21317000000012001), createdBy: CreatedBy(firstName: "Hariharan", lastName: "R S", emailId: "hariharan.rs@zohocorp.com", userType: "Admin"), createdTime: "Nov 04, 2024 04:10 PM", bucketURL: "https://packages-development.zohostratus.com")
 
 */
