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
        .frame(height: 40)
    }
}

struct AppIconView: View {
    let iconURL: String?
    let icon: Data?
    private var width: CGFloat
    private var height: CGFloat
    
    init(iconURL: String?, width: CGFloat = 40, height: CGFloat = 40) {
        self.iconURL = iconURL
        self.width = width
        self.height = height
        self.icon = nil
    }
    
    init(icon: Data?, width: CGFloat = 40, height: CGFloat = 40) {
        self.icon = icon
        self.width = width
        self.height = height
        self.iconURL = nil
    }
    
    var body: some View {
        if let iconURL {
            AsyncImage(url: URL(string: iconURL)!) { image in
                image
                    .resizable()
                    .frame(width: width, height: height)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .fill(.regularMaterial)
                    .frame(width: width, height: height)
                    .overlay {
                        ProgressView()
                    }
            }
        }else if let iconData = icon {
            Image(uiImage: UIImage(data: iconData)!)
                .resizable()
                .frame(width: width, height: height)
                .clipShape(Circle())
        }
    }
}
