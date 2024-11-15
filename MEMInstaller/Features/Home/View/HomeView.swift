//
//  HomeView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 05/11/24.
//

import SwiftUI
import MEMToast

struct HomeView: View {
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    @StateObject var viewModel: HomeViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel(StratusRepositoryImpl()))
    }
    
    var body: some View {
        NavigationStack {
            LoaderView(isLoading: $viewModel.isLoading) {
                ZStack {
                    if let bucket = viewModel.bucket, !bucket.contents.isEmpty {
                        List(bucket.contents, id: \.self) { bucket in
                            // Handle data available
                        }
                    }else {
                        EmptyBucketView(viewModel: viewModel)
                    }
                }
                .onChange(of: viewModel.packageHandler.bundleProperties, { _, newValue in
                    guard let newValue else { return }
                    appCoordinator.presentSheet(.attachedDetail(viewModel: viewModel, property: newValue))
                })
            }
            .navigationTitle("com.learn.meminstaller.home.title")
            .showToast(message: viewModel.toastMessage, isShowing: $viewModel.isPresentToast)
            .toolbar { settingToolBarItem() }
            .task {
                await viewModel.fetchBucket()
            }
        }
    }
    
    private func settingToolBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                appCoordinator.presentSheet(.settings(viewModel: viewModel))
            }, label: {
                let userName = viewModel.userprofile?.displayName ?? "Unknown"
                userImageView(imageWith(name: userName)!)
            })
        }
    }
    
    @ViewBuilder
    private func userImageView(_ uiImage: UIImage) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .frame(width: 35, height: 35)
            .clipShape(Circle())
    }
}


struct HomeViewPreviewProvider: PreviewProvider {
    
    static let bucket = BucketModel(bucketName: "packages", projectDetails: ProjectDetail(projectName: "ZInstaller", projectId: 21317000000012001), createdBy: CreatedBy(firstName: "Hariharan", lastName: "R S", emailId: "hariharan.rs@zohocorp.com", userType: "Admin"), createdTime: "Nov 04, 2024 04:10 PM", bucketURL: "https://packages-development.zohostratus.com")
    
    static var previews: some View {
        HomeView()
    }
}
