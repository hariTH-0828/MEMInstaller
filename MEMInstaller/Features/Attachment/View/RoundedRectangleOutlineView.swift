//
//  RoundedRectangleOutlineView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 26/11/24.
//

import SwiftUI

struct RoundedRectangleOutlineView<T>: View where T: View {
    let content: T
    
    init(content: @escaping () -> T) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.regularMaterial)
        )
        .padding()
    }
}
