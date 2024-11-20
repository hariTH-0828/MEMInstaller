//
//  SideMenu.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 18/11/24.
//

import SwiftUI

struct SideMenu<Content: View>: View where Content: View {
    @Binding var isSideMenuVisible: Bool
    @ViewBuilder var content: Content
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isSideMenuVisible {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isSideMenuVisible.toggle()
                    }
                
                content
                    .transition(.move(edge: .leading))
                    .background(.clear)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.4), value: isSideMenuVisible)
    }
}

#Preview {
    HomeView()
}
