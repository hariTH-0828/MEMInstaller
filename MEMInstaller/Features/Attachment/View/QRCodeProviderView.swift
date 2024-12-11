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
    
    init(qrProvider: QRProvider) {
        self.qrProvider = qrProvider
    }
    
    var body: some View {
        VStack {
            appIconWithTitle()
            
            QRCodeView(url: qrProvider.url, appIconURL: qrProvider.appIconURL)
            
            urlView()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "F3F6FD"))
        )
    }
    
    @ViewBuilder
    private func appIconWithTitle() -> some View {
        HStack {
            AppIconView(iconURL: qrProvider.appIconURL, width: 55, height: 55)
            Text(qrProvider.appName)
                .font(.system(size: 16, weight: .semibold))
        }
    }
    
    @ViewBuilder
    private func urlView() -> some View {
        CopyInstallationLinkView(installationLink: qrProvider.url)
    }
}


// MARK: - PREVIEW PROVIDER
struct QRCodeProviderView_Previews: PreviewProvider {
    static let qrprovider: QRProvider = QRProvider(appIconURL: "https://packages-development.zohostratus.com/hariharan.rs@zohocorp.com/SDP/AppIcon60x60@2x.png", appName: "SDP", url: "https://packages-development.zohostratus.com/hariharan.rs@zohocorp.com/SDP/SDP.plist")
    
    static var previews: some View {
        QRCodeProviderView(qrProvider: qrprovider)
    }
}
