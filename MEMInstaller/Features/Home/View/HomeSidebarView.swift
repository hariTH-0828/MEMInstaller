//
//  HomeSidebarView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 02/12/24.
//

import SwiftUI

struct HomeSidebarView: View {
    @EnvironmentObject private var appCoordinator: AppCoordinatorImpl
    @ObservedObject var viewModel: HomeViewModel
    
    @State var selectedBucketObject: BucketObjectModel? = nil
    @State var isPresentDetailView: Bool = false
    
    var body: some View {
        LoaderView(loadingState: $viewModel.sideBarLoadingState) {
            // Handle when state loading
            ProgressView()
                .progressViewStyle(.horizontalCircular)
        } loadedContent: {
            // Handle when state idle
            if viewModel.bucketObjectModels.isEmpty {
                textViewForIdleState("No apps available")
            }else {
                listAvailableApplications()
            }
        }
        .navigationTitle("Apps")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { UserProfileButtonView() }
        }
        .task {
            if viewModel.sideBarLoadingState == .loading {
                viewModel.fetchFolders()
            }
        }
    }
    
    @ViewBuilder
    private func listAvailableApplications() -> some View {
        List(viewModel.bucketObjectModels, id: \.self, selection: $selectedBucketObject) { bucketObject in
            // fileURLs
            let packageURL = viewModel.extractFileURLs(from: bucketObject.contents, folderName: bucketObject.folderName)

            Button {
                handleAppSelection(with: packageURL)
            } label: {
                HomeSideBarAppLabel(bucketObject: bucketObject, iconURL: packageURL.appIconURL)
            }
        }
        .refreshable { viewModel.fetchFolders() }
        .toolbar { addPackageButtonView() }
    }
    
    @ViewBuilder
    private func loadingOverlay() -> some View {
       if case .loading = viewModel.sideBarLoadingState {
           HorizontalLoadingWrapper()
       }
    }
    
    private func addPackageButtonView() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                appCoordinator.openFileImporter { result in
                    switch result {
                    case .success(let filePath):
                        viewModel.packageHandler.initiateAppExtraction(from: filePath)
                        viewModel.updateLoadingState(for: .detail, to: .idle(.detail(.upload)))
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
    /// Handles the action when a folder is selected, such as downloading necessary files and updating the UI state.
    /// - Parameter fileURLs: A tuple containing the URLs for the app icon, Info.plist, and object plist.
    private func handleAppSelection(with packageURL: PackageURL) {
        guard let iconURL = packageURL.appIconURL, let infoPlistURL = packageURL.infoPropertyListURL, let provisionURL = packageURL.mobileProvisionURL  else { return }

        viewModel.updateLoadingState(for: .detail, to: .loading)
        
        Task {
            async let infoPlistData: Void = viewModel.downloadFile(url: infoPlistURL, type: .infoFile)
            async let provisionData: Void = viewModel.downloadFile(url: provisionURL, type: .provision)
            async let iconData: Void = viewModel.downloadFile(url: iconURL, type: .appIcon)
            
            _ = await (infoPlistData, provisionData, iconData)
            
            viewModel.updateLoadingState(for: .detail, to: .idle(.detail(.install)))
        }
    }
}

#Preview {
    HomeSidebarView(viewModel: .preview)
}
