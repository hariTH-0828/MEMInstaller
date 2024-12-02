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
            HomeSidebarView(viewModel: viewModel)
        } detail: {
            HomeDetailView(viewModel: viewModel)
        }
        .navigationSplitViewStyle(.balanced)
        .showToast(message: viewModel.toastMessage, isShowing: $viewModel.isPresentToast)
    }
}


#Preview {
    HomeView(viewModel: .preview)
        .environmentObject(AppCoordinatorImpl())
}
