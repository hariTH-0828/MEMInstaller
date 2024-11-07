//
//  HomeView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 05/11/24.
//

import SwiftUI
import MEMToast

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel = HomeViewModel()
    @State var isPresentFiles: Bool = false
    @State var isPresentSetting: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                EmptyStateView(isPresentFiles: $isPresentFiles)
            }
            .navigationTitle("Home")
            .showToast(message: viewModel.toastMessage, isShowing: $viewModel.isPresentToast)
            .toolbar { settingToolBarItem() }
            .fileImporter(isPresented: $isPresentFiles, allowedContentTypes: [.ipa]) { result in
                switch result {
                case .success(let location):
                    viewModel.extractIpaFileContents(from: location)
                    viewModel.extractAppBundle()
                case .failure(let error):
                    viewModel.presentToast(message: error.localizedDescription)
                }
            }
            .sheet(item: $viewModel.bundleProperties, content: { property in
                #if RELEASE
                AttachedFileDetailView(viewModel: viewModel, bundleProperty: property)
                    .presentationDragIndicator(.visible)
                #endif
                
                #if DEBUG
                AttachedFileDetailView(viewModel: viewModel)
                #endif
            })
            .sheet(isPresented: $isPresentSetting, content: {
                SettingView(userprofile: viewModel.userprofile!)
            })
        }
    }
    
    private func settingToolBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: { isPresentSetting.toggle() }, label: {
                let userName = viewModel.userprofile?.firstName ?? "Unknown"
                if let uiImage = imageWith(name: userName) {
                    userImageView(uiImage)
                }else {
                    settingIconView()
                }
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
    
    @ViewBuilder
    private func settingIconView() -> some View {
        Image("gear")
            .resizable()
            .renderingMode(.template)
            .frame(width: 25, height: 25)
            .foregroundStyle(StyleManager.colorStyle.systemGray)
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

#Preview {
    HomeView()
}