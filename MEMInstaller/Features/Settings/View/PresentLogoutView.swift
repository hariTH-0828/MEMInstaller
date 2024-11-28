//
//  PresentLogoutView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 20/11/24.
//

import SwiftUI

// MARK: Logout View
struct PresentLogoutView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject private var coordinator: AppCoordinatorImpl
    
    var body: some View {
        VStack(spacing: 20, content: {
            Text("Do you wise to sign out?")
                .padding(.all, 15)
                .bold()
            
            HStack(spacing: 30, content: {
                Button(action: {
                    coordinator.dismissSheet()
                }, label: {
                    Text("Cancel")
                })
                .defaultOutlineButtonStyle(foregroundColor: Color.primary)
                
                Button(role: .destructive) {
                    appViewModel.logout()
                    coordinator.dismissSheet()
                } label: {
                    Text("Sign out")
                }
                .defaultOutlineButtonStyle(outlineColor: .red, foregroundColor: .red)
            })
        })
        .presentationDetents([.height(140)])
    }
}

#Preview {
    PresentLogoutView()
}
