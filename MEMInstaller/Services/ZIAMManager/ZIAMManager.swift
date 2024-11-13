//
//  ZIAMManager.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 12/11/24.
//

import Foundation
import SSOKit

typealias getIAMTokenSuccessBlock = (String) -> Void
typealias getIAMTokenErrorBlock = (Error?) -> Void
typealias getIAMPofilePicSuccessBlock = (UIImage) -> Void
typealias getIAMLogoutSuccessBlock = (UserLoggedStatus) -> Void

public enum UserLoggedStatus {
    case logIn
    case logOut
}

final class ZIAMManager {
    
    private class func oAuthScopes() -> [String] {
        return [
            "ZohoCatalyst.projects.READ",
            "ZohoCatalyst.projects.CREATE",
            "ZohoCatalyst.projects.UPDATE",
            "ZohoCatalyst.projects.DELETE",
            "ZohoCatalyst.projects.users.READ",
            "ZohoCatalyst.projects.users.CREATE",
            "ZohoCatalyst.projects.users.DELETE",
            "ZohoCatalyst.folders.READ",
            "ZohoCatalyst.folders.CREATE",
            "ZohoCatalyst.folders.UPDATE",
            "ZohoCatalyst.folders.DELETE",
            "ZohoCatalyst.files.READ",
            "ZohoCatalyst.files.CREATE",
            "ZohoCatalyst.files.DELETE",
            "ZohoCatalyst.buckets.READ",
            "ZohoCatalyst.buckets.objects.READ",
            "Stratus.fileop.READ"
        ]
    }
    
    public class func initiate(window: UIWindow) {
        let oAuthClientId: String = "1002.5B3D2AWQPLA6FABTW0R4T9JHJAR1HF"
        let oAuthURLScheme: String = "zadminzorroware://"
        let oAuthLoginMode: SSOBuildType = {
            #if INHOUSE_RELEASE
            return .Live_SSO_Mdm
            #else
            return .Live_SSO
            #endif
        }()
        
        let userDefaults = UserDefaults.standard
        
        if !userDefaults.bool(forKey: UserDefaultsKey.appFirstLaunch) {
            ZSSOKit.clearSSODetailsForFirstLaunch()
            userDefaults.set(true, forKey: UserDefaultsKey.appFirstLaunch)
            userDefaults.synchronize()
        }
        
        ZSSOKit.initWithClientID(oAuthClientId, scope: oAuthScopes(), urlScheme: oAuthURLScheme, mainWindow: window, buildType: oAuthLoginMode)
    }
    
    class func getCurrentLoggedInUser() -> ZSSOUser? {
        return ZSSOKit.getCurrentUser()
    }
    
    class func getCurrentLoggedUserProfile() -> ZSSOProfileData? {
        if let userInfo = ZSSOKit.getCurrentUser() {
            return userInfo.profile
        }
        
        return nil
    }
    
    public class var getCurrentLoggedUserId: String {
        return ZSSOKit.getCurrentUser().userZUID
    }

    public class var isUserLoggedIn: UserLoggedStatus {
        return ZSSOKit.isUserSignedIn() ? .logIn : .logOut
    }
    
    // MARK: PRESENT LOGIN
    public class func presentIAMLoginViewController() async throws -> UserLoggedStatus {
        return try await withCheckedThrowingContinuation { continuation in
            if ZIAMManager.isUserLoggedIn == .logOut {
                ZSSOKit.presentInitialViewController(withCustomParams: "hide_fs=true") { (_, error) in
                    if let error = error {
                        continuation.resume(throwing: error)
                    }else {
                        continuation.resume(returning: .logIn)
                    }
                }
            }
        }
    }
    
    // MARK: GET ACCESS TOKEN
    public class func getIAMAccessToken() async throws -> String? {
        if !ZSSOKit.isUserSignedIn() {
            throw ZError.IAMError.notSignedIn
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            ZSSOKit.getOAuth2Token { accessToken, error in
                if let error = error {
                    continuation.resume(throwing: error)
                }else {
                    continuation.resume(returning: accessToken)
                }
            }
        }
    }
    
    public class func getIAMAccessToken(completion: @escaping (String) -> Void, failure errorBlock: @escaping getIAMTokenErrorBlock) {
        if !ZSSOKit.isUserSignedIn() {
            let newError = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil)
            errorBlock(newError)
            return
        }
        
        ZSSOKit.getOAuth2Token { accessToken, error in
            DispatchQueue.main.async {
                guard let token = accessToken else {
                    errorBlock(error)
                    return
                }
                
                completion(token)
            }
        }
    }


    // MARK: GET USER_PROFILE
    public class func getIAMProfileImage(imgSize : CGSize? , _ successBlock:@escaping getIAMPofilePicSuccessBlock) {
        
        DispatchQueue.main.async {
            let profile = ZSSOKit.getCurrentUser().profile

            guard let imageData = profile?.profileImageData, var image = UIImage(data: imageData) else {
                let userName = profile?.displayName
                let letterAvatar = imageWith(name: userName)
                successBlock(letterAvatar!)
                return
            }

            if let size = imgSize {
                image = image.downsampleImage(size: size) ?? imageWith(name: profile?.displayName)!
            }
            successBlock(image)
        }
    }

    // MARK: LOGOUT
    public class func logout(_ successBlock:@escaping getIAMLogoutSuccessBlock) {
        if !ZSSOKit.isUserSignedIn(){
            successBlock(.logOut)
            return
        }
        
        ZSSOKit.revokeAccessToken { (_error) in
            DispatchQueue.main.async {
                if _error != nil{
                    ZSSOKit.clearSSODetailsForFirstLaunch()
                }
                successBlock(.logOut)
            }
        }
    }
    
    // MARK: CHECK AND FORCE LOGOUT
    public class func checkOAuthAndForceLogout(successBlock: @escaping getIAMLogoutSuccessBlock) {
        if ZSSOKit.isUserSignedIn() {
           
            ZSSOKit.checkAndLogoutUserDuringInvalidOAuth { error in
                guard let errorCode = error?.localizedDescription, errorCode.elementsEqual("invalid_mobile_code") else {
                    return
                }
                
                successBlock(.logOut)
            }
        }
    }
}
