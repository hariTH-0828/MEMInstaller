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
        return UserDataManager().retriveLoggedUserFromKeychain()
    }
    
    var logFileURL: URL {
        return ZLogs.shared.exportLogFile()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    UserProfileImageView(userProfile: userProfile ?? .preview)
                } header: {
                    Text("User profile")
                }
                
                Section {
                    Button(action: {
                        
                    }, label: {
                        Label(
                            title: {
                                Text("com.learn.meminstaller.setting.about")
                                    .lineLimit(1)
                                    .font(.system(size: 16, weight: .regular))
                            },
                            icon: {
                                Image(systemName: "i.circle")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(Color.teal)
                            }
                        )
                    })
                    
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
                    
                    Button(action: {
                        coordinator.presentSheet(.logout)
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
                } header: {
                    Text("General")
                } footer: {
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
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingSideBarView()
}
