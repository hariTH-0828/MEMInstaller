//
//  SettingLabelView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 10/12/24.
//

import SwiftUI

struct SettingLabelView: View {
    let title: LocalizedStringKey
    let color: Color
    let iconName: String
    let iconColor: Color
    
    init(_ title: LocalizedStringKey, color: Color = StyleManager.colorStyle.invertBackground, iconName: String, iconColor: Color) {
        self.title = title
        self.iconName = iconName
        self.color = color
        self.iconColor = iconColor
    }
    
    var body: some View {
        HStack {
            if UIImage.isAssetAvailable(named: iconName) {
                Image(iconName)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 20, height: 20)
                    .foregroundStyle(iconColor)
            }else {
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(iconColor)
            }
            
            Text(title)
                .lineLimit(1)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
