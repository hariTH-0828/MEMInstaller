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
                await viewModel.fetchFoldersFromBucket()
            }
        }
    }
    
    @ViewBuilder
    private func listAvailableApplications() -> some View {
        List(viewModel.bucketObjectModels, id: \.self, selection: $selectedBucketObject) { bucketObject in
            // fileURLs
            let fileURLs = viewModel.extractFileURLs(from: bucketObject.contents, folderName: bucketObject.folderName)

            Button {
                isPresentDetailView.toggle()
                handleAppSelection(with: fileURLs)
            } label: {
                HomeSideBarAppLabel(bucketObject: bucketObject, iconURL: fileURLs.iconURL)
            }
        }
        .refreshable { await viewModel.fetchFoldersFromBucket() }
        .toolbar { addPackageButtonView() }
        .navigationDestination(isPresented: $isPresentDetailView) {
            AttachedFileDetailView(viewModel: viewModel, attachmentMode: .install)
        }
    }
    
    @ViewBuilder
    private func loadingOverlay() -> some View {
       if case .loading = viewModel.sideBarLoadingState {
           OverlayLoaderView()
       }
    }
    
    private func addPackageButtonView() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                appCoordinator.openFileImporter { result in
                    switch result {
                    case .success(let filePath):
                        viewModel.packageHandler.initiateAppExtraction(from: filePath)
                        viewModel.detailViewLoadingState = .idle(.detail(.upload))
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
    private func handleAppSelection(with fileURLs: (iconURL: String?, infoPlistURL: String?, provisionURL: String?, objectURL: String?)) {
        guard let iconURL = fileURLs.iconURL, let infoPlistURL = fileURLs.infoPlistURL, let provisionURL = fileURLs.provisionURL  else { return }

        viewModel.updateLoadingState(for: .detail, to: .loading)
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        viewModel.downloadInfoFile(url: infoPlistURL) {
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        viewModel.downloadProvisionFile(url: provisionURL) {
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        viewModel.downloadAppIconFile(url: iconURL) {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            viewModel.packageHandler.objectURL = fileURLs.objectURL
            viewModel.detailViewLoadingState = .idle(.detail(.install))
        }
    }
}

#Preview {
    HomeSidebarView(viewModel: .preview)
}
