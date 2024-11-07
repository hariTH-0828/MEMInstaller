//
//  SettingsView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI

struct SettingView: View {
    @State private var shouldShowLogoutSheet: Bool = false
    let userprofile: ZCUserProfile
    
    init(userprofile: ZCUserProfile) {
        self.userprofile = userprofile
    }
    
    @State var toastMessage: String? = nil
    @State var isPresentToast: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                userProfileView()
                logoutSectionView()
            }
            .navigationTitle("com.learn.meminstaller.setting.title")
            .navigationBarTitleDisplayMode(.inline)
            .showToast(message: toastMessage, isShowing: $isPresentToast)
        }
    }
    
    @ViewBuilder
    private func userProfileView() -> some View {
        HStack(alignment: .top) {
            Image(uiImage: imageWith(name: userprofile.firstName)!)
                .resizable()
                .frame(width: 45, height: 45)
                .clipped()
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(userprofile.firstName) \(userprofile.lastName ?? "")")
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
                    AppViewModel.shared.logout()
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
    SettingView(userprofile: ZCUserProfile(id: 3948120384042, zuId: 2349820348520, firstName: "Hariharan", lastName: "R S", email: "hariharan.rs@zohocorp.com", status: "Available", role: ZCUserRole(id: 342340528301, name: "App administrator")))
}

