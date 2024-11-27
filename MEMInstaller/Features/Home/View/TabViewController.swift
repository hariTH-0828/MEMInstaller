//
//  TabViewController.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 27/11/24.
//

import SwiftUI

struct TabViewController: View {
    @EnvironmentObject private var appCoordinator: AppCoordinatorImpl
    @State private var tabSelection: Screen = .home
    
    var body: some View {
        TabView(selection: $tabSelection, content:  {
            appCoordinator.build(forScreen: .home)
                .tabItem { Label("Home", systemImage: "house") }
                .tag(Screen.home)
            
            appCoordinator.build(forScreen: .settings)
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(Screen.settings)
        })
    }
}

#Preview {
    TabViewController()
}
