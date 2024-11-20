//
//  SideMenuView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 18/11/24.
//

import SwiftUI

struct SideMenuView: View {
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    @ObservedObject var viewModel: HomeViewModel
    @Binding var isPresentSideMenu: Bool
    
    @State var isPresentShareLog: Bool = false
    
    var logFileURL: URL {
        return ZLogs.shared.exportLogFile()
    }
    
    // Cache size
    @State private var totalCacheSize: String = "0"
    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack {
                VStack(alignment: .leading) {
                    userProfileImageView(geometry)
                    
                    Button(action: {
                        FileManager.default.fileExists(atPath: logFileURL.path()) ?
                        isPresentShareLog.toggle() : viewModel.showToast("Error: No file found")
                    }, label: {
                        shareLogsButtonView()
                    })
                    
                    Button(action: { clearCacheData() }) {
                        clearCacheButtonView()
                    }
                    
                    Button(action: {
                        appCoordinator.presentSheet(.logout)
                    }, label: {
                        logOutButtonView()
                    })
                    
                    Spacer()

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
                    .padding(.bottom, 50)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .frame(width: geometry.size.width * 0.7)
                .background(Color(uiColor: .systemBackground))
            }
            .onAppear(perform: {
                self.totalCacheSize = try! ZFFileManager.shared.getDirectorySize(at: ZFFileManager.shared.getAppCacheDirectory())
            })
            .sheet(isPresented: $isPresentShareLog, content: {
                handleExportLogFile()
            })
        })
        .background(.clear)
    }
    
    @ViewBuilder
    func userProfileImageView(_ geometry: GeometryProxy) -> some View {
        VStack {
            if let userprofile = viewModel.userprofile {
                let uiImage = UIImage(data: userprofile.profileImageData)
                Image(uiImage: uiImage!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                
                Text(userprofile.displayName)
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .bold))
                
                Text(userprofile.email)
                    .lineLimit(1)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: geometry.size.height * 0.2)
        .padding(.top, 60)
        .background(
            Rectangle()
                .fill(StyleManager.colorStyle.tintColor)
        )
    }
    
    @ViewBuilder
    func shareLogsButtonView() -> some View {
        SideMenuButtonView {
            Text("com.learn.meminstaller.setting.share-log")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(StyleManager.colorStyle.invertBackground)
        } imageContent: {
            Image(systemName: "arrow.right")
                .foregroundStyle(StyleManager.colorStyle.invertBackground)
                .font(.system(size: 16, weight: .regular))
        }

    }
    
    @ViewBuilder
    func clearCacheButtonView() -> some View {
        VStack(alignment: .leading) {
            SideMenuButtonView {
                Text("com.learn.meminstaller.setting.cache-clear")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.red)
            } imageContent: {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.red)
            }
            
            Text("Cache memory size: " + totalCacheSize)
                .font(.footnote)
                .foregroundStyle(StyleManager.colorStyle.systemGray)
                .padding(.leading, 5)
        }
    }
    
    @ViewBuilder
    func logOutButtonView() -> some View {
        SideMenuButtonView {
            Text("com.learn.meminstaller.setting.signout")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color.red)
        } imageContent: {
            Image(systemName: "power")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color.red)
        }
    }
    
    @ViewBuilder
    private func handleExportLogFile() -> some View {
        ActivityViewRepresentable(activityItems: [logFileURL]) { completion, error in
            if let error = error {
                viewModel.showToast(error.localizedDescription)
            }else if completion {
                viewModel.showToast("File saved successfully")
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func clearCacheData() {
        do {
            try ZFFileManager.shared.clearAllCache()
            self.totalCacheSize = try ZFFileManager.shared.getDirectorySize(at: ZFFileManager.shared.getAppCacheDirectory())
            ZLogs.shared.info("com.learn.meminstaller.setting.cache-clear")
            viewModel.showToast("com.learn.meminstaller.setting.cache-clear".ZSLocal)
        }catch {
            viewModel.showToast(error.localizedDescription)
        }
    }
}

struct SideMenuButtonView<T: View, I: View>: View where T: View, I: View {
    @ViewBuilder var textContent: T
    @ViewBuilder var imageContent: I
    
    var body: some View {
        HStack {
            textContent
            Spacer()
            imageContent
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(StyleManager.colorStyle.secondaryBackground)
                .shadow(radius: 0.7)
        )
        .padding(.horizontal, 5)
    }
}

// MARK: Logout View
struct presentLogoutView: View {
    @EnvironmentObject private var appCoordinator: AppCoordinatorImpl
    
    var body: some View {
        VStack(spacing: 20, content: {
            Text("Do you wise to sign out?")
                .padding(.all, 15)
                .bold()
            
            HStack(spacing: 30, content: {
                Button(action: {
                    appCoordinator.sheet = nil
                }, label: {
                    Text("Cancel")
                })
                .defaultOutlineButtonStyle(foregroundColor: Color.primary)
                
                Button(role: .destructive) {
                    AppViewModel.shared.logout()
                    appCoordinator.sheet = nil
                } label: {
                    Text("Sign out")
                }
                .defaultOutlineButtonStyle(outlineColor: .red, foregroundColor: .red)
            })
        })
        .presentationDetents([.height(140)])
    }
}

#Preview {
    HomeView()
}
