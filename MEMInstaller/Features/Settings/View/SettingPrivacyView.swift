//
//  SettingPrivacyView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 04/12/24.
//

import SwiftUI

struct SettingPrivacyView: View {
    @AppStorage(UserDefaultsKey.biometricAuthenticate)
    var isEnableBiometric: Bool = false
    
    @AppStorage(UserDefaultsKey.shareUsageStats)
    var shouldShareUsageStats: Bool = false
    
    @AppStorage(UserDefaultsKey.shareEmailAddress)
    var shouldShareEmailAddress: Bool = true
    
    @AppStorage(UserDefaultsKey.enableCrashReport)
    var shouldShareCrashReport: Bool = false
    
    @AppStorage(UserDefaultsKey.shakeToSendFeedback)
    var shakeToSendFeedBack: Bool = false
    
    var body: some View {
        VStack {
            Section {
                Toggle(isOn: $isEnableBiometric, label: {
                    SettingLabelView("com.learn.meminstaller.setting.privacy.applock", iconName: "lock", iconColor: Color(hex: "e28743"))
                })
                .settingButtonView()
            } footer: {
                Text("com.learn.meminstaller.setting.privacy.applock-desc")
                    .font(.footnote)
                    .foregroundStyle(StyleManager.colorStyle.systemGray)
                    .padding(.horizontal)
            }
            
            Section {
                Toggle(isOn: $shouldShareUsageStats, label: {
                    SettingLabelView("com.learn.meminstaller.setting.privacy.usage-stats", iconName: "", iconColor: Color(hex: "e28743"))
                })
                .settingButtonView()
            } footer: {
                Text("com.learn.meminstaller.setting.privacy.usage-stats-desc")
                    .font(.footnote)
                    .foregroundStyle(StyleManager.colorStyle.systemGray)
                    .padding(.horizontal)
            }
            
            Section {
                Toggle(isOn: $shouldShareEmailAddress, label: {
                    SettingLabelView("com.learn.meminstaller.setting.privacy.share-email", iconName: "", iconColor: Color(hex: "e28743"))
                })
                .settingButtonView()
            } footer: {
                Text("com.learn.meminstaller.setting.privacy.share-email-desc")
                    .font(.footnote)
                    .foregroundStyle(StyleManager.colorStyle.systemGray)
                    .padding(.horizontal, 20)
            }
            
            Section {
                Toggle(isOn: $shouldShareCrashReport, label: {
                    SettingLabelView("com.learn.meminstaller.setting.privacy.crash-report", iconName: "", iconColor: Color(hex: "e28743"))
                })
                .settingButtonView()
            } footer: {
                Text("com.learn.meminstaller.setting.privacy.crash-report-desc")
                    .font(.footnote)
                    .foregroundStyle(StyleManager.colorStyle.systemGray)
                    .padding(.horizontal)
            }
            
            Section {
                Toggle(isOn: $shakeToSendFeedBack, label: {
                    SettingLabelView("com.learn.meminstaller.setting.privacy.shake-feedback", iconName: "ico_shake_phone", iconColor: Color.teal)
                })
                .settingButtonView()
            } footer: {
                Text("com.learn.meminstaller.setting.privacy.shake-feedback-desc")
                    .font(.footnote)
                    .foregroundStyle(StyleManager.colorStyle.systemGray)
                    .padding(.horizontal)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationTitle("Privacy")
    }
}

struct SettingPrivacyView_previewProvider: PreviewProvider {
    
    static var previews: some View {
        NavigationStack {
            SettingPrivacyView()
                .environmentObject(AppCoordinatorImpl())
        }
    }
}
