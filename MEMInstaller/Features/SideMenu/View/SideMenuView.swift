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
    
    var logFileURL: URL {
        return ZLogs.shared.exportLogFile()
    }
    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack {
                VStack(alignment: .leading) {
                    UserProfileImageView(viewModel: viewModel, geometry: geometry)
                    
                    // About
//                    SideMenuButton(title: "com.learn.meminstaller.setting.about",
//                                   systemImage: "i.circle",
//                                   action: { appCoordinator.push(.about) },
//                                   foregroundColor: StyleManager.colorStyle.invertBackground)
                    // Share Logs
                    SideMenuButton(title: "com.learn.meminstaller.setting.share-log",
                                   systemImage: "arrow.right",
                                   action: shareLogHandler,
                                   foregroundColor: StyleManager.colorStyle.invertBackground)
                    // Sign out
                    SideMenuButton(title: "com.learn.meminstaller.setting.signout",
                                   systemImage: "power",
                                   action: { appCoordinator.presentSheet(.logout) },
                                   foregroundColor: .red)
                    Spacer()
                    FooterView()
                        .padding(.bottom, 50)
                }
                .frame(maxWidth: geometry.size.width * 0.7, alignment: .topLeading)
                .background(Color(uiColor: .systemBackground))
            }
        })
        .background(.clear)
    }

    private func shareLogHandler() {
        if FileManager.default.fileExists(atPath: logFileURL.path()) {
            appCoordinator.presentActivityRepresentable(logFileURL: logFileURL) { status, error in
                if let error = error {
                    viewModel.showToast("Export failed: \(error.localizedDescription)")
                }else if status {
                    viewModel.showToast("Export successful!")
                }
            }
        }
    }
}

struct SideMenuButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    let foregroundColor: Color
    
    var body: some View {
        Button(action: action, label: {
            HStack {
                Text(title.ZSLocal)
                    .lineLimit(1)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(foregroundColor)
                Spacer()
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(foregroundColor)
            }
            .padding()
        })
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(color: StyleManager.colorStyle.contentBackground, radius: 1.8)
        )
        .padding(.horizontal, 6)
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
    }
}

#Preview {
    HomeView()
}
