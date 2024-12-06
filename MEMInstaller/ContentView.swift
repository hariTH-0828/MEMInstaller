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
    
    @StateObject var sideBarViewModel: HomeViewModel = HomeViewModel(repository: StratusRepositoryImpl(), userDataManager: UserDataManager())
    @StateObject var detailViewModel: AttachedFileDetailViewModel = AttachedFileDetailViewModel()

    var body: some View {
        ZStack {
            if appViewModel.isUserLoggedIn {
                HomeView(sideBarViewModel: sideBarViewModel, detailViewModel: detailViewModel)
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
