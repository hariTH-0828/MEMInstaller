//
//  View+.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 15/11/24.
//

import SwiftUI

extension View {
    func customShadow(color: Color = .black, radius: CGFloat = 10, x: CGFloat = 0, y: CGFloat = 0, opacity: Double = 0.3) -> some View {
        self.shadow(color: color.opacity(opacity), radius: radius, x: x, y: y)
    }
}
