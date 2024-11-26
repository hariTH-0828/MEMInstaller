//
//  LoginView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 05/11/24.
//

import SwiftUI
import MEMToast

struct LoginView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        NavigationStack {
            GeometryReader(content: { geometry in
                welcomeTextView()
                    .padding(.top, 50)
                
                VStack {
                    loginOnBoardImageView(geometry: geometry)
                    
                    Text("com.learn.meminstaller.loginview.description")
                        .frame(width: geometry.size.width * 0.5)
                        .padding(.horizontal)
                        .font(.system(size: 15.0))
                        .foregroundStyle(Color(uiColor: .systemGray))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                ZStack {
                    loginButtonView(geometry)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            })
            .showToast(message: appViewModel.toastMessage, isShowing: $appViewModel.isPresentToast)
        }
    }
    
    @ViewBuilder
    func welcomeTextView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Group {
                Text("com.learn.meminstaller.loginview.welcome")
                    .font(.system(size: 25, weight: .light, design: .default))
                
                Text("com.learn.meminstaller.loginview.appName")
                    .font(.system(size: 25, weight: .bold, design: .default))
            }
            .padding(.horizontal, 30)
        }
    }
    
    @ViewBuilder
    private func loginOnBoardImageView(geometry: GeometryProxy) -> some View {
        Image(.loginOnboard)
            .resizable()
            .frame(width: min(geometry.size.width * 0.5, 450), height: min(geometry.size.height * 0.4, 450))
            .scaledToFit()
            .padding()
    }
    
    @ViewBuilder
    private func loginButtonView(_ geometry: GeometryProxy) -> some View {
        Button(action: { appViewModel.IAMLogin() }, label: {
            Text("com.learn.meminstaller.loginview.loginBtn")
                .font(.system(size: 18, weight: .regular))
                .frame(width: min(geometry.size.width / 1.5, 450), height: 35)
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

