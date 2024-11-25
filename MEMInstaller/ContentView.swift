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
    @StateObject private var coordinator = AppCoordinatorImpl()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.build(appViewModel.isUserLoggedIn == .logIn ? .home : .login)
                .navigationDestination(for: Screen.self) { screen in
                    coordinator.build(screen)
                }
                .sheet(item: $coordinator.sheet, onDismiss: coordinator.dismissSheet) { sheet in
                    coordinator.build(sheet)
                }
                .fileImporter(isPresented: $coordinator.shouldShowFileImporter, allowedContentTypes: [.ipa]) { result in
                    coordinator.fileImportCompletion?(result)
                }
        }
        .environmentObject(coordinator)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel.shared)
}
