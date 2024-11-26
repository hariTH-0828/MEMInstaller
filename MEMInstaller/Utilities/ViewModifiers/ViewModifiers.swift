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
            .frame(width: 40, height: 40)
            .scaledToFit()
            .clipShape(.circle)
            .overlay {
                Circle()
                    .fill(.clear)
                    .strokeBorder(.gray)
                    .frame(width: 41, height: 41)
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
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(foregroundColor)
            .padding()
            .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: 12)
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

// MARK: - LoaderView
struct LoaderView<Content: View, Loader: View>: View {
    @Binding var loadingState: LoadingState
    let content: Content
    var progressView: Loader
    
    init(loadingState: Binding<LoadingState>,
         @ViewBuilder content: () -> Content,
         @ViewBuilder loader: () -> Loader = { ProgressView() } )
    {
        self._loadingState = loadingState
        self.content = content()
        self.progressView = loader()
    }
    
    var body: some View {
        if loadingState == .loading {
            ZStack(alignment: .center, content: {
                progressView
                    .progressViewStyle(.horizontalCircular)
                    .background(.clear)
                    .tint(StyleManager.colorStyle.tintColor)
                    .scaleEffect(1)
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }else {
            self.content
        }
    }
}

// MARK: - Shimmer Effect
struct ShimmerEffect: ViewModifier {
    @Binding var enable: Bool
    @State var isAnimating: Bool = false
    
    func body(content: Content) -> some View {
        content
            .mask {
                if enable {
                    shimmerLayer(in: UIScreen.main.bounds.size)
                        .onAppear {
                            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                                self.isAnimating = true
                            }
                        }
                }
            }
    }
    
    @ViewBuilder
    private func shimmerLayer(in size: CGSize) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.8), Color(uiColor: .systemGray5)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .offset(x: isAnimating ? size.width : -size.width)
            .opacity(0.5)
//            .clipped()
    }
}

// MARK: - ShowAlert
func showAlert(_ title: String = "", message: String, _ actionHandler: ((UIAlertAction) -> Void)? = nil) {
    if let scenes = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        if let topView = scenes.windows.first?.rootViewController {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: actionHandler))
            topView.present(alert, animated: true)
        }
    }
}

// MARK: - LabelWithFieldItem
struct LabelWithFieldItem<Content>: View where Content: View {
    let label: String
    let isMandatory: Bool
    let content: Content
    
    init(label: String, isMandatory: Bool = false, content: () -> Content) {
        self.label = label
        self.isMandatory = isMandatory
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 2) {
                Text(label)
                    .foregroundStyle(.placeholder)
                
                if isMandatory {
                    Text(" *")
                        .foregroundStyle(.red)
                        .baselineOffset(-2)
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            content
        }
        .padding(.vertical, 3)
    }
}
