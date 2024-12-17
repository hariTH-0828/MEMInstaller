//
//  DeletionToastStyle.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 17/12/24.
//

import SwiftUI
import MEMToast

struct DeletionToastStyle: ToastViewStyle {
    func makeBody(message: String?) -> some View {
        Label(
            title: { 
                Text(message ?? "Failed to delete path")
                    .font(.footnote)
            },
            icon: {
                Image("ico_checkmark")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
        )
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(StyleManager.colorStyle.backgroundColor)
                .shadow(color: StyleManager.colorStyle.contentBackground, radius: 6)
        )
    }
}


struct DeletionToastPreview: PreviewProvider {
    @State static var toastMessage: String = "Path deletion scheduled"
    @State static var isPresentToast: Bool = true
    static var previews: some View {
        ZStack {
            Text("Hello, World")
        }
        .showToast(message: toastMessage, isShowing: $isPresentToast)
        .toastViewStyle(DeletionToastStyle())
    }
}
