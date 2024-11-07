//
//  DefaultToastStyle.swift
//  MEMToast
//
//  Created by Hariharan R S on 25/10/24.
//

import SwiftUI

@available(iOS 16.0, *)
public struct DefaultToastStyle: ToastViewStyle {
    public func makeBody(message: String?) -> some View {
        GeometryReader(content: { geometry in
            ZStack {
                HStack(spacing: 6) {
                    Image(uiImage: getCurrentAppIcon())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 26, height: 26)
                        .clipShape(Circle())
                    
                    Text(message ?? "")
                        .lineLimit(1)
                        .font(.footnote)
                        .frame(height: 40)
                }
                .padding(.horizontal, 8)
                .background(
                    Capsule()
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
                .frame(minWidth: 0,
                       maxWidth: min(geometry.size.width * 0.7, messageWidth(message) + 50))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        })
    }
    
    private func messageWidth(_ msg: String?) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]
        return (msg as? NSString)?.size(withAttributes: attributes).width ?? 50
    }
    
    private func getCurrentAppIcon() -> UIImage {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
              let lastIcon = iconFiles.last,
              let icon = UIImage(named: lastIcon) else {
            return UIImage()
        }
        return icon
    }
}
