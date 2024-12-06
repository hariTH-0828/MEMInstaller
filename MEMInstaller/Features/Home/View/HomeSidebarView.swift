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
    
    var body: some View {
        LoaderView(loadingState: $viewModel.sideBarLoadingState) {
            ProgressView()
                .progressViewStyle(.horizontalCircular)
        } loadedContent: {
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
        List(viewModel.bucketObjectModels, id: \.self, selection: $viewModel.selectedBucketObject) { bucketObject in
            
            HomeSideBarAppLabel(bucketObject: bucketObject, iconURL: bucketObject.getAppIcon())
                .tag(bucketObject)
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
                        PackageExtractionHandler.shared.initiateAppExtraction(from: filePath)
//                        viewModel.updateLoadingState(for: .detail, to: .idle(.detail(.upload)))
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
}

#Preview {
    HomeSidebarView(viewModel: .preview)
}
