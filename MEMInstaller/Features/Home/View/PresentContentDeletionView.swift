//
//  PresentContentDeletionView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 17/12/24.
//

import SwiftUI

struct PresentContentDeletionView: View {
    @Environment(\.dismiss) private var dismiss
    private var action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20, content: {
            Text("Are you sure?")
                .padding(.all, 15)
                .bold()
            
            HStack(spacing: 30, content: {
                Button(action: { dismiss() }, label: {
                    Text("Cancel")
                })
                .defaultOutlineButtonStyle(foregroundColor: Color.primary)
                
                Button(role: .destructive) {
                    action()
                } label: {
                    Text("Delete")
                }
                .defaultOutlineButtonStyle(outlineColor: .red, foregroundColor: .red)
            })
        })
    }
}

#Preview {
    PresentContentDeletionView {
        
    }
}
