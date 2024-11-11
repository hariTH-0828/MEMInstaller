//
//  StyleManager.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI

protocol ColorStyleProtocol {
    var backgroundColor: Color { get }
    var invertBackground: Color { get }
    var tintColor: Color { get }
    var tintUIColor: UIColor { get }
    var placeholderText: Color { get }
    var secondaryBackground: Color { get }
    var systemGray: Color { get }
    var contentBackground: Color { get }
    var quaternarySystemFill: Color { get }
    var tabBarShadow: Color { get }
    var secondary: Color { get }
    var alert: Color { get }
}

struct StyleManager {
    static var colorStyle: ColorStyleProtocol = Colors()
}
