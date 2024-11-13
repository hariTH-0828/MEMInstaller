//
//  SettingsView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI

struct SettingView: View {
    @State private var shouldShowLogoutSheet: Bool = false
    @State var isPresentShareLog: Bool = false
    
    let userprofile: ZUserProfile
    
    var logFileURL: URL {
        return ZLogs.shared.exportLogFile()
    }
    
    // Cache size
    @State private var totalCacheSize: String = "0"
    
    init(userprofile: ZUserProfile) {
        self.userprofile = userprofile
    }
    
    // Toast properties
    @State var toastMessage: String? = nil
    @State var isPresentToast: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                userProfileView()
                
                Section {
                    shareLogsView()
                    removeLogFileView()
                }
                
                clearCacheView()
                
                logoutSectionView()
            }
            .navigationTitle("com.learn.meminstaller.setting.title")
            .navigationBarTitleDisplayMode(.inline)
            .showToast(message: toastMessage, isShowing: $isPresentToast)
            .sheet(isPresented: $isPresentShareLog, content: {
                handleExportLogFile()
            })
        }
    }
    
    @ViewBuilder
    private func userProfileView() -> some View {
        HStack(alignment: .top) {
            Image(uiImage: imageWith(name: userprofile.displayName)!)
                .resizable()
                .frame(width: 45, height: 45)
                .clipped()
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(userprofile.displayName)")
                    .font(.system(size: 17, weight: .semibold))
                    .padding(.leading, 8)
                
                Text(userprofile.email)
                    .lineLimit(1)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(StyleManager.colorStyle.secondary)
                    .padding(.leading, 8)
            }
        }
    }
    
    @ViewBuilder
    private func shareLogsView() -> some View {
        Button(action: {
            FileManager.default.fileExists(atPath: logFileURL.path()) ? isPresentShareLog.toggle() : presentToast(message: "Error: No file found")
        }, label: {
            ZLabel {
                Text("Share your logs")
                    .foregroundStyle(StyleManager.colorStyle.invertBackground)
                    .font(.system(size: 16, weight: .regular))
            } icon: {
                Image("log")
                    .resizable()
                    .frame(width: 16, height: 17)
            }
        })
    }
    
    @ViewBuilder
    private func removeLogFileView() -> some View {
        Button(action: {
            removeLogFileFromCache()
        }, label: {
            ZLabel {
                Text("Remove logs")
                    .foregroundStyle(StyleManager.colorStyle.invertBackground)
                    .font(.system(size: 16, weight: .regular))
            } icon: {
                Image(systemName: "trash")
                    .foregroundStyle(.gray)
            }
        })
    }
    
    @ViewBuilder
    private func clearCacheView() -> some View {
        Section {
            List {
                Button(action: { clearCacheData() }) {
                    ZLabel {
                        Text("com.learn.meminstaller.setting.cache-clear")
                            .foregroundStyle(StyleManager.colorStyle.alert)
                    } icon: {
                        Image(systemName: "trash")
                            .foregroundStyle(StyleManager.colorStyle.alert)
                    }

                }
            }
        } footer: {
            Text("Cache memory size: " + totalCacheSize)
        }
    }
    
    @ViewBuilder
    func logoutSectionView() -> some View {
        Section {
            // Logout
            Button(action: {
                shouldShowLogoutSheet.toggle()
            }, label: {
                ZLabel {
                    Text("Sign out")
                        .font(.system(size: 15.0)) // replaced from Roboto font
                        .foregroundStyle(.red)
                } icon: {
                    Image(systemName: "power")
                        .foregroundStyle(.red)
                        .font(.title3)
                }
            })
            .sheet(isPresented: $shouldShowLogoutSheet, content: {
                presentLogoutView(showLogoutAlert: $shouldShowLogoutSheet)
                    .presentationCompactAdaptation(.none)
                    .padding(.all, 15)
                    .interactiveDismissDisabled()
            })
        } footer: {
            Label(
                title: {
                    Text("com.learn.meminstaller.setting.footnote")
                        .font(.caption2)
                },
                icon: {
                    Image(systemName: "c.circle")
                }
            )
            .padding(.vertical, 8)
        }
    }
    
    private func presentToast(message: String) {
        toastMessage = message
        isPresentToast = true
    }
    
    private func clearCacheData() {
        do {
            try ZFFileManager.shared.clearAllCache()
            self.totalCacheSize = try ZFFileManager.shared.getDirectorySize(at: ZFFileManager.shared.getAppCacheDirectory())
            presentToast(message: "Cache cleared")
        }catch {
            presentToast(message: error.localizedDescription)
        }
    }
    
    private func removeLogFileFromCache() {
        if FileManager.default.fileExists(atPath: logFileURL.path()) {
            do {
                try FileManager.default.removeItem(atPath: logFileURL.path())
                presentToast(message: "Deleted \(logFileURL.lastPathComponent)")
            }catch {
                presentToast(message: "Failed to remove \(logFileURL.lastPathComponent)")
            }
        }
    }
    
    @ViewBuilder
    private func handleExportLogFile() -> some View {
        ActivityViewRepresentable(activityItems: [logFileURL]) { completion, error in
            if let error = error {
                presentToast(message: error.localizedDescription)
            }else if completion {
                presentToast(message: "File saved successfully")
            }else {
                presentToast(message: "Something went wrong")
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: Logout View
struct presentLogoutView: View {
    @Binding var showLogoutAlert: Bool
    
    // Toast Properties
    @State private var toastMessage: String = ""
    @State private var isPresentToast: Bool = false
    
    var body: some View {
        VStack(spacing: 20, content: {
            Text("Do you wise to sign out?")
                .padding(.all, 15)
                .bold()
            
            HStack(spacing: 30, content: {
                Button(action: {
                    showLogoutAlert.toggle()
                }, label: {
                    Text("Cancel")
                })
                .defaultOutlineButtonStyle(foregroundColor: Color.primary)
                
                Button(role: .destructive) {
//                    AppViewModel.shared.logout()
                    showLogoutAlert.toggle()
                } label: {
                    Text("Sign out")
                }
                .defaultOutlineButtonStyle(outlineColor: .red, foregroundColor: .red)
            })
        })
        .presentationDetents([.height(140)])
        .showToast(message: toastMessage, isShowing: $isPresentToast)
    }
}

#Preview {
    SettingView(userprofile: ZUserProfile(name: "Hariharan R S", displayName: "Harith", email: "hariharan.rs@zohocorp.com", profileImageData: Data()))
}

