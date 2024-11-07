//
//  Toast.swift
//  MEMToast
//
//  Created by Hariharan R S on 25/10/24.
//

import SwiftUI

@available(iOS 16.0, *)
struct MEMToast: View {
    @Environment(\.ToastStyle) private var toastStyle
    @State private var presentToast: Bool = false
    private let delay: Double = 2.5
    
    var message: String?
    
    init(message: String?) {
        self.message = message
    }
    
    public var body: some View {
        ZStack {
            if presentToast {
                ZStack {
                    toastStyle.makeBody(message: message)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear(perform: {
            toggleToast(shouldAppear: true, delay: delay)
        })
    }
    
    private func toggleToast(shouldAppear: Bool, delay: Double) {
        withAnimation(.spring()) {
            self.presentToast = shouldAppear
        }
        if shouldAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(duration: 3.0)) {
                    self.presentToast = false
                }
            }
        }
    }
}
