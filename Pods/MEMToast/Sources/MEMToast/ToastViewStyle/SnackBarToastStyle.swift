//
//  SnackBarViewStyle.swift
//  MEMToast
//
//  Created by Hariharan R S on 25/10/24.
//

import SwiftUI

@available(iOS 16, *)
public struct SnackBarToastStyle: ToastViewStyle {
    private let actionName: String
    private let action: (() -> Void)
    
    init(actionName: String, action: @escaping () -> Void) {
        self.actionName = actionName
        self.action = action
    }
    
    public func makeBody(message: String?) -> some View {
        ZStack {
            HStack {
                Text(message ?? "")
                    .foregroundStyle(.background)
                    .lineLimit(1)
                    .font(.footnote)
                    .frame(height: 40)
                
                Spacer()
                
                Button(action: action, label: {
                    Text(actionName)
                        .foregroundStyle(.background)
                        .font(.footnote)
                })
            }
            .padding(.horizontal)
            .background(
                Rectangle()
                    .fill(.indigo)
            )
        }
    }
}

