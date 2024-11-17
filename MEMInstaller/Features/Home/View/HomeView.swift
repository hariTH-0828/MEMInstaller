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
            LoaderView(isLoading: $viewModel.isLoading, content: {
                if !viewModel.allObject.isEmpty {
                    List(Array(viewModel.allObject.keys).sorted(), id: \.self) { folderName in
                        // Get content object and load image
                        if let contents = viewModel.allObject[folderName] {
                            
                            let iconURL = contents.filter({ $0.actualContentType == .png && $0.key.contains("AppIcon60x60@")}).first?.url
                            
                            Button(action: {
                                appCoordinator.presentSheet(.appDetail(content: contents))
                            }, label: {
                                Label(
                                    title: {
                                        Text(folderName)
                                            .foregroundStyle(.primary)
                                            .font(.system(.subheadline))
                                    },
                                    icon: {
                                        appIconView(iconURL, folderName: folderName)
                                    }
                                )
                            })
                        }
                    }
                    .refreshable {
                        await viewModel.fetchFoldersFromBucket()
                    }
                }else {
                    EmptyBucketView(viewModel: viewModel)
                }
            })
            .navigationTitle("com.learn.meminstaller.home.title")
            .navigationBarTitleDisplayMode(.inline)
            .showToast(message: viewModel.toastMessage, isShowing: $viewModel.isPresentToast)
            .toolbar {
                settingToolBarItem()
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        // Handle side menu
                    }, label: {
                        Image("menu")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    })
                }
            }
            .onChange(of: viewModel.packageHandler.bundleProperties, { _, newValue in
                guard let newValue else { return }
                appCoordinator.presentSheet(.attachedDetail(viewModel: viewModel, property: newValue))
            })
            .task {
                await viewModel.fetchFoldersFromBucket()
            }
        }
            
    }
    
    private func settingToolBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                appCoordinator.presentSheet(.settings(viewModel: viewModel))
            }, label: {
                if let profileImageData = viewModel.userprofile?.profileImageData, let uiImage = UIImage(data: profileImageData) {
                    userImageView(uiImage)
                }else {
                    let displayName = viewModel.userprofile?.displayName
                    userImageView(imageWith(name: displayName)!)
                }
            })
        }
    }
    
    @ViewBuilder
    private func userImageView(_ uiImage: UIImage) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .defaultProfileImageStyle()
    }
    
    @ViewBuilder
    private func appIconView(_ iconURL: String?, folderName: String) -> some View {
        if let iconURL {
            AsyncImage(url: URL(string: iconURL)!) { image in
                image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }else {
            Image(uiImage: imageWith(name: folderName)!)
        }
    }
}

struct HomeViewPreviewProvider: PreviewProvider {
    
    static let bucket = BucketModel(bucketName: "packages", projectDetails: ProjectDetail(projectName: "ZInstaller", projectId: 21317000000012001), createdBy: CreatedBy(firstName: "Hariharan", lastName: "R S", emailId: "hariharan.rs@zohocorp.com", userType: "Admin"), createdTime: "Nov 04, 2024 04:10 PM", bucketURL: "https://packages-development.zohostratus.com")
    
    static var previews: some View {
        HomeView()
    }
}
