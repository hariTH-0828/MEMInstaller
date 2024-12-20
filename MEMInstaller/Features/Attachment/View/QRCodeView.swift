//
//  QRCodeView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 11/12/24.
//

import SwiftUI

struct QRCodeView: View {
    // MARK: - Properties
    private let url: String
    private let appIconURL: String? // App Icon URL
    private let data: Data // QR Code Data
    @State private var appIcon: Data? // App Icon Data
    
    private var qrcodeWidth: CGFloat {
        return Device.isIphone ? 200 : 280
    }
    
    private var qrcodeHeight: CGFloat {
        return Device.isIphone ? 200: 280
    }
    
    init(url: String, appIconURL: String?) {
        self.url = Constants.installationPrefix + url
        self.appIconURL = appIconURL
        self.data = QRCodeGenerator.generate(from: self.url)!
    }
    
    var body: some View {
        VStack {
            qrCodeImage()
                .contextMenu(menuItems: {
                   saveQRCodeButtonView()
                })
            
            Text("com.learn.meminstaller.qrcode.description")
                .font(.footnote)
                .foregroundStyle(StyleManager.colorStyle.secondary)
        }
        .task {
            appIcon = try? await DownloadService(url: appIconURL!).downloadFile()
        }
    }
    
    @ViewBuilder
    private func qrCodeImage() -> some View {
        Image(uiImage: UIImage(data: data)!)
            .resizable()
            .frame(width: qrcodeWidth, height: qrcodeHeight)
            .padding(10)
            .background {
                if #available(iOS 17.0, *) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.clear)
                        .stroke(.thinMaterial, lineWidth: 2)
                }else {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.thinMaterial, lineWidth: 2)
                }
            }
            .overlay {
                if let appIcon {
                    AppIconView(icon: appIcon, width: 55, height: 55)
                        .background(Circle().fill(.background))
                }else {
                    ProgressView()
                        .padding(8)
                        .background(Circle().fill(.background))
                }
            }
    }
    
    @ViewBuilder
    private func saveQRCodeButtonView() -> some View {
        Button(action: {
            saveImageToPhotos()
        }, label: {
            Label("Save QR Code", systemImage: "square.and.arrow.down")
        })
    }
    
    private func saveImageToPhotos() {
        let uiImage = qrCodeImage().snapshot()
        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
    }
}

#Preview {
    QRCodeView(url: "https://packages-development.zohostratus.com/hariharan.rs@zohocorp.com/SDP/SDP.plist", appIconURL: "https://packages-development.zohostratus.com/hariharan.rs@zohocorp.com/ZorroWare/AppIcon60x60@2x.png")
}
