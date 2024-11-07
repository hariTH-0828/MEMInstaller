//
//  ViewModifiers.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI

// MARK: - DefaultProfileImageView
struct DefaultProfileImageView: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .frame(width: 45, height: 45)
            .aspectRatio(contentMode: .fit)
            .clipShape(.circle)
            .overlay {
                Circle()
                    .fill(.clear)
                    .strokeBorder(.gray)
                    .frame(width: 45, height: 45)
            }
    }
}

// MARK: - DefaultButtonStyle
struct DefaultButtonStyle: ViewModifier {
    let backgroundColor: Color
    let foregroundColor: Color
    let height: CGFloat
    let width: CGFloat
    let bold: Bool
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: width, alignment: .center)
            .frame(height: height)
            .foregroundStyle(foregroundColor)
            .bold()
            .background(
                Capsule()
                    .fill(backgroundColor)
            )
    }
}

// MARK: - DefaultOutlineButtonStyle
struct DefaultOutlineButtonStyle: ViewModifier {
    let outlineColor: Color
    let foregroundColor: Color
    let width: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: width, alignment: .center)
            .frame(height: 40)
            .foregroundStyle(foregroundColor)
            .overlay(Capsule().stroke(outlineColor))
            .shadow(color: outlineColor, radius: 25)
    }
}

// MARK: - ZLabel
struct ZLabel<Title: View, Icon: View>: View {
    var title: Title
    var content: Title?
    var icon: Icon
    var spacing: CGFloat
    var iconAlignment: VerticalAlignment
    
    init(spacing: CGFloat = 10,
         @ViewBuilder title: () -> Title,
         @ViewBuilder content: () -> Title? = { nil },
         @ViewBuilder icon: () -> Icon,
         alignment iconAlignment: VerticalAlignment = .center) 
    {
        self.title = title()
        self.content = content()
        self.icon = icon()
        self.spacing = spacing
        self.iconAlignment = iconAlignment
    }
    
    var body: some View {
        HStack(alignment: iconAlignment, spacing: spacing) {
            icon
            
            VStack(alignment: .leading, spacing: 2) {
                title
                
                if let content = content {
                    content
                }
            }
        }
    }
}
