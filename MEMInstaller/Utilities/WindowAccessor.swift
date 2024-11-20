//
//  WindowAccessor.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import UIKit
import SwiftUI

struct WindowAccessor: ViewModifier {
    var callback: (UIWindow) -> Void
    
    func body(content: Content) -> some View {
        content
            .background(WindowReader(callback: callback))
    }
}

struct WindowReader: UIViewRepresentable {
    var callback: (UIWindow) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            if let window = view.window {
                self.callback(window)
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

extension View {
    func onWindow(_ callback: @escaping (UIWindow) -> Void) -> some View {
        self.modifier(WindowAccessor(callback: callback))
    }
}
