//
//  ContentView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 05/11/24.
//

import SwiftUI
import MEMToast

struct ContentView: View {
    @StateObject private var appViewModel: AppViewModel = AppViewModel.shared
    
    var body: some View {
        if appViewModel.isUserLoggedIn == .logIn {
            HomeView()
        }else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
