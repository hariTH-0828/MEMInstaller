//
//  HomeSideBarAppLabel.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 02/12/24.
//

import SwiftUI

struct HomeSideBarAppLabel: View {
    let bucketObject: BucketObjectModel
    let iconURL: String?
    
    var body: some View {
        HStack {
            // Package size
            let packageFileSize = bucketObject.getPackageFileSize()
            
            Label(
                title: {
                    Text(bucketObject.folderName)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(StyleManager.colorStyle.invertBackground)
                },
                icon: {
                    AppIconView(iconURL: iconURL)
                }
            )
            
            Spacer()
            
            Text(packageFileSize)
                .font(.footnote)
                .foregroundStyle(StyleManager.colorStyle.systemGray)
        }
        .frame(height: 35)
    }
}

struct AppIconView: View {
    let iconURL: String?
    
    var body: some View {
        if let iconURL {
            AsyncImage(url: URL(string: iconURL)!) { image in
                image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .fill(.regularMaterial)
                    .frame(width: 40, height: 40)
                    .overlay {
                        ProgressView()
                    }
            }
        }
    }
}

#Preview {
    AppIconView(iconURL: "https://packages-development.zohostratus.com/hariharan.rs@zohocorp.com/SDP/AppIcon60x60@2x.png")
}
