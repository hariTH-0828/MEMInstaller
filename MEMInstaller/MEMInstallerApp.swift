//
//  MEMInstallerApp.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI

@main
struct MEMInstallerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject var appViewModel: AppViewModel = AppViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(StyleManager.colorStyle.tintColor)
                .onAppear(perform: {
                    if let window = AppViewModel.shared.getWindow {
                        appViewModel.initiate(window: window)
                    }
                })
                .environmentObject(appViewModel)
        }
    }
}
