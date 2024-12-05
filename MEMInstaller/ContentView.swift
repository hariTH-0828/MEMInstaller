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

    var body: some View {
        ZStack {
            if appViewModel.isUserLoggedIn {
                HomeView(viewModel: HomeViewModel(repository: StratusRepositoryImpl(),
                                                  userDataManager: UserDataManager()))
            }else {
                LoginView()
            }
        }
        .environmentObject(appViewModel)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}
