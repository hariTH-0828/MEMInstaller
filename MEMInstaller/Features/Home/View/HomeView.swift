//
//  HomeView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 05/11/24.
//

import SwiftUI
import MEMToast

struct HomeView: View {
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    @StateObject var viewModel: HomeViewModel
    
    @State var isSideMenuVisible: Bool = false
    
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel(StratusRepositoryImpl()))
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                LoaderView(isLoading: $viewModel.isLoading, content: {
                    if !viewModel.allObject.isEmpty {
                        ListAvailableApplications(viewModel: viewModel)
                    }else {
                        EmptyBucketView(viewModel: viewModel)
                    }
                })
                .navigationTitle(isSideMenuVisible ? "" : "com.learn.meminstaller.home.title")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    hambergerButton()
                    uploadButtonView()
                }
                .task {
                    await viewModel.fetchFoldersFromBucket()
                }
            }
            
            SideMenu(isSideMenuVisible: $isSideMenuVisible) {
                SideMenuView(viewModel: viewModel, isPresentSideMenu: $isSideMenuVisible)
            }
        }
        .showToast(message: viewModel.toastMessage, isShowing: $viewModel.isPresentToast)
    }
    
    private func hambergerButton() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: {
                isSideMenuVisible.toggle()
            }, label: {
                Image("ico_menu")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundStyle(StyleManager.colorStyle.invertBackground)
                    .frame(width: 25, height: 25)
            })
        }
    }
    
    private func uploadButtonView() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                appCoordinator.openFileImporter { result in
                    switch result {
                    case .success(let filePath):
                        viewModel.packageHandler.extractIpaFileContents(from: filePath)
                        viewModel.packageHandler.extractAppBundle()
                        appCoordinator.presentSheet(.attachedDetail(viewModel: viewModel, mode: .upload))
                    case .failure(let failure):
                        ZLogs.shared.error(failure.localizedDescription)
                        viewModel.presentToast(message: failure.localizedDescription)
                    }
                }
            }, label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(StyleManager.colorStyle.invertBackground)
            })
        }
    }
}

struct ListAvailableApplications: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject private var appCoordinator: AppCoordinatorImpl
    
    var body: some View {
        GeometryReader(content: { geometry in
            List(Array(viewModel.allObject.keys).sorted(), id: \.self) { folderName in
                // Get content object and load image
                if let contents = viewModel.allObject[folderName] {
                    
                    let iconURL = contents.filter({ $0.actualContentType == .png && $0.key.contains("AppIcon60x60@")}).first?.url
                    let infoPlistURL = contents.filter({ $0.actualContentType == .document && $0.key.contains("Info.plist")}).first?.url
                    let objectURL = contents.filter({$0.actualContentType == .document && $0.key.contains(folderName + ".plist")}).first?.url
                    
                    Button(action: {
                        guard let iconURL, let infoPlistURL else { return }
                        viewModel.downloadInfoFile(url: infoPlistURL)
                        viewModel.downloadAppIconFile(url: iconURL)
                        viewModel.packageHandler.objectURL = objectURL
                        appCoordinator.presentSheet(.attachedDetail(viewModel: viewModel, mode: .install))
                    }, label: {
                        Label(
                            title: {
                                Text(folderName)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(StyleManager.colorStyle.invertBackground)
                            },
                            icon: {
                                appIconView(iconURL, folderName: folderName)
                            }
                        )
                    })
                }
            }
            .overlay {
                if viewModel.isDownloadStateEnable {
                    ProgressView()
                        .progressViewStyle(.horizontalCircular)
                }
            }
            .refreshable {
                await viewModel.fetchFoldersFromBucket()
            }
        })
    }
    
    @ViewBuilder
    private func appIconView(_ iconURL: String?, folderName: String) -> some View {
        if let iconURL {
            AsyncImage(url: URL(string: iconURL)!) { image in
                image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
                    .progressViewStyle(.circular)
                    .foregroundStyle(StyleManager.colorStyle.systemGray)
            }
        }else {
            Image(uiImage: imageWith(name: folderName)!)
        }
    }
}

struct HomeViewPreviewProvider: PreviewProvider {
    
    static let bucket = BucketModel(bucketName: "packages", projectDetails: ProjectDetail(projectName: "ZInstaller", projectId: 21317000000012001), createdBy: CreatedBy(firstName: "Hariharan", lastName: "R S", emailId: "hariharan.rs@zohocorp.com", userType: "Admin"), createdTime: "Nov 04, 2024 04:10 PM", bucketURL: "https://packages-development.zohostratus.com")
    
    static var previews: some View {
        HomeView()
    }
}
