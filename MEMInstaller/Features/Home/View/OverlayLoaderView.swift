//
//  OverlayLoaderView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 02/12/24.
//

import SwiftUI

struct OverlayLoaderView: View {
    @State var title: String? = nil
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .opacity(0.3)
            
            if let title {
                ProgressView(title)
                    .progressViewStyle(.horizontalCircular)
            }else {
                ProgressView()
                    .progressViewStyle(.horizontalCircular)
            }
        }
    }
}

#Preview {
    OverlayLoaderView()
}
