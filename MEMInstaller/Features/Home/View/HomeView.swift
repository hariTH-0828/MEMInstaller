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
    
    @State var isPresentFile: Bool = false
    
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel(StratusRepositoryImpl()))
    }
    
    var body: some View {
        NavigationStack {
            LoaderView(isLoading: $viewModel.isLoading) {
                ZStack {
                    if viewModel.buckets.isEmpty {
                        EmptyStateView(isPresentFiles: $isPresentFile)
                    }else {
                        List(viewModel.buckets, id: \.self) { bucket in
                            ListBucketView(bucket: bucket)
                        }
                    }
                }
                .navigationTitle("com.learn.meminstaller.home.title")
                .showToast(message: viewModel.toastMessage, isShowing: $viewModel.isPresentToast)
                .toolbar { settingToolBarItem() }
                .fileImporter(isPresented: $isPresentFile, allowedContentTypes: [.ipa]) { result in
                    switch result {
                    case .success(let location):
                        viewModel.extractIpaFileContents(from: location)
                        viewModel.extractAppBundle()
                    case .failure(let error):
                        viewModel.presentToast(message: error.localizedDescription)
                    }
                }
                .sheet(item: $viewModel.bundleProperties, content: { property in
                    AttachedFileDetailView(viewModel: viewModel, bundleProperty: property)
                        .presentationDragIndicator(.visible)
                })
            }
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

struct EmptyStateView: View {
    @Binding var isPresentFiles: Bool
    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack {
                Image(.noFileFound)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.7)
                    .padding(.bottom, 50)
                
                Button(action: {
                    isPresentFiles.toggle()
                }, label: {
                    Text("Add file")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: geometry.size.width * 0.5, height: 50)
                        .background(RoundedRectangle(cornerRadius: 12))
                })
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 30)
            }
            .clipped()
            .frame(width: geometry.size.width, height: geometry.size.height)
        })
    }
}

struct ListBucketView: View {
    let bucket: BucketModel
    
    init(bucket: BucketModel) {
        self.bucket = bucket
    }
    
    var body: some View {
        HStack {
            Label(
                title: {
                    Text(bucket.bucketName.capitalized)
                        .font(.system(size: 16, weight: .regular))
                },
                icon: { 
                    Image("bucket")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            )
            
            Spacer()
            
            Button(action: {
                // Handle bottom sheet
            }, label: {
                Image(systemName: "i.circle")
                    .foregroundStyle(StyleManager.colorStyle.contentBackground)
                    .font(.system(size: 14))
            })
        }
    }
}



struct HomeViewPreviewProvider: PreviewProvider {
    
    static let bucket = BucketModel(bucketName: "packages", projectDetails: ProjectDetail(projectName: "ZInstaller", projectId: 21317000000012001), createdBy: CreatedBy(firstName: "Hariharan", lastName: "R S", emailId: "hariharan.rs@zohocorp.com", userType: "Admin"), createdTime: "Nov 04, 2024 04:10 PM", bucketURL: "https://packages-development.zohostratus.com")
    
    static var previews: some View {
        HomeView()
    }
}
