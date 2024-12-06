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
    @StateObject private var coordinator: AppCoordinatorImpl = AppCoordinatorImpl()
    
    @ObservedObject var sideBarViewModel: HomeViewModel
    @ObservedObject var detailViewModel: AttachedFileDetailViewModel
    
    // Use a default value for `viewModel`
    init(sideBarViewModel: HomeViewModel, detailViewModel: AttachedFileDetailViewModel) {
        self.sideBarViewModel = sideBarViewModel
        self.detailViewModel = detailViewModel
    }
    
    // MARK: BODY
    var body: some View {
        NavigationSplitView {
            NavigationStack(path: $coordinator.navigationPath) {
                HomeSidebarView(viewModel: sideBarViewModel)
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
            if let bucketObjectModel = sideBarViewModel.selectedBucketObject {
                AttachedFileDetailView(viewModel: detailViewModel,
                                       bucketObjectModel: bucketObjectModel,
                                       attachmentMode: .install)
            }else {
                Text("Select an app to see details")
                    .foregroundColor(.gray)
            }
        }
        .showToast(message: sideBarViewModel.toastMessage, isShowing: $sideBarViewModel.isPresentToast)
        .environmentObject(coordinator)
        .onAppear(perform: {
            appViewModel.coordinator = coordinator
        })
        .onChange(of: sideBarViewModel.selectedBucketObject) { _, _ in
            detailViewModel.detailViewState = .loading
        }

    }
}
