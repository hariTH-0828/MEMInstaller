//
//  HomeSidebarView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 02/12/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct HomeSidebarView: View {
    let packageHandler: PackageExtractionHandler = PackageExtractionHandler()
    
    @EnvironmentObject private var appCoordinator: AppCoordinatorImpl
    @ObservedObject var viewModel: HomeViewModel
    
    @State private var dragOver: Bool = false
    
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
        .navigationSplitViewColumnWidth(250)
        .toolbar(removing: .sidebarToggle)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { UserProfileButtonView() }
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
                .swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        viewModel.deleteContentFromBucket(bucketObject.prefix)
                    }
                    .tint(Color.red)
                })
        }
        .refreshable { viewModel.fetchFolders() }
        .toolbar { addPackageButtonView() }
        .onDrop(of: [UTType.ipa], isTargeted: $dragOver, perform: { providers in
            guard let provider = providers.first else { return false }
            return viewModel.handleDrop(provider: provider)
        })
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
