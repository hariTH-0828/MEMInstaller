//
//  ContentView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 05/11/24.
//

import SwiftUI
import MEMToast

struct ContentView: View {
    @StateObject var appViewModel: AppViewModel = AppViewModel()
    @StateObject private var coordinator: AppCoordinatorImpl = AppCoordinatorImpl()

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            coordinator.build(forScreen: appViewModel.isUserLoggedIn ? .tabView : .login)
                .navigationDestination(for: Screen.self) {
                    coordinator.build(forScreen: $0)
                }
                .sheet(item: $coordinator.sheet, onDismiss: coordinator.dismissSheet) {
                    coordinator.build(forSheet: $0)
                }
                .fileImporter(isPresented: $coordinator.shouldShowFileImporter, allowedContentTypes: [.ipa]) { result in
                    coordinator.fileImportCompletion?(result)
                }
        }
        .environmentObject(appViewModel)
        .environmentObject(coordinator)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}
