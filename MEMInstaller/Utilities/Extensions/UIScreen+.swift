//
//  UIScreen+.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 29/11/24.
//

import SwiftUI

extension UIScreen {
    static var screenWidth: CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return 0
        }
        return windowScene.screen.bounds.width
    }

    static var screenHeight: CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return 0
        }
        return windowScene.screen.bounds.height
    }
}
