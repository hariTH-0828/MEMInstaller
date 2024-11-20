//
//  AppDelegate.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 05/11/24.
//

import Foundation
import UIKit
import SSOKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApp = options[.sourceApplication] as? String
        return AppViewModel.shared.applicationOpenUrlHandling(url: url, sourceApp: sourceApp)
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
          let sceneConfig: UISceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
          sceneConfig.delegateClass = SceneDelegate.self
          return sceneConfig
    }
    
    public func discardSelfContainedWindows() {
        let scenes = UIApplication.shared.connectedScenes
        scenes.forEach({
            dismissWindow(with: .standard,session: $0.session)
        })
    }
    
    func dismissWindow(with windowDismissalAnimation: UIWindowScene.DismissalAnimation,session : UISceneSession){
        let options = UIWindowSceneDestructionRequestOptions()
        options.windowDismissalAnimation = windowDismissalAnimation
        UIApplication.shared.requestSceneSessionDestruction(session, options: options) { (error) in
            ZLogs.shared.error(error.localizedDescription)
        }
    }
}

