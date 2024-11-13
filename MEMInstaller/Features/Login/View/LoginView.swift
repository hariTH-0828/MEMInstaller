//
//  LoginView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 05/11/24.
//

import SwiftUI
import MEMToast

struct LoginView: View {
    @StateObject private var appViewModel: AppViewModel = AppViewModel.shared

    var body: some View {
        NavigationStack {
            GeometryReader(content: { geometry in
                VStack(spacing: 0) {
                    loginOnBoardImageView()
                    
                    loginContentView(geometry)
                    
                    loginButtonView(geometry)
                }
                .clipped()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            })
            .showToast(message: appViewModel.toastMessage, isShowing: $appViewModel.isPresentToast)
        }
    }
    
    @ViewBuilder
    private func loginOnBoardImageView() -> some View {
        Image(.loginOnboard)
            .resizable()
            .frame(width: 300, height: 300)
            .scaledToFit()
            .padding()
    }
    
    @ViewBuilder
    private func loginContentView(_ geometry: GeometryProxy) -> some View {
        Text("com.learn.meminstaller.loginview.welcome")
            .font(.system(size: 25.0, weight: .bold))
            .padding()
        
        Text("com.learn.meminstaller.loginview.description")
            .padding(.horizontal)
            .font(.system(size: 16.0))
            .foregroundStyle(Color(uiColor: .systemGray))
            .padding(.bottom, 60)
    }
    
    @ViewBuilder
    private func loginButtonView(_ geometry: GeometryProxy) -> some View {
        Button(action: { appViewModel.IAMLogin() }, label: {
            Label(
                title: {
                    Text("com.learn.meminstaller.loginview.loginBtn")
                        .font(.system(size: 18, weight: .regular))
                },
                icon: {
                    Image("zoho-logo")
                        .resizable()
                        .frame(width: 35, height: 20)
                }
            )
            .frame(width: geometry.size.width / 1.5, height: 35)
            .foregroundStyle(.white)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(StyleManager.colorStyle.tintColor)
            )
            .padding()
        })
    }
}

#Preview {
    LoginView()
}

