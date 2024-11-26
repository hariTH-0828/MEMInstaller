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
        NavigationView(content: {
            LoginView()
                .fullScreenCover(isPresented: $appViewModel.isUserLoggedIn, content: {
                    HomeView()
                        .environmentObject(appViewModel)
                })
        })
        .environmentObject(appViewModel)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}
