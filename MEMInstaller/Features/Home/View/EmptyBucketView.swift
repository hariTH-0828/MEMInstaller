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
                
                UploadButtonView(viewModel: viewModel, geometry: geometry)
            }
            .clipped()
        })
    }
}

struct UploadButtonView: View {
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    
    @ObservedObject var viewModel: HomeViewModel
    let geometry: GeometryProxy
    
    init(viewModel: HomeViewModel, geometry: GeometryProxy) {
        self.viewModel = viewModel
        self.geometry = geometry
    }
    
    var body: some View {
        Button(action: {
            appCoordinator.openFileImporter { result in
                switch result {
                case .success(let filePath):
                    viewModel.packageHandler.extractIpaFileContents(from: filePath)
                    viewModel.packageHandler.extractAppBundle()
                case .failure(let failure):
                    ZLogs.shared.error(failure.localizedDescription)
                    viewModel.presentToast(message: failure.localizedDescription)
                }
            }
        }, label: {
            Text("com.learn.meminstaller.home.btn_upload")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.background)
                .padding()
                .frame(width: geometry.size.width * 0.7, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(StyleManager.colorStyle.tintColor)
                )
        })
    }
}

#Preview {
    HomeView()
}
