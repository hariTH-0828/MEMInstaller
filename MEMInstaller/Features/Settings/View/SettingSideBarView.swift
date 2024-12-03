//
//  SettingSideBarView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 28/11/24.
//

import SwiftUI

struct SettingSideBarView: View {
    @EnvironmentObject private var coordinator: AppCoordinatorImpl
    
    var userProfile: ZUserProfile? {
        return UserDataManager().retrieveLoggedUserFromKeychain()
    }
    
    var logFileURL: URL {
        return ZLogs.shared.exportLogFile()
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                UserProfileImageView(userProfile: .preview)
                
                Section {
                    List {
                        Button(action: {
                            coordinator.presentSheet(.activityRepresentable(logFileURL))
                        }, label: {
                            Label(
                                title: {
                                    Text("com.learn.meminstaller.setting.share-log")
                                        .lineLimit(1)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundStyle(StyleManager.colorStyle.invertBackground)
                                },
                                icon: {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundStyle(Color.orange)
                                }
                            )
                        })
                        .listRowSeparator(.hidden)
                        
                        Button(action: {
                            Device.isIpad ? coordinator.pop(.logout) : coordinator.presentSheet(.logout)
                        }, label: {
                            Label(
                                title: {
                                    Text("com.learn.meminstaller.setting.signout")
                                        .lineLimit(1)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundStyle(.red)
                                },
                                icon: {
                                    Image(systemName: "power")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundStyle(Color.red)
                                }
                            )
                        })
                        .listRowSeparator(.hidden)
                        .popover(item: $coordinator.popView, content: { pop in
                            coordinator.build(forPop: pop)
                        })
                    }
                    .listStyle(.plain)
                    .scrollBounceBehavior(.basedOnSize)
                }
                .padding(.vertical)
            }
            .frame(maxHeight: UIScreen.screenHeight, alignment: .top)
            .navigationTitle("Settings")
        }
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
}

#Preview {
    SettingsView()
        .environmentObject(AppCoordinatorImpl())
}
