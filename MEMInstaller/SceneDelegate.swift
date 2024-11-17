//
//  SceneDelegate.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 17/11/24.
//

import Foundation
import SSOKit

@available(iOS  13.0,*)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var appViewModel = AppViewModel.shared
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let winScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: winScene)
        if window?.windowScene != winScene {
            window = UIWindow(windowScene: winScene)
        } else {
            window?.rootViewController = nil
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url{
            appViewModel.applicationOpenUrlHandling(url: url, sourceApp: URLContexts.first?.options.sourceApplication)
        }
    }
}
