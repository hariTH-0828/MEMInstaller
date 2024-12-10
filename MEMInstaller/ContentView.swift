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
    @StateObject var appCoordinator: AppCoordinatorImpl = AppCoordinatorImpl()

    var body: some View {
        ZStack {
            if appViewModel.isUserLoggedIn {
                HomeView(appCoordinator: appCoordinator)
            }else {
                LoginView()
            }
        }
        .environmentObject(appViewModel)
        .onAppear(perform: {
            // Handled when logout / login make the view as top view
            appViewModel.coordinator = appCoordinator
        })
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}
