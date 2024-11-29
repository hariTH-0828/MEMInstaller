//
//  EmptyBucketView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 15/11/24.
//

import SwiftUI

struct EmptyBucketView: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject private var coordinator: AppCoordinatorImpl
    
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
                                .frame(width: min(geometry.size.width * 0.7, 500), height: 500)
                        }
                    )
                }, description: {
                    Text("com.learn.meminstaller.home.no-file-description")
                })
                
                HStack(spacing: 20) {
                    Button("com.learn.meminstaller.home.btn_upload") {
                        coordinator.openFileImporter { result in
                            switch result {
                            case .success(let filePath):
                                viewModel.packageHandler.initiateAppExtraction(from: filePath)
                                viewModel.shouldShowDetailView = .upload
                            case .failure(let failure):
                                ZLogs.shared.error(failure.localizedDescription)
                                viewModel.showToast(failure.localizedDescription)
                            }
                        }
                    }
                    .defaultButtonStyle(width: min(geometry.size.width * 0.4, 300))
                    
                    Button("com.learn.meminstaller.home.refresh") { refreshView() }
                    .defaultButtonStyle(width: min(geometry.size.width * 0.4, 300))
                }
                .padding(.bottom, 30)
            }
            .clipped()
        })
    }
    
    // MARK: HELPER METHOD
    func refreshView() {
        Task {
            withAnimation { viewModel.updateLoadingState(for: .sidebar, to: .loading) }
            await viewModel.fetchFoldersFromBucket()
        }
    }
}


// MARK: Preview helper
extension HomeViewModel {
    static var preview: HomeViewModel {
        HomeViewModel(repository: StratusRepositoryImpl(),
                      userDataManager: UserDataManager(),
                      packageHandler: PackageExtractionHandler())
    }
}

#Preview {
    EmptyBucketView(viewModel: .preview)
}
