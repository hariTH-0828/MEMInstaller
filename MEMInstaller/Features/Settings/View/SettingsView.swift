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

struct FooterView: View {
    var body: some View {
        Label(
            title: {
                Text("com.learn.meminstaller.setting.footnote")
                    .font(.caption)
            },
            icon: {
                Image(systemName: "c.circle")
                    .font(.caption)
            }
        )
        .foregroundStyle(StyleManager.colorStyle.systemGray)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppCoordinatorImpl())
}
