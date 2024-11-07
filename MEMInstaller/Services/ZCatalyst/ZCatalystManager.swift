//
//  ZCatalystManager.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 05/11/24.
//

import Foundation
import ZCatalyst

public enum UserLoggedStatus {
    case logIn
    case logOut
}

public class ZCatalystManager {
    
    public class func initiate(window: UIWindow) {
        
        if !UserDefaults.standard.bool(forKey: "appLaunched") {
            UserDefaults.standard.set(true, forKey: "appLaunched")
            ZohoPortalAuth.clearZohoAuthPortalDetailsForFirstLaunch()
        }
        
        do {
            try ZCatalystApp.shared.initSDK(window: window, environment: .development)
        }catch {
            ZLogs.shared.error(error.localizedDescription)
        }
}
    
    class func isUserSignedIn() -> UserLoggedStatus {
        ZCatalystApp.shared.isUserSignedIn() ? .logIn : .logOut
    }
    
    class func getCurrentLoggedUserProfile(completion: @escaping (Swift.Result<ZCatalystUser, Error>) -> Void) {
        ZCatalystApp.shared.getCurrentUser { result in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .error(let error):
                completion(.failure(error))
            }
        }
    }
    
    public class func presentLoginView(completion: @escaping (Swift.Result<UserLoggedStatus, Error>) -> Void) async {
        ZCatalystApp.shared.showLogin { error in
            guard let error else {
                completion(.success(.logIn))
                return
            }
            completion(.failure(error))
        }
    }
    
    public class func logout(completion: @escaping (Swift.Result<UserLoggedStatus, Error>) -> Void) async {
        ZCatalystApp.shared.logout { error in
            guard let error else {
                completion(.success(.logOut))
                return
            }
            completion(.failure(error))
        }
    }
}
