//
//  AppViewModel.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI

@MainActor
class AppViewModel: ObservableObject {
    static var shared: AppViewModel = AppViewModel()
    
    @Published private(set) var isUserLoggedIn: UserLoggedStatus = .logOut
    
    // Toast
    @Published private(set) var toastMessage: String?
    @Published var isPresentToast: Bool = false
    
    private init() {
        self.isUserLoggedIn = ZCatalystManager.isUserSignedIn()
    }
    
    func login() {
        Task {
            // Safe: Delete existing user keychain
            try KeychainService.delete(forKey: KCKeys.loggedUserProfile)
            
            await ZCatalystManager.presentLoginView {[weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let loggedStatus):
                    // Login success: Fetch login user info and store into keychain
                    self.loginSuccessHandler(loggedStatus)
                case .failure(let error):
                    presentToast(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func loginSuccessHandler(_ status: UserLoggedStatus) {
        // Fetch user from ZCatalystManager
        ZCatalystManager.getCurrentLoggedUserProfile {[weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let userprofile):
                let zcuserprofile = ZCUserProfile.fromZCatalystUser(userprofile)
                ZLogs.shared.info("Login: \(zcuserprofile.email)")
                
                // Save user into keychain
                try? KeychainService.save(value: zcuserprofile, forKey: KCKeys.loggedUserProfile)
                ZLogs.shared.log(.info, message: "Successfully saved logged user info into keychain")
                
                // Login success: Navigate to Login view to Home View
                withAnimation(.spring(duration: 1.5)) {
                    self.isUserLoggedIn = status
                }
            case .failure(let error):
                ZLogs.shared.log(.error, message: error.localizedDescription)
                presentToast(message: error.localizedDescription)
            }
        }
    }
    
    func logout() {
        Task {
            await ZCatalystManager.logout {[weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let loggedStatus):
                    do {
                        // Logout success: Remove user credential from keychain
                        try logoutSuccessHandler(loggedStatus)
                    }catch {
                        self.presentToast(message: error.localizedDescription)
                    }
                case .failure(let error):
                    self.presentToast(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func logoutSuccessHandler(_ status: UserLoggedStatus) throws {
        do {
            try KeychainService.delete(forKey: KCKeys.loggedUserProfile)
            ZLogs.shared.info("Successfully deleted logged user from keychain")
            
            // Logout success: Navigate to Setting View to Login View
            withAnimation(.spring(duration: 1.5)) {
                self.isUserLoggedIn = status
            }
        }catch {
            ZLogs.shared.error(error.localizedDescription)
            throw error
        }
    }
    
    private func presentToast(message: String) {
        self.toastMessage = message
        self.isPresentToast = true
    }
}
