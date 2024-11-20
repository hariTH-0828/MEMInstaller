//
//  Colors.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI

struct Colors: ColorStyleProtocol {
    
    var invertBackground: Color {
        return .primary
    }
    
    var backgroundColor: Color {
        let uiColor = UIColor.setAppearance(dark: UIColor(red:0.11, green:0.11, blue:0.12, alpha:1.00), light: .white)
        return Color(uiColor: uiColor)
    }
    
    var tintColor: Color {
        let uiColor = UIColor.setAppearance(dark: darkModeTint, light: lightModeTint)
        return Color(uiColor: uiColor) // Green
    }
    
    var tintUIColor: UIColor {
        return UIColor.setAppearance(dark: darkModeTint, light: lightModeTint)
    }
    
    var placeholderText: Color {
        let uiColor = UIColor.placeholderText
        return Color(uiColor: uiColor)
    }
    
    var secondary: Color {
        return .secondary
    }
    
    var secondaryBackground: Color {
        let uiColor = UIColor.secondarySystemBackground
        return Color(uiColor: uiColor)
    }
    
    var systemGray: Color {
        let uiColor = UIColor.setAppearance(dark: .darkGray, light: .lightGray)
        return Color(uiColor: uiColor)
    }

    var contentBackground: Color {
        let lightGrayColor = UIColor(red: 223/255.0, green: 222/255.0, blue: 222/255.0, alpha: 1.0)
        let uiColor = UIColor.setAppearance(dark: .systemGray4, light: lightGrayColor)
        return Color(uiColor: uiColor)
    }
    
    var quaternarySystemFill: Color {
        return Color(.quaternarySystemFill)
    }
    
    var tabBarShadow: Color {
        let uiColor = UIColor.setAppearance(dark: UIColor.lightGray, light: .white)
        return Color(uiColor: uiColor)
    }
    
    private var darkModeTint: UIColor {
        UIColor(red: 0.35, green: 0.42, blue: 1.00, alpha: 1.00)
    }
    
    private var lightModeTint: UIColor {
        return UIColor(red: 0.18, green: 0.35, blue: 1.00, alpha: 1.00)
    }
    
    var alert: Color {
        return .red
    }
}

