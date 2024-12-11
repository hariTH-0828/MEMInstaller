//
//  SettingsView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 27/11/24.
//

import SwiftUI
import MEMToast

struct SettingsView: View {
    @EnvironmentObject private var coordinator: AppCoordinatorImpl
    let userDataManager: UserDataManager
    let userProfile: ZUserProfile?
    
    // Cache size
    @State private var totalCacheSize: String?
    
    // Toast
    @State var toastMessage: String?
    @State var isPresentToast: Bool = false
    
    init(userDataManager: UserDataManager = UserDataManager()) {
        self.userDataManager = userDataManager
        
        if ProcessInfo.processInfo.isPreview {
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
                
                NavigationLink { coordinator.build(forScreen: .privacy) } label: {
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
                    .popover(item: $coordinator.popView, arrowEdge: .bottom) { pop in
                        coordinator.build(forPop: pop)
                    }
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
        try? ZFFileManager.shared.clearAllCache()
        self.totalCacheSize = try? ZFFileManager.shared.getDirectorySize(at: ZFFileManager.shared.getAppCacheDirectory())
    }
}


// MARK: - PREVIEW
struct SettingViewPreviewProvider: PreviewProvider {
    
    static var previews: some View {
        NavigationStack {
            SettingsView()
                .navigationTitle("Settings")
        }
    }
}
