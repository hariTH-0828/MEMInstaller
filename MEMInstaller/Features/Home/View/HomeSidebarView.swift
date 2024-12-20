//
//  HomeSidebarView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 02/12/24.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import MEMToast

struct HomeSidebarView: View {
    let packageHandler: PackageExtractionHandler = PackageExtractionHandler()
    
    @EnvironmentObject private var appCoordinator: AppCoordinatorImpl
    @ObservedObject var viewModel: HomeViewModel
    @AppStorage(UserDefaultsKey.lastFilePickedURL)
    private var lastFilePath: URL = .downloadsDirectory
    
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
        .navigationSplitViewStyle(.balanced)
        .showToast(message: viewModel.toastMessage, isShowing: $viewModel.isPresentDeletionToast)
        .toastViewStyle(DeletionToastStyle())
        .removeSideBarToggle()
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
                    Button("Delete", systemImage: "trash", role: .cancel) {
                        viewModel.deleteContentFromBucket(bucketObject.prefix)
                    }
                    .tint(Color.red)
                })
        }
        .listStyle(SidebarListStyle())
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
                appCoordinator.presentSheet(.fileImporter(lastFilePath, { filePath in
                    guard let filePath else { return }
                    self.lastFilePath = filePath.deletingLastPathComponent()
                    packageHandler.initiateAppExtraction(from: filePath)
                    let packageExtractionModel = packageHandler.getPackageExtractionModel()
                    viewModel.selectedPackageModel = packageExtractionModel
                }))
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(StyleManager.colorStyle.invertBackground)
            }
        }
    }
}
