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
                if #available(iOS 17.0, *) {
                    Circle()
                        .fill(.clear)
                        .strokeBorder(.gray)
                        .frame(width: 41, height: 41)
                }else {
                    Circle()
                        .strokeBorder(.gray)
                        .frame(width: 41, height: 41)
                }
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

struct LoaderView<L, R>: View where L: View, R: View {
    @Binding var loadingState: LoadingState
    let loadingContent: L
    let loadedContent: R
    
    init(loadingState: Binding<LoadingState>, @ViewBuilder loadingContent: @escaping () -> L, @ViewBuilder loadedContent: @escaping () -> R) {
        self._loadingState = loadingState
        self.loadingContent = loadingContent()
        self.loadedContent = loadedContent()
    }
    
    var body: some View {
        Group {
            if loadingState == .loading { loadingContent }
            else { loadedContent }
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
                if #available(iOS 17, *) {
                    Text(label)
                        .foregroundStyle(.placeholder)
                }else {
                    Text(label)
                        .foregroundStyle(StyleManager.colorStyle.placeholderText)
                }
                
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


// MARK: - Setting Button View
struct SettingButtonView<S>: ViewModifier where S: ShapeStyle {
    let background: S
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(background)
            )
            .padding(.horizontal)
    }
}

struct ZPresentation: ViewModifier {
    @Binding var sheetContentHeight: Set<PresentationDetent>
    
    init(sheetContentHeight: Binding<Set<PresentationDetent>>) {
        self._sheetContentHeight = sheetContentHeight
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader(content: { proxy in
                    Color.clear
                        .clipped()
                        .task {
                            let contentHeight = proxy.size.height + 100
                            print("Height: \(contentHeight)")
                            if contentHeight < 420 {
                                sheetContentHeight = [.height(contentHeight)]
                            }
                        }
                })
            )
    }
}


struct RemoveSideBarToggle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .toolbar(removing: .sidebarToggle)
        }else {
            content
        }
    }
}

struct OnChangeModifier<E>: ViewModifier where E: Equatable {
    let equatable: E
    let action: (E, E) -> Void
    @State private var previousValue: E
    
    init(of equatable: E, action: @escaping (E, E) -> Void) {
        self.equatable = equatable
        self.action = action
        _previousValue = State(initialValue: equatable)
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                // Initialize the previous value on first appearance.
                previousValue = equatable
            }
            .onChange(of: equatable) { newValue in
                if #available(iOS 17.0, *) {
                    action(previousValue, newValue)
                } else {
                    if newValue != previousValue {
                        action(previousValue, newValue)
                        previousValue = newValue
                    }
                }
            }
    }
}
