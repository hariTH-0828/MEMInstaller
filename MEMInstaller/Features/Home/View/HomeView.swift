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
        NavigationSplitView {
            sideBarContentView()
        } detail: {
            detailContentView()
        }
        .navigationSplitViewStyle(.balanced)
        .showToast(message: viewModel.toastMessage, isShowing: $viewModel.isPresentToast)
    }
    
    @ViewBuilder
    private func sideBarContentView() -> some View {
        LoaderView(loadingState: $viewModel.sideBarLoadingState) {
            if viewModel.allObjects.isEmpty {
                Text("No apps available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }else {
                ListAvailableApplications(viewModel: viewModel)
            }
        }
        .navigationTitle("Apps")
        .toolbar { settingButtonView() }
        .task {
            if viewModel.sideBarLoadingState == .loading {
                await viewModel.fetchFoldersFromBucket()
            }
        }
    }
    
    @ViewBuilder
    private func detailContentView() -> some View {
        LoaderView(loadingState: $viewModel.detailViewLoadingState) {
            if viewModel.sideBarLoadingState == .loading {
                Text("select a app to view details")
                    .font(.footnote)
                    .foregroundStyle(StyleManager.colorStyle.systemGray)
            }else if viewModel.shouldShowDetailView {
                AttachedFileDetailView(viewModel: viewModel, attachmentMode: .install)
            }else if viewModel.shouldShowUploadView {
                AttachedFileDetailView(viewModel: viewModel, attachmentMode: .upload)
            }else if viewModel.allObjects.isEmpty {
                EmptyBucketView(viewModel: viewModel)
            }
        }
    }
    
    private func settingButtonView() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                Device.isIpad ? appCoordinator.push(.settings) : appCoordinator.presentSheet(.settings)
            }, label: {
                var uiImage: UIImage? {
                    if let userprofile = viewModel.userprofile {
                        return UIImage(data: userprofile.profileImageData)
                    }else {
                        return imageWith(name: "Unknown")
                    }
                }
                
                Image(uiImage: uiImage!)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
            })
        }
    }
}


#Preview {
    HomeView(viewModel: .preview)
        .environmentObject(AppCoordinatorImpl())
}
