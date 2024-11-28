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
    
    private let tabs: [Screen] = [.home, .settings] // Add all tabs here
    
    var body: some View {
        TabView(selection: $tabSelection, content:  {
            ForEach(tabs, id: \.self) { tab in
                appCoordinator.build(forScreen: tab)
                    .tabItem { tab.label }
                    .tag(tab)
            }
        })
    }
}

extension Screen {
    @ViewBuilder
    var label: some View {
        switch self {
        case .home:
            Label("Home", systemImage: "house")
        case .settings:
            Label("Settings", systemImage: "gear")
        default:
            Label("Unknown", systemImage: "x.circle")
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .home:
            HomeView()
        case .settings:
            SettingsView()
        default:
            EmptyView()
        }
    }
}
