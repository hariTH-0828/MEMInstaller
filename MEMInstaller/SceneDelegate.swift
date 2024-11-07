//
//  SceneDelegate.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 05/11/24.
//

import ZCatalyst
import SwiftUI

@available(iOS  13.0,*)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let winScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: winScene)
        window.rootViewController = UIHostingController(rootView: ContentView())
        window.makeKeyAndVisible()
        
        ZCatalystManager.initiate(window: window)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let context = URLContexts.first {
            ZCatalystApp.shared.handleLoginRedirection(context.url, sourceApplication: context.options.sourceApplication, annotation: context.options.annotation as Any)
        }
    }
}

