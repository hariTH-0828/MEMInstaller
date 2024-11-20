//
//  EmptyBucketView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 15/11/24.
//

import SwiftUI

struct EmptyBucketView: View {
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                ContentUnavailableView(label: {
                    Label(
                        title: {
                            Text("com.learn.meminstaller.home.no-file-title")
                        },
                        icon: {
                           Image("no-file-found")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.7)
                        }
                    )
                }, description: {
                    Text("com.learn.meminstaller.home.no-file-description")
                })
                
                HStack(spacing: 20) {
                    Button("com.learn.meminstaller.home.btn_upload") {
                        appCoordinator.openFileImporter { result in
                            switch result {
                            case .success(let filePath):
                                viewModel.packageHandler.initiateAppExtraction(from: filePath)
                                appCoordinator.presentSheet(.attachedDetail(viewModel: viewModel, mode: .upload))
                            case .failure(let failure):
                                ZLogs.shared.error(failure.localizedDescription)
                                viewModel.showToast(failure.localizedDescription)
                            }
                        }
                    }
                    .defaultButtonStyle(width: geometry.size.width * 0.4)
                    
                    Button("com.learn.meminstaller.home.refresh") {
                        Task {
                            withAnimation { viewModel.setLoadingState(.loading) }
                            await viewModel.fetchFoldersFromBucket()
                        }
                    }
                    .defaultButtonStyle(width: geometry.size.width * 0.4)
                }
            }
            .clipped()
        })
    }
}

#Preview {
    HomeView()
}
