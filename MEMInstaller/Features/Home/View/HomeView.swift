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
    
    var body: some View {
        NavigationStack {
            NavigationSplitView(preferredCompactColumn: .constant(.sidebar)) {
                sideBarContentView()
            } detail: {
                detailContentView()
            }
            .showToast(message: viewModel.toastMessage, isShowing: $viewModel.isPresentToast)
        }
    }
    
    @ViewBuilder
    private func sideBarContentView() -> some View {
        LoaderView(loadingState: $viewModel.sideBarLoadingState) {
            if viewModel.allObjects.isEmpty {
                EmptyBucketView(viewModel: viewModel)
            }else {
                ListAvailableApplications(viewModel: viewModel)
            }
        }
        .navigationTitle("Apps")
        .task {
            if viewModel.allObjects.isEmpty {
                await viewModel.fetchFoldersFromBucket()
            }
        }
    }
    
    @ViewBuilder
    private func detailContentView() -> some View {
        if viewModel.shouldShowDetailView {
            AttachedFileDetailView(viewModel: viewModel, attachmentMode: .install)
        }else {
            Text("Select a application to view details")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}


#Preview {
    HomeView(viewModel: .preview)
        .environmentObject(AppCoordinatorImpl())
}
