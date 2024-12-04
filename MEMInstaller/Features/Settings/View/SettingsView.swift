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
    
    // Cache size
    @State var totalCacheSize: String?
    
    // Toast
    @State var toastMessage: String?
    @State var isPresentToast: Bool = false
    
    init(userDataManager: UserDataManager = UserDataManager()) {
        self.userDataManager = userDataManager
        
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            self.userProfile = .preview
        }else {
            self.userProfile = userDataManager.retrieveLoggedUserFromKeychain()
        }
    }
    
    var logFileURL: URL {
        return ZLogs.shared.exportLogFile()
    }
    
    var body: some View {
        GeometryReader { _ in
            VStack {
                UserProfileImageView(userProfile: userProfile!)
                
                NavigationLink { SettingPrivacyView() } label: {
                    SettingLabelView("com.learn.meminstaller.setting.privacy", iconName: "shield", iconColor: Color.green)
                }
                .settingButtonView()
                
                NavigationLink { coordinator.build(forScreen: .about) } label: {
                    SettingLabelView("About", iconName: "i.circle", iconColor: .accentColor)
                    Text("version " + (Bundle.appVersion ?? "v1.0"))
                        .font(.system(size: 14))
                        .foregroundStyle(StyleManager.colorStyle.systemGray)
                }
                .settingButtonView()
                
                Button(action: {
                    coordinator.presentSheet(.activityRepresentable(logFileURL))
                }, label: {
                    SettingLabelView("com.learn.meminstaller.setting.share-log", iconName: "square.and.arrow.up", iconColor: .cyan)
                })
                .settingButtonView()
                
                Button(action: {
                    clearCacheData()
                }, label: {
                    SettingLabelView("com.learn.meminstaller.setting.clear_cache", iconName: "ico_database", iconColor: .blue)
                    
                    Text(totalCacheSize ?? "0")
                        .font(.system(size: 14))
                        .foregroundStyle(StyleManager.colorStyle.systemGray)
                })
                .settingButtonView()
                
                Section {
                    Button(action: {
                        Device.isIpad ? coordinator.pop(.logout) : coordinator.presentSheet(.logout)
                    }, label: {
                        SettingLabelView("com.learn.meminstaller.setting.signout", color: .red, iconName: "power", iconColor: .red)
                    })
                    .settingButtonView()
                } footer: {
                    footerView
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .showToast(message: toastMessage, isShowing: $isPresentToast)
            .onAppear(perform: {
                if !ProcessInfo.processInfo.isPreview {
                    self.totalCacheSize = try? ZFFileManager.shared.getDirectorySize(at: ZFFileManager.shared.getAppCacheDirectory())
                }
            })
        }
    }
    
    @ViewBuilder
    private var footerView: some View {
        Label(
            title: {
                Text("com.learn.meminstaller.setting.footnote")
                    .font(.caption)
                    .foregroundStyle(StyleManager.colorStyle.placeholderText)
            },
            icon: {
                Image(systemName: "c.circle")
                    .font(.caption)
                    .foregroundStyle(StyleManager.colorStyle.placeholderText)
            }
        )
    }
    
    // MARK: - HELPER METHODS
    private func clearCacheData() {
        do {
            try ZFFileManager.shared.clearAllCache()
            self.totalCacheSize = try ZFFileManager.shared.getDirectorySize(at: ZFFileManager.shared.getAppCacheDirectory())
        }catch {
            
        }
    }
}

struct SettingLabelView: View {
    let title: LocalizedStringKey
    let color: Color
    let iconName: String
    let iconColor: Color
    
    init(_ title: LocalizedStringKey, color: Color = StyleManager.colorStyle.invertBackground, iconName: String, iconColor: Color) {
        self.title = title
        self.iconName = iconName
        self.color = color
        self.iconColor = iconColor
    }
    
    var body: some View {
        HStack {
            if UIImage.isAssetAvailable(named: iconName) {
                Image(iconName)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 20, height: 20)
                    .foregroundStyle(iconColor)
            }else {
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(iconColor)
            }
            
            Text(title)
                .lineLimit(1)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


// MARK: - PREVIEW
struct SettingViewPreviewProvider: PreviewProvider {
    
    static var previews: some View {
        NavigationStack {
            SettingsView()
                .navigationTitle("Settings")
                .environmentObject(AppCoordinatorImpl())
        }
    }
}
