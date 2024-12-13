//
//  IdleStateView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/12/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct IdleStateView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    @State private var dragOver: Bool = false
    
    var body: some View {
        ZStack {
            // Drop area view
            Rectangle()
                .fill(StyleManager.colorStyle.secondaryBackground.opacity(0.01))
                .frame(maxWidth: UIScreen.screenWidth, maxHeight: UIScreen.screenHeight)
            
            Text("Select an app to see details")
                .foregroundColor(.gray)
        }
        .onDrop(of: [UTType.ipa], isTargeted: $dragOver, perform: { providers in
            guard let provider = providers.first else { return false }
            return viewModel.handleDrop(provider: provider)
        })
    }
}
