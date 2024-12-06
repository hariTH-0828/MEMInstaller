//
//  CopyInstallationLinkView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/12/24.
//

import SwiftUI

struct CopyInstallationLinkView: View {
    let installationLink: String
    var completion: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 1) {
            ScrollView(.horizontal) {
                Text(installationLink)
                    .lineLimit(1)
                    .font(.footnote)
                    .disabled(true)
                    .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            
            Button(action: {
                UIPasteboard.general.string = "itms-services://?action=download-manifest&url="+installationLink
                completion?()
            }, label: {
                Rectangle()
                    .fill(Material.thinMaterial)
                    .frame(width: 35)
                    .clipShape(.rect(bottomTrailingRadius: 8, topTrailingRadius: 8))
                    .overlay {
                        Image(systemName: "doc")
                            .font(.footnote)
                            .foregroundStyle(StyleManager.colorStyle.systemGray)
                    }
            })
        }
        .frame(height: 40)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.regularMaterial)
        
        )
    }
}
#Preview {
    CopyInstallationLinkView(installationLink: "https://packages-development.zohostratus.com/hariharan.rs@zohocorp.com/SDP/Info.plist")
}
