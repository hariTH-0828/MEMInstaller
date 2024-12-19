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
    @ObservedObject var appCoordinator: AppCoordinatorImpl
    
    @State var navigationSplitVisibility: NavigationSplitViewVisibility = .doubleColumn
    
    @StateObject var sideBarViewModel: HomeViewModel = HomeViewModel()
    @StateObject var detailViewModel: AttachedFileDetailViewModel = AttachedFileDetailViewModel()
    
    // MARK: BODY
    var body: some View {
        NavigationSplitView(columnVisibility: $navigationSplitVisibility) {
            NavigationStack(path: $appCoordinator.navigationPath) {
                HomeSidebarView(viewModel: sideBarViewModel)
                    .navigationDestination(for: Screen.self) {
                        appCoordinator.build(forScreen: $0)
                    }
                    .sheet(item: $appCoordinator.sheet, onDismiss: appCoordinator.onDismiss, content: { sheet in
                        appCoordinator.build(forSheet: sheet)
                    })
                    .fileImporter(isPresented: $appCoordinator.shouldShowFileImporter, allowedContentTypes: [.ipa]) { result in
                        appCoordinator.fileImportCompletion?(result)
                    }
            }
        } detail: {
            if let bucketObjectModel = sideBarViewModel.selectedBucketObject {
                AttachedFileDetailView(viewModel: detailViewModel,
                                       bucketObjectModel: bucketObjectModel,
                                       attachmentMode: .install)
            }else if sideBarViewModel.bucketObjectModels.isEmpty && sideBarViewModel.sideBarLoadingState == .loaded {
                EmptyBucketView(viewModel: sideBarViewModel)
            }else {
                IdleStateView()
            }
        }
        .showToast(message: sideBarViewModel.toastMessage, isShowing: $sideBarViewModel.isPresentToast)
        .toastViewStyle(.defaultToastStyle)
        .environmentObject(appCoordinator)
        .onChange(of: sideBarViewModel.selectedBucketObject) { _, _ in
            detailViewModel.detailLoadingState = .loading
        }
        .onChange(of: sideBarViewModel.selectedPackageModel) { _, newValue in
            guard let newValue = newValue else { return }
            appCoordinator.presentSheet(.AttachedFileDetail(detailViewModel, newValue, .upload)) {
                sideBarViewModel.selectedPackageModel = nil
            }
        }

    }
}
