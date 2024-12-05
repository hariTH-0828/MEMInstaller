//
//  EmptyBucketView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 15/11/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct EmptyBucketView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
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
                    Button {
                        coordinator.openFileImporter { result in
                            switch result {
                            case .success(let filePath):
                                PackageExtractionHandler.shared.initiateAppExtraction(from: filePath)
//                                viewModel.updateLoadingState(for: .detail, to: .idle(.detail(.upload)))
                            case .failure(let failure):
                                ZLogs.shared.error(failure.localizedDescription)
                                viewModel.showToast(failure.localizedDescription)
                            }
                        }
                    } label: {
                        Text("com.learn.meminstaller.home.btn_upload")
                            .defaultButtonStyle(width: min(geometry.size.width * 0.4, 300))
                    }
                    
                    Button {
                        refreshView()
                    } label: {
                        Text("com.learn.meminstaller.home.refresh")
                            .defaultButtonStyle(width: min(geometry.size.width * 0.4, 300))
                    }
                }
                .padding(.bottom, 30)
            }
        })
    }
    
    // MARK: HELPER METHOD
    func refreshView() {
        withAnimation { viewModel.updateLoadingState(for: .sidebar, to: .loading) }
        viewModel.fetchFolders()
    }
}


// MARK: Preview helper
extension HomeViewModel {
    static var preview: HomeViewModel {
        HomeViewModel(repository: StratusRepositoryImpl(),
                      userDataManager: UserDataManager())
    }
}

#Preview {
    EmptyBucketView()
}


/*
 
 func handleDrop(provider: NSItemProvider) -> Bool {
     var didHandleDrop = false
     if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
         provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
             guard let data = item as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil),
                   url.pathExtension == "ipa" else {
                 // Handle invalid file type
                 viewModel.handleError("Invalid file type")
                 return
             }

             DispatchQueue.main.async {
                 viewModel.packageHandler.initiateAppExtraction(from: url)
                 viewModel.shouldShowDetailView = .upload
             }
         }
         didHandleDrop = true
     }

     return didHandleDrop
 }
 
 */
