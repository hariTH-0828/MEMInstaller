//
//  QRCodeProviderView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 11/12/24.
//

import SwiftUI

struct QRProvider: Hashable, Identifiable {
    let appIconURL: String?
    let appName: String
    let url: String
    
    var id: Self { self }
}

struct QRCodeProviderView: View {
    let qrProvider: QRProvider
    
    var body: some View {
        VStack {
            appIconWithTitle()
            
            QRCodeView(url: qrProvider.url, appIconURL: qrProvider.appIconURL)
                .padding()
            
            StyledButton(title: "Copy URL", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = Constants.installationPrefix + qrProvider.url
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    @ViewBuilder
    private func appIconWithTitle() -> some View {
        HStack {
            AppIconView(iconURL: qrProvider.appIconURL, width: 45, height: 45)
            
            Text(qrProvider.appName)
                .font(.system(size: 16, weight: .semibold))
        }
    }
    
    @ViewBuilder
    private var noteTextView: some View {
        Text("Note: Long press the QR Code to save and copy the file installation url")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}


struct StyledButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .foregroundStyle(StyleManager.colorStyle.tintColor)
                .font(.callout)
                .padding(.horizontal)
                .frame(height: 50)
                .background {
                    if #available(iOS 17.0, *) {
                        Capsule()
                            .fill(.clear)
                            .stroke(StyleManager.colorStyle.tintColor, lineWidth: 1)
                    }else {
                        Capsule()
                            .stroke(StyleManager.colorStyle.tintColor, lineWidth: 1)
                    }
                }
        }
    }
}


// MARK: - PREVIEW PROVIDER
struct QRCodeProviderView_Previews: PreviewProvider {
    static let qrprovider: QRProvider = QRProvider(appIconURL: "https://packages-development.zohostratus.com/hariharan.rs@zohocorp.com/SDP/AppIcon60x60@2x.png", appName: "SDP", url: "https://packages-development.zohostratus.com/hariharan.rs@zohocorp.com/SDP/SDP.plist")
    
    static var previews: some View {
        QRCodeProviderView(qrProvider: qrprovider)
    }
}
