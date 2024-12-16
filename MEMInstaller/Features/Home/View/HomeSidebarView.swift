//
//  HomeSidebarView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 02/12/24.
//

import SwiftUI

struct HomeSidebarView: View {
    let packageHandler: PackageExtractionHandler = PackageExtractionHandler()
    
    @State private var shouldNavigate: Bool = false
    @State private var tempPackageModel: PackageExtractionModel? = nil
    
    @EnvironmentObject private var appCoordinator: AppCoordinatorImpl
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        LoaderView(loadingState: $viewModel.sideBarLoadingState) {
            ProgressView()
                .progressViewStyle(.horizontalCircular)
        } loadedContent: {
            Group {
                if viewModel.bucketObjectModels.isEmpty {
                    Device.isIphone ? AnyView(EmptyBucketView(viewModel: viewModel)) : AnyView(textViewForIdleState("No apps available").navigationTitle("Apps"))
                } else {
                    AnyView(listAvailableApplications())
                        .navigationTitle("Apps")
                }
            }
        }
        .navigationBarTitleDisplayMode(.large)
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
            Button {
                appCoordinator.openFileImporter { result in
                    switch result {
                    case .success(let filePath):
                        packageHandler.initiateAppExtraction(from: filePath)
                        let packageExtractionModel = packageHandler.getPackageExtractionModel()
                        viewModel.selectedPackageModel = packageExtractionModel
                    case .failure(let failure):
                        ZLogs.shared.error(failure.localizedDescription)
                        viewModel.showToast(failure.localizedDescription)
                    }
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(StyleManager.colorStyle.invertBackground)
            }
        }
    }
}
