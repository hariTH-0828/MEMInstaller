//
//  HomeView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 05/11/24.
//

import SwiftUI
import MEMToast
import Alamofire

enum HomeNavigation: Hashable {
    case settings
}

struct HomeView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    @StateObject var viewModel: HomeViewModel
    @StateObject private var coordinator: AppCoordinatorImpl = AppCoordinatorImpl()
    
    @State private var shouldPresentSettings = false
    
    // Use a default value for `viewModel`
    init(viewModel: HomeViewModel = HomeViewModel(repository: StratusRepositoryImpl(),
                                                  userDataManager: UserDataManager()))
    {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: BODY
    var body: some View {
        NavigationSplitView {
            NavigationStack(path: $coordinator.navigationPath) {
                HomeSidebarView()
                    .navigationDestination(for: Screen.self) {
                        coordinator.build(forScreen: $0)
                    }
                    .sheet(item: $coordinator.sheet, onDismiss: coordinator.onDismiss, content: { sheet in
                        coordinator.build(forSheet: sheet)
                    })
                    .fileImporter(isPresented: $coordinator.shouldShowFileImporter, allowedContentTypes: [.ipa]) { result in
                        coordinator.fileImportCompletion?(result)
                    }
            }
        } detail: {
            if let bucketObjectModel = viewModel.selectedBucketObject {
                AttachedFileDetailView(bucketObjectModel: bucketObjectModel, attachmentMode: .install)
            }
        }
        .showToast(message: viewModel.toastMessage, isShowing: $viewModel.isPresentToast)
        .environmentObject(viewModel)
        .environmentObject(coordinator)
        .onAppear(perform: {
            appViewModel.coordinator = coordinator
        })

    }
    
    private func navigateToSettings() {
        shouldPresentSettings = true
    }
}


#Preview {
    HomeView(viewModel: .preview)
}
