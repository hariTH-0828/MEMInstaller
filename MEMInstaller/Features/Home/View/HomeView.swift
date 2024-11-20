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
        _viewModel = StateObject(wrappedValue: HomeViewModel(repository: StratusRepositoryImpl(),
                                                             userDataManager: UserDataManager(),
                                                             packageHandler: PackageExtractionHandler()))
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                LoaderView(loadingState: $viewModel.loadingState) {
                    if !viewModel.allObjects.isEmpty {
                        ListAvailableApplications(viewModel: viewModel)
                    }else {
                        EmptyBucketView(viewModel: viewModel)
                    }
                }
                .navigationTitle(isSideMenuVisible ? "" : "com.learn.meminstaller.home.title")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { hambergerButton() }
                .animation(.smooth, value: isSideMenuVisible)
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
}

struct ListAvailableApplications: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject private var appCoordinator: AppCoordinatorImpl
    
    var body: some View {
        GeometryReader(content: { geometry in
            // Creates a list of folders, sorted alphabetically, and generates buttons for each folder
            List(sortedFolderNames(), id: \.self) { folderName in
                
                if let contents = viewModel.allObjects[folderName] {
                    // Extract relevant file URLs (icon, Info.plist, object plist) for each folder
                    let fileURLs = extractFileURLs(from: contents, folderName: folderName)
                    
                    Button(action: {
                        handleAppSelection(with: fileURLs)
                    }, label: {
                        appLabel(folderName: folderName, iconURL: fileURLs.iconURL)
                    })
                }
            }
            .refreshable { await viewModel.fetchFoldersFromBucket() }
            .toolbar { addPackageButtonView() }
        })
    }
    
    @ViewBuilder
    private func appLabel(folderName: String, iconURL: String?) -> some View {
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
    
    private func addPackageButtonView() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                appCoordinator.openFileImporter { result in
                    switch result {
                    case .success(let filePath):
                        viewModel.packageHandler.initiateAppExtraction(from: filePath)
                        appCoordinator.presentSheet(.attachedDetail(viewModel: viewModel, mode: .upload)) {
                            try? ZFFileManager.shared.clearAllCache()
                        }
                    case .failure(let failure):
                        ZLogs.shared.error(failure.localizedDescription)
                        viewModel.showToast(failure.localizedDescription)
                    }
                }
            }, label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(StyleManager.colorStyle.invertBackground)
            })
        }
    }
    
    // MARK: - HELPER METHODS
    /// Returns a sorted list of folder names from the `allObject` dictionary keys.
    /// Sorting ensures a consistent display order.
    private func sortedFolderNames() -> [String] {
        return Array(viewModel.allObjects.keys).sorted()
    }
    
    /// Extracts the URLs for the app icon, Info.plist, and object plist file from a folder's content list.
    /// - Parameters:
    ///   - contents: The list of contents in the folder.
    ///   - folderName: The name of the folder being processed.
    /// - Returns: A tuple containing the app icon URL, Info.plist URL, and object plist URL (all optional).
    private func extractFileURLs(from contents: [ContentModel], folderName: String) -> (iconURL: String?, infoPlistURL: String?, objectURL: String?) {
        let iconURL = contents.first(where: { $0.actualContentType == .png && $0.key.contains("AppIcon60x60@") })?.url
        let infoPlistURL = contents.first(where: { $0.actualContentType == .document && $0.key.contains("Info.plist") })?.url
        let objectURL = contents.first(where: { $0.actualContentType == .document && $0.key.contains("\(folderName).plist") })?.url
        return (iconURL, infoPlistURL, objectURL)
    }

    /// Handles the action when a folder is selected, such as downloading necessary files and updating the UI state.
    /// - Parameter fileURLs: A tuple containing the URLs for the app icon, Info.plist, and object plist.
    private func handleAppSelection(with fileURLs: (iconURL: String?, infoPlistURL: String?, objectURL: String?)) {
        guard let iconURL = fileURLs.iconURL, let infoPlistURL = fileURLs.infoPlistURL else { return }
        viewModel.downloadInfoFile(url: infoPlistURL)
        viewModel.downloadAppIconFile(url: iconURL)
        viewModel.packageHandler.objectURL = fileURLs.objectURL
        appCoordinator.presentSheet(.attachedDetail(viewModel: viewModel, mode: .install))
    }
}

struct HomeViewPreviewProvider: PreviewProvider {
    
    static let bucket = BucketModel(bucketName: "packages", projectDetails: ProjectDetail(projectName: "ZInstaller", projectId: 21317000000012001), createdBy: CreatedBy(firstName: "Hariharan", lastName: "R S", emailId: "hariharan.rs@zohocorp.com", userType: "Admin"), createdTime: "Nov 04, 2024 04:10 PM", bucketURL: "https://packages-development.zohostratus.com")
    
    static var previews: some View {
        HomeView()
    }
}
