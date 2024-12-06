//
//  OverlayLoaderView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 02/12/24.
//

import SwiftUI

struct HorizontalLoadingWrapper: View {
    var title: String = "Loading"
    var value: Double? = nil
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .opacity(0.3)
            
            if let value {
                ProgressView(title, value: value)
                    .lineLimit(1)
                    .padding()
                    .frame(width: 250)
                    .background(RoundedRectangle(cornerRadius: 8).fill(.regularMaterial))
            }else {
                ProgressView(title)
                    .progressViewStyle(.horizontalCircular)
            }
        }
    }
}

#Preview {
    HorizontalLoadingWrapper(title: "Uploading application", value: 0.7)
}
