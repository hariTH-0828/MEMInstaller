//
//  ContentView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 05/11/24.
//

import SwiftUI
import MEMToast

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject var appCoordinator: AppCoordinatorImpl = AppCoordinatorImpl()
    
    var body: some View {
        NavigationStack(path: $appCoordinator.path) {
            if appViewModel.isUserLoggedIn == .logIn {
                buildCoordinate(.home)
            }else {
                buildCoordinate(.login)
            }
        }
        .environmentObject(appCoordinator)
    }
    
    @ViewBuilder
    private func buildCoordinate(_ screen: Screen) -> some View {
        appCoordinator.build(screen)
            .navigationDestination(for: Screen.self) { screen in
                appCoordinator.build(screen)
            }
            .sheet(item: $appCoordinator.sheet) { sheet in
                appCoordinator.build(sheet)
            }
            .fileImporter(isPresented: $appCoordinator.shouldShowFileImporter, allowedContentTypes: [.ipa]) { result in
                appCoordinator.fileImportCompletion?(result)
            }
    }
}

#Preview {
    ContentView()
}



/*
 .fileImporter(isPresented: $appCoordinator.shouldShowFileImporter, allowedContentTypes: [.ipa]) { result in
     switch result {
     case .success(let location):
         viewModel.extractIpaFileContents(from: location)
         viewModel.extractAppBundle()
     case .failure(let error):
         viewModel.presentToast(message: error.localizedDescription)
     }
 */
