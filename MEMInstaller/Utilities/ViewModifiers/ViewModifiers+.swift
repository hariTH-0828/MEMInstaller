//
//  ViewModifiers+.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI

extension View {
    
    func defaultProfileImageStyle() -> some View {
        modifier(DefaultProfileImageView())
    }
    
    func defaultButtonStyle(backgroundColor: Color = StyleManager.colorStyle.tintColor,
                            foregroundColor: Color = Color(uiColor: .systemBackground),
                            bold: Bool = true,
                            width: CGFloat = 150,
                            height: CGFloat = 50) -> some View
    {
        modifier(DefaultButtonStyle(backgroundColor: backgroundColor,
                                    foregroundColor: foregroundColor,
                                    height: height,
                                    width: width,
                                    bold: true))
    }
    
    func defaultOutlineButtonStyle(outlineColor: Color = StyleManager.colorStyle.placeholderText, foregroundColor: Color, width: CGFloat = 150) -> some View {
        modifier(DefaultOutlineButtonStyle(outlineColor: outlineColor, foregroundColor: foregroundColor, width: width))
    }
    
    func shimmer(enable: Binding<Bool>) -> some View {
        modifier(ShimmerEffect(enable: enable))
    }
    
    func settingButtonView<S: ShapeStyle>(background: S = .regularMaterial) -> some View {
        modifier(SettingButtonView(background: background))
    }
    
    func zpresentationDetent(detents: Binding<Set<PresentationDetent>>) -> some View {
        modifier(ZPresentation(sheetContentHeight: detents))
    }
    
    func removeSideBarToggle() -> some View {
        modifier(RemoveSideBarToggle())
    }
    
    func onChange<E>(of equatable: E, action: @escaping (E, E) -> Void) -> some View where E: Equatable {
        modifier(OnChangeModifier(of: equatable, action: action))
    }
}
