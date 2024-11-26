//
//  MEMInstallerApp.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI
import SSOKit

@main
struct MEMInstallerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(StyleManager.colorStyle.tintColor)
                .onOpenURL(perform: { url in
                    ZSSOKit.handle(url, sourceApplication: nil, annotation: [UIApplication.OpenURLOptionsKey.annotation])
                })
        }
    }
}
