//
//  AppViewModel.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI
import SSOKit

final class AppViewModel: ObservableObject {
    static let shared = AppViewModel()
    
    @Published private(set) var isUserLoggedIn: UserLoggedStatus = .logOut
    let userDataManager = UserDataManager()
    
    // Toast
    @Published private(set) var toastMessage: String?
    @Published var isPresentToast: Bool = false
    
    private init() {}
    
    @MainActor
    func initiate(window: UIWindow) {
        /// Initiate IAM
        ZIAMManager.initiate(with: window)
        self.isUserLoggedIn = ZIAMManager.isUserLoggedIn
    }
    
    var getWindow: UIWindow? {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first {
            return window
        }
        
        return nil
    }
    
    @MainActor
    func IAMLogin() {
        Task {
            // Safe: Delete existing user keychain
            try? KeychainService.delete(forKey: KCKeys.loggedUserProfile)
            
            do {
                let userLoggedInStatus = try await ZIAMManager.presentIAMLoginViewController()
                ZLogs.shared.info("IAM Login success")
                
                // Handle success login and save user profile into keychain
                loginSuccessHandler(userLoggedInStatus)
            }catch {
                presentToast(message: error.localizedDescription)
            }
        }
    }
    
    @MainActor
    private func loginSuccessHandler(_ status: UserLoggedStatus) {
        
        let isSaveSuccess = userDataManager.saveLoggedUserIntoKeychain()
        
        if isSaveSuccess {
            // Login success: Navigate to Login view to Home View
            withAnimation(.easeInOut) {
                self.isUserLoggedIn = status
            }
        }
    }
    
    func logout() {
        if ZIAMManager.isUserLoggedIn == .logIn {
            ZIAMManager.logout { logoutStatus in
                try? self.logoutSuccessHandler(logoutStatus)
            }
        }
    }
    
    private func logoutSuccessHandler(_ status: UserLoggedStatus) throws {
        do {
            try KeychainService.delete(forKey: KCKeys.loggedUserProfile)
            ZLogs.shared.info("Successfully deleted logged user from keychain")
            
            // Logout success: Navigate to Setting View to Login View
            withAnimation(.easeInOut) {
                self.isUserLoggedIn = status
            }
        }catch {
            ZLogs.shared.error(error.localizedDescription)
            throw error
        }
    }
    
    @discardableResult
    func applicationOpenUrlHandling(url: URL,sourceApp: String?)  -> Bool {
        let ssoHandle = ZSSOKit.handle(url, sourceApplication: sourceApp, annotation: nil)
         if ssoHandle == true {
             return true
         }
         return true
    }
    
    @MainActor
    private func presentToast(message: String) {
        self.toastMessage = message
        self.isPresentToast = true
    }
}
