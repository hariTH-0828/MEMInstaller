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
    var action: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .opacity(0.6)
            
            if let value, let action {
                HStack {
                    ProgressView(title, value: value)
                        .lineLimit(1)
                        .padding()
                    
                    Spacer()
                    
                    Button(action: action, label: {
                        Image(systemName: "x.circle.fill")
                            .foregroundStyle(StyleManager.colorStyle.invertBackground)
                            .padding(10)
                    })
                }
                .frame(width: 280)
                .background(RoundedRectangle(cornerRadius: 8).fill(.regularMaterial))
            }else {
                ProgressView(title)
                    .progressViewStyle(.horizontalCircular)
            }
        }
    }
}

#Preview {
    HorizontalLoadingWrapper(title: "Uploading application", value: 0.7, action: {
        
    })
    .preferredColorScheme(.light)
}
