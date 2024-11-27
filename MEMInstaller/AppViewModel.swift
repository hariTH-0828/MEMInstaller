//
//  AppViewModel.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI
import SSOKit

final class AppViewModel: ObservableObject {
    @Published var isUserLoggedIn: Bool = false
    let userDataManager = UserDataManager()
    
    // Toast
    @Published private(set) var toastMessage: String?
    @Published var isPresentToast: Bool = false
    
    init() {
        #if DEBUG
        initConfig()
        #else
        initConfig(buildType: .Local_SSO_Development)
        #endif
    }
    
    func initConfig(buildType: SSOBuildType = .Live_SSO) {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else { return }
        
        ZIAMManager.initiate(with: window)
        self.isUserLoggedIn = ZIAMManager.isUserLoggedIn
        
        NotificationCenter.default.addObserver(forName: .performLogout, object: nil, queue: .main) { _ in
            self.logout()
        }
        
        // Clear existing caches
        try? ZFFileManager.shared.clearAllCache()
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
    private func loginSuccessHandler(_ status: Bool) {
        
        let isSaveSuccess = userDataManager.saveLoggedUserIntoKeychain()
        
        if isSaveSuccess {
            // Login success: Navigate to Login view to Home View
            withAnimation(.easeInOut) {
                self.isUserLoggedIn = status
            }
        }
    }
    
    func logout() {
        if ZIAMManager.isUserLoggedIn {
            ZIAMManager.logout {
                try? self.logoutSuccessHandler()
            }
        }
    }
    
    private func logoutSuccessHandler() throws {
        do {
            try KeychainService.delete(forKey: KCKeys.loggedUserProfile)
            ZLogs.shared.info("Successfully deleted logged user from keychain")
            
            // Logout success: Navigate to Setting View to Login View
            mainQueue {
                withAnimation(.easeInOut) {
                    self.isUserLoggedIn = false
                }
            }
        }catch {
            ZLogs.shared.error(error.localizedDescription)
            throw error
        }
    }
    
    @MainActor
    private func presentToast(message: String) {
        self.toastMessage = message
        self.isPresentToast = true
    }
}
