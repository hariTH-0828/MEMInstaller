//
//  EmptyBucketView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 15/11/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct EmptyBucketView: View {
    private let packageHandler = PackageExtractionHandler()

    @EnvironmentObject var coordinator: AppCoordinatorImpl
    @State private var isDropTarget = false
    
    @ObservedObject var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                if #available(iOS 17.0, *) {
                    ContentUnavailableView(label: {
                        Label(
                            title: {
                                Text("com.learn.meminstaller.home.no-file-title")
                            },
                            icon: {
                                imageView
                                    .frame(height: geometry.size.height * 0.4)
                            }
                        )
                    }, description: {
                        Text("com.learn.meminstaller.home.no-file-description")
                    })
                }else {
                    PlaceholderView(image: {
                        imageView
                            .frame(height: geometry.size.height * 0.4)
                    }, title: "com.learn.meminstaller.home.no-file-title", description: "com.learn.meminstaller.home.no-file-description")
                }
                
                // Action Buttons
                HStack(spacing: 20) {
                    Button {
                        coordinator.openFileImporter { result in
                            switch result {
                            case .success(let filePath):
                                packageHandler.initiateAppExtraction(from: filePath)
                                let packageExtractionModel = packageHandler.getPackageExtractionModel()
                                viewModel.selectedPackageModel = packageExtractionModel
                            case .failure(let failure):
                                ZLogs.shared.error(failure.localizedDescription)
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
            .frame(maxWidth: .infinity, alignment: .center)
            .onDrop(of: [UTType.ipa], isTargeted: $isDropTarget) { providers in
                guard let provider = providers.first else { return false }
                return viewModel.handleDrop(provider: provider)
            }
        })
    }
    
    @ViewBuilder
    private var imageView: some View {
        Image("no-file-found")
            .resizable()
            .scaledToFit()
    }
    
    // MARK: HELPER METHOD
    /// Refresh SideBar
    func refreshView() {
        viewModel.fetchFolders()
    }
}

struct PlaceholderView<V>: View where V: View {
    let image: V
    let title: LocalizedStringKey
    let description: LocalizedStringKey?
    
    init(@ViewBuilder image: @escaping () -> V, title: LocalizedStringKey, description: LocalizedStringKey?) {
        self.image = image()
        self.title = title
        self.description = description
    }
    
    var body: some View {
        VStack {
            image

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            if let description = description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
