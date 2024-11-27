//
//  ViewBuilders.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 27/11/24.
//

import SwiftUI

@ViewBuilder
func overlayLoaderView(with title: String? = nil) -> some View {
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
