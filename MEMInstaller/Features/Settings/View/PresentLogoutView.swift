//
//  PresentLogoutView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 20/11/24.
//

import SwiftUI

// MARK: Logout View
struct PresentLogoutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20, content: {
            Text("Do you wise to sign out?")
                .padding(.all, 15)
                .bold()
            
            HStack(spacing: 30, content: {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Cancel")
                })
                .defaultOutlineButtonStyle(foregroundColor: Color.primary)
                
                Button(role: .destructive) {
                    dismiss()
                    NotificationCenter.default.post(name: .performLogout, object: nil)
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
