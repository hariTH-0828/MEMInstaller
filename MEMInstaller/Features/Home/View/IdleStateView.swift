//
//  IdleStateView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/12/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct IdleStateView: View {

    var body: some View {
        ZStack {
            // Drop area view
            Rectangle()
                .fill(StyleManager.colorStyle.secondaryBackground.opacity(0.01))
                .frame(maxWidth: UIScreen.screenWidth, maxHeight: UIScreen.screenHeight)
            
            Text("Select an app to see details")
                .foregroundColor(.gray)
        }
    }
}
