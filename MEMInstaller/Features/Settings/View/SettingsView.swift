//
//  SettingsView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 27/11/24.
//

import SwiftUI

struct SettingsView: View {
    let userDataManager: UserDataManager = UserDataManager()
    
    var body: some View {
        NavigationSplitView {
            SettingSideBarView()
        } detail: {
            AboutView()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppCoordinatorImpl())
}
