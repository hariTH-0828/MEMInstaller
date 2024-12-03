//
//  SettingsView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 27/11/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var coordinator: AppCoordinatorImpl
    let userDataManager: UserDataManager
    let userProfile: ZUserProfile?
    
    init(userDataManager: UserDataManager = UserDataManager()) {
        self.userDataManager = userDataManager
        self.userProfile = userDataManager.retrieveLoggedUserFromKeychain()
    }
    
    var logFileURL: URL {
        return ZLogs.shared.exportLogFile()
    }
    
    var body: some View {
        Form {
            Section {
                UserProfileImageView(userProfile: userProfile!)
            }
            
            Section {
                NavigationLink { coordinator.build(forScreen: .about) } label: {
                    settingLabelView("About", systemName: "i.circle", iconColor: .accentColor)
                }

                Button(action: {
                    coordinator.presentSheet(.activityRepresentable(logFileURL))
                }, label: {
                    settingLabelView("com.learn.meminstaller.setting.share-log", systemName: "arrow.right", iconColor: .orange)
                })
                
                Button(action: {
                    Device.isIpad ? coordinator.pop(.logout) : coordinator.presentSheet(.logout)
                }, label: {
                    settingLabelView("com.learn.meminstaller.setting.signout", color: .red, systemName: "power", iconColor: .red)
                })
            } header: {
                Text("General")
            } footer: {
                footerView
            }
        }
        .navigationTitle("Settings")
    }
    
    @ViewBuilder
    private var footerView: some View {
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
    }
    
    @ViewBuilder
    private func settingLabelView(_ title: LocalizedStringKey, color: Color = StyleManager.colorStyle.invertBackground, systemName: String, iconColor: Color) -> some View {
        Label(
            title: {
                Text(title)
                    .lineLimit(1)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(color)
            },
            icon: {
                Image(systemName: systemName)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(iconColor)
            }
        )
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppCoordinatorImpl())
}
