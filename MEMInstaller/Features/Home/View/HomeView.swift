//
//  HomeView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 05/11/24.
//

import SwiftUI
import MEMToast
import Alamofire

struct HomeView: View {
    @EnvironmentObject private var appCoordinator: AppCoordinatorImpl
    @StateObject var viewModel: HomeViewModel
    
    // Use a default value for `viewModel`
    init(viewModel: HomeViewModel = HomeViewModel(repository: StratusRepositoryImpl(),
                                                  userDataManager: UserDataManager(),
                                                  packageHandler: PackageExtractionHandler()))
    {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: BODY
    var body: some View {
        NavigationSplitView {
            sideBarContentView()
        } detail: {
            detailContentView()
        }
        .navigationSplitViewStyle(.balanced)
        .showToast(message: viewModel.toastMessage, isShowing: $viewModel.isPresentToast)
        .environmentObject(viewModel)
    }
    
    // MARK: - SIDEBAR
    @ViewBuilder
    private func sideBarContentView() -> some View {
        LoaderView(loadingState: $viewModel.sideBarLoadingState) {
            // Handle when state loading
            ProgressView()
                .progressViewStyle(.horizontalCircular)
        } loadedContent: {
            // Handle when state idle
            if viewModel.bucketObjectModels.isEmpty {
                textViewForIdleState("No apps available")
            }else {
                ListAvailableApplications()
            }
        }
        .navigationTitle("Apps")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                UserProfileButtonView()
            }
        }
        .task {
            if viewModel.sideBarLoadingState == .loading {
                await viewModel.fetchFoldersFromBucket()
            }
        }
    }
    
    // MARK: - DETAIL
    @ViewBuilder
    private func detailContentView() -> some View {
        LoaderView(loadingState: $viewModel.detailViewLoadingState) {
            // Handle when state in loading
            ProgressView()
                .progressViewStyle(.horizontalCircular)
        } loadedContent: {
            // Handle when state in idle
            if viewModel.shouldShowDetailContentAvailable {
                textViewForIdleState("select a app to view details")
            }else if let attachmentMode = viewModel.shouldShowDetailView {
                AttachedFileDetailView(attachmentMode: attachmentMode)
            }else if viewModel.bucketObjectModels.isEmpty {
                EmptyBucketView(viewModel: viewModel)
            }
        }
    }
    
    @ViewBuilder
    private func textViewForIdleState(_ message: String) -> Text {
        Text(message)
            .font(.footnote)
            .foregroundStyle(StyleManager.colorStyle.systemGray)
    }
}


#Preview {
    HomeView(viewModel: .preview)
        .environmentObject(AppCoordinatorImpl())
}
