//
//  UserDataManager.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 13/11/24.
//

import SwiftUI

class UserDataManager: UserManagerProtocol {

    /// Saves the currently logged-in user profile to the Keychain.
    /// - Returns: `true` if the profile is saved successfully, otherwise `false`.
    @discardableResult
    func saveLoggedUserIntoKeychain() -> Bool {
        guard let userProfile = ZIAMManager.getCurrentLoggedUserProfile() else {
            ZLogs.shared.error(ZError.IAMError.userProfileNotFound.localizedDescription)
            return false
        }
        
        let zuserProfile = ZUserProfile(name: userProfile.name,
                                        displayName: userProfile.displayName,
                                        email: userProfile.email,
                                        profileImageData: userProfile.profileImageData)
        
        do {
            try KeychainService.save(value: zuserProfile, forKey: KCKeys.loggedUserProfile)
            ZLogs.shared.log(.info, message: "Successfully saved the logged-in user profile to the Keychain.")
            return true
        }catch {
            ZLogs.shared.error(ZError.KeyChainError.failedToSave.localizedDescription)
        }
        
        return false
    }
    
    /// Retrieves the logged-in user profile from the Keychain.
    /// - Returns: The ``ZUserProfile`` if retrieval is successful, or `nil` if it fails.
    func retriveLoggedUserFromKeychain() -> ZUserProfile? {
        do {
            return try KeychainService.retrieve(forKey: KCKeys.loggedUserProfile)
        }catch {
            ZLogs.shared.error(ZError.KeyChainError.failedToRetrieve.localizedDescription)
            return nil
        }
    }
}
